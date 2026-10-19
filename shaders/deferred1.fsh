#version 330 compatibility
/* DRAWBUFFERS:4 */
#include "/lib/settings.glsl"
#include "/lib/feedback.glsl"
const int colortex4Format = RGBA32F;
const bool colortex4Clear = false;
const vec4 colortex4ClearColor = vec4(0.0);
uniform sampler2D colortex4;
uniform float frameTimeCounter;
uniform int frameCounter;
void main() {
    ivec2 p = ivec2(gl_FragCoord.xy);
    vec4 old = texelFetch(colortex4, p, 0);
    float tick = floor(frameTimeCounter * 20.0 * FLOW_SPEED);
    if (frameCounter < 2 || old.a < 0.5 || tick < old.b || any(isnan(old)) || any(isinf(old))) {
        gl_FragData[0] = vec4(0.0, 0.0, tick, 1.0);
    } else if (tick > old.b) {
        gl_FragData[0] = vec4(gsWaveStep(colortex4, p, int(tick)), tick, 1.0);
    } else {
        gl_FragData[0] = old;
    }
}
