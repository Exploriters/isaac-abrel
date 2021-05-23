--Isaac.ConsoleOutput("Init mod hexanow\n")

local hexanowMod = RegisterMod("Hexanow", 1);

local playerTypeHexanow = Isaac.GetPlayerTypeByName("Hexanow")
local playerTypeHexanowTainted = Isaac.GetPlayerTypeByName("Tainted Hexanow", true)

--local hexanowItem = Isaac.GetItemIdByName( "Hexanow's Soul" )
local hexanowPortalTool = Isaac.GetItemIdByName("Eternal Portal")
local hexanowFlightTriggerItem = Isaac.GetItemIdByName( "Hexanow flight trigger" )
local hexanowHairCostume = Isaac.GetCostumeIdByPath("gfx/characters/HexanowHair.anm2")
local hexanowBodyCostume = Isaac.GetCostumeIdByPath("gfx/characters/Hexanow_uranus.anm2")
local hexanowFateCostume = Isaac.GetCostumeIdByPath("gfx/characters/Hexanow_fate.anm2")

local entityVariantHeartsBlender = Isaac.GetEntityVariantByName("Hearts Blender")
local entityTypeHexanowPortal = Isaac.GetEntityTypeByName("Hexanow Blue Portal")

local EternalChargeSprite = Sprite()
EternalChargeSprite:Load("gfx/ui/EternalCharge.anm2", true)
local SimNumbersPath = "gfx/ui/SimNumbers.anm2"

local MC_ENTITY_TAKE_DMG_Room = 0
local MC_ENTITY_TAKE_DMG_Forever = 0

local HUDoffset = 10

local EternalCharges = 0
local EternalChargesLastRoom = 0

-- local lastMaxHearts = nil
-- local updatedCostumesOvertime = false
local onceHoldingItem = false
local lastCanFly = nil
local roomClearBounsEnabled = false
local EternalChargeForFree = true

local EternalChargeSuppressed = false
local Tainted = false

--local WhiteHexanowCollectibleID = 0
--local WhiteHexanowTrinketID = 0
--local WhiteHexanowCollectibleIDLastRoom = 0
--local WhiteHexanowTrinketIDLastRoom = 0

local portalBlue = nil
local portalOrange = nil
local teledProjectiles = {}
--local fireworksToWipe = {}
--local rainbowFireworkRng = RNG()
--local tempt = 0

local WhiteItem = {}
local SelectedWhiteItem = {}
local WhiteItemSelectPressed = {}
local WhiteItemLastRoom = {}
local SelectedWhiteItemLastRoom = {}

function initWhiteItemArray()
	WhiteItem[1] = {}
	WhiteItem[2] = {}
	WhiteItem[3] = {}
	WhiteItem[4] = {}
	
	SelectedWhiteItem[1] = 1
	SelectedWhiteItem[2] = 1
	SelectedWhiteItem[3] = 1
	SelectedWhiteItem[4] = 1
	
	WhiteItemSelectPressed[1] = 0
	WhiteItemSelectPressed[2] = 0
	WhiteItemSelectPressed[3] = 0
	WhiteItemSelectPressed[4] = 0
	
	WhiteItem[1][1] = 0
	WhiteItem[1][2] = 0
	WhiteItem[1][3] = 0
	
	WhiteItem[2][1] = 0
	WhiteItem[2][2] = 0
	WhiteItem[2][3] = 0
	
	WhiteItem[3][1] = 0
	WhiteItem[3][2] = 0
	WhiteItem[3][3] = 0
	
	WhiteItem[4][1] = 0
	WhiteItem[4][2] = 0
	WhiteItem[4][3] = 0
	
	WhiteItemLastRoom = WhiteItem
end

initWhiteItemArray()

-- 抹除临时变量
function WipeTempVar()
	EternalCharges = 0
	EternalChargesLastRoom = 0

	onceHoldingItem = false
	lastCanFly = nil
	roomClearBounsEnabled = false
	EternalChargeForFree = true
	
	EternalChargeSuppressed = false
	Tainted = false
	
	--WhiteHexanowCollectibleID = 0
	--WhiteHexanowTrinketID = 0

	portalBlue = nil
	portalOrange = nil
	teledProjectiles = {}
	
	initWhiteItemArray()
	UpdateLastRoomVar()
end

function UpdateLastRoomVar()
	EternalChargesLastRoom = EternalCharges
	WhiteItemLastRoom = WhiteItem
	SelectedWhiteItemLastRoom = SelectedWhiteItem
	
	--WhiteHexanowCollectibleIDLastRoom = WhiteHexanowCollectibleID
	--WhiteHexanowTrinketIDLastRoom = WhiteHexanowTrinketID
end

function RewindLastRoomVar()
	EternalCharges = EternalChargesLastRoom
	WhiteItem = WhiteItemLastRoom
	SelectedWhiteItem = SelectedWhiteItemLastRoom
	
	--WhiteHexanowCollectibleID = WhiteHexanowCollectibleIDLastRoom
	--WhiteHexanowTrinketID = WhiteHexanowTrinketIDLastRoom
end

function GetPlayerID(player)
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		if Isaac.GetPlayer(i).Index == player.Index then
			return i + 1
		end
	end
	return nil
end

function IsWhiteHexanowCollectible(player, ID)
	local playerID = GetPlayerID(player)

	if HexanowBlackCollectiblePredicate(ID) then
		return false
	end
	for i=1,3 do
		if WhiteItem[playerID][i] == ID then
			return true
		end
	end
	return false
end

function SetWhiteHexanowCollectible(player, ID, slot)
	-- print("White Collectible Now",ID)
	local playerID = GetPlayerID(player)
	
	if HexanowBlackCollectiblePredicate(ID) then
		return nil
	end
	
	if HexanowCollectibleMaxAllowed(player, ID) - player:GetCollectibleNum(ID, true) > 0 then
		return nil
	end
	
	if slot == nil then
		slot = SelectedWhiteItem[playerID]
	end
	
	if slot ~= 1
	and slot ~= 2
	and slot ~= 3
	then
		return nil
	end
	
	WhiteItem[playerID][slot] = ID
end

function PickupWhiteHexanowCollectible(player, ID, slot)
	local playerID = GetPlayerID(player)
	local item = Isaac.GetItemConfig():GetCollectible(ID)
	
	if HexanowBlackCollectiblePredicate(ID) then
		return nil
	end
	
	if HexanowCollectibleMaxAllowed(player, ID) - player:GetCollectibleNum(ID, true) > 0 then
		return nil
	end
	
	if slot == nil then
		slot = SelectedWhiteItem[playerID]
	end
	
	if slot ~= 1
	and slot ~= 2
	and slot ~= 3
	and slot ~= 4
	then
		return nil
	end
	
	if item ~= nil and item.Type == ItemType.ITEM_ACTIVE then
		local primaryAcItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
		if primaryAcItem ~= CollectibleType.COLLECTIBLE_NULL
		and not ( player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG, true)
			and player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == CollectibleType.COLLECTIBLE_NULL
			)
		then
			if WhiteItem[playerID][1] == primaryAcItem then slot = 1 end
			if WhiteItem[playerID][2] == primaryAcItem then slot = 2 end
			if WhiteItem[playerID][3] == primaryAcItem then slot = 3 end
		end
	end
	
	if slot == 4
	then
		return nil
	end
	
	if ID ~= CollectibleType.COLLECTIBLE_SCHOOLBAG
	and WhiteItem[playerID][slot] == CollectibleType.COLLECTIBLE_SCHOOLBAG then
		local secondaryID = player:GetActiveItem(ActiveSlot.SLOT_SECONDARY)
		if secondaryID ~= CollectibleType.COLLECTIBLE_NULL then
			if WhiteItem[playerID][1] == secondaryID then
				WhiteItem[playerID][1] = 0
			end
			if WhiteItem[playerID][2] == secondaryID then
				WhiteItem[playerID][2] = 0
			end
			if WhiteItem[playerID][3] == secondaryID then
				WhiteItem[playerID][3] = 0
			end
		end
	end
	
	SetWhiteHexanowCollectible(player, ID, slot)
end


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

--[[local hexanowObjectives = {
["damageIncrease"] = 0.0,
}]]

local hexanowObjectives = { }
hexanowObjectives.__index = hexanowObjectives

function hexanowObjectives_Wipe()
	hexanowObjectives = { }
end

function hexanowObjectives_Read(key, default)
	for i,kvp in ipairs(hexanowObjectives) do
		if kvp.key == key then
			return kvp.value
		end
	end
	return default
end

function hexanowObjectives_Write(key, value)
	for i,kvp in ipairs(hexanowObjectives) do
		if kvp.key == key then
			kvp.value = value
			return value
		end
	end
	table.insert(hexanowObjectives, KeyValuePair(key, value))
	return value
end

function hexanowObjectives_Apply()
	HUDoffset = tonumber(hexanowObjectives_Read("HUDoffset", "10"))
	EternalCharges = tonumber(hexanowObjectives_Read("EternalCharges", "0"))
	
	local ECSStr = hexanowObjectives_Read("EternalChargeSuppressed", "false")
	if ECSStr == "true" then
		EternalChargeSuppressed = true
	elseif ECSStr == "false" then
		EternalChargeSuppressed = false
	else
		EternalChargeSuppressed = nil
	end
	--print("Eternal charge suppression state "..tostring(EternalChargeSuppressed))

	local HTSStr = hexanowObjectives_Read("HexanowTaintedStarted", "false")
	if HTSStr == "true" then
		Tainted = true
	elseif HTSStr == "false" then
		Tainted = false
	else
		Tainted = nil
	end
	
	--[[
	local WHIStr = hexanowObjectives_Read("WhiteHexanowItem", "")
	local WHIpoint = string.find(WHIStr, ":", 1)
	if WHIpoint ~= nil then
		local prefix = string.sub(WHIStr, 1, WHIpoint - 1)
		local value = tonumber(string.sub(WHIStr, WHIpoint + 1, 256))
		
		if prefix == "Collectible" then
			SetWhiteHexanowCollectible(player, value)
		elseif prefix == "Trinket" then
			--WhiteHexanowTrinket(value)
		end
	end
	]]
	
	for i=1,4 do
		SelectedWhiteItem[i] = tonumber(hexanowObjectives_Read("SelectedWhiteItem-"..tostring(i), "1"))
		for j=1,3 do
			WhiteItem[i][j] = tonumber(hexanowObjectives_Read("WhiteItem-"..tostring(i).."-"..tostring(j), "0"))
		end
	end
	
	UpdateLastRoomVar()
