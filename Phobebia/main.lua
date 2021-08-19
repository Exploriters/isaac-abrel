local phobebia = RegisterMod("Phobebia", 1);

local itemPool = Game():GetItemPool()
--==Phobebia==--
local costume_Phobebia = Isaac.GetCostumeIdByPath("gfx/characters/character_PhobebiaHair.anm2")
local playerType_Phobebia = Isaac.GetPlayerTypeByName("Phobebia")
local phobebiaFateCostume = Isaac.GetCostumeIdByPath("gfx/characters/Phobebia_fate.anm2")
--==PhobebiaII==--
local costume_PhobebiaII = Isaac.GetCostumeIdByPath("gfx/characters/character_PhobebiaHairII.anm2")
--local playerType_PhobebiaII = Isaac.GetPlayerTypeByName("PhobebiaII")
local phobebiaIIFateCostume = Isaac.GetCostumeIdByPath("gfx/characters/PhobebiaII_fate.anm2")
--==Why.. Ok this is Habit.. And more collectible costume==--
local phobebiaHabitCostume = Isaac.GetCostumeIdByPath("gfx/characters/Phobebia_habit.anm2")
local phobebiaAnemicCostume = Isaac.GetCostumeIdByPath("gfx/characters/Phobebia_anemic.anm2")

--==Tainted Phobebia==--
local costume_Tainted_Phobebia = Isaac.GetCostumeIdByPath("gfx/characters/character_Tainted_PhobebiaHair.anm2")
local playerType_Tainted_Phobebia = Isaac.GetPlayerTypeByName("Tainted Phobebia", true)

--==The Cat==--
local costume_TheCat = Isaac.GetCostumeIdByPath("gfx/characters/TheCat.anm2")
local costume_TheCat_Head = Isaac.GetCostumeIdByPath("gfx/characters/TheCat_Head.anm2")

--==Items==--
local ItemID = {
TheCatsGuide = Isaac.GetItemIdByName("The Cat's Guide"),
TheCatsSoul = Isaac.GetItemIdByName("The Cat's Soul"),
TheCatsMind = Isaac.GetItemIdByName("The Cat's Mind"),
JudasShadow = Isaac.GetItemIdByName("Judas' Shadow2"),
PhobebiasBloodBandage = Isaac.GetItemIdByName("Phobebia's Blood Bandage"),
PhobebiasBloodBandageII = Isaac.GetItemIdByName("Phobebia's Blood Bandage II")
}

--==Animate!Animate!!==--
local TCAnimateSadOnce = false -- When Tainted Phobebia become The Cat

--==...And More variable==--
local TCRemoveTheCatsMindOnce = false
local TCAnimateSadTwice = true

--== Update Tainted Phobebia's Cache==--
local PhobebiaStatUpdateItem = Isaac.GetItemIdByName( "Phobebia Stat Trigger" )

local Deads = 0

--==For Judas==--
local playerType_Judas = Isaac.GetPlayerTypeByName("Judas")
local playerType_BlackJudas = Isaac.GetPlayerTypeByName("Black Judas")

local PhobebiasBloodBandage_Costume = Isaac.GetCostumeIdByPath("gfx/characters/PhobebiasBloodBandage.anm2")
local PhobebiasBloodBandageII_Costume = Isaac.GetCostumeIdByPath("gfx/characters/PhobebiasBloodBandageII.anm2")

