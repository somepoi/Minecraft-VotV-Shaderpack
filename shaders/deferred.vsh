#version 330 compatibility
out vec2 vUV;
void main() {
    gl_Position = ftransform();
    vUV = gl_MultiTexCoord0.xy;
}
