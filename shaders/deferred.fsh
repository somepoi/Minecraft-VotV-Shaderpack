#version 330 compatibility
/* DRAWBUFFERS:05 */
uniform sampler2D colortex0;
in vec2 vUV;
void main() {
    vec4 scene = texture(colortex0, vUV);
    // Preserve the ordinary Minecraft sky and snapshot the opaque scene for water.
    gl_FragData[0] = scene;
    gl_FragData[1] = scene;
}
