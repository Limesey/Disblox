-- Script type: Module
-- Writen by github.com/Limesey, @Norbunny on Roblox.

-- services
local httpService = game:GetService("HttpService")

local module = {}

module.webhookConfig = {
	webhookUrl = "",
	overrideUsername = false,
	overrideAvatar = false,
	
	username = nil,
	avatar = nil
}

local function getDate()
	local date = os.date("!*t")
	
	local function format(i)
		if(string.len(i) == 1) then
			return string.format("0%s", i)
		else
			return i
		end
	end
	
	local str = string.format("%s-%s-%sT%s:%s:%s.000Z", date.year, date.month, date.day, format(date.hour), format(date.min), format(date.sec))
	return str
end

local function rgbToDec(rgb)
	local rgbTotal = rgb.R * 65536 + rgb.G * 256 + rgb.B
	
	return rgbTotal
end


local function getUsername()
	local config = module.webhookConfig
	
	if(config.overrideUsername) then
		return config.username
	end
end

local function getAvatar()
	local config = module.webhookConfig
	
	if(config.overrideAvatar) then
		return config.avatar
	end
end

function module.newMessage(message)
	
	if(message and string.len(message) > 2000) then
		warn("A message cannot be longer than 2000 characters.")
		message = string.sub(message, 1, 2000)
	end
	
	local content = {
		content = message,
		embeds = {},
		username =  getUsername() or "",
		avatar_url = getAvatar() or "",
	}
	
	function content.setWebhookUsername(name)
		if(not name) then error("Name cannot be nil.") end
		
		content.username = name
	end
	
	function content.setWebhookAvatar(url)
		if(not url) then error("URL cannot be nil.") end
		
		content.avatar_url = url
	end
	
	function content.addEmbed(title, description)
		local embed = {
			title = title,
			description = description,
			color = 0,
			fields = {},
			thumbnail = {
				url= ""
			},
			image= {
				url = ""
			},
			 author  = {
				 name  = "",
				 url  = "",
				 icon_url  = ""
			},
			 footer  = {
				 text  = "",
				 icon_url  = ""
			},
			 timestamp  = "" --"YYYY-MM-DDTHH:MM:SS.MSSZ"
		}
		
		if(title and string.len(title) > 256) then
			warn("Title cannot be longer than 265 characters.")
			title = string.sub(title, 1, 256)
		end
		
		if(description and string.len(description > 2048)) then
			warn("Description cannot be longer than 2048 characters.")
			description = string.sub(description, 1, 2048)
		end
		
		table.insert(content.embeds, embed)
		
		function embed.setColor(rgb)
			embed.color = rgbToDec(rgb)
		end
		
		function embed.addField(name, value, inline)
			if(not name or not value) then error("Name and value cannot be nil") end
			
			if(string.len(name) > 256) then
				warn("Field name cannot be longer than 256 characters.")
				name = string.sub(name, 1, 256)
			end
			
			if(string.len(value) > 1024) then
				warn("Field value cannot be longer than 1024 characters.")
				value = string.sub(value, 1, 1024)
			end
			
			inline = inline or false
			
			local field = {
				 name  = name,
				 value  = value,
				 inline  = inline
			}
			
			table.insert(embed.fields, field)
			return field
		end
		
		function embed.setAuthor(name, url, icon_url)
			if(not name and icon_url) then error("Name cannot be nil") end
			
			if(string.len(name) > 256) then
				warn("Author name cannot be longer than 256 characters.")
				name = string.sub(name, 1, 256)
			end
			
			embed.author.name = name
			embed.author.url = url
			embed.author.icon_url = icon_url
		end
		
		function embed.setThumbnail(url)
			if(not url) then error("URL cannot be nil") end
			
			embed.thumbnail.url = url
		end
		
		function embed.setImage(url)
			if(not url) then error("URL cannot be nil") end
			
			embed.image.url = url
		end
		
		function embed.setFooter(text, url)
			if(not text) then error("Text cannot be nil!") end
			
			if(string.len(text) > 2048) then
				warn("Footer text cannot be longer than 2048 characters.")
				text = string.sub(text, 1, 2048)
			end
			
			embed.footer.text = text
			embed.footer.icon_url = url
		end
		
		function embed.setTimestamp()
			embed.timestamp = getDate()
		end
		
		return embed
	end
	
	return content
end

function module:send(content)
	
	content = httpService:JSONEncode(content)
	
	local success, data = pcall(function()
		return httpService:PostAsync(module.webhookConfig.webhookUrl, content)
	end)
	
	return success, data
end

return module
