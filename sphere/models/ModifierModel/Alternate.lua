local Modifier	= require("sphere.models.ModifierModel.Modifier")

local Alternate = Modifier:new()

Alternate.type = "NoteChartModifier"
Alternate.interfaceType = "stepper"

Alternate.name = "Alternate"

Alternate.defaultValue = "key"
Alternate.range = {1, 2}
Alternate.values = {"key", "scratch"}

Alternate.description = "1 1 1 1 -> 1 2 1 2, doubles the input mode"

Alternate.getString = function(self, config)
	return "Alt"
end

Alternate.getSubString = function(self, config)
	return config.value:sub(1, 1):upper()
end

Alternate.applyMeta = function(self, config, state)
	local inputType = config.value
	local inputMode = state.inputMode
	if not inputMode[inputType] then
		return
	end
	inputMode[inputType] = inputMode[inputType] * 2
end

Alternate.apply = function(self, config)
	local noteChart = self.game.noteChartModel.noteChart

	local inputMode = noteChart.inputMode

	local inputType = config.value
	if not inputMode[inputType] then
		return
	end

	local inputAlternate = {}

	for _, layerData in noteChart:getLayerDataIterator() do
		if layerData.noteData[inputType] then
			local notes = {}
			for inputIndex, noteDatas in pairs(layerData.noteData[inputType]) do
				local newInputIndex = inputIndex
				for _, noteData in ipairs(noteDatas) do
					local isStartNote = noteData.noteType == "ShortNote" or noteData.noteType == "LongNoteStart"
					if isStartNote then
						inputAlternate[inputIndex] = inputAlternate[inputIndex] or 0

						if inputAlternate[inputIndex] == 0 then
							newInputIndex = (inputIndex - 1) * 2 + 1
							inputAlternate[inputIndex] = 1
						elseif inputAlternate[inputIndex] == 1 then
							newInputIndex = (inputIndex - 1) * 2 + 2
							inputAlternate[inputIndex] = 0
						end
					end

					notes[newInputIndex] = notes[newInputIndex] or {}
					table.insert(notes[newInputIndex], noteData)
				end
			end
			layerData.noteData[inputType] = notes
		end
	end

	inputMode[inputType] = inputMode[inputType] * 2

	noteChart:compute()
end

return Alternate
