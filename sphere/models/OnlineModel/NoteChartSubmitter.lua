local ThreadPool	= require("aqua.thread.ThreadPool")
local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")


local NoteChartSubmitter = Class:new()

NoteChartSubmitter.construct = function(self)
	self.observable = Observable:new()
end

NoteChartSubmitter.load = function(self)
	ThreadPool.observable:add(self)
end

NoteChartSubmitter.unload = function(self)
	ThreadPool.observable:remove(self)
end

NoteChartSubmitter.receive = function(self, event)
	if event.name == "NoteChartSubmitResponse" then
		self.onlineModel:receive(event)
	end
end

NoteChartSubmitter.submitNoteChart = function(self, noteChartEntry)
    print(noteChartEntry.path)

	return ThreadPool:execute(
		[[
            local arg = {...}
            local path = arg[1]
            local hash = arg[2]

            local noteChartFile = love.filesystem.newFile(path, "r")
            local content = noteChartFile:read()
            local tempFile = io.open("temp", "wb")
            tempFile:write(content)
            tempFile:close()

            local request = require("luajit-request")

            print("request 1")
            local result, err, message = request.send("https://soundsphere.xyz/noteChart", {
                method = "POST",
                data = {
                    fileName = path:match("^.+/(.-)$"),
                    hash = hash
                }
            })

            if (not result) then
                print(err, message)
            end

            print(result.body)
            
            thread:push({
				name = "NoteChartSubmitResponse",
				body = result.body
			})

            print("request 2")
            local result, err, message = request.send("https://soundsphere.xyz/noteChart", {
                method = "POST",
                files = {
                    noteChart = "temp"
                }
            })

            if (not result) then
                print(err, message)
            end

            print(result.body)
            
            thread:push({
				name = "NoteChartSubmitResponse",
				body = result.body
			})
		]],
		{noteChartEntry.path, noteChartEntry.hash}
	)
end

return NoteChartSubmitter
