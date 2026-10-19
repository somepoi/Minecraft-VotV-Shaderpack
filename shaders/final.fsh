#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/post.glsl"
uniform sampler2D colortex0;
in vec2 vUV;
void main() {
    float underwater=isEyeInWater==1 ? UNDERWATER_DISTORTION : 0.0;
    vec2 uv=vtPostUV(vUV,underwater);
    vec2 halfPixel=0.5/max(vec2(viewWidth,viewHeight),vec2(1.0));
    vec3 colour=texture(colortex0,clamp(uv,halfPixel,1.0-halfPixel)).rgb*EXPOSURE;
    if(underwater>0.0) {
        float amount=pow(underwater,1.5);
        vec3 blue=colour*vec3(0.5,0.625,1.0)*(1.0-clamp(length(vUV-0.5)*2.0*amount,0.0,1.0));
        colour=mix(colour,blue,0.8*amount);
    }
    gl_FragColor=vec4(vtQuantize(colour,gl_FragCoord.xy),1.0);
}
