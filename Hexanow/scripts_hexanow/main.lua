

HexanowMod.Main = {}

local playerTypeHexanow = Isaac.GetPlayerTypeByName("Hexanow")
local playerTypeHexanowTainted = Isaac.GetPlayerTypeByName("Tainted Hexanow", true)

local function IsHexanow(player)
	return player:GetPlayerType() == playerTypeHexanow
end

local function IsHexanowTainted(player)
	return player:GetPlayerType() == playerTypeHexanowTainted
end

--[[
local baseEntityPlayerGetHeartsLimit = APIOverride.GetCurrentClassFunction(EntityPlayer, "GetHeartLimit")
APIOverride.OverrideClassFunction(EntityPlayer, "GetHeartLimit", function(interval)
	if IsHexanow(interval) then
		return 36
	end
	return baseEntityPlayerGetHeartsLimit(interval)
end)
]]--
--[[
local baseEntityPlayerHasCollectible = APIOverride.GetCurrentClassFunction(EntityPlayer, "HasCollectible")
APIOverride.OverrideClassFunction(EntityPlayer, "HasCollectible", function(interval, Type, IgnoreModifiers)
    local result = baseEntityPlayerHasCollectible(interval, Type, IgnoreModifiers)
	if IsHexanow(interval)
	and (  Type == CollectibleType.COLLECTIBLE_ANALOG_STICK
		or Type == CollectibleType.COLLECTIBLE_URANUS
		or Type == CollectibleType.COLLECTIBLE_NEPTUNUS
	) then
		result = true
	end
	return result
end)
local baseEntityPlayerQueueItem = APIOverride.GetCurrentClassFunction(EntityPlayer, "QueueItem")
APIOverride.OverrideClassFunction(EntityPlayer, "QueueItem", function(interval, Item, Charge, Touched, Golden, VarData)
    local result = baseEntityPlayerQueueItem(interval, Item, Charge, Touched, Golden, VarData)
	if IsHexanow(interval) then
		print("QUEUE!")
	end
	return result
end)
]]--

--require("hexanowObjectives")
--require("hexanowFlags")

--Isaac.ConsoleOutput("Init mod hexanow\n")

------------------------------------------------------------
---------- 变量初始化
----------

--local hexanowItem = Isaac.GetItemIdByName( "Hexanow's Soul" )
local redMap = Isaac.GetItemIdByName("Red Map")
local hexanowPortalTool = Isaac.GetItemIdByName("Eternal Portal")
local hexanowStatTriggerItem = Isaac.GetItemIdByName( "Hexanow overall stat trigger" )
local hexanowHairCostume = Isaac.GetCostumeIdByPath("gfx/characters/HexanowHair.anm2")
local hexanowBodyCostume = Isaac.GetCostumeIdByPath("gfx/characters/HexanowBody.anm2")
local hexanowBodyFlightCostume = Isaac.GetCostumeIdByPath("gfx/characters/HexanowFlight.anm2")

--local entityVariantHeartsBlender = Isaac.GetEntityVariantByName("Hearts Blender")
local entityVariantHexanowLaser = Isaac.GetEntityVariantByName("Laser (Hexanow)")
local entityVariantHexanowPortalDoor = Isaac.GetEntityVariantByName("Hexanow Portal Door")
--local entityTypeHexanowPortal = Isaac.GetEntityTypeByName("Hexanow Blue Portal")

local portalColor = {}
portalColor[1] = {}
portalColor[1][1] = Color(9 / 255, 132 / 255, 255 / 255)
portalColor[1][2] = Color(234 / 255, 135 / 255, 0 / 255)
portalColor[2] = {}
portalColor[2][1] = Color(0 / 255, 0 / 255, 255 / 255)
portalColor[2][2] = Color(255 / 255, 255 / 255, 0 / 255)
portalColor[3] = {}
portalColor[3][1] = Color(0 / 255, 255 / 255, 255 / 255)
portalColor[3][2] = Color(255 / 255, 0 / 255, 255 / 255)
portalColor[4] = {}
portalColor[4][1] = Color(255 / 255, 0 / 255, 0 / 255)
portalColor[4][2] = Color(0 / 255, 255 / 255, 0 / 255)

local levelPosition = { RoomInLevelListIndex = -1, InRoomGridIndex = -1 }
levelPosition.__index = levelPosition
local function LevelPosition(RoomInLevelListIndex, InRoomGridIndex)
	local cted = {}
	setmetatable(cted, levelPosition)
	cted.RoomInLevelListIndex = RoomInLevelListIndex
	cted.InRoomGridIndex = InRoomGridIndex
	return cted
end

local SuperPower = false

local EternalChargeForFree = true
local roomClearBounsEnabled = false

local EternalCharges = 0

local queuedNextRoomGrid = nil

local EternalChargeSprite = Sprite()
EternalChargeSprite:Load("gfx/ui/EternalCharge.anm2", true)

Explorite.RegistSideBar("EternalCharge", function()
	if not PlayerTypeExistInGame(playerTypeHexanow) then return nil end
	if EternalChargeForFree then
		EternalChargeSprite:SetFrame("Gold", 0)
	else
		EternalChargeSprite:SetFrame("Base", 0)
	end
	return EternalChargeSprite, Parse00(EternalCharges)
end)

local hexanowPlayerData = {
}
hexanowPlayerData.__index = hexanowPlayerData

function hexanowPlayerData:UpdateLastRoomVar()
	self.lastRoom = {}
	self.lastRoom.WhiteItem = {}
	self.lastRoom.CreatedPortals = {}
	for slot=1, 3 do
		self.lastRoom.WhiteItem[slot] = self.WhiteItem[slot]
	end
	self.lastRoom.SelectedWhiteItem = self.SelectedWhiteItem
	self.lastRoom.portalToolColor = self.portalToolColor
    for dim=0, 2 do
		self.lastRoom.CreatedPortals[dim] = {}
		for type=1, 2 do
			self.lastRoom.CreatedPortals[dim][type] = self.CreatedPortals[dim][type]
		end
	end
end
function hexanowPlayerData:RewindLastRoomVar()
	for slot=1, 3 do
		self.WhiteItem[slot] = self.lastRoom.WhiteItem[slot]
	end
	self.SelectedWhiteItem = self.lastRoom.SelectedWhiteItem
	self.portalToolColor = self.lastRoom.portalToolColor
    for dim=0, 2 do
		for type=1, 2 do
			self.CreatedPortals[dim][type] = self.lastRoom.CreatedPortals[dim][type]
		end
	end
	self:UpdateLastRoomVar()
end
function hexanowPlayerData:GenSpriteCaches()
	self.sprites = {}
	self.sprites.frame0 = Sprite()
	self.sprites.frame1 = Sprite()
	self.sprites.frame2 = Sprite()
	self.sprites.frame3 = Sprite()
	self.sprites.frame4 = Sprite()
	self.sprites.arraw = Sprite()
	self.sprites.item1 = Sprite()
	self.sprites.item2 = Sprite()
	self.sprites.item3 = Sprite()
	self.sprites.portalBase1 = Sprite()
	self.sprites.portalBase2 = Sprite()
	self.sprites.portalCreated1 = Sprite()
	self.sprites.portalCreated2 = Sprite()
	self.sprites.portalSelected = Sprite()
	self.sprites.frame0:Load("gfx/ui/HexanowInventory.anm2", true)
	self.sprites.frame1:Load("gfx/ui/HexanowInventory.anm2", true)
	self.sprites.frame2:Load("gfx/ui/HexanowInventory.anm2", true)
	self.sprites.frame3:Load("gfx/ui/HexanowInventory.anm2", true)
	self.sprites.frame4:Load("gfx/ui/HexanowInventory.anm2", true)
	self.sprites.arraw:Load("gfx/ui/HexanowInventory.anm2", true)
	self.sprites.item1:Load("gfx/ui/HexanowInventoryItem.anm2", true)
	self.sprites.item2:Load("gfx/ui/HexanowInventoryItem.anm2", true)
	self.sprites.item3:Load("gfx/ui/HexanowInventoryItem.anm2", true)
	self.sprites.portalBase1:Load("gfx/ui/HexanowInventory.anm2", true)
	self.sprites.portalBase2:Load("gfx/ui/HexanowInventory.anm2", true)
	self.sprites.portalCreated1:Load("gfx/ui/HexanowInventory.anm2", true)
	self.sprites.portalCreated2:Load("gfx/ui/HexanowInventory.anm2", true)
	self.sprites.portalSelected:Load("gfx/ui/HexanowInventory.anm2", true)
	self.sprites.arraw:SetFrame("Select", 0)
	self.sprites.item1:SetFrame("Base", 0)
	self.sprites.item2:SetFrame("Base", 0)
	self.sprites.item3:SetFrame("Base", 0)
	self.sprites.portalBase1:SetFrame("PortalBase", 0)
	self.sprites.portalBase2:SetFrame("PortalBase", 1)
	self.sprites.portalCreated1:SetFrame("PortalCreated", 0)
	self.sprites.portalCreated2:SetFrame("PortalCreated", 1)
end

local function HexanowPlayerData()
	local cted = {}
	setmetatable(cted, hexanowPlayerData)
	cted.WhiteItem = {}
	cted.WhiteItem[1] = 0
	cted.WhiteItem[2] = 0
	cted.WhiteItem[3] = 0
	cted.SelectedWhiteItem = 1
	cted.portalToolColor = 2
	cted.CreatedPortals = {}
	cted.CreatedPortals[0] = {}
	cted.CreatedPortals[0][1] = nil
	cted.CreatedPortals[0][2] = nil
	cted.CreatedPortals[1] = {}
	cted.CreatedPortals[1][1] = nil
	cted.CreatedPortals[1][2] = nil
	cted.CreatedPortals[2] = {}
	cted.CreatedPortals[2][1] = nil
	cted.CreatedPortals[2][2] = nil

	cted:UpdateLastRoomVar()
	
	cted.InRoomCreatedPortals = {}
	cted.InRoomCreatedPortals[1] = nil
	cted.InRoomCreatedPortals[2] = nil
	cted.onceHoldingItem = false
	cted.lastCanFly = nil
	cted.WhiteItemSelectPressed = 0

	cted:GenSpriteCaches()
	return cted
end

