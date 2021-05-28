local lairub = RegisterMod("Lairub", 1);

--==Costume and something else==--
local costume_Lairub_Body = Isaac.GetCostumeIdByPath("gfx/characters/LairubBody.anm2")
local costume_Lairub_Head = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead.anm2")
local costume_Lairub_Head_TakeSoul = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead_TakeSoul.anm2")
local costume_Lairub_Head_TakeSoulBase = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead_TakeSoulBase.anm2")
local playerType_Lairub = Isaac.GetPlayerTypeByName("Lairub")
local LairubStatUpdateItem = Isaac.GetItemIdByName( "Lairub Stat Trigger" )
--==Animation==--
local AnimationEnd = true
local AnimationEnd_ReadySpawnCross = true
--==Shift(Changed TakeSoul)==--
local ShiftChanged = 1
local IsShiftChanged = true
local PressingShift = false
local PressedShiftOnce = false
--==Alt(Release Soul)==--
local PressingAlt = false
local PressedAltOnce = false
--==Ctrl(Spawn Soul Cross)==--
local PressingCtrl = false
local PressedCtrlOnce = false
--==Soul Cross==--
local ReadySpawnCross = false
local DetermineDirection = false
local SpawnedCross = false

--==Z(Talk to player)==--
local PressingZ = false
local PressedZOnce = false
local DialogueOver = false
local Dialogue = 0

--==X(Teleport To Devil Room)==--
local PressingX = false
local PressedXOnce = false
local LairubTeleportReadyTime = 0

--==Be Hunted Down In Stage10, BackdropType14(Sheol) And Stage11, BackdropType16(DarkRoom)==--
--Dialogue(Sheol)--
local DialogueOver_Sheol = false
local Dialogue_Sheol = 0
--Function--
local DMGframeCount = 90
local DMGcount = 0
local CountDown = 60
local DMGCountDown = 3

local AnmTalkStat = true
local FinishedTalkAnmPart = 0
local FinishedTalkAnmPart_Sheol = 0

--==== Store mod Data ====--
keyValuePair = {key = "", value = ""}
keyValuePair.__index = keyValuePair

local LairubObjectives = { }
LairubObjectives.__index = LairubObjectives

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

function LairubObjectives_Wipe()
	LairubObjectives = { }
end

function LairubObjectives_Read(key, default)
	for i, kvp in ipairs(LairubObjectives) do
		if kvp.key == key then
			return kvp.value
		end
	end
	return default
end

function LairubObjectives_Write(key, value)
	for i, kvp in ipairs(LairubObjectives) do
		if kvp.key  == key then
			kvp.value = value
			return value
		end
	end
	table.insert(LairubObjectives, KeyValuePair(key, value))
	return value
end

function LairubObjectives_Apply()
	local DialogueOverStr = LairubObjectives_Read("DialogueOver", "false")
	if DialogueOverStr == "true" then
		DialogueOver = true
	elseif DialogueOverStr == "false" then
		DialogueOver = false
	else
		DialogueOver = nil
	end
end

function LairubObjectives_Recieve()
	LairubObjectives_Write("DialogueOver", tostring(DialogueOver))
end

function LairubObjectives_ToString()
	local str = ""
	for i,kvp in ipairs(LairubObjectives) do
		str = str..tostring(kvp.key).."="..tostring(kvp.value).."\n"
	end
	return str
end

function LairubObjectives_LoadFromString(str)
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
		table.insert(strTable, string.sub(str, pointer1 + 1, pointer2 -1))
		count = count + 1
	end
	for i, str in ipairs(strTable) do
		local point = string.find(str, "=", 1)
		if point ~= nil then
			local key = string.sub(str, 1, point - 1)
			local value = string.sub(str, point + 1, 256)
			LairubObjectives_Write(key, value)
			
		end
	end
end
--==Read==--
function LoadLairubModData()
	local str = "Error"
	if Isaac.HasModData(lairub) then
		str = Isaac.LoadModData(lairub, "ERROR\nERROR\nERROR\nI HATE YOU")
	end
	LairubObjectives_Wipe()
	LairubObjectives_LoadFromString(str)
	LairubObjectives_Apply()
end
--==Write==--
function SaveLairubModData()
	LairubObjectives_Recieve()
	local str = LairubObjectives_ToString()
	Isaac.SaveModData(lairub, str)
end
--==Post game started==--
function lairub:PostGameStarted(loadedFromSaves)
	if not loadedFromSaves then
		LoadLairubModData()
		DialogueOver = false
		SaveLairubModData()
	else
		DialogueOver = false
		LoadLairubModData()
	end
end
lairub:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, lairub.PostGameStarted)

