#ifndef VT_NORMALS
#define VT_NORMALS
#include "/lib/settings.glsl"
#include "/lib/common.glsl"
// RG maps from the user's VotV installation. Mips are packed individually in
// the base image, never generated over atlas borders by the GL driver.
uniform sampler2D noisetex;
uniform sampler2D colortex4;
#include "/lib/ripple.glsl"
vec2 vtNormalRG(int layer, vec2 uv, int level) {
    int baseSize = layer == 3 ? 512 : 1024;
    int size = max(baseSize >> level, 1);
    ivec2 origin = ivec2(layer * 1024, 0);
    if (level > 0) origin += ivec2(baseSize - (baseSize >> (level - 1)), baseSize);
    ivec2 p = ivec2(mod(floor(fract(uv) * float(size)), float(size)));
    return texelFetch(noisetex, origin + p, 0).rg;
}
vec3 vtDecode(vec2 rg) {
    vec2 xy = rg * 2.0 - 1.0;
    return vec3(xy, sqrt(clamp(1.0 - dot(xy, xy), 0.0, 1.0)));
}
vec3 vtSafeNormal(vec3 n) { return n * inversesqrt(max(dot(n, n), 1e-8)); }
vec3 vtSampleNormal(int layer, vec2 uv, vec2 dx, vec2 dy) {
    float size = layer == 3 ? 512.0 : 1024.0;
    float lod = clamp(log2(max(max(length(dx), length(dy)) * size, 1.0)), 0.0, log2(size));
    int level = int(floor(lod + 0.5));
    return vtDecode(vtNormalRG(layer, uv, level));
}
vec3 vtRiverLayer(int layer, vec2 uv, vec2 dx, vec2 dy) {
    vec3 d = vtSampleNormal(layer, uv, dx, dy);
    // Unusual remap and flat-normal blend found in recovered River material.
    return mix(vec3(d.x, 1.0 - d.y, d.z) - vec3(0.5, 0.5, 0.0), vec3(0, 0, 1), 0.75);
}
vec3 vtTangentNormal(vec2 plane, vec2 planeDx, vec2 planeDy) {
    vec3 n;
#if WATER_STYLE == 2
    // Unreal XY/cm -> Minecraft surface plane/blocks. Constants from recovered
    // mat_gldsrcQuakeWater. No vertex displacement or height simulation.
    vec2 w = plane * (100.0 / WATER_SCALE);
    vec2 dx = planeDx * (100.0 / WATER_SCALE), dy = planeDy * (100.0 / WATER_SCALE);
    vec2 waveTexels = plane * WATER_TEXELS;
    vec2 displacement = gsRippleOffset(colortex4, waveTexels);
    // Software Renderer wave field drives UV displacement; VotV water_n remains the material detail.
    vec2 uv = w * 0.01 + displacement / 512.0;
    vec3 a = vtSampleNormal(3, uv, dx * 0.01, dy * 0.01);
    vec2 slope = gsRippleSlope(colortex4, waveTexels);
    n = vtSafeNormal(a + vec3(slope * 0.35, 0.0));
#else
    // Adapted density: Minecraft has no source spline mesh UVs.
    vec2 scale = vec2(1.0, 2.0) / (4.0 * 0.333333 * WATER_SCALE);
    vec2 uv = plane * scale, dx = planeDx * scale, dy = planeDy * scale;
    // Chosen mapping of Inst_waterRiver flow vectors, centred on .5.
    // A common 400-second period wraps all three offsets by integer UVs.
    float t = mod(frameTimeCounter * FLOW_SPEED, 400.0) * 0.75;
    vec3 a = vtRiverLayer(0, uv + vec2(-0.35, -0.01) * t, dx, dy);
    vec3 b = vtRiverLayer(1, uv + vec2(-0.40, 0.02) * t, dx, dy);
    vec3 c = vtRiverLayer(2, uv + vec2(-0.50, 0.01) * t, dx, dy);
    n = vtSafeNormal(mix(vtSafeNormal(mix(a, b, 0.5)), c, 0.5));
#endif
    return vtSafeNormal(vec3(n.xy * NORMAL_STRENGTH, max(n.z, 0.0001)));
}
#endif
