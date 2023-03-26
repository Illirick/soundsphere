local Class = require("Class")
local gfx_util = require("gfx_util")
local math_util = require("math_util")
local spherefonts = require("sphere.assets.fonts")
local just = require("just")
local Fraction = require("ncdk.Fraction")
local time_util = require("time_util")
local imgui = require("imgui")

local Layout = require("sphere.views.EditorView.Layout")

return function(self)
	local editorModel = self.game.editorModel
	local editorTimePoint = editorModel.timePoint
	local ld = editorModel.layerData

	local w, h = Layout:move("footer")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local lineHeight = h
	imgui.setSize(w, h, 200, lineHeight)

	just.row(true)

	local play_pause = editorModel.timer.isPlaying and "pause" or "play"
	local button_pressed = imgui.TextButton("play/pause", play_pause, 100, h)
	local key_pressed = just.keypressed("space")
	if button_pressed or key_pressed then
		if editorModel.timer.isPlaying then
			editorModel:pause()
		else
			editorModel:play()
		end
	end

	local fullLength = editorModel.lastTime - editorModel.firstTime
	local pos = (editorTimePoint.absoluteTime - editorModel.firstTime) / fullLength
	local newTime = imgui.Slider("time slider", pos, w / 4, h, time_util.format(editorTimePoint.absoluteTime, 3))

	if just.active_id == "time slider" then
		if newTime then
			editorModel:scrollSeconds(newTime * fullLength + editorModel.firstTime)
		end
		if editorModel.timer.isPlaying then
			editorModel:pause()
			editorModel.dragging = true
		end
	elseif editorModel.dragging then
		editorModel:play()
		editorModel.dragging = false
	end

	just.row()

	just.emptyline(-2 * h)

	local newRate = imgui.Slider("rate slider", editorModel.timer.rate, w / 6, h, ("%0.2fx"):format(editorModel.timer.rate))
	if newRate then
		editorModel.timer:setRate(math.min(math.max(newRate, 0.25), 1))
	end
end
