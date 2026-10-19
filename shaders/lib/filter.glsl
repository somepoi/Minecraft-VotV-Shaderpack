#ifndef GS_FILTER
#define GS_FILTER
// Bounds are a conservative UV rectangle, NOT atlas sprite metadata.
// Four exact texelFetch calls are independent of the GL sampler filter.
vec4 gsBilinear(sampler2D image, vec2 uv, vec4 bounds, int level) {
    ivec2 size = textureSize(image, level);
    vec2 p = uv * vec2(size) - 0.5;
    ivec2 base = ivec2(floor(p));
    vec2 f = fract(p);
    // Tolerance absorbs the tiny UV contraction/quantization in terrain buffers.
    ivec2 low = clamp(ivec2(floor(bounds.xy * vec2(size) + 0.02)), ivec2(0), size - 1);
    ivec2 high = clamp(ivec2(ceil(bounds.zw * vec2(size) - 0.02)) - 1, low, size - 1);
    vec4 a = texelFetch(image, clamp(base, low, high), level);
    vec4 b = texelFetch(image, clamp(base + ivec2(1, 0), low, high), level);
    vec4 c = texelFetch(image, clamp(base + ivec2(0, 1), low, high), level);
    vec4 d = texelFetch(image, clamp(base + ivec2(1, 1), low, high), level);
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float gsFootprint(sampler2D image, vec2 dx, vec2 dy) {
    vec2 size = vec2(textureSize(image, 0));
    return max(length(dx * size), length(dy * size));
}

vec4 gsNearest(sampler2D image, vec2 uv) {
    ivec2 size = textureSize(image, 0);
    return texelFetch(image, clamp(ivec2(floor(fract(uv) * vec2(size))), ivec2(0), size - 1), 0);
}
vec4 gsSurface(sampler2D image, vec2 uv, vec2 mid, vec2 halfSpan) {
    // Derivatives are taken before divergent branches, including water selection.
    vec2 dx = dFdx(uv), dy = dFdy(uv);
    vec4 nativeSample = textureGrad(image, uv, dx, dy);
#if FILTER_MODE == 0
    return nativeSample;
#else
    vec2 size = vec2(textureSize(image, 0));
    vec2 span = halfSpan * 2.0 * size;
    // For a rectangular quad, abs(vertexUV-midUV) is constant. Rotated/irregular
    // UV quads generally vary; retain native sampling rather than guess bounds.
    float variation = length(dFdx(halfSpan) * size) + length(dFdy(halfSpan) * size);
    bool usable = all(greaterThanEqual(span, vec2(0.95))) && variation < 0.001;
    if (!usable) return nativeSample;
    vec4 bounds = vec4(mid - halfSpan, mid + halfSpan);
    float rho = gsFootprint(image, dx, dy);
#if FILTER_MODE == 1
    vec4 nearSample = gsBilinear(image, uv, bounds, 0);
    return mix(nearSample, nativeSample, smoothstep(1.0, 2.0, rho));
#else
    // Avoid levels coarser than the face's UV extent. Existing mip levels are
    // supplied by Minecraft, not created by this pack. See README.md.
    // Match the bound rounding tolerance above: a contracted 16-texel face
    // must still be allowed to reach mip 4 rather than being rounded to mip 3.
    float faceMax = floor(log2(max(min(span.x, span.y) + 0.04, 1.0)));
    float maxLevel = min(float(ATLAS_MIP_LEVELS), faceMax);
    float lod = clamp(log2(max(rho, 0.0001)), 0.0, maxLevel);
#if FILTER_MODE == 5
    ivec2 levelSize = textureSize(image, 0);
    ivec2 low = clamp(ivec2(floor(bounds.xy * vec2(levelSize) + 0.02)), ivec2(0), levelSize - 1);
    ivec2 high = clamp(ivec2(ceil(bounds.zw * vec2(levelSize) - 0.02)) - 1, low, levelSize - 1);
    return texelFetch(image, clamp(ivec2(floor(uv * vec2(levelSize))), low, high), 0);
#elif FILTER_MODE == 4
    int level = int(floor(lod + 0.5));
    ivec2 levelSize = textureSize(image, level);
    ivec2 low = clamp(ivec2(floor(bounds.xy * vec2(levelSize) + 0.02)), ivec2(0), levelSize - 1);
    ivec2 high = clamp(ivec2(ceil(bounds.zw * vec2(levelSize) - 0.02)) - 1, low, levelSize - 1);
    return texelFetch(image, clamp(ivec2(floor(uv * vec2(levelSize))), low, high), level);
#elif FILTER_MODE == 3
    return gsBilinear(image, uv, bounds, int(floor(lod + 0.5)));
#else
    int low = int(floor(lod));
    int high = min(low + 1, int(maxLevel));
    return mix(gsBilinear(image, uv, bounds, low),
               gsBilinear(image, uv, bounds, high), fract(lod));
#endif
#endif
#endif
}

vec4 gsModel(sampler2D image, vec2 uv) {
#if MODEL_FILTER == 2
    ivec2 size = textureSize(image, 0);
    return texelFetch(image, clamp(ivec2(floor(fract(uv) * vec2(size))), ivec2(0), size - 1), 0);
#endif
    vec2 dx = dFdx(uv), dy = dFdy(uv);
    vec4 nativeSample = textureGrad(image, uv, dx, dy);
#if MODEL_FILTER == 1
    return mix(gsBilinear(image, uv, vec4(0.0, 0.0, 1.0, 1.0), 0),
               nativeSample, smoothstep(1.0, 2.0, gsFootprint(image, dx, dy)));
#else
    return nativeSample;
#endif
}
#endif
