local palette = require'palette-marshmellow32'
local shader = require'fogShader'
local m = {}

local holeSize = 15
local strokeWidth = 0.14
local strokeHeight = 8.2
local holeHeight = 100

function m.load()
  lovr.graphics.setBackgroundColor(0,0,0.05)
  lovr.graphics.setShader(shader)
  shader:send('fogColor', {lovr.graphics.getBackgroundColor()})
  shader:send('fogStrength', 0.1)
end


function m:update(dt)
end


function m:draw()
  local t = lovr.timer.getTime()
  local depth = t * math.min(2 * t, 200)
  lovr.graphics.setShader(shader)
  -- hole walls
  for thickness = 0, 1 do
    for y = -holeHeight, holeHeight, 60 do
      for a = 0, 2 * math.pi, 0.4 do
        math.randomseed(a * 100 + (holeHeight + y * 10) + thickness)
        local vertical = -holeHeight + (y + 2 * holeHeight * math.random() + depth) % (2 * holeHeight)
        local a = a + 0.2 * (2 * math.random() - 1) + thickness
        local r = holeSize + thickness * 3 + 0.5 * math.random()
        local strokeWidth = strokeWidth - 0.05 * thickness
        local strokeHeight = strokeHeight + 1.3 * thickness + 0.8 * math.random()
        color(math.random() > 0.5 and 24 or 25, 1)
        strokeTo( -- hole walls
          vec3(r * math.sin(a-strokeWidth), vertical, r * math.cos(a-strokeWidth)),
          vec3(r * math.sin(a+strokeWidth), vertical, r * math.cos(a+strokeWidth)),
          math.pi/2, strokeHeight)
      end
        lovr.math.drain()
    end
  end
end

function color(paletteIndex, alpha)
  local r,g,b = unpack(palette[paletteIndex])
  lovr.graphics.setColor(r, g, b, alpha or 1)
end

return m