local Class = require("aqua.util.Class")

local TimeManager = Class:new()

TimeManager.rate = 1

TimeManager.load = function(self)
	self.currentTime = -1
	self.pauseTime = 0
	self.rateDelta = 0
	self.state = "waiting"
	self.playState = "delayed"
	
	self:loadTimePoints()
end

TimeManager.loadTimePoints = function(self)
	local absoluteTimes = {}

	local noteChart = self.engine.noteChart
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local timePointList = noteChart:requireLayerData(layerIndex).timeData.timePointList
		for timePointIndex = 1, #timePointList do
			local timePoint = timePointList[timePointIndex]
			absoluteTimes[timePoint.absoluteTime] = true
		end
	end
	
	local absoluteTimeList = {}
	for time in pairs(absoluteTimes) do
		absoluteTimeList[#absoluteTimeList + 1] = time
	end
	table.sort(absoluteTimeList)
	
	self.absoluteTimeList = absoluteTimeList
	self.nextTimeIndex = 1
end

TimeManager.updateNextTimeIndex = function(self)
	local timeList = self.absoluteTimeList
	while true do
		if
			timeList[self.nextTimeIndex + 1] and
			self.currentTime >= timeList[self.nextTimeIndex]
		then
			self.nextTimeIndex = self.nextTimeIndex + 1
		else
			break
		end
	end
end

TimeManager.getNearestTime = function(self)
	local timeList = self.absoluteTimeList
	local prevTime = timeList[self.nextTimeIndex - 1]
	local nextTime = timeList[self.nextTimeIndex]
	
	if not prevTime then
		return nextTime
	end
	
	local prevDelta = math.abs(self.currentTime - prevTime)
	local nextDelta = math.abs(self.currentTime - nextTime)
	
	if prevDelta < nextDelta then
		return prevTime
	else
		return nextTime
	end
end

TimeManager.update = function(self)
	local deltaTime = love.timer.getTime() - (self.startTime or 0)
	
	if self.state == "waiting" then
	elseif self.state == "delayed" then
		if self.currentTime >= 0 then
			self.state = "started"
			self.playState = self.state
		else
			self.currentTime = (deltaTime - self.pauseTime - self.rateDelta) * self.rate
		end
	elseif self.state == "started" or self.state == "playing" then
		self.state = "playing"
		self.playState = self.state
		
		self.currentTime = (deltaTime - self.pauseTime - self.rateDelta) * self.rate
	elseif self.state == "paused" then
		
	elseif self.state == "ended" then
		self.currentTime = (deltaTime - self.pauseTime - self.rateDelta) * self.rate
	end
	
	self:updateNextTimeIndex()
end

TimeManager.unload = function(self)

end

TimeManager.setRate = function(self, rate)
	if self.startTime then
		local pauseTime
		if self.state == "paused" then
			pauseTime = self.pauseTime + love.timer.getTime() - self.pauseStartTime
		else
			pauseTime = self.pauseTime
		end
		local deltaTime = love.timer.getTime() - self.startTime - pauseTime
		self.rateDelta = (self.rateDelta - deltaTime) * self.rate / rate + deltaTime
	end
	self.rate = rate
end

TimeManager.getRoundedTime = function(self)
	local nearestTime = self:getNearestTime()
	if math.abs(self.currentTime - nearestTime) < math.min(love.timer.getDelta() / 2, 1 / 30) then
		return nearestTime
	else
		return self.currentTime
	end
end

TimeManager.getTime = function(self)
	return self.currentTime
end

TimeManager.pause = function(self)
	self.state = "paused"
	self.pauseStartTime = love.timer.getTime()
end

TimeManager.play = function(self)
	if self.state == "waiting" then
		self.state = self.playState
		self.startTime = love.timer.getTime() - self.currentTime
	elseif self.state == "paused" then
		self.state = "playing"
		self.pauseTime = self.pauseTime + love.timer.getTime() - self.pauseStartTime
		self.pauseStartTime = love.timer.getTime()
	end
end

return TimeManager
