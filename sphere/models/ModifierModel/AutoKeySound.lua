local Modifier = require("sphere.models.ModifierModel.Modifier")
local NoteData = require("ncdk.NoteData")

---@class sphere.AutoKeySound: sphere.Modifier
---@operator call: sphere.AutoKeySound
local AutoKeySound = Modifier + {}

AutoKeySound.type = "NoteChartModifier"
AutoKeySound.interfaceType = "toggle"

AutoKeySound.defaultValue = true
AutoKeySound.name = "AutoKeySound"
AutoKeySound.shortName = "AKS"

AutoKeySound.description = "Key sounds will not depend on the input"

---@param config table
---@return string?
function AutoKeySound:getString(config)
	if not config.value then
		return
	end
	return Modifier.getString(self, config)
end

---@param config table
function AutoKeySound:apply(config)
	if not config.value then
		return
	end

	local noteChart = self.noteChart

	for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
		local layerData = noteChart.layerDatas[layerDataIndex]
		for _, noteData in ipairs(noteDatas) do
			if noteData.noteType == "ShortNote" or noteData.noteType == "LongNoteStart" then
				local soundNoteData = NoteData(noteData.timePoint)

				soundNoteData.noteType = "SoundNote"
				soundNoteData.sounds, noteData.sounds = noteData.sounds, {}

				layerData:addNoteData(soundNoteData, "auto", 0)
			end
		end
	end
end

return AutoKeySound
