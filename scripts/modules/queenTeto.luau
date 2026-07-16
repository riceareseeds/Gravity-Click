local qTetoM = {}

local findBall = require(ScriptService.FindBall)
local camEff = ScriptService.CameraEffect

local active = false
local pounding = false
local map = script.Parent.Parent

local BEGINNING_DIFF = 5.0
local TETO_SPEED = 10.0
local POUND_COOLDOWN = 2.0
local POUNDS_TIL_SPIKE = 2
local TETO_MAX_HEALTH = 400.0

qTetoM.Teto = map.WaitChild("QueenTeto")
qTetoM.LandingPart = map.WaitChild("QTLanding")
qTetoM.HoveringPart = map.WaitChild("QTHovering")
qTetoM.CutscenePart = map.WaitChild("CutsceneSpot")
qTetoM.BDoor = map.WaitChild("BlockDoor")

qTetoM.Music = map.WaitChild("BossMusic")
qTetoM.Sound = qTetoM.Teto.Sound
qTetoM.Impact = qTetoM.Teto.Impact
qTetoM.Stab = qTetoM.Teto.Stab
qTetoM.Explode = qTetoM.Teto.WaitChild("Explode")

qTetoM.GOHitbox = qTetoM.Teto.GameOverHitbox
qTetoM.GORing = map.GameOverRing
qTetoM.Spikes = map.WaitChild("Spikes")

qTetoM.HoveringAtY = qTetoM.HoveringPart.Position.Y
qTetoM.LandingAtY = qTetoM.LandingPart.Position.Y

qTetoM.GUI = PlayerGUI.WaitChild("BaguetteGUI")

qTetoM.AwardEvent = ScriptService.WaitChild("AwardBadgeEvent")
qTetoM.LevelEvent = ScriptService.WaitChild("LevelBindEve")

qTetoM._RespawnPart = map.WaitChild("RespawnPoint")
qTetoM._RespawnPoint = ScriptService.WaitChild("RespawnPoint")

local Health = TETO_MAX_HEALTH

local function playerGameOver()
	active = false
	pounding = false
	local GOScreen = qTetoM.GUI.GameOverScreen
	if GOScreen.Visible then return end
	local ball = findBall.find(Players.LocalPlayer.Name)
	ball.Anchored = true
	ball.Size = Vector3.Zero
	GOScreen.Visible = true
	wait(2.75)
	local HealthUI = qTetoM.GUI.QTetoHealthUI
	HealthUI.PositionRelative = Vector2.New(0.5, -0.5)
	GOScreen.Visible = false
	qTetoM._RespawnPoint.Value = qTetoM._RespawnPart.Position
	qTetoM.LevelEvent.Invoke("Baguette Planet")
end

local prevHealth = Health
local function updateHealthGUI()
	local HealthUI = qTetoM.GUI.QTetoHealthUI
	local healthTween = Tween.NewTween()
	healthTween.TweenNumber(prevHealth, Health, 0.67, function(val)
		HealthUI.Fill.SizeRelative = Vector2.New(val/TETO_MAX_HEALTH, 1.0)
		HealthUI.Label.Text = tostring(math.round(val)).."/"..tostring(TETO_MAX_HEALTH)
	end)
	prevHealth = Health
end

function qTetoM.Win()
	active = false
	pounding = false
	qTetoM.Music:Stop()
	wait(3)
	qTetoM.Teto.Nuke.Color = Color.FromHSV(0,0,1,1)
	qTetoM.Explode:Play()
	wait(2)
	local Crown = qTetoM.Teto.Crown
	Crown.Parent = map.PhysicsFolder
	Crown.Size *= 1/6
	Crown.Anchored = false
	qTetoM.Teto.Position = Vector3.Zero
	local HealthUI = qTetoM.GUI.QTetoHealthUI
	local HealthUITween = Tween.NewTween()
	HealthUITween:SetTrans(Enums.TweenTransition.Sine)
	HealthUITween:SetDirection(Enums.TweenDirection.Out)
	HealthUITween.TweenNumber(0, -0.5, 1.5, function(newY)
		HealthUI.PositionRelative = Vector2.New(0.5, newY)
	end)
	local bDoorTween = Tween.NewTween()
	bDoorTween.TweenNumber(qTetoM.BDoor.Position.Y, qTetoM.BDoor.Position.Y+36, 0.5, function(newY)
		qTetoM.BDoor.Position = qTetoM.BDoor.Position*Vector3.New(1,0,1)+Vector3.New(0, newY, 0)
	end)
	map.Music.Pitch = 0.9
	map.Music:Play()
	local msg = NetMessage.New()
	msg.AddString("badgeName", "Defeat Queen Teto")
	qTetoM.AwardEvent.InvokeServer(msg)
end

