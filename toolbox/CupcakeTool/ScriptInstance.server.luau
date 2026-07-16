local tool = script.Parent

local sound = tool["Sound"]

tool.Activated:Connect(function(Player)

    sound.Play()
    wait(2)

end)