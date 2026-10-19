// Reconstructed from shipped Vulkan SPIR-V; not original author source.
#version 450

layout(set = 1, binding = 1, std140) uniform type_View
{
    layout(offset = 2080) vec4 View_ViewSizeAndInvSize;
} View;

layout(set = 1, binding = 2, std140) uniform type_MaterialCollection0
{
    vec4 MaterialCollection0_Vectors[1];
} MaterialCollection0;

layout(set = 1, binding = 3, std140) uniform type_MaterialCollection1
{
    vec4 MaterialCollection1_Vectors[1];
} MaterialCollection1;

layout(set = 1, binding = 4, std140) uniform type_Material
{
    vec4 Material_VectorExpressions[2];
    vec4 Material_ScalarExpressions[1];
} Material;

layout(set = 1, binding = 0, std140) uniform type_Globals
{
    layout(offset = 0) vec2 PostProcessInput_0_UVViewportMin;
    layout(offset = 8) vec2 PostProcessInput_0_UVViewportSize;
    layout(offset = 16) vec2 PostProcessInput_0_UVViewportBilinearMin;
    layout(offset = 24) vec2 PostProcessInput_0_UVViewportBilinearMax;
    layout(offset = 160) uvec2 PostProcessOutput_ViewportMin;
    layout(offset = 168) vec2 PostProcessOutput_ViewportSizeInverse;
} _Globals;

layout(set = 1, binding = 7) uniform texture2D Material_Texture2D_0;
layout(set = 1, binding = 5) uniform sampler Material_Texture2D_0Sampler;
layout(set = 1, binding = 8) uniform texture2D PostProcessInput_0_Texture;
layout(set = 1, binding = 6) uniform sampler PostProcessInput_BilinearSampler;

layout(location = 0) in vec4 in_var_TEXCOORD0[1];
layout(location = 0) out vec4 out_var_SV_Target0;

void main()
{
    vec2 _94 = (gl_FragCoord.xy - vec2(_Globals.PostProcessOutput_ViewportMin)) * _Globals.PostProcessOutput_ViewportSizeInverse;
    vec2 _96 = (_94 * 2.0) - vec2(1.0);
    float _98 = sqrt(dot(_96, _96));
    float _106 = (MaterialCollection0.MaterialCollection0_Vectors[0].w <= 0.0) ? 0.0 : pow(MaterialCollection0.MaterialCollection0_Vectors[0].w, 1.5);
    bool _110 = _98 <= 0.0;
    float _119 = mix(0.0, 0.5, _106);
    vec4 _139 = vec4(_Globals.PostProcessInput_0_UVViewportBilinearMin, _Globals.PostProcessInput_0_UVViewportBilinearMax);
    vec4 _146 = texture(sampler2D(PostProcessInput_0_Texture, PostProcessInput_BilinearSampler), clamp((((((((_96 / vec2(_98)) * (_110 ? 0.0 : pow(_98, mix(1.0, mix(1.0, 2.0, _106), _110 ? 0.0 : pow(_98, Material.Material_ScalarExpressions[0].x))))) + vec2(1.0)) * vec2(0.5)) * mix(1.0, 0.0, _119)) + vec2(mix(0.0, 0.5, _119))) * _Globals.PostProcessInput_0_UVViewportSize) + _Globals.PostProcessInput_0_UVViewportMin, _139.xy, _139.zw));
    float _147 = _146.x;
    float _148 = _146.y;
    float _150 = _146.z;
    float _151 = max(max(_147, _148), _150);
    float _154 = _151 - min(min(_147, _148), _150);
    vec3 _163 = (((vec3(_151) - _146.xyz) * vec3(0.16666667163372039794921875)) + vec3(_154 * 0.5)) / vec3(_154);
    float _164 = _163.y;
    float _166 = _163.x;
    float _173 = _163.z;
    float _183 = (abs(_151 - _147) > 9.9999997473787516355514526367188e-06) ? ((abs(_148 - _151) > 9.9999997473787516355514526367188e-06) ? ((abs(_150 - _151) > 9.9999997473787516355514526367188e-06) ? 0.0 : ((0.66666698455810546875 + _164) - _166)) : ((0.3333329856395721435546875 + _166) - _173)) : (_173 - _164);
    float _189 = _183 + ((abs(_183) > 9.9999997473787516355514526367188e-06) ? ((_183 >= 0.0) ? 0.0 : 1.0) : 0.0);
    bool _198 = abs(_154) > 9.9999997473787516355514526367188e-06;
    float _204 = mod((_198 ? (((abs(_189 - 1.0) > 9.9999997473787516355514526367188e-06) ? ((_189 >= 1.0) ? (-1.0) : 0.0) : 0.0) + _189) : 0.0) + MaterialCollection0.MaterialCollection0_Vectors[0].z, 1.0);
    vec3 _232 = mix(vec3(1.0), vec3(clamp((abs((mod(_204 + 1.0, 1.0) * 2.0) - 1.0) * 3.0) - 1.0, 0.0, 1.0), clamp((abs((mod(_204 + 0.66666698455810546875, 1.0) * 2.0) - 1.0) * 3.0) - 1.0, 0.0, 1.0), clamp((abs((mod(_204 + 0.33333301544189453125, 1.0) * 2.0) - 1.0) * 3.0) - 1.0, 0.0, 1.0)), vec3(_198 ? (_154 / _151) : 0.0)) * _151;
    float _237 = round(MaterialCollection1.MaterialCollection1_Vectors[0].x) - 1.0;
    vec3 _238 = _232 * _237;
    vec3 _239 = floor(_238);
    vec3 _240 = vec3(_237);
    vec3 _241 = _239 / _240;
    vec3 _243 = (_239 + vec3(1.0)) / _240;
    vec2 _249 = mod(_94 * (View.View_ViewSizeAndInvSize.xy * vec2(0.25)), vec2(1.0));
    vec3 _253 = clamp(clamp(mod(_238, vec3(1.0)), vec3(0.0), vec3(1.0)) - vec3(0.100000001490116119384765625), vec3(0.0), vec3(1.0));
    vec3 _298 = mix(_232, vec3(mix(_241.x, _243.x, texture(sampler2D(Material_Texture2D_0, Material_Texture2D_0Sampler), mod((_249 + vec2(round(_253.x * 10.0))) * vec2(0.100000001490116119384765625, 1.0), vec2(1.0))).x), mix(_241.y, _243.y, texture(sampler2D(Material_Texture2D_0, Material_Texture2D_0Sampler), mod((_249 + vec2(round(_253.y * 10.0))) * vec2(0.100000001490116119384765625, 1.0), vec2(1.0))).x), mix(_241.z, _243.z, texture(sampler2D(Material_Texture2D_0, Material_Texture2D_0Sampler), mod((_249 + vec2(round(_253.z * 10.0))) * vec2(0.100000001490116119384765625, 1.0), vec2(1.0))).x)), vec3(MaterialCollection0.MaterialCollection0_Vectors[0].x));
    vec2 _300 = _94 - vec2(0.5);
    out_var_SV_Target0 = vec4(max(mix(mix(_298, (_298 * vec3(0.5, 0.625, 1.0)) * (1.0 - clamp(sqrt(dot(_300, _300)) * mix(0.0, 2.0, _106), 0.0, 1.0)), vec3(mix(0.0, 0.800000011920928955078125, _106))), Material.Material_VectorExpressions[1].xyz, vec3(Material.Material_ScalarExpressions[0].y)), vec3(0.0)), 1.0);
}