local HexanowPlayerDatas = {}
HexanowPlayerDatas[1] = HexanowPlayerData()
HexanowPlayerDatas[2] = HexanowPlayerData()
HexanowPlayerDatas[3] = HexanowPlayerData()
HexanowPlayerDatas[4] = HexanowPlayerData()

local LastRoom = {}

------------------------------------------------------------
---------- 变量处理
----------

function HexanowMod.Main.UpdateLastRoomVar()
	LastRoom = {}
	LastRoom.EternalCharges = EternalCharges
	for playerID=1,4 do
		HexanowPlayerDatas[playerID]:UpdateLastRoomVar()
	end
end

function HexanowMod.Main.RewindLastRoomVar()
	EternalCharges = LastRoom.EternalCharges
	for playerID=1,4 do
		HexanowPlayerDatas[playerID]:RewindLastRoomVar()
	end
end

-- 抹除临时变量
function HexanowMod.Main.WipeTempVar()
	EternalCharges = 0
	EternalChargesLastRoom = 0
	roomClearBounsEnabled = false
	EternalChargeForFree = true
	SuperPower = false
	queuedNextRoomGrid = nil

	HexanowPlayerDatas = {}
	HexanowPlayerDatas[1] = HexanowPlayerData()
	HexanowPlayerDatas[2] = HexanowPlayerData()
	HexanowPlayerDatas[3] = HexanowPlayerData()
	HexanowPlayerDatas[4] = HexanowPlayerData()
end

function HexanowMod.Main.ApplyVar(objective)
	EternalCharges = tonumber(objective:Read("EternalCharges", "0"))
	for playerID=1,4 do
		HexanowPlayerDatas[playerID].SelectedWhiteItem = tonumber(objective:Read("Player"..playerID.."-SelectedWhiteItem", "1"))
		for i=1,3 do
			HexanowPlayerDatas[playerID].WhiteItem[i] = tonumber(objective:Read("Player"..playerID.."-WhiteItem-"..i, "0"))
		end
		HexanowPlayerDatas[playerID].portalToolColor = tonumber(objective:Read("Player"..playerID.."-portalToolColor", "2"))
		if HexanowPlayerDatas[playerID].portalToolColor ~= 1 and HexanowPlayerDatas[playerID].portalToolColor ~= 2 then
			HexanowPlayerDatas[playerID].portalToolColor = 2
		end
		for dim=0,2 do
			for type=1,2 do
				local RoomInLevelListIndex = tonumber(objective:Read("Player"..playerID.."-CreatedPortal-"..dim.."-"..type.."-RoomInLevelListIndex", "-1"))
				local InRoomGridIndex = tonumber(objective:Read("Player"..playerID.."-CreatedPortal-"..dim.."-"..type.."-InRoomGridIndex", "-1"))
				if RoomInLevelListIndex ~= nil and RoomInLevelListIndex1 ~= -1 and InRoomGridIndex ~= nil and InRoomGridIndex ~= -1 then
					HexanowPlayerDatas[playerID].CreatedPortals[dim][type] = LevelPosition(RoomInLevelListIndex, InRoomGridIndex)
				end
			end
		end
	end
end

function HexanowMod.Main.RecieveVar(objective)
	objective:Write("Flags", HexanowFlags:ToString())
	objective:Write("EternalCharges", tostring(EternalCharges))
	for playerID=1,4 do
		objective:Write("Player"..playerID.."-SelectedWhiteItem", tostring(HexanowPlayerDatas[playerID].SelectedWhiteItem))
		for i=1,3 do
			objective:Write("Player"..playerID.."-WhiteItem-"..i, tostring(HexanowPlayerDatas[playerID].WhiteItem[i]))
		end
		objective:Write("Player"..playerID.."-portalToolColor", tostring(HexanowPlayerDatas[playerID].portalToolColor))
		for dim=0,2 do
			for type=1,2 do
				local portalInfoLID = -1
				local portalInfoRID = -1
				if HexanowPlayerDatas[playerID].CreatedPortals[dim][type] ~= nil then
					portalInfoLID = HexanowPlayerDatas[playerID].CreatedPortals[dim][type].RoomInLevelListIndex
					portalInfoRID = HexanowPlayerDatas[playerID].CreatedPortals[dim][type].InRoomGridIndex
				end
				objective:Write("Player"..playerID.."-CreatedPortal-"..dim.."-"..type.."-RoomInLevelListIndex", tostring(portalInfoLID))
				objective:Write("Player"..playerID.."-CreatedPortal-"..dim.."-"..type.."-InRoomGridIndex", tostring(portalInfoRID))
			end
		end
	end
end

------------------------------------------------------------
---------- 游戏功能
----------

local function GetHexanowPortalColor(player, num)
	return portalColor[GetPlayerSameTryeID(player)][num]
end

-- 更新玩家外观，按需执行
local function UpdateCostumes(player)
	if IsHexanow(player) then
		player:ClearCostumes()
		player:RemoveSkinCostume()

		--player:TryRemoveCollectibleCostume(CollectibleType.COLLECTIBLE_ANALOG_STICK, false)
		--player:TryRemoveCollectibleCostume(CollectibleType.COLLECTIBLE_URANUS, false)
		--player:TryRemoveCollectibleCostume(CollectibleType.COLLECTIBLE_NEPTUNUS, false)
		--player:TryRemoveNullCostume(hexanowHairCostume)
		--player:TryRemoveNullCostume(hexanowBodyFlightCostume)
		--player:TryRemoveNullCostume(hexanowBodyCostume)

		player:AddNullCostume(hexanowHairCostume)
		player:AddNullCostume(hexanowBodyFlightCostume)
		player:AddNullCostume(hexanowBodyCostume)

		local color = player:GetColor()
		if color.R < 1.0
		or color.G < 1.0
		or color.B < 1.0
		or color.A < 1.0
		then
			player:SetColor(Color (1.0, 1.0, 1.0, 1.0), -1, 999999999, false, false)
		end
	else
		player:TryRemoveNullCostume(hexanowHairCostume)
		player:TryRemoveNullCostume(hexanowBodyCostume)
		player:TryRemoveNullCostume(hexanowBodyFlightCostume)
	end
end

-- 提交缓存更新请求
local function UpdateCache(player)
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
local function ApplyEternalHearts(player)
	if player:GetEternalHearts() <= 0 then
		player:AddEternalHearts(1)
	end
end

-- 给予永恒充能
local function ApplyEternalCharge(player)
	if player:GetEternalHearts() <= 0 and EternalCharges > 0 then
		player:AddEternalHearts(1)
		EternalCharges = EternalCharges - 1
	end
end

--[[
-- 确保随从数量
local function EnsureFamiliars(player)
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
]]

-- 移除红心外的所有心
local function RearrangeHearts(player)
	local maxHearts = player:GetMaxHearts()
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
			player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANNOUNCER)
			countBlack = countBlack + 1
		end
		blackHeartsByteTemp = blackHeartsByteTemp >> 1
	end

	local chargesocre = countSoul + countBone * 2
	EternalCharges = EternalCharges + math.floor(chargesocre)

	player:AddSoulHearts(-soulHearts)
	player:AddBoneHearts(-countBone)
	player:AddGoldenHearts(countGold)

	if (countSoul > 0 or countBone > 0) and player:GetHearts() <=0 then
		if player:GetMaxHearts() <=0 then
			EternalCharges = EternalCharges - 1
			player:AddMaxHearts(1)
		end
		EternalCharges = EternalCharges - 1
		player:AddHearts(1)
	end

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

-- 物品谓词
local function HexanowOwnedCollectibleNum(player, ID, IgnoreModifiers)
	local num = player:GetCollectibleNum(ID, IgnoreModifiers)
	if ID ~= 0 and HexanowPlayerDatas[GetPlayerID(player)].upcomingItem == ID then
		num = num + 1
	end
	return num
end

-- 物品谓词
local function HexanowBlackCollectiblePredicate(ID)
	--local item = Isaac.GetItemConfig():GetCollectible(ID)
	if ID ~= 0 and (
		(
		ID == CollectibleType.COLLECTIBLE_MEGA_MUSH
		or ID == CollectibleType.COLLECTIBLE_ANKH
		or ID == CollectibleType.COLLECTIBLE_JUDAS_SHADOW
		--or ID == CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR
		))
	then
		return true
	else
		return false
	end
end