end

function hexanowObjectives_Recieve()
	hexanowObjectives_Write("HUDoffset", tostring(HUDoffset))
	hexanowObjectives_Write("EternalCharges", tostring(EternalCharges))
	hexanowObjectives_Write("EternalChargeSuppressed", tostring(EternalChargeSuppressed))
	hexanowObjectives_Write("HexanowTaintedStarted", tostring(Tainted))
	
	--[[
	if WhiteHexanowCollectibleID ~= 0 then
		hexanowObjectives_Write("WhiteHexanowItem", "Collectible:"..tostring(WhiteHexanowCollectibleID))
	--elseif WhiteHexanowTrinketID ~= 0 then
	--	hexanowObjectives_Write("WhiteHexanowItem", "Trinket:"..tostring(WhiteHexanowTrinketID))
	else
		hexanowObjectives_Write("WhiteHexanowItem", "")
	end
	]]
	
	for i=1,4 do
		hexanowObjectives_Write("SelectedWhiteItem-"..tostring(i), tostring(SelectedWhiteItem[i]))
		for j=1,3 do
			hexanowObjectives_Write("WhiteItem-"..tostring(i).."-"..tostring(j), tostring(WhiteItem[i][j]))
		end
	end
end

function hexanowObjectives_ToString()
	local str = ""
	for i,kvp in ipairs(hexanowObjectives) do
		str = str..tostring(kvp.key).."="..tostring(kvp.value).."\n"
	end
	return str
end

function hexanowObjectives_LoadFromString(str)
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
			hexanowObjectives_Write(key, value)
		end
	end
	--print("Load from string result:\n"..hexanowObjectives_ToString())
end

--[[
for i,kvp in ipairs(hexanowObjectives) do
	Isaac.ConsoleOutput(kvp.key)
	Isaac.ConsoleOutput("=")
	Isaac.ConsoleOutput(kvp.value)
	Isaac.ConsoleOutput("\n")
end
]]

require("apioverride")
--[[ MALFUNCTIONING
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


function Tears2TearDelay(Tears)
	if Tears <= 0.77 then
		return 16 - 6 * Tears
	elseif Tears < 0 then
		return 16 - 6 * math.sqrt( Tears * 1.3 + 1 ) - 6 * Tears
	else
		return 16 - 6 * math.sqrt( Tears * 1.3 + 1 )
	end
end

function TearDelay2Tears(TearDelay)
	if TearDelay <= 10 then
		return ( ( - ( TearDelay - 16 ) / 6 )^2 - 1 )/1.3
	elseif TearDelay < 20.62 then
		return -(10*TearDelay+math.sqrt(3)*math.sqrt(5867-260*TearDelay)-199)/60
	else
		return ( 16 - TearDelay ) / 6
	end
end

function ApplyTears2TearDelay(TearDelay, Tears)
	return Tears2TearDelay(TearDelay2Tears(TearDelay) + Tears)
end

		--return ( 770 - 77*TearDelay )/1062 临时方案
		--return ((-10*TearDelay)+math.sqrt(3)*math.sqrt(5867-260*TearDelay)+199)/60

-- 为每个玩家执行目标函数
function CallForEveryPlayer(func)
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		func(Isaac.GetPlayer(i))
	end
end

-- 为每个实体执行目标函数
function CallForEveryEntity(func)
	local roomEntities = Isaac.GetRoomEntities()
	for i,entity in ipairs(roomEntities) do
		func(entity)
	end
end

-- 检测游戏中是否存在指定的玩家类型
function PlayerTypeExistInGame(playerType)
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		if Isaac.GetPlayer(i):GetPlayerType() == playerType then
			return true
		end
	end
	return false
end

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

-- 读取mod数据
function LoadHexanowModData()
	--Isaac.SaveModData(hexanowMod, "someThingWrong\nsomeThingWrong")
	local str = ""
	if Isaac.HasModData(hexanowMod) then
		str = Isaac.LoadModData(hexanowMod)
	--	if str == nil then
	--		print("Null readout!")
	--	else
	--		print("Load Readout:\n"..str)
	--	end
	--else
	--	print("Data does not exist")
	end
	hexanowObjectives_Wipe()
	hexanowObjectives_LoadFromString(str)
	hexanowObjectives_Apply()
end

-- 存储mod数据
function SaveHexanowModData()
	hexanowObjectives_Recieve()
	local str = hexanowObjectives_ToString()
	-- print("Save Readout: ", str)
	Isaac.SaveModData(hexanowMod, str)
end

-- 在游戏被初始化后运行
function hexanowMod:PostGameStarted(loadedFromSaves)	
	if not loadedFromSaves then -- 仅限新游戏
		LoadHexanowModData()
		WipeTempVar()
		SaveHexanowModData()
		CallForEveryPlayer(InitPlayerHexanowTainted)
		CallForEveryPlayer(InitPlayerHexanow)
	else -- 仅限从存档中读取
		WipeTempVar()
		LoadHexanowModData()
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, hexanowMod.PostGameStarted)

-- 在游戏退出前运行
function hexanowMod:PreGameExit(shouldSave)
	if not shouldSave then
		WipeTempVar()
	end
	SaveHexanowModData()
	WipeTempVar()
end
hexanowMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, hexanowMod.PreGameExit)

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

-- 更新玩家外观，按需执行
function UpdateCostumes(player)
	if player:GetPlayerType() == playerTypeHexanow then
		player:ClearCostumes()
		player:RemoveSkinCostume()
		
		--player:TryRemoveCollectibleCostume(CollectibleType.COLLECTIBLE_ANALOG_STICK, false)
		--player:TryRemoveCollectibleCostume(CollectibleType.COLLECTIBLE_URANUS, false)
		--player:TryRemoveCollectibleCostume(CollectibleType.COLLECTIBLE_NEPTUNUS, false)
		--player:TryRemoveNullCostume(hexanowHairCostume)
		--player:TryRemoveNullCostume(hexanowFateCostume)
		--player:TryRemoveNullCostume(hexanowBodyCostume)
		
		player:AddNullCostume(hexanowHairCostume)
		
		if player.CanFly then
			player:AddNullCostume(hexanowFateCostume)
		else
			--player:AddNullCostume(hexanowBodyCostume)
		end
	else
		player:TryRemoveNullCostume(hexanowHairCostume)
		player:TryRemoveNullCostume(hexanowBodyCostume)
		player:TryRemoveNullCostume(hexanowFateCostume)
	end
end

-- 提交缓存更新请求
function UpdateCache(player)
	--[[
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:AddCacheFlags(CacheFlag.CACHE_SPEED)
	player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
	player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
	player:AddCacheFlags(CacheFlag.CACHE_RANGE)
	player:AddCacheFlags(CacheFlag.CACHE_FLYING)
	]]
end

-- 给予永恒之心
function ApplyEternalHearts(player)
	if player:GetEternalHearts() <= 0 then
		player:AddEternalHearts(1)
	end
end

-- 给予永恒充能
function ApplyEternalCharge(player)
	if player:GetEternalHearts() <= 0 and EternalCharges > 0then
		player:AddEternalHearts(1)
		EternalCharges = EternalCharges - 1
	end
end

-- 确保随从数量
function EnsureFamiliars(player)
	local roomEntities = Isaac.GetRoomEntities()
	local HBcount = 0
	local HBcountTarget = 0
	for i, entity in pairs(roomEntities) do
		if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == entityVariantHeartsBlender then
			HBcount = HBcount + 1
			if HBcount > HBcountTarget then
				entity:Remove()
			end
		end
	end
	-- if HBcount < HBcountTarget then
		for i=HBcount, HBcountTarget - 1, 1 do
			local e = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, entityVariantHeartsBlender, 0, player.Position, Vector(0, 0), player)
		end
	-- end
end

-- 移除红心外的所有心
function RearrangeHearts(player)
	local soulHearts = player:GetSoulHearts()
	local blackHeartsByte = player:GetBlackHearts()
	
	local totalHearts = math.ceil((player:GetHearts() + soulHearts)*0.5)
	
	local countSoul = soulHearts
	local countBlack = 0
	local countBone = 0
	local countRott = player:GetRottenHearts()
	local countBroken = player:GetBrokenHearts()
	local countGold = math.min(player:GetGoldenHearts(), math.ceil(player:GetHearts()*0.5))
	player:AddGoldenHearts(-countGold)
	player:AddBrokenHearts(-countBroken)
	player:AddRottenHearts(-countRott*2)
	player:AddHearts(countRott*2)
	
	for i=0,totalHearts-1,1 do
		if player:IsBoneHeart(i) then
			countBone = countBone + 1
		end
	end
	
	local blackHeartsByteTemp = blackHeartsByte
	while blackHeartsByteTemp ~= 0 do
		if blackHeartsByteTemp & 1 == 1 then
			countBlack = countBlack + 1
		end
		blackHeartsByteTemp = blackHeartsByteTemp >> 1
	end
	
	countSoul = countSoul + countBlack * 2 + countBone * 2
	EternalCharges = EternalCharges + math.floor(countSoul)
	
	player:AddSoulHearts(-soulHearts)
	player:AddBoneHearts(-countBone)
	player:AddGoldenHearts(countGold)
	
	return nil ----------------------------------------------------------------
