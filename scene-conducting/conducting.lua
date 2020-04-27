local palette = require'palette-marshmellow32'
local sampler = require'scene-conducting/sampler'
local avatar = require'avatar'
local m = {}

local scale = {0, 3, 5, 7, 10} --minor pentantonic intervals

local cello
local choir

function m.load()
  cello = sampler.new({
    {path='scene-conducting/susvib_A2_v3.ogg', note=  9},
    {path='scene-conducting/susvib_B1_v3.ogg', note= -1},
    {path='scene-conducting/susvib_C1_v3.ogg', note=-12},
    {path='scene-conducting/susvib_C3_v3.ogg', note= 12},
    {path='scene-conducting/susvib_D2_v3.ogg', note=  2},
    {path='scene-conducting/susvib_D4_v3.ogg', note= 26},
    {path='scene-conducting/susvib_E1_v3.ogg', note= -8},
    {path='scene-conducting/susvib_E3_v3.ogg', note= 16},
    {path='scene-conducting/susvib_F2_v3.ogg', note=  5},
    {path='scene-conducting/susvib_F4_v3.ogg', note= 29},
    {path='scene-conducting/susvib_G1_v3.ogg', note= -5},
    {path='scene-conducting/susvib_G3_v3.ogg', note= 19},
    looped = true,
    envelope = {attack = 0.2, decay = 0.1, sustain = 0.8, release = 0.6},
  })
  celloLate = sampler.new({
    {path='scene-conducting/susvib_A2_v3.ogg', note=  9},
    {path='scene-conducting/susvib_B1_v3.ogg', note= -1},
    {path='scene-conducting/susvib_C1_v3.ogg', note=-12},
    {path='scene-conducting/susvib_C3_v3.ogg', note= 12},
    {path='scene-conducting/susvib_D2_v3.ogg', note=  2},
    {path='scene-conducting/susvib_D4_v3.ogg', note= 26},
    {path='scene-conducting/susvib_E1_v3.ogg', note= -8},
    {path='scene-conducting/susvib_E3_v3.ogg', note= 16},
    {path='scene-conducting/susvib_F2_v3.ogg', note=  5},
    {path='scene-conducting/susvib_F4_v3.ogg', note= 29},
    {path='scene-conducting/susvib_G1_v3.ogg', note= -5},
    {path='scene-conducting/susvib_G3_v3.ogg', note= 19},
    looped = true,
    envelope = {attack = 0.25, decay = 0.1, sustain = 1, release = 0.65},
  })
  cello5th = sampler.new({
    {path='scene-conducting/susvib_A2_v3.ogg', note=  9},
    {path='scene-conducting/susvib_B1_v3.ogg', note= -1},
    {path='scene-conducting/susvib_C1_v3.ogg', note=-12},
    {path='scene-conducting/susvib_C3_v3.ogg', note= 12},
    {path='scene-conducting/susvib_D2_v3.ogg', note=  2},
    {path='scene-conducting/susvib_D4_v3.ogg', note= 26},
    {path='scene-conducting/susvib_E1_v3.ogg', note= -8},
    {path='scene-conducting/susvib_E3_v3.ogg', note= 16},
    {path='scene-conducting/susvib_F2_v3.ogg', note=  5},
    {path='scene-conducting/susvib_F4_v3.ogg', note= 29},
    {path='scene-conducting/susvib_G1_v3.ogg', note= -5},
    {path='scene-conducting/susvib_G3_v3.ogg', note= 19},
    transpose = 7,
    looped = true,
    envelope = {attack = 0.3, decay = 0.1, sustain = 0.3, release = 0.3},
  })
  choir = sampler.new({
    {path='scene-conducting/choir_21.ogg',  note= -9},
    {path='scene-conducting/choir_15.ogg',  note= -3},
    {path='scene-conducting/choir_12.ogg',  note=  0},
    {path='scene-conducting/choir_9.ogg',   note=  3},
    {path='scene-conducting/choir_6.ogg',   note=  6},
    {path='scene-conducting/choir_3.ogg',   note=  9},
    {path='scene-conducting/choir_0.ogg',   note= 12},
    {path='scene-conducting/choir_-3.ogg',  note= 15},
    {path='scene-conducting/choir_-6.ogg',  note= 18},
    looped = true,
    envelope = { attack = 0.05, decay = 0.40, sustain = 0.85, release = 0.35 },})
  choir.masterVolume = 0
  cello.masterVolume = 0
  lovr.graphics.setBackgroundColor(palette[2])
end