function phobebia:Update()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerType_Phobebia then
				--==For Phobebia==--
				if room:GetFrameCount() == 1 and not player:IsDead() then
					if player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
						player:TryRemoveNullCostume(costume_Phobebia)
						player:AddNullCostume(costume_Phobebia)
						if player:HasCollectible(CollectibleType.COLLECTIBLE_FATE) then
							player:TryRemoveNullCostume(phobebiaFateCostume)
							player:AddNullCostume(phobebiaFateCostume)
						end
						if player:HasCollectible(CollectibleType.COLLECTIBLE_HABIT) then
							player:TryRemoveNullCostume(phobebiaHabitCostume)
							player:AddNullCostume(phobebiaHabitCostume)
						end
						if player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC) then
							player:TryRemoveNullCostume(phobebiaAnemicCostume)
							player:AddNullCostume(phobebiaAnemicCostume)
						end
					else
						player:TryRemoveNullCostume(costume_Phobebia)
						player:AddNullCostume(costume_Phobebia)
						if player:HasCollectible(CollectibleType.COLLECTIBLE_FATE) then
							player:TryRemoveNullCostume(phobebiaFateCostume)
							player:AddNullCostume(phobebiaFateCostume)
						end
						if player:HasCollectible(CollectibleType.COLLECTIBLE_HABIT) then
							player:TryRemoveNullCostume(phobebiaHabitCostume)
							player:AddNullCostume(phobebiaHabitCostume)
						end
						if player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC) then
							player:TryRemoveNullCostume(phobebiaAnemicCostume)
							player:AddNullCostume(phobebiaAnemicCostume)
						end
					end
				end
				
				--==The Cat's Guide==--
				if player:HasCollectible(ItemID.TheCatsGuide, true) then
					if player:IsDead() then
						player:Revive()
						player:RemoveCollectible(ItemID.TheCatsGuide)
						player:AddCollectible(ItemID.TheCatsSoul, 0, true)
						player:AddCollectible(542, 0, true)
						player:AddCollectible(542, 0, true)
					end
				end
				
				--==The Cat's Soul(PhobebiaII)==--
				if room:GetFrameCount() == 1 and player:HasCollectible(ItemID.TheCatsSoul, true) and not player:IsDead() then
					if player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
						player:TryRemoveNullCostume(costume_PhobebiaII)
						player:AddNullCostume(costume_PhobebiaII)
						if player:HasCollectible(CollectibleType.COLLECTIBLE_FATE) then
							player:TryRemoveNullCostume(phobebiaIIFateCostume)
							player:AddNullCostume(phobebiaIIFateCostume)
						end
					else
						player:TryRemoveNullCostume(costume_PhobebiaII)
						player:AddNullCostume(costume_PhobebiaII)
						if player:HasCollectible(CollectibleType.COLLECTIBLE_FATE) then
							player:TryRemoveNullCostume(phobebiaIIFateCostume)
							player:AddNullCostume(phobebiaIIFateCostume)
						end
					end
				end
			--==Angel Room==--
				if not player:HasCollectible(ItemID.TheCatsSoul, true) then
					level:AddAngelRoomChance(100)
				else
					level:DisableDevilRoom()
					level:AddAngelRoomChance(0)
				end
			end
		end
	)
	
end
phobebia:AddCallback( ModCallbacks.MC_POST_UPDATE, phobebia.Update)

function phobebia:PostPlayerInit(player)
	--==for Phobebia==--
	if player:GetPlayerType() == playerType_Phobebia and not player:HasCollectible(ItemID.TheCatsSoul, true) then
		player:TryRemoveNullCostume(costume_Phobebia)
		player:AddNullCostume(costume_Phobebia)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_FATE) then
			player:TryRemoveNullCostume(phobebiaFateCostume)
			player:AddNullCostume(phobebiaFateCostume)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_HABIT) then
			player:TryRemoveNullCostume(phobebiaHabitCostume)
			player:AddNullCostume(phobebiaHabitCostume)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC) then
			player:TryRemoveNullCostume(phobebiaAnemicCostume)
			player:AddNullCostume(phobebiaAnemicCostume)
		end
		costumeEquipped = true
	else
		player:TryRemoveNullCostume(costume_Phobebia)
		player:TryRemoveNullCostume(costume_Phobebia)
		player:TryRemoveNullCostume(phobebiaFateCostume)
		player:TryRemoveNullCostume(phobebiaHabitCostume)
		player:TryRemoveNullCostume(phobebiaAnemicCostume)
		costumeEquipped = false
	end
	--==The Cat's Soul(PhobebiaII)==--
	if player:GetPlayerType() == playerType_Phobebia and player:HasCollectible(ItemID.TheCatsSoul, true) then
		player:TryRemoveNullCostume(costume_PhobebiaII)
		player:AddNullCostume(costume_PhobebiaII)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_FATE) then
			player:TryRemoveNullCostume(phobebiaIIFateCostume)
			player:AddNullCostume(phobebiaIIFateCostume)
		end
		costumeEquipped = true
	else
		player:TryRemoveNullCostume(costume_PhobebiaII)
		player:TryRemoveNullCostume(costume_PhobebiaII)
		player:TryRemoveNullCostume(phobebiaIIFateCostume)
		costumeEquipped = false
	end
end
phobebia:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, phobebia.PostPlayerInit)

