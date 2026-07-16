local tetoM = {}

function tetoM.tetoize(teto)
	local newSound = script.Sound.Clone()
	newSound.Position = teto.Position
	newSound.Parent = teto
	spawn(function()
		while wait(math.random(200,1000)/100) do
			teto.Velocity += Vector3.New(math.random(-25, 25), math.random(10, 50), math.random(-5, 5))
			teto.Sound.Play()
		end
	end)
end

function tetoM.init(folder)
	for _, teto in folder:GetChildren() do
		if string.find(teto.Name, "Teto") then
			tetoM.tetoize(teto)
		end
	end
end

return tetoM