function lairub:PreGameExit(shouldSave)
	SaveLairubModData()
	DialogueOver = false
end
lairub:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, lairub.PreGameExit)
--================================--

--================================--

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
	--==Costume==--
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
				player:AddNullCostume(costume_Lairub_Head_TakeSoulBase)
			else
				player:TryRemoveNullCostume(costume_Lairub_Body)
				player:AddNullCostume(costume_Lairub_Body)
				player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
				player:AddNullCostume(costume_Lairub_Head_TakeSoul)
				player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
				player:AddNullCostume(costume_Lairub_Head_TakeSoulBase)
			end
		end
	end

	if player:GetPlayerType() == playerType_Lairub then
		--==Hearts Limit==--
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
		--====--
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
			player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
			player:AddNullCostume(costume_Lairub_Head_TakeSoulBase)
		end
		costumeEquipped = true
	else
		player:TryRemoveNullCostume(costume_Lairub_Body)
		player:TryRemoveNullCostume(costume_Lairub_Head)
		player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
		player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
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
					player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
					player:AddNullCostume(costume_Lairub_Head_TakeSoulBase)
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
						player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
						player:AddNullCostume(costume_Lairub_Head_TakeSoulBase)
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
local TeleportSign = Sprite()
TeleportSign:Load("gfx/Lairub_TeleportSign.anm2", true)

local SoulCount = 0