function phobebia:EvaluateCache(player, cacheFlag, tear)
	--==For Phobebia==--
	if player:GetPlayerType() == playerType_Phobebia then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + 0.2
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage - .6
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 1
		elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed + 0.5
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay - 3
		elseif cacheFlag == CacheFlag.CACHE_TEARS then
			player.Tears = player.Tears - 5
		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
			if player:HasCollectible(ItemID.TheCatsSoul) then
				player.TearFlags = player.TearFlags | 0
			else
				player.TearFlags = player.TearFlags | 1 << 13
			end
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
				player:TryRemoveNullCostume(costume_Phobebia)
				player:AddNullCostume(costume_Phobebia)
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_FATE) then
				player:TryRemoveNullCostume(phobebiaFateCostume)
				player:AddNullCostume(phobebiaFateCostume)
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_HABIT) then
				player:TryRemoveNullCostume(phobebiaHabitCostume)
				player:AddNullCostume(phobebiaHabitCostume)
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC) then
				player:TryRemoveNullCostume(phobebiaAnemicCostume)
				player:AddNullCostume(phobebiaAnemicCostume)
			end
		elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
			local maybeFamiliars = Isaac.GetRoomEntities()
			for m = 1, #maybeFamiliars do
				local variant = maybeFamiliars[m].Variant
				if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
					player:TryRemoveNullCostume(costume_Phobebia)
					player:AddNullCostume(costume_Phobebia)
					if player:HasCollectible(CollectibleType.COLLECTIBLE_HABIT) then
						player:TryRemoveNullCostume(phobebiaHabitCostume)
						player:AddNullCostume(phobebiaHabitCostume)
					end
					if player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC) then
						player:TryRemoveNullCostume(phobebiaAnemicCostume)
						player:AddNullCostume(phobebiaAnemicCostume)
					end
				else
					player:TryRemoveNullCostume(costume_Phobebia)
					player:AddNullCostume(costume_Phobebia)
					if player:HasCollectible(CollectibleType.COLLECTIBLE_HABIT) then
						player:TryRemoveNullCostume(phobebiaHabitCostume)
						player:AddNullCostume(phobebiaHabitCostume)
					end
					if player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC) then
						player:TryRemoveNullCostume(phobebiaAnemicCostume)
						player:AddNullCostume(phobebiaAnemicCostume)
					end
				end
			end
		end
	end
	--==The Cat's Soul(PhobebiaII)==--
	if player:GetPlayerType() == playerType_Phobebia and player:HasCollectible(ItemID.TheCatsSoul, true) then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + 0.2
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 1.6
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 1
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
				player:TryRemoveNullCostume(costume_PhobebiaII)
				player:AddNullCostume(costume_PhobebiaII)
			elseif player:HasCollectible(CollectibleType.COLLECTIBLE_FATE) then
				player:TryRemoveNullCostume(phobebiaIIFateCostume)
				player:AddNullCostume(phobebiaIIFateCostume)
			end
		elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
			local maybeFamiliars = Isaac.GetRoomEntities()
			for m = 1, #maybeFamiliars do
				local variant = maybeFamiliars[m].Variant
				if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
					player:TryRemoveNullCostume(costume_PhobebiaII)
					player:AddNullCostume(costume_PhobebiaII)
					if player:HasCollectible(CollectibleType.COLLECTIBLE_FATE) then
						player:TryRemoveNullCostume(phobebiaIIFateCostume)
						player:AddNullCostume(phobebiaIIFateCostume)
					end
				else
					player:TryRemoveNullCostume(costume_PhobebiaII)
					player:AddNullCostume(costume_PhobebiaII)
					if player:HasCollectible(CollectibleType.COLLECTIBLE_FATE) then
						player:TryRemoveNullCostume(phobebiaIIFateCostume)
						player:AddNullCostume(phobebiaIIFateCostume)
					end
				end
			end
		end
	end
end
phobebia:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, phobebia.EvaluateCache )

function phobebia:PostUpdate()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerType_Phobebia then
				
				if not player:IsDead() then
				end
			
			
				if room:GetBackdropType() ~= 58 and room:GetBackdropType() ~= 59 then
					if not player:HasCollectible(ItemID.TheCatsGuide, true) and not player:HasCollectible(ItemID.TheCatsSoul, true) then
						player:AddCollectible(ItemID.TheCatsGuide, 0, true)
					end
					if not player:HasCollectible(179, true) then
						player:AddCollectible(179, 0, true)
					end
					if not player:HasCollectible(313, true) then
						player:AddCollectible(313, 0, true)
					end
			--[[		if not player:HasCollectible(536, true) then
						player:AddCollectible(536, 0, true)
					end]]--
					if not player:HasCollectible(534, true) then
						player:AddCollectible(534, 0, true)
					end
				end
			end
		end
	)
end
phobebia:AddCallback(ModCallbacks.MC_POST_UPDATE, phobebia.PostUpdate)

function phobebia:PostUpdateProcessTears()
	local roomEntities = Isaac.GetRoomEntities()
	
	CallForEveryEntity(
		function(entity)
			local tear = entity:ToTear()
			if tear ~= nil then
				if tear.Parent ~= nil
				and tear.Parent.Type == EntityType.ENTITY_PLAYER
				then
					local player = tear.Parent:ToPlayer()
					if player:GetPlayerType() == playerType_Phobebia
					or player:GetPlayerType() == playerType_Tainted_Phobebia 
					then
						if tear.Variant ~= TearVariant.BLOOD then
							local tearSprite = tear:GetSprite()
							tear:ChangeVariant(TearVariant.BLOOD)
							tearSprite:ReplaceSpritesheet(0,"gfx/Phobebia_tears.png")
							tearSprite:LoadGraphics()
							tearSprite.Rotation = entity.Velocity:GetAngleDegrees()
						end
					end
				end
			end
		end
	)