-- 物品谓词
local function HexanowWhiteCollectiblePredicate(ID, ignoreEnsured)
	local item = Isaac.GetItemConfig():GetCollectible(ID)
	if  (	(item ~= nil and item:HasTags(ItemConfig.TAG_QUEST))
		or	ID == CollectibleType.COLLECTIBLE_POLAROID
		or	ID == CollectibleType.COLLECTIBLE_NEGATIVE
		or	ID == CollectibleType.COLLECTIBLE_BROKEN_SHOVEL
		or	ID == CollectibleType.COLLECTIBLE_BROKEN_SHOVEL_2
		or	ID == CollectibleType.COLLECTIBLE_MOMS_SHOVEL
		or	ID == CollectibleType.COLLECTIBLE_KEY_PIECE_1
		or	ID == CollectibleType.COLLECTIBLE_KEY_PIECE_2
		or	ID == CollectibleType.COLLECTIBLE_KNIFE_PIECE_1
		or	ID == CollectibleType.COLLECTIBLE_KNIFE_PIECE_2
		or	ID == CollectibleType.COLLECTIBLE_DADS_NOTE
		or	ID == CollectibleType.COLLECTIBLE_DOGMA
		or	ID == hexanowPortalTool
		--or	ID == CollectibleType.COLLECTIBLE_RED_KEY
		--[[
		or (not ignoreEnsured == true and (
			ID == CollectibleType.COLLECTIBLE_ANALOG_STICK
		or	ID == CollectibleType.COLLECTIBLE_URANUS
		or	ID == CollectibleType.COLLECTIBLE_NEPTUNUS
		--or	ID == CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR
		))
		]]
		--or	ID == CollectibleType.COLLECTIBLE_BIRTHRIGHT

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
local function HexanowCollectibleMaxAllowed(player, ID)
	local playerID = GetPlayerID(player)
	local num = 0

	if HexanowBlackCollectiblePredicate(ID)
	or ID == 0
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
		if HexanowPlayerDatas[playerID].WhiteItem[i] == ID then
			num = num + 1
		end
	end

	return num
end

local function IsWhiteHexanowCollectible(player, ID)
	local playerID = GetPlayerID(player)

	if HexanowBlackCollectiblePredicate(ID) or ID == 0 then
		return false
	end
	for i=1,3 do
		if HexanowPlayerDatas[playerID].WhiteItem[i] == ID then
			return true
		end
	end
	return false
end

local function SetWhiteHexanowCollectible(player, ID, slot)
	--print("White Collectible",slot,"Now",ID)
	local playerID = GetPlayerID(player)

	if ID ~= 0 then
		if HexanowBlackCollectiblePredicate(ID)
		then
			return nil
		end

		if HexanowCollectibleMaxAllowed(player, ID) - HexanowOwnedCollectibleNum(player, ID, true) > 0 then
			return nil
		end
	end

	if slot == nil then
		slot = HexanowPlayerDatas[playerID].SelectedWhiteItem
	end

	if slot ~= 1
	and slot ~= 2
	and slot ~= 3
	then
		return nil
	end

	HexanowPlayerDatas[playerID].WhiteItem[slot] = ID
end

local function PickupWhiteHexanowCollectible(player, ID, slot)
	local playerID = GetPlayerID(player)
	local item = Isaac.GetItemConfig():GetCollectible(ID)

	if HexanowBlackCollectiblePredicate(ID) then
		return nil
	end

	if HexanowCollectibleMaxAllowed(player, ID) - HexanowOwnedCollectibleNum(player, ID, true) > 0 then
		return nil
	end

	if slot == nil then
		slot = HexanowPlayerDatas[playerID].SelectedWhiteItem
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
			if HexanowPlayerDatas[playerID].WhiteItem[1] == primaryAcItem then slot = 1 end
			if HexanowPlayerDatas[playerID].WhiteItem[2] == primaryAcItem then slot = 2 end
			if HexanowPlayerDatas[playerID].WhiteItem[3] == primaryAcItem then slot = 3 end
		end
	end

	if slot == 4
	then
		return nil
	end

	if ID ~= CollectibleType.COLLECTIBLE_SCHOOLBAG
	and HexanowPlayerDatas[playerID].WhiteItem[slot] == CollectibleType.COLLECTIBLE_SCHOOLBAG then
		local secondaryID = player:GetActiveItem(ActiveSlot.SLOT_SECONDARY)
		if secondaryID ~= CollectibleType.COLLECTIBLE_NULL then
			if HexanowPlayerDatas[playerID].WhiteItem[1] == secondaryID then
				HexanowPlayerDatas[playerID].WhiteItem[1] = 0
			end
			if HexanowPlayerDatas[playerID].WhiteItem[2] == secondaryID then
				HexanowPlayerDatas[playerID].WhiteItem[2] = 0
			end
			if HexanowPlayerDatas[playerID].WhiteItem[3] == secondaryID then
				HexanowPlayerDatas[playerID].WhiteItem[3] = 0
			end
		end
	end
	
	SetWhiteHexanowCollectible(player, ID, slot)
end

local function fromDirectionString(str)
	if str == "left" then
		return Direction.LEFT
	elseif str == "up" then
		return Direction.UP
	elseif str == "right" then
		return Direction.RIGHT
	elseif str == "down" then
		return Direction.DOWN
	else
		return Direction.NO_DIRECTION
	end
end

local function TeleportToRoomDescLocation(player, gridIndex, dimension, inInRoomGridIndex)
	Game():StartRoomTransition(gridIndex, Direction.NO_DIRECTION, RoomTransitionAnim.WOMB_TELEPORT, player, dimension)
	queuedNextRoomGrid = inInRoomGridIndex
	if player ~= nil then
		player:AnimateTeleport(true)
	end
	return true
end

local function TeleportToLevelLocation(player, RoomInLevelListIndex, InRoomGridIndex)
	local roomDesc = Game():GetLevel():GetRooms():Get(RoomInLevelListIndex)
	if roomDesc == nil
	or roomDesc.SafeGridIndex < 0
	then
		return false
	end
	return TeleportToRoomDescLocation(player, roomDesc.SafeGridIndex, GetDimensionOfRoomDesc(roomDesc), InRoomGridIndex)
end

local function IsPortalInSameRoom(portalOwnerPlayerID, portalColorType)
	local level = Game():GetLevel()
	local levelPosition = HexanowPlayerDatas[portalOwnerPlayerID].CreatedPortals[GetCurrentDimension()][portalColorType]
	return levelPosition.RoomInLevelListIndex == level:GetCurrentRoomDesc().ListIndex
end

local function TeleportToPortalLocation(entity, portalOwnerPlayerID, portalColorType, originalDegree)
	local room = Game():GetRoom()
	local location = HexanowPlayerDatas[portalOwnerPlayerID].CreatedPortals[GetCurrentDimension()][portalColorType]
	if location ~= nil then
		if IsPortalInSameRoom(portalOwnerPlayerID, portalColorType) then
			local inInRoomGridIndex, direction = ValidHexanowPortalWall(room:GetRoomShape(), location.InRoomGridIndex)
			local pos = room:GetGridPosition(inInRoomGridIndex)
			direction = fromDirectionString(direction)
			if pos ~= nil and direction ~= Direction.NO_DIRECTION then
				local outFacingDeg = ((direction) * 90) % 360
				local dir = Vector.FromAngle(outFacingDeg)
				local rot = (outFacingDeg - originalDegree - 180) % 360
				entity.Position = pos + (dir * 40)
				entity.Velocity = entity.Velocity:Rotated(rot)
				--entity:AddVelocity(dir * 40)
				--entity:AddControlsCooldown(2)
			end
		elseif entity:ToPlayer() ~= nil then
			if location.InRoomGridIndex == nil then
				print("NIL!!!")
			end
			return TeleportToLevelLocation(entity:ToPlayer(), location.RoomInLevelListIndex, location.InRoomGridIndex)
		end
	end
	return false
end


local function HasValidCreatedPortal(portalOwnerPlayerID, portalColorType)
	local level = Game():GetLevel()
	local levelPosition = HexanowPlayerDatas[portalOwnerPlayerID].CreatedPortals[GetCurrentDimension()][portalColorType]
	if levelPosition == nil then
		return false
	end
	local portalRoomDesc = level:GetRooms():Get(levelPosition.RoomInLevelListIndex)
	if (portalRoomDesc == nil or portalRoomDesc.SafeGridIndex < 0) and not IsPortalInSameRoom(portalOwnerPlayerID, portalColorType) then
		return false
	end
	return true
end

local function MaintainPortal(skipCreationAnim)

	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	local roomDesc = level:GetCurrentRoomDesc()
	local roomEntities = Isaac.GetRoomEntities()
	local roomPortals = {}
	local dimension = GetCurrentDimension()
	roomPortals[1] = {}
	roomPortals[2] = {}
	roomPortals[3] = {}
	roomPortals[4] = {}
	roomPortals[5] = {}
	roomPortals[6] = {}
	roomPortals[7] = {}
	roomPortals[8] = {}

	for i,entity in ipairs(roomEntities) do
		if entity.Type == EntityType.ENTITY_EFFECT
		and entity.Variant == entityVariantHexanowPortalDoor
		then
			if entity.SubType < 1 or entity.SubType > 8 then
				entity:Remove()
			else
				table.insert(roomPortals[entity.SubType], entity)
			end
		end
	end
	for playerID=1,4 do
		for portaltype=1,2 do
			if HexanowPlayerDatas[playerID].InRoomCreatedPortals[portaltype] ~= nil
			and HexanowPlayerDatas[playerID].InRoomCreatedPortals[portaltype]:IsDead()
			then
				HexanowPlayerDatas[playerID].InRoomCreatedPortals[portaltype] = nil
			end
			local portalCode = playerID*2 + portaltype - 2
			local levelPosition = HexanowPlayerDatas[playerID].CreatedPortals[dimension][portaltype]
			local inInRoomGridIndex = nil
			local direction = nil
			local pos = nil
			local isInRoom = false
			if levelPosition ~= nil then
				isInRoom = levelPosition.RoomInLevelListIndex == roomDesc.ListIndex
				if isInRoom then
					inInRoomGridIndex, direction = ValidHexanowPortalWall(room:GetRoomShape(), levelPosition.InRoomGridIndex)
					pos = room:GetGridPosition(inInRoomGridIndex)
					direction = fromDirectionString(direction)
					if inInRoomGridIndex == nil or direction == Direction.NO_DIRECTION or pos == nil or room:GetType() == RoomType.ROOM_DUNGEON then
						isInRoom = false
						pos = nil
						direction = nil
						HexanowPlayerDatas[playerID].CreatedPortals[dimension][portaltype] = nil
					end
				end
			end
			local foundMatchedPortal = false--isInRoom and HexanowPlayerDatas[playerID].InRoomCreatedPortals[portaltype] ~= nil and pos.X == HexanowPlayerDatas[playerID].InRoomCreatedPortals[portaltype].Position.X and pos.Y == HexanowPlayerDatas[playerID].InRoomCreatedPortals[portaltype].Position.Y
			local portals = roomPortals[portalCode]
			--for k=1,#portals do
			for k,portal in pairs(portals) do --remove invalid portals
				if isInRoom
				and not foundMatchedPortal
				and pos.X == portal.Position.X
				and pos.Y == portal.Position.Y
				then
					foundMatchedPortal = true
					HexanowPlayerDatas[playerID].InRoomCreatedPortals[portaltype] = portal
				else
					if HexanowPlayerDatas[playerID].InRoomCreatedPortals[portaltype] == portal then
						HexanowPlayerDatas[playerID].InRoomCreatedPortals[portaltype] = nil
					end
					portal:Remove()
				end
			end
			if isInRoom and not foundMatchedPortal then --gen missing portal
				local newPortal = Isaac.Spawn(EntityType.ENTITY_EFFECT, entityVariantHexanowPortalDoor, portalCode, pos, Vector(0,0), player)
				newPortal.SpriteRotation = ((direction - 1) * 90) % 360
				--newPortal:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
				local sprite = newPortal:GetSprite()
				sprite.Color = GetHexanowPortalColor(Game():GetPlayer(playerID-1), portaltype)
				HexanowPlayerDatas[playerID].InRoomCreatedPortals[portaltype] = newPortal
			end
		end
	end

	if skipCreationAnim then
		for i=1, 8 do
			local ownerId = math.ceil(i/2)
			local otherType = i%2+1
			local portals = roomPortals[i]
			for j=1,#portals do
				local portal = portals[j]
				if not portal:IsDead() then
					CallForEveryEntity(
						function(entity)
							if entity:ToPlayer() ~= nil
							or entity:ToTear() ~= nil
							--or entity.Type == EntityType.ENTITY_FROZEN_ENEMY
							then
								local dist = entity.Position:Distance(portal.Position)
								if dist < 40 then--28.284271247461900976033774484194 then
									TeleportToPortalLocation(entity, ownerId, otherType, (portal.SpriteRotation + 90) % 360)
								end
							end
						end
					)
				end
			end
		end
	end
end

local function SetPortal(player, typeNum, room, roomDesc, pos)
	pos.X = math.floor((pos.X + 20)/40.0)*40
	pos.Y = math.floor((pos.Y+ 20)/40.0)*40
	local playerID = GetPlayerID(player)
	local dimension = GetCurrentDimension()
	local inInRoomGridIndex, direction = ValidHexanowPortalWall(room:GetRoomShape(), room:GetGridIndex(pos))
	if inInRoomGridIndex == nil or direction == nil then
		HexanowPlayerDatas[playerID].CreatedPortals[dimension][typeNum] = nil
		MaintainPortal(false)
		return false
	end
	local anotherTypeNum = 1
	if typeNum == 1 then anotherTypeNum = 2 end
	if HexanowPlayerDatas[playerID].CreatedPortals[dimension][anotherTypeNum] ~= nil
	and HexanowPlayerDatas[playerID].CreatedPortals[dimension][anotherTypeNum].RoomInLevelListIndex == roomDesc.ListIndex
	then
		if HexanowPlayerDatas[playerID].CreatedPortals[dimension][anotherTypeNum].InRoomGridIndex == inInRoomGridIndex then
			HexanowPlayerDatas[playerID].CreatedPortals[dimension][anotherTypeNum] = nil
		end
	end

	for i=1,4 do
		if i ~= playerID then
			for j=1,2 do
				if HexanowPlayerDatas[i].CreatedPortals[dimension][j] ~= nil
				and HexanowPlayerDatas[i].CreatedPortals[dimension][j].RoomInLevelListIndex == roomDesc.ListIndex
				and HexanowPlayerDatas[i].CreatedPortals[dimension][j].InRoomGridIndex == inInRoomGridIndex
				then
					HexanowPlayerDatas[playerID].CreatedPortals[dimension][typeNum] = nil
					MaintainPortal(false)
					return false
				end
			end
		end
	end

	if HexanowPlayerDatas[playerID].CreatedPortals[dimension][typeNum] ~= nil
	and HexanowPlayerDatas[playerID].CreatedPortals[dimension][typeNum].RoomInLevelListIndex == roomDesc.ListIndex
	and HexanowPlayerDatas[playerID].CreatedPortals[dimension][typeNum].InRoomGridIndex == inInRoomGridIndex
	then
		return true
	end
	--[[
	HexanowPlayerDatas[playerID].[dimension]CreatedPortals[typeNum] = nil
	if HexanowPlayerDatas[playerID].InRoomCreatedPortals[typeNum] ~= nil then
		HexanowPlayerDatas[playerID].InRoomCreatedPortals[typeNum]:Remove()
		HexanowPlayerDatas[playerID].InRoomCreatedPortals[typeNum] = nil
	end
	]]
	HexanowPlayerDatas[playerID].CreatedPortals[dimension][typeNum] = nil
	if room:GetType() ~= RoomType.ROOM_DUNGEON and inInRoomGridIndex ~= -1 then
		HexanowPlayerDatas[playerID].CreatedPortals[dimension][typeNum] = LevelPosition(roomDesc.ListIndex, inInRoomGridIndex)
		return true
	end
	MaintainPortal(false)
	return true
end

local function HexanowLaserOverPortalLocation(player, degrees, colorType)
	local playerID = GetPlayerID(player)
	local room = Game():GetRoom()
	local dimension = GetCurrentDimension()
	--local thisPortal = HexanowPlayerDatas[playerID].InRoomCreatedPortals[colorType]
	--local otherPortal = HexanowPlayerDatas[playerID].InRoomCreatedPortals[(colorType)%2+1]
	local thisPortal = HexanowPlayerDatas[playerID].CreatedPortals[dimension][colorType]
	local otherPortal = HexanowPlayerDatas[playerID].CreatedPortals[dimension][(colorType)%2+1]
	if thisPortal == nil or otherPortal == nil
	or not IsPortalInSameRoom(playerID, 1)
	or not IsPortalInSameRoom(playerID, 2)
	then
		return nil
	end
	local inInRoomGridIndex1, direction1 = ValidHexanowPortalWall(room:GetRoomShape(), thisPortal.InRoomGridIndex)
	local inInRoomGridIndex2, direction2 = ValidHexanowPortalWall(room:GetRoomShape(), otherPortal.InRoomGridIndex)
	direction1 = fromDirectionString(direction1)
	direction2 = fromDirectionString(direction2)

	if inInRoomGridIndex1 == nil or direction1 == Direction.NO_DIRECTION
	or inInRoomGridIndex2 == nil or direction2 == Direction.NO_DIRECTION
	then
		return nil
	end
	local pos1 = room:GetGridPosition(inInRoomGridIndex1)
	local pos2 = room:GetGridPosition(inInRoomGridIndex2)
	local rot1 = ((direction1 - 1) * 90) % 360
	local rot2 = ((direction2 - 1) * 90) % 360
	--if thisPortal ~= nil and otherPortal ~= nil then
	if pos1 ~= nil and pos2 ~= nil and rot1 ~= nil and rot2 ~= nil then
		return pos2, (rot2 - rot1 - 180 + degrees) % 360
	end
	return nil
end

local function CastHexanowLaser(player, position, degrees, colorType, fromOtherBeam)
	local offset = Vector(0, 0)
	if not fromOtherBeam then
		offset = Vector(0, -26)
	end
	local laser = EntityLaser.ShootAngle(entityVariantHexanowLaser, position, degrees, 10, offset, player)
	local sprite = laser:GetSprite()
	local color = GetHexanowPortalColor(player, colorType)
	sprite.Color = color
	laser.CollisionDamage = player.Damage
	laser.DepthOffset = -10 --3000
	laser.Shrink = false
	laser.DisableFollowParent = true
	laser.OneHit = true
	laser.GridHit = true
	laser.TearFlags = player.TearFlags | TearFlags.TEAR_ICE
	if not fromOtherBeam then
		local endpoint = EntityLaser.CalculateEndPoint(position + offset, Vector.FromAngle(degrees), Vector(0,0), player, 20)
		local settedPortal = SetPortal(player, colorType, Game():GetRoom(), Game():GetLevel():GetCurrentRoomDesc(), endpoint)
		if settedPortal then
			local newPosition, newDegrees = HexanowLaserOverPortalLocation(player, degrees, colorType)
			if newPosition ~= nil and newDegrees ~= nil then
				CastHexanowLaser(player, newPosition, newDegrees, (colorType)%2+1, true)
				local newEndpoint = EntityLaser.CalculateEndPoint(newPosition, Vector.FromAngle(newDegrees), Vector(0,0), player, 20)
				local intersection = ComputeIntersection(position, endpoint, newPosition, newEndpoint)
				if (degrees - newDegrees) % 180 ~= 0 and intersection ~= nil then
					--[[
					local bomb = player:FireBomb(intersection, Vector(0, 0), player)
					bomb.Visible = false
					bomb:AddTearFlags(TearFlags.TEAR_ICE)
					bomb.ExplosionDamage = 0
					bomb:SetExplosionCountdown(0)
					]]
					--[[
					local entitiesTempNoKnockback = {}
					CallForEveryEntity(
						function(entity)
							if entity:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) then
								entity:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
								entitiesTempNoKnockback[entity.Index] = true
							end
						end
					)
					]]
					Game():BombExplosionEffects(
						intersection,
						player.Damage,
						player.TearFlags | TearFlags.TEAR_ICE,
						Color(color.R,color.G,color.B,0),
						player,
						1,
						false,
						false,
						DamageFlag.DAMAGE_LASER
					)
					--[[
					CallForEveryEntity(
						function(entity)
							if entitiesTempNoKnockback[entity.Index] then
								entity:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
							end
						end
					)
					]]
					--[[
					Game():BombDamage(
						intersection,
						player.Damage,
						40,
						false,
						player,
						player.TearFlags | TearFlags.TEAR_ICE,
						DamageFlag.DAMAGE_LASER,
						false
					)
					Game():BombTearflagEffects(
						intersection,
						40,
						player.TearFlags | TearFlags.TEAR_ICE,
						player,
						1
					)
					]]
				end
			end
		end
	end
	return laser
