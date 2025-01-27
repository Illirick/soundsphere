local class = require("class")
local NoteChartExporter = require("sph.NoteChartExporter")
local OsuNoteChartExporter = require("osu.NoteChartExporter")
local FileFinder = require("sphere.filesystem.FileFinder")

---@class sphere.EditorController
---@operator call: sphere.EditorController
local EditorController = class()

function EditorController:load()
	local selectModel = self.selectModel
	local editorModel = self.editorModel

	local noteChart = selectModel:loadNoteChart()
	local chartItem = selectModel.noteChartItem

	local noteSkin = self.noteSkinModel:getNoteSkin(noteChart.inputMode)
	noteSkin:loadData()
	noteSkin.editor = true

	editorModel.noteSkin = noteSkin
	editorModel.noteChart = noteChart
	editorModel.audioPath = chartItem.path:match("^(.+)/.-$") .. "/" .. noteChart.metaData.audioPath
	editorModel:load()

	self.previewModel:stop()

	FileFinder:reset()
	FileFinder:addPath(chartItem.path:match("^(.+)/.-$"))
	FileFinder:addPath(noteSkin.directoryPath)
	FileFinder:addPath("userdata/hitsounds")
	FileFinder:addPath("userdata/hitsounds/midi")

	self.resourceModel:load(chartItem.path, noteChart, function()
		editorModel:loadResources()
	end)

	self.windowModel:setVsyncOnSelect(false)
end

function EditorController:unload()
	self.editorModel:unload()

	local graphics = self.configModel.configs.settings.graphics
	local flags = graphics.mode.flags
	if graphics.vsyncOnSelect and flags.vsync == 0 then
		flags.vsync = self.windowModel.baseVsync
	end
end

function EditorController:save()
	local selectModel = self.selectModel
	local editorModel = self.editorModel

	self.editorModel:save()
	self.editorModel:genGraphs()

	local exp = NoteChartExporter()
	exp.noteChart = editorModel.noteChart

	local path = selectModel.noteChartItem.path:gsub(".sph$", "") .. ".sph"

	love.filesystem.write(path, exp:export())

	self.cacheModel:startUpdate(selectModel.noteChartItem.path:match("^(.+)/.-$"))
end

function EditorController:saveToOsu()
	local selectModel = self.selectModel
	local editorModel = self.editorModel

	self.editorModel:save()

	local chartItem = selectModel.noteChartItem
	local exp = OsuNoteChartExporter()
	exp.noteChart = editorModel.noteChart
	exp.noteChartEntry = chartItem
	exp.noteChartDataEntry = chartItem

	local path = chartItem.path
	path = path:gsub(".osu$", ""):gsub(".sph$", "") .. ".sph.osu"

	love.filesystem.write(path, exp:export())
end

---@param event table
function EditorController:receive(event)
	self.editorModel:receive(event)
	if event.name == "filedropped" then
		self:filedropped(event[1])
	end
end

local exts = {
	mp3 = true,
	ogg = true,
}

---@param file love.File
function EditorController:filedropped(file)
	local path = file:getFilename():gsub("\\", "/")

	local _name, ext = path:match("^(.+)%.(.-)$")
	if not exts[ext] then
		return
	end

	local audioName = _name:match("^.+/(.-)$")
	local chartSetPath = "userdata/charts/editor/" .. os.time() .. " " .. audioName

	love.filesystem.write(chartSetPath .. "/" .. audioName .. "." .. ext, file:read())
end

return EditorController
