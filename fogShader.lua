return lovr.graphics.newShader([[
out float depth;
vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
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
uniform float fogStrength;

in float depth;
vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
  float fogAmount = clamp(depth * fogStrength / 10.0, 0.0, 1.1);
  vec4 c = graphicsColor * lovrDiffuseColor * vertexColor * texture(image, uv);
  return mix(c, vec4(toLinear(fogColor), 1), fogAmount);
}
]])