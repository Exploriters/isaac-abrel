local lairub = RegisterMod("Lairub", 1);

local LairubFlags = Explorite.NewExploriteFlags()
local LairubObjectives = Explorite.NewExploriteObjectives()

--==== Const values ====--
--==Costume and something else==--
--Wait, something else???????
local costume_Lairub_Body = Isaac.GetCostumeIdByPath("gfx/characters/LairubBody.anm2")
local costume_Lairub_Head = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead.anm2")
local costume_Lairub_Head_TakeSoul = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead_TakeSoul.anm2")
local costume_Lairub_Head_TakeSoulBase = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead_TakeSoulBase.anm2")

local playerType_Lairub = Isaac.GetPlayerTypeByName("Lairub")
local LairubStatUpdateItem = Isaac.GetItemIdByName( "Lairub Stat Trigger" )

local playerType_Tainted_Lairub = Isaac.GetPlayerTypeByName("Tainted Lairub", true)
local costume_TaintedLairub_Body = Isaac.GetCostumeIdByPath("gfx/characters/TaintedLairubBody.anm2")
local costume_TaintedLairub_Head = Isaac.GetCostumeIdByPath("gfx/characters/TaintedLairubHead.anm2")

--==== Temporary values ====--
local gameInited = false

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
local ReleaseingSoul = false
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
local Dialogue = 0
local Dialogue_Sheol = 0
--local DialogueOver = false
--local DialogueOver_Sheol = false

--==X(Teleport To Devil Room)==--
local PressingX = false
local PressedXOnce = false
local LairubTeleportReadyTime = 0

--==H(Help List)==--
local ShowHelpList = false
local PressingH = false
local PressedHOnce = false
local ShowedInitialTips = false

--==Misc==--
local AnmTalkStat = true
local FinishedTalkAnmPart = 0
local FinishedTalkAnmPart_Sheol = 0

local NPCdis = 0

--==HuntedDown==--
local HuntedDownReadout = "none" -- none, safe, BOSS, Vigilant, DANGER
local HuntedDownReadoutNumber = 0
local huntDownEnabled = false

--== Soul Stone ==--

local lairubSoulStoneID = Isaac.GetCardIdByName("Soul of Lairub")
local UsedLairubSoulStone = false
local TriggerDelay = 1
local TriggeredCount = 0
local BaseFrameCount = 0
local BaseGameFrameCount = 0
local DMGtoEveryNPC = false
local TotalRoomFrame = 0

--==== Saved values ====--

local SoulCount = 0
local HuntedDownFrame = -1

--==== Data Management ====--
local function WipeTempVar()
	LairubFlags:Wipe()
	
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
	--DialogueOver = false
	Dialogue = 0
	
	--DialogueOver_Sheol = false
	Dialogue_Sheol = 0
	
	PressingX = false
	PressedXOnce = false
	LairubTeleportReadyTime = 0
	
	ShowHelpList = false
	PressingH = false
	PressedHOnce = false
	ShowedInitialTips = false
	
	DMGcount = 1
	CountDown = 60
	DMGCountDown = 3
	
	AnmTalkStat = true
	FinishedTalkAnmPart = 0
	FinishedTalkAnmPart_Sheol = 0
	
	UsedLairubSoulStone = false
	TriggeredCount = 0
	BaseFrameCount = 0
	DMGtoEveryNPC = false
	BaseGameFrameCount = 0
	
	ReadyAttack = false
	Attacked = true
	Invincible = false
	InvincibleEnd = true
	LevelKillCount = 0
	RoomKillCount = 0
	LevelDevourOnce = false
	BoneCount = 0
end

--==== Store mod Data ====--

function LairubObjectives:Apply()
	LairubFlags:Wipe()
	LairubFlags:LoadFromString(self:Read("Flags", ""))
	SoulCount = tonumber(self:Read("SoulCount", "0"))
	HuntedDownReadout = self:Read("HuntedDownReadout", "none")
	HuntedDownReadoutNumber = self:Read("HuntedDownReadoutNumber", "0")

	--DialogueOver = StringConvertToBoolean(self:Read("DialogueOver", "false"))
	
end

function LairubObjectives:Recieve()
	self:Write("Flags", LairubFlags:ToString())
	self:Write("SoulCount", tostring(SoulCount))
	self:Write("HuntedDownReadout", HuntedDownReadout)
	self:Write("HuntedDownReadoutNumber", tostring(HuntedDownReadoutNumber))
	--self:Write("DialogueOver", tostring(DialogueOver))
