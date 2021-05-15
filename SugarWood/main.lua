local sugarwood = RegisterMod("SugarWood", 1);

local costume_SugarWood = Isaac.GetCostumeIdByPath("gfx/characters/character_SugarWoodHair.anm2")
local playerType_SugarWood = Isaac.GetPlayerTypeByName("SugarWood")

local Costume2020_SugarWood = Isaac.GetCostumeIdByPath("gfx/characters/SugarWood_2020.anm2")
local PiggyBankCostume_SugarWood = Isaac.GetCostumeIdByPath("gfx/characters/SugarWood_piggybank.anm2")

local BluePrisonerVariant = Isaac.GetEntityVariantByName("Blue Prisoner")

function sugarwood:Update()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	
	if room:GetFrameCount() == 1 and player:GetPlayerType() == playerType_SugarWood and not player:IsDead() then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
			player:AddNullCostume(costume_SugarWood)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
				player:TryRemoveNullCostume(Costume2020_SugarWood)
				player:AddNullCostume(Costume2020_SugarWood)
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_PIGGY_BANK) then
				player:TryRemoveNullCostume(PiggyBankCostume_SugarWood)
				player:AddNullCostume(PiggyBankCostume_SugarWood)
			end
		else
			player:TryRemoveNullCostume(costume_SugarWood)
			player:AddNullCostume(costume_SugarWood)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
				player:TryRemoveNullCostume(Costume2020_SugarWood)
				player:AddNullCostume(Costume2020_SugarWood)
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_PIGGY_BANK) then
				player:TryRemoveNullCostume(PiggyBankCostume_SugarWood)
				player:AddNullCostume(PiggyBankCostume_SugarWood)
			end
		end
	end
end
sugarwood:AddCallback( ModCallbacks.MC_POST_UPDATE, sugarwood.Update)

local Coins = 0

function sugarwood:PostUpdate()
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == playerType_SugarWood then
		if Coins ~= player:GetNumCoins() then
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			Coins = player:GetNumCoins()
		end
	end
end
sugarwood:AddCallback( ModCallbacks.MC_POST_UPDATE, sugarwood.PostUpdate )

function sugarwood:PostPlayerInit(player)
	if player:GetPlayerType() == playerType_SugarWood then
		player:TryRemoveNullCostume(costume_SugarWood)
		player:AddNullCostume(costume_SugarWood)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
			player:TryRemoveNullCostume(Costume2020_SugarWood)
			player:AddNullCostume(Costume2020_SugarWood)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_PIGGY_BANK) then
			player:TryRemoveNullCostume(PiggyBankCostume_SugarWood)
			player:AddNullCostume(PiggyBankCostume_SugarWood)
		end
		costumeEquipped = true
	else
		player:TryRemoveNullCostume(costume_SugarWood)
		player:TryRemoveNullCostume(costume_SugarWood)
		player:TryRemoveNullCostume(PiggyBankCostume_SugarWood)
		player:TryRemoveNullCostume(Costume2020_SugarWood)
		costumeEquipped = false
	end
end
sugarwood:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, sugarwood.PostPlayerInit)

