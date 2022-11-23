local Class = require("Class")
local gfx_util = require("gfx_util")
local spherefonts		= require("sphere.assets.fonts")
local DynamicLayerData = require("ncdk.DynamicLayerData")
local Fraction = require("ncdk.Fraction")

local Layout = require("sphere.views.EditorView.Layout")

local SnapGridView = Class:new()

SnapGridView.construct = function(self)
	local ld = DynamicLayerData:new()
	self.layerData = ld

	ld:setTimeMode("measure")
	ld:setSignatureMode("short")
	ld:setRange(Fraction(0), Fraction(10))

	ld:getSignatureData(2, Fraction(3))

	ld:getTempoData(Fraction(1), 60)
	ld:getTempoData(Fraction(3.5, 10, true), 120)

	ld:getStopData(Fraction(5), Fraction(4))

	ld:getVelocityData(Fraction(0.5, 10, true), -1, 1)
	ld:getVelocityData(Fraction(4.5, 10, true), -1, 2)
	ld:getVelocityData(Fraction(5, 4), -1, 0)
	ld:getVelocityData(Fraction(6, 4), -1, 1)

	ld:getExpandData(Fraction(2), -1, Fraction(1))
end

local pixelsPerBeat = 40
SnapGridView.drawRangeTracker = function(self, rangeTracker, x, format)
	local object = rangeTracker.startObject
	if not object then
		return
	end

	local ld = self.layerData
	local measureOffsets = self.measureOffsets

	local endObject = rangeTracker.endObject
	while object and object <= endObject do
		local time = rangeTracker:getObjectTime(object)
		local measureIndex = time:floor()
		local offset = measureOffsets[measureIndex]
		if offset then
			local signature = ld:getSignature(measureIndex):tonumber()
			local y = offset + (time:tonumber() - measureIndex) * pixelsPerBeat * signature
			love.graphics.line(x, y, x + 10, y)
			gfx_util.printFrame(format(object), x - 500, y - 25, 490, 50, "right", "center")
		end

		object = object.next
	end
end

SnapGridView.drawComputedGrid = function(self, x, field)
	local ld = self.layerData
	for time = ld.startTime:floor(), ld.endTime:floor() - 1 do
		local timePoint = ld:getDynamicTimePoint(Fraction(time), -1)
		local y = timePoint[field] * pixelsPerBeat

		love.graphics.line(x, y, x + 40, y)

		local signature = ld:getSignature(time):floor()
		for i = 2, signature do
			timePoint = ld:getDynamicTimePoint(Fraction(time * signature + i - 1, signature), -1)
			local _y = timePoint[field] * pixelsPerBeat
			love.graphics.line(x, _y, x + 10, _y)
		end
	end
end

SnapGridView.draw = function(self)
	local graphicEngine = self.game.rhythmModel.graphicEngine

	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local x = w / 5

	local ld = self.layerData

	local measureOffsets = {}
	self.measureOffsets = measureOffsets

	local offset = 0
	for time = ld.startTime:floor(), ld.endTime:ceil() do
		local signature = ld:getSignature(time):tonumber()

		love.graphics.line(x, offset, x + 40, offset)

		for i = 2, signature do
			local y = offset + (i - 1) * pixelsPerBeat
			love.graphics.line(x, y, x + 10, y)
		end

		measureOffsets[time] = offset
		offset = offset + pixelsPerBeat * signature
	end

	x = x - 40

	self:drawRangeTracker(ld.tempoDatasRange, x, function(object)
		return object.tempo .. " bpm"
	end)

	self:drawRangeTracker(ld.stopDatasRange, x, function(object)
		return "stop " .. object.duration:tonumber() .. " beats"
	end)

	self:drawRangeTracker(ld.velocityDatasRange, x, function(object)
		return object.currentSpeed .. "x"
	end)

	self:drawRangeTracker(ld.expandDatasRange, x, function(object)
		return "expand into " .. object.duration:tonumber() .. " beats"
	end)

	local _, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local t = my / pixelsPerBeat
	local dtp = ld:getDynamicTimePointAbsolute(t, -1, 192)

	x = x + 40
	local measureIndex = dtp.measureTime:floor()
	local offset = measureOffsets[measureIndex]
	if offset then
		local signature = ld:getSignature(measureIndex):tonumber()
		local y = offset + (dtp.measureTime:tonumber() - measureIndex) * pixelsPerBeat * signature
		love.graphics.circle("fill", x, y, 4)
	end

	x = x + 80
	self:drawComputedGrid(x, "absoluteTime")
	love.graphics.circle("fill", x, my, 4)

	x = x + 80
	self:drawComputedGrid(x, "visualTime")
	local dtp = ld:getDynamicTimePointAbsolute(t, -1, 192)
	love.graphics.circle("fill", x, dtp.visualTime * pixelsPerBeat, 4)
end

return SnapGridView
