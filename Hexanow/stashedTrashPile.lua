

--[[
function ReplaceWhiteHexanowCollectible(player, ID, slot)
	--print("White Collectible Now",ID)
	
	if slot == nil then
		slot = SelectedWhiteItem[playerID]
	end
	
	if slot ~= 1
	and slot ~= 2
	and slot ~= 3
	then
		return nil
	end
	
	player:RemoveCollectible(WhiteItem[playerID][slot], true)
	
	SetWhiteHexanowCollectible(player, ID, slot)
end
]]

--[[
function WhiteHexanowTrinket(ID)
	ID = ID & 32767
	--print("White Trinket Now",ID)
	WhiteHexanowCollectibleID = 0
	WhiteHexanowTrinketID = ID
	return ID
end
]]

--[[local hexanowObjectives = {
["damageIncrease"] = 0.0,
}]]

--[[
for i,kvp in ipairs(hexanowObjectives) do
	Isaac.ConsoleOutput(kvp.key)
	Isaac.ConsoleOutput("=")
	Isaac.ConsoleOutput(kvp.value)
	Isaac.ConsoleOutput("\n")
end
]]

--[[ MALFUNCTIONING
require("apioverride")
local baseEntityPlayerHasCollectible = APIOverride.GetCurrentClassFunction(EntityPlayer, "HasCollectible")
APIOverride.OverrideClassFunction(EntityPlayer, "HasCollectible", function(interval, Type, IgnoreModifiers)	
    local result = baseEntityPlayerHasCollectible(interval, Type, IgnoreModifiers)
	if interval:GetPlayerType() == playerTypeHexanow
	and (  Type == CollectibleType.COLLECTIBLE_ANALOG_STICK
		or Type == CollectibleType.COLLECTIBLE_URANUS
		or Type == CollectibleType.COLLECTIBLE_NEPTUNUS
	) then
		result = true
	end
	return result
end)

local baseHasCollectible = APIOverride.GetCurrentClassFunction(EntityPlayer, "HasCollectible")
APIOverride.OverrideClassFunction(EntityPlayer, "HasCollectible", function(self, Type, IgnoreModifiers, a,b,c,d,e,f,g,h,i,j,k,l,m,n)
	if self:GetPlayerType() == playerTypeHexanow
	and (  Type == CollectibleType.COLLECTIBLE_ANALOG_STICK
		or Type == CollectibleType.COLLECTIBLE_URANUS
		or Type == CollectibleType.COLLECTIBLE_NEPTUNUS
	) then
		return true
	end

	return baseHasCollectible(self, Type, IgnoreModifiers, a,b,c,d,e,f,g,h,i,j,k,l,m,n)
end)
]]

--[[
APIOverride.OverrideClassFunction(EntityPlayer, "GetMaxHearts", function()
    return 123456789
end)

APIOverride.OverrideClassFunction(EntityPlayer, "GetPlayerType", function()
    return PlayerType.PLAYER_AZAZEL 
end)
]]

		--return ( 770 - 77*TearDelay )/1062 临时方案
		--return ((-10*TearDelay)+math.sqrt(3)*math.sqrt(5867-260*TearDelay)+199)/60