function sugarwood:EvaluateCache(player, cacheFlag)
	if player:GetPlayerType() == playerType_SugarWood then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + 0.2
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage - .5
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 4
		--==Coins = Tears==--
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay + 3
			if Coins > 25 and Coins < 49 then
				player.MaxFireDelay = player.MaxFireDelay - 1
			elseif Coins < 61 then
				player.MaxFireDelay = player.MaxFireDelay - 2
			elseif Coins < 73 then
				player.MaxFireDelay = player.MaxFireDelay - 3
			elseif Coins < 85 then
				player.MaxFireDelay = player.MaxFireDelay - 4
			elseif Coins < 97 then
				player.MaxFireDelay = player.MaxFireDelay - 5
			elseif Coins > 97 then
				player.MaxFireDelay = player.MaxFireDelay - 6
			end
		--==End==--
		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | 1 << 3
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
				player:TryRemoveNullCostume(costume_SugarWood)
				player:AddNullCostume(costume_SugarWood)
			end
		elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
			local maybeFamiliars = Isaac.GetRoomEntities()
			for m = 1, #maybeFamiliars do
				local variant = maybeFamiliars[m].Variant
				if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
					player:TryRemoveNullCostume(costume_SugarWood)
					player:AddNullCostume(costume_SugarWood)
					if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
						player:TryRemoveNullCostume(Costume2020_SugarWood)
						player:AddNullCostume(Costume2020_SugarWood)
					end
					if player:HasCollectible(CollectibleType.COLLECTIBLE_PIGGY_BANK) then
						player:TryRemoveNullCostume(PiggyBankCostume_SugarWood)
						player:AddNullCostume(PiggyBankCostume_SugarWood)
					end
				else
					player:TryRemoveNullCostume(costume_SugarWood)
					player:AddNullCostume(costume_SugarWood)
					if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
						player:TryRemoveNullCostume(Costume2020_SugarWood)
						player:AddNullCostume(Costume2020_SugarWood)
					end
					if player:HasCollectible(CollectibleType.COLLECTIBLE_PIGGY_BANK) then
						player:TryRemoveNullCostume(PiggyBankCostume_SugarWood)
						player:AddNullCostume(PiggyBankCostume_SugarWood)
					end
				end
			end
				--==BluePrisoner!==--
			local BluePrisonerCount = 0
			for i, entity in pairs(maybeFamiliars) do
				if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == BluePrisonerVariant then
					BluePrisonerCount = BluePrisonerCount + 1
					if BluePrisonerCount >= 2 then
						entity:Remove()
					end
				end
			end
			if BluePrisonerCount < 1 then
				local BPspawn = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, BluePrisonerVariant, 0, player.Position, Vector(0,0), player)
			end
		end
	end
end
sugarwood:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, sugarwood.EvaluateCache )

--==BluePrisoner==--
local function BluePrisonerFamiliarInit(_, FamBluePrisoner)
	local player = Isaac.GetPlayer(0)
end
sugarwood:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, BluePrisonerFamiliarInit, BluePrisonerVariant)

local Frame30 = 30
local FrameCount = 0
local function BluePrisonerFamiliarUpdate(_, FamBluePrisoner)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	
	if player:GetPlayerType() == playerType_SugarWood then
		FamBluePrisoner:FollowPosition(player.Position)
		if room:GetFrameCount() == Frame30 * FrameCount then
			FamBluePrisoner:BloodExplode()
			FrameCount = FrameCount + 1
		end
		if player:GetHeadDirection() == Direction.DOWN then
			FamBluePrisoner:GetSprite():Play("FloatDown", false)
		elseif player:GetHeadDirection() == Direction.UP then
			FamBluePrisoner:GetSprite():Play("FloatUp", false)
		end
		if player:GetLastActionTriggers() == 4 then
			if FamBluePrisoner.FireCooldown < 1 then
				FamBluePrisoner:Shoot()
				FamBluePrisoner.FireCooldown = player.MaxFireDelay - 1
			else
				FamBluePrisoner.FireCooldown = FamBluePrisoner.FireCooldown - 1
			end
		end
	end
	for i,entity in ipairs(roomEntities) do
		local tear = entity:ToTear()
		if tear ~= nil then
			if tear.Parent.Type == EntityType.ENTITY_FAMILIAR and tear.Parent.Variant == BluePrisonerVariant and tear.Variant ~= TearVariant.BLOOD then
				local tearSprite = tear:GetSprite()
				tear:ChangeVariant(TearVariant.BLOOD)
				tearSprite:ReplaceSpritesheet(0,"gfx/Phobebia_tears.png")
				tearSprite:LoadGraphics("gfx/Phobebia_tears.png")
				tearSprite.Rotation = entity.Velocity:GetAngleDegrees()
				tear.CollisionDamage = player.Damage * 2 + 1
				tear.TearFlags = player.TearFlags
			end
		end
	end
end
sugarwood:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, BluePrisonerFamiliarUpdate, BluePrisonerVariant)

function sugarwood:BluePrisonerPostNewRoom()
	FrameCount = 0
end
sugarwood:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, sugarwood.BluePrisonerPostNewRoom)

function sugarwood:BluePrisonerPostNewGame()
	FrameCount = 0
end
sugarwood:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, sugarwood.BluePrisonerPostNewGame)