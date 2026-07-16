local mFillsM = {}

local map = script.Parent.Parent
local frames = map.WaitChild("Frames")

mFillsM.LeverEvent = ScriptService.WaitChild("LeverEvent")

mFillsM.Folder = frames.WaitChild("Moving")
mFillsM.Model = Instance.New("Model")

local fillIsUp = false

local MOVE_BY = 9.0

function mFillsM.init()
	mFillsM.Model.Parent = frames
	
	for _, Fill in mFillsM.Folder:GetChildren() do
		if not (Fill) then continue end
		Fill.Parent = mFillsM.Model
	end
	
	mFillsM.Model.Name = mFillsM.Folder.Name .. " Model"
	
	mFillsM.LeverEvent.Invoked:Connect(function(isUp)
		local target = mFillsM.Model.Position.Y
		local begin = mFillsM.Model.Position.Y
		if isUp then
			target += MOVE_BY
		else
			target -= MOVE_BY
		end
		Tween.NewTween().TweenNumber(begin, target, 0.215, function(val)
			mFillsM.Model.Position = mFillsM.Model.Position*Vector3.New(1, 0, 1)	+	Vector3.New(0, val, 0)
		end)
		fillIsUp = isUp
	end)
end

return mFillsM