end

--==Read==--
function LoadLairubModData()
	local str = ""
	if Isaac.HasModData(lairub) then
		str = Isaac.LoadModData(lairub)
	end
	LairubObjectives:Wipe()
	LairubObjectives:LoadFromString(str)
	LairubObjectives:Apply()
end
--==Write==--
function SaveLairubModData()
	LairubObjectives:Recieve()
	local str = LairubObjectives:ToString()
	Isaac.SaveModData(lairub, str)
end
--==Post game started==--
function lairub:PostGameStarted(loadedFromSaves)
	WipeTempVar()
	LoadLairubModData()
	if not loadedFromSaves then -- Only new games
		WipeTempVar()
		local game = Game()
		local level = game:GetLevel()
		local player = Isaac.GetPlayer(0)
		local room = game:GetRoom()
		local roomEntities = Isaac.GetRoomEntities()
		for i, entity in pairs(roomEntities) do
			if entity.Type == EntityType.ENTITY_FAMILIAR then
				if entity.Variant == LairubSoulCross_Variant then
					entity:Remove()
				end
				if entity.Variant == LairubTheBone_Variant then
					entity:Remove()
				end
			end
		end
		if player:GetPlayerType() == playerType_Lairub then
			player:TryRemoveNullCostume(costume_Lairub_Body)
			player:AddNullCostume(costume_Lairub_Body)
			player:TryRemoveNullCostume(costume_Lairub_Head)
			player:AddNullCostume(costume_Lairub_Head)
			player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
		end
		SaveLairubModData()
	end
	gameInited = true
end
lairub:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, lairub.PostGameStarted)

function lairub:PreGameExit(shouldSave)
	SaveLairubModData()
	gameInited = false
end
lairub:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, lairub.PreGameExit)
--================================--

--==Be Hunted Down In Stage10, BackdropType14(Sheol) And Stage11, BackdropType16(DarkRoom)==--
local HuntedDownThreshold = 60 * 30 -- Exceeded this value result damage overtime
local HuntedDownDamageRate = 3 * 30 -- For ever amount of frames, dealt damage
local HuntedDownDamagePerShot = 2 -- Damage value

local function HuntedDownInterval()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()

	-- if not in Sheol or Dark Room, hide timer
	if not LairubFlags:HasFlag("HUNTED_DOWN") then
		HuntedDownReadout = "none"
		HuntedDownReadoutNumber = 0
		HuntedDownFrame = -1
		return nil
	end

	-- if room is clear, stop timer
	if room:IsClear() then
		HuntedDownReadout = "safe"
		HuntedDownReadoutNumber = math.ceil(HuntedDownThreshold / 30)
		HuntedDownFrame = -1
		return nil
	end

	-- if room is boss room, stop timer
	if room:GetType() == RoomType.ROOM_BOSS then
		HuntedDownReadout = "BOSS"
		HuntedDownReadoutNumber = 0
		HuntedDownFrame = -1
		return nil
	end

	-- if all invalid testing are passed, timing

	HuntedDownFrame = HuntedDownFrame + 1

	-- if time below threshold, stop trigger damage
	if HuntedDownFrame < HuntedDownThreshold then
		HuntedDownReadout = "Vigilant"
		HuntedDownReadoutNumber = math.ceil((HuntedDownThreshold - HuntedDownFrame) / 30)
		return nil
	end

	-- execute damage
	HuntedDownReadout = "DANGER"
	HuntedDownReadoutNumber = math.ceil((HuntedDownDamageRate - (HuntedDownFrame - HuntedDownThreshold) % HuntedDownDamageRate) / 30)

	if (HuntedDownFrame - HuntedDownThreshold) % HuntedDownDamageRate == 0 then
		player:TakeDamage(HuntedDownDamagePerShot, DamageFlag.DAMAGE_DEVIL | DamageFlag.DAMAGE_INVINCIBLE , EntityRef(player), 0)
	end
	
end

