local Class				= require("Class")
local Observable		= require("Observable")
local ScoreSystemContainer	= require("sphere.models.RhythmModel.ScoreEngine.ScoreSystemContainer")

local ScoreEngine = Class:new()

ScoreEngine.construct = function(self)
	self.observable = Observable:new()
	self.scoreSystem = ScoreSystemContainer:new()
end

ScoreEngine.load = function(self)
	local scoreSystem = self.scoreSystem
	scoreSystem.scoreEngine = self
	scoreSystem:load()

	self.inputMode = tostring(self.noteChart.inputMode)
	self.baseTimeRate = self.rhythmModel.timeEngine.baseTimeRate

	self.enps = self.baseEnps * self.baseTimeRate

	self.ratingDifficulty = self.enps * (1 + (self.longNoteRatio * (1 + self.longNoteArea)) * 0.25)

	self.bpm = self.noteChartDataEntry.bpm * self.baseTimeRate
	self.length = self.noteChartDataEntry.length / self.baseTimeRate

	self.pausesCount = 0
	self.paused = false

	self.minTime = self.noteChart.metaData.minTime
	self.maxTime = self.noteChart.metaData.maxTime
end

ScoreEngine.update = function(self)
	local timeEngine = self.rhythmModel.timeEngine
	local timer = timeEngine.timer
	local currentTime = timeEngine.currentTime

	if currentTime < self.minTime or currentTime > self.maxTime then
		return
	end
	if not timer.isPlaying and not self.paused then
		self.paused = true
		self.pausesCount = self.pausesCount + 1
	elseif timer.isPlaying and self.paused then
		self.paused = false
	end
end

return ScoreEngine
