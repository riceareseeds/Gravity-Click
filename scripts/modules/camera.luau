local cameraM = {}

local bind = ScriptService.CameraEffect
local camera = Environment.CurrentCamera
local constants = require(ScriptService.Constants)

local findBall = require(ScriptService.FindBall)
local targetX = camera.Position.X
local targetY = camera.Position.Y
local extraDistance = 0
local focusPos = nil
local shakeOffset = Vector2.Zero
local rotateZ = 0
function cameraM.loop(dt)
	local ball = findBall.find(Players.LocalPlayer.Name)

	local ballX = ball.Position.X
	
	if focusPos then
		targetX = focusPos.X
		targetY = focusPos.Y
	else
		if ballX > targetX + constants.CAM_X_BOUNDARY then
 			targetX = targetX + (ballX - constants.CAM_X_BOUNDARY - targetX) * Camera.LerpSpeed * dt
		elseif ballX < targetX - constants.CAM_X_BOUNDARY then
			targetX = targetX + (ballX + constants.CAM_X_BOUNDARY - targetX) * Camera.LerpSpeed * dt
		end
		targetY = ball.Position.Y + constants.CAM_Y_OFFSET
	end

	local target = Vector3.New(
   	targetX + shakeOffset.X,
   	targetY + shakeOffset.Y,
   	ball.Position.Z - constants.CAM_DIST - extraDistance
	)

	camera.Position = camera.Position + (target - camera.Position) * Camera.LerpSpeed * dt
	local newZ = camera.Rotation.Z + (rotateZ-camera.Rotation.Z) * Camera.LerpSpeed * dt
	camera.Rotation = Vector3.New(0, 180, newZ)
end

function initCamEff()
	bind.Invoked:Connect(function(effName, ...)
		args = table.pack(...)
		if effName == "Distance" then
			extraDistance = args[1]
		elseif effName == "Position" then
			focusPos = args[1]
		elseif effName == "Shake" then
			local intensity = args[1]
			local duration = args[2]
			local tween = Tween.NewTween()
			tween:TweenNumber(intensity, 0, duration, function(val)
    		shakeOffset = Vector2.New((math.random(-100,100)/100)*val,(math.random(-100,100)/100)*val)
				rotateZ = (math.random(-100,100)/100)*val
			end)
			tween.Finished:Wait()
			shapeOffset = Vector2.Zero
			rotateZ = 0
		end
	end)
end

function cameraM.init()
  print("initializing "..script.Name.." Module...")
	
	camera.Position = Vector3.New(0, 30, 0)
	camera.Rotation = Vector3.New(0, 180, 0)
	
	initCamEff()
	
	print(script.Name.." Module initialized!")
end

return cameraM