end

local function TaintedHexanowRoomOverride()
	if not HexanowFlags:HasFlag("TAINTED") then
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
					local redKey = CollectibleType.COLLECTIBLE_RED_KEY
					if redMap ~= nil then
						redKey = redMap
					end
					if not HexanowFlags:HasFlag("TEFFECT_REDKEY_GEN") and room:GetBackdropType() == 51 and pickup.SubType ~= redKey then
						pickup:Morph(pickup.Type, pickup.Variant, redKey, true)
						HexanowFlags:AddFlag("TEFFECT_REDKEY_GEN")
					end

					if pickup.SubType == CollectibleType.COLLECTIBLE_R_KEY
					or pickup.SubType == CollectibleType.COLLECTIBLE_SPINDOWN_DICE
					or pickup.SubType == CollectibleType.COLLECTIBLE_CLICKER
					then
						pickup:Morph(pickup.Type, pickup.Variant, CollectibleType.COLLECTIBLE_BREAKFAST, true)
					end
				end
				if not HexanowFlags:HasFlag("TEFFECT_CHESTWIPE") and room:GetBackdropType() == 49 and
					 ( pickup.Variant == PickupVariant.PICKUP_CHEST
					or pickup.Variant == PickupVariant.PICKUP_BOMBCHEST
					or pickup.Variant == PickupVariant.PICKUP_SPIKEDCHEST
					or pickup.Variant == PickupVariant.PICKUP_ETERNALCHEST
					or pickup.Variant == PickupVariant.PICKUP_MIMICCHEST
					or pickup.Variant == PickupVariant.PICKUP_LOCKEDCHEST
					)
				then
					pickup:Remove()
					HexanowFlags:AddFlag("TEFFECT_CHESTWIPE")
				end
			end

			if not HexanowFlags:HasFlag("TEFFECT_DEATHCERTIFICATE_GEN") and
			(entity.Type == EntityType.ENTITY_SHOPKEEPER
			or (pickup ~= nil and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.SubType == CollectibleType.COLLECTIBLE_INNER_CHILD)
			)then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE, entity.Position, Vector(0,0), entity)
				entity:Remove()
				HexanowFlags:AddFlag("TEFFECT_DEATHCERTIFICATE_GEN")
			end


		end
	end

