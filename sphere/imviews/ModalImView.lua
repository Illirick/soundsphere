local just = require("just")

local quit = false

---@param f function
---@param self table?
---@return any?
local function _draw(f, self)
	just.key_over()
	if quit then
		quit = false
		return f()
	end
	local ret = f(self)
	quit = self and just.keypressed("escape")
	return ret
end

return function(draw)
	return function(self)
		just.container("ModalImView", true)
		local ret = _draw(draw, self)
		just.container()
		return ret
	end
end
