local gravM = {}
local constants = require(ScriptService.Constants)
local findBall = require(ScriptService.FindBall)
local map = script.Parent.Parent

local GRAV_CONSTANT = 1

-- Cached folders and children
local planetFolder = map.WaitChild("Planets")
local physicsFolder = map.WaitChild("PhysicsFolder")
gravM.planetCache = planetFolder:GetChildren()
gravM.objectCache = physicsFolder:GetChildren()

local function affectObj(obj, planetPos, mass, minDist, dt)
  if not obj then return end
  if not obj.Position then return end
  if not obj.Velocity then return end
  local objPos = Vector3.New(obj.Position.X, obj.Position.Y, 0)
  local delta = planetPos - objPos
  local dist = delta.Magnitude
  if dist > minDist then return end
  local forceMag = (GRAV_CONSTANT * mass) / (dist * dist)
  local forceDir = delta.Normalized
  obj.Velocity += Vector3.New(
    forceDir.X * forceMag * dt,
    forceDir.Y * forceMag * dt,
    0
  )
end

function gravM.simulate(dt)
  local ball = findBall.find(Players.LocalPlayer.Name)
  for _, planet in gravM.planetCache do
    if not planet then continue end
    local planetPos = Vector3.New(planet.Position.X, planet.Position.Y, 0)
    local radius = planet.Size.X / 2
    local mass = radius ^ 3
    local minDist = radius + radius
    for _, obj in gravM.objectCache do
      affectObj(obj, planetPos, mass, minDist, dt)
    end
    if ball then
      affectObj(ball, planetPos, mass, minDist, dt)
    end
  end
end

-- Call this whenever objects are added/removed from the folders
function gravM.refreshCache()
  gravM.planetCache = planetFolder:GetChildren()
  gravM.objectCache = physicsFolder:GetChildren()
end

return gravM