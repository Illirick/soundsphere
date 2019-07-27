local Modifier = require("sphere.game.ModifierManager.Modifier")

local AutoPlay = Modifier:new()

AutoPlay.name = "AutoPlay"

AutoPlay.apply = function(self)
	self.sequence.engine.autoplay = true
end

return AutoPlay