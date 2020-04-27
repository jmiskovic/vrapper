local m = {}
-- DISTANCE constrains distance, allows rotation
-- lovr.physics.newDistanceJoint(collider1, collider2, wx1, wy1, wz1, wx2, wy2, wz2)

-- HINGE constrains distance, constrains rotation to hinge axis, 
-- lovr.physics.newHingeJoint(collider1, collider2, x, y, z, ax, ay, az)

-- BALL constrains distance to joint, allows rotation (like distance joints to in-between object)
-- lovr.physics.newBallJoint(colliderA, colliderB, x, y, z)

-- SLIDER constrains rotation, constrains relative movement to 1 axis
-- lovr.physics.newSliderJoint(colliderA, colliderB, ax, ay, az)

function m.load()
	local gravity = 4 -- 9.81
	local sleeping = true
  local tags = {'matter', 'ghost'}
  m.world = lovr.physics.newWorld(0, -gravity, 0, sleeping, tags)
  for i,tag in ipairs(tags) do -- can't touch this
  	m.world:disableCollisionBetween('ghost', tag)
  end
  m.world:setLinearDamping(.015)
  m.world:setAngularDamping(.005)
  m.colliders = {}
  lovr.timer.step()
end


function m:update(dt)
  self.world:update(dt)
end


function m:drawHud(t)
end


function m:draw(t)
  -- draw physics boxes
  for i, collider in ipairs(self.colliders) do
    local ud = collider:getUserData()
    if ud.color then
      if ud.shape == 'box' then
        lovr.graphics.setColor(ud.color)
        local x, y, z = collider:getPosition()
        local sx, sy, sz = unpack(ud.size)
        lovr.graphics.box('fill', x, y, z, sx, sy, sz, collider:getOrientation())
      end
    end
  end
end


function setPhysicalProperties(c, config)
  if config.position then c:setPosition(config.position:unpack()) end
  if config.kinematic then c:setKinematic(true) end
end

function m:box(sx, sy, sz, userdata)
  local c = self.world:newBoxCollider(0, 0, 0, sx, sy, sz)
  userdata = userdata or {}
  setPhysicalProperties(c, userdata)
  c:setTag('matter')
  c:setFriction(0)
  c:setRestitution(0)
  userdata.shape = 'box'
  userdata.size = {sx, sy, sz}
  c:setUserData(userdata)
  table.insert(self.colliders, c)
  return c
end


function m:ball(r, userdata)
  local c = self.world:newSphereCollider(0, 0, 0, r)
  userdata = userdata or {}
  c:setTag('matter')
  setPhysicalProperties(c, userdata)
  userdata.shape = 'sphere'
  userdata.size = r
  c:setUserData(userdata)
  table.insert(self.colliders, c)
  return c
end


function m:raycast(transform, minDistance, maxDistance)
  --to = lovr.math.newVec3(from + gunDirection * 100)
  minDistance, maxDistance = minDistance or 0, maxDistance or 50
  local ox, oy, oz = transform:unpack(false)
  local tx, ty, tz = transform:mul(vec3(0, 0, -maxDistance)):unpack()
  local origin = vec3(ox, oy, oz)
  local hits = {}
  self.world:raycast(ox, oy, oz, tx, ty, tz,
    function(shape, hx, hy, hz, nx, ny, nz)
      local position = vec3(hx, hy, hz)
      local distance = (origin - position):length()
      if distance > minDistance then
        local normal = vec3(nx, ny, nz)
        local collider = shape:getCollider()
        table.insert(hits, {collider= collider, shape= shape, position= position, normal= normal, distance= distance})
      end
    end)
  table.sort(hits, function(a,b) return a.distance < b.distance end)
  return hits
end


return m
