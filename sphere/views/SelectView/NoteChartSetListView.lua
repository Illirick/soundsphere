local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local NoteChartSetListItemView = require(viewspackage .. "SelectView.NoteChartSetListItemView")

local NoteChartSetListView = ListView:new()

NoteChartSetListView.construct = function(self)
	ListView.construct(self)
	self.itemView = NoteChartSetListItemView:new()
	self.itemView.listView = self
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

NoteChartSetListView.reloadItems = function(self)
	self.state.items = self.noteChartSetLibraryModel.items
end

NoteChartSetListView.getItemIndex = function(self)
	return self.selectModel.noteChartSetItemIndex
end

NoteChartSetListView.scrollUp = function(self)
	self.navigator:scrollNoteChartSet("up")
end

NoteChartSetListView.scrollDown = function(self)
	self.navigator:scrollNoteChartSet("down")
end

return NoteChartSetListView