end
phobebia:AddCallback(ModCallbacks.MC_POST_UPDATE, phobebia.PostUpdateProcessTears)

function phobebia:PostNewLevel()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerType_Phobebia then
				if level:GetStage() == (LevelStage.STAGE1_2) or level:GetStage() == (LevelStage.STAGE2_2) or level:GetStage() == (LevelStage.STAGE3_2) or level:GetStage() == (LevelStage.STAGE4_2) then
					if not player:HasCollectible(536, true) then
						player:AddCollectible(536, 0, true)
					end
					if not player:HasCollectible(534, true) then
						player:AddCollectible(534, 0, true)
					end
		--[[		elseif level:GetCurses() == (LevelCurse.CURSE_OF_LABYRINTH) and level:GetStage() == (LevelStage.STAGE1_1) or level:GetStage() == (LevelStage.STAGE2_1) or level:GetStage() == (LevelStage.STAGE3_1) or level:GetStage() == (LevelStage.STAGE4_1) then
					if not player:HasCollectible(536, true) then
						player:AddCollectible(536, 0, true)
					end
					if not player:HasCollectible(534, true) then
						player:AddCollectible(534, 0, true)
					end]]--
				else
					player:RemoveCollectible(536)
					player:RemoveCollectible(534)
				end
			end
		end
	)
end
phobebia:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, phobebia.PostNewLevel)

--==Tainted Phobebia==--

function phobebia:TaintedUpdate()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerType_Tainted_Phobebia then
				if room:GetFrameCount() == 1 and not player:IsDead() then
					if player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
						player:AddNullCostume(costume_Tainted_Phobebia)
						if player:HasCollectible(CollectibleType.COLLECTIBLE_HABIT) then
							player:TryRemoveNullCostume(phobebiaHabitCostume)
							player:AddNullCostume(phobebiaHabitCostume)
						end
						if player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC) then
							player:TryRemoveNullCostume(phobebiaAnemicCostume)
							player:AddNullCostume(phobebiaAnemicCostume)
						end
						if player:HasCollectible(ItemID.TheCatsMind) then
							player:TryRemoveNullCostume(costume_TheCat)
							player:AddNullCostume(costume_TheCat)
						end
					else
						player:TryRemoveNullCostume(costume_Tainted_Phobebia)
						player:AddNullCostume(costume_Tainted_Phobebia)
						if player:HasCollectible(CollectibleType.COLLECTIBLE_HABIT) then
							player:TryRemoveNullCostume(phobebiaHabitCostume)
							player:AddNullCostume(phobebiaHabitCostume)
						end
						if player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC) then
							player:TryRemoveNullCostume(phobebiaAnemicCostume)
							player:AddNullCostume(phobebiaAnemicCostume)
						end
						if player:HasCollectible(ItemID.TheCatsMind) then
							player:TryRemoveNullCostume(costume_TheCat)
							player:AddNullCostume(costume_TheCat)
							player:TryRemoveNullCostume(costume_TheCat_Head)
							player:AddNullCostume(costume_TheCat_Head)
							player:TryRemoveCollectibleCostume(118)
						end
					end
				end
			
		--== About Tainted Phobebia --> The Cat==--
				if player:GetSoulHearts() <= 1 then
					if room:GetBackdropType() ~= 58 and room:GetBackdropType() ~= 59 then
						if not player:HasCollectible(ItemID.TheCatsMind, true) then
							player:AddCollectible(ItemID.TheCatsMind, 0, true)
							player:AddCollectible(118, 0, true)
						elseif not player:HasCollectible(118, true) then
							player:AddCollectible(118, 0, true)
						end
						if TCAnimateSadOnce == false then
							player:AnimateSad()
							TCAnimateSadOnce = true
							TCAnimateSadTwice = false
						end
					end
				else
					if player:HasCollectible(ItemID.TheCatsMind, true) then
						player:RemoveCollectible(ItemID.TheCatsMind)
						TCRemoveTheCatsMindOnce = true
					end
					if TCRemoveTheCatsMindOnce == true then
						player:TryRemoveNullCostume(costume_TheCat)
						player:TryRemoveNullCostume(costume_TheCat_Head)
						if  player:HasCollectible(118, true) then
							player:RemoveCollectible(118)
							TCRemoveTheCatsMindOnce = false
						end
						if TCAnimateSadTwice == false then
							player:AnimateSad()
							TCAnimateSadTwice = true
						end
						TCAnimateSadOnce = false
					end
				end
			end
		end
	)
