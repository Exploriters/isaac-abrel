
local playerType_Lairub = Isaac.GetPlayerTypeByName("Lairub")
local playerType_Tainted_Lairub = Isaac.GetPlayerTypeByName("Tainted Lairub", true)

local function IsLairub(player)
	return player ~= nil and player:GetPlayerType() == playerType_Lairub
end

local function IsLairubTainted(player)
	return player ~= nil and player:GetPlayerType() == playerType_Tainted_Lairub
end

--==Tainted==--

LairubMod.Tainted = {}

local LastRoom = {}

function LairubMod.Tainted.ApplyVar(objective)
end

function LairubMod.Tainted.RecieveVar(objective)
end

function LairubMod.Tainted.UpdateLastRoomVar()
	LastRoom = {}
end

function LairubMod.Tainted.RewindLastRoomVar()
end

function LairubMod.Tainted.WipeTempVar()
	--[[
	ReadyAttack = false
	Attacked = true
	Invincible = false
	InvincibleEnd = true
	LevelKillCount = 0
	RoomKillCount = 0
	LevelDevourOnce = false
	BoneCount = 0
	]]
end

local costume_TaintedLairub_Body = Isaac.GetCostumeIdByPath("gfx/characters/TaintedLairubBody.anm2")
local costume_TaintedLairub_Head = Isaac.GetCostumeIdByPath("gfx/characters/TaintedLairubHead.anm2")

--UNFINISHED--
function LairubMod.Tainted:UnfinishedPostRender()
	if PlayerTypeExistInGame(playerType_Tainted_Lairub) then
		Explorite.RenderText("Unfinished, please wait for the update.", 78, 70, 1, 0, 0, 255)
	end
end
LairubMod:AddCallback(ModCallbacks.MC_POST_RENDER, LairubMod.Tainted.UnfinishedPostRender)

function LairubMod.Tainted:UnfinishedUpdate(player)
	if IsLairubTainted(player) then
		player.ControlsEnabled = false
		player.Visible = false
	end
end
LairubMod:AddCallback( ModCallbacks.MC_POST_PLAYER_UPDATE, LairubMod.Tainted.UnfinishedUpdate)

--[[
--==Shift(Devour)==--
local ReadyAttack = false
local Attacked = true
local Invincible = false
local InvincibleEnd = true
local LevelKillCount = 0
local RoomKillCount = 0
local LevelDevourOnce = false
local BoneCount = 0

local ReleaseIcon_Blood = Sprite()
ReleaseIcon_Blood:Load("gfx/Lairub_ReleaseIcon_Blood.anm2", true)
local AttackIcon_Tainted = Sprite()
AttackIcon_Tainted:Load("gfx/Lairub_AttackIcon_Tainted.anm2", true)

function lairub:TaintedPostRender()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	local playerPos = room:WorldToScreenPosition(player.Position)
	if IsLairubTainted(player) then
		--==== Can Hide ====--
		if not IsLairubButtonPressed(player,"hide_ui") then
			--==SoulSign==--
			SoulSign:SetOverlayRenderPriority(true)
			SoulSign:SetFrame("SoulSign", 1)
			SoulSign:Render(Vector(64,76), Vector(0,0), Vector(0,0))
			Explorite.RenderText(tostring(SoulCount), 78, 70, 255, 255, 255, 255)
			--==ReleaseIcon==--
			ReleaseIcon_Blood:SetOverlayRenderPriority(true)
			if SoulCount > 0 then
				ReleaseIcon_Blood:SetFrame("Ready", 1)
			elseif SoulCount <= 0 then
				ReleaseIcon_Blood:SetFrame("Locking", 1)
			end
			ReleaseIcon_Blood:Render(Vector(128,52), Vector(0,0), Vector(0,0))
			--==AttackIcon==--
			AttackIcon_Tainted:SetOverlayRenderPriority(true)
			if ReadyAttack == false then
				AttackIcon_Tainted:SetFrame("Normal", 1)
			elseif ReadyAttack == true then
				AttackIcon_Tainted:SetFrame("Attack", 1)
			end
			AttackIcon_Tainted:Render(Vector(64,52), Vector(0,0), Vector(0,0))
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_POST_RENDER, lairub.TaintedPostRender)

function lairub:TaintedUpdate()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	
	if room:GetFrameCount() == 1 and IsLairubTainted(player) and not player:IsDead() then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
			player:AddNullCostume(costume_TaintedLairub_Body)
			player:AddNullCostume(costume_TaintedLairub_Head)
		else
			player:TryRemoveNullCostume(costume_TaintedLairub_Body)
			player:AddNullCostume(costume_TaintedLairub_Body)
			player:TryRemoveNullCostume(costume_TaintedLairub_Head)
			player:AddNullCostume(costume_TaintedLairub_Head)
		end
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_UPDATE, lairub.TaintedUpdate)