function lairub:PostRender()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	local playerPos = room:WorldToScreenPosition(player.Position)
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
		if SpawnedCross == true then
			CrossIcon:SetFrame("Locking", 1)
		else
			CrossIcon:SetFrame("Ready", 1)
		end
		CrossIcon:Render(Vector(96,52), Vector(0,0), Vector(0,0))
		--==ReleaseIcon==--
		ReleaseIcon:SetOverlayRenderPriority(true)
		if SoulCount > 0 then
			ReleaseIcon:SetFrame("Ready", 1)
		elseif SoulCount <= 0 then
			ReleaseIcon:SetFrame("Locking", 1)
		end
		ReleaseIcon:Render(Vector(128,52), Vector(0,0), Vector(0,0))
		--==Teleport To Devil Room==--
		TeleportSign:SetOverlayRenderPriority(true)
		TeleportSign:SetFrame("TeleportSign", 1)
		TeleportSign:Render(Vector(112,76), Vector(0,0), Vector(0,0))
		Isaac.RenderScaledText("'X'", 120, 70, 0.9, 0.9, 255, 255, 255, 255)
		--==Talk to player==--
		if DialogueOver == false and level:GetStage() == 13 then
			--Lowest Y = -64--
			Isaac.RenderText("(Press 'Z' to continue)", playerPos.X - 64, playerPos.Y - 64, 255, 255, 255, 255)
			if Dialogue == 0 then
				Isaac.RenderText("Lairub:", playerPos.X - 96, playerPos.Y - 84, 255, 255, 255, 255)
				Isaac.RenderText("...", playerPos.X - 96, playerPos.Y - 74, 255, 255, 255, 255)
			elseif Dialogue == 1 then
				Isaac.RenderText("Lairub:", playerPos.X - 96, playerPos.Y - 94, 255, 255, 255, 255)
				Isaac.RenderText("It seems that we have a stronger", playerPos.X - 96, playerPos.Y - 84, 255, 255, 255, 255)
				Isaac.RenderText("enemy to deal with.", playerPos.X - 96, playerPos.Y - 74, 255, 255, 255, 255)
			elseif Dialogue == 2 then
				Isaac.RenderText("Lairub:", playerPos.X - 96, playerPos.Y - 94, 255, 255, 255, 255)
				Isaac.RenderText("For the next battle, my skill 'Release Soul'", playerPos.X - 96, playerPos.Y - 84, 255, 255, 255, 255)
				Isaac.RenderText("has been enhanced to full screen.", playerPos.X - 96, playerPos.Y - 74, 255, 255, 255, 255)
			elseif Dialogue == 3 then
				Isaac.RenderText("Lairub:", playerPos.X - 96, playerPos.Y - 84, 255, 255, 255, 255)
				Isaac.RenderText("Good luck.", playerPos.X - 96, playerPos.Y - 74, 255, 255, 255, 255)
			elseif Dialogue == 4 then
				Isaac.RenderText("Lairub:", playerPos.X - 96, playerPos.Y - 84, 255, 255, 255, 255)
				Isaac.RenderText("...And that bed doesn't work for me.", playerPos.X - 96, playerPos.Y - 74, 255, 255, 255, 255)
			end
		end
		--==Be Hunted Down In Stage10, BackdropType14(Sheol) And Stage11, BackdropType16(DarkRoom)==-
		--==Dialogue(Sheol)==--
		if DialogueOver_Sheol == false and level:GetStage() == 10 and room:GetBackdropType() == 14 then
			Isaac.RenderText("(Press 'Z' to continue)", playerPos.X - 64, playerPos.Y - 64, 255, 255, 255, 255)
			if Dialogue_Sheol == 0 then
				Isaac.RenderText("Lairub:", playerPos.X - 96, playerPos.Y - 84, 255, 255, 255, 255)
				Isaac.RenderText("...What", playerPos.X - 96, playerPos.Y - 74, 255, 255, 255, 255)
			elseif Dialogue_Sheol == 1 then
				Isaac.RenderText("Lairub:", playerPos.X - 96, playerPos.Y - 84, 255, 255, 255, 255)
				Isaac.RenderText("Wh-What are you doing? This is my home!", playerPos.X - 96, playerPos.Y - 74, 255, 255, 255, 255)
			elseif Dialogue_Sheol == 2 then
				Isaac.RenderText("Lairub:", playerPos.X - 96, playerPos.Y - 84, 255, 255, 255, 255)
				Isaac.RenderText("If I'm reckless here, It-It'll kill me!", playerPos.X - 96, playerPos.Y - 74, 255, 255, 255, 255)
			elseif Dialogue_Sheol == 3 then
				Isaac.RenderText("Lairub:", playerPos.X - 96, playerPos.Y - 84, 255, 255, 255, 255)
				Isaac.RenderText("...*Sigh*", playerPos.X - 96, playerPos.Y - 74, 255, 255, 255, 255)
			elseif Dialogue_Sheol == 4 then
				Isaac.RenderText("Lairub:", playerPos.X - 96, playerPos.Y - 84, 255, 255, 255, 255)
				Isaac.RenderText("All right, whatever you want.", playerPos.X - 96, playerPos.Y - 74, 255, 255, 255, 255)
			end
		end
		--==CountDown==--
		if (level:GetStage() == 10 and room:GetBackdropType() == 14) or (level:GetStage() == 11 and room:GetBackdropType() == 16) then
			if DialogueOver_Sheol == false and level:GetStage() == 10 and room:GetBackdropType() == 14 then
				--Do nothing
			else
				if room:IsClear() then
					Isaac.RenderScaledText("00", 200, 60, 2, 2, 1, 1, 1, 1)
					Isaac.RenderScaledText("safe", 200, 80, 0.9, 0.9, 1, 1, 1, 1)
				elseif room:GetType() == RoomType.ROOM_BOSS then
					Isaac.RenderScaledText("00", 200, 60, 2, 2, 1, 0.5, 0.5, 0.8)
					Isaac.RenderScaledText("BOSS", 200, 80, 0.9, 0.9, 1, 0.5, 0.5, 0.8)
				elseif not (room:IsClear() and room:GetType() == RoomType.ROOM_BOSS) then
					if room:GetFrameCount() <= 1800 then
						if CountDown < 10 then
							Isaac.RenderScaledText("0"..tostring(CountDown), 200, 60, 2, 2, 1, 0.5, 0.5, 0.8)
						else
							Isaac.RenderScaledText(tostring(CountDown), 200, 60, 2, 2, 1, 0.5, 0.5, 0.8)
						end
						Isaac.RenderScaledText("Vigilant", 190, 80, 0.9, 0.9, 1, 0.5, 0.5, 0.8)
					elseif room:GetFrameCount() >= 1800 then
						Isaac.RenderScaledText("0"..tostring(DMGCountDown), 200, 60, 2, 2, 1, 0, 0, 0.8)
						Isaac.RenderScaledText("DANGER", 192, 80, 0.9, 0.9, 1, 0, 0, 0.8)
					end
				end
			end
		end
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
			AnimationEnd = true
			LairubAnmChangedToTakeSoul:Remove()
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubAnmChangedToTakeSoulUpdate, LairubAnmChangedToTakeSoul_Variant)

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
			AnimationEnd = true
			LairubAnmChangedToNormal:Remove()
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubAnmChangedToNormalUpdate, LairubAnmChangedToNormal_Variant)

local LairubAnmReleaseSoul_Type = Isaac.GetEntityTypeByName("LairubAnmReleaseSoul")
local LairubAnmReleaseSoul_Variant = Isaac.GetEntityVariantByName("LairubAnmReleaseSoul")

local function LairubAnmReleaseSoulUpdate(_, LairubAnmReleaseSoul)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		LairubAnmReleaseSoul:GetSprite():Play("ReleaseSoul", false)
		if LairubAnmReleaseSoul:GetSprite():IsEventTriggered("End") then
			if PressingAlt == false then
				player.ControlsEnabled = true
				player.Visible = true
				AnimationEnd = true
				LairubAnmReleaseSoul:Remove()
			end
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubAnmReleaseSoulUpdate, LairubAnmReleaseSoul_Variant)

