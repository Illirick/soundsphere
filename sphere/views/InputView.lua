local bit = require("bit")
local ffi = require("ffi")
local imgui = require("cimgui")
local transform = require("aqua.graphics.transform")
local ImguiView = require("sphere.views.ImguiView")
local ImguiHotkey = require("aqua.imgui.Hotkey")

local InputView = ImguiView:new()

local keyPtr = ffi.new("const char*[1]")
local devicePtr = ffi.new("const char*[1]")

local tfTable = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}
local tfOriginTable = {0, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}
InputView.draw = function(self)
	local noteChart = self.gameController.noteChartModel.noteChart
	if not noteChart then
		return
	end

	local inputModeString = noteChart.inputMode:getString()
	local items = self.gameController.inputModel:getInputs(inputModeString)

	if self.isOpen[0] then
		imgui.SetNextWindowPos({transform(tfTable):transformPoint(279, 279)}, 0)
		imgui.SetNextWindowSize({transform(tfOriginTable):transformPoint(454, 522)}, 0)
		local flags = bit.bor(imgui.ImGuiWindowFlags_NoMove, imgui.ImGuiWindowFlags_NoResize)
		if imgui.Begin("Input bindings", self.isOpen, flags) then
			for i = 1, #items do
				local virtualKey = items[i].virtualKey
				local key, device = self.gameController.inputModel:getKey(inputModeString, virtualKey)
				keyPtr[0] = key
				devicePtr[0] = device
				if ImguiHotkey(virtualKey, keyPtr, devicePtr) then
					key = ffi.string(keyPtr[0])
					device = ffi.string(devicePtr[0])
					self.navigator:setInputBinding(inputModeString, virtualKey, key, device)
				end
			end
		end
		imgui.End()
	end
end

return InputView
