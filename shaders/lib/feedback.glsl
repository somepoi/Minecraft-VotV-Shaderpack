#ifndef GS_FEEDBACK
#define GS_FEEDBACK
uint gsHash(uint v) {
    v ^= v >> 16u;
    v *= 0x7feb352du;
    v ^= v >> 15u;
    v *= 0x846ca68bu;
    return v ^ (v >> 16u);
}
float gsDrop(ivec2 p, int tick) {
#if RIPPLE_DROPS == 0
    return 0.0;
#else
    if (tick % DROP_EVERY_TICKS != 0) return 0.0;
    uint h = gsHash(uint(tick / DROP_EVERY_TICKS) + 73421u);
    ivec2 center = ivec2(int(h & 127u), int((h >> 7u) & 127u));
    ivec2 d = abs(p - center);
    d = min(d, ivec2(128) - d);
    float strength = float((h >> 16u) & 1023u);
    if (d.x + d.y == 0) return strength;
    if (d.x + d.y == 1) return floor(strength / 4.0);
    return 0.0;
#endif
}
vec2 gsState(sampler2D field, int index, int tick) {
    // Linear wrapping matches the reference stencil at row boundaries too.
    int i = (index + 16384) % 16384;
    ivec2 p = ivec2(i % 128, i / 128);
    vec2 pair = texelFetch(field, p, 0).rg;
    pair.x += gsDrop(p, tick);
    return pair;
}
vec2 gsWaveStep(sampler2D field, ivec2 p, int tick) {
    int i = p.y * 128 + p.x;
    vec2 center = gsState(field, i, tick);
    float neighbors = gsState(field, i - 128, tick).x + gsState(field, i + 128, tick).x
                    + gsState(field, i - 1, tick).x + gsState(field, i + 1, tick).x;
    float next = floor(neighbors * 0.5) - center.y;
    next -= floor(next / 64.0);
    return vec2(clamp(next, -32768.0, 32767.0), center.x);
}
#endif
