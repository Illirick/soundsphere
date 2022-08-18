local Class = require("aqua.util.Class")
local UpdateModel = require("sphere.models.UpdateModel")
local ConfigModel = require("sphere.models.ConfigModel")
local WindowManager = require("sphere.window.WindowManager")
local aquathread = require("aqua.thread")
local aquatimer = require("aqua.timer")

local UpdateController = Class:new()

UpdateController.construct = function(self)
	self.updateModel = UpdateModel:new()
	self.configModel = ConfigModel:new()
	self.windowManager = WindowManager:new()

	for k, v in pairs(self) do
		v.game = self
	end
end

UpdateController.updateAsync = function(self)
	local updateModel = self.updateModel
	local configModel = self.configModel

	configModel:read("settings", "urls", "files")

	local configs = configModel.configs

	if
		not configs.settings.miscellaneous.autoUpdate or
		configs.urls.update == "" or
		love.filesystem.getInfo(".git")
	then
		return
	end

	self.windowManager:load()

	function love.update()
		aquathread.update()
		aquatimer.update()
		self.windowManager:update()
	end

	function love.draw()
		love.graphics.printf(updateModel.status, 0, 0, love.graphics.getWidth())
	end

	return updateModel:updateFilesAsync()
end

return UpdateController