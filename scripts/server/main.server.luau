--local LevelHandler = require(ScriptService.LevelHandler)
local SPH = require(ScriptService.ServerPlayerHandler)
local BadgeHandler = require(ScriptService.BadgeHandler)

print("Initializing Server Handlers...")
--LevelHandler.init()
BadgeHandler.init()
SPH.init()
print("Server Handlers Initialized!")