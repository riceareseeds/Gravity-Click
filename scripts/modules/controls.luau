local controlM = {}

local constants = require(ScriptService.Constants)
local physics = require(ScriptService.Physics)

-- Gravity Multiplier
controlM.gravMult = 0
controlM.Part = Hidden.WaitChild("GravPart")
controlM.GUI = PlayerGUI.ControlGUI

controlM._LevelBindEve = ScriptService.WaitChild("LevelBindEve")

local function projectToZPlane(screenPos: Vector2, fov: number, distance: number): Vector3
	local f = 1 / math.tan(math.rad(fov / 2))
	local worldX = (screenPos.X / f) * distance
	local worldY = (screenPos.Y / f) * distance
		
	return Vector3.New(worldX, worldY, 0)
end

local function worldRadiusToScreenSize(worldRadius: number): number
  local cam = Camera
  local camZ = math.abs(cam.Position.Z)
  local fov = math.rad(cam.FOV)
  local screenWidth = Input.ScreenWidth

  local focalLength = screenWidth / (2 * math.tan(fov / 2))
  return (worldRadius / camZ) * focalLength
end

local regCooldown = constants.GRAV_REG_COOLDOWN
local function initControls()
	Input.KeyDown:Connect(function(keyCode, gameFocused)
		if not gameFocused then return end
		if keyCode == Enums.KeyCode.MouseLeft then
			controlM.gravMult = 1
		elseif keyCode == Enums.KeyCode.MouseRight then
			controlM.gravMult = -1
		end
	end)
	Input.KeyUp:Connect(function(keyCode, _gameFocused)
		if keyCode == Enums.KeyCode.MouseLeft or keyCode == Enums.KeyCode.MouseRight then
			if regCooldown <= 0 and controlM.gravMult ~= 0 then
				regCooldown = constants.GRAV_REG_COOLDOWN
			end
			controlM.gravMult = 0
		end
	end)
end

local gravAmount = constants.GRAV_MAX_TIME
local GravInd = controlM.GUI.GravIndicator
local prevGravMult = nil
function controlM.loop(dt)
  local mousePos = Input.MousePosition
	local mouseViewport = Camera.ScreenToViewportPoint(mousePos)
	local pixels = worldRadiusToScreenSize(constants.MIN_GRAV_DIST)
	GravInd.PositionOffset = mousePos
	GravInd.SizeOffset = Vector2.New(pixels * 2, pixels * 2)
	local aspectRatio = Input.ScreenWidth / Input.ScreenHeight
	local worldPos = projectToZPlane(
		Vector2.New(
       (mouseViewport.X * 2 - 1) * aspectRatio,
       mouseViewport.Y * 2 - 1
   	),
		Camera.FOV,
		Camera.Position.Z
	) + Camera.Position * Vector3.New(1,1,0)
	controlM.Part.Position = worldPos
		
	local GravIndAmouFill = controlM.GUI.GravAmount.Fill
	local GravIndAmouLabel = controlM.GUI.GravAmount.Label
	if controlM.gravMult == 0 then
		if regCooldown <= 0 then
			gravAmount += dt*1.67
		end
	elseif gravAmount > 0 then
		gravAmount -= dt
	end
	gravAmount = math.min(constants.GRAV_MAX_TIME, gravAmount)
	GravIndAmouFill.SizeRelative = Vector2.New(gravAmount/constants.GRAV_MAX_TIME, 1)
	local precentage = math.max(0,(gravAmount/constants.GRAV_MAX_TIME)*100)
	GravIndAmouLabel.Text = string.format("%d%%", precentage)
	if gravAmount <= 0 then
		if controlM.gravMult ~= 0 then
			gravAmount = -constants.GRAV_REG_COOLDOWN*1.5
		end
		controlM.gravMult = 0
	end
		
	if regCooldown > 0 then
		regCooldown -= dt
	end
		
	if prevGravMult ~= controlM.gravMult then
		prevGravMult = controlM.gravMult
		local brightness = controlM.gravMult*-1
		local alpha = math.abs(controlM.gravMult)*0.7
			
		local colorTween = Tween.NewTween()
		local oldColor = GravInd.Color
		local newColor = Color.FromHSV(0, 0, brightness, alpha)
			
		colorTween.TweenColor(oldColor, newColor, 0.25, function(val)
			GravInd.Color = val
		end)
			
		local pitchTween = Tween.NewTween()
		local oldPitch = 0
		if brightness == 0 then
			oldPitch = 1
		end
		pitchTween.TweenNumber(oldPitch, math.abs(brightness+(math.random(5,15)/100)), 0.25, function(val)
			if controlM.Part.Sound then
				controlM.Part.Sound.Pitch = val
			end
		end)
	end
	physics.gravPull(worldPos, controlM.gravMult)
end

local function initConnections()
	initControls()
	controlM._LevelBindEve.Invoked:Connect(function(_n, _v)
		wait(1)
		gravAmount = constants.GRAV_MAX_TIME
	end)
end

function controlM.init()
	print("initializing "..script.Name.." Module...")
	controlM.Part.Parent = Environment
	initConnections()
	print(script.Name.." Module initialized!")
end

return controlM