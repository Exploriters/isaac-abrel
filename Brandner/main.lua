local brandner = RegisterMod("Brandner", 1);

local costume_Brandner_Body = Isaac.GetCostumeIdByPath("gfx/characters/BrandnerBody.anm2")
local costume_Brandner_Head = Isaac.GetCostumeIdByPath("gfx/characters/BrandnerHead.anm2")
local costume_Brandner_HeadBone = Isaac.GetCostumeIdByPath("gfx/characters/BrandnerHeadBone.anm2")
local playerType_Brandner = Isaac.GetPlayerTypeByName("Brandner")

local BSAD_DCount = 0

function brandner:Update(player)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	
	if room:GetFrameCount() == 1 and player:GetPlayerType() == playerType_Brandner and not player:IsDead() then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
			player:AddNullCostume(costume_Brandner_Body)
			player:AddNullCostume(costume_Brandner_Head)
			player:AddNullCostume(costume_Brandner_HeadBone)
		else
			player:TryRemoveNullCostume(costume_Brandner_Body)
			player:AddNullCostume(costume_Brandner_Body)
			player:TryRemoveNullCostume(costume_Brandner_Head)
			player:AddNullCostume(costume_Brandner_Head)
			player:TryRemoveNullCostume(costume_Brandner_HeadBone)
			player:AddNullCostume(costume_Brandner_HeadBone)
		end
	end
	
	if player:GetPlayerType() == playerType_Brandner then
		if not player:HasCollectible(544) then
			player:AddCollectible(544, 0, true)
			player:TryRemoveNullCostume(costume_Brandner_Body)
			player:AddNullCostume(costume_Brandner_Body)
			player:TryRemoveNullCostume(costume_Brandner_Head)
			player:AddNullCostume(costume_Brandner_Head)
			player:TryRemoveNullCostume(costume_Brandner_HeadBone)
			player:AddNullCostume(costume_Brandner_HeadBone)
		end
	end
	
	if player:GetPlayerType() == playerType_Brandner then
	-- Hearts <= 2, Slipped Rib Num == 4
		if player:GetHearts() <= 2 then
			if player:GetCollectibleNum(542) ~= 4 then
				if player:GetCollectibleNum(542) < 4 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:AddCollectible(542, 0, true)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
					player:TryRemoveNullCostume(costume_Brandner_Head)
					player:AddNullCostume(costume_Brandner_Head)
					player:TryRemoveNullCostume(costume_Brandner_HeadBone)
					player:AddNullCostume(costume_Brandner_HeadBone)
				end
				if player:GetCollectibleNum(542) > 4 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:RemoveCollectible(542)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
					player:TryRemoveNullCostume(costume_Brandner_Head)
					player:AddNullCostume(costume_Brandner_Head)
					player:TryRemoveNullCostume(costume_Brandner_HeadBone)
					player:AddNullCostume(costume_Brandner_HeadBone)
				end
			end
		else
			--Do nothing
		end
		-- Hearts <= 6, Slipped Rib Num == 3
		if player:GetHearts() <= 6 and player:GetHearts() > 2 then
			if player:GetCollectibleNum(542) ~= 3 then
				if player:GetCollectibleNum(542) < 3 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:AddCollectible(542, 0, true)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
					player:TryRemoveNullCostume(costume_Brandner_Head)
					player:AddNullCostume(costume_Brandner_Head)
					player:TryRemoveNullCostume(costume_Brandner_HeadBone)
					player:AddNullCostume(costume_Brandner_HeadBone)
				end
				if player:GetCollectibleNum(542) > 3 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:RemoveCollectible(542)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
					player:TryRemoveNullCostume(costume_Brandner_Head)
					player:AddNullCostume(costume_Brandner_Head)
					player:TryRemoveNullCostume(costume_Brandner_HeadBone)
					player:AddNullCostume(costume_Brandner_HeadBone)
				end
			end
		else
			--Do nothing
		end
		-- Hearts <= 12, Slipped Rib Num == 2
		if player:GetHearts() <= 12 and player:GetHearts() > 6 then
			if player:GetCollectibleNum(542) ~= 2 then
				if player:GetCollectibleNum(542) < 2 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:AddCollectible(542, 0, true)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
					player:TryRemoveNullCostume(costume_Brandner_Head)
					player:AddNullCostume(costume_Brandner_Head)
					player:TryRemoveNullCostume(costume_Brandner_HeadBone)
					player:AddNullCostume(costume_Brandner_HeadBone)
				end
				if player:GetCollectibleNum(542) > 2 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:RemoveCollectible(542)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
					player:TryRemoveNullCostume(costume_Brandner_Head)
					player:AddNullCostume(costume_Brandner_Head)
					player:TryRemoveNullCostume(costume_Brandner_HeadBone)
					player:AddNullCostume(costume_Brandner_HeadBone)
				end
			end
		else
			--Do nothing
		end
		-- Hearts <= 18, Slipped Rib Num == 1
		if player:GetHearts() <= 18 and player:GetHearts() > 12 then
			if player:GetCollectibleNum(542) ~= 1 then
				if player:GetCollectibleNum(542) < 1 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:AddCollectible(542, 0, true)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
					player:TryRemoveNullCostume(costume_Brandner_Head)
					player:AddNullCostume(costume_Brandner_Head)
					player:TryRemoveNullCostume(costume_Brandner_HeadBone)
					player:AddNullCostume(costume_Brandner_HeadBone)
				end
				if player:GetCollectibleNum(542) > 1 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:RemoveCollectible(542)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
					player:TryRemoveNullCostume(costume_Brandner_Head)
					player:AddNullCostume(costume_Brandner_Head)
					player:TryRemoveNullCostume(costume_Brandner_HeadBone)
					player:AddNullCostume(costume_Brandner_HeadBone)
				end
			end
		else
			--Do nothing
		end
		-- Hearts <= 24, Slipped Rib Num == 0
		if player:GetHearts() <= 24 and player:GetHearts() > 18 then
			if player:GetCollectibleNum(542) ~= 0 then
				if player:GetCollectibleNum(542) < 0 then
					player:AddCollectible(542, 0, true)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
					player:TryRemoveNullCostume(costume_Brandner_Head)
					player:AddNullCostume(costume_Brandner_Head)
					player:TryRemoveNullCostume(costume_Brandner_HeadBone)
					player:AddNullCostume(costume_Brandner_HeadBone)
				end
				if player:GetCollectibleNum(542) > 0 then
					player:RemoveCollectible(542)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
					player:TryRemoveNullCostume(costume_Brandner_Head)
					player:AddNullCostume(costume_Brandner_Head)
					player:TryRemoveNullCostume(costume_Brandner_HeadBone)
					player:AddNullCostume(costume_Brandner_HeadBone)
				end
			end
		else
			-- Do nothing
		end
	end
