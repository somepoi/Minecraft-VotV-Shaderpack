#include "/lib/settings.glsl"
#include "/lib/common.glsl"
out vec4 vColor;
out vec2 vUV;
out vec2 vLightUV;
out vec3 vFogPosition;
out vec3 vScenePosition;
out vec3 vSceneNormal;
#ifdef GS_TERRAIN
in vec2 mc_midTexCoord;
out vec2 vMid;
out vec2 vHalfSpan;
#endif
#ifdef GS_WATER
in vec4 mc_Entity;
out vec3 vWorldPosition;
out vec3 vWaterViewPosition;
flat out vec3 vWorldNormal;
flat out float vIsWater;
flat out vec2 vWaterHalfSpan;
#endif

void main() {
    vec4 view = gl_ModelViewMatrix * gl_Vertex;
    gl_Position = gl_ProjectionMatrix * view;
    // Cylindrical fog needs camera-relative world axes, not rotated view axes.
    vFogPosition = mat3(gbufferModelViewInverse) * view.xyz;
    vScenePosition = (gbufferModelViewInverse * view).xyz;
    vec3 sceneNormal = mat3(gbufferModelViewInverse) * gl_NormalMatrix * gl_Normal;
    // Some particle/weather formats do not supply a meaningful normal.
    vSceneNormal = sceneNormal * inversesqrt(max(dot(sceneNormal, sceneNormal), 1e-8));
    vColor = gl_Color;
    vUV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vLightUV = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
#ifdef GS_TERRAIN
    vMid = (gl_TextureMatrix[0] * vec4(mc_midTexCoord, 0.0, 1.0)).xy;
    vHalfSpan = abs(vUV - vMid);
#endif
#ifdef GS_WATER
    vWorldPosition = (gbufferModelViewInverse * view).xyz + cameraPosition;
    vWaterViewPosition = view.xyz;
    vWorldNormal = normalize(mat3(gbufferModelViewInverse) * gl_NormalMatrix * gl_Normal);
    vIsWater = abs(mc_Entity.x - 10001.0) < 0.5 ? 1.0 : 0.0;
    // Keep the density constant across the triangle, including rotated flow UVs.
    vWaterHalfSpan = vHalfSpan;
#endif
}
