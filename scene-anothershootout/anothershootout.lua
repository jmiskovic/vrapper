local palette = require'scene-anothershootout/palette-anotherworld'
local icosphere = require'geometry/icosphere'
local shader = require'fogShader'
local avatar = require'avatar'
local physics = require'physics'

local m = {}

local dome
local colorCycler = 1
local cc = colorCycler
local onDesktop = false
local pewSound = lovr.audio.newSource('scene-anothershootout/pewpew.ogg', 'static')
local hitSound = lovr.audio.newSource('scene-anothershootout/rayhit.ogg', 'static')

local rays = {}

function m.load()
  lovr.graphics.setBackgroundColor(palette[14])
  shader:send('fogColor', {lovr.graphics.getBackgroundColor()})
  shader:send('fogStrength', 0.1)
  local vertices, indices = icosphere(1)
  dome = lovr.graphics.newMesh(vertices, 'triangles')
  dome:setVertexMap(indices)
  -- ground
  local ground = physics:box(150, 2, 150, {position= vec3(0, -1, 0), kinematic= true, color= palette[11]})
  for i= 1, 30 do
    physics:box(.05 + math.random()*.3, .35 + math.random()*.3, .05 + math.random()*.3, 
      {position= vec3(-3 + math.random()*6, math.random()*5, -5+math.random()*5),
      color= palette[math.random(19,20)]})
  end
  onDesktop = lovr.headset.getName() == 'Simulator'
end


function m:update(dt)
  --helper for selecting colors
  colorCycler = (colorCycler + dt * 2) % #palette
  cc = math.floor(colorCycler) + 1
  -- gunfire
  local hand = avatar.hands[2] or avatar.hands[1]
  if hand.triggerPress then
    pewSound:stop()
    pewSound:setPitch(0.9 + 0.1 * math.random())
    pewSound:play()
    local hits = physics:raycast(hand.VRtransform, 0.2, 100) -- shooting ray
    local from = lovr.math.newVec3(hand.VRtransform:mul(vec3(0,0.055, -0.16)))
    local to
    if hits[1] then
      to = lovr.math.newVec3(hits[1].position)
      hits[1].collider:applyForce((quat(hand.VRtransform):direction() * dt * 150000):unpack())
      hitSound:stop()
      hitSound:setPitch(0.9 + 0.1 * math.random())
      hitSound:play()
    else
      to = lovr.math.newVec3(hand.VRtransform:mul(vec3(0,0,-100)))
    end
    table.insert(rays, 1, {from = from, to = to, lifetime = 0})
  end
  for i,ray in ipairs(rays) do
    ray.lifetime = ray.lifetime + dt
    if ray.lifetime > 0.2 then
      rays[i] = nil
    end
  end
end


function drawGun()
  local hand = avatar.hands[2] or avatar.hands[1]
  lovr.graphics.push()
  lovr.graphics.transform(hand.VRtransform)
  lovr.graphics.setColor(palette[1])
  stroke(vec3(0, 0.06, 0.03), vec3(0, 0, -0.18), 0, 0.02, 0.02)
  lovr.graphics.setColor(palette[4])
  stroke(vec3(0, 0.05, 0.02), vec3(0, 0, -0.15), 0, 0.026, 0.042)
  lovr.graphics.setColor(palette[2])  --handle
  stroke(vec3(0, 0.06, -0.01), vec3(0, -0.11, 0.02), 0, 0.025, 0.04)
  lovr.graphics.pop()
end


function circleOf(drawFunction, loc, r, count, faceOut)
  for id = 1, count do
    local a = id * 2 * math.pi / count
    lovr.graphics.push()
    lovr.graphics.translate(loc)
    lovr.graphics.translate(r * math.cos(a), 0, r * math.sin(a))
    lovr.graphics.rotate(faceOut and -a or 0, 0, 1, 0)
    drawFunction(id)
    lovr.graphics.pop()
  end
end

function city(size, lod)
  local averageHeight = 7
  local scraperHeight = 30
  lovr.graphics.setColor(palette[2])
  if not onDesktop then
    lovr.graphics.cylinder(vec3(0, 0, -80), (1 - lod) * averageHeight,
                           math.pi/2, 1, 0, 0,
                           size * 0.9, size * 0.9, true, 7)
  end
  circleOf(
    function(id)
      math.randomseed(id)
      local height = 5 + 4 * math.random() + math.floor(math.random() * 1.2) * 30 * math.random()
      local offset = 8 * math.random()
      stroke(vec3(offset,0,2 * offset), vec3(0,height,0), 0, 3, 6)
    end,
    vec3(0, 0, -80),
    size / 2, 30, true)
  if not onDesktop then
    dome:draw(17, -15, -65, 20)
  end
end


function m:draw()
  local t = lovr.timer.getTime()
  lovr.graphics.setColor(palette[cc])
  lovr.graphics.setShader(shader)
  drawGun()
  city(20, 0)
  math.randomseed(t)
  for i,ray in ipairs(rays) do
    lovr.graphics.setColor(palette[ray.lifetime < 0.1 and 13 or 10])
    strokeTo(ray.from, ray.to, 0, 0.05, 0.02)
    lovr.graphics.setColor(palette[23])
    lovr.graphics.sphere(ray.to, 0.08)
  end
end

return m