function lairub:TaintedPostPlayerInit(player)
	if IsLairubTainted(player) then
		player:TryRemoveNullCostume(costume_TaintedLairub_Body)
		player:AddNullCostume(costume_TaintedLairub_Body)
		player:TryRemoveNullCostume(costume_TaintedLairub_Head)
		player:AddNullCostume(costume_TaintedLairub_Head)
		costumeEquipped = true
	else
		player:TryRemoveNullCostume(costume_TaintedLairub_Body)
		player:TryRemoveNullCostume(costume_TaintedLairub_Head)
		costumeEquipped = false
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, lairub.TaintedPostPlayerInit)

function lairub:TaintedEvaluateCache(player, cacheFlag)
	if IsLairubTainted(player) then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed - 0.2
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 1.5
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 6
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay + 2
		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | 1 << 1 | 1 << 2 | 1 << 9
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
				player:TryRemoveNullCostume(costume_TaintedLairub_Body)
				player:AddNullCostume(costume_TaintedLairub_Body)
				player:TryRemoveNullCostume(costume_TaintedLairub_Head)
				player:AddNullCostume(costume_TaintedLairub_Head)
			end
			player.CanFly = true
		elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
			local maybeFamiliars = Isaac.GetRoomEntities()
			for m = 1, #maybeFamiliars do
				local variant = maybeFamiliars[m].Variant
				if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
					player:TryRemoveNullCostume(costume_TaintedLairub_Body)
					player:AddNullCostume(costume_TaintedLairub_Body)
					player:TryRemoveNullCostume(costume_TaintedLairub_Head)
					player:AddNullCostume(costume_TaintedLairub_Head)
				else
					player:TryRemoveNullCostume(costume_TaintedLairub_Body)
					player:AddNullCostume(costume_TaintedLairub_Body)
					player:TryRemoveNullCostume(costume_TaintedLairub_Head)
					player:AddNullCostume(costume_TaintedLairub_Head)
				end
			end
		end
	end
end
lairub:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, lairub.TaintedEvaluateCache )

function lairub:LockingPostRender()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	if IsLairubTainted(player) then
		Explorite.RenderText("I'm trying to update!! TAT", 50, 60, 255, 0, 0, 255)
	end
end
lairub:AddCallback(ModCallbacks.MC_POST_RENDER, lairub.LockingPostRender)

function lairub:playerDamage(tookDamage, damage, damageFlags, damageSourceRef)
	if Invincible == true and InvincibleEnd == false then
		InvincibleEnd = true
		return false
	end
end
lairub:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, lairub.playerDamage, EntityType.ENTITY_PLAYER)

local TheAttackMarker_Type = Isaac.GetEntityTypeByName("TheAttackMarker")
local TheAttackMarker_Variant = Isaac.GetEntityVariantByName("TheAttackMarker")
local LairubTheBone_Type = Isaac.GetEntityTypeByName("LairubTheBone")
local LairubTheBone_Variant = Isaac.GetEntityVariantByName("LairubTheBone")

local function TheAttackMarkerUpdate(_, TheAttackMarker)
	local level = Game():GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	if IsLairubTainted(player) and not player:IsDead() then
		TheAttackMarker:GetSprite().Scale = Vector(1.5,1.5)
		if ReadyAttack == true then
			--Move
			TheAttackMarker:GetSprite():Play("TheAttackMarker", false)
			if IsLairubButtonPressed(player,"left") then
				TheAttackMarker.Position = TheAttackMarker.Position + Vector(-16, 0)
			end
			if IsLairubButtonPressed(player,"right") then
				TheAttackMarker.Position = TheAttackMarker.Position + Vector(16, 0)
			end
			if IsLairubButtonPressed(player,"up") then
				TheAttackMarker.Position = TheAttackMarker.Position + Vector(0, -16)
			end
			if IsLairubButtonPressed(player,"down") then
				TheAttackMarker.Position = TheAttackMarker.Position + Vector(0, 16)
			end
			--Attack
			if Attacked == false and PressedShiftOnce == true then
				for i,entity in ipairs(roomEntities) do
					local NPC = entity:ToNPC()
					if NPC ~= nil and (TheAttackMarker.Position - NPC.Position):Length() <= 40 then
						if NPC:IsVulnerableEnemy() and NPC.HitPoints <= player.Damage * 2 then
							if PressingShift == true then
								Invincible = true
								InvincibleEnd = false
								NPC:TakeDamage(9999, 0, EntityRef(player), 0)
								SoulCount = SoulCount + 1
								LevelKillCount = LevelKillCount + 1
								RoomKillCount = RoomKillCount + 1
								player.Position = TheAttackMarker.Position
								if not NPC:IsBoss() then
									if RoomKillCount <= 3 then
										Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubTheBone_Variant, 0, NPC.Position, Vector(0,0), player)
									end
									Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubSoulEffect_Variant, 0, NPC.Position, Vector(0,0), player)
								end
								ReadyAttack = false
								Attacked = true
							end
							if InvincibleEnd == true then
								Invincible = false
							end
							--player.ControlsEnabled = true
						end
					elseif NPC == nil or (NPC ~= nil and (TheAttackMarker.Position - NPC.Position):Length() > 40) then
						Attacked = true
						ReadyAttack = false
					end
				end
			end
			if level:GetStage() == 13 then
				for i,entity in ipairs(roomEntities) do
					local NPC = entity:ToNPC()
					if NPC ~= nil and (TheAttackMarker.Position - NPC.Position):Length() <= 80 then
						if NPC:IsVulnerableEnemy() and NPC.HitPoints <= player.Damage * 1.2 then
							NPC:TakeDamage(9999, 0, EntityRef(player), 0)
							if not NPC:IsBoss() then
								Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubSoulEffect_Variant, 0, NPC.Position, Vector(0,0), player)
							end
							SoulCount = SoulCount + 1
						end
					end
				end
			end
			----
		elseif ReadyAttack == false then
			--player.ControlsEnabled = true
			TheAttackMarker:Remove()
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,TheAttackMarkerUpdate, TheAttackMarker_Variant)

