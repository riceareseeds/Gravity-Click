local fBallM = {}

local constants = require(ScriptService.Constants)

fBallM.Folder = Environment.WaitChild(constants.BALL_FOLD)

function fBallM.find(plrName)
	local ball = fBallM.Folder.WaitChild(Players.LocalPlayer.Name)
	
	if not fBallM.Folder then
		print("Ball Folder not found")
	end
		
	if not ball then
		print("LocalPlayer ball not found")
	end
	
	return ball
end

return fBallM