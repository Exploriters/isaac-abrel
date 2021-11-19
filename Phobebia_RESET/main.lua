local Phobebia_Reset = RegisterMod("Phobebia_Reset", 1);

--==STATIC==--
--Resources reference--
local costume_Phobebia = Isaac.GetCostumeIdByPath("gfx/characters/character_PhobebiaHair.anm2")
local playerType_Phobebia = Isaac.GetPlayerTypeByName("Phobebia")
local TheCatsGuide = Isaac.GetItemIdByName("Cat's Teeth")
local StatUpdateItem = Isaac.GetItemIdByName("Stat Trigger")
local PhobebiaSoulStoneID = Isaac.GetCardIdByName("Soul of Phobebia")
--Vars--
local SoulStoneTriggerDelay = 1

--==GAME==--
local gameInited = false
local phobebiaFlags = Explorite.NewExploriteFlags()
local phobebiaObjectives = Explorite.NewExploriteObjectives()

--==PLAYER==--

	--Hurts flight--
	--Soul Stone--
local PlayerVarsStruct = {
	FristDamageFrameInRoom = -1,
	UsedPhobebiaSoulStone = false,
	PhobebiaSoulStone_Damaged = false,
	PhobebiaSoulStone_KillCount = 0,
	TriggeredCount = 0,
	BaseFrameCount = 0,
	BaseGameFrameCount = 0
}
PlayerVarsStruct.__index = PlayerVarsStruct

function BuildPlayerVarsStruct()
    local cted = {}
    setmetatable(cted, PlayerVarsStruct)
    return cted
end

local PlayerVars = {}

function PlayerVars.Init()
	PlayerVars[1] = BuildPlayerVarsStruct()
	PlayerVars[2] = BuildPlayerVarsStruct()
	PlayerVars[3] = BuildPlayerVarsStruct()
	PlayerVars[4] = BuildPlayerVarsStruct()
end

function PlayerVars.Wipe()
	PlayerVars[1] = {}
	PlayerVars[2] = {}
	PlayerVars[3] = {}
	PlayerVars[4] = {}
end

function PlayerVars.CallForEvery(func)
	func(PlayerVars[1])
	func(PlayerVars[2])
	func(PlayerVars[3])
	func(PlayerVars[4])
end

PlayerVars.Init()


--==============--
--==LOCAL UTILITY==--

local function UpdateLastRoomVar()
	
end

local function RewindLastRoomVar()
	
end

--== Invincible the first damage in everyroom, then flight ==--
local function IsReducedDamage(player)
	local playerID = GetPlayerID(player)
	return PlayerVars[playerID].FristDamageFrameInRoom == -1
end

local function IsInvincible(player)
	local playerID = GetPlayerID(player)
	return PlayerVars[playerID].FristDamageFrameInRoom == -1 or Game():GetFrameCount() < (PlayerVars[playerID].FristDamageFrameInRoom + 15)
end

local function IsHurtsflightEnabled(player)
	return PlayerVars[GetPlayerID(player)].FristDamageFrameInRoom ~= -1
end

local function EndInvincible(player)
	local playerID = GetPlayerID(player)
	if PlayerVars[playerID].FristDamageFrameInRoom == -1 then
		PlayerVars[playerID].FristDamageFrameInRoom = Game():GetFrameCount()
		player:AnimateSad()
		player:RemoveCollectible(StatUpdateItem)
	end
end

local function ResetHurtsflight(player)
	local playerID = GetPlayerID(player)
	PlayerVars[playerID].FristDamageFrameInRoom = -1
	if player:GetSoulHearts() == 1 then
		player:AddBlackHearts(1)
	end
	player:RemoveCollectible(StatUpdateItem)
end

local function UpdateCostumes(player)
	if player:GetPlayerType() == playerType_Phobebia then
		-- TODO: flight costume
		if player.CanFly then
			player:TryRemoveNullCostume(costume_Phobebia)
			player:AddNullCostume(costume_Phobebia)
		else
			player:TryRemoveNullCostume(costume_Phobebia)
			player:AddNullCostume(costume_Phobebia)
		end
	else
		player:TryRemoveNullCostume(costume_Phobebia)
	end
end

--==============--
--==DATA EVENT==--

function phobebiaObjectives:Apply()
	phobebiaFlags:Wipe()
	phobebiaFlags:LoadFromString(self:Read("Flags", ""))
	
	UpdateLastRoomVar()
end

function phobebiaObjectives:Recieve()
	self:Write("Flags", phobebiaFlags:ToString())
end

-- 读取mod数据
local function LoadPhobebiaModData()
	local str = ""
	if Isaac.HasModData(Phobebia_Reset) then
		str = Isaac.LoadModData(Phobebia_Reset)
	end
	phobebiaObjectives:Wipe()
	phobebiaObjectives:LoadFromString(str)
	phobebiaObjectives:Apply()
