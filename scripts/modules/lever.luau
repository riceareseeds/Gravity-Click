local leverM = {}

leverM.Lever = Hidden.WaitChild("Lever")
leverM.BindEvent = ScriptService.WaitChild("LeverEvent")

leverM._onCooldown = false

local DEFAULT_STICK_ROTATION = 50.0
local ACTION_COOLDOWN = 0.36

function leverM.action(lever)
	if leverM._onCooldown then return end
	leverM._onCooldown = true
	
	spawn(function()
		wait(ACTION_COOLDOWN)
		leverM._onCooldown = false
	end)

	local stick = lever.Stick
	local tween = Tween.NewTween()
	local folder = lever.Parent
	local startRotation = nil
	local endingRotation = nil
	if stick.LocalRotation.X < 0 then
		startingRotation = -DEFAULT_STICK_ROTATION
		endingRotation = DEFAULT_STICK_ROTATION
		lever.PullUp:PlayOneShot(1)
		leverM.BindEvent:Invoke(true)
	else
		startingRotation = DEFAULT_STICK_ROTATION
		endingRotation = -DEFAULT_STICK_ROTATION
		lever.PullDown:PlayOneShot(1)
		leverM.BindEvent:Invoke(false)
	end
	tween.TweenNumber(startingRotation, endingRotation, 0.215, function(val)
		stick.LocalRotation = Vector3.New(val, 0, 0)
	end)
	tween.Finished:Connect(function()
		stick.LocalRotation = Vector3.New(endingRotation, 0, 0)
	end)
	for _, levers in folder:GetChildren() do
		if not (levers and levers.Name and levers.FindChild("Stick")) then continue end
		if levers.Name == lever.Name then continue end
		levers.Stick.LocalRotation = Vector3.New(endingRotation, 0, 0)
	end
end

function leverM.init(map)
	local folder = map.FindChild("Levers")
	if not folder then return end
	print("Lever Folder Found!")
	for _, spawn in folder:GetChildren() do
		if not (spawn and spawn.Position) then continue end
		local newLever = leverM.Lever.Clone()
		newLever.Position = spawn.Position
		newLever.Parent = folder
		spawn.Destroy()
	end
end

return leverM