end
phobebia:AddCallback( ModCallbacks.MC_POST_UPDATE, phobebia.TaintedUpdate)

function phobebia:TaintedPostUpdate()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
					
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerType_Tainted_Phobebia then
				if not player:IsDead() then
				end
				if room:GetBackdropType() ~= 58 and room:GetBackdropType() ~= 59 then
					if player:GetPlayerType() == playerType_Tainted_Phobebia then
						if not player:HasCollectible(313, true) then
							player:AddCollectible(313, 0, true)
						end
					end
				end
			end
		end
	)
	
end
phobebia:AddCallback( ModCallbacks.MC_POST_UPDATE, phobebia.TaintedPostUpdate)

function phobebia:TaintedPostPlayerInit(player)
	if player:GetPlayerType() == playerType_Tainted_Phobebia then
		player:TryRemoveNullCostume(costume_Tainted_Phobebia)
		player:AddNullCostume(costume_Tainted_Phobebia)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_HABIT) then
			player:TryRemoveNullCostume(phobebiaHabitCostume)
			player:AddNullCostume(phobebiaHabitCostume)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC) then
			player:TryRemoveNullCostume(phobebiaAnemicCostume)
			player:AddNullCostume(phobebiaAnemicCostume)
		end
		if player:HasCollectible(ItemID.TheCatsMind) then
			player:TryRemoveNullCostume(costume_TheCat)
			player:AddNullCostume(costume_TheCat)
			player:TryRemoveNullCostume(costume_TheCat_Head)
			player:AddNullCostume(costume_TheCat_Head)
			player:TryRemoveCollectibleCostume(118)
		else
			player:TryRemoveNullCostume(costume_TheCat)
			player:TryRemoveNullCostume(costume_TheCat_Head)
		end
		costumeEquipped = true
	else
		player:TryRemoveNullCostume(costume_Tainted_Phobebia)
		player:TryRemoveNullCostume(costume_Tainted_Phobebia)
		player:TryRemoveNullCostume(phobebiaHabitCostume)
		player:TryRemoveNullCostume(phobebiaAnemicCostume)
		player:TryRemoveNullCostume(costume_TheCat)
		player:TryRemoveNullCostume(costume_TheCat_Head)
		costumeEquipped = false
	end
end
phobebia:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, phobebia.TaintedPostPlayerInit)

function phobebia:TaintedNPCDeath()
	Deads = Deads + 1
	
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerType_Tainted_Phobebia then
				player:RemoveCollectible(PhobebiaStatUpdateItem)
				
				--  NO MORE DEMANDED
				-- player:AddCollectible(PhobebiaStatUpdateItem)
				-- UpdateCache(player)
			end
		end
	)
end
phobebia:AddCallback( ModCallbacks.MC_POST_NPC_DEATH, phobebia.TaintedNPCDeath)

function phobebia:InitDeads()
	Deads = 0
	
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerType_Tainted_Phobebia then
				player:RemoveCollectible(PhobebiaStatUpdateItem)
			end
		end
	)
end
phobebia:AddCallback( ModCallbacks.MC_POST_GAME_STARTED, phobebia.InitDeads)