-- 弃用
-- 将魂心处理为黑心，放置于骨心后
--[[
	
	local boneMisArrangeState = 0
	for i=0,totalHearts-1,1 do
		if boneMisArrangeState == 0 and not player:IsBoneHeart(i) then
			boneMisArrangeState = 1
		elseif boneMisArrangeState == 1 and player:IsBoneHeart(i) then
			boneMisArrangeState = 2
		end
	end
	
	if boneMisArrangeState == 2
	or blackHeartsByte ~= 2^(math.ceil(soulHearts * 0.5)) - 1
	then
		player:AddSoulHearts(-soulHearts)
		player:AddBlackHearts(soulHearts) --math.ceil(soulHearts * 0.5)*2)
	end
	
	
	local num1,num2=math.modf(soulHearts*0.5)
    if num2 ~= 0 then
		player:AddBlackHearts(1)
		--
		--player:TakeDamage(
		--	1,
		--	DamageFlag.DAMAGE_NOKILL | DamageFlag.DAMAGE_INVINCIBLE ,
		--	EntityRef(nil),
		--	0
		--	)
		--
    end
]]
	
end

function TaintedHexanowRoomOverride()
	if not Tainted then
		return nil
	end
	
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	
	if Game().Difficulty ~= Difficulty.DIFFICULTY_GREED 
	and Game().Difficulty ~= Difficulty.DIFFICULTY_GREEDIER
	then
		for i,entity in ipairs(roomEntities) do
			
			local pickup = entity:ToPickup()
			if pickup ~= nil then
				if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.SubType ~= 0 then
					if room:GetBackdropType() == 51 and pickup.SubType ~= CollectibleType.COLLECTIBLE_RED_KEY then
						pickup:Morph(pickup.Type, pickup.Variant, CollectibleType.COLLECTIBLE_RED_KEY, true)
					end
					
					if pickup.SubType == CollectibleType.COLLECTIBLE_R_KEY
					or pickup.SubType == CollectibleType.COLLECTIBLE_SPINDOWN_DICE
					or pickup.SubType == CollectibleType.COLLECTIBLE_CLICKER
					then
						pickup:Morph(pickup.Type, pickup.Variant, CollectibleType.COLLECTIBLE_BREAKFAST, true)
					end
				end
				if room:GetBackdropType() == 49 and 
					 ( pickup.Variant == PickupVariant.PICKUP_CHEST 	
					or pickup.Variant == PickupVariant.PICKUP_BOMBCHEST 	
					or pickup.Variant == PickupVariant.PICKUP_SPIKEDCHEST 	
					or pickup.Variant == PickupVariant.PICKUP_ETERNALCHEST 	
					or pickup.Variant == PickupVariant.PICKUP_MIMICCHEST 	
					or pickup.Variant == PickupVariant.PICKUP_LOCKEDCHEST 
					)
				then
					pickup:Remove()
				end
			end
			
			if entity.Type == EntityType.ENTITY_SHOPKEEPER then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE, entity.Position, Vector(0,0), entity)
				entity:Remove()
			end
			
			
		end
	end
	
end

-- 初始化人物
function InitPlayerHexanowTainted(player)
	--print("CALLED!")
	--print("PType", player:GetPlayerType())
	--print("TType", playerTypeHexanowTainted)
	if player:GetPlayerType() == playerTypeHexanowTainted then
		--print("CALLED ACCEPT!")
		local level = Game():GetLevel()
		player:ChangePlayerType(playerTypeHexanow)
		Tainted = true
		
		player:AddTrinket(TrinketType.TRINKET_PERFECTION | 32768)
		--player:AddCard(Card.CARD_CRACKED_KEY)
		--player:AddCollectible(CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE, 0, false)
		player:AddCoins(99)
		player:AddBombs(99)
		player:AddKeys(99)
		--player:AddEternalHearts(24)
		EternalCharges = EternalCharges + 99
		
		local stageType = level:GetStageType()
		
		-- stageType == StageType.STAGETYPE_GREEDMODE
			--level:SetStage(LevelStage.STAGE7_GREED, stageType)
			--level:SetNextStage()
			--level:SetStage(13, stageType)
			--level:SetNextStage()
			
		if Game().Difficulty == Difficulty.DIFFICULTY_GREED 
		or Game().Difficulty == Difficulty.DIFFICULTY_GREEDIER 
		then
			Isaac.ExecuteCommand("stage 6")
		else
			Isaac.ExecuteCommand("stage 13")
		end
	end
end

-- 初始化人物
function InitPlayerHexanow(player)
	if player:GetPlayerType() == playerTypeHexanow then
		local itemPool = Game():GetItemPool()
		
		player:AddHearts(-player:GetHearts())
		player:AddMaxHearts(-player:GetMaxHearts())
		player:AddMaxHearts(12)
		player:AddHearts(11)
		
		player:AddGoldenKey()
		player:AddGoldenBomb()
		-- player:AddGoldenHearts(0)
		ApplyEternalHearts(player)
		
		--player:AddHearts(-1)
		--player:AddCard(Card.CARD_JUSTICE)
		--player:AddCard(Card.CARD_CRACKED_KEY)
		if Tainted then
			player:AddMaxHearts(12)
			player:AddHearts(13)
		else
			player:AddTrinket(TrinketType.TRINKET_NO | 32768)
		end
		-- player:AddCard(Card.CARD_SUN)
		-- player:AddTrinket(TrinketType.TRINKET_BIBLE_TRACT)
		
		-- print("PostGameStarted for", player:GetName())
		
		itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK)
		itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_URANUS)
		itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS)
		--itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_SOL)
		itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR)
		--itemPool:RemoveTrinket(TrinketType.TRINKET_NO)
		
		for i=0, PillColor.NUM_PILLS - 1, 1 do
			itemPool:IdentifyPill(i)
		end
		
		if player:GetActiveItem(ActiveSlot.SLOT_POCKET) ~= hexanowPortalTool -- CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR
		then
			--player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR, ActiveSlot.SLOT_POCKET, false)
			player:SetPocketActiveItem(hexanowPortalTool, ActiveSlot.SLOT_POCKET, false)
		end
		
		TickEventHexanow(player)
		UpdateCostumes(player)
	end
end

-- 物品谓词
function HexanowBlackCollectiblePredicate(ID)
	local item = Isaac.GetItemConfig():GetCollectible(ID)
	if item ~= nil and
		(
		item.ID == CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR
		or item.ID == CollectibleType.COLLECTIBLE_MEGA_MUSH
		)
	then
		return true
	else
		return false
	end
end

-- 物品谓词
function HexanowWhiteCollectiblePredicate(ID, ignoreEnsured)
	local item = Isaac.GetItemConfig():GetCollectible(ID)
	if item ~= nil and
		(	item:HasTags(ItemConfig.TAG_QUEST)
		or	item.ID == CollectibleType.COLLECTIBLE_POLAROID
		or	item.ID == CollectibleType.COLLECTIBLE_NEGATIVE
		or	item.ID == CollectibleType.COLLECTIBLE_BROKEN_SHOVEL
		or	item.ID == CollectibleType.COLLECTIBLE_BROKEN_SHOVEL_2
		or	item.ID == CollectibleType.COLLECTIBLE_MOMS_SHOVEL
		or	item.ID == CollectibleType.COLLECTIBLE_KEY_PIECE_1
		or	item.ID == CollectibleType.COLLECTIBLE_KEY_PIECE_2
		or	item.ID == CollectibleType.COLLECTIBLE_KNIFE_PIECE_1
		or	item.ID == CollectibleType.COLLECTIBLE_KNIFE_PIECE_2
		or	item.ID == CollectibleType.COLLECTIBLE_DADS_NOTE
		or	item.ID == CollectibleType.COLLECTIBLE_DOGMA
		or	item.ID == hexanowPortalTool
		--or	item.ID == CollectibleType.COLLECTIBLE_RED_KEY
		
		or (not ignoreEnsured == true and (
			item.ID == CollectibleType.COLLECTIBLE_ANALOG_STICK
		or	item.ID == CollectibleType.COLLECTIBLE_URANUS
		or	item.ID == CollectibleType.COLLECTIBLE_NEPTUNUS
		--or	item.ID == CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR
		))
		--or	item.ID == CollectibleType.COLLECTIBLE_BIRTHRIGHT
		
		--or	(item.Quality >= 4 and item.ItemType ~= ItemType.ITEM_FAMILIAR)
		
		--or	item.Type == ItemType.ITEM_ACTIVE
		)
	then
		return true
	else
		return false
	end
end

-- 返回物品持有数量上限
function HexanowCollectibleMaxAllowed(player, ID)
	local playerID = GetPlayerID(player)
	local num = 0
	
	if HexanowBlackCollectiblePredicate(ID)
	then
		return num
	end
	
	if HexanowWhiteCollectiblePredicate(ID, false) then
		num = num + 1
	end
	
	--[[
	if WhiteHexanowCollectibleID ~= 0
	and ID == WhiteHexanowCollectibleID
	then
		num = num + 1
	end
	]]
	
	for i=1,3 do
		if WhiteItem[playerID][i] == ID then
			num = num + 1
		end
	end
	
	return num
end

