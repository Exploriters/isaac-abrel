local lairub = RegisterMod("Lairub", 1);

local costume_Lairub_Body = Isaac.GetCostumeIdByPath("gfx/characters/LairubBody.anm2")
local costume_Lairub_Head = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead.anm2")
local costume_Lairub_Head_TakeSoul = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead_TakeSoul.anm2")
local playerType_Lairub = Isaac.GetPlayerTypeByName("Lairub")
local LairubStatUpdateItem = Isaac.GetItemIdByName( "Lairub Stat Trigger" )

local ShiftChanged = 1
local IsShiftChanged = true
local PressingShift = false
local PressedShiftOnce = false

local PressingAlt = false
local PressedAltOnce = false


function UpdateCache(player)
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:AddCacheFlags(CacheFlag.CACHE_SPEED)
	player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
end

function lairub:Update(player)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	
	if room:GetFrameCount() == 1 and player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		if ShiftChanged == 1 then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
				player:AddNullCostume(costume_Lairub_Body)
				player:AddNullCostume(costume_Lairub_Head)
			else
				player:TryRemoveNullCostume(costume_Lairub_Body)
				player:AddNullCostume(costume_Lairub_Body)
				player:TryRemoveNullCostume(costume_Lairub_Head)
				player:AddNullCostume(costume_Lairub_Head)
			end
		elseif ShiftChanged == 2 then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
				player:AddNullCostume(costume_Lairub_Body)
				player:AddNullCostume(costume_Lairub_Head_TakeSoul)
			else
				player:TryRemoveNullCostume(costume_Lairub_Body)
				player:AddNullCostume(costume_Lairub_Body)
				player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
				player:AddNullCostume(costume_Lairub_Head_TakeSoul)
			end
		end
	end
	
	if player:GetPlayerType() == playerType_Lairub then
		while player:GetMaxHearts() > 0 do
			player:AddMaxHearts(-2, true)
			player:AddBoneHearts(1)
		end
		if player:GetHearts() > 0 then
			player:AddHearts(-player:GetHearts(), true)
		end
		local soulHearts = player:GetSoulHearts()
		local blackHearts = player:GetBlackHearts()
		local totalHearts = math.ceil(player:GetBoneHearts() + (soulHearts*0.5))
		local boneMisArrangeState = 0
		for i=0,totalHearts-1,1 do
			if boneMisArrangeState == 0 and not player:IsBoneHeart(i) then
				boneMisArrangeState = 1
			elseif boneMisArrangeState == 1 and player:IsBoneHeart(i) then
				boneMisArrangeState = 2
			end
		end
		if boneMisArrangeState == 2
		or blackHearts ~= 2^(math.ceil(soulHearts * 0.5)) - 1
		then
			player:AddSoulHearts(-soulHearts)
			player:AddBlackHearts(soulHearts)
		end
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_UPDATE, lairub.Update)

function lairub:PostPlayerInit(player)
	if player:GetPlayerType() == playerType_Lairub then
		if ShiftChanged == 1 then
			player:TryRemoveNullCostume(costume_Lairub_Body)
			player:AddNullCostume(costume_Lairub_Body)
			player:TryRemoveNullCostume(costume_Lairub_Head)
			player:AddNullCostume(costume_Lairub_Head)
		elseif ShiftChanged == 2 then
			player:TryRemoveNullCostume(costume_Lairub_Body)
			player:AddNullCostume(costume_Lairub_Body)
			player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
			player:AddNullCostume(costume_Lairub_Head_TakeSoul)
		end
		costumeEquipped = true
	else
		player:TryRemoveNullCostume(costume_Lairub_Body)
		player:TryRemoveNullCostume(costume_Lairub_Head)
		player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
		costumeEquipped = false
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, lairub.PostPlayerInit)

function lairub:EvaluateCache(player, cacheFlag)
	if player:GetPlayerType() == playerType_Lairub then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed - 0.5
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 1.3
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay + 12
		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | 1 << 1 | 1 << 2 | 1 << 9
		elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed + 0.5
		elseif cacheFlag == CacheFlag.CACHE_RANGE then
			player.TearHeight = player.TearHeight * 2
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 1
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
				if ShiftChanged == 1 then
					player:TryRemoveNullCostume(costume_Lairub_Body)
					player:AddNullCostume(costume_Lairub_Body)
					player:TryRemoveNullCostume(costume_Lairub_Head)
					player:AddNullCostume(costume_Lairub_Head)
				elseif ShiftChanged == 2 then
					player:TryRemoveNullCostume(costume_Lairub_Body)
					player:AddNullCostume(costume_Lairub_Body)
					player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
					player:AddNullCostume(costume_Lairub_Head_TakeSoul)
				end
			end
		elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
			local maybeFamiliars = Isaac.GetRoomEntities()
			for m = 1, #maybeFamiliars do
				local variant = maybeFamiliars[m].Variant
				if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
					if ShiftChanged == 1 then
						player:TryRemoveNullCostume(costume_Lairub_Body)
						player:AddNullCostume(costume_Lairub_Body)
						player:TryRemoveNullCostume(costume_Lairub_Head)
						player:AddNullCostume(costume_Lairub_Head)
					elseif ShiftChanged == 2 then
						player:TryRemoveNullCostume(costume_Lairub_Body)
						player:AddNullCostume(costume_Lairub_Body)
						player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
						player:AddNullCostume(costume_Lairub_Head_TakeSoul)
					end
				end
			end
		end
		-- Normal -> TakeSoul
		if ShiftChanged == 2 then
			if cacheFlag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed - 0.2
			elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage + 0.3
			elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = player.MaxFireDelay + 10
			end
			IsShiftChanged = true
		end
		-- TakeSoul -> Normal
		if ShiftChanged ==  1 then
			if cacheFlag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed + 0.2
			elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage - 1
			elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = player.MaxFireDelay - 10
			end
			IsShiftChanged = true
		end
		--========--
	end