local LairubSoulCross_Type = Isaac.GetEntityTypeByName("LairubSoulCross")
local LairubSoulCross_Variant = Isaac.GetEntityVariantByName("LairubSoulCross")

local NPCdis = 0

local function LairubSoulCrossUpdate(_, LairubSoulCross)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	
	local posX = math.floor(LairubSoulCross.Position.X/40.0)*40
	local posY = math.floor(LairubSoulCross.Position.Y/40.0)*40
	LairubSoulCross.Position = Vector(posX, posY)
	LairubSoulCross.Velocity = Vector(0, 0)
	
	if LairubSoulCross.FireCooldown < 1 then
		for i,entity in ipairs(roomEntities) do
			local NPC = entity:ToNPC()
			if NPC ~= nil and NPC:IsVulnerableEnemy() then
				if (LairubSoulCross.Position - NPC.Position):Length() < NPCdis then
					local Laser = player:FireTechLaser(LairubSoulCross.Position, 1, (NPC.Position - LairubSoulCross.Position), false, true)
					Laser.CollisionDamage = player.Damage * 0.5
					local LaserSprite = Laser:GetSprite()
					LaserSprite:ReplaceSpritesheet(0,"gfx/effects/effect_LairubLaserEffects.png")
					LaserSprite:LoadGraphics("gfx/effects/effect_LairubLaserEffects.png")
					NPCdis = 0
				elseif (LairubSoulCross.Position - NPC.Position):Length() > NPCdis then
					NPCdis = NPCdis + 64
				end
			end
		end
		LairubSoulCross.FireCooldown = math.ceil(player.MaxFireDelay)
	else
		LairubSoulCross.FireCooldown = LairubSoulCross.FireCooldown - 1
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubSoulCrossUpdate, LairubSoulCross_Variant)

local function PreFamiliarCollision(Fam, Collider, Low)
	if Fam.Variant == LairubSoulCross_Variant then
		print("respown to collision")
		return true
	end
end
lairub:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION,PreFamiliarCollision)


local LairubAnmReadySpawnCross_Type = Isaac.GetEntityTypeByName("LairubAnmReadySpawnCross")
local LairubAnmReadySpawnCross_Variant = Isaac.GetEntityVariantByName("LairubAnmReadySpawnCross")

local function LairubAnmReadySpawnCrossUpdate(_, LairubAnmReadySpawnCross)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	
	
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		LairubAnmReadySpawnCross:GetSprite():Play("ReadySpawnCross", false)
		if LairubAnmReadySpawnCross:GetSprite():WasEventTriggered("End") then
			AnimationEnd_ReadySpawnCross = true
		end
		if ReadySpawnCross == false or DetermineDirection == true then
			player.Visible = true
			player.ControlsEnabled = true
			LairubAnmReadySpawnCross:Remove()
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubAnmReadySpawnCrossUpdate, LairubAnmReadySpawnCross_Variant)

local LairubSoulEffect_Type = Isaac.GetEntityTypeByName("LairubSoulEffect")
local LairubSoulEffect_Variant = Isaac.GetEntityVariantByName("LairubSoulEffect")

local function LairubSoulEffectUpdate(_, LairubSoulEffect)
	LairubSoulEffect:GetSprite():Play("SoulEffect", false)
	if LairubSoulEffect:GetSprite():WasEventTriggered("End") then
		LairubSoulEffect:Remove()
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubSoulEffectUpdate, LairubSoulEffect_Variant)

local LairubAnmTalkNormal_Type = Isaac.GetEntityTypeByName("LairubAnmTalkNormal")
local LairubAnmTalkNormal_Variant = Isaac.GetEntityVariantByName("LairubAnmTalkNormal")

local function LairubAnmTalkNormalUpdate(_, LairubAnmTalkNormal)
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		if PressedZOnce == true or Dialogue == 3 then
			LairubAnmTalkNormal:Remove()
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubAnmTalkNormalUpdate, LairubAnmTalkNormal_Variant)

local LairubAnmTalkHappy_Type = Isaac.GetEntityTypeByName("LairubAnmTalkHappy")
local LairubAnmTalkHappy_Variant = Isaac.GetEntityVariantByName("LairubAnmTalkHappy")

local function LairubAnmTalkHappyUpdate(_, LairubAnmTalkHappy)
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		if PressedZOnce == true then
			LairubAnmTalkHappy:Remove()
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubAnmTalkHappyUpdate, LairubAnmTalkHappy_Variant)