local poundsTilSpike = POUNDS_TIL_SPIKE
function qTetoM.pound()
	pounding = true
	
	local beginningTween = Tween.NewTween()
	local prevPos = qTetoM.Teto.Position
	qTetoM.Sound:Play()
	beginningTween.TweenNumber(prevPos.Y, prevPos.Y+BEGINNING_DIFF, 0.67, function(val)
		qTetoM.Teto.Position = prevPos*Vector3.New(1,0,1) + Vector3.New(0, val, 0)
	end)
	wait(0.67)
	
	local midTween = Tween.NewTween()
	prevPos = qTetoM.Teto.Position
	midTween.TweenNumber(prevPos.Y, qTetoM.LandingAtY, 0.1, function(val)
		qTetoM.Teto.Position = prevPos*Vector3.New(1,0,1) + Vector3.New(0, val, 0)
	end)
	wait(0.1)
	if map:FindChild("Mount") then
		map.Mount.Destroy()
	end
	
	wait()
	for _, obj in qTetoM.GOHitbox.GetTouching() do
		if not (obj and obj.Name) then continue end
		if string.find(obj.Name, "Spike") then
			Health -= 100
			updateHealthGUI()
			qTetoM.Stab:Play()
			obj.Destroy()
			if Health <= 0 then
				qTetoM.Win()
			end
			local endingTween = Tween.NewTween()
			prevPos = qTetoM.Teto.Position
			endingTween.TweenNumber(prevPos.Y, qTetoM.HoveringAtY, 1.0, function(val)
				qTetoM.Teto.Position = prevPos*Vector3.New(1,0,1) + Vector3.New(0, val, 0)
			end)
			wait(1.0)
			pounding = false
			return
		end
	end
	
	poundsTilSpike -= 1
	if poundsTilSpike <= 0 then
    local Spikes = qTetoM.Spikes:GetChildren()
    if #Spikes > 0 then
      local chosenS = Spikes[math.random(1, #Spikes)]
      chosenS.Anchored = false
      chosenS.Parent = map.PhysicsFolder
      poundsTilSpike = POUNDS_TIL_SPIKE
    end
	end
	
	qTetoM.GORing.Position = qTetoM.GORing.Position*Vector3.New(0, 1, 1)+Vector3.New(qTetoM.Teto.Position.X, 0, 0)
	local ringTween = Tween.NewTween()
	ringTween.TweenNumber(1.0, 500.0, 3.0, function(val)
		qTetoM.GORing.Size = Vector3.New(val, 10.0, val)
		qTetoM.GORing.Color = Color.FromHSV(0,1,1,(500-val)/500)
	end)
	
	spawn(function()
		ringTween.Finished:Wait()
		qTetoM.GORing.Size = Vector3.Zero
		qTetoM.GORing.Position = qTetoM.GORing.Position*Vector3.New(0, 1, 1)+Vector3.New(0, 0, 0)
	end)
	
	camEff.Invoke("Shake", 5, 3)
	qTetoM.Impact:Play()
	wait(2)
	
	local endingTween = Tween.NewTween()
	prevPos = qTetoM.Teto.Position
	endingTween.TweenNumber(prevPos.Y, qTetoM.HoveringAtY, 0.2, function(val)
		qTetoM.Teto.Position = prevPos*Vector3.New(1,0,1) + Vector3.New(0, val, 0)
	end)
	
	pounding = false
end

local poundCoolDown = POUND_COOLDOWN
function qTetoM.loop(dt)
	if not active or pounding then return end
	local ball = findBall.find(Players.LocalPlayer.Name)
	local target = (qTetoM.Teto.Position*Vector3.New(0, 1, 1))+Vector3.New(ball.Position.X, 0, 0)
	qTetoM.Teto.Position = qTetoM.Teto.Position + (target-qTetoM.Teto.Position)*dt*TETO_SPEED
	poundCoolDown -= dt
	if poundCoolDown <= 0 then
		spawn(function()
			qTetoM.pound()
			poundCoolDown = POUND_COOLDOWN
		end)
	end
end

local function gameOverHit(hit)
	if not (hit and hit.Name and active and pounding) then return end
	if hit.Name == Players.LocalPlayer.Name then
		playerGameOver()
	end
end

local function initConnections()
	qTetoM.GORing.Touched:Connect(gameOverHit)
	qTetoM.GOHitbox.Touched:Connect(gameOverHit)
end

function qTetoM.init()
	local mainMusic = map.Music
	local pitchTween = Tween.NewTween()
	pitchTween.TweenNumber(map.Music.Pitch, 0, 1.0, function(pit)
		mainMusic.Pitch = pit
	end)
	local bDoorTween = Tween.NewTween()
	bDoorTween.TweenNumber(qTetoM.BDoor.Position.Y, qTetoM.BDoor.Position.Y-36, 0.5, function(newY)
		qTetoM.BDoor.Position = qTetoM.BDoor.Position*Vector3.New(1,0,1)+Vector3.New(0, newY, 0)
	end)
	wait(1.0)
	mainMusic:Stop()
	camEff.Invoke("Position", qTetoM.CutscenePart.Position)
	qTetoM.pound()
	camEff.Invoke("Position", nil)
	qTetoM.Music:Play()
	active = true
	local HealthUI = qTetoM.GUI.QTetoHealthUI
	local HealthUITween = Tween.NewTween()
	HealthUITween:SetTrans(Enums.TweenTransition.Sine)
	HealthUITween:SetDirection(Enums.TweenDirection.Out)
	HealthUITween.TweenNumber(-0.5, 0, 1.5, function(newY)
		HealthUI.PositionRelative = Vector2.New(0.5, newY)
	end)
	updateHealthGUI()
	initConnections()
end

return qTetoM