end
lairub:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, lairub.EvaluateCache)

local AttackIcon = Sprite()
AttackIcon:Load("gfx/Lairub_AttackIcon.anm2", true)
local SoulSign = Sprite()
SoulSign:Load("gfx/Lairub_SoulSign.anm2", true)
local CrossIcon = Sprite()
CrossIcon:Load("gfx/Lairub_CrossIcon.anm2", true)
local ReleaseIcon = Sprite()
ReleaseIcon:Load("gfx/Lairub_ReleaseIcon.anm2", true)

local SoulCount = 0

function lairub:PostRender()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	if player:GetPlayerType() == playerType_Lairub then
		--==SoulSign==--
		SoulSign:SetOverlayRenderPriority(true)
		SoulSign:SetFrame("SoulSign", 1)
		SoulSign:Render(Vector(64,76), Vector(0,0), Vector(0,0))
		Isaac.RenderText(tostring(SoulCount), 78, 70, 255, 255, 255, 255)
		--==AttackIcon==--
		AttackIcon:SetOverlayRenderPriority(true)
			if ShiftChanged == 1 then
				AttackIcon:SetFrame("Normal", 1)
			elseif ShiftChanged == 2 then
				AttackIcon:SetFrame("Take Soul", 1)
			end
		AttackIcon:Render(Vector(64,52), Vector(0,0), Vector(0,0))
		--==CrossIcon==--
		CrossIcon:SetOverlayRenderPriority(true)
		CrossIcon:SetFrame("Locking", 1)
		CrossIcon:Render(Vector(96,52), Vector(0,0), Vector(0,0))
		--==ReleaseIcon==--
		ReleaseIcon:SetOverlayRenderPriority(true)
		if SoulCount > 0 then
			ReleaseIcon:SetFrame("Ready", 1)
		elseif SoulCount <= 0 then
			ReleaseIcon:SetFrame("Locking", 1)
		end
		ReleaseIcon:Render(Vector(128,52), Vector(0,0), Vector(0,0))
		--====--
	end
end
lairub:AddCallback(ModCallbacks.MC_POST_RENDER, lairub.PostRender)

local LairubAnmChangedToTakeSoul_Type = Isaac.GetEntityTypeByName("LairubAnmChangedToTakeSoul")
local LairubAnmChangedToTakeSoul_Variant = Isaac.GetEntityVariantByName("LairubAnmChangedToTakeSoul")

local function LairubAnmChangedToTakeSoulUpdate(_, LairubAnmChangedToTakeSoul)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		LairubAnmChangedToTakeSoul:GetSprite():Play("ChangedToTakeSoul", false)
		if LairubAnmChangedToTakeSoul:GetSprite():IsEventTriggered("End") then
			player.Visible = true
			player.ControlsEnabled = true
			LairubAnmChangedToTakeSoul:Remove()
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubAnmChangedToTakeSoulUpdate, LairubAnmChangedToTakeSoul)

local LairubAnmChangedToNormal_Type = Isaac.GetEntityTypeByName("LairubAnmChangedToNormal")
local LairubAnmChangedToNormal_Variant = Isaac.GetEntityVariantByName("LairubAnmChangedToNormal")

local function LairubAnmChangedToNormalUpdate(_, LairubAnmChangedToNormal)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		LairubAnmChangedToNormal:GetSprite():Play("ChangedToNormal", false)
		if LairubAnmChangedToNormal:GetSprite():IsEventTriggered("End") then
			player.Visible = true
			player.ControlsEnabled = true
			LairubAnmChangedToNormal:Remove()
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubAnmChangedToNormalUpdate, LairubAnmChangedToNormal)

local LairubAnmReleaseSoul_Type = Isaac.GetEntityTypeByName("LairubAnmReleaseSoul")
local LairubAnmReleaseSoul_Variant = Isaac.GetEntityVariantByName("LairubAnmReleaseSoul")