-- 玩家刻事件，每一帧执行
function TickEventHexanow(player)
	if player:GetPlayerType() == playerTypeHexanow then
		local game = Game()
		local level = game:GetLevel()
		local room = game:GetRoom()
		local roomEntities = Isaac.GetRoomEntities()
		local playerID = GetPlayerID(player)
		
		if game == nil
		or level == nil
		or room == nil
		or roomEntities == nil
		then
			return nil
		end
		
		--[[
		if not player:IsFlying() and Game():GetRoom():IsClear() and not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
			
			-- player:UseActiveItem(CollectibleType.COLLECTIBLE_BIBLE,false,true,true,false)
			-- player:UseCard(Card.CARD_HANGED_MAN)
			--if not player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
			--	player:AddCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE, 0, false)
			--	player:AddCacheFlags(CacheFlag.CACHE_FLYING)
			--	player:RemoveCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE)
			--end
			
			--player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_TRANSCENDENCE, false, 1)
			--player:AddCacheFlags(CacheFlag.CACHE_FLYING)
			
			-- player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_TRANSCENDENCE)
		end
		]]
		if Game():GetRoom():IsClear() and not roomClearBounsEnabled then
			roomClearBounsEnabled = true
			player:RemoveCollectible(hexanowFlightTriggerItem)
		end
		
		if roomClearBounsEnabled and not player:IsFlying() then
			player:RemoveCollectible(hexanowFlightTriggerItem)
		end
		
		--[[
		-- player:UseActiveItem(CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR,false,true,true,false)

		-- player:AddCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG, 0, false)
		-- player:AddCollectible(CollectibleType.COLLECTIBLE_MOMS_PURSE, 0, false)
		-- player:AddCollectible(CollectibleType.COLLECTIBLE_POLYDACTYLY, 0, false)
		-- player:AddCollectible(CollectibleType.COLLECTIBLE_PRAYER_CARD, 0, false)
		]]
		
		--[[
		if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
			player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_ANALOG_STICK, false)
		end
		]]
		--if room:GetBackdropType() ~= 59 and room:GetBackdropType() ~= 58 then
			if not player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK, true) then
				player:AddCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK, 0, false)
				UpdateCostumes(player)
			end
			if not player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS, true) then
				player:AddCollectible(CollectibleType.COLLECTIBLE_URANUS, 0, false)
				UpdateCostumes(player)
			end
			if not player:HasCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS, true) then
				player:AddCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS, 0, false)
				UpdateCostumes(player)
			end
			--if not player:HasCollectible(CollectibleType.COLLECTIBLE_SOL, true) then
			--	player:AddCollectible(CollectibleType.COLLECTIBLE_SOL, 0, false)
			--	UpdateCostumes(player)
			--end
		--end
		
		
		local VREntityNotTraced = true
		local VRHolding = false
		local roomEntities = Isaac.GetRoomEntities()
				
		--[[
		--if player:HasCollectible(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR, true) then
		if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR
		or player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR
		then
			VREntityNotTraced = false
			VRHolding = true
		end
		
		for i,entity in ipairs(roomEntities) do
			local pickup = entity:ToPickup()
			if pickup ~= nil then
				if pickup.Type == EntityType.ENTITY_PICKUP 
				and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE 
				and pickup.SubType == CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR
				then
					if not VREntityNotTraced then
						entity:Remove()
					end
					VREntityNotTraced = false
				end
			end
		end
		
		if VREntityNotTraced then
			if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_NULL
			-- and not player:HasTrinket(TrinketType.TRINKET_BUTTER)
			then
				player:AddCollectible(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR, 0, false)
				VRHolding = true
			end
		end
		]]
		
		--[[
		if VRHolding then
			if player:GetActiveItem(ActiveSlot.SLOT_POCKET) == CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR
			then
				player:RemoveCollectible(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR, true, ActiveSlot.SLOT_POCKET)
			end
		else
			if player:GetActiveItem(ActiveSlot.SLOT_POCKET) ~= CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR
			then
				player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR, ActiveSlot.SLOT_POCKET, false)
			end
		end
		]]
		
			--[[
			if lastMaxHearts ~= player:GetMaxHearts() then
				print("Max hearts mismatching detected ( from ", lastMaxHearts, " to ", player:GetMaxHearts(), "), cache update queued.")
				UpdateCache(player)
				lastMaxHearts = player:GetMaxHearts()
			end
			]]
			
			-- TestDoDmg(player)
			
		if player:IsDead() then
			--player:Revive()
		end
		
		if room:GetFrameCount() == 1 then
			ApplyEternalHearts(player)
			UpdateCostumes(player)
		else
			
			--[[ --Malfunction
			if  ( player.Velocity.X < 0.05 and player.Velocity.X > -0.05)
			and ( player.Velocity.Y < 0.05 and player.Velocity.Y > -0.05)
			and ( player:GetRecentMovementVector().X < 0.05 and player:GetRecentMovementVector().X > -0.05)
			and ( player:GetRecentMovementVector().Y < 0.05 and player:GetRecentMovementVector().Y > -0.05)
			then
				if player.FireDelay < 0 and not updatedCostumesOvertime then
					UpdateCostumes(player)
					updatedCostumesOvertime = true
				end
			else
				updatedCostumesOvertime = false
			end
			]]
			
			if player:IsHoldingItem()
			then
				onceHoldingItem = true
			elseif onceHoldingItem then
				UpdateCostumes(player)
				onceHoldingItem = false
			end
			
			if lastCanFly ~= player.CanFly then
				UpdateCostumes(player)
				lastCanFly = player.CanFly
			end
			
		end
			
		if room:GetAliveEnemiesCount() <= 0 then
			ApplyEternalHearts(player)
			EternalChargeForFree = true
		else
			ApplyEternalCharge(player)
			EternalChargeForFree = false
		end
		
		--[[
		for i,entity in ipairs(roomEntities) do
			local tear = entity:ToTear()
		end
		]]
		
		RearrangeHearts(player)
		
		-- EnsureFamiliars(player)
		
		
		if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex)
		then
			if WhiteItemSelectPressed[playerID] >= 20 then
				WhiteItemSelectPressed[playerID] = 0
			end
			if WhiteItemSelectPressed[playerID] == 0 then
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
			WhiteItemSelectPressed[playerID] = WhiteItemSelectPressed[playerID] + 1
		else
			WhiteItemSelectPressed[playerID] = 0
		end
		
		--local tracedItems = player:GetCollectibleCount()
		
		--local missingWhiteCollectible = false
		--local missingWhiteTrinket = false
		--local hasWhiteCollectible = false
		--local hasWhiteTrinket = false
		
		local item1 = WhiteItem[playerID][1]
		local item2 = WhiteItem[playerID][2]
		local item3 = WhiteItem[playerID][3]
		
		local item1Missing = item1 == 0
		local item2Missing = item2 == 0
		local item3Missing = item3 == 0
			
		if not player:IsHoldingItem() then
			
			local item1dem = 1
			local item2dem = 1
			local item3dem = 1
			
			
			if item1 == item2 then
				item2dem = item2dem + 1
			end
			if item3 == item1 then
				item3dem = item3dem + 1
			end
			if item3 == item2 then
				item3dem = item3dem + 1
			end
			
			if not item1Missing and player:GetCollectibleNum(item1, true) < item1dem then
				item1Missing = true
				SetWhiteHexanowCollectible(player, 0, 1)
			end
			
			if not item2Missing and  player:GetCollectibleNum(item2, true) < item2dem then
				item2Missing = true
				SetWhiteHexanowCollectible(player, 0, 2)
			end
			
			if not item3Missing and  player:GetCollectibleNum(item3, true) < item3dem then
				item3Missing = true
				SetWhiteHexanowCollectible(player, 0, 3)
			end
			
			--[[
			--if WhiteHexanowTrinketID == 0
			--or not player:HasTrinket(WhiteHexanowTrinketID, true) then
			--	missingWhiteTrinket = true
			--end
			
			--if WhiteHexanowCollectibleID == 0
			--or not player:HasCollectible(WhiteHexanowCollectibleID, true)
			--then
				--missingWhiteCollectible = true
			--end
			
			--if player:HasCollectible(WhiteHexanowCollectibleID, true) then
				--missingWhiteTrinket = false
				--hasWhiteTrinket = true
			--end
			--if player:HasTrinket(WhiteHexanowTrinketID, true) then
			--	missingWhiteCollectible = false
			--	hasWhiteCollectible = true
			--end
			]]
		end
		
		local removedSomething = true
		while removedSomething do
			removedSomething = false
			for ID = CollectibleType.NUM_COLLECTIBLES - 1, 1, -1 do
				
				local item = Isaac.GetItemConfig():GetCollectible(ID)
				local ownNum = player:GetCollectibleNum(ID, true)
				local maxNum = HexanowCollectibleMaxAllowed(player, ID)
				local exceededNum = math.max(0, ownNum - maxNum)
				
				
				--if not HexanowBlackCollectiblePredicate(ID) and exceededNum >= 1 and missingWhiteCollectible then
				--	SetWhiteHexanowCollectible(player, ID)
				--	exceededNum = exceededNum - 1
				--	--print("MISSING WHITE COLLECTIBLE FIX")
				--end
					
				--print("MISSING WHITE COLLECTIBLE FIX")
				
				if not HexanowBlackCollectiblePredicate(ID) then
					if item1Missing and exceededNum >= 1 then
						SetWhiteHexanowCollectible(player, ID, 1)
						exceededNum = exceededNum - 1
					end
					if item2Missing and exceededNum >= 1 then
						SetWhiteHexanowCollectible(player, ID, 2)
						exceededNum = exceededNum - 1
					end
					if item3Missing and exceededNum >= 1 then
						SetWhiteHexanowCollectible(player, ID, 3)
						exceededNum = exceededNum - 1
					end
				end
				
				if exceededNum > 0 then
					removedSomething = true
					for i = 1, exceededNum do
						player:RemoveCollectible(ID, true)
						EternalCharges = EternalCharges + item.Quality * 2 + 1
					end
				end
			end
		end
		
		--player.ItemHoldCooldown = 0
	end
end

