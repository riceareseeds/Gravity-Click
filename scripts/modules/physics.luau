local physicsM = {}

local constants = require(ScriptService.Constants)
local findBall = require(ScriptService.FindBall)

local function getPhysFold()
	local lvlFold = Environment.FindChild("Level")
	if not lvlFold then
		print("Level not found, can't update Phy. Obj. table.")
		return
	end
	local physFold = lvlFold.FindChild(constants.PHYS_FOLD)
	if not physFold then
		print("Phy. Folder not found.")
	else
		return physFold
	end
end

local function handleObjPhys(pos, object, mult)
	local delta = pos - object.Position
	local dist = (delta*Vector3.New(1,1,0)).Magnitude
	if dist < constants.MIN_GRAV_DIST and dist > 0 then
		object.Velocity += delta.Normalized * math.min((1 / dist), 1) * mult * constants.GRAV_POWER
		object.Velocity = object.Velocity.Normalized * math.min(constants.GRAV_SPEED_CAP, object.Velocity.Magnitude)
	end
end

function physicsM.gravPull(pos, mult)
	if mult == 0 then return end
	local physFold = getPhysFold()
	
	if physFold then
		for _, object in physFold:GetChildren() do
			handleObjPhys(pos, object, mult)
		end
	end
	
	local ball = findBall.find(Players.LocalPlayer.Name)
	handleObjPhys(pos, ball, mult)
end

return physicsM