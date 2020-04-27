return lovr.graphics.newShader([[
uniform float roundness = 0.5;
out float depth;
vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
		float modulator = mix(1, -sin(vertex.z * 2.6 - 0.2), roundness);
    vertex.xy = vertex.xy * 0.2 * modulator;
    vec4 result = projection * transform * vertex;
    depth = result.z;
    return result;
}
]], [[
vec3 toLinear(vec3 sRGB) {
  const float gamma = 2.23;
  return pow(sRGB, vec3(gamma));
} 

uniform vec3 fogColor;
const float fogStrength = 1.0 / 1000.0;

in float depth;
vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
  float fogAmount = clamp(depth * fogStrength, 0.0, 1.1);
  vec4 c = graphicsColor * lovrDiffuseColor * vertexColor * texture(image, uv);
  return mix(c, vec4(toLinear(fogColor), 1), fogAmount);
}
]])
