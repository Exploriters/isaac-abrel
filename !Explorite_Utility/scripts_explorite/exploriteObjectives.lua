
local keyValuePair = {key = "", value = "", used = false}
keyValuePair.__index = keyValuePair
function Explorite.KeyValuePair(key, value)
	return keyValuePair:ctor(key, value)
end
function keyValuePair:ctor(key, value)
	local cted = {}
	setmetatable(cted, keyValuePair)
	cted.key = key
	cted.value = value
	cted.used = false
	return cted
end

local exploriteObjectives = { data = { } }
exploriteObjectives.__index = exploriteObjectives
function Explorite.NewExploriteObjectives()
	return exploriteObjectives:ctor()
end
function exploriteObjectives:ctor()
	local cted = {}
	setmetatable(cted, exploriteObjectives)
	cted.data = { }
	return cted
end

function exploriteObjectives:Wipe()
	for i in next, self.data do rawset(self.data, i, nil) end
end

function exploriteObjectives:Read(key, default)
	for i,kvp in ipairs(self.data) do
		if kvp.key == key then
			kvp.used = true
			return kvp.value
		end
	end
	self:Write(key, default).used = true
	return default
end

function exploriteObjectives:Write(key, value)
	for i,kvp in ipairs(self.data) do
		if kvp.key == key then
			kvp.value = value
			return kvp
		end
	end
	local ret = Explorite.KeyValuePair(key, value)
	table.insert(self.data, ret)
	return ret
end

function exploriteObjectives:ToString(ignoreUnused)
	local str = ""
	for i,kvp in ipairs(self.data) do
		if ignoreUnused ~= true or kvp.used == true then
			str = str..tostring(kvp.key).."="..tostring(kvp.value).."\n"
		end
	end
	return str
end

function exploriteObjectives:LoadFromString(str)
	local strTable = {}
	local lastPoint = 0
	while true do
		local point1,point2 = string.find(str, "[^\n]+", lastPoint + 1)
		if point1 == nil then
			break
		end
		lastPoint = point2
		table.insert(strTable, string.sub(str, point1, point2))
	end
	for i,str in ipairs(strTable) do
		local point = string.find(str, "=", 1)
		if point ~= nil then
			local key = string.sub(str, 1, point - 1)
			local value = string.sub(str, point + 1, string.len(str))
			self:Write(key, value)
		end
	end
end
