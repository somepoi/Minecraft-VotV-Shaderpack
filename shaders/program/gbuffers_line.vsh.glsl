out vec4 vColor;
void main() {
    // Oculus VanillaTransformer wraps this entrypoint to widen modern lines.
    // Keep the position transform linear; do not extrude a second time here.
    gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
    vColor = gl_Color;
}
