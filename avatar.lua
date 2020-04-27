local physics = require'physics'
local icosphere = require'geometry/icosphere'
local avatar = {}

avatar.skinColor = {0.443, 0.333, 0.290, 1}
avatar.teleportValidColor = {0.306, 0.235, 0.361}
avatar.teleportInvalidColor = {0.306, 0.235, 0.361, 0.5}
avatar.hands = {}

function avatar.load()
  for i, hand in pairs(lovr.headset.getHands()) do
    table.insert(avatar.hands, avatar:makeHand(hand))
  end
  avatar.RWtransform = lovr.math.newMat4() -- headset transform in RW space
  avatar.VRtransform = lovr.math.newMat4() -- avatar's transform in VR space
  -- avatar.VRtransform:set(0,0,0, 1,1,1, math.pi, 0,1,0) -- initial position/orientation
  -- hand mesh from icosphere
  local vertices, indices = icosphere(0)
  avatar.handMesh = lovr.graphics.newMesh(vertices, 'triangles')
  avatar.handMesh:setVertexMap(indices)
  avatar.teleporter = {
    targeting= false, 
    valid = false,
    destination= lovr.math.newVec3(),
    curve = lovr.math.newCurve(0,0,0, 0,0,0, 0,0,0),
  }
  return avatar
end


function avatar:makeHand(controller)
  local collider = physics:ball(0.03)
  collider:setFriction(0.9)
  collider:setKinematic(true)
  local hand = {
    name = controller,
    right = controller == 'hand/right',
    left  = controller == 'hand/left',
    gripping = false,
    gripPress = false,
    gripRelease = false,
    triggering = false,
    triggerPress = false,
    triggerRelease = false,
    collider = collider, -- physical collider of fist
    RWtransform = lovr.math.newMat4(),  -- controller's transformation in RW
    VRtransform = lovr.math.newMat4(),  -- hand collider's transformation in VR
  }
  collider:setUserData(hand)
  return hand 
end


