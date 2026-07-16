local level = {}

local constants = require(ScriptService.Constants)

level.Folder = Environment.Levels

function level.init()
	print("Initializing "..script.Name.."...")
	local POF = Hidden[constants.POF_NAME]
	for _, level in level.Folder:GetChildren() do
		
	end
	print(script.Name.." Initialized!")
end

return level