local function LairubAnmReleaseSoulUpdate(_, LairubAnmReleaseSoul)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		LairubAnmReleaseSoul:GetSprite():Play("ReleaseSoul", false)
		if LairubAnmReleaseSoul:GetSprite():IsEventTriggered("LoopEnd") then
			LairubAnmReleaseSoul:GetSprite():SetFrame("ReleaseSoul", 9)
			LairubAnmReleaseSoul:GetSprite():Play("ReleaseSoul", false)
		end
		if LairubAnmReleaseSoul:GetSprite():IsEventTriggered("End") then
			player.Visible = true
			player.ControlsEnabled = true
			LairubAnmReleaseSoul:Remove()
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubAnmReleaseSoulUpdate, LairubAnmReleaseSoul)

function lairub:Functions()
	local level = Game():GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		--==== Changed Tears ====--	
		--== Changed Icon==--
		if Input.IsButtonPressed(Keyboard.KEY_LEFT_SHIFT, player.ControllerIndex) then
			PressingShift = true
			if PressedShiftOnce == false then
				PressedShiftOnce = true
				if ShiftChanged == 1 then
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmChangedToTakeSoul_Variant, 0, player.Position, Vector(0,0), player)
					player.Visible = false
					player.ControlsEnabled = false
					ShiftChanged = 2 
					IsShiftChanged = false
				elseif ShiftChanged == 2 then
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmChangedToNormal_Variant, 0, player.Position, Vector(0,0), player)
					player.Visible = false
					player.ControlsEnabled = false
					ShiftChanged = 1
					IsShiftChanged = false
				end
			end
		else
			PressingShift = false
			PressedShiftOnce = false
		end
		--== Function ==--
		local roomEntities = Isaac.GetRoomEntities()
		for i,entity in ipairs(roomEntities) do
			local tear = entity:ToTear()
			if tear ~= nil then
				if tear.Parent.Type == EntityType.ENTITY_PLAYER then
					local tearSprite = tear:GetSprite()
					if ShiftChanged == 1 then
						tearSprite:ReplaceSpritesheet(0,"gfx/Lairub_Tears_Normal.png")
						tearSprite:LoadGraphics("gfx/Lairub_Tears_Normal.png")
					elseif ShiftChanged == 2 then
						tearSprite:ReplaceSpritesheet(0,"gfx/Lairub_Tears_TakeSoul.png")
						tearSprite:LoadGraphics("gfx/Lairub_Tears_TakeSoul.png")
					end
					tearSprite.Rotation = entity.Velocity:GetAngleDegrees()
				end
			end		
		end
		
		if not IsShiftChanged then
			player:AddCollectible(LairubStatUpdateItem)
			player:RemoveCollectible(LairubStatUpdateItem)
			UpdateCache(player)
			if ShiftChanged == 1 then
				player:TryRemoveNullCostume(costume_Lairub_Body)
				player:AddNullCostume(costume_Lairub_Body)
				player:TryRemoveNullCostume(costume_Lairub_Head)
				player:AddNullCostume(costume_Lairub_Head)
			elseif ShiftChanged == 2 then
				player:TryRemoveNullCostume(costume_Lairub_Body)
				player:AddNullCostume(costume_Lairub_Body)
				player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
				player:AddNullCostume(costume_Lairub_Head_TakeSoul)
			end
		end
		--==== Release Soul ====--
		if Input.IsButtonPressed(Keyboard.KEY_LEFT_ALT, player.ControllerIndex) then
			player.ControlsEnabled = false
			PressingAlt = true
			if PressedAltOnce == false then
				PressedAltOnce = true
				--Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmReleaseSoul_Variant, 0, player.Position, Vector(0,0), player)
			end
			if SoulCount > 0 then
				for i,entity in ipairs(roomEntities) do
					local NPC = entity:ToNPC()
					if NPC ~= nil and NPC:IsVulnerableEnemy() then
						if (player.Position - NPC.Position):Length() < 192 then
							SoulCount = SoulCount - 1
							NPC:TakeDamage(player.Damage, 0, EntityRef(player), 0)
							if SoulCount < 0 then
								SoulCount = 0
							end
						end
					end
				end
			end
		else
			player.ControlsEnabled = true
			PressingAlt = false
			PressedAltOnce = false
		end
		--========--
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_UPDATE, lairub.Functions)

function lairub:PostNPCDeath()
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == playerType_Lairub and ShiftChanged == 2 and not Input.IsButtonPressed(Keyboard.KEY_LEFT_ALT, player.ControllerIndex) then
		SoulCount = SoulCount + 1
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_NPC_DEATH, lairub.PostNPCDeath)

function lairub:PostNewLevel()
	SoulCount = 0
end
lairub:AddCallback( ModCallbacks.MC_POST_NEW_LEVEL, lairub.PostNewLevel)

function lairub:PostNewGame()
	ShiftChanged = 1
	PressingShift = false
	PressedShiftOnce = false
	IsShiftChanged = true
	SoulCount = 0
	PressingAlt = false
	PressedAltOnce = false
end
lairub:AddCallback( ModCallbacks.MC_POST_GAME_STARTED, lairub.PostNewGame)