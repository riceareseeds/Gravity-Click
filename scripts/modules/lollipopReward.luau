local cookieM = {}

local map = script.Parent.Parent

cookieM._Event = ScriptService.AwardBadgeEvent
cookieM.SillyHitbox = map.WaitChild("SillyHitbox")
cookieM.SillyBilly = map.WaitChild("Silly Billy").WaitChild("Character")
cookieM.cookie = map.WaitChild("PhysicsFolder").WaitChild("cookie")
cookieM.FaceImage3D = script.WaitChild("Face")
cookieM.Tubby = script.WaitChild("Tubby")
cookieM.Sound = cookieM.SillyBilly.WaitChild("Eat")
function cookieM.init()
	cookieM.SillyHitbox.Touched:Connect(function(hit)
		if hit.Name == cookieM.cookie.Name then
			cookieM.cookie.Destroy()
			cookieM.SillyBilly.FaceImage = cookieM.FaceImage3D.Image
			cookieM.SillyBilly.BodyMesh = cookieM.Tubby.Asset
			cookieM.Sound.Play()
			local msg = NetMessage.New()
			msg.AddString("badgeName", "COOKIE")
			cookieM._Event.InvokeServer(msg)
		end
	end)
	
end

return cookieM