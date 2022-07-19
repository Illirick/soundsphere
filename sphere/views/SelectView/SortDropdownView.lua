local DropdownView = require("sphere.views.DropdownView")

local SortDropdownView = DropdownView:new()

SortDropdownView.getCount = function(self)
	return #self.game.sortModel.names
end

SortDropdownView.scroll = function(self, delta)
	self.navigator:scrollSortFunction(delta)
end

SortDropdownView.getPreview = function(self)
	return self.game.sortModel.name
end

SortDropdownView.select = function(self, i)
	self.navigator:setSortFunction(self.game.sortModel:fromIndexValue(i))
end

SortDropdownView.getItemText = function(self, i)
	return self.game.sortModel.names[i]
end

return SortDropdownView