end
brandner:AddCallback( ModCallbacks.MC_POST_UPDATE, brandner.Update)

function brandner:PostPlayerInit(player)
	if player:GetPlayerType() == playerType_Brandner then
		player:TryRemoveNullCostume(costume_Brandner_Body)
		player:AddNullCostume(costume_Brandner_Body)
		player:TryRemoveNullCostume(costume_Brandner_Head)
		player:AddNullCostume(costume_Brandner_Head)
		player:TryRemoveNullCostume(costume_Brandner_HeadBone)
		player:AddNullCostume(costume_Brandner_HeadBone)
		costumeEquipped = true
	else
		player:TryRemoveNullCostume(costume_Brandner_Body)
		player:TryRemoveNullCostume(costume_Brandner_Head)
		player:TryRemoveNullCostume(costume_Brandner_HeadBone)
		costumeEquipped = false
	end
end
brandner:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, brandner.PostPlayerInit)

function brandner:EvaluateCache(player, cacheFlag)
	if player:GetPlayerType() == playerType_Brandner then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + 0.3
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 0.5
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay + 8
		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | 1 << 49 | 1 << 22 | 1
		elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed + 0.3
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + 2
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
				player:TryRemoveNullCostume(costume_Brandner_Body)
				player:AddNullCostume(costume_Brandner_Body)
				player:TryRemoveNullCostume(costume_Brandner_Head)
				player:AddNullCostume(costume_Brandner_Head)
				player:TryRemoveNullCostume(costume_Brandner_HeadBone)
				player:AddNullCostume(costume_Brandner_HeadBone)
			end
			player.CanFly = true
		elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
			local maybeFamiliars = Isaac.GetRoomEntities()
			for m = 1, #maybeFamiliars do
				local variant = maybeFamiliars[m].Variant
				if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
					player:TryRemoveNullCostume(costume_Brandner_Head)
					player:AddNullCostume(costume_Brandner_Head)
					player:TryRemoveNullCostume(costume_Brandner_HeadBone)
					player:AddNullCostume(costume_Brandner_HeadBone)
				else
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
					player:TryRemoveNullCostume(costume_Brandner_Head)
					player:AddNullCostume(costume_Brandner_Head)
					player:TryRemoveNullCostume(costume_Brandner_HeadBone)
					player:AddNullCostume(costume_Brandner_HeadBone)
				end
			end
		end
	end
