--[[
local SimNumbersPath = "gfx/ui/SimNumbers.anm2"

-- 渲染单个数字
local function DrawSimNumberSingle(num, pos, bg)
	local sprite = Sprite()
	sprite:Load(SimNumbersPath, true)
	local AnimationName = "Base"
	
	if type(num) ~= "number" then
		num = 10
	else
		num = math.floor(num)
	end
	if num == -1 then
		num = 11
	elseif num < 0 or num > 9 then
		num = 10
	end
	
	if bg == true then
		AnimationName = "Background"
		pos = pos + Vector(2,2)
	end
	sprite:SetFrame(AnimationName, num)
	sprite:Render(pos, Vector(0,0), Vector(0,0))
	
	if num == 1 then
		return 4
	else
		return 6
	end
end

-- 渲染数字组
local function DrawSimNumberSeries(nums, pos, bg)
	local posp = 0
	for i,num in ipairs(nums) do
		posp = posp + DrawSimNumberSingle(num, pos + Vector(posp, 0), bg)
	end
end

-- 渲染多个数字
function DrawSimNumbers(num, pos)
	local nums = {}
	local inum = 0
	local negative = false
	local lessThanTen = false
	
	if type(num) ~= "number" then
		table.insert(nums, -2)
		table.insert(nums, -2)
	else
		inum = math.floor(num)
		if inum < 0 then
			negative = true
			inum = inum * -1
		end
		if inum < 10 then
			lessThanTen = true
		end
		
		while true do
			table.insert(nums, inum%10)
			inum = math.floor(inum/10)
			if inum == 0 then
				break
			end
		end
		
		if negative then
			table.insert(nums, -1)
		elseif lessThanTen then
			table.insert(nums, 0)
		end
		
		nums = ReverseTable(nums)
	end
	
	
	DrawSimNumberSeries(nums, pos, true)
	DrawSimNumberSeries(nums, pos, false)
end
]]