--[[
function table.tostringex (t)
	local tableT = {"{"}

	function toStringF (k, v)
		if "number" == type(k) then
		elseif "string" == type(k) then
			table.insert(tableT, string.format("%s=", k))
		elseif "table" == type(k) then
			table.insert(tableT, string.format("table:%s=", k))
		elseif "function" == type(k) then
			table.insert(tableT, tostring(k))
		end

		if "table" == type(v) then
			table.insert(tableT, table.tostringex(v))
		elseif "number" == type(v) or "boolean" == type(v) then
			table.insert(tableT, tostring(v))
		else 
			table.insert(tableT, string.format("\"%s\"", tostring(v)))
		end

		table.insert(tableT, ",")
	end

	table.foreach(t, toStringF)
	table.remove(tableT, table.getn(tableT)) -- 删除逗号
	table.insert(tableT, "}")
	local tableStr = table.concat(tableT)
	return tableStr
end
function table.tostring (t, tabCountedP)
	local tableT = {"{\n"}
	if (nil == tabCountedP) then
		tabCounted = "    "
	else 
		tableT = {"\n", tabCounted, "{\n"}
	end

	function toStringF (k, v)
		table.insert(tableT, tabCounted)
		if "number" == type(k) then
			table.insert(tableT, string.format("[%s] = ", k))
		elseif "string" == type(k) then
			table.insert(tableT, string.format("\"%s\" = ", k))
		elseif "table" == type(k) then
			table.insert(tableT, string.format("table: %s = ", tostring(k)))
		end

		if "table" == type(v) then
			tabCounted = string.format("%s%s", tabCounted, "    ")
			returnStr = table.tostring(v, tabCounted)
			table.insert(tableT, returnStr)
			table.insert(tableT, ",") --分步添加，方便后面删除逗号
			table.insert(tableT, "\n")
		else
			table.insert(tableT, tostring(v))
			table.insert(tableT, ",")
			table.insert(tableT, "\n")
		end
	end

	--table.foreach(t, toStringF)
	for i,td in ipairs(t) do
		toStringF(i,td)
	end
	--table.remove(tableT, table.getn(tableT) -1) -- 删除逗号
	local manCount = 0
	for k,v in pairs(t) do
		manCount = manCount + 1
	end
	
	if manCount > 0 then
		table.remove(tableT, manCount -1) -- 删除逗号
	end
	tabCounted = string.sub(tabCounted, 1, -5) -- 缩进-1
	table.insert(tableT, string.format("%s}", tabCounted))
	local tableStr = table.concat(tableT)
	return tableStr, tabCounted
end
function stringToTable (stringP)
	local loadFunction = load("return " .. stringP)
	local loadTable = loadFunction()
	return loadTable
end

-- 读取mod数据
function LoadHexanowModData()
	local str = Isaac.LoadModData(hexanowMod)
	print("Load Readout: ", str)
	if str ~= nil and str ~= "" then
		hexanowObjectives = stringToTable()
	end
end

-- 存储mod数据
function SaveHexanowModData()
	local str = table.tostring(hexanowObjectives)
	print("Save Readout: ", str)
	Isaac.SaveModData(hexanowMod, str)
end
]]

-- 测试
function TestDoDmg(player)
	--[[
	if hexanowObjectives["damageIncrease"] == nil then
		hexanowObjectives["damageIncrease"] = 0.0
	end
	hexanowObjectives["damageIncrease"] = hexanowObjectives["damageIncrease"] +0.01
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	]]
end

--[[
-- 按键事件
function hexanowMod:InputAction(entity, inputHook, buttonAction)
	if entity ~= nil then
		local player = entity:ToPlayer()
		if player ~= nil
		and player:GetPlayerType() == playerTypeHexanow
		then
			local playerID = GetPlayerID(player)
			
			if buttonAction == ButtonAction.ACTION_DROP
			and inputHook == InputHook.IS_ACTION_PRESSED
			then
				local slot = SelectedWhiteItem[playerID]
				
				if slot == 1
				or slot == 2
				or slot == 3
				then
					slot = slot + 1
				else
					slot = 1
				end
				
				SelectedWhiteItem[playerID] = slot
			end
			
		end
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, hexanowMod.InputAction, InputHook.IS_ACTION_PRESSED)
]]

--[[
-- 在生成物品后运行
function hexanowMod:PostGetCollectible(SelectedCollectible, PoolType, Decrease, Seed)
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerTypeHexanow then
				SetWhiteHexanowCollectible(player, SelectedCollectible)
				UpdateCostumes(player)
			end
		end
	)
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, hexanowMod.PostGetCollectible)

-- 在生成饰品后运行
function hexanowMod:GetTrinket(SelectedTrinket, TrinketRNG)
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerTypeHexanow then
				WhiteHexanowTrinket(SelectedTrinket)
				UpdateCostumes(player)
			end
		end
	)
end
hexanowMod:AddCallback(ModCallbacks.MC_GET_TRINKET, hexanowMod.GetTrinket)
]]
