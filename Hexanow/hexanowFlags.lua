
hexanowFlags = { }
hexanowFlags.__index = hexanowFlags

function hexanowFlags:Wipe()
	self = { }
end

function hexanowFlags:HasFlag(flag)
	for i,hflag in ipairs(self) do
		if hflag == flag then
			return true
		end
	end
	return false
end

function hexanowFlags:AddFlag(flag)
	for i,hflag in ipairs(self) do
		if hflag == flag then
			return nil
		end
	end
	table.insert(self, flag)
end

function hexanowFlags:RemoveFlag(flag)
	for i,hflag in ipairs(self) do
		if hflag == flag then
			table.remove(self, i)
			return nil
		end
	end
end

function hexanowFlags:ToString()
	local str = ""
	for i,hflag in ipairs(self) do
		str = str..hflag..","
	end
	str = string.sub(str, 1, string.len(str)-1)
	return str
end

function hexanowFlags:LoadFromString(str)
	--print("recieve<"..str..">")

	local strTable = {}
	local pointer1 = 0
	local pointer2 = 0
	local count = 1
	local length = string.len(str)
	while pointer2 < length do
		local point,_ = string.find(str, ",", pointer2 + 1)
		if point == nil then
			point = length + 1
		end
		pointer1 = pointer2
		pointer2 = point
		
		table.insert(strTable, string.sub(str, pointer1 + 1, pointer2 - 1))
		
		count = count + 1
	end	
	for i,str in ipairs(strTable) do
		self:AddFlag(str)
	end
end