end
brandner:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, brandner.EvaluateCache)

local BSAD_D_Type = Isaac.GetEntityTypeByName("BrandnerAnmDeath")
local BSAD_D_Variant = Isaac.GetEntityVariantByName("BrandnerAnmDeath")
local HasBSAD_D = false

local function BSAD_D_Update(_, BSAD_D)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	if player:GetPlayerType() == playerType_Brandner and player:IsDead() then
		player.Visible = false
		SFXManager():Stop(55)
		if HasBSAD_D == false then
			Isaac.Spawn(EntityType.ENTITY_FAMILIAR, BSAD_D_Variant, 0, player.Position, Vector(0,0), player)
			BSAD_D:GetSprite():Play("BrandnerDeath", false)
			HasBSAD_D = true
		end
		if BSAD_D:GetSprite():IsEventTriggered("Stat") then
			--Wel, Do nothing.
		end
		if BSAD_D:GetSprite():IsEventTriggered("BloodExplosion") then
			SFXManager():Play(28, 3, 0, false, 1 )
		end
		if BSAD_D:GetSprite():IsEventTriggered("FirePutout") then
			SFXManager():Play(43, 3, 0, false, 1 )
		end
		if	BSAD_D:GetSprite():IsEventTriggered("End") then
			HasBSAD_D = false
			BSAD_D:Remove()
		end
	end
end
brandner:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,BSAD_D_Update, BSAD_D)

local BSAD_H_Type = Isaac.GetEntityTypeByName("BrandnerAnmHematemesis")
local BSAD_H_Variant = Isaac.GetEntityVariantByName("BrandnerAnmHematemesis")
local BrandnerUsePills = false

local function BSAD_H_Update(_, BSAD_H)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	if player:GetPlayerType() == playerType_Brandner and BrandnerUsePills == true then
		BSAD_H:GetSprite():Play("BrandnerHematemesis", false)
		if BSAD_H:GetSprite():IsEventTriggered("Stat") then
			--Wel, Do nothing.
		end
		if	BSAD_H:GetSprite():IsEventTriggered("End") then
			player.Visible = true
			player.ControlsEnabled = true
			BrandnerUsePills = false
			BSAD_H:Remove()
		end
	end
end
brandner:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,BSAD_H_Update, BSAD_H)

function brandner:UsePills()
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == playerType_Brandner then
		BrandnerUsePills = true
		Isaac.Spawn(EntityType.ENTITY_FAMILIAR, BSAD_H_Variant, 0, player.Position, Vector(0,0), player)
		player.Visible = false
		player.ControlsEnabled = false
		player:TakeDamage(2, DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_INVINCIBLE , EntityRef(player), 0)
		local pos = Isaac.GetFreeNearPosition(player.Position, 1)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 8, pos, Vector(0, 0), nil)
		player:BloodExplode()
		SFXManager():Play(30, 3, 0, false, 1 )
		SFXManager():Stop(55)
		if player:IsDead() then
			print "Brandner:If I die... It's all the pills' fault.."
		end
	end
end
brandner:AddCallback( ModCallbacks.MC_USE_PILL, brandner.UsePills)

function brandner:PostNewGame()
	HasBSAD_D = false
	BrandnerUsePills = false
end
brandner:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, brandner.PostNewGame)

