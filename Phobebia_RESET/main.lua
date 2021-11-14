local Phobebia_Reset = RegisterMod("Phobebia_Reset", 1);

local DamageStatUpdateItem = Isaac.GetItemIdByName( "Damage Stat Trigger" )
--Soul Stone--
local PhobebiaSoulStoneID = Isaac.GetCardIdByName("Soul of Phobebia")
local UsedPhobebiaSoulStone = false
local PhobebiaSoulStone_Damaged = false
local PhobebiaSoulStone_KillCount = 0
local TriggeredCount = 0
local TriggerDelay = 1
local BaseFrameCount = 0
local BaseGameFrameCount = 0

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
	player:RemoveCollectible(DamageStatUpdateItem)
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
	player:RemoveCollectible(DamageStatUpdateItem)
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

function Phobebia_Reset:PostNewLevel()
	local player = Isaac.GetPlayer(0)
	UsedPhobebiaSoulStone = false
	PhobebiaSoulStone_Damaged = false
	PhobebiaSoulStone_KillCount = 0
	TriggeredCount = 0
	TriggerDelay = 1
	BaseFrameCount = 0
	BaseGameFrameCount = 0
	player:RemoveCollectible(DamageStatUpdateItem)
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
	player:RemoveCollectible(DamageStatUpdateItem)
end
Phobebia_Reset:AddCallback( ModCallbacks.MC_POST_GAME_STARTED, Phobebia_Reset.PostNewGame)