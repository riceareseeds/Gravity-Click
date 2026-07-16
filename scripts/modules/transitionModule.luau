local transM = {}

local constants = require(ScriptService.Constants)

transM.GUI = PlayerGUI.WaitChild("TransitionGUI")

local function transition(startValue, endValue, t)
	local traView = transM.GUI.Transition
	
	local borderTween = Tween.NewTween()
	borderTween.TweenNumber(endValue, startValue, t, function(val)
		traView.Left.SizeRelative = Vector2.New(val, 1.0)
		traView.Right.SizeRelative = Vector2.New(val, 1.0)
		traView.Top.SizeRelative = Vector2.New(1.0, val)
		traView.Bottom.SizeRelative = Vector2.New(1.0, val)
	end)
	borderTween.Play()
	wait(t)
end

function transM.startTrans(text)
	transM.GUI.Visible = true
	transition(1.0, 0.0, 0.5)
	transM.GUI.Label.Text = text
	transM.GUI.Label.Visible = true
	wait()
end

function transM.endTrans()
	spawn(function()
		transM.GUI.Visible = true
		transM.GUI.Label.Visible = false
		transition(0.0, 1.0, 0.5)
		transM.GUI.Visible = false
	end)
end

return transM