local function HuntedDownRendering()
	if HuntedDownReadout ~= "none" then
		-- safe: white
		-- BOSS: pink
		-- Vigilant: pink
		-- DANGER: red
		local R, G, B, A = 1, 1, 1, 1
		if HuntedDownReadout == "BOSS" or HuntedDownReadout == "Vigilant" then
			R, G, B, A = 1, 0.5, 0.5, 0.8
		end
		if HuntedDownReadout == "DANGER" then
			R, G, B, A = 1, 0, 0, 0.8
		end

		-- use computed result from game interval function, instead of compute them in render function
		local displayNumber
		if HuntedDownReadoutNumber < 10 then
			displayNumber = "0"..tostring(HuntedDownReadoutNumber)
		else
			displayNumber = tostring(HuntedDownReadoutNumber)
		end
		
		Isaac.RenderScaledText(displayNumber, 212 - Isaac.GetTextWidth (displayNumber) * 2 / 2, 60, 2, 2, R, G, B, A)
		Isaac.RenderScaledText(HuntedDownReadout, 212 - Isaac.GetTextWidth (HuntedDownReadout) * 0.9 / 2, 80, 0.9, 0.9, R, G, B, A)
	end
end
--==== Key process ====--
local function IsLairubButtonPressed(player, name)
	if player == nil then
		return false
	elseif not player.ControlsEnabled then
		return false
	elseif name == "hide_ui" then
		return Input.IsButtonPressed(Keyboard.KEY_TAB, player.ControllerIndex)
	elseif name == "swap_form" then
		return Input.IsButtonPressed(Keyboard.KEY_LEFT_SHIFT, player.ControllerIndex)
	elseif name == "soul_cross" then
		return Input.IsButtonPressed(Keyboard.KEY_LEFT_CONTROL, player.ControllerIndex)
	elseif name == "release_souls" then
		return Input.IsButtonPressed(Keyboard.KEY_LEFT_ALT, player.ControllerIndex)
	elseif name == "up" then
		return Input.IsButtonPressed(Keyboard.KEY_UP, player.ControllerIndex)
	elseif name == "down" then
		return Input.IsButtonPressed(Keyboard.KEY_DOWN, player.ControllerIndex)
	elseif name == "left" then
		return Input.IsButtonPressed(Keyboard.KEY_LEFT, player.ControllerIndex)
	elseif name == "right" then
		return Input.IsButtonPressed(Keyboard.KEY_RIGHT, player.ControllerIndex)
	elseif name == "teleport_to_devil_room" then
		return Input.IsButtonPressed(Keyboard.KEY_X, player.ControllerIndex)
	elseif name == "step_dialogue" then
		return Input.IsButtonPressed(Keyboard.KEY_Z, player.ControllerIndex)
	elseif name == "help" then
		return Input.IsButtonPressed(Keyboard.KEY_H, player.ControllerIndex)
	else
		return false
	end
end

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
	--==Remove Costume if player isn't Lairub==--
	if player:GetPlayerType() ~= playerType_Lairub then
		player:TryRemoveNullCostume(costume_Lairub_Body)
		player:TryRemoveNullCostume(costume_Lairub_Head)
		player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
		player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
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
			player.MoveSpeed = player.MoveSpeed - 0.3
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 0.3
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay + 2
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
				player.Damage = player.Damage + 1.3
			elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = player.MaxFireDelay + 8
			end
			IsShiftChanged = true
		end
		-- TakeSoul -> Normal
		if ShiftChanged ==  1 then
			--[[if cacheFlag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed + 0.2
			elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage - 1
			elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = player.MaxFireDelay - 10
			end]]--
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

function lairub:PostRender()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	local playerPos = room:WorldToScreenPosition(player.Position)
	if player:GetPlayerType() == playerType_Lairub then
		--==Initial tips==--