-- 自定义命令行
function hexanowMod:ExecuteCmd(cmd, params)
	if cmd == "hudoffset" then
		if tonumber(params) ~= nil
		and tonumber(params) > -1 and tonumber(params) < 11 then
			HUDoffset = tonumber(params)
			Isaac.ConsoleOutput("HUD Offset updated.")
		else
			Isaac.ConsoleOutput("Invalid args")
		end
	end
	if cmd == "echarge" then
		if tonumber(params) ~= nil then
			EternalCharges = tonumber(params)
			Isaac.ConsoleOutput("Eternal charges updated.")
		else
			Isaac.ConsoleOutput("Invalid args")
		end
	end
	if cmd == "sel" then
		if tonumber(params) ~= nil then
			SelectedWhiteItem[1] = tonumber(params)
			Isaac.ConsoleOutput("Sel updated.")
		else
			Isaac.ConsoleOutput("Invalid args")
		end
	end
	if cmd == "hexanow" then
		local pnum = tonumber(params)
		if pnum ~= nil and pnum >= 1 and pnum <= 4 then
			local player = Game():GetPlayer(pnum - 1)
			if player ~= nil then
				while player:GetCollectibleCount() ~= 0 do
					for m = 1, CollectibleType.NUM_COLLECTIBLES - 1 do
						if player:HasCollectible(m, true) then
							player:RemoveCollectible(m, true)
						end
					end
				end	
				player:ChangePlayerType(playerTypeHexanow)
				
				InitPlayerHexanow(player)
			end
		else
			Isaac.ConsoleOutput("Invalid args")
		end
	end
	if cmd == "t2td" then
		local pnum = tonumber(params)
		if pnum == nil then
			Isaac.ConsoleOutput("Invalid args")
		else
			Isaac.ConsoleOutput(Tears2TearDelay(pnum))
		end
	end
	if cmd == "td2t" then
		local pnum = tonumber(params)
		if pnum == nil then
			Isaac.ConsoleOutput("Invalid args")
		else
			Isaac.ConsoleOutput(TearDelay2Tears(pnum))
		end
	end
	if cmd == "reportpos" then
		local roomEntities = Isaac.GetRoomEntities()
				
		for i,entity in ipairs(roomEntities) do
			if entity.Type == EntityType.ENTITY_PICKUP then
				print("Pickup : ", entity.Position.X, ", ", entity.Position.Y)
			elseif entity.Type == EntityType.ENTITY_TEAR then
				print("Tear : ", entity.Position.X, ", ", entity.Position.Y)
			end
		end
	end
	if cmd == "reportpickup" then
		local roomEntities = Isaac.GetRoomEntities()
				
		for i,entity in ipairs(roomEntities) do
			if entity.Type == EntityType.ENTITY_PICKUP then
				local pickup = entity:ToPickup()
				print(entity.Type,".",entity.Variant,".",entity.SubType,"(", pickup.State, ")")
			end
		end
	end
	if cmd == "reportentity" then
		local roomEntities = Isaac.GetRoomEntities()
		
		for i,entity in ipairs(roomEntities) do
			print(tostring(entity.Type).."."..tostring(entity.Variant).."."..tostring(entity.SubType).." "..tostring(entity.Index).." ("..tostring(entity.Position.X)..", "..tostring(entity.Position.Y)..")")
		end
	end
	if cmd == "reportentityne" then
		local roomEntities = Isaac.GetRoomEntities()
				
		for i,entity in ipairs(roomEntities) do
			if entity.Type ~= 1000 then
				print(tostring(entity.Type).."."..tostring(entity.Variant).."."..tostring(entity.SubType).." "..tostring(entity.Index).." ("..tostring(entity.Position.X)..", "..tostring(entity.Position.Y)..")")
			end
		end
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, hexanowMod.ExecuteCmd);

-- 在玩家被加载后运行
function hexanowMod:PostPlayerInit(player)
	UpdateCostumes(player)
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, hexanowMod.PostPlayerInit)

-- 使用传送门工具的效果
function hexanowMod:UsePortalTool(itemId, itemRng, player, useFlags, activeSlot, customVarData)
	local result = {
		Discharge = true,
		Remove = false,
		ShowAnim = false,
	}
	player:UseActiveItem(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR, false, false, true, false)
	
	return result
end
hexanowMod:AddCallback(ModCallbacks.MC_USE_ITEM, hexanowMod.UsePortalTool, hexanowPortalTool)

-- 时间回溯
function hexanowMod:UsePortalTool(itemId, itemRng, player, useFlags, activeSlot, customVarData)
	if itemId == CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS
	--and player:GetPlayerType() == playerTypeHexanow
	then
		RewindLastRoomVar()
		UpdateLastRoomVar()
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_USE_ITEM, hexanowMod.UsePortalTool)

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

-- 在玩家进入新楼层后运行
function hexanowMod:PostNewLevel()
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerTypeHexanow then
				if Game():GetLevel():GetStage() ~= 13 then
					player:UseActiveItem(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR, false, false, true, false)
				end
			end
		end
	)
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, hexanowMod.PostNewLevel)

-- 在玩家进入新房间后运行
function hexanowMod:PostNewRoom()
	TaintedHexanowRoomOverride()
	UpdateLastRoomVar()
	
	if Game():GetRoom():GetAliveEnemiesCount() <= 0 then
		EternalChargeForFree = true
	else
		EternalChargeForFree = false
	end
	
	CallForEveryPlayer(
		function(player)
			UpdateCostumes(player)
			if player:GetPlayerType() == playerTypeHexanow then
				ApplyEternalHearts(player)
				if not Game():GetRoom():IsClear() then
					roomClearBounsEnabled = false
					player:RemoveCollectible(hexanowFlightTriggerItem)
				end
			end
		end
	)
	
	if PlayerTypeExistInGame(playerTypeHexanow) then
		local level = Game():GetLevel()
		level:ApplyBlueMapEffect()
		level:ApplyCompassEffect()
		level:ApplyMapEffect()
		level:ShowMap ()
		
		CallForEveryEntity(
			function(entity)
				if entity.Type == EntityType.ENTITY_EFFECT
				and entity.Variant == EffectVariant.WOMB_TELEPORT
				then
					local portalFound = false
					
					CallForEveryEntity(
						function(entity2)
							if entity2.Type == entityTypeHexanowPortal
							and entity2.Position:Distance(entity.Position) <= 20
							then
								portalFound = true
								return nil
							end
						end
					)
					
					if not portalFound then
						local portalEntity = Isaac.Spawn(entityTypeHexanowPortal, entity.SubType, 0, entity.Position, Vector(0,0), entity)
					end
					
					entity.Visible = false
				end
			end
		)
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, hexanowMod.PostNewRoom)

-- 在房间被清理后运行
function hexanowMod:PreSpawnCleanAward(Rng, SpawnPos)
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerTypeHexanow then
				ApplyEternalHearts(player)
			end
		end
	)
end
hexanowMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, hexanowMod.PreSpawnCleanAward)

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

-- 在玩家受伤时运行
function hexanowMod:EntityTakeDmg(TookDamage, DamageAmount, DamageFlag, DamageSource, DamageCountdownFrames)
	if TookDamage.Type == EntityType.ENTITY_PLAYER then
		local player = TookDamage:ToPlayer()
		local room = Game():GetRoom()
		if player:GetPlayerType() == playerTypeHexanow then
			RearrangeHearts(player)
			local num1,num2=math.modf( math.max(player:GetSoulHearts() - DamageAmount, 0)*0.5 )
			if num2 ~= 0 then
				player:AddBlackHearts(-1)
			end
			--[[
			if room:GetAliveEnemiesCount() <= 0 and room:IsClear() then
				ApplyEternalHearts(player)
			end
			]]
		end
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG , hexanowMod.EntityTakeDmg)

-- 在生物被移除时运行
function hexanowMod:PostEntityRemove(entity)
	if entity.Type == 963 then
		CallForEveryPlayer(
			function(player)
				--ApplyEternalHearts(player)
				--[[
				if player:GetEternalHearts() <= 0 then
					player:AddEternalHearts(1)
				elseif player:GetMaxHearts() > player:GetHearts() then
					player:AddHearts(1)
				end
				]]
			end
		)
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE , hexanowMod.PostEntityRemove)

-- 干涉掉落物生成
function hexanowMod:PostPickupSelection(Pickup, Variant, SubType)
	if PlayerTypeExistInGame(playerTypeHexanow) then
		--[[
		if Variant == PickupVariant.PICKUP_HEART and 
		(
			SubType == HeartSubType.HEART_FULL or
			SubType == HeartSubType.HEART_HALF or
			SubType == HeartSubType.HEART_SOUL or
			SubType == HeartSubType.HEART_HALF_SOUL or
			SubType == HeartSubType.HEART_SCARED or
			SubType == HeartSubType.HEART_BLACK
		)
		then
			return {Variant, HeartSubType.HEART_BLENDED}
		end
		]]
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION , hexanowMod.PostPickupSelection)

-- 改变玩家碰撞行为
function hexanowMod:PrePlayerCollision(player, collider, low)
	if player:GetPlayerType() == playerTypeHexanow then
		if collider.Type == 306 then
			return true
		end
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION , hexanowMod.PrePlayerCollision)

-- 改变眼泪碰撞行为
function hexanowMod:PreTearCollision(tear, collider, low)
	if tear.Parent ~= nil then
		local player = tear.Parent:ToPlayer()
		if player ~= nil
		and player:GetPlayerType() == playerTypeHexanow
		and collider.Type == 963
		then
			return true
		end
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION , hexanowMod.PreTearCollision)

