
local LogicEngine = require("sphere.models.RhythmModel.LogicEngine")

local NoteChart		= require("ncdk.NoteChart")
local VelocityData	= require("ncdk.VelocityData")
local NoteData		= require("ncdk.NoteData")

local rhythmModel = {}

local logicEngine = LogicEngine:new()
rhythmModel.logicEngine = logicEngine
logicEngine.rhythmModel = rhythmModel

local timeEngine = {
	currentTime = 0,
	timeRate = 1,
	inputOffset = 0,
	timer = {isPlaying = true}
}
rhythmModel.timeEngine = timeEngine

logicEngine.timings = {
	ShortNote = {
		hit = {-0.1, 0.1},
		miss = {-0.2, 0.2}
	},
	LongNote = {
		startHit = {-0.1, 0.1},
		startMiss = {-0.2, 0.2},
		endHit = {-0.1, 0.1},
		endMiss = {-0.2, 0.2}
	}
}

local function test(notes, events, states)
	local noteChart = NoteChart:new()

	local layerData = noteChart.layerDataSequence:requireLayerData(1)
	layerData:setTimeMode("absolute")

	noteChart.inputMode:setInputCount("key", 1)

	do
		local timePoint = layerData:getTimePoint(
			0, -- absoluteTime in absolute mode
			-1 -- side, doesn't affect anything in absolute mode
		)

		local velocityData = VelocityData:new(timePoint)
		velocityData.currentVelocity = 1
		layerData:addVelocityData(velocityData)
	end

	for _, time in ipairs(notes) do
		if type(time) == "number" then
			local timePoint = layerData:getTimePoint(time, -1)

			local noteData = NoteData:new(timePoint)
			noteData.inputType = "key"
			noteData.inputIndex = 1

			noteData.noteType = "ShortNote"

			layerData:addNoteData(noteData)
		elseif type(time) == "table" then
			local timePoint = layerData:getTimePoint(time[1], -1)

			local startNoteData = NoteData:new(timePoint)
			startNoteData.inputType = "key"
			startNoteData.inputIndex = 1
			startNoteData.noteType = "LongNoteStart"
			layerData:addNoteData(startNoteData)

			timePoint = layerData:getTimePoint(time[2], -1)

			local endNoteData = NoteData:new(timePoint)
			endNoteData.inputType = "key"
			endNoteData.inputIndex = 1
			endNoteData.noteType = "LongNoteEnd"
			layerData:addNoteData(endNoteData)

			startNoteData.endNoteData = endNoteData
			endNoteData.startNoteData = startNoteData
		end
	end

	noteChart:compute()

	logicEngine.noteChart = noteChart

	local newStates = {}
	rhythmModel.scoreEngine = {
		scoreSystem = {receive = function(self, event)
			local eventCopy = {
				currentTime = event.currentTime,
				newState = event.newState,
				noteEndTime = event.noteEndTime,
				noteStartTime = event.noteStartTime,
				noteType = event.noteType,
				oldState = event.oldState,
			}
			-- print(inspect(eventCopy))
			table.insert(newStates, eventCopy)
		end},
	}

	logicEngine:load()

	local function press(time)
		logicEngine:receive({
			"key1",
			name = "keypressed",
			virtual = true,
			time = time
		})
	end
	local function release(time)
		logicEngine:receive({
			"key1",
			name = "keyreleased",
			virtual = true,
			time = time
		})
	end
	local function update(time)
		logicEngine:update()
	end

	-- for t = events[1][1], events[#events][1], 0.01 do
	-- 	table.insert(events, {t, "tu"})
	-- end
	-- table.sort(events, function(a, b) return a[1] < b[1] end)

	-- print(require("inspect")(events))

	for _, event in ipairs(events) do
		local time = event[1]
		for char in event[2]:gmatch(".") do
			if char == "p" then
				press(time)
			elseif char == "r" then
				release(time)
			elseif char == "u" then
				update(time)
			elseif char == "t" then
				timeEngine.currentTime = time
			end
		end
	end

	-- print(require("inspect")(newStates))

	if not states then return end
	assert(#states == #newStates)
	for i, event in ipairs(newStates) do
		assert(event.currentTime == states[i][1])
		assert(event.oldState == states[i][2])
		assert(event.newState == states[i][3])
	end
end

--[[
	Specs:

	press, release or update can change many states on one call
	press and release can affect the time of only one state change
	update should not affect the time of any state change
]]

-- 1 short note tests

local function test1sn()
test(
	{0},
	{{-1, "p"}},
	{{-1, "clear", "clear"}}
)

test(
	{0},
	{{-0.15, "p"}},
	{{-0.15, "clear", "missed"}}
)

test(
	{0},
	{{0, "p"}},
	{{0, "clear", "passed"}}
)

test(
	{0},
	{{0.15, "p"}},
	{{0.15, "clear", "missed"}}
)

test(
	{0},
	{{0.25, "p"}},
	{{0.2, "clear", "missed"}}
)

test(
	{0},
	{{1, "tu"}},
	{{0.2, "clear", "missed"}}
)
end
test1sn()

-- 2 short notes tests

test(
	{0, 0.3},
	{{0.15, "pp"}},
	{
		{0.15, "clear", "missed"},
		{0.15, "clear", "missed"},
	}
)

test(
	{0, 0.15},
	{{0.075, "pp"}},
	{
		{0.075, "clear", "passed"},
		{0.075, "clear", "passed"},
	}
)

test(
	{0, 0.25},
	{{0.25, "p"}},
	{
		{0.2, "clear", "missed"},
		{0.25, "clear", "passed"},
	}
)

test(
	{0, 0.15},
	{{0.15, "p"}},
	{
		{0.15, "clear", "missed"},
	}
)

test(
	{0, 0.15},
	{{0.15, "pp"}},
	{
		{0.15, "clear", "missed"},
		{0.15, "clear", "passed"},
	}
)

-- 1 long note tests

local function test1ln()
test(
	{{0, 1}},
	{{2, "tu"}},
	{
		{0.2, "clear", "startMissed"},
		{1.2, "startMissed", "endMissed"},
	}
)

test(
	{{0, 1}},
	{{0, "p"}, {1, "r"}},
	{
		{0, "clear", "startPassedPressed"},
		{1, "startPassedPressed", "endPassed"},
	}
)

test(
	{{0, 1}},
	{{-1, "p"}, {1, "r"}, {2, "tu"}},
	{
		{-1, "clear", "clear"},
		{0.2, "clear", "startMissed"},
		{1.2, "startMissed", "endMissed"},
	}
)

test(
	{{0, 1}},
	{{-0.15, "p"}},
	{{-0.15, "clear", "startMissedPressed"}}
)

test(
	{{0, 1}},
	{{0.15, "p"}},
	{{0.15, "clear", "startMissedPressed"}}
)

test(
	{{0, 1}},
	{{0.5, "p"}},
	{
		{0.2, "clear", "startMissed"},
		{0.5, "startMissed", "startMissedPressed"},
	}
)

test(
	{{0, 1}},
	{{0, "p"}, {0.85, "r"}},
	{
		{0, "clear", "startPassedPressed"},
		{0.85, "startPassedPressed", "endMissed"},
	}
)

test(
	{{0, 1}},
	{{0, "p"}, {1.15, "r"}},
	{
		{0, "clear", "startPassedPressed"},
		{1.15, "startPassedPressed", "endMissed"},
	}
)

test(
	{{0, 1}},
	{{0, "p"}, {1.25, "r"}},
	{
		{0, "clear", "startPassedPressed"},
		{1.2, "startPassedPressed", "endMissed"},
	}
)

test(
	{{0, 1}},
	{{0, "p"}, {0.85, "r"}},
	{
		{0, "clear", "startPassedPressed"},
		{0.85, "startPassedPressed", "endMissed"},
	}
)
end
test1ln()

-- long note + short note tests

local function test1lnsn()
test(
	{{0, 1}, 1},
	{{0, "p"}, {1, "rp"}},
	{
		{0, "clear", "startPassedPressed"},
		{1, "startPassedPressed", "endPassed"},
		{1, "clear", "passed"},
	}
)

test(
	{{0, 1}, 1},
	{{1, "tu"}},
	{
		{0.2, "clear", "startMissed"},
		{0.8, "startMissed", "endMissed"},
	}
)

test(
	{{0, 1}, 1},
	{{2, "tu"}},
	{
		{0.2, "clear", "startMissed"},
		{0.8, "startMissed", "endMissed"},
		{1.2, "clear", "missed"},
	}
)

test(
	{{0, 1}, 1},
	{{1, "p"}},
	{
		{0.2, "clear", "startMissed"},
		{0.8, "startMissed", "endMissed"},
		{1, "clear", "passed"},
	}
)

test(
	{{0, 1}, 1},
	{{-1, "p"}, {1, "r"}},
	{
		{-1, "clear", "clear"},
		{0.2, "clear", "startMissed"},
		{0.8, "startMissed", "endMissed"},
	}
)

test(
	{{0, 1}, 1},
	{{1, "tu"}, {10, "tu"}},
	{
		{0.2, "clear", "startMissed"},
		{0.8, "startMissed", "endMissed"},
		{1.2, "clear", "missed"},
	}
)

test(
	{{0, 1}, 1},
	{{10, "tu"}},
	{
		{0.2, "clear", "startMissed"},
		{0.8, "startMissed", "endMissed"},
		{1.2, "clear", "missed"},
	}
)

test(
	{{0, 1}, {2, 3}},
	{{4, "tu"}},
	{
		{0.2, "clear", "startMissed"},
		{1.2, "startMissed", "endMissed"},
		{2.2, "clear", "startMissed"},
		{3.2, "startMissed", "endMissed"},
	}
)
end
test1lnsn()

-- nearest logic

logicEngine.timings.nearest = true

test1sn()

-- 2 short notes tests

test(
	{0, 0.3},
	{{0.14, "pp"}},
	{
		{0.14, "clear", "missed"},
		{0.14, "clear", "missed"},
	}
)

test(
	{0, 0.3},
	{{0.16, "p"}},
	{
		{0.15, "clear", "missed"},
		{0.16, "clear", "missed"},
	}
)

test(
	{0, 0.3},
	{{0.15, "pp"}},
	{
		{0.15, "clear", "missed"},
		{0.15, "clear", "missed"},
	}
)

test(
	{0, 0.15},
	{{0.075, "pp"}},
	{
		{0.075, "clear", "passed"},
		{0.075, "clear", "passed"},
	}
)

test(
	{0, 0.15},
	{{0.07, "pp"}},
	{
		{0.07, "clear", "passed"},
		{0.07, "clear", "passed"},
	}
)

test(
	{0, 0.15},
	{{0.08, "pp"}},
	{
		{0.075, "clear", "missed"},
		{0.08, "clear", "passed"},
	}
)

test(
	{0, 0.25},
	{{0.25, "p"}},
	{
		{0.125, "clear", "missed"},
		{0.25, "clear", "passed"},
	}
)

test(
	{0, 0.15},
	{{0.15, "p"}},
	{
		{0.075, "clear", "missed"},
		{0.15, "clear", "passed"},
	}
)

test1ln()
test1lnsn()

test(
	{{0, 0.1}, 0.1},
	{{0.04, "pr"}, {0.1, "p"}},
	{
		{0.04, "clear", "startPassedPressed"},
		{0.04, "startPassedPressed", "endPassed"},
		{0.1, "clear", "passed"},
	}
)

test(
	{{0, 0.1}, 0.1},
	{{0.06, "p"}},
	{
		{0.05, "clear", "startMissed"},
		{-0.1, "startMissed", "endMissed"},
		{0.06, "clear", "passed"},
	}
)