local LairubAnmTalkFear_Type = Isaac.GetEntityTypeByName("LairubAnmTalkFear")
local LairubAnmTalkFear_Variant = Isaac.GetEntityVariantByName("LairubAnmTalkFear")

local function LairubAnmTalkFearUpdate(_, LairubAnmTalkFear)
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		if PressedZOnce == true or Dialogue_Sheol == 3 then
			LairubAnmTalkFear:Remove()
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubAnmTalkFearUpdate, LairubAnmTalkFear_Variant)

local LairubAnmTalkSigh_Type = Isaac.GetEntityTypeByName("LairubAnmTalkSigh")
local LairubAnmTalkSigh_Variant = Isaac.GetEntityVariantByName("LairubAnmTalkSigh")

local function LairubAnmTalkSighUpdate(_, LairubAnmTalkSigh)
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		if PressedZOnce == true then
			LairubAnmTalkSigh:Remove()
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubAnmTalkSighUpdate, LairubAnmTalkSigh_Variant)

local LairubAnmTeleportToDevilRoom_Type = Isaac.GetEntityTypeByName("LairubAnmTeleportToDevilRoom")
local LairubAnmTeleportToDevilRoom_Variant = Isaac.GetEntityVariantByName("LairubAnmTeleportToDevilRoom")

local function LairubAnmTeleportToDevilRoomUpdate(_, LairubAnmTeleportToDevilRoom)
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		LairubTeleportReadyTime = LairubTeleportReadyTime + 1
		if LairubTeleportReadyTime == 180 then
			player.Visible = true
			player.ControlsEnabled = true
			player:UseCard(Card.CARD_JOKER)
			LairubAnmTeleportToDevilRoom:Remove()
		end
		if PressingX == false then
			player.Visible = true
			player.ControlsEnabled = true
			LairubTeleportReadyTime = 0
			LairubAnmTeleportToDevilRoom:Remove()
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubAnmTeleportToDevilRoomUpdate, LairubAnmTeleportToDevilRoom_Variant)

