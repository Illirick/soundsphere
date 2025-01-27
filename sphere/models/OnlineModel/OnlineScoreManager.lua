local thread = require("thread")
local class = require("class")
local inspect = require("inspect")

---@class sphere.OnlineScoreManager
---@operator call: sphere.OnlineScoreManager
local OnlineScoreManager = class()

local async_read = thread.async(function(...) return love.filesystem.read(...) end)

OnlineScoreManager.submit = thread.coro(function(self, chartItem, replayHash)
	local webApi = self.webApi
	local api = webApi.api

	print("POST " .. api.scores)
	local notechart_filename = chartItem.path:match("^.+/(.-)$")
	local response, code, headers = api.scores:post({
		notechart_filename = notechart_filename,
		notechart_filesize = 0,
		notechart_hash = chartItem.hash,
		notechart_index = chartItem.index,
		replay_hash = replayHash,
		replay_size = 0,
	})
	if code ~= 201 then
		print(code)
		print(inspect(response))
		return
	end

	local score = webApi:newResource(headers.location):get({
		notechart = true,
		notechart_file = true,
		file = true,
	})
	if not score or not score.file or not score.notechart or not score.notechart.file then
		print("not score")
		return
	end

	local notechart = score.notechart
	if not notechart.is_complete then
		local file = notechart.file
		if not file.uploaded then
			local content = async_read(chartItem.path)
			api.files[file.id]:put(nil, {
				{content, name = "file", filename = notechart_filename},
			})
		end
		response, code, headers = api.notecharts[notechart.id]:_patch()
		if code ~= 200 then
			print(code)
			print(inspect(response))
		end
	end
	if not score.is_complete then
		local file = score.file
		if not file.uploaded then
			local content = async_read("userdata/replays/" .. replayHash)
			if content then
				response, code, headers = api.files[file.id]:put(nil, {
					{content, name = "file", filename = replayHash},
				})
				if code ~= 200 then
					print(code)
					print(inspect(response))
				end
			end
		end
		response, code, headers = api.scores[score.id]:_patch()
		if code ~= 200 then
			print(code)
			print(inspect(response))
		end
	end
	api.scores[score.id].leaderboards:put()

	score = api.scores[score.id]:get()
	print(inspect(score))
end)

return OnlineScoreManager