-- 改变掉落物拾取行为
function hexanowMod:PrePickupCollision(pickup, collider, low)
	local player = collider:ToPlayer()
	if player ~= nil
	and player:GetPlayerType() == playerTypeHexanow
	then
		if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
			if pickup.SubType == CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE
			and not pickup:IsShopItem()
			then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE,false,false,true,false, -1)
				--player:RemoveCollectible(WhiteHexanowCollectibleID, true)
				--SetWhiteHexanowCollectible(player, 0)
				pickup:Remove()
				return false
			end
		end
	
		if pickup.Variant == PickupVariant.PICKUP_HEART then
			if pickup.SubType == HeartSubType.HEART_ETERNAL
			and player:GetMaxHearts() >= 24 
			and player:GetHearts() < player:GetMaxHearts()
			and player:GetEternalHearts() >= 1 then
				if pickup:IsShopItem() then
					if player:GetNumCoins() >= pickup.Price then
						player:AddCoins(-pickup.Price)
					else
						return true
					end
				end
				--SFXManager():Play(SoundEffect.SOUND_SUPERHOLY, 1, 0, false, 1 )
				pickup:GetSprite():Play("Collect", true)
				player:AddEternalHearts(2)
				pickup:PlayPickupSound()
				--print("DESTROYING")
				player:AddHearts(player:GetMaxHearts())
				--if pickup:IsShopItem() then
				--	--pickup:Morph(pickup.Type, pickup.Variant, 0, true)
				--	pickup.SubType = 0
				--else
					pickup:Remove()
				--end
				return false
			elseif
				pickup.SubType == HeartSubType.HEART_HALF_SOUL
			or	pickup.SubType == HeartSubType.HEART_SOUL
			or	pickup.SubType == HeartSubType.HEART_BONE
			or	pickup.SubType == HeartSubType.HEART_BLACK
			or	pickup.SubType == HeartSubType.HEART_BLACK
			or	pickup.SubType == HeartSubType.HEART_BLENDED
			then
				
				if pickup:IsShopItem() then
					if player:GetNumCoins() >= pickup.Price then
						player:AddCoins(-pickup.Price)
					else
						return true
					end
				end
				
				local score = 2
				if pickup.SubType == HeartSubType.HEART_HALF_SOUL then
					score = 1
				elseif pickup.SubType == HeartSubType.HEART_BLACK then
					score = 4
				elseif pickup.SubType == HeartSubType.HEART_BLENDED then
					if player:GetMaxHearts() - player:GetHearts() > 1 then
						player:AddHearts(2)
						score = 0
					elseif player:GetMaxHearts() - player:GetHearts() == 1 then
						player:AddHearts(1)
						score = 1
					else
						score = 2
					end
				end
				
				if pickup.SubType == HeartSubType.HEART_BLENDED then
					SFXManager():Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1 )
				else
					pickup:PlayPickupSound()
				end
				EternalCharges = EternalCharges + score
				pickup:GetSprite():Play("Collect", true)
				pickup:Remove()
				return false
			end
		end
		
		if pickup.SubType ~= 0
		and player:CanPickupItem()
		and not player:IsHoldingItem()
		and (pickup:IsShopItem() or player:GetNumCoins() >= pickup.Price) then
			if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
				PickupWhiteHexanowCollectible(player, pickup.SubType)
				return nil
			end
			--if pickup.Variant == PickupVariant.PICKUP_TRINKET then
			--	WhiteHexanowTrinket(pickup.SubType)
			--	return nil
			--end
		end
		
		
		--[[
		if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
			local item = Isaac.GetItemConfig():GetCollectible(pickup.SubType)
			
			if pickup.SubType == 0 or not HexanowWhiteCollectiblePredicate(item, true)
			then				
				if item ~= nil then
					local baseScore = item.Quality * 2
					
					if baseScore > 0 then
						
						if pickup:IsShopItem() then
							if player:GetNumCoins() >= pickup.Price then
								player:AddCoins(-pickup.Price)
							else
								return true
							end
						end
						
						local score = baseScore
					
						local deltaMH = player:GetMaxHearts()
						player:AddMaxHearts(baseScore)
						deltaMH = (player:GetMaxHearts() - deltaMH)/2
						score = score - deltaMH
						
						local deltaH = player:GetHearts()
						player:AddHearts(baseScore * 2 - deltaMH * 2)
						deltaH = (player:GetHearts() - deltaH)/2
						score = score - deltaH
						
						EternalCharges = EternalCharges + math.max(0, math.floor(score))
						SFXManager():Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1 )
						pickup:Remove()
						return false
					else
						if pickup:IsShopItem() then
							return true
						else
							return false
						end
					end
				elseif pickup.SubType == 0 then
					pickup:Remove()
					return false
				end
					
					--pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0, true)
					--pickup.SubType = 0
			end
		end
		]]
		
		--[[
		if pickup.Variant == PickupVariant.PICKUP_PILL
		--or (pickup.Variant == PickupVariant.PICKUP_TRINKET
		--	and pickup.SubType ~= TrinketType.TRINKET_NO
		--	and pickup.SubType ~= TrinketType.TRINKET_NO | 32768
		--	and pickup.SubType ~= TrinketType.TRINKET_PERFECTION
		--	and pickup.SubType ~= TrinketType.TRINKET_PERFECTION | 32768
		--	)
		--or pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY
		or ( pickup.Variant == PickupVariant.PICKUP_TAROTCARD
			and pickup.SubType ~= Card.CARD_CRACKED_KEY
			)
		then
			if pickup:IsShopItem() then
				if player:GetNumCoins() >= pickup.Price then
					player:AddCoins(-pickup.Price)
				else
					return true
				end
			end
			EternalCharges = EternalCharges + 1
			SFXManager():Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1 )
			
			
			pickup:Remove()
			
			return false
		end
		]]
		
		
		return nil
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION , hexanowMod.PrePickupCollision)

-- 后期处理属性缓存
function hexanowMod:EvaluateCache(player, cacheFlag, tear)
	if player:GetPlayerType() == playerTypeHexanow then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			if roomClearBounsEnabled then
				player.MoveSpeed = player.MoveSpeed + 0.15 --  * (1.0 + 0.15 * player:GetMaxHearts() / 24.0)
			else
				player.MoveSpeed = player.MoveSpeed - 0.15
			end
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 3 -- (1.0 + 2.5 * player:GetMaxHearts() / 24.0 - 0.5)
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 3
		elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed - 0.15 -- * (1.0 - 0.3 * player:GetMaxHearts() / 24.0 + 0.15)
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			--player.MaxFireDelay = math.ceil(
			--		(player.MaxFireDelay + (player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) and {2} or {0})[1]
			--		) * 2 -- * (1.0 + 1.5 * player:GetMaxHearts() / 24.0 - 0.5)
			--	)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
				player.MaxFireDelay = ApplyTears2TearDelay(player.MaxFireDelay, -0.34999972571835 -0.6666666666666)
			else
				player.MaxFireDelay = ApplyTears2TearDelay(player.MaxFireDelay, -0.6666666666666)
			end
			--player.MaxFireDelay = player.MaxFireDelay * 2
		elseif cacheFlag == CacheFlag.CACHE_RANGE  then
			player.TearHeight = player.TearHeight * 3 -- (1 + 2.5 * player:GetMaxHearts() / 24.0 - 0.5)
			--player.TearFallingSpeed = player.TearFallingSpeed -- + 5.0 -- * player:GetMaxHearts() / 24.0 
			--player.TearFallingAcceleration = math.min(player.TearFallingAcceleration, - 0.2 / 3)
		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING | TearFlags.TEAR_PERSISTENT | TearFlags.TEAR_SPECTRAL
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			--[[if Game():GetRoom():IsClear() then
				player.CanFly = true
			else
				player.CanFly = false
			end]]
			if roomClearBounsEnabled then
				player.CanFly = true
			end
			 UpdateCostumes(player)
		elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
			--[[
			local maybeFamiliars = Isaac.GetRoomEntities()
			for m = 1, #maybeFamiliars do
				local variant = maybeFamiliars[m].Variant
				if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
					player:TryRemoveNullCostume(hexanowHairCostume)
					player:AddNullCostume(hexanowHairCostume)
				else
					player:TryRemoveNullCostume(hexanowHairCostume)
					player:AddNullCostume(hexanowHairCostume)
				end
			end
			]]
			
			EnsureFamiliars(player)
			UpdateCostumes(player)
		elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = Color(1, 1, 1, 1, 0, 0, 0)
		end
		
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, hexanowMod.EvaluateCache)