--== Tainted Brandner==--
local costume_TaintedBrandner_FireHead = Isaac.GetCostumeIdByPath("gfx/characters/TaintedBrandnerFireHead.anm2")
local costume_TaintedBrandner_Head = Isaac.GetCostumeIdByPath("gfx/characters/TaintedBrandnerHead.anm2")
local costume_TaintedBrandner_HeadBone = Isaac.GetCostumeIdByPath("gfx/characters/TaintedBrandnerHeadBone.anm2")

local playerType_TaintedBrandner = Isaac.GetPlayerTypeByName("Tainted Brandner")

function brandner:TaintedUpdate()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	
	if room:GetFrameCount() == 1 and player:GetPlayerType() == playerType_TaintedBrandner and not player:IsDead() then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
			player:AddNullCostume(costume_TaintedBrandner_FireHead)
			player:AddNullCostume(costume_TaintedBrandner_Head)
			player:AddNullCostume(costume_TaintedBrandner_HeadBone)
			player:AddNullCostume(costume_Brandner_Body)
		else
			player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
			player:AddNullCostume(costume_TaintedBrandner_FireHead)
			player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
			player:AddNullCostume(costume_TaintedBrandner_Head)
			player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
			player:AddNullCostume(costume_TaintedBrandner_HeadBone)
			player:TryRemoveNullCostume(costume_Brandner_Body)
			player:AddNullCostume(costume_Brandner_Body)
		end
	end
	
	if player:GetPlayerType() == playerType_TaintedBrandner then
		if not player:HasCollectible(544) then
			player:AddCollectible(544, 0, true)
			player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
			player:AddNullCostume(costume_TaintedBrandner_FireHead)
			player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
			player:AddNullCostume(costume_TaintedBrandner_Head)
			player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
			player:AddNullCostume(costume_TaintedBrandner_HeadBone)
			player:TryRemoveNullCostume(costume_Brandner_Body)
			player:AddNullCostume(costume_Brandner_Body)
		end
	end
	
	if player:GetPlayerType() == playerType_TaintedBrandner	 then
	-- Hearts <= 2, Slipped Rib Num == 4
		if player:GetHearts() <= 2 then
			if player:GetCollectibleNum(542) ~= 4 then
				if player:GetCollectibleNum(542) < 4 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:AddCollectible(542, 0, true)
					player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
					player:AddNullCostume(costume_TaintedBrandner_FireHead)
					player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
					player:AddNullCostume(costume_TaintedBrandner_Head)
					player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
					player:AddNullCostume(costume_TaintedBrandner_HeadBone)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
				end
				if player:GetCollectibleNum(542) > 4 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:RemoveCollectible(542)
					player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
					player:AddNullCostume(costume_TaintedBrandner_FireHead)
					player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
					player:AddNullCostume(costume_TaintedBrandner_Head)
					player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
					player:AddNullCostume(costume_TaintedBrandner_HeadBone)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
				end
			end
		else
			--Do nothing
		end
		-- Hearts <= 6, Slipped Rib Num == 3
		if player:GetHearts() <= 6 and player:GetHearts() > 2 then
			if player:GetCollectibleNum(542) ~= 3 then
				if player:GetCollectibleNum(542) < 3 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:AddCollectible(542, 0, true)
					player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
					player:AddNullCostume(costume_TaintedBrandner_FireHead)
					player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
					player:AddNullCostume(costume_TaintedBrandner_Head)
					player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
					player:AddNullCostume(costume_TaintedBrandner_HeadBone)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
				end
				if player:GetCollectibleNum(542) > 3 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:RemoveCollectible(542)
					player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
					player:AddNullCostume(costume_TaintedBrandner_FireHead)
					player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
					player:AddNullCostume(costume_TaintedBrandner_Head)
					player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
					player:AddNullCostume(costume_TaintedBrandner_HeadBone)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
				end
			end
		else
			--Do nothing
		end
		-- Hearts <= 12, Slipped Rib Num == 2
		if player:GetHearts() <= 12 and player:GetHearts() > 6 then
			if player:GetCollectibleNum(542) ~= 2 then
				if player:GetCollectibleNum(542) < 2 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:AddCollectible(542, 0, true)
					player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
					player:AddNullCostume(costume_TaintedBrandner_FireHead)
					player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
					player:AddNullCostume(costume_TaintedBrandner_Head)
					player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
					player:AddNullCostume(costume_TaintedBrandner_HeadBone)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
				end
				if player:GetCollectibleNum(542) > 2 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:RemoveCollectible(542)
					player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
					player:AddNullCostume(costume_TaintedBrandner_FireHead)
					player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
					player:AddNullCostume(costume_TaintedBrandner_Head)
					player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
					player:AddNullCostume(costume_TaintedBrandner_HeadBone)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
				end
			end
		else
			--Do nothing
		end
		-- Hearts <= 18, Slipped Rib Num == 1
		if player:GetHearts() <= 18 and player:GetHearts() > 12 then
			if player:GetCollectibleNum(542) ~= 1 then
				if player:GetCollectibleNum(542) < 1 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:AddCollectible(542, 0, true)
					player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
					player:AddNullCostume(costume_TaintedBrandner_FireHead)
					player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
					player:AddNullCostume(costume_TaintedBrandner_Head)
					player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
					player:AddNullCostume(costume_TaintedBrandner_HeadBone)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
				end
				if player:GetCollectibleNum(542) > 1 then
					SFXManager():Play(461, 3, 0, false, 1 )
					player:RemoveCollectible(542)
					player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
					player:AddNullCostume(costume_TaintedBrandner_FireHead)
					player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
					player:AddNullCostume(costume_TaintedBrandner_Head)
					player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
					player:AddNullCostume(costume_TaintedBrandner_HeadBone)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
				end
			end
		else
			--Do nothing
		end
		-- Hearts <= 24, Slipped Rib Num == 0
		if player:GetHearts() <= 24 and player:GetHearts() > 18 then
			if player:GetCollectibleNum(542) ~= 0 then
				if player:GetCollectibleNum(542) < 0 then
					player:AddCollectible(542, 0, true)
					player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
					player:AddNullCostume(costume_TaintedBrandner_FireHead)
					player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
					player:AddNullCostume(costume_TaintedBrandner_Head)
					player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
					player:AddNullCostume(costume_TaintedBrandner_HeadBone)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
				end
				if player:GetCollectibleNum(542) > 0 then
					player:RemoveCollectible(542)
					player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
					player:AddNullCostume(costume_TaintedBrandner_FireHead)
					player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
					player:AddNullCostume(costume_TaintedBrandner_Head)
					player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
					player:AddNullCostume(costume_TaintedBrandner_HeadBone)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
				end
			end
		else
			-- Do nothing
		end
	end
