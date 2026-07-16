local hitM = {}

local constants = require(ScriptService.Constants)
local statsEvent = ScriptService.WaitChild("StatsEvent")
local lever = require(ScriptService.Lever)

hitM.GUI = PlayerGUI.WaitChild("HitboxGUI")
hitM.LDD = hitM.GUI.LevelDoorDisplay
hitM.LD = hitM.GUI.LeverDisplay

local LBE = ScriptService.WaitChild("LevelBindEve")

local function touch(hit)
	local tags = hit.Parent.Tags
	if table.find(tags, "Collectable") then
		script.Collect.Pitch = math.random(90, 110)/100
		script.Collect:PlayOneShot(1)
		
		local msg = NetMessage.New()
		msg.AddNumber("amount", 1)
		statsEvent.InvokeServer(msg)
		hit.Parent.Destroy()
	end
	if table.find(tags, "Door") then
		hitM.LDD.Title.Text = hit.Parent.Name
		hitM.LDD.Visible = true
	end
	if hit.Name then
		if string.find(hit.Name, "ZoomTrigger") then
			ScriptService.CameraEffect.Invoke("Distance", hit.Distance.Value)
		end
		if hit.Parent and hit.Parent.Name then
			if string.find(hit.Parent.Name, "Lever") then
				hitM.LD.Lever.Value = hit.Parent
				hitM.LD.Visible = true
			end
		end
	end
end

local function touchEnd(hit)
	local tags = hit.Parent.Tags
	if tags == {} then return end
	if table.find(tags, "Door") then
		hitM.LDD.Visible = false
	end
	if string.find(hit.Name, "ZoomTrigger") then
		ScriptService.CameraEffect.Invoke("Distance", 0)
	end
	if hit.Parent and hit.Parent.Name then
		if string.find(hit.Parent.Name, "Lever") then
			hitM.LD.Visible = false
		end
	end
end

function hitM.init()
	print("initializing "..script.Name.."...")
	local ballFold = Environment.FindChild(constants.BALL_FOLD)
	local ball = ballFold.FindChild(Players.LocalPlayer.Name)
	
	ball.Touched:Connect(touch)
	
	ball.TouchEnded:Connect(touchEnd)
	
	Input.KeyDown:Connect(function(keyCode, gameFocused)
		if not gameFocused then return end
		if keyCode == Enums.KeyCode.Space and hitM.LDD.Visible then
			LBE.Invoke(hitM.LDD.Title.Text)
			hitM.LDD.Visible = false
		end
		if keyCode == Enums.KeyCode.Space and hitM.LD.Visible then
			lever.action(hitM.LD.Lever.Value)
		end
	end)

	local touching = ball.GetTouching()
	for _, hit in touching do
		touch(hit)
	end
	
	print(script.Name.." initialized!")
end

return hitM