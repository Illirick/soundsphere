local class = require("class")

---@class sphere.InputAnimationView
---@operator call: sphere.InputAnimationView
local InputAnimationView = class()

---@param event table
function InputAnimationView:receive(event)
	local key = event and event[1]
	if key == self.input then
		if event.name == "keypressed" then
			-- if self.released then
			-- 	self.released:setTime(math.huge)
			-- end
			if self.pressed then
				self.pressed:setTime(0)
			end
			if self.hold then
				local time = 0
				if self.pressed then
					local range = self.pressed.range
					time = (math.abs(range[2] - range[1]) + 1) / self.pressed.rate
				end
				self.hold:setCycles(math.huge)
				self.hold:setTime(-time)
			end
		elseif event.name == "keyreleased" then
			if self.released then
				self.released:setTime(0)
			end
			-- if self.pressed then
			-- 	self.pressed:setTime(math.huge)
			-- end
			if self.hold then
				self.hold:setCycles(1)
				self.hold:setTime(math.huge)
			end
		end
	end
end

return InputAnimationView
