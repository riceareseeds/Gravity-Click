local batteryPM = {}

local map = script.Parent.Parent

batteryPM.Power = map.WaitChild("Power")
batteryPM.Battery = map.WaitChild("PhysicsFolder").WaitChild("Battery")
batteryPM.BattProp = batteryPM.Power.WaitChild("Battery")
batteryPM.Hitbox = batteryPM.Power.WaitChild("Hitbox")
batteryPM.Door = map.WaitChild("Electric Door")
batteryPM.Sound = batteryPM.Power.WaitChild("Success")
batteryPM.Sound2 = batteryPM.Power.WaitChild("PowerUp")

function batteryPM.init()
	batteryPM.Hitbox.Touched:Connect(function(hit)
		if hit.Name == batteryPM.Battery.Name then
			batteryPM.Battery.Destroy()
			batteryPM.BattProp.Position -= Vector3.New(0, 0, 2)
			
			local begin = batteryPM.Door.Position.Y
			local ending = batteryPM.Door.Position.Y + 9
			local tween = Tween.NewTween()
			tween.TweenNumber(begin, ending, 1.0, function(val)
				batteryPM.Door.Position = batteryPM.Door.Position*Vector3.New(1,0,1) + Vector3.New(0, val, 0)
			end)
			batteryPM.Sound.Play()
			batteryPM.Sound2.Play()
			wait(1.0)
			batteryPM.Door.Position = batteryPM.Door.Position*Vector3.New(1,0,1) + Vector3.New(0, ending, 0)
		end
	end)
end

return batteryPM