local SPH = {}

local constants = require(ScriptService.Constants)

local StatsEvent = ScriptService.StatsEvent

SPH.Folder = nil

local function createFolder()
	local newFolder = Instance.New("Folder")
	newFolder.Name = constants.BALL_FOLD
	newFolder.Parent = Environment
	return newFolder
end

local function createBall(name)
	local newBall: Part = ServerHidden.Ball.Clone()
	newBall.Name = name
	newBall.Position = Vector3.New(0, 100, 0)
	newBall.Parent = SPH.Folder
	return newBall
end

local function removePlrModel(plr)
	plr.Size = Vector3.Zero
	plr.Position = Vector3.One*99999
end

local function addNameTag(object)
	local newTag = ServerHidden.NameTag.Clone()
	newTag.Text = object.Name
	newTag.Parent = object
	newTag.Position = object.Position + Vector3.New(0, 1, 0)
end

local function makePlrBall(plr)
	local plrBall = createBall(plr.Name)
	addNameTag(plrBall)
	plrBall.SetNetworkAuthority(plr)
end

local function initConnections()
	Players.PlayerAdded:Connect(function(plr)
		print(plr.Name.." Joined!")
		removePlrModel(plr)
		makePlrBall(plr)
		local stat = Stats.FindChild("Collectables")
		stat.Set(plr, 0)
	end)
	Players.PlayerRemoved:Connect(function(plr)
		print(plr.Name.." Left!")
		local plrBall = SPH.Folder.FindChild(plr.Name)
		if plrBall then
			plrBall.Destroy()
		end
	end)
	StatsEvent.InvokedServer:Connect(function(sender, msg)
		local amount = msg.GetNumber("amount")
		local stat = Stats.FindChild("Collectables")
		stat.Set(sender, stat.Get(sender) + amount)
	end)
end

function SPH.init()
	print("Initializing "..script.Name.."...")
	SPH.Folder = createFolder()
	initConnections()
	print(script.Name.." Initialized!")
end

return SPH