local discordrpc = require("discordrpc.discordrpc")

local DiscordPresence = {}

discordrpc.ready = function(userId, username, discriminator, avatar)
	return DiscordPresence:ready(userId, username, discriminator, avatar)
end

discordrpc.disconnected = function(errorCode, message)
	return DiscordPresence:disconnected(errorCode, message)
end

discordrpc.errored = function(errorCode, message)
	return DiscordPresence:errored(errorCode, message)
end

discordrpc.joinGame = function(joinSecret)
	return DiscordPresence:joinGame(joinSecret)
end

discordrpc.spectateGame = function(spectateSecret)
	return DiscordPresence:spectateGame(spectateSecret)
end

discordrpc.joinRequest = function(userId, username, discriminator, avatar)
	return DiscordPresence:joinRequest(userId, username, discriminator, avatar)
end

DiscordPresence.appId = "594443609668059149"

DiscordPresence.load = function(self)
	discordrpc.initialize(self.appId, true)
	
	self.presence = {}
	
	self.nextUpdate = 0
end

DiscordPresence.setPresence = function(self, presence)
	self.presence = self:validatePresence(presence)
end

DiscordPresence.validatePresence = function(self, presence)
	presence.state				= presence.state			and presence.state			:sub(1, 127)
	presence.details			= presence.details			and presence.details		:sub(1, 127)
	presence.startTimestamp		= presence.startTimestamp	--integer (52 bit, signed)
	presence.endTimestamp		= presence.endTimestamp		--integer (52 bit, signed)
	presence.largeImageKey		= presence.largeImageKey	and presence.largeImageKey	:sub(1, 21)
	presence.largeImageText		= presence.largeImageText	and presence.largeImageText	:sub(1, 127)
	presence.smallImageKey		= presence.smallImageKey	and presence.smallImageKey	:sub(1, 31)
	presence.smallImageText		= presence.smallImageText	and presence.smallImageText	:sub(1, 127)
	presence.partyId			= presence.partyId			and presence.partyId		:sub(1, 127)
	presence.partySize			= presence.partySize		--integer (32 bit, signed)
	presence.partyMax			= presence.partyMax			--integer (32 bit, signed)
	presence.matchSecret		= presence.matchSecret		and presence.matchSecret	:sub(1, 127)
	presence.joinSecret			= presence.joinSecret		and presence.joinSecret		:sub(1, 127)
	presence.spectateSecret		= presence.spectateSecret	and presence.spectateSecret	:sub(1, 127)
	presence.instance			= presence.instance			--integer (8 bit, signed)

	return presence
end

DiscordPresence.update = function(self)
	if self.nextUpdate < love.timer.getTime() then
		discordrpc.updatePresence(self.presence)
		self.nextUpdate = love.timer.getTime() + 2
	end
	return discordrpc.runCallbacks()
end

DiscordPresence.unload = function(self)
	return discordrpc.shutdown()
end

DiscordPresence.ready = function(self, userId, username, discriminator, avatar)
	print(string.format("Discord: ready (%s, %s, %s, %s)", userId, username, discriminator, avatar))
end

DiscordPresence.disconnected = function(self, errorCode, message)
	print(string.format("Discord: disconnected (%d: %s)", errorCode, message))
end

DiscordPresence.errored = function(self, errorCode, message)
	print(string.format("Discord: error (%d: %s)", errorCode, message))
end

DiscordPresence.joinGame = function(self, joinSecret)
	print(string.format("Discord: join (%s)", joinSecret))
end

DiscordPresence.spectateGame = function(self, spectateSecret)
	print(string.format("Discord: spectate (%s)", spectateSecret))
end

DiscordPresence.joinRequest = function(self, userId, username, discriminator, avatar)
	print(string.format("Discord: join request (%s, %s, %s, %s)", userId, username, discriminator, avatar))
	self:respond(userId, "yes")
end

DiscordPresence.respond = function(self, userId, reply)
	discordrpc.respond(userId, "yes")
end

return DiscordPresence
