return lovr.graphics.newShader([[
uniform float iTime2;
out float depth;
vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
    vec4 result = projection * transform * vertex;
    depth = result.z;
    /* wobbling
    result.x += 0.01f * sin(5.0f * iTime2 + vertex.x);
    result.y += 0.12f * sin(6.0f * iTime2 + vertex.x);
    result.z += 0.01f * sin(5.0f * iTime2 + vertex.x);
    */
    return result;
}
]], [[
uniform float iTime;
const float gamma = 2.23;
const float fogStrength = 1 / 500.0;
vec4 cFog = pow(vec4(0.271, 0.314, 0.431, 1.0), vec4(gamma));

in float depth;
vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
  float fog = clamp(depth * fogStrength + 0.0 * sin(iTime), 0.0, 1.1);
  vec4 c = graphicsColor * lovrDiffuseColor * vertexColor * texture(image, uv);
  //return mix(c, cFog, fog);
  //c.a = 1;
  //c.r = 0;
  //c.g = 0;
  //c.a = 1 - pow(length(vec2(0.5,0.5) - uv), 0.3);
  c.r = uv.x;
  c.b = uv.y;
  return c;

}
]])