function phobebia:TaintedEvaluateCache(player, cacheFlag)
	if player:GetPlayerType() == playerType_Tainted_Phobebia then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + 0.2
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage - 1
			if Deads >= 0 then
				player.Damage = Deads * 0.03 + player.Damage
			end
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 6
		elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed + 0.5
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay - 3
		elseif cacheFlag == CacheFlag.CACHE_TEARS then
			player.Tears = player.Tears - 5
		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | 1 << 4
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
				player:TryRemoveNullCostume(costume_Tainted_Phobebia)
				player:AddNullCostume(costume_Tainted_Phobebia)
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_HABIT) then
				player:TryRemoveNullCostume(phobebiaHabitCostume)
				player:AddNullCostume(phobebiaHabitCostume)
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC) then
				player:TryRemoveNullCostume(phobebiaAnemicCostume)
				player:AddNullCostume(phobebiaAnemicCostume)
			end
			if player:HasCollectible(ItemID.TheCatsMind) then
				player:TryRemoveNullCostume(costume_TheCat)
				player:AddNullCostume(costume_TheCat)
				player:TryRemoveNullCostume(costume_TheCat_Head)
				player:AddNullCostume(costume_TheCat_Head)
				player:TryRemoveCollectibleCostume(118)
			end
		elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
			local maybeFamiliars = Isaac.GetRoomEntities()
			for m = 1, #maybeFamiliars do
				local variant = maybeFamiliars[m].Variant
				if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
					player:TryRemoveNullCostume(costume_Tainted_Phobebia)
					player:AddNullCostume(costume_Tainted_Phobebia)
					if player:HasCollectible(CollectibleType.COLLECTIBLE_HABIT) then
						player:TryRemoveNullCostume(phobebiaHabitCostume)
						player:AddNullCostume(phobebiaHabitCostume)
					end
					if player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC) then
						player:TryRemoveNullCostume(phobebiaAnemicCostume)
						player:AddNullCostume(phobebiaAnemicCostume)
					end
					if player:HasCollectible(ItemID.TheCatsMind) then
						player:TryRemoveNullCostume(costume_TheCat)
						player:AddNullCostume(costume_TheCat)
						player:TryRemoveNullCostume(costume_TheCat_Head)
						player:AddNullCostume(costume_TheCat_Head)
						player:TryRemoveCollectibleCostume(118)
					end
				else
					player:TryRemoveNullCostume(costume_Tainted_Phobebia)
					player:AddNullCostume(costume_Tainted_Phobebia)
					if player:HasCollectible(CollectibleType.COLLECTIBLE_HABIT) then
						player:TryRemoveNullCostume(phobebiaHabitCostume)
						player:AddNullCostume(phobebiaHabitCostume)
					end
					if player:HasCollectible(CollectibleType.COLLECTIBLE_ANEMIC) then
						player:TryRemoveNullCostume(phobebiaAnemicCostume)
						player:AddNullCostume(phobebiaAnemicCostume)
					end
					if player:HasCollectible(ItemID.TheCatsMind) then
						player:TryRemoveNullCostume(costume_TheCat)
						player:AddNullCostume(costume_TheCat)
						player:TryRemoveNullCostume(costume_TheCat_Head)
						player:AddNullCostume(costume_TheCat_Head)
						player:TryRemoveCollectibleCostume(118)
					end
				end
			end
		end
		--==The Cat==--
		if player:HasCollectible(ItemID.TheCatsMind) then
			if cacheFlag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed + 0.3
			elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage + 2
			elseif cacheFlag == CacheFlag.CACHE_FLYING then
				player.CanFly = true
			elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = player.MaxFireDelay - 3
			end
		end
	end
end
phobebia:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, phobebia.TaintedEvaluateCache)

function phobebia:TaintedPostNewLevel()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerType_Tainted_Phobebia and not player:IsDead() then
				Deads = 0
				player:RemoveCollectible(PhobebiaStatUpdateItem)
			end
		end
	)
end
phobebia:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, phobebia.TaintedPostNewLevel)

--==Universal==--

function phobebia:UniversalUpdate()
	--==Universal==--
	local HasRedHeartCount = 2
	local HasBoneHearts = 1
	local HasEternalHearts = 1
	local MoreBlackHeartsCount = 1
	--==Phobebia==--
	local ChangedBlackHeartsCount = 1
	local MaxBlackHearts = 2
	--==Tainted Phobebia==--
	local TaintedChangedBlackHeartsCount = 2
	local TaintedMaxSoulHearts = 12
	--==Hearts Limit==--
	
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerType_Phobebia then
				player:SetFullHearts()
				local game = Game()
				local level = game:GetLevel()
				while player:GetBoneHearts() >= HasBoneHearts do
					player:AddBoneHearts(-HasBoneHearts, true)
					player:AddBlackHearts(ChangedBlackHeartsCount)
				end
				while player:GetHearts() >= HasRedHeartCount do
					player:AddMaxHearts(-HasRedHeartCount, true)
					player:AddBlackHearts(ChangedBlackHeartsCount)
				end
				while player:GetEternalHearts() >= HasEternalHearts do
					player:AddEternalHearts(-HasEternalHearts, true)
				end
				if level:GetStage() == 4 then
					if player:GetSoulHearts() > TaintedMaxSoulHearts and player:GetBlackHearts() > TaintedMaxSoulHearts then
						player:AddBlackHearts(-MoreBlackHeartsCount, true)
					else
						if player:GetSoulHearts() > TaintedMaxSoulHearts and player:GetBlackHearts() <= TaintedMaxSoulHearts then
						player:AddSoulHearts(-MoreBlackHeartsCount, true)
						end
					end
				else
					if player:GetSoulHearts() > MaxBlackHearts and player:GetBlackHearts() > MaxBlackHearts then
						player:AddBlackHearts(-MoreBlackHeartsCount, true)
					else
						if player:GetSoulHearts() > MaxBlackHearts and player:GetBlackHearts() <= MaxBlackHearts then
						player:AddSoulHearts(-MoreBlackHeartsCount, true)
						end
					end
				end
			end
			
			if player:GetPlayerType() == playerType_Tainted_Phobebia then
				player:SetFullHearts()
				while player:GetBoneHearts() >= HasBoneHearts do
					player:AddBoneHearts(-HasBoneHearts, true)
					player:AddBlackHearts(TaintedChangedBlackHeartsCount)
				end
				while player:GetHearts() >= HasRedHeartCount do
					player:AddMaxHearts(-HasRedHeartCount, true)
					player:AddBlackHearts(TaintedChangedBlackHeartsCount)
				end
				while player:GetEternalHearts() >= HasEternalHearts do
					player:AddEternalHearts(-HasEternalHearts, true)
				end
				if player:GetSoulHearts() > TaintedMaxSoulHearts and player:GetBlackHearts() > TaintedMaxSoulHearts then
					player:AddBlackHearts(-MoreBlackHeartsCount, true)
				else
					if player:GetSoulHearts() > TaintedMaxSoulHearts and player:GetBlackHearts() <= TaintedMaxSoulHearts then
					player:AddSoulHearts(-MoreBlackHeartsCount, true)
					end
				end
			end

			--==More get Judas' Shadow Chance==--
			if player:GetPlayerType() == playerType_Phobebia or player:GetPlayerType() == playerType_Tainted_Phobebia then
				if player:HasCollectible(ItemID.JudasShadow) then
					player:RemoveCollectible(ItemID.JudasShadow)
					player:AddCollectible(311, 0, true)
				end
			else
				itemPool:RemoveCollectible(ItemID.JudasShadow)
			end
			
		end
	)