--		if ShowedInitialTips == false then
		if Game():GetFrameCount() <= 60 then
			Isaac.RenderText("Pressing'Tap' to hide skill icon.", playerPos.X - 96, playerPos.Y + 6, 255, 255, 255, 255)
			Isaac.RenderText("Press'H' to show help list.", playerPos.X - 96, playerPos.Y + 16, 255, 255, 255, 255)
		else
			--Do nothing
		end
		--==== Can Hide ====--
		if not IsLairubButtonPressed(player,"hide_ui") then
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
			--==Hunted down readout==--
			HuntedDownRendering()
			--==CountDown==--
			--[[
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
							Isaac.RenderScaledText("DANGER", 195, 80, 0.9, 0.9, 1, 0, 0, 0.8)
						end
					end
				end
			end
			]]--
			
			--== Help List ==--
			if ShowHelpList == true then
				-- Shift --
				Isaac.RenderScaledText("Shift - ChangeFrom", 64, 86, 0.9, 0.9, 1, 1, 1, 0.7)
				Isaac.RenderScaledText("Changed to 'TakeSoul' or normal.", 70, 96, 0.9, 0.9, 1, 1, 1, 0.7)
				Isaac.RenderScaledText("When you're in 'TakeSoul', you can collect souls", 70, 106, 0.9, 0.9, 1, 1, 1, 0.7)
				Isaac.RenderScaledText("for ReleaseSoul.", 70, 116, 0.9, 0.9, 1, 1, 1, 0.7)
				-- Ctrl --
				Isaac.RenderScaledText("Ctrl - SoulCross", 64, 126, 0.9, 0.9, 1, 1, 1, 0.7)
				Isaac.RenderScaledText("Spawn a SoulCross that will attack the", 70, 136, 0.9, 0.9, 1, 1, 1, 0.7)
				Isaac.RenderScaledText("enemy autonomously.(DMG = player.Damage * 50%)", 70, 146, 0.9, 0.9, 1, 1, 1, 0.7)
				Isaac.RenderScaledText("When SoulCross is spawned, it can damage enemies", 70, 156, 0.9, 0.9, 1, 1, 1, 0.7)
				Isaac.RenderScaledText("with a radius of 90 pixels.(DMG = player.Damage * 200%)", 70, 166, 0.9, 0.9, 1, 1, 1, 0.7)
				-- Alt --
				Isaac.RenderScaledText("Alt - ReleaseSoul", 64, 176, 0.9, 0.9, 1, 1, 1, 0.7)
				Isaac.RenderScaledText("Consume soul and deal damage to enemies with", 70, 186, 0.9, 0.9, 1, 1, 1, 0.7)
				Isaac.RenderScaledText("radius 192 pixels.(DMG = player.Damage)", 70, 196, 0.9, 0.9, 1, 1, 1, 0.7)
				-- X --
				Isaac.RenderScaledText("X - Teleport To Devil Room", 64, 206, 0.9, 0.9, 1, 1, 1, 0.7)
				Isaac.RenderScaledText("Hold 'X' for 6 seconds and teleport to devil room.", 70, 216, 0.9, 0.9, 1, 1, 1, 0.7)
			else
				-- Do nothing
			end
			--====--
		else
			--Do nothing
		end
		--========--
		--==Talk to player==--
		if (not LairubFlags:HasFlag("DIALOGUE_OVER")) and level:GetStage() == 13 then
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
		if (not LairubFlags:HasFlag("DIALOGUE_OVER_SHEOL")) and LairubFlags:HasFlag("HUNTED_DOWN") then
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
			--player.ControlsEnabled = true
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
			--player.ControlsEnabled = true
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
	if (player:GetPlayerType() == playerType_Lairub or player:GetPlayerType() == playerType_Tainted_Lairub) and not player:IsDead() then
		LairubAnmReleaseSoul:GetSprite():Play("ReleaseSoul", false)
--		if LairubAnmReleaseSoul:GetSprite():IsEventTriggered("End") then
			if ReleaseingSoul == false then
				--player.ControlsEnabled = true
				player.Visible = true
				AnimationEnd = true
				LairubAnmReleaseSoul:Remove()
			end
--		end
	end
end
lairub:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,LairubAnmReleaseSoulUpdate, LairubAnmReleaseSoul_Variant)

local LairubSoulCross_Type = Isaac.GetEntityTypeByName("LairubSoulCross")
local LairubSoulCross_Variant = Isaac.GetEntityVariantByName("LairubSoulCross")

