local halfedge = require 'geometry/halfedge'
local point = require 'geometry/point'
local palette = require'palette-marshmellow32'
local m = {}

function m.load()
  m.mesh = constructMesh()
  m.mesh:setMaterial(mat)
  m.shader = require'scene-stroke/strokeShader'
  lovr.graphics.setCullingEnabled(true)
  lovr.graphics.setBackgroundColor(.05,.02,.08)
  m.shader:send('fogColor', {lovr.graphics.getBackgroundColor()})
end


function m:update(dt)
end

function m:drawHud(t)
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
  	lovr.math.drain()
  end
  lovr.graphics.pop()
end


local o = lovr.math.newVec3(-1, 1, -2)
local d = lovr.math.newVec3(0, 2, 0) 
local offset = lovr.math.newVec3(0, 3, 0)

local mat = lovr.graphics.newMaterial()

function m:draw()
  local t = lovr.timer.getTime()
  --lovr.graphics.setWireframe(true)
  lovr.graphics.setShader(m.shader)
  lovr.graphics.translate(0, -5, 0)
  d.x , d.z = math.cos(t), math.sin(t)
  --local o = vec3(-1, 1, -2)
  --local d = vec3(math.cos(t), 3, math.sin(t))
  ---[[
  m.shader:send('roundness', 0.5 + 0.5 * math.sin(t * 2))
  drawArmyOf(function(t, id)
  	  lovr.math.setRandomSeed(id)
  	  lovr.graphics.setColor(.1, .15 + 0.1 + lovr.math.random(), .1)
  		--lovr.graphics.setColor(.1, .15 + 0.1 + lovr.math.random(), .1)
  		m:curved(vec3(), vec3(d))
  	end, t, vec3(), 0, 5, 5)
  --]]
  --[[
  for i = 1, 100 do
  	math.randomseed(i)
  	lovr.graphics.setColor(.1, .15 + 0.1 + math.random(), .1)
  	local p = vec3()

  	p.x = (1.005^i + 8) * math.cos(i / 2)
  	p.z = (1.005^i + 8) * math.sin(i / 2)
  	lovr.graphics.push()
  	lovr.graphics.translate(p)
		m:curved(o, d)
  	lovr.graphics.pop()
		--m:curved(p, p + vec3(d))
  	--lovr.math.drain()
  end
  --]]
  --lovr.graphics.setShader()
  --strokeTo(o + offset, d + offset, 0, 0.2, 0.2)
  --m.mesh:draw(0,0,-2)
end


function m:curved(origin, destination)
  local delta = destination - origin
  local scale = delta:length()
  local q = quat(delta:normalize())
  --q = q * quat(math.pi/2, 0, 0, 1)
  local angle, ax, ay, az = q:unpack()
  m.mesh:draw(origin.x, origin.y, origin.z, scale, angle, ax, ay, az)
  instanceCount = instanceCount + 1
end


function constructMesh()
  -- construct
  local model = halfedge()
  local top = model:gen_disk(4, 1)
  top = model:extrude(top, 0.05)
  top = model:extrude(top, 0.15)
  top = model:extrude(top, 0.30)
  top = model:extrude(top, 0.50)
  -- convert
  model:triangulate_quads(false)
  model:triangulate_simple()
  local verticle_list = {}
  local face_count = 0
  for face,_ in pairs(model.faces) do
    local center = point(0,0,0)
    face_count = face_count + 1
    for e in face:edges() do
      local pos = center + e.point
      table.insert(verticle_list, {pos:get()})
    end
  end
  -- should end up between 0,0,0 and 0,0,-1 with size 1
  print('face_count', face_count)
  local mesh = lovr.graphics.newMesh(verticle_list, 'triangles')
  return mesh
end


return m