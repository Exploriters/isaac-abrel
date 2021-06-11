
keyValuePair = {key = "", value = ""}
keyValuePair.__index = keyValuePair
function KeyValuePair(key, value)
  return keyValuePair:ctor(key, value)
end
function keyValuePair:ctor(key, value)
  local cted = {}
  setmetatable(cted, keyValuePair)
  cted.key = key
  cted.value = value
  return cted
end

hexanowObjectives = { }
hexanowObjectives.__index = hexanowObjectives

function hexanowObjectives:Wipe()
	self = { }
end

function hexanowObjectives:Read(key, default)
	for i,kvp in ipairs(self) do
		if kvp.key == key then
			return kvp.value
		end
	end
	return default
end

function hexanowObjectives:Write(key, value)
	for i,kvp in ipairs(self) do
		if kvp.key == key then
			kvp.value = value
			return value
		end
	end
	table.insert(self, KeyValuePair(key, value))
	return value
end

function hexanowObjectives:ToString()
	local str = ""
	for i,kvp in ipairs(self) do
		str = str..tostring(kvp.key).."="..tostring(kvp.value).."\n"
	end
	return str
end

function hexanowObjectives:LoadFromString(str)
	--print("RAW:\n"..str)
	local strTable = {}
	local pointer1 = 0
	local pointer2 = 0
	local count = 1
	while true do
		local point = string.find(str, "\n", count)
		if point == nil then
			break
		end
		pointer1 = pointer2
		pointer2 = point
		
		table.insert(strTable, string.sub(str, pointer1 + 1, pointer2 - 1))
		
		count = count + 1
	end
	--print("Splt by line complete with "..tostring(count).." lines.")
	
	for i,str in ipairs(strTable) do
		local point = string.find(str, "=", 1)
		if point ~= nil then
			local key = string.sub(str, 1, point - 1)
			local value = string.sub(str, point + 1, 256)
			self:Write(key, value)
		end
	end
	--print("Load from string result:\n"..self:ToString())
end
