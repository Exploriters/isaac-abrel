
local exploriteFlags = { data = { } }
exploriteFlags.__index = exploriteFlags
function Explorite.NewExploriteFlags()
	return exploriteFlags:ctor()
end
function exploriteFlags:ctor()
	local cted = {}
	setmetatable(cted, exploriteFlags)
	cted.data = { }
	return cted
end

function exploriteFlags:Wipe()
	for i in next, self.data do rawset(self.data, i, nil) end
end

function exploriteFlags:HasFlag(flag)
	for i,hflag in ipairs(self.data) do
		if hflag == flag then
			return true
		end
	end
	return false
end

function exploriteFlags:AddFlag(flag)
	for i,hflag in ipairs(self.data) do
		if hflag == flag then
			return nil
		end
	end
	table.insert(self.data, flag)
end

function exploriteFlags:RemoveFlag(flag)
	for i,hflag in ipairs(self.data) do
		if hflag == flag then
			table.remove(self.data, i)
			return nil
		end
	end
end

function exploriteFlags:ToString()
	local str = ""
	for i,hflag in ipairs(self.data) do
		str = str..hflag..","
	end
	str = string.sub(str, 1, string.len(str)-1)
	return str
end

function exploriteFlags:LoadFromString(str)
	--print("recieve<"..str..">")

	local strTable = {}
	local lastPoint = 0
	while true do
		local point1,point2 = string.find(str, "[^,]+", lastPoint + 1)
		if point1 == nil then
			break
		end
		lastPoint = point2
		table.insert(strTable, string.sub(str, point1, point2))
	end
	for i,str in ipairs(strTable) do
		self:AddFlag(str)
	end
end
