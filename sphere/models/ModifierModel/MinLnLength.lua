local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.MinLnLength: sphere.Modifier
---@operator call: sphere.MinLnLength
local MinLnLength = Modifier + {}

MinLnLength.type = "NoteChartModifier"
MinLnLength.interfaceType = "slider"

MinLnLength.name = "MinLnLength"

MinLnLength.defaultValue = 0.4
MinLnLength.range = {0, 40}
MinLnLength.step = 0.025

MinLnLength.description = "Convert long notes to short notes if they are shorter than this length"

---@param config table
---@return string
function MinLnLength:getString(config)
	return "MLL"
end

---@param config table
---@return string
function MinLnLength:getSubString(config)
	return tostring(config.value * 1000)
end

---@param config table
function MinLnLength:apply(config)
	local duration = config.value
	local noteChart = self.noteChart

	for noteDatas in noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			if noteData.noteType == "LongNoteStart" or noteData.noteType == "LaserNoteStart" then
				if (noteData.endNoteData.timePoint.absoluteTime - noteData.timePoint.absoluteTime) <= duration then
					noteData.noteType = "ShortNote"
					noteData.endNoteData.noteType = "Ignore"
				end
			end
		end
	end
end

return MinLnLength
