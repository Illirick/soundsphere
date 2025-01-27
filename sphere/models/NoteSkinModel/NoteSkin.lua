local class = require("class")
local NoteSkinData = require("sphere.models.NoteSkinModel.NoteSkinData")

---@class sphere.NoteSkin
---@operator call: sphere.NoteSkin
local NoteSkin = class()

---@param skin table?
function NoteSkin:new(skin)
	self.notes = {}
	self.inputs = {}
	self.textures = {}
	self.images = {}
	self.blendModes = {}

	self.data = NoteSkinData()
	self.data.noteSkin = self

	if not skin then
		return
	end

	for k, v in pairs(skin) do
		self[k] = v
	end
end

function NoteSkin:loadData()
	self.data:load()
end

---@param note sphere.GraphicalNote
---@return number?
function NoteSkin:check(note)
	return self.notes[note.noteType] and self.inputs[note.inputType .. note.inputIndex]
end

---@param input string
---@param index number?
---@return number?
function NoteSkin:getColumn(input, index)
	local inputs = self.inputs
	index = index or 1

	local c = 0
	for i = 1, #inputs do
		if inputs[i] == input then
			c = c + 1
			if c == index then
				return i
			end
		end
	end
end

---@param value any?
---@param column number
---@param timeState table?
---@param noteView sphere.NoteView?
---@return any?
function NoteSkin:getValue(value, column, timeState, noteView)
	if type(value) == "table" then
		value = value[column]
	end
	if type(value) == "function" then
		return value(timeState, noteView, column)  -- multiple values
	end
	return value
end

---@param noteView sphere.NoteView
---@param part string
---@param key string
---@param timeState table
---@return any?
function NoteSkin:get(noteView, part, key, timeState)
	local note = noteView.graphicalNote
	local noteType = noteView.noteType
	local column = self:getColumn(note.inputType .. note.inputIndex, noteView.index)

	local value =
		self.notes[noteType] and
		self.notes[noteType][part] and
		self.notes[noteType][part][key]

	return self:getValue(value, column, timeState, noteView)
end

---@param textures table
---@return table
function NoteSkin:setTextures(textures)
	self.textures = textures
	return textures
end

---@param images table?
---@return table
function NoteSkin:setImagesAuto(images)
	images = images or {}
	for i, texture in ipairs(self.textures) do
		local k, v = next(texture)
		images[k] = {k}
	end
	return self:setImages(images)
end

---@param images table
---@return table
function NoteSkin:setImages(images)
	local map = {}
	for i, texture in ipairs(self.textures) do
		local k, v = next(texture)
		map[k] = texture
	end
	for _, image in pairs(images) do
		image[1] = map[image[1]]
	end
	self.images = images
	return images
end

---@param blendModes table
---@return table
function NoteSkin:setBlendModes(blendModes)
	self.blendModes = blendModes
	return blendModes
end

---@param imageName string
---@return number
---@return number
function NoteSkin:getDimensions(imageName)
	local image = self.images[imageName]
	if not image then
		return 1, 1
	elseif image[2] then
		return image[2][3], image[2][4]
	elseif image[3] then
		return image[3][1], image[3][2]
	end
end

return NoteSkin
