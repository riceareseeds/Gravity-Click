local map = script.Parent
local PhysicsFolder = map.WaitChild("PhysicsFolder")
local Cake = PhysicsFolder.WaitChild("Cake")
local VineBoom = map.WaitChild("VineBoom")
local Hitbox = map.WaitChild("CakeHitbox")
local AwardEvent = ScriptService.WaitChild("AwardBadgeEvent")
local LieSign = map.WaitChild("Troll")
local plr = Players.LocalPlayer

wait(2)
Hitbox.TouchEnded:Connect(function(hit)
	if hit.Name == "Cake" then
		VineBoom.Play()
		Cake.Destroy()
		LieSign.Position -= Vector3.New(0, 0, .5)
		wait(3)
		local msg = NetMessage.New()
		msg.AddString("badgeName", "Lie")
		AwardEvent.InvokeServer(msg)
	end
end)