local function LairubSoulCrossUpdate(_, LairubSoulCross)
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	
--[[	local posX = math.floor(LairubSoulCross.Position.X/40.0)*40
	local posY = math.floor(LairubSoulCross.Position.Y/40.0)*40
	LairubSoulCross.Position = Vector(posX, posY)
	LairubSoulCross.Velocity = Vector(0, 0)]]--
	--!Spawned position error!--
	
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
					NPCdis = NPCdis + 96
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
			--player.ControlsEnabled = true
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
			--player.ControlsEnabled = true
			player:UseCard(Card.CARD_JOKER, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANNOUNCER)
			LairubAnmTeleportToDevilRoom:Remove()
		end
		if PressingX == false then
			player.Visible = true
			--player.ControlsEnabled = true
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
		if not IsLairubButtonPressed(player,"release_souls") and not ReadySpawnCross == true and not IsLairubButtonPressed(player,"teleport_to_devil_room") then
			if IsLairubButtonPressed(player,"swap_form") then
				PressingShift = true
				player:AddControlsCooldown(2)--player.ControlsEnabled = false
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
				if NPC:IsBoss() or IsLairubButtonPressed(player,"release_souls") or level:GetStage() == 13 then
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
		if IsLairubButtonPressed(player,"release_souls") and not ReadySpawnCross == true then
			PressingAlt = true
			if PressedAltOnce == false then
				PressedAltOnce = true
				ReleaseingSoul = true
				Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmReleaseSoul_Variant, 0, player.Position, Vector(0,0), player)
			end
		else
			PressingAlt = false
			PressedAltOnce = false
			ReleaseingSoul = false
		end
		
		if ReleaseingSoul == true then
			player:AddControlsCooldown(2)--player.ControlsEnabled = false
			player.Visible = false
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
		end
		--====Soul Cross====--
		--==Ready Spawn==--
		if not IsLairubButtonPressed(player,"release_souls") and not IsLairubButtonPressed(player,"swap_form") and not IsLairubButtonPressed(player,"teleport_to_devil_room") then
			if IsLairubButtonPressed(player,"soul_cross") then
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
		end
		if not IsLairubButtonPressed(player,"release_souls") and not IsLairubButtonPressed(player,"swap_form") and not Input.IsLairubButtonPressed(player,"teleport_to_devil_room") then
			if ReadySpawnCross == true then
				AnimationEnd_ReadySpawnCross = false
				player:AddControlsCooldown(2)--player.ControlsEnabled = false
				--== Spawn direction==--
				-- Left
				if IsLairubButtonPressed(player,"left") then
					DetermineDirection = true
					if SpawnedCross == false then
						SFXManager():Play(2, 2, 0, false, 0.7 )
						LairubCross = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubSoulCross_Variant, 0, Vector((player.Position.X - 32), player.Position.Y), Vector(0,0), player)
						LairubCross:BloodExplode()
						--player.ControlsEnabled = true
						ReadySpawnCross = false
						for i,entity in ipairs(roomEntities) do
							local NPC = entity:ToNPC()
							if NPC ~= nil and NPC:IsVulnerableEnemy() then
								if (player.Position - NPC.Position):Length() < 90 then
									NPC:TakeDamage((player.Damage * 2), 0, EntityRef(player), 0)
								end
							end
						end
						SpawnedCross = true
					end
				end
				-- Right
				if IsLairubButtonPressed(player,"right") then
					DetermineDirection = true
					if SpawnedCross == false then
						SFXManager():Play(2, 2, 0, false, 0.7 )
						LairubCross = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubSoulCross_Variant, 0, Vector((player.Position.X + 32), player.Position.Y), Vector(0,0), player)
						LairubCross:BloodExplode()
						--player.ControlsEnabled = true
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
				if IsLairubButtonPressed(player,"up") then
					DetermineDirection = true
					if SpawnedCross == false then
						SFXManager():Play(2, 2, 0, false, 0.7 )
						LairubCross = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubSoulCross_Variant, 0, Vector(player.Position.X, (player.Position.Y - 32)), Vector(0,0), player)
						LairubCross:BloodExplode()
						--player.ControlsEnabled = true
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
				if IsLairubButtonPressed(player,"down") then
					DetermineDirection = true
					if SpawnedCross == false then
						SFXManager():Play(2, 2, 0, false, 0.7 )
						LairubCross = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubSoulCross_Variant, 0, Vector(player.Position.X, (player.Position.Y + 32)), Vector(0,0), player)
						LairubCross:BloodExplode()
						--player.ControlsEnabled = true
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
				--player.ControlsEnabled = true
			end
		end
		--====Talk to player==--
		if level:GetStage() == 13 then
			if not LairubFlags:HasFlag("DIALOGUE_OVER") then
				player:AddControlsCooldown(2)--player.ControlsEnabled = false
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
				if IsLairubButtonPressed(player,"step_dialogue") then
					PressingZ = true
					if PressedZOnce == false then
						PressedZOnce = true
						Dialogue = Dialogue + 1
						if Dialogue > 4 then
							Dialogue = 0
							LairubFlags:AddFlag("DIALOGUE_OVER")
							--player.ControlsEnabled = true
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
		local BackdropType = Game():GetRoom():GetBackdropType()
		if BackdropType ~= 54 and BackdropType ~= 55 and BackdropType ~= 56 and BackdropType ~= 57 then
			if not IsLairubButtonPressed(player,"release_souls") and not IsLairubButtonPressed(player,"swap_form") then
				if IsLairubButtonPressed(player,"teleport_to_devil_room") then
					PressingX = true
					player:AddControlsCooldown(2)--player.ControlsEnabled = false
					player.Visible = false
					if PressedXOnce == false then
						PressedXOnce = true
						Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubAnmTeleportToDevilRoom_Variant, 0, player.Position, Vector(0,0), player)
					end
				else
					PressingX = false
					PressedXOnce = false
				end
			end
		end
		--====Be Hunted Down In Stage10, BackdropType14(Sheol) And Stage11, BackdropType16(DarkRoom)====-
		HuntedDownInterval()
		--[[
		--==Function==--
		if not room:IsClear() then
			if (level:GetStage() == 10 and room:GetBackdropType() == 14) or (level:GetStage() == 11 and room:GetBackdropType() == 16) then
				if room:GetType() == RoomType.ROOM_BOSS then
					--Do nothing
				end
				if room:GetFrameCount() > 1800 then
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
			DMGcount = 1
			CountDown = 60
			DMGCountDown = 3
		end
		]]--


		--==Dialogue(Sheol)==--
		if level:GetStage() == 10 and room:GetBackdropType() == 14 then
			if not LairubFlags:HasFlag("DIALOGUE_OVER_SHEOL") then
				player:AddControlsCooldown(2)--player.ControlsEnabled = false
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
				if IsLairubButtonPressed(player,"step_dialogue") then
					PressingZ = true
					if PressedZOnce == false then
						PressedZOnce = true
						Dialogue_Sheol = Dialogue_Sheol + 1
						if Dialogue_Sheol > 4 then
							Dialogue_Sheol = 0
							LairubFlags:AddFlag("DIALOGUE_OVER_SHEOL")
							--player.ControlsEnabled = true
							player.Visible = true
						end
					end
				else
					PressingZ = false
					PressedZOnce = false
				end
			end
		end
		--==== Help List ====--
		if IsLairubButtonPressed(player,"help") then
			PressingH = true
			if PressedHOnce == false then
				PressedHOnce = true
				ShowHelpList = true
			end
		else
			ShowHelpList = false
			PressingH = false
			PressedHOnce = false
		end
		if level:GetStage() == 1 and ShowedInitialTips == false then
			if room:GetFrameCount() > 90 then
				ShowedInitialTips = true
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