function avatar:update(dt)
  --if #avatar.hands == 0 then avatar.load() end -- fix bad code reload
  -- headset
  local x,y,z,angle,ax,ay,az = lovr.headset.getPose('head')
  self.RWtransform:set(x, y, z, 1, 1, 1, angle, ax, ay, az)
  -- hands
  local transform = mat4() -- holder for VR transformations on this frame
  for i, hand in ipairs(self.hands) do
    local x,y,z,angle,ax,ay,az = hand.collider:getPose(hand.name)
    hand.VRtransform:set(x, y, z, 1, 1, 1, angle, ax, ay, az)
    local x,y,z,angle,ax,ay,az = lovr.headset.getPose(hand.name)
    hand.RWtransform:set(x, y, z, 1, 1, 1, angle, ax, ay, az)
    -- align collider to hand orientation (by spinning it to correct angles)
    -- easy way, bad for collisions: hand.collider:setOrientation(angle, ax, ay, az)
    local target = quat(self.VRtransform):mul(quat(hand.RWtransform))
    local current = quat(hand.VRtransform)
    local angle, ax, ay, az = target:mul(current:conjugate()):unpack(false)
    angle = ((angle + math.pi) % (2 * math.pi) - math.pi) -- for minimal motion wrap to (-pi, +pi) range
    hand.collider:setAngularVelocity(ax * angle * dt * 1000, ay * angle * dt * 1000, az * angle * dt * 1000)
    -- move hand collider to where hand should be in VR (by applying VR transform to RW transform)
    local target = vec3(mat4(self.VRtransform):mul(hand.RWtransform):unpack(false))
    local current = vec3(hand.VRtransform:unpack())
    local speed = (target - current) * 5000 * dt
    hand.collider:setLinearVelocity(speed:unpack())
    -- controller button handling
    local old
    old = hand.gripping
    hand.gripping    = lovr.headset.isDown(hand.name, 'grip')
    hand.gripPress   = hand.gripping and (not old)
    hand.gripRelease = (not hand.gripping) and old
    old = hand.triggering
    hand.triggering     = lovr.headset.isDown(hand.name, 'trigger')
    hand.triggerPress   = hand.triggering and (not old)
    hand.triggerRelease = (not hand.triggering) and old
    ---[[ thumbstick locomotion
    local x,y = lovr.headset.getAxis(hand.name, 'thumbstick')
    self.turnCoolDown = (self.turnCoolDown or 0) - dt
    local deadzone = 0.2
    if hand.right then
      if math.abs(x) > deadzone and self.turnCoolDown < 0 then
        self.VRtransform:rotate(math.pi/6 * -x / math.abs(x), 0, 1, 0)
        self.turnCoolDown = 0.3
      end
    else
      if math.abs(y) > deadzone then
        local moveVector = quat(self.RWtransform):direction() * dt * y * 2
        self.VRtransform:translate(moveVector.x, 0, moveVector.z)
      end
    end
    --]]
  end
  ---[[ teleporter locomotion
  local hand = self.hands[1]
  if hand.gripRelease and self.teleporter.valid then -- let's go!
    local rwx, _, rwy = self.RWtransform:unpack()
      -- teleporting should be relative and should ignore RW position
    local x,y,z = (self.teleporter.destination - vec3(rwx, 0, rwy)):unpack()
    local _,_,_, sx,sy,sz, angle, ax,ay,az = self.VRtransform:unpack(false)
    self.VRtransform:set(x,y,z, sx,sy,sz, angle, ax,ay,az)
  end
  self.teleporter.targeting = hand.gripping and #physics.colliders > #self.hands -- cannot teleport if hands are only tangible object in world
  self.teleporter.destination:set(0,0,0)
  if self.teleporter.targeting then
    local hits = physics:raycast(hand.VRtransform, 0.3)
    local hit = hits[1]
    local handPosition = vec3(hand.VRtransform:unpack())
    if hit then
      self.teleporter.destination:set(hit.position)
      self.teleporter.valid = hit.collider:isKinematic() and hit.distance < 8
        -- middle point is raised to make a smooth arc
      self.teleporter.curve:setPoint(1, handPosition)
      self.teleporter.curve:setPoint(2, handPosition:lerp(self.teleporter.destination, 0.2) + vec3(0,0.3,0)) 
      self.teleporter.curve:setPoint(3, self.teleporter.destination)
    else
      self.teleporter.destination:set(hand.VRtransform:mul(0,0,-0.4))
      self.teleporter.valid = false
        -- middle point is unaffected for straight line
      self.teleporter.curve:setPoint(1, handPosition)
      self.teleporter.curve:setPoint(2, handPosition:lerp(self.teleporter.destination, 0.5)) 
      self.teleporter.curve:setPoint(3, self.teleporter.destination)
    end
  end
  --]]
end

function teleportUpdate(dt)
end


function avatar:draw()
  -- draw teleporting destination and arc
  if self.teleporter.targeting then
    lovr.graphics.setColor(self.teleporter.valid and avatar.teleportValidColor or avatar.teleportInvalidColor)
    local points = self.teleporter.curve:render(16)
    for i = 4, #points, 3 do
      strokeTo(vec3(points[i-3], points[i-2], points[i-1]),
               vec3(points[i], points[i+1], points[i+2]),
               0, 0.03, 0.03)
    end
    if self.teleporter.valid then
      lovr.graphics.sphere(self.teleporter.destination, 0.3)
    end
  else
  end

  for i, hand in ipairs(self.hands) do
    --[[ actual location of VR collider
    local x,y,z, _,_,_, angle, ax,ay,az = hand.VRtransform:unpack()
    lovr.graphics.box('fill', x, y, z,
      0.05, 0.08, 0.10,
      angle, ax, ay, az)
    --]]
    -- squished icosphere fist
    lovr.graphics.setColor(self.skinColor)
    lovr.graphics.push()
    lovr.graphics.origin()
    lovr.graphics.transform(hand.RWtransform)
    lovr.graphics.scale(0.03, 0.05, 0.07)
    avatar.handMesh:draw()
    lovr.graphics.pop()
  end
end

return avatar