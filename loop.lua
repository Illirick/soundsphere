local Observable = require("Observable")
local thread = require("thread")
local delay = require("delay")
local asynckey = require("asynckey")
local just = require("just")
local LuaMidi = require("luamidi")
local flux = require("flux")
local reqprof = require("reqprof")

local loop = Observable()

loop.fpslimit = 240
loop.time = 0
loop.dt = 0
loop.eventTime = 0
loop.startTime = 0
loop.stats = {}
loop.asynckey = false
loop.dwmflush = false
loop.timings = {
	event = 0,
	update = 0,
	draw = 0,
}

local dwmapi
if love.system.getOS() == "Windows" then
	local ffi = require("ffi")
	dwmapi = ffi.load("dwmapi")
	ffi.cdef("void DwmFlush();")
end

local hasMidi

---@return number
local function getinportcount()
	return hasMidi and LuaMidi.getinportcount() or 0
end

loop.quitting = false
---@return number?
function loop:quittingLoop()
	love.event.pump()

	for name, a, b, c, d, e, f in love.event.poll() do
		if name == "quit" then
			loop:send({name = "quit"})
			return 0
		end
	end

	thread.update()
	delay.update()

	if thread.current == 0 then
		loop:send({name = "quit"})
		return 0
	end

	if love.graphics and love.graphics.isActive() then
		love.graphics.clear(love.graphics.getBackgroundColor())
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("waiting for " .. thread.current .. " coroutines", 0, 0, 1000, "left")
		love.graphics.present()
	end

	love.timer.sleep(0.1)
end

local framestarted = {name = "framestarted"}
---@return function
function loop:run()
	love.math.setRandomSeed(os.time())
	math.randomseed(os.time())
	love.timer.step()

	local fpsLimitTime = love.timer.getTime()
	loop.time = fpsLimitTime
	loop.startTime = fpsLimitTime
	loop.dt = 0

	hasMidi = LuaMidi.getinportcount() > 0

	return function()
		if loop.quitting then
			return loop:quittingLoop()
		end

		reqprof.start()

		if loop.asynckey and asynckey.start then
			asynckey.start()
		end

		loop.dt = love.timer.step()
		loop.time = love.timer.getTime()

		local timingsEvent = loop.time

		love.event.pump()

		framestarted.time = loop.time
		framestarted.dt = loop.dt
		loop:send(framestarted)

		local asynckeyWorking = loop.asynckey and asynckey.events
		if asynckeyWorking then
			if love.window.hasFocus() then
				for event in asynckey.events do
					loop.eventTime = event.time
					if event.state then
						love.keypressed(event.key, event.key)
					else
						love.keyreleased(event.key, event.key)
					end
				end
			else
				asynckey.clear()
			end
		end

		loop.eventTime = loop.time - loop.dt / 2
		for name, a, b, c, d, e, f in love.event.poll() do
			if name == "quit" then
				if not love.quit or not love.quit() then
					loop.quit()
					return a or 0
				end
			end
			if not asynckeyWorking or name ~= "keypressed" and name ~= "keyreleased" then
				love.handlers[name](a, b, c, d, e, f)
			end
		end

		for i = 0, getinportcount() - 1 do
			-- command, note, velocity, delta-time-to-last-event
			local a, b, c, d = LuaMidi.getMessage(i)
			while a do
				if a == 144 and c ~= 0 then
					love.midipressed(b, c, d)
				elseif a == 128 or c == 0 then
					love.midireleased(b, c, d)
				end
				a, b, c, d = LuaMidi.getMessage(i)
			end
		end

		local timingsUpdate = love.timer.getTime()
		loop.timings.event = timingsUpdate - timingsEvent

		thread.update()
		delay.update()
		flux.update(loop.dt)
		love.update(loop.dt)

		local timingsDraw = love.timer.getTime()
		loop.timings.update = timingsDraw - timingsUpdate

		local frameEndTime
		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.draw()
			just._end()
			love.graphics.origin()
			love.graphics.getStats(loop.stats)
			love.graphics.present() -- all new events are read when present is called
			if dwmapi and loop.dwmflush then
				dwmapi.DwmFlush()
			end
			frameEndTime = love.timer.getTime()
		end

		local timingsSleep = love.timer.getTime()
		loop.timings.draw = timingsSleep - timingsDraw

		if loop.fpslimit > 0 then
			fpsLimitTime = math.max(fpsLimitTime + 1 / loop.fpslimit, frameEndTime)
			love.timer.sleep(fpsLimitTime - frameEndTime)
		end
	end
end

loop.callbacks = {
	"update",
	"draw",
	"textinput",
	"keypressed",
	"keyreleased",
	"mousepressed",
	"gamepadpressed",
	"gamepadreleased",
	"joystickpressed",
	"joystickreleased",
	"midipressed",
	"midireleased",
	"mousemoved",
	"mousereleased",
	"wheelmoved",
	"resize",
	-- "quit",
	"filedropped",
	"directorydropped",
	"focus",
	"mousefocus",
}

-- all events are from [time - dt, time]

---@param time number
---@return number
local function clampEventTime(time)
	return math.min(math.max(time, loop.time - loop.dt), loop.time)
end

function loop:init()
	local e = {}
	for _, name in pairs(loop.callbacks) do
		love[name] = function(...)
			local icb = just.callbacks[name]
			if icb and icb(...) then return end
			e[1], e[2], e[3], e[4], e[5], e[6] = ...
			e.name = name
			e.time = clampEventTime(loop.eventTime)
			return loop:send(e)
		end
	end
	love.quit = function(...)
		print("Quitting")
		loop.quitting = true
		return true
	end
end

function loop:quit()
	LuaMidi.gc()
end

return loop