function m:update(dt)
  local touches = {}
  local hand = avatar.hands[1]
  if hand.triggering then
    local direction = quat(hand.RWtransform):direction()
    local angle = 5 + 8 * direction:dot(vec3(0, 1, 0))
    local degree = math.floor(angle) % #scale + 1
    local note = scale[degree] + math.floor(angle / #scale) * 12
    touches[1] = {note=note, location={-2,1,-6}, noteRetrigger=hand.triggerPress}
    local lp = 0.95
    cello.masterVolume = cello.masterVolume * (1 - lp) + lp * vec3(lovr.headset.getVelocity(hand.name)):length() * 8
    celloLate.masterVolume = cello.masterVolume
    cello5th.masterVolume = cello.masterVolume
    cello:update(dt, touches)
    touches[1].location = {-3,1,-6}
    celloLate:update(dt, touches)
    touches[1].location = {-2,1,-7}
    cello5th:update(dt, touches)
  end
  if not avatar.hands[2] then 
    return
  end
  touches[1] = nil
  local hand = avatar.hands[2]
  if hand.triggering then
    local direction = quat(hand.RWtransform):direction()
    local angle = -4 + 5 * direction:dot(vec3(0, 1, 0))
    local degree = math.floor(angle) % #scale + 1
    local note = scale[degree] + math.floor(angle / #scale) * 12
    touches[1] = {note=note, location={2,1,-6}, noteRetrigger=hand.triggerPress}
    local lp = 0.02
    choir.masterVolume = choir.masterVolume * (1 - lp) + lp * vec3(lovr.headset.getVelocity(hand.name)):length() * 10
    choir:update(dt, touches)
  end
end


local function drawCelloist(t, id)
  local loudness = math.min(cello.masterVolume / 3, 1)
  --chair
  lovr.graphics.setColor(palette[16])
  stroke(vec3(-0.3, 0,  0.3), vec3(0, 0.6, 0), 0, 0.1, 0.1)
  stroke(vec3(-0.3, 0, -0.3), vec3(0, 0.6, 0), 0, 0.1, 0.1)
  stroke(vec3( 0.3, 0,  0.3), vec3(0, 0.6, 0), 0, 0.1, 0.1)
  stroke(vec3( 0.3, 0, -0.3), vec3(0, 0.6, 0), 0, 0.1, 0.1)
  stroke(vec3( 0, 0.6, -0.3), vec3(0, 0, 0.6), math.pi, 0.7, 0.1)
  --chello body
  lovr.graphics.setColor(palette[18])
  stroke(vec3( 0, 0, 0.45), vec3(0, 0.1, 0), 0, 0.02, 0.1) --stand
  stroke(vec3( 0, 0.1, 0.45), vec3(-0.03, 1.0, -0.15), 0, 0.5, 0.1) --body
  lovr.graphics.setColor(palette[17]) --cello neck
  stroke(vec3( 0, 1, 0.35), vec3(-0.03, 0.6, -0.15), 0, 0.1, 0.1)
  --celloist
  lovr.graphics.setColor(palette[11]) --torso
  stroke(vec3(0, 0.6, 0), vec3(0, 0.7, 0), math.pi/24, 0.6, 0.1)
  lovr.graphics.setColor(palette[14]) --head
  stroke(vec3(-0.15, 1.4, 0), vec3(0.3, 0, 0.1), -5 * math.pi/12, 0.2, 0.1)
  --bow
  lovr.graphics.setColor(palette[17])
  stroke(vec3(0.3 + loudness * 0.06 * math.sin(t + 7 * math.pi/12), 0.5, 0.55), vec3(-0.6, loudness * 0.2 * math.sin(t), 0), math.pi/24, 0.05, 0.05)
end


local function drawChorist(t, id)
  local loudness = math.min(choir.masterVolume, 1)
  math.randomseed(id)
  lovr.graphics.push()
  lovr.graphics.rotate(0.05 * math.sin(t + 0.2 * id) * loudness,0,0,1)
  lovr.graphics.setColor(palette[27])
  stroke(vec3(0, 0, -0.1), vec3(0, 1.3, 0), 0, 0.3, 0.1)
  lovr.graphics.setColor(palette[26])
  stroke(vec3(0, 0.3, 0), vec3(0, 1.3, 0), 0, 0.6, 0.1)
  lovr.graphics.setColor(palette[14])
  stroke(vec3(0, 1.6, 0), vec3(0, 0.25, 0), -math.pi/12, 0.4, 0.1)
  lovr.graphics.setColor(palette[11])
  stroke(vec3(0, 1.63, 0.05), vec3(0, 0.02 + 0.08 * loudness, 0), 0, 0.2, 0.1)
  lovr.graphics.pop()  
end


local function drawArmyOf(drawFunction, t, loc, angle, columns, rows, distance)
  lovr.graphics.push()
  local distance = distance or 1
  local center = vec3(distance * columns/2 * distance, 0, distance * rows / 2 * distance)
  lovr.graphics.translate(loc)
  lovr.graphics.rotate(angle, 0, 1, 0)
  lovr.graphics.translate(-center)
  for z = 1, rows do
    for x = 1, columns do
      drawFunction(t, x + z * 100)
      lovr.graphics.translate(distance, 0, 0)
    end
    lovr.graphics.translate(-columns * distance, 0, distance)
  end
  lovr.graphics.pop()  
end


function m:drawHud(t)
  for i,hand in ipairs(avatar.hands) do
    if hand.triggering then
      lovr.graphics.setColor(palette[13])
    	--local x, y, z, angle, ax, ay, az = unpack(hand.pose)
      --stroke(vec3(x + 0.03*(1.5-i), y + 0.02, z), quat(angle, ax, ay, az):direction() * 0.25, 0, 0.02, 0.02)
      stroke(vec3(hand.RWtransform:unpack()), quat(hand.RWtransform):direction() * 0.25, 0, 0.02, 0.02)
    end
  end
end

function m:draw()
  local t = lovr.timer.getTime()
  lovr.graphics.setBackgroundColor(palette[2])
  lovr.graphics.setColor(palette[9])
  stroke(vec3(0, -0.5, -10), vec3(0, 0, 12), 0, 16, 0.1) --ground
  lovr.graphics.setColor(palette[18])
  stroke(vec3(0, -0.5, -1), vec3(0, 0, 2), 0, 2, 0.5) --stand
  drawArmyOf(drawCelloist, t, vec3(-3,-0.5,-3),  math.pi/6, 5, 3, 0.8)
  drawArmyOf(drawChorist,  t, vec3( 3,-0.5,-3), -math.pi/6, 5, 3, 0.8)
end

return m