function lairub:Functions()
	local level = Game():GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		--==== Changed Tears ====--	
		--== Changed Icon==--
		if Input.IsButtonPressed(Keyboard.KEY_LEFT_SHIFT, player.ControllerIndex) then
			PressingShift = true
			player.ControlsEnabled = false
			if PressedShiftOnce == false then
				PressedShiftOnce = true
				if ShiftChanged == 1 and AnimationEnd == true then
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmChangedToTakeSoul_Variant, 0, player.Position, Vector(0,0), player)
					player.Visible = false
					SFXManager():Play(38, 3, 0, false, 0.5 )
					ShiftChanged = 2 
					IsShiftChanged = false
					AnimationEnd = false
				elseif ShiftChanged == 2 and AnimationEnd == true then
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmChangedToNormal_Variant, 0, player.Position, Vector(0,0), player)
					player.Visible = false
					SFXManager():Play(38, 3, 0, false, 0.8 )
					ShiftChanged = 1
					IsShiftChanged = false
					AnimationEnd = false
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
			local NPC = entity:ToNPC()
			if NPC ~= nil and NPC:IsDead() and ShiftChanged == 2then
				if NPC:IsBoss() or Input.IsButtonPressed(Keyboard.KEY_LEFT_ALT, player.ControllerIndex) or level:GetStage() == 13 then
					--Do nothing
				else
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubSoulEffect_Variant, 0, NPC.Position, Vector(0,0), player)
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
				player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
			elseif ShiftChanged == 2 then
				player:TryRemoveNullCostume(costume_Lairub_Body)
				player:AddNullCostume(costume_Lairub_Body)
				player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
				player:AddNullCostume(costume_Lairub_Head_TakeSoul)
				player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
				player:AddNullCostume(costume_Lairub_Head_TakeSoulBase)
			end
		end
		--==== Release Soul ====--
		if Input.IsButtonPressed(Keyboard.KEY_LEFT_ALT, player.ControllerIndex) and not ReadySpawnCross == true then
			player.ControlsEnabled = false
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
							NPC:TakeDamage(player.Damage, 0, EntityRef(player), 0)
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
		--====Soul Cross====--
		--==Ready Spawn==--
		if Input.IsButtonPressed(Keyboard.KEY_LEFT_CONTROL, player.ControllerIndex) then
			PressingCtrl = true
			if PressedCtrlOnce == false then
				PressedCtrlOnce = true
				if ReadySpawnCross == false and SpawnedCross == false then
					player.Visible = false
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmReadySpawnCross_Variant, 0, player.Position, Vector(0,0), player)
					SFXManager():Play(252, 1, 0, false, 1 )
					ReadySpawnCross = true -- Ready spawn
				elseif ReadySpawnCross == true or SpawnedCross == true then
					ReadySpawnCross = false -- Give up
				end
			end
		else
			PressingCtrl = false
			PressedCtrlOnce = false
		end
		
		if not Input.IsButtonPressed(Keyboard.KEY_LEFT_ALT, player.ControllerIndex) and not Input.IsButtonPressed(Keyboard.KEY_LEFT_SHIFT, player.ControllerIndex) then
			if ReadySpawnCross == true then
				AnimationEnd_ReadySpawnCross = false
				player.ControlsEnabled = false
				--== Spawn direction==--
				-- Left
				if Input.IsButtonPressed(Keyboard.KEY_LEFT, player.ControllerIndex) then
					DetermineDirection = true
					if SpawnedCross == false then
						SFXManager():Play(2, 2, 0, false, 0.7 )
						LairubCross = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubSoulCross_Variant, 0, Vector((player.Position.X - 32), player.Position.Y), Vector(0,0), player)
						LairubCross:BloodExplode()
						player.ControlsEnabled = true
						ReadySpawnCross = false
						for i,entity in ipairs(roomEntities) do
							local NPC = entity:ToNPC()
							if NPC ~= nil and NPC:IsVulnerableEnemy() then
								if (player.Position - NPC.Position):Length() < 64 then
									NPC:TakeDamage((player.Damage * 2), 0, EntityRef(player), 0)
								end
							end
						end
						SpawnedCross = true
					end
				end
				-- Right
				if Input.IsButtonPressed(Keyboard.KEY_RIGHT, player.ControllerIndex) then
					DetermineDirection = true
					if SpawnedCross == false then
						SFXManager():Play(2, 2, 0, false, 0.7 )
						LairubCross = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubSoulCross_Variant, 0, Vector((player.Position.X + 32), player.Position.Y), Vector(0,0), player)
						LairubCross:BloodExplode()
						player.ControlsEnabled = true
						ReadySpawnCross = false
						for i,entity in ipairs(roomEntities) do
							local NPC = entity:ToNPC()
							if NPC ~= nil and NPC:IsVulnerableEnemy() then
								if (player.Position - NPC.Position):Length() < 64 then
									NPC:TakeDamage((player.Damage * 2), 0, EntityRef(player), 0)
								end
							end
						end
						SpawnedCross = true
					end
				end
				-- Up
				if Input.IsButtonPressed(Keyboard.KEY_UP, player.ControllerIndex) then
					DetermineDirection = true
					if SpawnedCross == false then
						SFXManager():Play(2, 2, 0, false, 0.7 )
						LairubCross = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubSoulCross_Variant, 0, Vector(player.Position.X, (player.Position.Y - 32)), Vector(0,0), player)
						LairubCross:BloodExplode()
						player.ControlsEnabled = true
						ReadySpawnCross = false
						for i,entity in ipairs(roomEntities) do
							local NPC = entity:ToNPC()
							if NPC ~= nil and NPC:IsVulnerableEnemy() then
								if (player.Position - NPC.Position):Length() < 64 then
									NPC:TakeDamage((player.Damage * 2), 0, EntityRef(player), 0)
								end
							end
						end
						SpawnedCross = true
					end
				end
				-- Down
				if Input.IsButtonPressed(Keyboard.KEY_DOWN, player.ControllerIndex) then
					DetermineDirection = true
					if SpawnedCross == false then
						SFXManager():Play(2, 2, 0, false, 0.7 )
						LairubCross = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubSoulCross_Variant, 0, Vector(player.Position.X, (player.Position.Y + 32)), Vector(0,0), player)
						LairubCross:BloodExplode()
						player.ControlsEnabled = true
						ReadySpawnCross = false
						for i,entity in ipairs(roomEntities) do
							local NPC = entity:ToNPC()
							if NPC ~= nil and NPC:IsVulnerableEnemy() then
								if (player.Position - NPC.Position):Length() < 64 then
									NPC:TakeDamage((player.Damage * 2), 0, EntityRef(player), 0)
								end
							end
						end
						SpawnedCross = true
					end
				end
			elseif ReadySpawnCross == false then
				player.ControlsEnabled = true
			end
		end
		--====Talk to player==--
		if level:GetStage() == 13 then
			if DialogueOver == false then
				player.ControlsEnabled = false
				player.Visible = false
				if Dialogue == 0 and FinishedTalkAnmPart == 0 then
					TalkNormal = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmTalkNormal_Variant, 0, player.Position, Vector(0,0), player)
					TalkNormal:GetSprite():Play("TalkNormal", false)
					FinishedTalkAnmPart = 1
				elseif Dialogue == 1 and FinishedTalkAnmPart == 1 then
					TalkNormal = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmTalkNormal_Variant, 0, player.Position, Vector(0,0), player)
					TalkNormal:GetSprite():Play("TalkNormal", false)
					FinishedTalkAnmPart = 2
				elseif Dialogue == 2 and FinishedTalkAnmPart == 2 then
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmTalkNormal_Variant, 0, player.Position, Vector(0,0), player)
					TalkNormal:GetSprite():Play("TalkNormal", false)
					FinishedTalkAnmPart = 3
				elseif Dialogue == 3 and FinishedTalkAnmPart == 3 then
					TalkHappy = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmTalkHappy_Variant, 0, player.Position, Vector(0,0), player)
					TalkHappy:GetSprite():Play("TalkHappy", false)
					FinishedTalkAnmPart = 4
				elseif Dialogue == 4 and FinishedTalkAnmPart == 4 then
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmTalkNormal_Variant, 0, player.Position, Vector(0,0), player)
					TalkNormal:GetSprite():Play("TalkNormal", false)
					FinishedTalkAnmPart = 0
				end
				if Input.IsButtonPressed(Keyboard.KEY_Z, player.ControllerIndex) then
					PressingZ = true
					if PressedZOnce == false then
						PressedZOnce = true
						Dialogue = Dialogue + 1
						if Dialogue > 4 then
							Dialogue = 0
							DialogueOver = true
							player.ControlsEnabled = true
							player.Visible = true
						end
					end
				else
					PressingZ = false
					PressedZOnce = false
				end
			end
		end
		--====Teleport To Devil Room====--
		if Input.IsButtonPressed(Keyboard.KEY_X, player.ControllerIndex) then
			PressingX = true
			player.ControlsEnabled = false
			player.Visible = false
			if PressedXOnce == false then
				PressedXOnce = true
				Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmTeleportToDevilRoom_Variant, 0, player.Position, Vector(0,0), player)
			end
		else
			PressingX = false
			PressedXOnce = false
		end
		--====Be Hunted Down In Stage10, BackdropType14(Sheol) And Stage11, BackdropType16(DarkRoom)====-
		--==Function==--
		if not room:IsClear() then
			if (level:GetStage() == 10 and room:GetBackdropType() == 14) or (level:GetStage() == 11 and room:GetBackdropType() == 16) then
				if room:GetFrameCount() >= 1800 then
					--Damage--
					DMGCountDown = math.ceil((DMGframeCount * DMGcount + 1800 -room:GetFrameCount()) / 30)
					if room:GetFrameCount() == DMGframeCount * DMGcount + 1800 then
						player:TakeDamage(2, DamageFlag.DAMAGE_DEVIL | DamageFlag.DAMAGE_INVINCIBLE , EntityRef(player), 0)
						DMGcount = DMGcount + 1
						DMGCountDown = 3
					end
				elseif room:GetFrameCount() <= 1800 then
					--CountDown--
					CountDown = 60 - math.ceil(room:GetFrameCount() / 30)
				end
			end
		elseif room:IsClear() or room:GetType() == RoomType.ROOM_BOSS then
			DMGcount = 0
			CountDown = 60
			DMGCountDown = 3
		end
		--==Dialogue(Sheol)==--
		if level:GetStage() == 10 and room:GetBackdropType() == 14 then
			if DialogueOver_Sheol == false then
				player.ControlsEnabled = false
				player.Visible = false
				if Dialogue_Sheol == 0 and FinishedTalkAnmPart_Sheol == 0 then
					TalkFear = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmTalkFear_Variant, 0, player.Position, Vector(0,0), player)
					TalkFear:GetSprite():Play("TalkFear", false)
					FinishedTalkAnmPart_Sheol = 1
				elseif Dialogue_Sheol == 1 and FinishedTalkAnmPart_Sheol == 1 then
					TalkFear = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmTalkFear_Variant, 0, player.Position, Vector(0,0), player)
					TalkFear:GetSprite():Play("TalkFear", false)
					FinishedTalkAnmPart_Sheol = 2
				elseif Dialogue_Sheol == 2 and FinishedTalkAnmPart_Sheol == 2 then
					TalkFear = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmTalkFear_Variant, 0, player.Position, Vector(0,0), player)
					TalkFear:GetSprite():Play("TalkFear", false)
					FinishedTalkAnmPart_Sheol = 3
				elseif Dialogue_Sheol == 3 and FinishedTalkAnmPart_Sheol == 3 then
					TalkSigh = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmTalkSigh_Variant, 0, player.Position, Vector(0,0), player)
					TalkSigh:GetSprite():Play("TalkSigh", false)
					FinishedTalkAnmPart_Sheol = 4
				elseif Dialogue_Sheol == 4 and FinishedTalkAnmPart_Sheol == 4 then
					TalkSigh = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmTalkSigh_Variant, 0, player.Position, Vector(0,0), player)
					TalkSigh:GetSprite():Play("TalkSigh", false)
					FinishedTalkAnmPart_Sheol = 0
				end
				if Input.IsButtonPressed(Keyboard.KEY_Z, player.ControllerIndex) then
					PressingZ = true
					if PressedZOnce == false then
						PressedZOnce = true
						Dialogue_Sheol = Dialogue_Sheol + 1
						if Dialogue_Sheol > 4 then
							Dialogue_Sheol = 0
							DialogueOver_Sheol = true
							player.ControlsEnabled = true
							player.Visible = true
						end
					end
				else
					PressingZ = false
					PressedZOnce = false
				end
			end
		end
		--====Remove Poof (I can't finish this..)====--
--[[	for i,entity in ipairs(roomEntities) do
			local Effect = entity:ToEffect()
			if Effect ~= nil and Effect.Variant == EffectVariant.POOF01 then
				Effect.Remove()
			end
		end]]--
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

function lairub:PrePickupCollision(pickup, collider, low)
	local player = collider:ToPlayer()
	if player ~= nil and player:GetPlayerType() == playerType_Lairub then
		if pickup.Variant == PickupVariant.PICKUP_HEART and (pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_HALF or pickup.SubType == HeartSubType.HEART_SCARED) then
			return false
		else
			return nil
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, lairub.PrePickupCollision)