-- 在每一帧后执行
function hexanowMod:PostUpdate()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	
	TaintedHexanowRoomOverride()
	
	--[[
	if level:GetStage() == 13 and not EternalChargeSuppressed then
		EternalChargeSuppressed = true
		print("Suppressed!")
	end
	]]
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerTypeHexanow then		
				TickEventHexanow(player)
			end
		end
	)
	
	if PlayerTypeExistInGame(playerTypeHexanow) then
		--if room:GetType() == RoomType.PLANETARIUM then
		--[[
		if room:GetType() == 24 then
			local restockFound = false
			
			CallForEveryEntity(
				function(entity)
					if entity.Type == EntityType.ENTITY_SLOT
					and entity.Variant == 10
					then
						restockFound = true
						return nil
					end
				end
			)
			
			if not restockFound then
				Isaac.Spawn(EntityType.ENTITY_SLOT, 10, 0, Vector(320,200), Vector(0,0), nil)
			end
		end
		]]
		
		CallForEveryEntity(
			function(entity)
				if entity.Type == EntityType.ENTITY_EFFECT
				and entity.Variant == EffectVariant.WOMB_TELEPORT
				then
					local portalFound = false
					local wombPortalFound = false
					local voidPortalFound = false
					
					local posX = math.floor(entity.Position.X/40.0)*40
					local posY = math.floor(entity.Position.Y/40.0)*40
					entity.Position = Vector(posX, posY)
					entity.Velocity = Vector(0, 0)
					
					
					CallForEveryEntity(
						function(entity2)
							if entity2.Index ~= entity.Index
							and entity2.Position:Distance(entity.Position) <= 20
							then
								if entity2.Type == EntityType.ENTITY_EFFECT
								and entity2.Variant == EffectVariant.WOMB_TELEPORT
								then
									wombPortalFound = true
								end
								
								if entity2.Type == entityTypeHexanowPortal
								and (entity2.Variant == 0 or entity2.Variant == 1)
								and entity2.SubType ~= 1
								then
									portalFound = true
								end
								
								--if entity2.Type == 306
								if entity2.Type == entityTypeHexanowPortal
								and entity2.Variant == 2
								and entity2.SubType ~= 1
								then
									voidPortalFound = true
								end
							end
						end
					)
					
					if wombPortalFound then
						if not voidPortalFound then
							Isaac.Spawn(entityTypeHexanowPortal, 2, 0, entity.Position, Vector(0,0), entity)
						end
					else
						if not portalFound then
							Isaac.Spawn(entityTypeHexanowPortal, entity.SubType, 0, entity.Position, Vector(0,0), entity)
						end
					end
						
					
					entity.Visible = false
				end
			end
		)
	end
	
	CallForEveryEntity(
		function(entity)
			if entity.Type == entityTypeHexanowPortal then
				local posX = math.floor(entity.Position.X/40.0)*40
				local posY = math.floor(entity.Position.Y/40.0)*40
				entity.Position = Vector(posX, posY)
				entity.Velocity = Vector(0, 0)
				
				if entity.Variant ~= 0
				and entity.Variant ~= 1
				and entity.Variant ~= 2
				then
					--entity.Variant = 2
					entity:Remove()
				end
				
				local sprite = entity:GetSprite()

				if entity.FrameCount == 1 then
				end
				
				local wombTeleportFound = 0
				
				if PlayerTypeExistInGame(playerTypeHexanow) then
					CallForEveryEntity(
						function(entity2)
							if entity2.Type == EntityType.ENTITY_EFFECT
							and entity2.Variant == EffectVariant.WOMB_TELEPORT
							and entity2.Position:Distance(entity.Position) <= 20
							then
								wombTeleportFound = wombTeleportFound + 1
							end
						end
					)
				end
				
				if wombTeleportFound ~= 1 and entity.Variant ~= 2 then
					entity.SubType = 1
				end
				if wombTeleportFound < 2 and entity.Variant == 2 then
					entity.SubType = 1
				end
				
				if entity.Variant == 2 then
					if entity.FrameCount%6 == 0 then
						sprite:ReplaceSpritesheet(0,"gfx/effects/HexanowPortalBlue.png")
						sprite:ReplaceSpritesheet(1,"gfx/effects/HexanowPortalBlue.png")
						sprite:ReplaceSpritesheet(2,"gfx/effects/HexanowPortalBlue.png")
						sprite:ReplaceSpritesheet(3,"gfx/effects/HexanowPortalBlue.png")
						sprite:ReplaceSpritesheet(4,"gfx/effects/HexanowPortalOrange.png")
						sprite:ReplaceSpritesheet(5,"gfx/effects/HexanowPortalOrange.png")
						sprite:ReplaceSpritesheet(6,"gfx/effects/HexanowPortalOrange.png")
						sprite:LoadGraphics()
					elseif entity.FrameCount%6 == 3 then
						sprite:ReplaceSpritesheet(0,"gfx/effects/HexanowPortalOrange.png")
						sprite:ReplaceSpritesheet(1,"gfx/effects/HexanowPortalOrange.png")
						sprite:ReplaceSpritesheet(2,"gfx/effects/HexanowPortalOrange.png")
						sprite:ReplaceSpritesheet(3,"gfx/effects/HexanowPortalOrange.png")
						sprite:ReplaceSpritesheet(4,"gfx/effects/HexanowPortalBlue.png")
						sprite:ReplaceSpritesheet(5,"gfx/effects/HexanowPortalBlue.png")
						sprite:ReplaceSpritesheet(6,"gfx/effects/HexanowPortalBlue.png")
						sprite:LoadGraphics()
					end
				end
				
				if entity.SubType == 1 then
					if portalBlue == entity then
						portalBlue = nil
					end
					if portalOrange == entity then
						portalOrange = nil
					end
					if not sprite:IsPlaying("Death") and not sprite:IsFinished("Death") then
						sprite:Play("Death", true)
					elseif sprite:IsFinished("Death") and sprite:GetFrame() > 0 then
						entity:Remove()
					end
				else
					if sprite:IsFinished("Appear") and sprite:GetFrame() > 0 then
						sprite:Play("Idle", false)
					end
					
					if entity.FrameCount > 20 then
						if entity.Variant == 0 then
							--entity:SetColor(Color(9,132,255,1, 0, 0, 0), 0, 999, false, false)
							portalBlue = entity
						elseif entity.Variant == 1 then
							--entity:SetColor(Color(234,135,0,1, 0, 0, 0), 0, 999, false, false)
							portalOrange = entity
						end
					end
				
						--entity.SubType = 1
					--if entity.FrameCount%10 == 0 then
					--	SFXManager():Play(tempt, 3, 0, false, 1 )
					--	print("Playing",tempt)
					--	tempt = tempt + 1
					--end
				end
				
			end
		end
	)
	if portalBlue ~= nil and not portalBlue:Exists() then
		portalBlue = nil
	end
	if portalOrange ~= nil and not portalOrange:Exists() then
		portalOrange = nil
	end
	
	if portalBlue ~= nil and portalOrange ~= nil then
		CallForEveryEntity(
			function(entity)
				if entity.Type == EntityType.ENTITY_TEAR
				or entity.Type == EntityType.ENTITY_BOMBDROP
				--or entity.Type == EntityType.ENTITY_KNIFE
				or entity.Type == EntityType.ENTITY_PROJECTILE  
				then
					if entity.Parent ~= nil and entity.Parent.Type == EntityType.ENTITY_PLAYER then
						local closeToBlue = false
						local closeToOrange = false
						
						local traced = false
						for k,v in ipairs(teledProjectiles) do
							if v == entity.Index then
								traced = true
								break
							end
						end
						
						if not traced then
							if entity.Position:Distance(portalBlue.Position) <= 28.284271247461900976033774484194 then
								closeToBlue = true
							end
							if entity.Position:Distance(portalOrange.Position) <= 28.284271247461900976033774484194 then
								closeToOrange = true
							end
							
							if closeToBlue and not closeToOrange then
								entity.Position = portalOrange.Position -- portalBlue.Position - entity.Position + portalOrange.Position
								SFXManager():Play(SoundEffect.SOUND_TEARIMPACTS, 1, 0, false, 1 )
								table.insert(teledProjectiles, entity.Index)
							elseif closeToOrange and not closeToBlue then
								entity.Position = portalBlue.Position -- portalOrange.Position - entity.Position + portalBlue.Position
								SFXManager():Play(SoundEffect.SOUND_TEARIMPACTS, 1, 0, false, 1 )
								table.insert(teledProjectiles, entity.Index)
							end
						else
							if entity.Position:Distance(portalBlue.Position) <= 40 then
								closeToBlue = true
							end
							if entity.Position:Distance(portalOrange.Position) <= 40 then
								closeToOrange = true
							end
							if not closeToBlue and not closeToOrange then
								for k,v in ipairs(teledProjectiles) do
									if v == entity.Index then
										table.remove(teledProjectiles, k)
										break
									end
								end
							end
						end
					end
				end
			end
		)
	else
		teledProjectiles = {}
	end
	--[[
	local hexanowExist = PlayerTypeExistInGame(playerTypeHexanow)
	
	for i,entity in ipairs(fireworksToWipe) do
		if entity ~= nil then
			entity:Remove()
		end
	end
	fireworksToWipe = {}
	
	local roomEntities = Isaac.GetRoomEntities()
	for i,entity in ipairs(roomEntities) do
		
		if hexanowExist then
			local npc = entity:ToNPC()
			if npc ~= nil then
				local fireworkEntity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FIREWORKS, 5, entity.Position, entity.Velocity, entity)
				
				local r,g,b,h
				h = rainbowFireworkRng:RandomInt(359)
				
				if     h < 60 then
					r = 1
					g = (h - 0) / 30.0
					b = 0
				elseif h < 120 then
					r = 1 - (h - 60) / 30.0
					g = 1
					b = 0
				elseif h < 180 then
					r = 0
					g = 1
					b = (h - 120) / 30.0
				elseif h < 240 then
					r = 0
					g = 1 - (h - 180) / 30.0
					b = 1
				elseif h < 270 then
					r = (h - 240) / 30.0
					g = 0
					b = 1
				elseif h < 360 then
					r = 1
					g = 0
					b = 1 - (h - 270) / 30.0
				end
				
				fireworkEntity.Visible = false
				fireworkEntity:SetColor(Color(r,g,b,
					1, 0, 0, 0), 0, 999, false, false)
				table.insert(
					fireworksToWipe,
					fireworkEntity
					)
			end
		end
		
		local tear = entity:ToTear()
		if tear ~= nil then
			if      tear.Parent.Type == EntityType.ENTITY_PLAYER then
				local player = tear.Parent:ToPlayer()
				if player:GetPlayerType() == playerTypeHexanow
				then
					-- tear.Height = tear.Height + tear.FallingSpeed * 2 / 3
					-- local roomEntities = Isaac.GetRoomEntities()
					-- print("HomingFriction: ", tear.HomingFriction)
					
					if tear.Variant ~= TearVariant.BLUE then
						local tearSprite = tear:GetSprite()
						tear:ChangeVariant(TearVariant.BLUE)
						
						tearSprite:ReplaceSpritesheet(0,"gfx/Hexanow_tears.png")
						tearSprite:LoadGraphics("gfx/Hexanow_tears.png")
						tearSprite.Rotation = tear.Velocity:GetAngleDegrees()
					end
					
					
					for i,entity in ipairs(roomEntities) do
						local pickup = entity:ToPickup()
						if pickup ~= nil then
							if pickup.Type == EntityType.ENTITY_PICKUP 
							and pickup.Variant == PickupVariant.PICKUP_HEART
							and pickup.SubType ~= HeartSubType.HEART_BLENDED
							and (
								pickup.SubType == HeartSubType.HEART_FULL or
								pickup.SubType == HeartSubType.HEART_HALF or
								pickup.SubType == HeartSubType.HEART_SOUL or
								pickup.SubType == HeartSubType.HEART_HALF_SOUL or
								pickup.SubType == HeartSubType.HEART_SCARED or
								pickup.SubType == HeartSubType.HEART_BLACK or
								(pickup.SubType == HeartSubType.HEART_ETERNAL and player:GetMaxHearts() >= 24 and player:GetEternalHearts() >= 1) or
								(pickup.SubType == HeartSubType.HEART_BONE and player:GetMaxHearts() >= 24) or
								pickup.SubType == HeartSubType.HEART_DOUBLEPACK
							)
							then
								if tear.Position:Distance(pickup.Position) < 20
								then
									if pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
										Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED, pickup.Position, Vector(0.005, 0.005), player)
										pickup:AddVelocity(Vector(-0.005, -0.005))
									end
									pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED, true)
								end
							end
						end
					end
			
				end
			elseif  tear.Parent.Type == EntityType.ENTITY_FAMILIAR
				and tear.Parent.Variant == entityVariantHeartsBlender
				then
				local fam = tear.Parent:ToFamiliar()
				-- SOME THING TO DO
			end
		end
	end
	]]
	--[[
	CallForEveryEntity(
		function(entity)
			local tear = entity:ToTear()
			if tear ~= nil then
				if tear.Parent ~= nil
				and tear.Parent.Type == EntityType.ENTITY_PLAYER then
					local player = tear.Parent:ToPlayer()
					if player:GetPlayerType() == playerTypeHexanow
					then
						--tear.Visible = false
						--Isaac.Spawn(1000, 59, 0, tear.Position, Vector(0, 0), player)
					end
				end
			end
		end
	)
	]]
	--SaveHexanowModData()
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_UPDATE, hexanowMod.PostUpdate)