end
phobebia:AddCallback( ModCallbacks.MC_POST_UPDATE, phobebia.UniversalUpdate)

function phobebia:UniversalPostNewRoom()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	--==I don't need Judas or other with cat ears!!==--
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() ~= playerType_Phobebia and player:GetPlayerType() ~= playerType_Tainted_Phobebia then
				--Else Do nothing!
				player:TryRemoveNullCostume(costume_Phobebia)
				player:TryRemoveNullCostume(costume_PhobebiaII)
				player:TryRemoveNullCostume(costume_Tainted_Phobebia)
				player:TryRemoveNullCostume(costume_TheCat)
				player:TryRemoveNullCostume(costume_TheCat_Head)
				player:TryRemoveNullCostume(phobebiaHabitCostume)
				player:TryRemoveNullCostume(phobebiaAnemicCostume)
			end
		end
	)
end
phobebia:AddCallback( ModCallbacks.MC_POST_NEW_ROOM, phobebia.UniversalPostNewRoom)

function phobebia:UniversalPostRender()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	local BackdropType = Game():GetRoom():GetBackdropType()
	CallForEveryPlayer(
		function(player)
		local playerPos = room:WorldToScreenPosition(player.Position)
		local PlayerDMG = player.Damage
		if player:GetPlayerType() == playerType_Phobebia or player:GetPlayerType() == playerType_Tainted_Phobebia then
				if BackdropType == 55 or BackdropType == 56 or BackdropType == 57 then
					Isaac.RenderText("DAMAGE:"..tostring(math.ceil(PlayerDMG)), playerPos.X - 25, playerPos.Y - 58, 1, 0.7, 0.7, 0.5)
				end
			end
		end
	)
end
phobebia:AddCallback(ModCallbacks.MC_POST_RENDER, phobebia.UniversalPostRender)

function phobebia:UniversalPrePickupCollision(pickup, collider, low)
	local player = collider:ToPlayer()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	if player ~= nil and (player:GetPlayerType() == playerType_Phobebia or player:GetPlayerType() == playerType_Tainted_Phobebia) then
		if pickup.Variant == PickupVariant.PICKUP_HEART then
			if (player:GetPlayerType() == playerType_Phobebia and player:GetSoulHearts() >= 2) 
			or (player:GetPlayerType() == playerType_Phobebia and level:GetStage() == 4 and player:GetSoulHearts() >= 12) 
			or (player:GetPlayerType() == playerType_Tainted_Phobebia and player:GetSoulHearts() >= 12) then
				return false
			end
		else
			return nil
		end
	end
end
phobebia:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, phobebia.UniversalPrePickupCollision)

