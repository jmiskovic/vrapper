local palette = require'palette-marshmellow32'
local avatar = require'avatar'
local physics = require'physics'

local scene = 
  require'scene-anothershootout/anothershootout'
--[[
  require'scene-stroke/stroke'
  require'scene-ballpit/ballpit'
  require'scene-bottomless/bottomless'
  require'scene-conducting/conducting'
]]

instanceCount = 0 -- global counter for drawn primitives
local onDesktop = false
local t = 0 -- time

local logs = {limit = 30}
function log(entry)
  table.insert(logs, 1, entry)
  print(entry)
  logs[logs.limit] = nil -- delete old entries
end
local tracks = {}
function track(entry)
  table.insert(tracks, entry)
end


function lovr.load()
  onDesktop = lovr.headset.getName() == 'Simulator'
  physics.load()
  avatar:load()
  scene.load()
  lovr.timer.step()
end


function lovr.update(dt)
  physics:update(dt)
  avatar:update(dt)  
  scene:update(dt)
  if onDesktop then lovr.timer.sleep(0.015) end
end


function lovr.draw()
  lovr.graphics.setWireframe(not true)
  instanceCount = 0
  lovr.graphics.transform(mat4(avatar.VRtransform):invert())
  scene:draw()
  physics:draw()
  avatar:draw()
  lovr.graphics.origin()
  lovr.graphics.setShader()
  ---[[ debug text
  track('drawcalls: ' .. lovr.graphics.getStats().drawcalls)
  track('instanceCount: ' .. instanceCount)
  track('fps: ' .. lovr.timer.getFPS())
  lovr.graphics.setColor(palette[1])
  for i = 1, #tracks do
    lovr.graphics.print(tracks[i], 10, 20+i, -25, 0.8)
  end
  tracks = {}
  for i = 1, #logs do -- show log lines
    --lovr.graphics.setColor(1,1,1, 1 - 1/logs.limit)
    lovr.graphics.print(logs[i], 10, 20+i, -25, 0.8)
  end
  --]]
  if scene.drawHud then
    lovr.graphics.origin()
    lovr.graphics.transform(scene.RWtransform)
    scene:drawHud()
  end
end


function strokeTo(origin, destination, rotation, width, height)
  stroke(origin, destination-origin, rotation, width, height)
end


function stroke(origin, delta, rotation, width, height)
  local scale = (delta):length()
  local width = (width or 0.3) / scale
  lovr.graphics.push()
  lovr.graphics.translate(origin)
  lovr.graphics.rotate(math.atan2(-delta.x, -delta.z), 0,1,0)
  lovr.graphics.rotate(math.atan2(delta.y, delta.zx:length()), 1,0,0)
  lovr.graphics.rotate(rotation, 0,0,-1)
  lovr.graphics.scale(scale)
  if height then
    lovr.graphics.box('fill',
      0, 0, -0.5,
      width, 1, height / scale,
      math.pi/2, 1, 0, 0)
  else
    lovr.graphics.plane('fill',
      0, 0, -0.5,
      width, 1,
      math.pi/2, 1, 0, 0)
  end
  lovr.graphics.pop()
  instanceCount = instanceCount + 1
end