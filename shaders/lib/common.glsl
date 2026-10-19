#ifndef VT_COMMON
#define VT_COMMON
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 cameraPosition;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform float fogStart;
uniform float fogEnd;
uniform float fogDensity;
uniform int fogMode;
uniform int fogShape;
uniform int isEyeInWater;
uniform int worldTime;
#endif