-- 渲染器，每一帧执行
function hexanowMod:PostRender()
	local baseOffset = Vector(3,71)
	local offsetModSel = Vector(2 * HUDoffset, 1.2 * HUDoffset)
	local offsetModStat = Vector(2 * HUDoffset, 1.2 * HUDoffset)
	
	if PlayerTypeExistInGame(playerTypeHexanow) then
		
		local bet1 = PlayerTypeExistInGame(PlayerType.PLAYER_BETHANY)
		local bet2 = PlayerTypeExistInGame(36)
		if bet1 and bet2 then
			offsetModStat = offsetModStat + Vector(0, 19)
		elseif bet1 or bet2 then
			offsetModStat = offsetModStat + Vector(0, 8)
		end
		
		if PlayerTypeExistInGame(Isaac.GetPlayerTypeByName("Lairub")) then
			offsetModSel = offsetModStat + Vector(0, 35)
		end
		
		if EternalChargeForFree then
			EternalChargeSprite:SetFrame("Gold", 0)
		else
			EternalChargeSprite:SetFrame("Base", 0)
		end
		--EternalChargeSprite:SetOverlayRenderPriority(true)
		EternalChargeSprite:Render(baseOffset + offsetModStat, Vector(0,0), Vector(0,0))
		DrawSimNumbers(EternalCharges, baseOffset + Vector(12, 1) + offsetModStat)
		
		local sortNum = 0
		CallForEveryPlayer(
			function(player)
				if player:GetPlayerType() == playerTypeHexanow then
					SelManageRander(baseOffset + Vector(42, -36) + offsetModSel, GetPlayerID(player), sortNum)
					sortNum = sortNum + 1
				end
			end
		)
		
		--Isaac.RenderScaledText("00", 35, 85, 1, 1, 255, 255, 255, 255)--tostring(00)
		--DrawSimNumberSingle(7, Vector(35, 84), true)
		--DrawSimNumberSingle("s", Vector(35+6, 84), true)
		--DrawSimNumberSingle(7, Vector(35, 84), false)
		--DrawSimNumberSingle("s", Vector(35+6, 84), false)
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_RENDER, hexanowMod.PostRender)

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
		
		nums = reverseTable(nums)
	end
	
	
	DrawSimNumberSeries(nums, pos, true)
	DrawSimNumberSeries(nums, pos, false)
end

function reverseTable(tab)
	local tmp = {}
	for i = 1, #tab do
		local key = #tab
		tmp[i] = table.remove(tab)
	end

	return tmp
end

-- 渲染数字组
function DrawSimNumberSeries(nums, pos, bg)
	local posp = 0
	for i,num in ipairs(nums) do
		posp = posp + DrawSimNumberSingle(num, pos + Vector(posp, 0), bg)
	end
end

-- 渲染单个数字
function DrawSimNumberSingle(num, pos, bg)
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

-- 渲染物品选单
function SelManageRander(pos, playerID, sortNum)
	-- local playerID = 1
	local FrameAnm = "Frame"
	if sortNum >= 1 then
		FrameAnm = "Frame2"
	end
	pos = pos + Vector(sortNum*35/2, 0)
	
	local frame1 = Sprite()
	local frame2 = Sprite()
	local frame3 = Sprite()
	local frame4 = Sprite()
	local arraw = Sprite()
	local item1 = Sprite()
	local item2 = Sprite()
	local item3 = Sprite()
	
	frame1:Load("gfx/ui/HexanowInventory.anm2", true)
	frame2:Load("gfx/ui/HexanowInventory.anm2", true)
	frame3:Load("gfx/ui/HexanowInventory.anm2", true)
	frame4:Load("gfx/ui/HexanowInventory.anm2", true)
	arraw:Load("gfx/ui/HexanowInventory.anm2", true)
	item1:Load("gfx/ui/HexanowInventoryItem.anm2", true)
	item2:Load("gfx/ui/HexanowInventoryItem.anm2", true)
	item3:Load("gfx/ui/HexanowInventoryItem.anm2", true)
	
	if WhiteItem[playerID][1] ~= nil then
	local item = Isaac.GetItemConfig():GetCollectible(WhiteItem[playerID][1])
		if item ~= nil then
			item1:ReplaceSpritesheet(0,item.GfxFileName)
			item1:LoadGraphics()
		end
	end
	if WhiteItem[playerID][2] ~= nil then
	local item = Isaac.GetItemConfig():GetCollectible(WhiteItem[playerID][2])
		if item ~= nil then
			item2:ReplaceSpritesheet(0,item.GfxFileName)
			item2:LoadGraphics()
		end
	end
	if WhiteItem[playerID][3] ~= nil then
	local item = Isaac.GetItemConfig():GetCollectible(WhiteItem[playerID][3])
		if item ~= nil then
			item3:ReplaceSpritesheet(0,item.GfxFileName)
			item3:LoadGraphics()
		end
	end
	
	--item3:ReplaceSpritesheet(0,"gfx/items/collectibles/".."Collectibles_118_Brimstone.png")
	
	frame1:SetFrame(FrameAnm, 0)
	frame2:SetFrame(FrameAnm, 1)
	frame3:SetFrame(FrameAnm, 1)
	frame4:SetFrame(FrameAnm, 2)
	item1:SetFrame("Base", 0)
	item2:SetFrame("Base", 0)
	item3:SetFrame("Base", 0)
	
	if SelectedWhiteItem[playerID] == 1 then
		arraw:SetFrame("Select", 0)
	elseif SelectedWhiteItem[playerID] == 2 then
		arraw:SetFrame("Select", 1)
	elseif SelectedWhiteItem[playerID] == 3 then
		arraw:SetFrame("Select", 2)
	else
		arraw:SetFrame("Select", 3)
	end
	
	frame1:Render(pos + Vector(0,0/2), Vector(0,0), Vector(0,0))
	frame2:Render(pos + Vector(0,35/2), Vector(0,0), Vector(0,0))
	frame3:Render(pos + Vector(0,70/2), Vector(0,0), Vector(0,0))
	frame4:Render(pos + Vector(0,105/2), Vector(0,0), Vector(0,0))
	
	item1:Render(pos + Vector(0,0/2), Vector(0,0), Vector(0,0))
	item2:Render(pos + Vector(0,35/2), Vector(0,0), Vector(0,0))
	item3:Render(pos + Vector(0,70/2), Vector(0,0), Vector(0,0))
	
	arraw:Render(pos + Vector(0,0/2), Vector(0,0), Vector(0,0))
	
end

-- 初始化随从
local function FamiliarInit(_, fam)
	print("Initiating Hearts Blender")
end
hexanowMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, FamiliarInit, entityVariantHeartsBlender)

-- 更新随从行为
local function FamiliarUpdate(_, fam)
	local roomEntities = Isaac.GetRoomEntities()
	
	local targetPos = nil
	local dis = nil
	
    local parent = fam.Player
	--[[if parent:ToPlayer() ~= nil then
		parent = fam.Parent:ToPlayer()
	end]]
	
	--[[
	for i,entity in ipairs(roomEntities) do
		local pickup = entity:ToPickup()
		if pickup ~= nil then
			if pickup.Type == EntityType.ENTITY_PICKUP 
			and (pickup.Variant == PickupVariant.PICKUP_HEART and (
				-- HeartSubType.HEART_BLENDED or
				pickup.SubType == HeartSubType.HEART_FULL or
				pickup.SubType == HeartSubType.HEART_HALF or
				pickup.SubType == HeartSubType.HEART_SOUL or
				pickup.SubType == HeartSubType.HEART_HALF_SOUL or
				pickup.SubType == HeartSubType.HEART_SCARED or
				pickup.SubType == HeartSubType.HEART_BLACK or
				-- (pickup.SubType == HeartSubType.HEART_ETERNAL and parent:GetMaxHearts() >= 24 and parent:GetEternalHearts() >= 1) or
				-- (pickup.SubType == HeartSubType.HEART_BONE and parent:GetMaxHearts() >= 24) or
				false
			))
			then
				if targetPos == nil
				or fam.Position:Distance(pickup.Position) < dis or dis ~= nil
				then
					if fam.Position:Distance(pickup.Position) < 10 -- and not pickup.IsShopItem () and parent.Position:Distance(pickup.Position) > 100
					then
						pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED, true)
						-- pickup.Position = parent.Position
					else
						targetPos = pickup.Position
						dis = fam.Position:Distance(pickup.Position)
					end
				end
			end
		end
	end
	]]
	
	if targetPos ~= nil then
		--  targetPos = parent.Position
		fam:FollowPosition(targetPos)
		-- fam.Position = targetPos
	else
		fam:FollowParent()
	end

    if fam.FrameCount%300 == 0 then
    end
end
hexanowMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, FamiliarUpdate, entityVariantHeartsBlender)

-- 更新眼泪行为，在每一帧后执行
function hexanowMod:PostTearUpdate(tear)
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE , hexanowMod.PostTearUpdate)