function lairub:StopReleaseSoul(tookDamage, damage, damageFlags, damageSourceRef)
	ReleaseingSoul = false
	return true
end
lairub:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, lairub.StopReleaseSoul, EntityType.ENTITY_PLAYER)

--==Tainted==--

--UNFINISHED--
function lairub:UnfinishedPostRender()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	local playerPos = room:WorldToScreenPosition(player.Position)
	if player:GetPlayerType() == playerType_Tainted_Lairub then
		Isaac.RenderText("Unfinished, please wait for the update.", 78, 70, 1, 0, 0, 255)
	end
end
lairub:AddCallback(ModCallbacks.MC_POST_RENDER, lairub.UnfinishedPostRender)

function lairub:UnfinishedUpdate()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	if player:GetPlayerType() == playerType_Tainted_Lairub then
		player:AddControlsCooldown(2)--player.ControlsEnabled = false
		player.Visible = false
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_UPDATE, lairub.UnfinishedUpdate)

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
	if player:GetPlayerType() == playerType_Tainted_Lairub then
		--==== Can Hide ====--
		if not IsLairubButtonPressed(player,"hide_ui") then
			--==SoulSign==--
			SoulSign:SetOverlayRenderPriority(true)
			SoulSign:SetFrame("SoulSign", 1)
			SoulSign:Render(Vector(64,76), Vector(0,0), Vector(0,0))
			Isaac.RenderText(tostring(SoulCount), 78, 70, 255, 255, 255, 255)
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
	
	if room:GetFrameCount() == 1 and player:GetPlayerType() == playerType_Tainted_Lairub and not player:IsDead() then
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
	if player:GetPlayerType() == playerType_Tainted_Lairub then
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
	if player:GetPlayerType() == playerType_Tainted_Lairub then
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
	if player:GetPlayerType() == playerType_Tainted_Lairub then
		Isaac.RenderText("I'm trying to update!! TAT", 50, 60, 255, 0, 0, 255)
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
	if player:GetPlayerType() == playerType_Tainted_Lairub and not player:IsDead() then
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
	if player:GetPlayerType() == playerType_Tainted_Lairub and not player:IsDead() then
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
]]--

