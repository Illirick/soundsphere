local GameplayViewConfig = require("sphere.views.GameplayView.GameplayViewConfig")
local GameplayNavigator	= require("sphere.views.GameplayView.GameplayNavigator")
local ScreenView = require("sphere.views.ScreenView")

local GameplayView = ScreenView:new({construct = false})

GameplayView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = GameplayViewConfig
	self.navigator = GameplayNavigator:new()
end

GameplayView.load = function(self)
	self.game.rhythmModel.observable:add(self.sequenceView)
	self.game.gameplayController:load()

	local noteSkin = self.game.rhythmModel.graphicEngine.noteSkin
	for i, config in ipairs(self.viewConfig) do
		if config.class == "PlayfieldView" then
			self.playfieldViewConfig = self.viewConfig[i]
			self.playfieldViewConfigIndex = i
			self.viewConfig[i] = noteSkin.playField
		end
	end

	self.subscreen = ""
	self.failed = false
	ScreenView.load(self)
end

GameplayView.unload = function(self)
	self.game.gameplayController:unload()
	self.game.rhythmModel.observable:remove(self.sequenceView)
	ScreenView.unload(self)
	self.viewConfig[self.playfieldViewConfigIndex] = self.playfieldViewConfig
end

GameplayView.update = function(self, dt)
	self.game.gameplayController:update(dt)

	local state = self.game.rhythmModel.pauseManager.state
	if state == "play" then
		self.subscreen = ""
	elseif state == "pause" then
		self.subscreen = "pause"
	end

	if self.game.rhythmModel.pauseManager.needRetry then
		self.failed = false
		self.game.gameplayController:retry()
	end

	local timeEngine = self.game.rhythmModel.timeEngine
	if timeEngine.currentTime >= timeEngine.maxTime + 1 then
		self:quit()
	end

	local pauseOnFail = self.game.configModel.configs.settings.gameplay.pauseOnFail
	local failed = self.game.rhythmModel.scoreEngine.scoreSystem.hp.failed
	if pauseOnFail and failed and not self.failed then
		self.game.gameplayController:changePlayState("pause")
		self.failed = true
	end

	local multiplayerModel = self.game.multiplayerModel
	if multiplayerModel.room and not multiplayerModel.isPlaying then
		self:quit()
	end

	ScreenView.update(self, dt)
end

GameplayView.receive = function(self, event)
	self.game.gameplayController:receive(event)
	ScreenView.receive(self, event)
end

GameplayView.quit = function(self)
	local hasResult = self.game.gameplayController:hasResult()
	if hasResult then
		return self:changeScreen("resultView")
	end
	return self:changeScreen("selectView")
end

return GameplayView
