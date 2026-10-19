#version 330 compatibility
/* DRAWBUFFERS:0 */
in vec4 vColor;
void main() {
    gl_FragData[0] = vColor;
}