--== Soul Stone ==--

-- Thanks for siiftun1857's help >w< --
function lairub:UseLairubSoulStone(cardId, player, useFlags)
	local room = Game():GetRoom()
	BaseFrameCount = room:GetFrameCount()
	BaseGameFrameCount = Game():GetFrameCount()
	UsedLairubSoulStone = true
end
lairub:AddCallback(ModCallbacks.MC_USE_CARD, lairub.UseLairubSoulStone, lairubSoulStoneID)


function lairub:SoulStonePostRender()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	local playerPos = room:WorldToScreenPosition(player.Position)
	if UsedLairubSoulStone == true then
		if player:GetPlayerType() ~= playerType_Lairub and player:GetPlayerType() ~= playerType_Tainted_Lairub then
			if not IsLairubButtonPressed(player,"hide_ui") then
				SoulSign:SetOverlayRenderPriority(true)
				SoulSign:SetFrame("SoulSign", 1)
				SoulSign:Render(Vector(playerPos.X - 5, playerPos.Y - 44), Vector(0,0), Vector(0,0))
				Isaac.RenderText(tostring(SoulCount), playerPos.X + 5, playerPos.Y - 46, 255, 255, 255, 255)
			end
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_POST_RENDER, lairub.SoulStonePostRender)

function lairub:LairubSoulStoneFunction()
	local level = Game():GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	if UsedLairubSoulStone == true then
		--==Spawn==--
		if (room:GetFrameCount() - BaseFrameCount) % TriggerDelay == 0 then
			TriggeredCount = TriggeredCount + 1
			Isaac.Spawn(EntityType.ENTITY_EFFECT, 111, 0, Vector(player.Position.X, player.Position.Y - 25), Vector(math.random(-8, 8), math.random(-8, 8)), player)
		end
		for i, Effect in pairs(roomEntities) do
			if Effect.Type == EntityType.ENTITY_EFFECT and Effect.Variant == 111 then
				Effect:SetColor(Color(1, 1, 1, 1, 1, 1, 1), 0, 999, true, true)
			end
		end
		--==Function==--
		--DMG To Every NPC
		if DMGtoEveryNPC == false then
			for i, entity in pairs(roomEntities) do
				local NPC = entity:ToNPC()
				if NPC ~= nil and NPC:IsVulnerableEnemy() and not NPC:IsBoss() then
					NPC:TakeDamage(9999, 0, EntityRef(player), 0)
					if NPC:IsDead() then
						Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubSoulEffect_Variant, 0, NPC.Position, Vector(0,0), player)
					end
				end
			end
			if room:IsClear() then
				DMGtoEveryNPC = true
			end
		end
		--
		TotalRoomFrame = Game():GetFrameCount() - BaseGameFrameCount
		if TotalRoomFrame >= 600 then
			UsedLairubSoulStone = false
			DMGtoEveryNPC = false
			TotalRoomFrame = 0
			BaseGameFrameCount = 0
			if player:GetPlayerType() ~= playerType_Lairub and player:GetPlayerType() ~= playerType_Tainted_Lairub then
				SoulCount = 0
			end
		elseif TotalRoomFrame < 600 then
			for i,entity in ipairs(roomEntities) do
				local NPC = entity:ToNPC()
				if SoulCount > 0 then
					if NPC ~= nil and NPC:IsVulnerableEnemy() and not NPC:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
						if (player.Position - NPC.Position):Length() < 128 or level:GetStage() == 13 then
							SoulCount = SoulCount - 1
							NPC:TakeDamage((player.Damage * 1.5), 0, EntityRef(player), 0)
							NPC:SetColor(Color(0, 0, 0, 1, 0, 0, 0), 30, 999, true, true)
							if SoulCount < 0 then
								SoulCount = 0
							end
						end
					end
				end
				if NPC ~= nil and NPC:IsDead() and not NPC:IsBoss() then
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LairubSoulEffect_Variant, 0, NPC.Position, Vector(0,0), player)
				end
			end
		end
		--====--
	end
end
lairub:AddCallback(ModCallbacks.MC_POST_UPDATE, lairub.LairubSoulStoneFunction)

--==Universal==--

function lairub:UniversalUpdate()
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == playerType_Lairub or player:GetPlayerType() == playerType_Tainted_Lairub then
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_DUALITY) then
			Game():GetLevel():AddAngelRoomChance(0)
		end
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
lairub:AddCallback( ModCallbacks.MC_POST_UPDATE, lairub.UniversalUpdate)