function phobebia:JudasUpdate()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	CallForEveryPlayer(
		function(player)
			if room:GetFrameCount() == 1 and player:GetPlayerType() == playerType_Judas or player:GetPlayerType() == playerType_BlackJudas then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
					if player:HasCollectible(ItemID.PhobebiasBloodBandage) then
						player:TryRemoveNullCostume(PhobebiasBloodBandage_Costume)
						player:AddNullCostume(PhobebiasBloodBandage_Costume)
					end
				else
					if player:HasCollectible(ItemID.PhobebiasBloodBandage) then
						player:TryRemoveNullCostume(PhobebiasBloodBandage_Costume)
						player:AddNullCostume(PhobebiasBloodBandage_Costume)
					end
				end
			else
				itemPool:RemoveCollectible(ItemID.PhobebiasBloodBandage)
			end
			
			--==BloodBandageII==--
			if room:GetFrameCount() == 1 and player:GetPlayerType() == playerType_Judas or player:GetPlayerType() == playerType_BlackJudas then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
					if player:HasCollectible(ItemID.PhobebiasBloodBandageII) then
						player:TryRemoveNullCostume(PhobebiasBloodBandageII_Costume)
						player:AddNullCostume(PhobebiasBloodBandageII_Costume)
					end
				else
					if player:HasCollectible(ItemID.PhobebiasBloodBandageII) then
						player:TryRemoveNullCostume(PhobebiasBloodBandageII_Costume)
						player:AddNullCostume(PhobebiasBloodBandageII_Costume)
					end
				end
			else
				itemPool:RemoveCollectible(ItemID.PhobebiasBloodBandageII)
			end
			
			--==I -> II ==--
			if player:IsDead() then
				if player:GetPlayerType() == playerType_Judas or player:GetPlayerType() == playerType_BlackJudas then
					if player:HasCollectible(ItemID.PhobebiasBloodBandage) then
						player:Revive()
						player:RemoveCollectible(ItemID.PhobebiasBloodBandage)
						player:AddCollectible(ItemID.PhobebiasBloodBandageII, 0, true)
						player:SetFullHearts()
						local JudasHasRedHearts = 2
						player:AddMaxHearts(-JudasHasRedHearts, true)
						player:AddBlackHearts(2)
					end
				end
			end
		end
	)
end
phobebia:AddCallback( ModCallbacks.MC_POST_UPDATE, phobebia.JudasUpdate)

function phobebia:JudasEvaluateCache(player, cacheFlag)
	if player:GetPlayerType() == playerType_Judas or player:GetPlayerType() == playerType_BlackJudas then
	
		if player:HasCollectible(ItemID.PhobebiasBloodBandage) then
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage + 0.03
			elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
				player.TearFlags = player.TearFlags | 1 << 4
			elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
				player.TearColor = Color(0.623, 0, 0.251, 1, 0, 0, 0)
			elseif cacheFlag == CacheFlag.CACHE_FLYING then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
					player:TryRemoveNullCostume(PhobebiasBloodBandage_Costume)
					player:AddNullCostume(PhobebiasBloodBandage_Costume)
				end
			elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
				local maybeFamiliars = Isaac.GetRoomEntities()
				for m = 1, #maybeFamiliars do
					local variant = maybeFamiliars[m].Variant
					if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
						player:TryRemoveNullCostume(PhobebiasBloodBandage_Costume)
						player:AddNullCostume(PhobebiasBloodBandage_Costume)
					else
						player:TryRemoveNullCostume(PhobebiasBloodBandage_Costume)
						player:AddNullCostume(PhobebiasBloodBandage_Costume)
					end
				end
			end
		end
		--==BloodBandageII==--
		if player:HasCollectible(ItemID.PhobebiasBloodBandageII) then
			if cacheFlag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = player.MaxFireDelay - 2
			elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage + 0.03
			elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
				player.TearFlags = player.TearFlags | 1 << 13
			elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
				player.TearColor = Color(0.623, 0, 0.251, 1, 0, 0, 0)
			elseif cacheFlag == CacheFlag.CACHE_FLYING then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
					player:TryRemoveNullCostume(PhobebiasBloodBandageII_Costume)
					player:AddNullCostume(PhobebiasBloodBandageII_Costume)
				end
			elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
				local maybeFamiliars = Isaac.GetRoomEntities()
				for m = 1, #maybeFamiliars do
					local variant = maybeFamiliars[m].Variant
					if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
						player:TryRemoveNullCostume(PhobebiasBloodBandageII_Costume)
						player:AddNullCostume(PhobebiasBloodBandageII_Costume)
					else
						player:TryRemoveNullCostume(PhobebiasBloodBandageII_Costume)
					end
				end
			end
		end
	end
end
phobebia:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, phobebia.JudasEvaluateCache)

function phobebia:JudasPostPlayerInit(player)
	if player:GetPlayerType() == playerType_Judas or player:GetPlayerType() == playerType_BlackJudas then
		if player:HasCollectible(ItemID.PhobebiasBloodBandage) then
			player:TryRemoveNullCostume(PhobebiasBloodBandage_Costume)
			player:AddNullCostume(PhobebiasBloodBandage_Costume)
		end
		if player:HasCollectible(ItemID.PhobebiasBloodBandageII) then
			player:TryRemoveNullCostume(PhobebiasBloodBandageII_Costume)
			player:AddNullCostume(PhobebiasBloodBandageII_Costume)
		end
		costumeEquipped = true
	else
		player:TryRemoveNullCostume(PhobebiasBloodBandage_Costume)
		player:TryRemoveNullCostume(PhobebiasBloodBandageII_Costume)
		costumeEquipped = false
	end
end
phobebia:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, phobebia.JudasPostPlayerInit)