local function LairubTheBoneUpdate(_, LairubTheBone)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	
	if LairubTheBone.FireCooldown < 1 then
		for i,entity in ipairs(roomEntities) do
			local NPC = entity:ToNPC()
			if NPC ~= nil and NPC:IsVulnerableEnemy() then
				if (LairubTheBone.Position - NPC.Position):Length() < 128 then
					local Laser = player:FireTechLaser(LairubTheBone.Position, 1, (NPC.Position - LairubTheBone.Position), false, true)
					Laser.CollisionDamage = player.Damage * 0.2
					local LaserSprite = Laser:GetSprite()
					LaserSprite:ReplaceSpritesheet(0,"gfx/effects/effect_LairubLaserEffects.png")
					LaserSprite:LoadGraphics("gfx/effects/effect_LairubLaserEffects.png")
				--NPCdis = 0
			--	elseif (LairubTheBone.Position - NPC.Position):Length() > NPCdis then
				--	NPCdis = NPCdis + 64
				end
			end
		end
		LairubTheBone.FireCooldown = math.ceil(player.MaxFireDelay)
	else
		LairubTheBone.FireCooldown = LairubTheBone.FireCooldown - 1
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubTheBoneUpdate, LairubTheBone_Variant)

function lairub:TaintedFunctions()
	local level = Game():GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	if IsLairubTainted(player) and not player:IsDead() then
		--==== Eating Children(?Not)... Devour ====--
		if IsLairubButtonPressed(player,"swap_form") then
			PressingShift = true
			if PressedShiftOnce == false then
				PressedShiftOnce = true
				if ReadyAttack == false and Attacked == true then
					player:AddControlsCooldown(2)--player.ControlsEnabled = false
					AttackMarker = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, TheAttackMarker_Variant, 0, player.Position, Vector(0,0), player)
					AttackMarker:GetSprite().Scale = Vector(1.5,1.5)
					AttackMarker:GetSprite():Play("TheAttackMarker", false)
					ReadyAttack = true
					Attacked = false
				end
			end
		else
			PressingShift = false
			PressedShiftOnce = false
		end
		if LevelKillCount == 1 and LevelDevourOnce == false then
			LevelDevourOnce = true
			player:AddBoneHearts(1)
			AttackMarker = Isaac.Spawn(EntityType.ENTITY_EFFECT, 49, 0, Vector(player.Position.X, player.Position.Y - 40), Vector(0,0), player)
		end
		if RoomKillCount < 3 then
			for i,entity in ipairs(roomEntities) do
				local NPC = entity:ToNPC()
				if NPC ~= nil and NPC:IsDead() then
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubTheBone_Variant, 0, NPC.Position, Vector(0,0), player)
				end
			end
			--BoneCount = BoneCount + 1
		end
		--==== Release Soul ====--
		if IsLairubButtonPressed(player,"release_souls") and not IsLairubButtonPressed(player,"swap_form") then
			player:AddControlsCooldown(2)--player.ControlsEnabled = false
			player.Visible = false
			PressingAlt = true
			if PressedAltOnce == false then
				PressedAltOnce = true
				Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmReleaseSoul_Variant, 0, player.Position, Vector(0,0), player)
			end
			if SoulCount > 0 then
				for i,entity in ipairs(roomEntities) do
					local NPC = entity:ToNPC()
					if NPC ~= nil and NPC:IsVulnerableEnemy() and not NPC:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
						if (player.Position - NPC.Position):Length() < 192 or level:GetStage() == 13 then
							SoulCount = SoulCount - 1
							NPC:TakeDamage(player.Damage * 1.6, 0, EntityRef(player), 0)
							NPC:SetColor(Color(0, 0, 0, 1, 0, 0, 0), 30, 999, true, true)
							if SoulCount < 0 then
								SoulCount = 0
							end
						end
					end
				end
			end
		else
			PressingAlt = false
			PressedAltOnce = false
		end
		--========--
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_UPDATE, lairub.TaintedFunctions)

function LairubMod:PostNewLevel()
	LevelKillCount = 0
	LevelDevourOnce = false
end
LairubMod:AddCallback( ModCallbacks.MC_POST_NEW_LEVEL, LairubMod.PostNewLevel)

function LairubMod:PostNewRoom()
	RoomKillCount = 0
	BoneCount = 0
end
LairubMod:AddCallback( ModCallbacks.MC_POST_NEW_ROOM, LairubMod.PostNewRoom)
]]--
