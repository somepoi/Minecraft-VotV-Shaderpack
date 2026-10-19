#include "/lib/settings.glsl"
#include "/lib/filter.glsl"
#ifdef GS_WATER
in vec3 vWorldPosition;
in vec3 vWaterViewPosition;
flat in vec3 vWorldNormal;
flat in float vIsWater;
flat in vec2 vWaterHalfSpan;
#include "/lib/votv_water.glsl"
#endif
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform float alphaTestRef;
#ifdef GS_ENTITY
uniform vec4 entityColor;
#endif
in vec4 vColor;
in vec2 vUV;
in vec2 vLightUV;
in vec3 vFogPosition;
in vec3 vScenePosition;
in vec3 vSceneNormal;
#ifdef GS_TERRAIN
in vec2 vMid;
in vec2 vHalfSpan;
#endif

float gsVisibility() {
    float dist = fogShape == 1 ? max(length(vFogPosition.xz), abs(vFogPosition.y)) : length(vFogPosition);
    if (fogMode == 9729) return 1.0 - clamp((dist - fogStart) / max(fogEnd - fogStart, 0.0001), 0.0, 1.0);
    if (fogMode == 2048) return exp(-fogDensity * dist);
    if (fogMode == 2049) return exp(-pow(fogDensity * dist, 2.0));
    return 1.0;
}

void main() {
    bool composedWater = false;
    float visibility=gsVisibility();
    float totalFog=1.0-visibility;
    vec3 fogTint=fogColor;
    vec3 lightValue=vec3(1.0);
#if GS_LIT == 1
    vec3 vanillaLight=textureLod(lightmap,clamp(vLightUV,vec2(0.03125),vec2(0.96875)),0.0).rgb;
    lightValue=vanillaLight;
#endif
#ifdef GS_WATER
    vec3 face = abs(vWorldNormal);
    vec2 plane = face.y >= max(face.x, face.z) ? vWorldPosition.xz :
                 (face.x > face.z ? vWorldPosition.zy : vWorldPosition.xy);
    // Evaluate derivatives before selection between water and glass.
    vec2 planeDx = dFdx(plane), planeDy = dFdy(plane);
#endif
    vec4 surface = vec4(1.0);
#if GS_TEXTURED == 1
#ifdef GS_TERRAIN
    surface = gsSurface(gtexture, vUV, vMid, vHalfSpan);
#elif defined(GS_MODEL)
    surface = gsModel(gtexture, vUV);
#else
    surface = gsNearest(gtexture, vUV);
#endif
#endif
    vec4 color = surface * vColor;
#ifdef GS_WATER
#if WATER_STYLE > 0
    if (vIsWater > 0.5) {
        vec3 axis=abs(vWorldNormal);
        float spriteTexels=vtWaterDensity(vWaterHalfSpan,vec2(textureSize(gtexture,0)),axis.y>=max(axis.x,axis.z));
        color = vtWater(plane, planeDx, planeDy, spriteTexels, vWorldNormal, vWaterViewPosition,
                        vColor.rgb, lightValue, 1.0-totalFog, fogTint);
        composedWater = true;
    }
#endif
#endif
    if (color.a < alphaTestRef) discard;
#if GS_LIT == 1
    if (!composedWater) color.rgb *= lightValue;
#endif
#ifdef GS_ENTITY
    color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
#endif
#if GS_FOG == 1
#ifdef GS_ADDITIVE
    color.rgb *= 1.0-totalFog;
#else
    if (!composedWater) color.rgb = mix(fogTint, color.rgb, 1.0-totalFog);
#endif
#endif
    gl_FragData[0] = color;
}
