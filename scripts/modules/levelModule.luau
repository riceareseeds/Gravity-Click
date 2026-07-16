local levelM = {}

local constants = require(ScriptService.Constants)
local TransitionModule = require(ScriptService.TransitionModule)
local findBall = require(ScriptService.FindBall)
local lever = require(ScriptService.Lever)

local SpawnParticles = Hidden.WaitChild("SpawnParticles")

levelM.CurrentLevel = nil
levelM.PrevLevel = nil

levelM.CollCache = {}

levelM.HasInitialized = false

levelM.Bind = ScriptService.WaitChild("LevelBindEve")
levelM._RespawnPoint = ScriptService.WaitChild("RespawnPoint")

function levelM.loadLevel(levelName)
	if levelM.HasInitialized then
		TransitionModule.startTrans("Loading "..levelName.." please wait...")
	end
	local Folder = Hidden.WaitChild("Levels")
	local newLevel = Folder.FindChild(levelName).Clone()
	if not newLevel then
		print("Level not found")
	end
	newLevel.Name = "Level"
	if levelM.CurrentLevel then
		if levelM.CurrentLevel.FindChildByClass("Sound") then
			levelM.CurrentLevel.FindChildByClass("Sound").Stop()
		end
		if levelM.CurrentLevel.FindChildByClass("LocalScript") then
			levelM.CurrentLevel.FindChildByClass("LocalScript").IsEnabled = false
		end
		levelM.CurrentLevel.Destroy()
	end
	levelM.CurrentLevel = newLevel
	newLevel.Parent = Environment
	
	local physFold = newLevel.FindChild(constants.PHYS_FOLD)
	
	local ball = findBall.find(Players.LocalPlayer.Name)
	local lvlSpawn = levelM.CurrentLevel.WaitChild("Spawn")
	local newSpawnParticles = SpawnParticles:Clone()
	wait(0.1)
	ball.Size = Vector3.One
	ball.Anchored = false
	ball.CanCollide = true
	ball.Color = constants.DEFAULT_BALL_COLOR
	newSpawnParticles.Position = lvlSpawn.Position
	newSpawnParticles.Parent = newLevel
	if levelM._RespawnPoint.Value ~= Vector3.Zero then
		ball.Position = levelM._RespawnPoint.Value
		levelM._RespawnPoint.Value = Vector3.Zero
	else
		ball.Position = lvlSpawn.Position
	end
	lvlSpawn:Destroy()
	
	physFold.Parent = levelM.CurrentLevel
	for _, items in physFold:GetChildren() do
		if items then
			items.Anchored = false
		end
	end
	
	local CollFold = newLevel.FindChild("Collectables")
	if CollFold then
		for _, obj in CollFold:GetChildren() do
			local newCollectable = Hidden.Collectable.Clone()
			newCollectable.Position = obj.Position
			newCollectable.Parent = CollFold
			obj.Destroy()
		end
	end
	
	levelM.CollCache = CollFold:GetChildren()
	
	local InvisFold = newLevel.FindChild("Invisible")
	if InvisFold then
		for _, obj in InvisFold:GetChildren() do
			obj.Color = Color.FromHSV(0,0,0,0)
		end
	end
	
	local DoorFold = newLevel.FindChild("Doors")
	if DoorFold then
		for _, obj in DoorFold:GetChildren() do
			local newDoor = Hidden.Door.Clone()
			newDoor.Position = obj.Position
			newDoor.Name = obj.Name
			newDoor.Model.Enter.Color = obj.Color
			obj.Destroy()
			newDoor.Parent = DoorFold
		end
	end
	
	local Song = newLevel.FindChildByClass("Sound")
	if Song then
		Song.Play()
	end
	
	lever.init(newLevel)
	
	local Script = newLevel.FindChildByClass("ClientScript")
	if Script then
		Script.IsEnabled = true
	end
	
	local grav = newLevel.FindChild("Gravity")
	if grav then
		Environment.Gravity = grav.Value
	else
		Environment.Gravity = constants.DEFAULT_GRAVITY
	end
	
	local gradSky = newLevel.FindChild("GradientSky")
	if gradSky then
		local prevSky = Lighting.FindChild("GradientSky")
		if prevSky then
			prevSky.Destroy()
		end
		gradSky.Parent = Lighting
	end
	
	local SLC = newLevel.FindChild("SunLightColor")
	if SLC then
		Lighting.SunLight.Color = SLC.Value
	else
		Lighting.SunLight.Color = constants.DEFAULT_SUNLIGHT_COLOR
	end
	
	ScriptService.CameraEffect.Invoke("Distance", 0)
	
	TransitionModule.endTrans()
end

function levelM.loop(dt)
	for _, col in levelM.CollCache do
		if not (col and col.Model) then continue end
		if not Camera.IsPositionInView(col.Model.Position) then continue end
		col.Model.Rotate(Vector3.New(30, 180, 45) * dt * 1.5)
	end
end

function levelM.init()
	print("initializing "..script.Name.."...")
	
	levelM.loadLevel(constants.START_LEVEL)
	
	levelM.Bind.Invoked:Connect(function(levelName)
		levelM.loadLevel(levelName)
	end)
	
	levelM.HasInitialized = true
	
	print(script.Name.." initialized!")
end

return levelM