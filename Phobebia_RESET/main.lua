local Phobebia_Reset = RegisterMod("Phobebia_Reset", 1);

--==LOCAL==--
--About Player and Costume--
local costume_Phobebia = Isaac.GetCostumeIdByPath("gfx/characters/character_PhobebiaHair.anm2")
local playerType_Phobebia = Isaac.GetPlayerTypeByName("Phobebia")
local InvincibleEnd = false
local Invincible = true
local InvincibleFrame = 0
local InvincibleAnimated = false
--Items--
local ItemID = {
TheCatsGuide = Isaac.GetItemIdByName("Cat's Teeth")
}
--Stat Trigger--
local StatUpdateItem = Isaac.GetItemIdByName("Stat Trigger")
--Soul Stone--
local PhobebiaSoulStoneID = Isaac.GetCardIdByName("Soul of Phobebia")
local UsedPhobebiaSoulStone = false
local PhobebiaSoulStone_Damaged = false
local PhobebiaSoulStone_KillCount = 0
local TriggeredCount = 0
local TriggerDelay = 1
local BaseFrameCount = 0
local BaseGameFrameCount = 0
--==============--

--==PLAYERS==--
--==============--
function Phobebia_Reset:playerDamage(tookDamage, damage, damageFlags, damageSourceRef)
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == playerType_Phobebia then
		if Invincible == true then
			if InvincibleAnimated == false then
				player:AnimateSad()
				InvincibleAnimated = true
			end
			InvincibleEnd = true
			InvincibleFrame = Game():GetFrameCount()
			player:RemoveCollectible(StatUpdateItem)
			return false
		end
	end
end
Phobebia_Reset:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Phobebia_Reset.playerDamage, EntityType.ENTITY_PLAYER)

function Phobebia_Reset:Update(player)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	--==Costume==--
	if room:GetFrameCount() == 1 and player:GetPlayerType() == playerType_Phobebia and not player:IsDead() then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
			player:AddNullCostume(costume_Phobebia)
		else
			player:TryRemoveNullCostume(costume_Phobebia)
			player:AddNullCostume(costume_Phobebia)
		end
	end
	--== Invincible the first damage in everyroom ==--
	if InvincibleEnd == true then
		if Game():GetFrameCount() == (InvincibleFrame + 15) then
			Invincible = false
			player:RemoveCollectible(StatUpdateItem)
		end
	end
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_POST_UPDATE, Phobebia_Reset.Update)

function Phobebia_Reset:PostPlayerInit(player)
	if player:GetPlayerType() == playerType_Phobebia then
		player:TryRemoveNullCostume(costume_Phobebia)
		player:AddNullCostume(costume_Phobebia)
		costumeEquipped = true
	else
		player:TryRemoveNullCostume(costume_Phobebia)
		costumeEquipped = false
	end
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
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
				player:TryRemoveNullCostume(costume_Phobebia)
				player:AddNullCostume(costume_Phobebia)
			end
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
--[[			print "CAN YOU FUCKING HEAR ME!?"
			if Invincible == false then
				print "Fly!"
				player.CanFly = true
			end]]--
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
				player:TryRemoveNullCostume(costume_Phobebia)
				player:AddNullCostume(costume_Phobebia)
			end
			player:TryRemoveNullCostume(costume_Phobebia)
			player:AddNullCostume(costume_Phobebia)
--			player.CanFly = true
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

--==SOUL STONE==--
--==============--
function Phobebia_Reset:UsePhobebiaSoulStone(cardId, player, useFlags)
	local level = Game():GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local TotalHeartCount = player:GetMaxHearts() + player:GetBlackHearts() + player:GetSoulHearts()
	BaseFrameCount = room:GetFrameCount()
	BaseGameFrameCount = Game():GetFrameCount()
	UsedPhobebiaSoulStone = true
	player:TakeDamage((math.ceil(TotalHeartCount/2)), 0, EntityRef(player), 0)
	print (TotalHeartCount)
	player:RemoveCollectible(StatUpdateItem)
	level:ShowMap()
end
Phobebia_Reset:AddCallback(ModCallbacks.MC_USE_CARD, Phobebia_Reset.UsePhobebiaSoulStone, PhobebiaSoulStoneID)

function Phobebia_Reset:PhobebiaSoulStoneFunction()
	local level = Game():GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	local TotalHeartCount = player:GetMaxHearts()+ player:GetBlackHearts() + player:GetSoulHearts()
	if UsedPhobebiaSoulStone == true then
		--Spawn--
		if (room:GetFrameCount() - BaseFrameCount) % TriggerDelay == 0 then
			TriggeredCount = TriggeredCount + 1
			Isaac.Spawn(EntityType.ENTITY_EFFECT, 111, 0, Vector(player.Position.X, player.Position.Y - 25), Vector(math.random(-8, 8), math.random(-8, 8)), player)
		end
		for i, Effect in pairs(roomEntities) do
			if Effect.Type == EntityType.ENTITY_EFFECT and Effect.Variant == 111 then
				Effect:SetColor(Color(1, 1, 1, 0.4, 0.5, 0.2, 0.2), 0, 999, true, true)
			end
		end
	end
end
Phobebia_Reset:AddCallback(ModCallbacks.MC_POST_UPDATE, Phobebia_Reset.PhobebiaSoulStoneFunction)

function Phobebia_Reset:SoulStoneNPCDeath()
	PhobebiaSoulStone_KillCount = PhobebiaSoulStone_KillCount + 1
	local player = Isaac.GetPlayer(0)
	player:RemoveCollectible(StatUpdateItem)
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_POST_NPC_DEATH, Phobebia_Reset.SoulStoneNPCDeath)

function Phobebia_Reset:SoulStoneEvaluateCache(player, cacheFlag)
	local player = Isaac.GetPlayer(0)
	if UsedPhobebiaSoulStone == true then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 0.5 + (PhobebiaSoulStone_KillCount * 0.01)
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay - 3
		end
	end
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, Phobebia_Reset.SoulStoneEvaluateCache)

function Phobebia_Reset:PostNewRoom()
	InvincibleEnd = false
	Invincible = true
	InvincibleFrame = 0
	InvincibleAnimated = false
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_POST_NEW_ROOM, Phobebia_Reset.PostNewRoom)

function Phobebia_Reset:PostNewLevel()
	local player = Isaac.GetPlayer(0)
	UsedPhobebiaSoulStone = false
	PhobebiaSoulStone_Damaged = false
	PhobebiaSoulStone_KillCount = 0
	TriggeredCount = 0
	TriggerDelay = 1
	BaseFrameCount = 0
	BaseGameFrameCount = 0
	InvincibleEnd = false
	Invincible = true
	InvincibleFrame = 0
	InvincibleAnimated = false
	player:RemoveCollectible(StatUpdateItem)
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_POST_NEW_LEVEL, Phobebia_Reset.PostNewLevel)

function Phobebia_Reset:PostNewGame()
	local player = Isaac.GetPlayer(0)
	UsedPhobebiaSoulStone = false
	PhobebiaSoulStone_Damaged = false
	PhobebiaSoulStone_KillCount = 0
	TriggeredCount = 0
	TriggerDelay = 1
	BaseFrameCount = 0
	BaseGameFrameCount = 0
	InvincibleEnd = false
	Invincible = true
	InvincibleFrame = 0
	InvincibleAnimated = false
	player:RemoveCollectible(StatUpdateItem)
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_POST_GAME_STARTED, Phobebia_Reset.PostNewGame)