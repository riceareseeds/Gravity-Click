local CameraModule = require(ScriptService.Camera)
local ControlModule = require(ScriptService.Controls)
local LevelModule = require(ScriptService.LevelModule)
local HitboxModule = require(ScriptService.HitboxModule)

print("Initializing Module Scripts...")
CameraModule.init()
LevelModule.init()
ControlModule.init()
HitboxModule.init()
print("Initializing Modules Complete!")

function _FixedUpdate(dt)
	ControlModule.loop(dt)
end

function _Update(dt)
	CameraModule.loop(dt)
	LevelModule.loop(dt)
end
