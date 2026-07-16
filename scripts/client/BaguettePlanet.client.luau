local TetoModule = require(script.Teto)
local QueenTetoModule = require(script.QueenTeto)

local PhysFold = script.Parent.PhysicsFolder

TetoModule.init(PhysFold)

local allowQTInit = true

script.Parent.BaguetteHitbox.TouchEnded:Connect(function(hit)
	if not (hit and hit.Name and allowQTInit) then return end
	if hit.Name == "SacredBaguette" then
		allowQTInit = false
		QueenTetoModule.init()
	end
end)

function _FixedUpdate(dt)
	QueenTetoModule.loop(dt)
end