end

-- 存储mod数据
local function SavePhobebiaModData()
	phobebiaObjectives:Recieve()
	local str = phobebiaObjectives:ToString(true)
	Isaac.SaveModData(Phobebia_Reset, str)
end

-- 在游戏被初始化后运行
function Phobebia_Reset:PostGameStarted(loadedFromSaves)	
	PlayerVars.Wipe()
	LoadPhobebiaModData()
	if not loadedFromSaves then -- 仅限新游戏
		PlayerVars.Wipe()
		PlayerVars.Init()
		SavePhobebiaModData()
	end
	gameInited = true
end
Phobebia_Reset:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Phobebia_Reset.PostGameStarted)

-- 在游戏退出前运行
function Phobebia_Reset:PreGameExit(shouldSave)
	if not shouldSave then
		PlayerVars.Wipe()
	end
	SavePhobebiaModData()
	PlayerVars.Wipe()
	gameInited = false
end
Phobebia_Reset:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Phobebia_Reset.PreGameExit)

--==============--
--==PROGRESS==--
function Phobebia_Reset:PostNewRoom()
	UpdateLastRoomVar()
	if gameInited then
		SavePhobebiaModData()
	end

	CallForEveryPlayer(ResetHurtsflight)
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_POST_NEW_ROOM, Phobebia_Reset.PostNewRoom)

function Phobebia_Reset:PostNewLevel()
	PlayerVars.CallForEvery(function(vars)
		vars.UsedPhobebiaSoulStone = false
		vars.PhobebiaSoulStone_Damaged = false
		vars.PhobebiaSoulStone_KillCount = 0
		vars.TriggeredCount = 0
		vars.BaseFrameCount = 0
		vars.BaseGameFrameCount = 0
	end)
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_POST_NEW_LEVEL, Phobebia_Reset.PostNewLevel)

--==============--
--==PLAYERS==--
function Phobebia_Reset:playerDamage(tookDamage, damage, damageFlags, damageSourceRef)
	local player = tookDamage:ToPlayer()
	if tookDamage ~= nil and player:GetPlayerType() == playerType_Phobebia then
		if IsReducedDamage(player) and damage > 0 then
			player:AddSoulHearts(math.max(0, damage-1))
			EndInvincible(player)
			--return false
		end
	end
end
Phobebia_Reset:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Phobebia_Reset.playerDamage, EntityType.ENTITY_PLAYER)

function Phobebia_Reset:Update()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	--==Costume==--
	if room:GetFrameCount() == 1 then
		CallForEveryPlayer(
			function(player)
				if player:GetPlayerType() == playerType_Phobebia and not player:IsDead() then
					if player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
						player:AddNullCostume(costume_Phobebia)
					else
						player:TryRemoveNullCostume(costume_Phobebia)
						player:AddNullCostume(costume_Phobebia)
					end
				end
			end
		)
	end

	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerType_Phobebia then
				player:AddSoulHearts(math.min(0,2-player:GetSoulHearts()))
				player:AddBoneHearts(-player:GetBoneHearts())
				player:AddHearts(-player:GetHearts())
				player:AddMaxHearts(-player:GetMaxHearts())
			end
		end
	)
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_POST_UPDATE, Phobebia_Reset.Update)

function Phobebia_Reset:PostPlayerInit(player)
	UpdateCostumes(player)
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, Phobebia_Reset.PostPlayerInit)

function Phobebia_Reset:EvaluateCache(player, cacheFlag)
	if player:GetPlayerType() == playerType_Phobebia then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + 0.2
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage - 1.1
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay - 3
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 1
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			--print "CAN YOU FUCKING HEAR ME!?"
			if IsHurtsflightEnabled(player) then
				--print "Fly!"
				player.CanFly = true
			end
			UpdateCostumes(player)
		elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
			local maybeFamiliars = Isaac.GetRoomEntities()
			for m = 1, #maybeFamiliars do
				local variant = maybeFamiliars[m].Variant
				if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
					player:TryRemoveNullCostume(costume_Phobebia)
					player:AddNullCostume(costume_Phobebia)
				end
			end
		end
	end
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, Phobebia_Reset.EvaluateCache)