function lairub:PostNewLevel()
	SoulCount = 0
	NPCdis = 0
	local level = Game():GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		level:AddAngelRoomChance(0)
		if level:GetStage() == 13 then
			player:AddBlackHearts(6)
		end
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_NEW_LEVEL, lairub.PostNewLevel)

function lairub:PostNewRoom()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	
	NPCdis = 0
	
	LairubTeleportReadyTime = 0
	
	ReadySpawnCross = false
	DetermineDirection = false
	SpawnedCross = false
	for i, entity in pairs(roomEntities) do
		if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == LairubSoulCross_Variant then
			entity:Remove()
		end
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_NEW_ROOM, lairub.PostNewRoom)

function lairub:PostNewGame()
	ShiftChanged = 1
	PressingShift = false
	PressedShiftOnce = false
	IsShiftChanged = true
	
	SoulCount = 0
	PressingAlt = false
	PressedAltOnce = false
	
	PressingCtrl = false
	PressedCtrlOnce = false
	
	ReadySpawnCross = false
	DetermineDirection = false
	SpawnedCross = false
	
	AnimationEnd = true
	AnimationEnd_ReadySpawnCross = true
	
	NPCdis = 0
	
	PressingZ = false
	PressedZOnce = false
--	DialogueOver = false
	Dialogue = 0
	
	DialogueOver_Sheol = false
	Dialogue_Sheol = 0
	
	PressingX = false
	PressedXOnce = false
	LairubTeleportReadyTime = 0
	
	DMGcount = 0
	CountDown = 60
	DMGCountDown = 3
	
	AnmTalkStat = true
	FinishedTalkAnmPart = 0
	FinishedTalkAnmPart_Sheol = 0
	
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	for i, entity in pairs(roomEntities) do
		if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == LairubSoulCross_Variant then
			entity:Remove()
		end
	end
	if player:GetPlayerType() == playerType_Lairub then
		player:TryRemoveNullCostume(costume_Lairub_Body)
		player:AddNullCostume(costume_Lairub_Body)
		player:TryRemoveNullCostume(costume_Lairub_Head)
		player:AddNullCostume(costume_Lairub_Head)
		player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_GAME_STARTED, lairub.PostNewGame)

--==For Locking Characters==--

local playerType_Tainted_Lairub = Isaac.GetPlayerTypeByName("Tainted Lairub", true)

function lairub:LockingUpdate(player)
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == playerType_Tainted_Lairub then
		player.Visible = false
		player.ControlsEnabled = false
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_UPDATE, lairub.LockingUpdate)

function lairub:LockingPostRender()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	if player:GetPlayerType() == playerType_Tainted_Lairub then
		Isaac.RenderText("Character 'Tainted Lairub' is an unfinished character.", 50, 60, 255, 0, 0, 255)
		Isaac.RenderText("Now that she is locked, please wait for the update.", 50, 70, 255, 0, 0, 255)
	end
end
lairub:AddCallback(ModCallbacks.MC_POST_RENDER, lairub.LockingPostRender)