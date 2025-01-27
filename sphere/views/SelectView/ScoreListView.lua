local ListView = require("sphere.views.ListView")
local just = require("just")
local TextCellImView = require("sphere.imviews.TextCellImView")
local Format = require("sphere.views.Format")
local time_util = require("time_util")

local ScoreListView = ListView()

ScoreListView.rows = 5

function ScoreListView:reloadItems()
	self.stateCounter = self.game.selectModel.scoreStateCounter
	self.items = self.game.scoreLibraryModel.items
end

---@return number
function ScoreListView:getItemIndex()
	return self.game.selectModel.scoreItemIndex
end

---@param delta number
function ScoreListView:scroll(delta)
	self.game.selectModel:scrollScore(delta)
end

---@param i number
---@param w number
---@param h number
function ScoreListView:drawItem(i, w, h)
	local scoreSourceName = self.game.scoreLibraryModel.scoreSourceName
	if scoreSourceName == "online" then
		self:drawItemOnline(i, w, h)
		return
	end

	local item = self.items[i]
	w = (w - 44) / 5

	just.row(true)
	just.indent(22)
	TextCellImView(w, h, "right", i == 1 and "rank" or "", item.rank)
	TextCellImView(w, h, "right", i == 1 and "rating" or "", Format.difficulty(item.rating))
	TextCellImView(w, h, "right", i == 1 and "time rate" or "", Format.timeRate(item.timeRate))
	if just.mouse_over(i .. "a", just.is_over(-w, h), "mouse") then
		self.game.gameView.tooltip = ("%0.2fX"):format(item.timeRate)
	end
	TextCellImView(w * 2, h, "right", item.time ~= 0 and time_util.time_ago_in_words(item.time) or "never", Format.inputMode(item.inputMode))
	if just.mouse_over(i .. "b", just.is_over(-w * 2, h), "mouse") then
		self.game.gameView.tooltip = os.date("%c", item.time)
	end
	just.row()
end

---@param i number
---@param w number
---@param h number
function ScoreListView:drawItemOnline(i, w, h)
	local item = self.items[i]
	w = (w - 44) / 7

	just.row(true)
	just.indent(22)
	TextCellImView(w, h, "right", i == 1 and "rank" or "", item.rank)
	TextCellImView(w, h, "right", i == 1 and "rating" or "", Format.difficulty(item.rating))
	TextCellImView(w, h, "right", i == 1 and "rate" or "", Format.timeRate(item.modifierset.timerate))
	TextCellImView(w, h, "right", i == 1 and "mode" or "", Format.inputMode(item.inputmode))
	-- if just.mouse_over(i .. "a", just.is_over(-w, h), "mouse") then
	-- 	self.game.gameView.tooltip = ("%0.2fX"):format(item.timeRate)
	-- end
	TextCellImView(w * 3, h, "right", item.time ~= 0 and time_util.time_ago_in_words(item.created_at) or "never", item.user.name)
	-- TextCellImView(w * 2, h, "right", item.time ~= 0 and time_util.time_ago_in_words(item.created_at) or "never", Format.inputMode(item.inputmode))
	if just.mouse_over(i .. "b", just.is_over(-w * 3, h), "mouse") then
		self.game.gameView.tooltip = os.date("%c", item.time)
	end
	just.row()
end

return ScoreListView
