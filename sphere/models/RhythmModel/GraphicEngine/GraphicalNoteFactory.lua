local FileFinder = require("sphere.filesystem.FileFinder")
local ShortGraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.ShortGraphicalNote")
local LongGraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.LongGraphicalNote")
local ImageNote = require("sphere.models.RhythmModel.GraphicEngine.ImageNote")

local GraphicalNoteFactory = {}

---@param noteData ncdk.NoteData
---@return string
local function getImageNoteType(noteData)
	local image = noteData.images[1] and noteData.images[1][1]
	if image and FileFinder:getType(image) == "video" then
		return "VideoNote"
	end
	return "ImageNote"
end

local notes = {
	ShortNote = {ShortGraphicalNote, "ShortNote"},
	LongNoteStart = {LongGraphicalNote, "LongNote"},
	LaserNoteStart = {LongGraphicalNote, "LongNote"},
	LineNoteStart = {LongGraphicalNote, "LongNote"},
	SoundNote = {ShortGraphicalNote, "SoundNote"},
	ImageNote = {ImageNote, getImageNoteType},
}

---@param noteData ncdk.NoteData
---@return sphere.GraphicalNote?
function GraphicalNoteFactory:getNote(noteData)
	local classAndType = notes[noteData.noteType]
	if not classAndType then
		return
	end

	local noteType = classAndType[2]
	if type(noteType) == "function" then
		noteType = noteType(noteData)
	end

	return classAndType[1](noteType, noteData)
end

return GraphicalNoteFactory
