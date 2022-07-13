local utf8 = require("utf8")
local Class = require("aqua.util.Class")
local erfunc = require("libchart.erfunc")

local SearchModel = Class:new()

SearchModel.searchFilter = ""
SearchModel.searchLamp = ""
SearchModel.collection = {path = ""}
SearchModel.stateCounter = 1

SearchModel.setSearchString = function(self, searchMode, text)
	if searchMode == "filter" then
		self:setSearchFilter(text)
	else
		self:setSearchLamp(text)
	end
	self.stateCounter = self.stateCounter + 1
end

SearchModel.setSearchFilter = function(self, text)
	self.searchFilter = text
end

SearchModel.setSearchLamp = function(self, text)
	self.searchLamp = text
end

SearchModel.setCollection = function(self, collection)
	self.collection = collection
end

local numberFields = {
	{
		keys = {"difficulty", "d"},
		field = "noteChartDatas.difficulty",
	},
	{
		keys = {"length", "l"},
		field = "noteChartDatas.length",
		transform = function(self, v)
			if tonumber(v) then
				return tonumber(v)
			end
			local n, s = v:match("(%d+)(%a+)")
			if s == "m" then
				return n * 60
			end
		end,
	},
	{
		keys = {"bpm", "b"},
		field = "noteChartDatas.bpm",
	},
	{
		keys = {"notesCount", "nc"},
		field = "noteChartDatas.notesCount",
	},
	{
		keys = {"level", "lv"},
		field = "noteChartDatas.level",
	},
	{
		keys = {"longNotes", "ln"},
		field = "noteChartDatas.longNoteRatio * 100",
	},

	{
		keys = {"missCount", "m"},
		field = "scores.missCount",
	},
	{
		keys = {"accuracy", "a"},
		field = "scores.accuracy * 1000",
	},
	{
		keys = {"score", "s"},
		field = "-scores.accuracy",
		transform = function(self, v)
			if not tonumber(v) then
				return
			end
			v = tonumber(v)
			if v <= 0 then
				return -1000
			end
			if v >= 10000 then
				return 0
			end
			local window = self.game.configModel.configs.settings.gameplay.ratingHitTimingWindow
			local accuracy = window / (erfunc.erfinv(v / 10000) * math.sqrt(2))
			if accuracy ~= accuracy or math.abs(accuracy) == math.huge then
				return 0
			end
			return -accuracy
		end,
	},
}

local numberFieldsMap = {}
for _, config in ipairs(numberFields) do
	for _, k in ipairs(config.keys) do
		assert(not numberFieldsMap[k], "duplicate key: " .. k)
		numberFieldsMap[k] = config
	end
end

local textFields = {
	"hash",
	"artist",
	"title",
	"name",
	"source",
	"tags",
	"creator",
	"inputMode",
}

local fieldLikePattern = {}
for _, key in ipairs(textFields) do
	table.insert(fieldLikePattern, ("noteChartDatas.%s LIKE <substring>"):format(key))
end
fieldLikePattern = "(" .. table.concat(fieldLikePattern, " OR ") .. ")"

local operators = {"=", ">", "<", ">=", "<=", "~=", "!="}
local operatorsMap = {}
for _, operator in ipairs(operators) do
	operatorsMap[operator] = operator
	if operator == "~=" then
		operatorsMap[operator] = "!="
	end
end

SearchModel.transformSearchString = function(self, s, addCollectionFilter, showNonManiaCharts)
	local searchString = s
	local conditions = {}

	if addCollectionFilter then
		local path = self.collection.path .. "/"
		table.insert(
			conditions,
			("substr(noteCharts.path, 1, %d) = %q"):format(utf8.len(path), path)
		)
	end

	if not showNonManiaCharts then
		table.insert(conditions, "noteChartDatas.inputMode != \"1osu\"")
		table.insert(conditions, "noteChartDatas.inputMode != \"1taiko\"")
		table.insert(conditions, "noteChartDatas.inputMode != \"1fruits\"")
	end

	for _, searchSubString in ipairs(searchString:split(" ")) do
		local key, operator, value = searchSubString:match("^(.-)([=><~!]+)(.+)$")
		if searchSubString == "!" or searchSubString == "~" then
			table.insert(conditions, "scores.id IS NULL")
		elseif key and operatorsMap[operator] then
			local config = numberFieldsMap[key]
			operator = operatorsMap[operator]
			if config then
				if config.transform then
					value = config.transform(self, value)
				else
					value = tonumber(value)
				end
				if value then
					table.insert(conditions, ("%s %s %s"):format(config.field, operator, value))
				end
			end
		elseif not key and searchSubString ~= "" then
			table.insert(conditions, (fieldLikePattern:gsub("<substring>", ("%q"):format("%%" .. searchSubString .. "%%"))))
		end
	end

	return table.concat(conditions, " AND ")
end

SearchModel.getConditions = function(self)
	local settings = self.game.configModel.configs.settings
	local showNonManiaCharts = settings.miscellaneous.showNonManiaCharts

	if self.searchLamp == "" then
		return self:transformSearchString(self.searchFilter, true, showNonManiaCharts)
	end

	return
		self:transformSearchString(self.searchFilter, true, showNonManiaCharts),
		self:transformSearchString(self.searchLamp)
end

return SearchModel