end

-- 玩家刻事件，每一帧执行
local function TickEventHexanow(player)
	if IsHexanowTainted(player) then
		player:ChangePlayerType(playerTypeHexanow)
	end
	if IsHexanow(player) then
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
			--return nil
		end

		player:FlushQueueItem()

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
			player:RemoveCollectible(hexanowStatTriggerItem)
		end

		if roomClearBounsEnabled and not player:IsFlying() then
			player:RemoveCollectible(hexanowStatTriggerItem)
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
			--[[
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
			]]
			--if not player:HasCollectible(CollectibleType.COLLECTIBLE_SOL, true) then
			--	player:AddCollectible(CollectibleType.COLLECTIBLE_SOL, 0, false)
			--	UpdateCostumes(player)
			--end
		--end


		--[[
		local VREntityNotTraced = true
		local VRHolding = false

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
		--[[
		if player:IsDead() then
			--player:Revive()
		end
		]]
		--[[
		if room:GetFrameCount() == 1 then
			ApplyEternalHearts(player)
			UpdateCostumes(player)
		else
		end
		]]
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
			HexanowPlayerDatas[playerID].onceHoldingItem = true
		elseif HexanowPlayerDatas[playerID].onceHoldingItem then
			UpdateCostumes(player)
			HexanowPlayerDatas[playerID].onceHoldingItem = false
		end
		--[[
		if HexanowPlayerDatas[playerID].lastCanFly ~= player.CanFly then
			UpdateCostumes(player)
			HexanowPlayerDatas[playerID].lastCanFly = player.CanFly
		end
		]]

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
			if HexanowPlayerDatas[playerID].WhiteItemSelectPressed >= 20 then
				HexanowPlayerDatas[playerID].WhiteItemSelectPressed = 0
			end
			if HexanowPlayerDatas[playerID].WhiteItemSelectPressed == 0 then
				local slot = HexanowPlayerDatas[playerID].SelectedWhiteItem

				if slot == 1
				or slot == 2
				or slot == 3
				then
					slot = slot + 1
				else
					slot = 1
				end

				HexanowPlayerDatas[playerID].SelectedWhiteItem = slot
			end
			HexanowPlayerDatas[playerID].WhiteItemSelectPressed = HexanowPlayerDatas[playerID].WhiteItemSelectPressed + 1
		else
			HexanowPlayerDatas[playerID].WhiteItemSelectPressed = 0
		end

		--local tracedItems = player:GetCollectibleCount()

		--local missingWhiteCollectible = false
		--local missingWhiteTrinket = false
		--local hasWhiteCollectible = false
		--local hasWhiteTrinket = false

		local item1 = HexanowPlayerDatas[playerID].WhiteItem[1]
		local item2 = HexanowPlayerDatas[playerID].WhiteItem[2]
		local item3 = HexanowPlayerDatas[playerID].WhiteItem[3]

		local item1Missing = item1 == 0
		local item2Missing = item2 == 0
		local item3Missing = item3 == 0

		--if not player:IsHoldingItem() then
		if true then
			--[[
			local queuedItem = player.QueuedItem.Item
			if queuedItem ~= nil then
				print("1!")
				if (not HexanowPlayerDatas[playerID].onceHoldingItem) or HexanowPlayerDatas[playerID].upcomingItem ~= queuedItem.ID or HexanowPlayerDatas[playerID].upcomingType ~= queuedItem.Type then
					print("11!")
					HexanowPlayerDatas[playerID].onceHoldingItem = true
					HexanowPlayerDatas[playerID].upcomingItem = queuedItem.ID
					HexanowPlayerDatas[playerID].upcomingType = queuedItem.Type
					if queuedItem.Type == ItemType.ITEM_PASSIVE or queuedItem.Type == ItemType.ITEM_ACTIVE then
						print("SET!")
						PickupWhiteHexanowCollectible(player, queuedItem.ID, HexanowPlayerDatas[playerID].SelectedWhiteItem)
					end
					AddEternalHearts(queuedItem.AddSoulHearts)
					AddEternalHearts(queuedItem.AddBlackHearts)
					for i=1,math.ceil(queuedItem.AddBlackHearts/2) do
						player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANNOUNCER)
					end
					queuedItem.AddBlackHearts = 0
					queuedItem.AddSoulHearts = 0
					player:AddCoins(queuedItem.AddCoins)
					queuedItem.AddCoins = 0
					player:AddBombs(queuedItem.AddBombs)
					queuedItem.AddBombs = 0
					player:AddKeys(queuedItem.AddKeys)
					queuedItem.AddKeys = 0
					player:AddMaxHearts(queuedItem.AddMaxHearts)
					queuedItem.AddMaxHearts = 0
					player:AddHearts(queuedItem.AddHearts)
					queuedItem.AddHearts = 0
				end
			else
				if HexanowPlayerDatas[playerID].onceHoldingItem then
					HexanowPlayerDatas[playerID].onceHoldingItem = false
					HexanowPlayerDatas[playerID].upcomingItem = nil
					HexanowPlayerDatas[playerID].upcomingType = nil
					UpdateCostumes(player)
				end
			end
			]]
			local item1dem = 1
			local item2dem = 1
			local item3dem = 1


			if item2 == item1 then
				item2dem = item2dem + 1
			end
			if item3 == item1 then
				item3dem = item3dem + 1
			end
			if item3 == item2 then
				item3dem = item3dem + 1
			end

			if not item1Missing and HexanowOwnedCollectibleNum(player, item1, true) < item1dem then
				item1Missing = true
				SetWhiteHexanowCollectible(player, 0, 1)
			end

			if not item2Missing and  HexanowOwnedCollectibleNum(player, item2, true) < item2dem then
				item2Missing = true
				SetWhiteHexanowCollectible(player, 0, 2)
			end

			if not item3Missing and  HexanowOwnedCollectibleNum(player, item3, true) < item3dem then
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
			--for ID = CollectibleType.NUM_COLLECTIBLES - 1, 1, -1 do
			local ID = 0
			while true do
				ID = ID + 1
				local item = Isaac.GetItemConfig():GetCollectible(ID)
				if ID >= CollectibleType.NUM_COLLECTIBLES and item == nil then
					break
				end
				local ownNum = HexanowOwnedCollectibleNum(player, ID, true)
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
						EternalCharges = EternalCharges + 4 --item.Quality * 2 + 1
					end
				end
			end
		end

		--player.ItemHoldCooldown = 0
	end
end

-- 玩家攻击，每一帧执行
local function TryCastFireHexanow(player)
	if IsHexanow(player) then
		local playerID = GetPlayerID(player)
		local aimDirection = player:GetAimDirection()

		if player.FireDelay <= 0
		and not (aimDirection.X == 0 and aimDirection.Y == 0)
		then
			player.HeadFrameDelay = math.floor(player.MaxFireDelay)
			player.FireDelay = math.floor(player.MaxFireDelay)
			CastHexanowLaser(player, player.Position, aimDirection:GetAngleDegrees(), HexanowPlayerDatas[playerID].portalToolColor)
		end
	end
end

-- 初始化人物
local function InitPlayerHexanow(player)
	if IsHexanow(player) then
		local itemPool = Game():GetItemPool()

		player:AddHearts(-player:GetHearts())
		player:AddMaxHearts(-player:GetMaxHearts())
		player:AddMaxHearts(12)
		player:AddHearts(11)

		--player:AddGoldenKey()
		--player:AddGoldenBomb()
		-- player:AddGoldenHearts(0)
		ApplyEternalHearts(player)

		--player:AddHearts(-1)
		--player:AddCard(Card.CARD_JUSTICE)
		--player:AddCard(Card.CARD_CRACKED_KEY)
		if player:GetData().InitedAsTaintedHexanow == true then
			player:AddMaxHearts(12)
			player:AddHearts(13)
			player:AddTrinket(TrinketType.TRINKET_PERFECTION | 32768)
		else
			player:AddTrinket(TrinketType.TRINKET_NO | 32768)
		end
		-- player:AddCard(Card.CARD_SUN)
		-- player:AddTrinket(TrinketType.TRINKET_BIBLE_TRACT)

		-- print("PostGameStarted for", player:GetName())

		--itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK)
		--itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_URANUS)
		--itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS)
		--itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_SOL)
		--itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR)
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

-- 初始化人物
local function InitPlayerHexanowTainted(player)
	--print("CALLED!")
	--print("PType", player:GetPlayerType())
	--print("TType", playerTypeHexanowTainted)
	if IsHexanowTainted(player) then
		--print("CALLED ACCEPT!")
		player:ChangePlayerType(playerTypeHexanow)
		player:GetData().InitedAsTaintedHexanow = true
	end
end

------------------------------------------------------------
---------- 渲染器功能
----------