function lairub:PostNPCDeath()
	local player = Isaac.GetPlayer(0)
	if player:GetPlayerType() == playerType_Lairub and ShiftChanged == 2 and not IsLairubButtonPressed(player,"release_souls") then
		SoulCount = SoulCount + 1
	end
	if UsedLairubSoulStone == true then
		SoulCount = SoulCount + 1
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_NPC_DEATH, lairub.PostNPCDeath)

function lairub:PrePickupCollision(pickup, collider, low)
	local player = collider:ToPlayer()
	if player ~= nil and (player:GetPlayerType() == playerType_Lairub or player:GetPlayerType() == playerType_Tainted_Lairub) then
		if pickup.Variant == PickupVariant.PICKUP_HEART then
			if pickup.SubType == HeartSubType.HEART_FULL
			or pickup.SubType == HeartSubType.HEART_HALF
			or pickup.SubType == HeartSubType.HEART_SCARED
			or pickup.SubType == HeartSubType.HEART_DOUBLEPACK
			or pickup.SubType == HeartSubType.HEART_ROTTEN
			then
				return pickup:IsShopItem()
			elseif pickup.SubType == HeartSubType.HEART_BLENDED then
				local soulHearts = player:GetSoulHearts()
				local countBroken = player:GetBrokenHearts()
				local totalHearts = math.ceil((player:GetHearts() + soulHearts)*0.5)
				local countBone = 0
				for i=0,totalHearts-1,1 do
					if player:IsBoneHeart(i) then
						countBone = countBone + 1
					end
				end
				if soulHearts + countBone * 2 + countBroken * 2 >= 24 then
					return pickup:IsShopItem()
				end

				if pickup:IsShopItem() then
					if player:GetNumCoins() >= pickup.Price then
						player:AddCoins(-pickup.Price)
					else
						return true
					end
				end
				player:AddBlackHearts(2)
				--pickup:GetSprite():Play("Collect", true)
				SFXManager():Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1 )
				pickup:Remove()
				return pickup:IsShopItem()
			end
		elseif pickup.Variant == PickupVariant.PICKUP_BED and pickup.SubType == BedSubType.BED_ISAAC then
			return false
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, lairub.PrePickupCollision)

function lairub:PostNewLevel()
	SoulCount = 0
	NPCdis = 0
	UsedLairubSoulStone = false
	TriggeredCount = 0
	BaseFrameCount = 0
	DMGtoEveryNPC = false
	BaseGameFrameCount = 0
	LevelKillCount = 0
	RoomKillCount = 0
	LevelDevourOnce = false
	BoneCount = 0
	local level = Game():GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	
	if (level:GetStage() == LevelStage.STAGE5 and level:GetCurrentRoom():GetBackdropType() == BackdropType.SHEOL)
	or (level:GetStage() == LevelStage.STAGE6 and level:GetCurrentRoom():GetBackdropType() == BackdropType.DARKROOM)
	then
		LairubFlags:AddFlag("HUNTED_DOWN")
	else
		LairubFlags:RemoveFlag("HUNTED_DOWN")
	end
	
	if player:GetPlayerType() == playerType_Lairub and not player:IsDead() then
		level:AddAngelRoomChance(-20000)
		if level:GetStage() == 13 then
			player:AddBlackHearts(6)
		end
	end
	
	if gameInited then
		SaveLairubModData()
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
	TriggeredCount = 0
	BaseFrameCount = 0
	
	ReadySpawnCross = false
	DetermineDirection = false
	SpawnedCross = false
	
	RoomKillCount = 0
	BoneCount = 0
	
	for i, entity in pairs(roomEntities) do
		if entity.Type == EntityType.ENTITY_FAMILIAR then
			if entity.Variant == LairubSoulCross_Variant then
				entity:Remove()
			end
			if entity.Variant == LairubTheBone_Variant then
				entity:Remove()
			end
		end
	end
	
	if gameInited then
		SaveLairubModData()
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_NEW_ROOM, lairub.PostNewRoom)

function lairub:ExecuteCmd(cmd, params)
	if cmd == "soulcount" then
		if tonumber(params) ~= nil then
			SoulCount = tonumber(params)
			Isaac.ConsoleOutput("=u=")
		else
			Isaac.ConsoleOutput("qnp")
		end
	end
end
lairub:AddCallback(ModCallbacks.MC_EXECUTE_CMD, lairub.ExecuteCmd)
