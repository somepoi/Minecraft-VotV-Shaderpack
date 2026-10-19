#ifndef VT_WATER
#define VT_WATER
#include "/lib/votv_normals.glsl"
#include "/lib/pixels.glsl"
// Oculus gbuffers exposes render-target samplers >=4. Never read colortex0
// while writing it: use the opaque scene snapshot on colortex5.
uniform sampler2D colortex5;
uniform sampler2D depthtex1;
vec3 vtViewAt(vec2 uv, float z) {
    vec4 p = gbufferProjectionInverse * vec4(uv * 2.0 - 1.0, z * 2.0 - 1.0, 1.0);
    return p.xyz / p.w;
}
vec4 vtWater(vec2 plane, vec2 dx, vec2 dy, float spriteTexels, vec3 faceNormal, vec3 viewPosition,
             vec3 tint, vec3 lighting, float visibility, vec3 surfaceFog) {
    vec2 waterPoint=vtWaterCell(plane,spriteTexels);
    vec3 tn = vtTangentNormal(waterPoint, dx, dy);
    vec3 base = normalize(faceNormal);
    vec3 tangent = abs(base.y) > 0.5 ? vec3(1, 0, 0) : (abs(base.x) > 0.5 ? vec3(0, 0, 1) : vec3(1, 0, 0));
    // Flowing water tops can be sloped, so the selected axis is not yet tangent.
    tangent = normalize(tangent - base * dot(tangent, base));
    vec3 bitangent = normalize(cross(tangent, base));
    vec3 n = normalize(tangent * tn.x + bitangent * tn.y + base * tn.z);
    vec3 v = normalize(-mat3(gbufferModelViewInverse) * viewPosition);
    if (dot(n, v) < 0.0) n = -n;
    float f0 = pow((1.33 - 1.0) / (1.33 + 1.0), 2.0);
    float fresnel = f0 + (1.0 - f0) * pow(1.0 - clamp(dot(n, v), 0.0, 1.0), 5.0);
    vec2 viewport = max(vec2(viewWidth, viewHeight), vec2(1.0));
    vec2 screen = gl_FragCoord.xy / viewport;
    vec2 margin = 0.5 / viewport;
    vec3 viewSlope = transpose(mat3(gbufferModelViewInverse)) * (n - base * dot(n, base));
    vec2 offset = viewSlope.xy * vec2(viewHeight / max(viewWidth, 1.0), 1.0) * REFRACTION_STRENGTH;
    vec2 refracted = clamp(screen + offset, margin, 1.0 - margin);
    ivec2 viewportSize = ivec2(viewWidth, viewHeight);
    ivec2 scenePixel = clamp(ivec2(floor(refracted * vec2(viewportSize))), ivec2(0), viewportSize - 1);
    float depth = texelFetch(depthtex1, scenePixel, 0).r;
    if (depth < gl_FragCoord.z - 0.00001) {
        scenePixel = clamp(ivec2(floor(screen * vec2(viewportSize))), ivec2(0), viewportSize - 1);
        depth = texelFetch(depthtex1, scenePixel, 0).r;
    }
    vec3 background = texelFetch(colortex5, scenePixel, 0).rgb;
    float thickness = depth >= 0.99999 ? 16.0 : clamp(length(vtViewAt(refracted, depth)) - length(viewPosition), 0.0, 32.0);
    // Underwater vanilla fog already accounts for the camera-to-scene path.
    if (isEyeInWater == 1) thickness = 0.0;
    vec3 body = mix(vec3(0.10, 0.16, 0.13), clamp(tint, 0.0, 1.0) * 0.36, 0.45) * lighting;
    body = mix(surfaceFog, body, visibility);
    vec3 absorption = vec3(1.0, 0.55, 0.30) * WATER_ABSORPTION;
    vec3 transmittance = exp(-absorption * thickness);
    vec3 result = background * transmittance + body * (1.0 - transmittance);
    // Reflect the vanilla Minecraft sky colour; VotV sky rendering is not included.
    vec3 reflected;
reflected = max(skyColor, vec3(0)) * (0.7 + 0.3 * max(n.y, 0.0)) * lighting;
    reflected = mix(surfaceFog, reflected, visibility);
    result = mix(result, reflected, fresnel * REFLECTION_STRENGTH);
    return vec4(result, 1.0); // Transmission already contains the scene.
}
#endif