-- Pickup collision
function Phobebia_Reset:PrePickupCollision(pickup, collider, low)
	local player = collider:ToPlayer()
	if player ~= nil
	and player:GetPlayerType() == playerType_Phobebia
	then

		if pickup.Variant == PickupVariant.PICKUP_HEART then
			if (
				pickup.SubType == HeartSubType.HEART_ETERNAL and player:GetEternalHearts() >= 1
			)
			or ( 
				(pickup.SubType == HeartSubType.HEART_HALF_SOUL
				or	pickup.SubType == HeartSubType.HEART_SOUL
				or	pickup.SubType == HeartSubType.HEART_BLACK
				or	pickup.SubType == HeartSubType.HEART_BLENDED
				) and player:GetSoulHearts() >= 2
			)
			or (
					pickup.SubType == HeartSubType.HEART_FULL
				or	pickup.SubType == HeartSubType.HEART_HALF
				or	pickup.SubType == HeartSubType.HEART_DOUBLEPACK
				or	pickup.SubType == HeartSubType.HEART_SCARED
				or	pickup.SubType == HeartSubType.HEART_BONE
			)
			or (
					false
				and	pickup.SubType == HeartSubType.HEART_GOLDEN
			)
			then
				if pickup:IsShopItem() then
					return true
				else
					return false
				end
			end
		end
		
		return nil
	end
end
Phobebia_Reset:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION , Phobebia_Reset.PrePickupCollision)

-- 时间回溯
function Phobebia_Reset:UsePortalTool(itemId, itemRng, player, useFlags, activeSlot, customVarData)
	if itemId == CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS
	then
		RewindLastRoomVar()
		UpdateLastRoomVar()
	end
end
Phobebia_Reset:AddCallback(ModCallbacks.MC_USE_ITEM, Phobebia_Reset.UsePortalTool)

--==SOUL STONE==--
--==============--
function Phobebia_Reset:UsePhobebiaSoulStone(cardId, player, useFlags)
	local level = Game():GetLevel()
	local room = Game():GetRoom()
	local playerID = GetPlayerID(player)
	local TotalHeartCount = player:GetMaxHearts() + player:GetBlackHearts() + player:GetSoulHearts()
	PlayerVars[playerID].BaseFrameCount = room:GetFrameCount()
	PlayerVars[playerID].BaseGameFrameCount = Game():GetFrameCount()
	PlayerVars[playerID].UsedPhobebiaSoulStone = true
	player:TakeDamage((math.ceil(TotalHeartCount/2)), 0, EntityRef(player), 0)
	print (TotalHeartCount)
	player:RemoveCollectible(StatUpdateItem)
	level:ShowMap()
end
Phobebia_Reset:AddCallback(ModCallbacks.MC_USE_CARD, Phobebia_Reset.UsePhobebiaSoulStone, PhobebiaSoulStoneID)

function Phobebia_Reset:PhobebiaSoulStoneFunction()
	local level = Game():GetLevel()
	local room = Game():GetRoom()
	local roomEntities = Isaac.GetRoomEntities()

	CallForEveryPlayer(
		function(player)
			local playerID = GetPlayerID(player)
			if UsedPhobebiaSoulStone == true then
				--Spawn--
				if (room:GetFrameCount() - PlayerVars[playerID].BaseFrameCount) % SoulStoneTriggerDelay == 0 then
					PlayerVars[playerID].TriggeredCount = PlayerVars[playerID].TriggeredCount + 1
					Isaac.Spawn(EntityType.ENTITY_EFFECT, 111, 0, Vector(player.Position.X, player.Position.Y - 25), Vector(math.random(-8, 8), math.random(-8, 8)), player)
				end
				for i, Effect in pairs(roomEntities) do
					if Effect.Type == EntityType.ENTITY_EFFECT and Effect.Variant == 111 then
						Effect:SetColor(Color(1, 1, 1, 0.4, 0.5, 0.2, 0.2), 0, 999, true, true)
					end
				end
			end

		end
	)
end
Phobebia_Reset:AddCallback(ModCallbacks.MC_POST_UPDATE, Phobebia_Reset.PhobebiaSoulStoneFunction)

function Phobebia_Reset:SoulStoneNPCDeath()
	CallForEveryPlayer(
		function(player)
			local playerID = GetPlayerID(player)
			if PlayerVars[playerID].UsedPhobebiaSoulStone == true then
				PlayerVars[playerID].PhobebiaSoulStone_KillCount = PlayerVars[playerID].PhobebiaSoulStone_KillCount + 1
				player:RemoveCollectible(StatUpdateItem)
			end
		end
	)
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_POST_NPC_DEATH, Phobebia_Reset.SoulStoneNPCDeath)

function Phobebia_Reset:SoulStoneEvaluateCache(player, cacheFlag)
	local playerID = GetPlayerID(player)
	if PlayerVars[playerID].UsedPhobebiaSoulStone == true then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 0.5 -- + (PlayerVars[playerID].PhobebiaSoulStone_KillCount * 0.01)
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay - 3
		end
	end
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, Phobebia_Reset.SoulStoneEvaluateCache)
