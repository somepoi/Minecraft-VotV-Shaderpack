#ifndef GS_RIPPLE
#define GS_RIPPLE
// A persistent, discrete wave field; no crossed sinusoidal UV animation.
float gsRippleHeight(sampler2D field, vec2 texels) {
    return texelFetch(field, ivec2(mod(floor(texels), 128.0)), 0).r;
}
vec2 gsRippleOffset(sampler2D field, vec2 texels) {
    float displacement = floor(gsRippleHeight(field, texels) / 16.0) * (WATER_AMPLITUDE / 8.0);
    return vec2(displacement, -displacement);
}
vec2 gsRippleSlope(sampler2D field, vec2 texels) {
    float x = gsRippleHeight(field, texels + vec2(1.0, 0.0)) - gsRippleHeight(field, texels - vec2(1.0, 0.0));
    float y = gsRippleHeight(field, texels + vec2(0.0, 1.0)) - gsRippleHeight(field, texels - vec2(0.0, 1.0));
    return clamp(vec2(x, y) / 180.0, vec2(-0.4), vec2(0.4));
}
#endif
