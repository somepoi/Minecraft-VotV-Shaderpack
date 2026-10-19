#ifndef VT_POST
#define VT_POST
#include "/lib/settings.glsl"
uniform sampler2D vtDitherMask;
// Extracted PP_main quantizer: ten 4x4 mask strips, 16 colour levels by default.
// Scene shader stays at normal precision until this final presentation pass.
vec3 vtQuantize(vec3 colour, vec2 pixel) {
    vec3 c=clamp(colour,0.0,1.0);
#if RETRO_COLOUR == 1
    float levels=float(COLOUR_LEVELS-1);
    vec3 scaled=c*levels;
#if DITHERING == 1
    ivec2 cell=ivec2(mod(floor(pixel),4.0));
    ivec3 strips=ivec3(floor(clamp(fract(scaled)-0.1,0.0,1.0)*10.0+0.5));
    vec3 mask=vec3(texelFetch(vtDitherMask,ivec2(cell.x+4*strips.x,cell.y),0).r,
                   texelFetch(vtDitherMask,ivec2(cell.x+4*strips.y,cell.y),0).r,
                   texelFetch(vtDitherMask,ivec2(cell.x+4*strips.z,cell.y),0).r);
    vec3 quantized = floor(scaled+0.5)/levels;
    vec3 dithered = (floor(scaled)+mask)/levels;
    return clamp(mix(quantized,dithered,clamp(DITHER_STRENGTH,0.0,1.0)),0.0,1.0);
#else
    return floor(scaled+0.5)/levels;
#endif
#else
    return c;
#endif
}
vec2 vtPostUV(vec2 uv,float underwater) {
    // PP_main's radial underwater branch. Guard the centre (source divides by
    // radius) and adapt activation to Minecraft's isEyeInWater flag.
    float amount=pow(clamp(underwater,0.0,1.0),1.5);
    vec2 p=uv*2.0-1.0;float radius=length(p);
    if(radius<1e-7)return uv;
    float exponent=mix(1.0,mix(1.0,2.0,amount),pow(radius,2.0));
    vec2 warped=(p/radius*pow(radius,exponent)+1.0)*0.5;
    float zoom=amount*0.5;
    return warped*(1.0-zoom)+0.5*zoom;
}
#endif
