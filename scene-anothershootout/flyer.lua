function update():
end


function draw():
  plank(vec3(0, 0, -0.5), vec3(0, 0, 0.5), 0, palette[18], 0.6)
  plank(vec3(0, 0, -0.5), vec3(0, 1, -0.6), 0, palette[13], 0.1)
  plank(vec3(-0.3, 1, -0.6), vec3(0.3, 1, -0.6), 0.5, palette[21], 0.2)
end
