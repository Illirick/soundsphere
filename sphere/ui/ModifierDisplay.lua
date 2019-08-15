local aquafonts = require("aqua.assets.fonts")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local Theme = require("aqua.ui.Theme")
local spherefonts = require("sphere.assets.fonts")
local ModifierManager = require("sphere.game.ModifierManager")

local ModifierDisplay = Theme.Button:new()

ModifierDisplay.sender = "ModifierDisplay"

ModifierDisplay.text = ""
ModifierDisplay.enableStencil = true

ModifierDisplay.rectangleColor = {255, 255, 255, 0}
ModifierDisplay.mode ="fill"
ModifierDisplay.limit = 1
ModifierDisplay.textAlign = {
	x = "left", y = "bottom"
}
ModifierDisplay.textColor = {255, 255, 255, 255}
ModifierDisplay.font = aquafonts.getFont(spherefonts.NotoSansRegular, 14)

ModifierDisplay.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
ModifierDisplay.x = 30/1920
ModifierDisplay.y = 1 - 2 * 67/1080
ModifierDisplay.w = 0.6 - 60/1920
ModifierDisplay.h = 67/1080

ModifierDisplay.updateText = function(self)
	self:setText(ModifierManager.sequence:tostring())
end

ModifierDisplay.interact = function(self)
	ModifierManager.sequence:remove()
	self:updateText()
end

ModifierDisplay.reload = function(self)
	Theme.Button.reload(self)
	self:updateText()
end

return ModifierDisplay