end
brandner:AddCallback( ModCallbacks.MC_POST_UPDATE, brandner.TaintedUpdate)

function brandner:TaintedPostPlayerInit(player)
	if player:GetPlayerType() == playerType_TaintedBrandnerBrandner then
		player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
		player:AddNullCostume(costume_TaintedBrandner_FireHead)
		player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
		player:AddNullCostume(costume_TaintedBrandner_Head)
		player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
		player:AddNullCostume(costume_TaintedBrandner_HeadBone)
		player:TryRemoveNullCostume(costume_Brandner_Body)
		player:AddNullCostume(costume_Brandner_Body)
		costumeEquipped = true
	else
		player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
		player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
		player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
		player:TryRemoveNullCostume(costume_Brandner_Body)
		costumeEquipped = false
	end
end
brandner:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, brandner.TaintedPostPlayerInit)

function brandner:EvaluateCache(player, cacheFlag)
	if player:GetPlayerType() == playerType_TaintedBrandner then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed - 0.2
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 1.5
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay + 12
		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | 1 << 49 | 1 << 22 | 1
		elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed + 0.3
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + 4
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
				player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
				player:AddNullCostume(costume_TaintedBrandner_FireHead)
				player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
				player:AddNullCostume(costume_TaintedBrandner_Head)
				player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
				player:AddNullCostume(costume_TaintedBrandner_HeadBone)
				player:TryRemoveNullCostume(costume_Brandner_Body)
				player:AddNullCostume(costume_Brandner_Body)
			end
			player.CanFly = true
		elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
			local maybeFamiliars = Isaac.GetRoomEntities()
			for m = 1, #maybeFamiliars do
				local variant = maybeFamiliars[m].Variant
				if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
					player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
					player:AddNullCostume(costume_TaintedBrandner_FireHead)
					player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
					player:AddNullCostume(costume_TaintedBrandner_Head)
					player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
					player:AddNullCostume(costume_TaintedBrandner_HeadBone)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
				else
					player:TryRemoveNullCostume(costume_TaintedBrandner_FireHead)
					player:AddNullCostume(costume_TaintedBrandner_FireHead)
					player:TryRemoveNullCostume(costume_TaintedBrandner_Head)
					player:AddNullCostume(costume_TaintedBrandner_Head)
					player:TryRemoveNullCostume(costume_TaintedBrandner_HeadBone)
					player:AddNullCostume(costume_TaintedBrandner_HeadBone)
					player:TryRemoveNullCostume(costume_Brandner_Body)
					player:AddNullCostume(costume_Brandner_Body)
				end
			end
		end
	end