-- 渲染物品选单
local function SelManageRander(pos, playerID, sortNum)
	-- local playerID = 1
	local FrameAnm = "Frame"
	if sortNum >= 1 then
		FrameAnm = "Frame2"
	end
	pos = pos + Vector(sortNum*16, 0)

	local frame0 = HexanowPlayerDatas[playerID].sprites.frame0
	local frame1 = HexanowPlayerDatas[playerID].sprites.frame1
	local frame2 = HexanowPlayerDatas[playerID].sprites.frame2
	local frame3 = HexanowPlayerDatas[playerID].sprites.frame3
	local frame4 = HexanowPlayerDatas[playerID].sprites.frame4
	local arraw = HexanowPlayerDatas[playerID].sprites.arraw
	local item1 = HexanowPlayerDatas[playerID].sprites.item1
	local item2 = HexanowPlayerDatas[playerID].sprites.item2
	local item3 = HexanowPlayerDatas[playerID].sprites.item3
	local portalBase1 = HexanowPlayerDatas[playerID].sprites.portalBase1
	local portalBase2 = HexanowPlayerDatas[playerID].sprites.portalBase2
	local portalCreated1 = HexanowPlayerDatas[playerID].sprites.portalCreated1
	local portalCreated2 = HexanowPlayerDatas[playerID].sprites.portalCreated2
	local portalSelected = HexanowPlayerDatas[playerID].sprites.portalSelected

	local portalColor1 = GetHexanowPortalColor(Game():GetPlayer(playerID-1), 1)
	local portalColor2 = GetHexanowPortalColor(Game():GetPlayer(playerID-1), 2)


	--item3:ReplaceSpritesheet(0,"gfx/items/collectibles/".."Collectibles_118_Brimstone.png")

	frame0:SetFrame(FrameAnm, 0)
	frame1:SetFrame(FrameAnm, 1)
	frame2:SetFrame(FrameAnm, 1)
	frame3:SetFrame(FrameAnm, 1)
	frame4:SetFrame(FrameAnm, 2)

	portalBase1.Color = portalColor1
	portalBase2.Color = portalColor2

	--[[
	if HexanowPlayerDatas[playerID].SelectedWhiteItem == 1 then
		arraw:SetFrame("Select", 0)
	elseif HexanowPlayerDatas[playerID].SelectedWhiteItem == 2 then
		arraw:SetFrame("Select", 1)
	elseif HexanowPlayerDatas[playerID].SelectedWhiteItem == 3 then
		arraw:SetFrame("Select", 2)
	else
		arraw:SetFrame("Select", 3)
	end
	]]

	frame0:Render(pos + Vector(0,16*0), Vector(0,0), Vector(0,0))
	frame1:Render(pos + Vector(0,16*1), Vector(0,0), Vector(0,0))
	frame2:Render(pos + Vector(0,16*2), Vector(0,0), Vector(0,0))
	frame3:Render(pos + Vector(0,16*3), Vector(0,0), Vector(0,0))
	frame4:Render(pos + Vector(0,16*4), Vector(0,0), Vector(0,0))

	portalBase1:Render(pos + Vector(0,0), Vector(0,0), Vector(0,0))
	portalBase2:Render(pos + Vector(0,0), Vector(0,0), Vector(0,0))

	local portal1created = HasValidCreatedPortal(playerID,1)
	local portal2created = HasValidCreatedPortal(playerID,2)
	if portal1created then
		portalCreated1.Color = portalColor1
		portalCreated1:Render(pos + Vector(0,0), Vector(0,0), Vector(0,0))
	end
	if portal2created then
		portalCreated2.Color = portalColor2
		portalCreated2:Render(pos + Vector(0,0), Vector(0,0), Vector(0,0))
	end

	if HexanowPlayerDatas[playerID].portalToolColor == 2 then
		if portal2created then
			portalSelected:SetFrame("PortalSelectedCreated", 1)
		else
			portalSelected:SetFrame("PortalSelected", 1)
		end
	else
		if portal1created then
			portalSelected:SetFrame("PortalSelectedCreated", 0)
		else
			portalSelected:SetFrame("PortalSelected", 0)
		end
	end

	if HexanowPlayerDatas[playerID].WhiteItem[1] ~= nil then
		local item = Isaac.GetItemConfig():GetCollectible(HexanowPlayerDatas[playerID].WhiteItem[1])
		if item ~= nil then
			item1:ReplaceSpritesheet(0,item.GfxFileName)
			item1:LoadGraphics()
			item1:Render(pos + Vector(0,16*1), Vector(0,0), Vector(0,0))
		end
	end
	if HexanowPlayerDatas[playerID].WhiteItem[2] ~= nil then
	local item = Isaac.GetItemConfig():GetCollectible(HexanowPlayerDatas[playerID].WhiteItem[2])
		if item ~= nil then
			item2:ReplaceSpritesheet(0,item.GfxFileName)
			item2:LoadGraphics()
			item2:Render(pos + Vector(0,16*2), Vector(0,0), Vector(0,0))
		end
	end
	if HexanowPlayerDatas[playerID].WhiteItem[3] ~= nil then
	local item = Isaac.GetItemConfig():GetCollectible(HexanowPlayerDatas[playerID].WhiteItem[3])
		if item ~= nil then
			item3:ReplaceSpritesheet(0,item.GfxFileName)
			item3:LoadGraphics()
			item3:Render(pos + Vector(0,16*3), Vector(0,0), Vector(0,0))
		end
	end

	arraw:Render(pos + Vector(0,(HexanowPlayerDatas[playerID].SelectedWhiteItem-1)*16), Vector(0,0), Vector(0,0))
	portalSelected:Render(pos + Vector(0,0), Vector(0,0), Vector(0,0))

end

------------------------------------------------------------
---------- 注册事件
----------

-- 在游戏被初始化后运行
function HexanowMod.Main:PostGameStarted(loadedFromSaves)
	if not loadedFromSaves then -- 仅限新游戏
		local player = PlayerFindFirst(function(player) return player:GetData().InitedAsTaintedHexanow == true end)
		if not HexanowFlags:HasFlag("TAINTED") and player ~= nil then
			HexanowFlags:AddFlag("TAINTED")
			player:GetData().InitedAsTaintedHexanow = nil
			--player:AddCard(Card.CARD_CRACKED_KEY)
			--player:AddCollectible(CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE, 0, false)
			player:AddCoins(99)
			player:AddBombs(99)
			player:AddKeys(99)
			--player:AddEternalHearts(24)
			EternalCharges = EternalCharges + 99

			--local stageType = Game():GetLevel():GetStageType()

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
			TaintedHexanowRoomOverride()
		end
	end
end
HexanowMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, HexanowMod.Main.PostGameStarted)

-- 自定义命令行
function HexanowMod.Main:ExecuteCmd(cmd, params)
	--[[
	if cmd == "hudoffset" then
		if tonumber(params) ~= nil
		and tonumber(params) > -1 and tonumber(params) < 11 then
			HUDoffset = tonumber(params)
			Isaac.ConsoleOutput("HUD Offset updated.")
		else
			Isaac.ConsoleOutput("Invalid args")
		end
	end
	]]--
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
	if cmd == "flashred" then
		local pnum = tonumber(params)
		if pnum ~= nil then
			local level = Game():GetLevel()

			local redsecretIndex = level:QueryRoomTypeIndex(RoomType.ROOM_ULTRASECRET, false, RNG(), true)
			local redsecretRoom = level:GetRoomByIdx(redsecretIndex)
			--redsecretRoom.DisplayFlags = redsecretRoom.DisplayFlags | 1 << 0 | 1 << 1 | 1 << 2
			redsecretRoom.DisplayFlags = redsecretRoom.DisplayFlags | pnum

			level:UpdateVisibility()
		else
			Isaac.ConsoleOutput("Invalid args")
		end


		--[[
		--local rooms = level:GetRooms()
		local targetRoomIndex = nil

		--for i = 0, rooms:__len()-1 , 1 do
			--local roomDes = rooms:Get(i)
		for i = 0, level:GetRoomCount()-1 , 1 do
			local roomDes = rooms:Get(i)
			print("test",roomDes.ListIndex,"result",roomDes.Data.Type)
			if roomDes.Data.Type == RoomType.ROOM_ULTRASECRET then
				targetRoomIndex = roomDes.ListIndex
				break
			end
		end

		if targetRoomIndex ~= nil then
			local currIndex = level:GetCurrentRoomIndex()
			level:ChangeRoom(106)
			level:ChangeRoom(currIndex)
			print("FOUND!")
		else
			print("NOT FOUND!")
		end
		]]

	end
	if cmd == "toportal" then
		TeleportToPortalLocation(Game():GetPlayer(0), 1, tonumber(params))
	end
	if cmd == "ffsp" then
		SuperPower = not SuperPower
		CallForEveryPlayer(
			function(player)
				player:RemoveCollectible(hexanowStatTriggerItem)
			end
		)
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
			print(tostring(entity.Type).."."..tostring(entity.Variant).."."..tostring(entity.SubType).." "..tostring(entity.Index).." ("..tostring(entity.Position.X)..", "..tostring(entity.Position.Y)..") ("..tostring(entity.PositionOffset.X)..", "..tostring(entity.PositionOffset.Y)..") "..tostring(entity.DepthOffset))
		end
	end
	if cmd == "reportentityne" then
		local roomEntities = Isaac.GetRoomEntities()

		for i,entity in ipairs(roomEntities) do
			if entity.Type ~= 1000 then
				print(tostring(entity.Type).."."..tostring(entity.Variant).."."..tostring(entity.SubType).." "..tostring(entity.Index).." ("..tostring(entity.Position.X)..", "..tostring(entity.Position.Y)..") ("..tostring(entity.PositionOffset.X)..", "..tostring(entity.PositionOffset.Y)..") "..tostring(entity.DepthOffset))
			end
		end
	end
	if cmd == "reportportals" then
		local roomEntities = Isaac.GetRoomEntities()

		for i=1,4 do
			for j=1,2 do
				local entity = HexanowPlayerDatas[i].InRoomCreatedPortals[j]
				if entity ~= nil then
					print(tostring(entity.Type).."."..tostring(entity.Variant).."."..tostring(entity.SubType).." "..tostring(entity.Index).." ("..tostring(entity.Position.X)..", "..tostring(entity.Position.Y)..") ("..tostring(entity.PositionOffset.X)..", "..tostring(entity.PositionOffset.Y)..") "..tostring(entity.DepthOffset))
				end
			end
		end
	end
	if cmd == "hflag" then
		local subcmd = params
		local subcmd_arg = ""

		local point,_ = string.find(params, " ", 1)
		if point ~= nil then
			subcmd = string.sub(params, 1, point - 1)
			subcmd_arg = string.sub(params, point + 1, string.len(params))
			--Isaac.ConsoleOutput("Invalid args\nRequires either")
		end

		if subcmd == "" or subcmd == "report" then
			print(HexanowFlags:ToString())
		elseif subcmd == "add" then
			HexanowFlags:AddFlag(subcmd_arg)
			print(HexanowFlags:ToString())
		elseif subcmd == "remove" then
			HexanowFlags:RemoveFlag(subcmd_arg)
			print(HexanowFlags:ToString())
		elseif subcmd == "test" then
			print(HexanowFlags:HasFlag(subcmd_arg))
		else
			Isaac.ConsoleOutput('Invalid args\nRequires either "report", "add", "remove" or "test".')
		end

	end
