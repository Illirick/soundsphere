local Class				= require("Class")
local NoteHandler		= require("sphere.models.RhythmModel.LogicEngine.NoteHandler")

local LogicEngine = Class:new()

LogicEngine.load = function(self)
	self.sharedLogicalNotes = {}
	self.notesCount = {}

	self:loadNoteHandlers()
end

LogicEngine.update = function(self)
	self:updateNoteHandlers()
end

LogicEngine.unload = function(self)
	self.autoplay = false
	self.promode = false
end

LogicEngine.getEventTime = function(self)
	return self.eventTime or self.rhythmModel.timeEngine.currentTime
end

LogicEngine.sendScore = function(self, event)
	self.rhythmModel.scoreEngine.scoreSystem:receive(event)
end

LogicEngine.playSound = function(self, noteData, isBackground)
	if not self.rhythmModel.audioEngine then return end
	self.rhythmModel.audioEngine:playNote(noteData, isBackground)
end

LogicEngine.receive = function(self, event)
	if not event.virtual or self.promode then
		return
	end

	self.eventTime = event.time
	for _, noteHandler in ipairs(self.noteHandlers) do
		noteHandler:receive(event)
	end
	self.eventTime = nil
end

LogicEngine.loadNoteHandlers = function(self)
	self.noteHandlers = {}
	for noteDatas, inputType, inputIndex in self.noteChart:getInputIterator() do
		local noteHandler = NoteHandler:new({
			noteDatas = noteDatas,
			keyBind = inputType .. inputIndex,
			logicEngine = self
		})
		table.insert(self.noteHandlers, noteHandler)
		noteHandler:load()
	end
end

LogicEngine.updateNoteHandlers = function(self)
	if not self.rhythmModel.timeEngine.timer.isPlaying then
		return
	end
	for _, noteHandler in ipairs(self.noteHandlers) do
		noteHandler:update()
	end
end

return LogicEngine