end
brandner:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, brandner.EvaluateCache)

local Fireworks = {}

function brandner:TaintedPostUpdate()
	local player = Isaac.GetPlayer(0)
	local roomEntities = Isaac.GetRoomEntities()
	
	if player:GetPlayerType() == playerType_TaintedBrandner then
		for i, entity in ipairs(Fireworks) do
			if entity ~= nil then
				entity:Remove()
			end
		end
		Fireworks = {}
		for i,entity in ipairs(roomEntities) do
			--==NPC==--
			local NPC = entity:ToNPC()
			if NPC ~= nil then
				local FireworksEntityNPC = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FIREWORKS, 5, NPC.Position, NPC.Velocity, NPC)
				FireworksEntityNPC.Visible = false
				FireworksEntityNPC:SetColor(Color(0.5, 0.75, 1, 1, 0, 0, 0), 0, 999, false, false)
				table.insert(
				Fireworks,
				FireworksEntityNPC
				)
			end
			--==Tear==--
			local tear = entity:ToTear()
			if tear ~= nil then
				if tear.Parent.Type == EntityType.ENTITY_PLAYER then
					local FireworksEntityTear = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FIREWORKS, 5, tear.Position, tear.Velocity, tear)
					FireworksEntityTear.Visible = false
					FireworksEntityTear:SetColor(Color(0.5, 0.75, 1, 1, 0, 0, 0), 0, 999, false, false)
					table.insert(
					Fireworks,
					FireworksEntityTear
					)
				end
			end
		end
	end
end
brandner:AddCallback( ModCallbacks.MC_POST_UPDATE, brandner.TaintedPostUpdate)

function brandner:TaintedPostNewLevel()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	if player:GetPlayerType() == playerType_TaintedBrandner then
		if level:GetCurses() ~= (LevelCurse.CURSE_OF_DARKNESS) then
			level:AddCurse(LevelCurse.CURSE_OF_DARKNESS, false)
		end
	end
end
brandner:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, brandner.TaintedPostNewLevel)

function brandner:TaintedUsePills()
	local player = Isaac.GetPlayer(0)
	local roomEntities = Isaac.GetRoomEntities()
	if player:GetPlayerType() == playerType_TaintedBrandner then
		BrandnerUsePills = true
		player:TakeDamage(2, DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_INVINCIBLE , EntityRef(player), 0)
		local pos = Isaac.GetFreeNearPosition(player.Position, 1)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 8, pos, Vector(0, 0), nil)
		player:BloodExplode()
		SFXManager():Play(30, 3, 0, false, 1 )
		SFXManager():Stop(55)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, player.Position, Vector(0,0), player)
	end
end
brandner:AddCallback( ModCallbacks.MC_USE_PILL, brandner.TaintedUsePills)

--==Universal==--
function brandner:UniversalUpdate()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	
	if player:GetPlayerType() == playerType_Brandner or player:GetPlayerType() == playerType_TaintedBrandner then
		while player:GetMaxHearts() > 0 do
			if player:GetMaxHearts() >= 2 then
				player:AddMaxHearts(-1, true)
			else
				player:AddMaxHearts(-1, true)
				player:AddBoneHearts(1)
				player:AddHearts(2)
			end
		end
	end