end
HexanowMod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, HexanowMod.Main.ExecuteCmd);

-- 在玩家被加载后运行
function HexanowMod.Main:PostPlayerInit(player)
	InitPlayerHexanowTainted(player)
	InitPlayerHexanow(player)
end
HexanowMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, HexanowMod.Main.PostPlayerInit)

-- 使用传送门工具的效果
function HexanowMod.Main:UsePortalTool(itemId, itemRng, player, useFlags, activeSlot, customVarData)
	local result = {
		Discharge = false,
		Remove = false,
		ShowAnim = false,
	}
	local playerID = GetPlayerID(player)
	if HexanowPlayerDatas[playerID].portalToolColor == 1 then
		HexanowPlayerDatas[playerID].portalToolColor = 2
	else
		HexanowPlayerDatas[playerID].portalToolColor = 1
	end
	--player:UseActiveItem(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR, false, false, true, false)

	return result
end
HexanowMod:AddCallback(ModCallbacks.MC_USE_ITEM, HexanowMod.Main.UsePortalTool, hexanowPortalTool)

-- 时间回溯
function HexanowMod.Main:UseGlowingHourGlass(itemId, itemRng, player, useFlags, activeSlot, customVarData)
	if itemId == CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS
	--and IsHexanow(player)
	then
		RewindLastRoomVar()
	end
end
HexanowMod:AddCallback(ModCallbacks.MC_USE_ITEM, HexanowMod.Main.UseGlowingHourGlass)

-- 在玩家进入新楼层后运行
function HexanowMod.Main:PostNewLevel()
	for playerID=1,4 do
		HexanowPlayerDatas[playerID].CreatedPortals[0][1] = nil
		HexanowPlayerDatas[playerID].CreatedPortals[0][2] = nil
		HexanowPlayerDatas[playerID].CreatedPortals[1][1] = nil
		HexanowPlayerDatas[playerID].CreatedPortals[1][2] = nil
		HexanowPlayerDatas[playerID].CreatedPortals[2][1] = nil
		HexanowPlayerDatas[playerID].CreatedPortals[2][2] = nil
		HexanowPlayerDatas[playerID].InRoomCreatedPortals[1] = nil
		HexanowPlayerDatas[playerID].InRoomCreatedPortals[2] = nil
	end
	MaintainPortal(true)
	if HexanowFlags:HasFlag("TREASURE_ROOM_NOT_ENTERED") then
		EternalCharges = EternalCharges + 0
	end
	HexanowFlags:AddFlag("TREASURE_ROOM_NOT_ENTERED")
	HexanowFlags:RemoveFlag("MIRROR_WORLD_PORTALS_GENERATED")
	--[[
	CallForEveryPlayer(
		function(player)
			if IsHexanow(player) then
				if Game():GetLevel():GetStage() ~= 13 then
					player:UseActiveItem(hexanowPortalTool, false, false, true, false)
				end
			end
		end
	)
	]]
end
HexanowMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, HexanowMod.Main.PostNewLevel)

-- 在玩家进入新房间后运行
function HexanowMod.Main:PostNewRoom()
	local level = Game():GetLevel()
	local room = Game():GetRoom()
	for playerID=1,4 do
		HexanowPlayerDatas[playerID].InRoomCreatedPortals[1] = nil
		HexanowPlayerDatas[playerID].InRoomCreatedPortals[2] = nil
	end
	if queuedNextRoomGrid ~= nil then
		local inInRoomGridIndex, direction = ValidHexanowPortalWall(room:GetRoomShape(), queuedNextRoomGrid)
		direction = fromDirectionString(direction)
		local pos = room:GetGridPosition(inInRoomGridIndex)
		if pos ~= nil and direction ~= Direction.NO_DIRECTION then
			pos = pos + (Vector.FromAngle(((direction) * 90) % 360) * 40)
		else
			pos = room:GetGridPosition(queuedNextRoomGrid)
		end
		CallForEveryPlayer(
			function(player)
				player:AnimateTeleport()
				player.Position = pos
			end
		)
		queuedNextRoomGrid = nil
	end
	TaintedHexanowRoomOverride()
	MaintainPortal(true)
	if room:IsMirrorWorld() and not HexanowFlags:HasFlag("MIRROR_WORLD_PORTALS_GENERATED") then
		HexanowFlags:AddFlag("MIRROR_WORLD_PORTALS_GENERATED")
		for playerID=1,4 do
			for i=1,2 do
				if HexanowPlayerDatas[playerID].CreatedPortals[0][i] ~= nil then
					local gridIndex = level:GetRooms():Get(HexanowPlayerDatas[playerID].CreatedPortals[0][i].RoomInLevelListIndex).SafeGridIndex
					if gridIndex >= 0 then
						local listIndex = level:GetRoomByIdx(gridIndex, 1).ListIndex
						HexanowPlayerDatas[playerID].CreatedPortals[1][i] = LevelPosition(listIndex, HexanowPlayerDatas[playerID].CreatedPortals[0][i].InRoomGridIndex)
					end
				end
			end
		end
	end

	if room:GetType() == RoomType.ROOM_TREASURE and not room:IsMirrorWorld() then
		HexanowFlags:RemoveFlag("TREASURE_ROOM_NOT_ENTERED")
	end

	if room:GetAliveEnemiesCount() <= 0 then
		EternalChargeForFree = true
	else
		EternalChargeForFree = false
	end

	CallForEveryPlayer(
		function(player)
			UpdateCostumes(player)
			if IsHexanow(player) then
				player:RemoveCollectible(hexanowStatTriggerItem)
				ApplyEternalHearts(player)
				if not Game():GetRoom():IsClear() then
					roomClearBounsEnabled = false
					player:RemoveCollectible(hexanowStatTriggerItem)
				end
			end
		end
	)

	if PlayerTypeExistInGame(playerTypeHexanow) then
		local level = Game():GetLevel()
		--[[
		level:ApplyBlueMapEffect()
		level:ApplyCompassEffect()
		level:ApplyMapEffect()
		level:ShowMap ()

		local redsecretIndex = level:QueryRoomTypeIndex(RoomType.ROOM_ULTRASECRET, false, RNG(), true)
		local redsecretRoom = level:GetRoomByIdx(redsecretIndex)
		redsecretRoom.DisplayFlags = redsecretRoom.DisplayFlags | 1 << 0 | 1 << 1 | 1 << 2
		]]
		local rooms = level:GetRooms()
		for i = 0, #rooms - 1 do
			local room = level:GetRoomByIdx(rooms:Get(i).SafeGridIndex)
			if room then
				room.DisplayFlags = room.DisplayFlags | 1 << 0 | 1 << 1 | 1 << 2
			end
		end
		level:UpdateVisibility()

		--[[
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
		]]--
	end
end
HexanowMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, HexanowMod.Main.PostNewRoom)

-- 在房间被清理后运行
function HexanowMod.Main:PreSpawnCleanAward(Rng, SpawnPos)
	CallForEveryPlayer(
		function(player)
			if IsHexanow(player) then
				ApplyEternalHearts(player)
			end
		end
	)
end
HexanowMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, HexanowMod.Main.PreSpawnCleanAward)

-- 在玩家受伤时运行
function HexanowMod.Main:EntityTakeDmg(TookDamage, DamageAmount, DamageFlag, DamageSource, DamageCountdownFrames)
	if TookDamage.Type == EntityType.ENTITY_PLAYER then
		local player = TookDamage:ToPlayer()
		local room = Game():GetRoom()
		if IsHexanow(player) then
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
HexanowMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG , HexanowMod.Main.EntityTakeDmg)

-- 在生物被移除时运行
function HexanowMod.Main:PostEntityRemove(entity)
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
HexanowMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE , HexanowMod.Main.PostEntityRemove)

-- 干涉掉落物生成
function HexanowMod.Main:PostPickupSelection(Pickup, Variant, SubType)
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
HexanowMod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION , HexanowMod.Main.PostPickupSelection)

-- 干涉诅咒选择
function HexanowMod.Main:PostCurseEval(curses)
	if PlayerTypeExistInGame(playerTypeHexanow) then
		return ~( ~curses | LevelCurse.CURSE_OF_DARKNESS | LevelCurse.CURSE_OF_MAZE | LevelCurse.CURSE_OF_THE_UNKNOWN | LevelCurse.CURSE_OF_BLIND | LevelCurse.CURSE_OF_THE_LOST )
	end
end
HexanowMod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL , HexanowMod.Main.PostCurseEval)

-- 改变玩家碰撞行为
function HexanowMod.Main:PrePlayerCollision(player, collider, low)
	if IsHexanow(player) then
		if collider.Type == 306 then
			return true
		end
	end
end
HexanowMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION , HexanowMod.Main.PrePlayerCollision)

-- 改变眼泪碰撞行为
function HexanowMod.Main:PreTearCollision(tear, collider, low)
	if tear.Parent ~= nil then
		local player = tear.Parent:ToPlayer()
		if player ~= nil
		and IsHexanow(player)
		and collider.Type == 963
		then
			return true
		end
	end
end
HexanowMod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION , HexanowMod.Main.PreTearCollision)

