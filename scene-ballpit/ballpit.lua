local palette = require'palette-marshmellow32'
local avatar = require'avatar'
local physics = require'physics'
local shader = require'fogShader'
local m = {}

local boxes = {}
local balls = {}

local function rainBalls() -- yes.
  local spread = 1.5
  local ball = physics:ball(.2 + .15 * math.random())
  ball:setPosition((math.random()-0.5) * spread, 2 + math.random(), (math.random()-0.5) * spread)
  ball:setRestitution(0.8)
  ball:setFriction(0.1)
  table.insert(balls, ball)
end

function m.load()
  lovr.graphics.setBackgroundColor(0.05,0.15,0.25)
  shader:send('fogColor', {lovr.graphics.getBackgroundColor()})
  shader:send('fogStrength', 0.1)
  -- ground
  local ground = physics:box(40, 2, 40)
  ground:setPosition(0, -1, 0)
  ground:setKinematic(true)
  math.randomseed(9)
  ---[[ walls and balls
  local wall
  wall = physics:box(3, 1, .4) wall:setPosition(0,0.41,  1.5) wall:setKinematic(true)
  table.insert(boxes, wall)
  wall = physics:box(3, 1, .4) wall:setPosition(0,0.42, -1.5) wall:setKinematic(true)
  table.insert(boxes, wall)
  wall = physics:box(.4, 1, 3) wall:setPosition(-1.5,0.43, 0) wall:setKinematic(true)
  table.insert(boxes, wall)
  wall = physics:box(.4, 1, 3) wall:setPosition( 1.5,0.44, 0) wall:setKinematic(true)
  table.insert(boxes, wall)
  for i = 1, 15 do
    rainBalls()
  end
  --]]
end


function m:update(dt)
  local hand = avatar.hands[2] or avatar.hands[1]
  if hand.triggering then
  	rainBalls()
  end
end


function m:draw()
  lovr.graphics.setShader(shader)
  math.randomseed(0)
  local size = 5
  -- draw ground
  for x = -size, size do
    for z = -size, size do
      height = 0.2
      if math.abs(x) == size or math.abs(z) == size then
        height = 1
      end
      --height = height + (math.random() > 0.9 and math.random() or 0)
      local r,g,b = unpack(palette[math.random(1,32)])
      lovr.graphics.setColor(r * 0.4, g * 0.4, b * 0.4)
      stroke(vec3(x * 2, -0.2, z * 2), vec3(0, height, 0), 0, 1.8, 1.8)
    end
  end
  -- draw physics boxes
  for i, box in ipairs(boxes) do
    math.randomseed(i)
    local color = palette[math.random(1,32)]
    lovr.graphics.setColor(color)
    local x, y, z = box:getPosition()
    local sx, sy, sz = unpack(box:getUserData().size)
    lovr.graphics.box('fill', x, y, z, sx, sy, sz, box:getOrientation())
  end
  -- draw physics balss
  for i, ball in ipairs(balls) do
    math.randomseed(i)
    local color = palette[math.random(1,32)]
    lovr.graphics.setColor(color)
    local x, y, z = ball:getPosition()
    local r = ball:getUserData().size
    lovr.graphics.sphere(x, y, z, r)
  end
end


return m