end
brandner:AddCallback( ModCallbacks.MC_POST_UPDATE, brandner.UniversalUpdate)

function brandner:UniversalPostUpdate()
	local player = Isaac.GetPlayer(0)
	local roomEntities = Isaac.GetRoomEntities()
	if player:GetPlayerType() == playerType_Brandner or player:GetPlayerType() == playerType_TaintedBrandner then
		for i,entity in ipairs(roomEntities) do
			local tear = entity:ToTear()
			if tear ~= nil then
				if tear.Parent.Type == EntityType.ENTITY_PLAYER and tear.Variant ~= TearVariant.DARK_MATTER then
					local tearSprite = tear:GetSprite()
					tear:ChangeVariant(TearVariant.DARK_MATTER)
					tearSprite:ReplaceSpritesheet(0,"gfx/Brandner_tears.png")
					tearSprite:LoadGraphics("gfx/Brandner_tears.png")
					tearSprite.Rotation = entity.Velocity:GetAngleDegrees()
				end
			end
			local effect = entity:ToEffect()
			if effect ~= nil then
				if effect.Variant == EffectVariant.HOT_BOMB_FIRE then
					local fireSprite = effect:GetSprite()
					fireSprite:ReplaceSpritesheet(0,"gfx/effects/effect_Brandnerbluefire.png")
					fireSprite:LoadGraphics("gfx/effects/effect_Brandnerbluefire.png")
				end
			end
		end
	end
end
brandner:AddCallback( ModCallbacks.MC_POST_UPDATE, brandner.UniversalPostUpdate )

--== Some funny things ==--

function brandner:CharacterInteraction(cmd, params)
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == playerType_Brandner then
		--==Hello==--
		if cmd == "HelloBrandner" or cmd == "helloBrandner" or cmd == "hellobrandner" then
			local RandomNum = math.random(5)
			if RandomNum == 1 then
				print "Brandner:Hello!"
			elseif RandomNum == 2 then
				print "Brandner:Hi!"
			elseif RandomNum == 3 then
				print "Brandner:Hello, player!"
			elseif RandomNum == 4 then
				print "Brandner:What's up?"
			elseif RandomNum == 5 then
				print "Brandner:UuU!"
			end
		end
		--==How're you?==--
		if cmd == "HowreYouBrandner" or cmd == "howreyouBrandner" or cmd == "howreyoubrandner" then
			if player:HasFullHearts() then
				local RandomNum = math.random(3)
				if RandomNum == 1 then
					print "Brandner:Very fine! Thanks for your asking!"
				elseif RandomNum == 2 then
					print "Brandner:Verrrry fine!!!!"
				elseif RandomNum == 3 then
					print "Brandner:Gruuuuuuuu! Fine!"
				end
			end
			if not player:HasFullHearts() and player:GetHearts() >= 1then
				local RandomNum = math.random(3)
				if RandomNum == 1 then
					print "Brandner:Fine, thank you!"
				elseif RandomNum == 2 then
					print "Brandner:I'm fine, thanks OuO"
				elseif RandomNum == 3 then
					print "Brandner:not bad-! UuU"
				end
			end
			if player:GetHearts() <= 0 and player:GetSoulHearts() ~= 0 then
				local RandomNum = math.random(3)
				if RandomNum == 1 then
					print "Brandner:I feel a little weak ;.;"
				elseif RandomNum == 2 then
					print "Brandner:I don't feel like I have enough Hearts, am I ok? ;.;"
				elseif RandomNum == 3 then
					print "Brandner:I don't know how to describe my feelings ;.;"
				end
			end
			if player:GetHearts() <= 0 and player:GetSoulHearts() <= 0 then
				local RandomNum = math.random(3)
				if RandomNum == 1 then
					print "Brandner:No.. Help XAX"
				elseif RandomNum == 2 then
					print "Brandner:I feel terrible.. Help me! XAX"
				elseif RandomNum == 3 then
					print "Brandner:I'm.. I'm scared.. QAQ"
				end
			end
		end
	end
end
brandner:AddCallback(ModCallbacks.MC_EXECUTE_CMD, brandner.CharacterInteraction )