-- 改变掉落物拾取行为
function HexanowMod.Main:PrePickupCollision(pickup, collider, low)
	local player = collider:ToPlayer()
	if player ~= nil
	and IsHexanow(player)
	then
		if HexanowFlags:HasFlag("TAINTED") and not HexanowFlags:HasFlag("TEFFECT_DEATHCERTIFICATE_USED")
		and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE
		and pickup.SubType == CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE
		and not pickup:IsShopItem()
		then
			HexanowFlags:AddFlag("TEFFECT_DEATHCERTIFICATE_USED")
			player:UseActiveItem(CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE,false,false,true,false, -1)
			--player:RemoveCollectible(WhiteHexanowCollectibleID, true)
			--SetWhiteHexanowCollectible(player, 0)
			pickup:Remove()
			return false
		end

		if pickup.Variant == PickupVariant.PICKUP_HEART then
			if pickup.SubType == HeartSubType.HEART_ETERNAL
			and player:GetMaxHearts() >= 24
			and player:GetHearts() < player:GetMaxHearts()
			and player:GetEternalHearts() >= 1 then
				if pickup:IsShopItem() then
					if player:GetNumCoins() >= pickup.Price and not player:IsHoldingItem() then
						player:AddCoins(-pickup.Price)
						player:AnimatePickup(pickup:GetSprite())
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
				return pickup:IsShopItem()
			elseif
				pickup.SubType == HeartSubType.HEART_HALF_SOUL
			or	pickup.SubType == HeartSubType.HEART_SOUL
			or	pickup.SubType == HeartSubType.HEART_BONE
			or	pickup.SubType == HeartSubType.HEART_BLACK
			or	pickup.SubType == HeartSubType.HEART_BLENDED
			then

				if pickup:IsShopItem() then
					if player:GetNumCoins() >= pickup.Price and not player:IsHoldingItem() then
						player:AddCoins(-pickup.Price)
						player:AnimatePickup(pickup:GetSprite())
					else
						return true
					end
				end

				local score = 2
				if pickup.SubType == HeartSubType.HEART_HALF_SOUL then
					score = 1
				elseif pickup.SubType == HeartSubType.HEART_BLACK then
					score = 2
					player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANNOUNCER)
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
				return pickup:IsShopItem()
			end
		end

		
		if pickup.SubType ~= 0
		and player:CanPickupItem()
		and not player:IsHoldingItem()
		and (not pickup:IsShopItem() or player:GetNumCoins() >= pickup.Price) then
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
HexanowMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION , HexanowMod.Main.PrePickupCollision)

-- 后期处理属性缓存
function HexanowMod.Main:EvaluateCache(player, cacheFlag, tear)
	--[[
		Hexanow stats
		damage: 300%
		tears: -0.66
		speed: -0.15 is room is not cleared, +0.15 if room is cleared
		tear range: 300%
		luck: -3
	]]
	if IsHexanow(player) then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			if roomClearBounsEnabled then
				player.MoveSpeed = player.MoveSpeed + 0.15 --  * (1.0 + 0.15 * player:GetMaxHearts() / 24.0)
			else
				player.MoveSpeed = player.MoveSpeed - 0.15
			end
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 3 -- (1.0 + 2.5 * player:GetMaxHearts() / 24.0 - 0.5)
			if Game():GetRoom():GetType() == RoomType.ROOM_DUNGEON then
				player.Damage = player.Damage * 3
			end
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 3
		elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed - 0.15 -- * (1.0 - 0.3 * player:GetMaxHearts() / 24.0 + 0.15)
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			--player.MaxFireDelay = math.ceil(
			--		(player.MaxFireDelay + (player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) and {2} or {0})[1]
			--		) * 2 -- * (1.0 + 1.5 * player:GetMaxHearts() / 24.0 - 0.5)
			--	)
			if false and player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
				player.MaxFireDelay = ApplyTears2TearDelay(player.MaxFireDelay, -0.34999972571835 -0.6666666666666)
			else
				player.MaxFireDelay = ApplyTears2TearDelay(player.MaxFireDelay, -0.6666666666666)
			end
			--player.MaxFireDelay = player.MaxFireDelay * 2
		elseif cacheFlag == CacheFlag.CACHE_RANGE  then
			--player.TearHeight = player.TearHeight * 3 -- (1 + 2.5 * player:GetMaxHearts() / 24.0 - 0.5)
			player.TearRange = player.TearRange * 3 -- (1 + 2.5 * player:GetMaxHearts() / 24.0 - 0.5)
			--player.TearFallingSpeed = player.TearFallingSpeed -- + 5.0 -- * player:GetMaxHearts() / 24.0
			--player.TearFallingAcceleration = math.min(player.TearFallingAcceleration, - 0.2 / 3)
		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
			--player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING | TearFlags.TEAR_PERSISTENT | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_ICE
			player.TearFlags = player.TearFlags
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			--[[if Game():GetRoom():IsClear() then
				player.CanFly = true
			else
				player.CanFly = false
			end]]
			if roomClearBounsEnabled then
				player.CanFly = true
			end
			-- UpdateCostumes(player)
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

			-- EnsureFamiliars(player)
			-- UpdateCostumes(player)
		elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = Color(1, 1, 1, 1, 0, 0, 0)
		end

	end

	if SuperPower and cacheFlag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage * 3 * 20 * 100 * 1000
	end
end
HexanowMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, HexanowMod.Main.EvaluateCache)

-- 在每一帧后执行
function HexanowMod.Main:PostUpdate()
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
	--[[
	CallForEveryPlayer(
		function(player)
			if IsHexanow(player) then
				TickEventHexanow(player)
				TryCastFireHexanow(player)
			end
		end
	)
	]]

	if PlayerTypeExistInGame(playerTypeHexanow) then
		if (level:GetCurses() & (LevelCurse.CURSE_OF_DARKNESS | LevelCurse.CURSE_OF_MAZE | LevelCurse.CURSE_OF_THE_UNKNOWN | LevelCurse.CURSE_OF_BLIND | LevelCurse.CURSE_OF_THE_LOST)) ~= 0 then
			level:RemoveCurses(LevelCurse.CURSE_OF_DARKNESS | LevelCurse.CURSE_OF_MAZE | LevelCurse.CURSE_OF_THE_UNKNOWN | LevelCurse.CURSE_OF_BLIND | LevelCurse.CURSE_OF_THE_LOST)
		end

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

				local tear = entity:ToTear()
				if tear ~= nil and tear.Parent ~= nil then
					if tear.Parent.Type == EntityType.ENTITY_PLAYER then
						local player = tear.Parent:ToPlayer()
						if IsHexanow(player)
						then
							if tear.Variant ~= TearVariant.ICE then
								tear:ChangeVariant(TearVariant.ICE)

								local tearSprite = tear:GetSprite()
								--tearSprite:ReplaceSpritesheet(0,"gfx/Hexanow_tears.png")
								tearSprite:ReplaceSpritesheet(0,"gfx/ice_tears.png")
								tearSprite:LoadGraphics()
								tearSprite.Rotation = tear.Velocity:GetAngleDegrees()
							end
						end
					end
				end
				--[[
				if entity.Type == EntityType.ENTITY_EFFECT
				and entity.Variant == EffectVariant.WOMB_TELEPORT
				then
					local portalFound = false
					local wombPortalFound = false
					local voidPortalFound = false

					local posX = math.floor((entity.Position.X + 20)/40.0)*40
					local posY = math.floor((entity.Position.Y + 20)/40.0)*40
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
				]]
			end
		)
	end

	--[[
	CallForEveryEntity(
		function(entity)
			if entity.Type == entityTypeHexanowPortal then
				local posX = math.floor((entity.Position.X + 20)/40.0)*40
				local posY = math.floor((entity.Position.Y + 20)/40.0)*40
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
	]]--
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
				if IsHexanow(player)
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
					if IsHexanow(player)
					then
						--tear.Visible = false
						--Isaac.Spawn(1000, 59, 0, tear.Position, Vector(0, 0), player)
					end
				end
			end
		end
	)
	]]
	MaintainPortal(true)
end
HexanowMod:AddCallback(ModCallbacks.MC_POST_UPDATE, HexanowMod.Main.PostUpdate)

function HexanowMod.Main:PostUpdate()
end
HexanowMod:AddCallback(ModCallbacks.MC_POST_UPDATE, HexanowMod.Main.PostUpdate)

function HexanowMod.Main:PostPlayerUpdate(player)
	TickEventHexanow(player)
	TryCastFireHexanow(player)
end
HexanowMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, HexanowMod.Main.PostPlayerUpdate)

-- 渲染器，每一帧执行
function HexanowMod.Main:PostRender()
	if not Game():GetHUD():IsVisible() then
		return nil
	end

	local baseOffset = Vector(3,71)
	local offsetModSel = Vector(20 * Options.HUDOffset, 12 * Options.HUDOffset)

	if PlayerTypeExistInGame(playerTypeHexanow) then

		if PlayerTypeExistInGame(Isaac.GetPlayerTypeByName("Lairub")) then
			offsetModSel = offsetModSel + Vector(0, 40)
		end
		if PlayerTypeExistInGame(PlayerType.PLAYER_ISAAC_B)
		or PlayerTypeExistInGame(PlayerType.PLAYER_BLUEBABY_B)
		then
			offsetModSel = offsetModSel + Vector(0, 24)
		end

		--[[
		if EternalChargeForFree then
			EternalChargeSprite:SetFrame("Gold", 0)
		else
			EternalChargeSprite:SetFrame("Base", 0)
		end
		--EternalChargeSprite:SetOverlayRenderPriority(true)
		--Explorite.RenderResourceBox(EternalChargeSprite, Parse00(EternalCharges), baseOffset + offsetModStat)
		--EternalChargeSprite:Render(baseOffset + offsetModStat, Vector(0,0), Vector(0,0))
		--DrawSimNumbers(EternalCharges, baseOffset + Vector(12, 1) + offsetModStat)
		]]

		local sortNum = 0
		CallForEveryPlayer(
			function(player)
				if IsHexanow(player) then
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
HexanowMod:AddCallback(ModCallbacks.MC_POST_RENDER, HexanowMod.Main.PostRender)

--[[
-- 初始化随从
function HexanowMod.Main:FamiliarInit(_, fam)
	print("Initiating Hearts Blender")
end
HexanowMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, HexanowMod.Main.FamiliarInit, entityVariantHeartsBlender)
-- 更新随从行为
function HexanowMod.Main:FamiliarUpdate(_, fam)
	local roomEntities = Isaac.GetRoomEntities()

	local targetPos = nil
	local dis = nil

    local parent = fam.Player
	--[[if parent:ToPlayer() ~= nil then
		parent = fam.Parent:ToPlayer()
	end] ]

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
	] ]

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
HexanowMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, HexanowMod.Main.FamiliarUpdate, entityVariantHeartsBlender)
]]
-- 更新眼泪行为，在每一帧后执行
function HexanowMod.Main:PostTearUpdate(tear)
end
HexanowMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE , HexanowMod.Main.PostTearUpdate)