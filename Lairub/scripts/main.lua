
local playerType_Lairub = Isaac.GetPlayerTypeByName("Lairub")
local playerType_Tainted_Lairub = Isaac.GetPlayerTypeByName("Tainted Lairub", true)

local function IsLairub(player)
	return player ~= nil and player:GetPlayerType() == playerType_Lairub
end

local function IsLairubTainted(player)
	return player ~= nil and player:GetPlayerType() == playerType_Tainted_Lairub
end

--==== Const values ====--
--==Costume and something else==--
--Wait, something else???????
local costume_Lairub_Body = Isaac.GetCostumeIdByPath("gfx/characters/LairubBody.anm2")
local costume_Lairub_Head = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead.anm2")
local costume_Lairub_Head_TakeSoul = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead_TakeSoul.anm2")
local costume_Lairub_Head_TakeSoulBase = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead_TakeSoulBase.anm2")

local LairubStatUpdateItem = Isaac.GetItemIdByName( "Lairub Stat Trigger" )

local LairubSoulCross_Variant = Isaac.GetEntityVariantByName("LairubSoulCross")
local LairubSoulEffect_Variant = Isaac.GetEntityVariantByName("LairubSoulEffect")

local costume_TaintedLairub_Body = Isaac.GetCostumeIdByPath("gfx/characters/TaintedLairubBody.anm2")
local costume_TaintedLairub_Head = Isaac.GetCostumeIdByPath("gfx/characters/TaintedLairubHead.anm2")

local SoulSign = Sprite()
SoulSign:Load("gfx/Lairub_SoulSign.anm2", true)
SoulSign:SetOverlayRenderPriority(true)
SoulSign:SetFrame("SoulSign", 1)

--==== Temporary values ====--
local gameInited = false

--== Soul Stone ==--

local lairubSoulStoneID = Isaac.GetCardIdByName("Soul of Lairub")
local UsedLairubSoulStone = false
local TriggerDelay = 1
local TriggeredCount = 0
local BaseFrameCount = 0
local BaseGameFrameCount = 0
local DMGtoEveryNPC = false
local TotalRoomFrame = 0

--==HuntedDown==--
local HuntedDownReadout = "none" -- none, safe, BOSS, Vigilant, DANGER
local HuntedDownReadoutNumber = 0

--==== Saved values ====--

local SoulCount = 0
local HuntedDownFrame = -1

Explorite.RegistSideBar("LairubSouls", function()
	if not PlayerTypeExistInGame(playerType_Lairub) then return nil end
	return SoulSign, Parse00(SoulCount)
end)

local LairubDialogueManager = {}
LairubDialogueManager.onGoingDialogue = nil
LairubDialogueManager.step = 0

local lairubPlayerData = {
}
lairubPlayerData.__index = lairubPlayerData

function lairubPlayerData:UpdateLastRoomVar()
	self.lastRoom = {}
	self.lastRoom.form = self.form
end
function lairubPlayerData:RewindLastRoomVar()
	self.form = self.lastRoom.form
	self:UpdateLastRoomVar()
end
function lairubPlayerData:GenSpriteCaches()
	self.sprites = {}
	self.sprites.AttackIcon = Sprite()
	self.sprites.AttackIcon:Load("gfx/Lairub_AttackIcon.anm2", true)
	self.sprites.AttackIcon:SetOverlayRenderPriority(true)
	self.sprites.CrossIcon = Sprite()
	self.sprites.CrossIcon:Load("gfx/Lairub_CrossIcon.anm2", true)
	self.sprites.CrossIcon:SetOverlayRenderPriority(true)
	self.sprites.ReleaseIcon = Sprite()
	self.sprites.ReleaseIcon:Load("gfx/Lairub_ReleaseIcon.anm2", true)
	self.sprites.ReleaseIcon:SetOverlayRenderPriority(true)
	self.sprites.TeleportSign = Sprite()
	self.sprites.TeleportSign:Load("gfx/Lairub_TeleportSign.anm2", true)
	self.sprites.TeleportSign:SetOverlayRenderPriority(true)
end

local function LairubPlayerData()
	local cted = {}
	setmetatable(cted, lairubPlayerData)
	cted.form = 1
	cted.crossPlaced = nil
	cted.crossPlacedOnce = false
	cted.pressingKeys = Explorite.NewExploriteFlags()
	cted.pressedKeys = Explorite.NewExploriteFlags()
	cted.releasedKeys = Explorite.NewExploriteFlags()

	cted.overlayName = nil
	cted.overlaySprite = nil
	cted.overlayOffset = nil
	cted.overlayFrame = 0
	cted.overlayWearoff = 0
	
	cted.enabledAbility = nil
	cted.justDisabledAbility = nil
	cted.enabledAbilityTime = 0

	cted:UpdateLastRoomVar()
	cted:GenSpriteCaches()
	return cted
end

local LairubPlayerDatas = {}
LairubPlayerDatas[1] = LairubPlayerData()
LairubPlayerDatas[2] = LairubPlayerData()
LairubPlayerDatas[3] = LairubPlayerData()
LairubPlayerDatas[4] = LairubPlayerData()

local LastRoom = {}

--==== Data Management ====--

local function UpdateLastRoomVar()
	LastRoom = {}
	LastRoom.SoulCount = SoulCount
	for playerID=1,4 do
		LairubPlayerDatas[playerID]:UpdateLastRoomVar()
	end
end

local function RewindLastRoomVar()
	SoulCount = LastRoom.SoulCount
	for playerID=1,4 do
		LairubPlayerDatas[playerID]:RewindLastRoomVar()
	end
	UpdateLastRoomVar()
end

local function WipeTempVar()
	LairubFlags:Wipe()
	LairubPlayerDatas = {}
	LairubPlayerDatas[1] = LairubPlayerData()
	LairubPlayerDatas[2] = LairubPlayerData()
	LairubPlayerDatas[3] = LairubPlayerData()
	LairubPlayerDatas[4] = LairubPlayerData()

	HuntedDownReadout = "none"
	HuntedDownReadoutNumber = 0

	LairubDialogueManager = {}
	LairubDialogueManager.onGoingDialogue = nil
	LairubDialogueManager.step = 0
	
	SoulCount = 0
	
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

	UpdateLastRoomVar()
end

--==== Store mod Data ====--

function LairubObjectives:Apply()
	LairubFlags:Wipe()
	LairubFlags:LoadFromString(self:Read("Flags", ""))
	SoulCount = tonumber(self:Read("SoulCount", "0"))
	HuntedDownReadout = self:Read("HuntedDownReadout", "none")
	HuntedDownReadoutNumber = tonumber(self:Read("HuntedDownReadoutNumber", "0"))

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
	local room = game:GetRoom()

	-- if not in Sheol or Dark Room, hide timer
	if not LairubFlags:HasFlag("HUNTED_DOWN") or not PlayerTypeExistInGame(playerType_Lairub) then
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
		
		CallForEveryPlayer(
			function(player)
				if IsLairub(player) then
					player:TakeDamage(HuntedDownDamagePerShot, DamageFlag.DAMAGE_DEVIL | DamageFlag.DAMAGE_INVINCIBLE , EntityRef(player), 0)
				end
			end
		)
	end
	
end

local function HuntedDownRendering()
	if LairubFlags:HasFlag("DIALOGUE_OVER_HUNTDOWN") and HuntedDownReadout ~= "none" and PlayerFindFirst(function(player) return IsLairubButtonPressed(player,"hide_ui") end) == nil then
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
		
		Explorite.RenderScaledText(displayNumber, (Isaac.GetScreenWidth() - Explorite.GetTextWidth(displayNumber)*2) / 2, 60, 2, 2, R, G, B, A)
		Explorite.RenderScaledText(HuntedDownReadout, (Isaac.GetScreenWidth() - Explorite.GetTextWidth(HuntedDownReadout)) / 2, 80, 1, 1, R, G, B, A)
	end
end

--==== Overlay claim ====--

local function MaintainOverlay(player)
	local playerID = GetPlayerID(player)
	local overlayName = LairubPlayerDatas[playerID].overlayName
	if type(LairubOverlayDatas[overlayName]) ~= "function" then
		overlayName = nil
		LairubPlayerDatas[playerID].overlayName = nil
	end
	if overlayName == nil then
		if LairubPlayerDatas[playerID].overlaySprite ~= nil then
			if LairubPlayerDatas[playerID].overlayWearoff < 4 then
				LairubPlayerDatas[playerID].overlayWearoff = LairubPlayerDatas[playerID].overlayWearoff + 1
			else
				LairubPlayerDatas[playerID].overlayWearoff = 0
				LairubPlayerDatas[playerID].overlaySprite = nil
				LairubPlayerDatas[playerID].overlayOffset = nil
				LairubPlayerDatas[playerID].overlayFrame = 0
			end
		end
	else
		if LairubPlayerDatas[playerID].overlaySprite == nil then
			LairubPlayerDatas[playerID].overlaySprite, LairubPlayerDatas[playerID].overlayOffset = LairubOverlayDatas[overlayName]()
		end
		--player:PlayExtraAnimation("NOTEXIST BUT WORKS!!!!!!")
		player:SetColor(Color(1, 1, 1, 0, 255, 255, 255), 2, 1, false, false)
	end
	if LairubPlayerDatas[playerID].overlaySprite ~= nil then
		player.ControlsCooldown = math.max(1, player.ControlsCooldown)
	end
end
local function SetLairubOverlay(player, overlayName)
	local playerID = GetPlayerID(player)
	if type(LairubOverlayDatas[overlayName]) == "function" then
		LairubPlayerDatas[playerID].overlayName = overlayName
		LairubPlayerDatas[playerID].overlaySprite = nil
		LairubPlayerDatas[playerID].overlayFrame = 0
		LairubPlayerDatas[playerID].overlayWearoff = 0
		MaintainOverlay(player)
	end
end
local function ClearLairubOverlay(player, overlayName)
	local playerID = GetPlayerID(player)
	if LairubPlayerDatas[playerID].overlayName == overlayName then
		LairubPlayerDatas[playerID].overlayName = nil
		MaintainOverlay(player)
	end
end

function lairub:LairubSoulEffectUpdate(entity)
	entity:GetSprite():Play("SoulEffect", false)
	if entity:GetSprite():WasEventTriggered("End") then
		entity:Remove()
	end
end
lairub:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, lairub.LairubSoulEffectUpdate, LairubSoulEffect_Variant)

--==== Ability claim ====--
local lairubAbilityData = {}
lairubAbilityData.__index = lairubAbilityData
local function LairubAbilityData()
	local cted = {}
	setmetatable(cted, lairubAbilityData)
	cted.name = ""
	cted.startingInterval = function (player) end
	cted.endingInterval = function (player) end
	cted.enabledInterval = function (player) end
	cted.onEnable = function (player) end
	cted.onDisable = function (player) end
	return cted
end
local LairubAbilityDatas = {}

local function CanEnableAbility(player, ability)
	local playerID = GetPlayerID(player)
	if LairubAbilityDatas[ability] == nil then
		return false
	end
	if ability == "dialogue" then
		return true
	end
	return LairubPlayerDatas[playerID].justDisabledAbility ~= ability and (LairubPlayerDatas[playerID].enabledAbility == nil or LairubPlayerDatas[playerID].enabledAbility == ability)
end

local function IsAbilityEnabled(player, ability)
	return LairubPlayerDatas[GetPlayerID(player)].enabledAbility == ability
end

local function ReleaseAbility(player, ability)
	local playerID = GetPlayerID(player)
	if LairubPlayerDatas[playerID].enabledAbility == ability then
		LairubAbilityDatas[ability].onDisable(player)
		LairubPlayerDatas[playerID].justDisabledAbility = ability
		LairubPlayerDatas[playerID].enabledAbility = nil
		LairubPlayerDatas[playerID].enabledAbilityTime = 0
		return true
	end
	return false
end

local function ClaimAbility(player, ability)
	local playerID = GetPlayerID(player)
	if CanEnableAbility(player, ability) then
		if LairubPlayerDatas[playerID].enabledAbility ~= nil then
			ReleaseAbility(player, ability)
		end
		if LairubPlayerDatas[playerID].enabledAbility ~= ability then
			LairubPlayerDatas[playerID].enabledAbility = ability
			LairubPlayerDatas[playerID].enabledAbilityTime = 0
			LairubAbilityDatas[ability].onEnable(player)
		end
		return true
	end
	return false
end

--==== Key process ====--
local function LairubButtonName(player, name)
	if player == nil and false then
		return ""
	elseif name == "hide_ui" then
		return "TAB"
	elseif name == "swap_form" then
		return "LSHIFT"
	elseif name == "soul_cross" then
		return "LCTRL"
	elseif name == "release_souls" then
		return "LALT"
	elseif name == "up" then
		return "UP"
	elseif name == "down" then
		return "DOWN"
	elseif name == "left" then
		return "LEFT"
	elseif name == "right" then
		return "RIGHT"
	elseif name == "teleport_to_devil_room" then
		return "X"
	elseif name == "step_dialogue" then
		return "Z"
	elseif name == "help" then
		return "H"
	else
		return ""
	end
end

local function IsLairubButtonPressed(player, name)
	if player == nil then
		return false
	elseif not player.ControlsEnabled then
		return false
	elseif name == "hide_ui" then
		return Input.IsButtonPressed(Keyboard.KEY_TAB, player.ControllerIndex)
	elseif name == "step_dialogue" then
		return Input.IsButtonPressed(Keyboard.KEY_Z, player.ControllerIndex)
	elseif name == "help" then
		return Input.IsButtonPressed(Keyboard.KEY_H, player.ControllerIndex)
	elseif name == "up" then
		return Input.IsButtonPressed(Keyboard.KEY_UP, player.ControllerIndex)
	elseif name == "down" then
		return Input.IsButtonPressed(Keyboard.KEY_DOWN, player.ControllerIndex)
	elseif name == "left" then
		return Input.IsButtonPressed(Keyboard.KEY_LEFT, player.ControllerIndex)
	elseif name == "right" then
		return Input.IsButtonPressed(Keyboard.KEY_RIGHT, player.ControllerIndex)
	elseif name == "swap_form" and CanEnableAbility(player, "swap_form") then
		return Input.IsButtonPressed(Keyboard.KEY_LEFT_SHIFT, player.ControllerIndex)
	elseif name == "soul_cross" and CanEnableAbility(player, "soul_cross") then
		return Input.IsButtonPressed(Keyboard.KEY_LEFT_CONTROL, player.ControllerIndex)
	elseif name == "release_souls" and CanEnableAbility(player, "release_souls") then
		return Input.IsButtonPressed(Keyboard.KEY_LEFT_ALT, player.ControllerIndex)
	elseif name == "teleport_to_devil_room" and CanEnableAbility(player, "teleport_to_devil_room") then
		return Input.IsButtonPressed(Keyboard.KEY_X, player.ControllerIndex)
	else
		return false
	end
end

local function UpdateMonitKey(player, name)
	local playerID = GetPlayerID(player)
	if IsLairubButtonPressed(player, name) then
		if not LairubPlayerDatas[playerID].pressingKeys:HasFlag(name) then
			LairubPlayerDatas[playerID].pressingKeys:AddFlag(name)
			LairubPlayerDatas[playerID].pressedKeys:AddFlag(name)
		end
	else
		if LairubPlayerDatas[playerID].pressingKeys:HasFlag(name) then
			LairubPlayerDatas[playerID].pressingKeys:RemoveFlag(name)
			LairubPlayerDatas[playerID].releasedKeys:AddFlag(name)
		end
	end
end

local function MonitKeyPress(player, name)
	return LairubPlayerDatas[GetPlayerID(player)].pressedKeys:HasFlag(name)
end

local function MonitKeyRelease(player, name)
	return LairubPlayerDatas[GetPlayerID(player)].releasedKeys:HasFlag(name)
end

local function UpdateMonitKeys(player)
	local playerID = GetPlayerID(player)
	LairubPlayerDatas[playerID].pressedKeys:Wipe()
	LairubPlayerDatas[playerID].releasedKeys:Wipe()
	UpdateMonitKey(player, "hide_ui")
	UpdateMonitKey(player, "swap_form")
	UpdateMonitKey(player, "soul_cross")
	UpdateMonitKey(player, "release_souls")
	UpdateMonitKey(player, "up")
	UpdateMonitKey(player, "down")
	UpdateMonitKey(player, "left")
	UpdateMonitKey(player, "right")
	UpdateMonitKey(player, "teleport_to_devil_room")
	UpdateMonitKey(player, "step_dialogue")
	UpdateMonitKey(player, "help")
end

--================================--

function UpdateCache(player)
	player:RemoveCollectible(LairubStatUpdateItem)
	--player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	--player:AddCacheFlags(CacheFlag.CACHE_SPEED)
	--player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
end

function UpdateCostume(player)
	if IsLairub(player) then
		player:TryRemoveNullCostume(costume_Lairub_Body)
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_JUPITER) then
			player:AddNullCostume(costume_Lairub_Body)
		end
		if LairubPlayerDatas[GetPlayerID(player)].form ~= 2 then
			player:TryRemoveNullCostume(costume_Lairub_Head)
			player:AddNullCostume(costume_Lairub_Head)
		else
			player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
			player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
			player:AddNullCostume(costume_Lairub_Head_TakeSoul)
			player:AddNullCostume(costume_Lairub_Head_TakeSoulBase)
		end
	else
		player:TryRemoveNullCostume(costume_Lairub_Body)
		player:TryRemoveNullCostume(costume_Lairub_Head)
		player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
		player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
	end
end

function lairub:PostPlayerInit(player)
end
lairub:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, lairub.PostPlayerInit)

function lairub:EvaluateCache(player, cacheFlag)
	if IsLairub(player) then
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
			UpdateCostume(player)
		elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
			local maybeFamiliars = Isaac.GetRoomEntities()
			for m = 1, #maybeFamiliars do
				local variant = maybeFamiliars[m].Variant
				if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
					UpdateCostume(player)
				end
			end
		end
		if LairubPlayerDatas[GetPlayerID(player)].form == 2 then
			if cacheFlag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed - 0.2
			elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage + 1.3
			elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = player.MaxFireDelay + 8
			end
		end
	end
end
lairub:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, lairub.EvaluateCache)

--==== Abilities ====--

LairubAbilityDatas.swap_form = LairubAbilityData()
LairubAbilityDatas.swap_form.name = "swap_form"
LairubAbilityDatas.swap_form.startingInterval = function (player) if MonitKeyPress(player,"swap_form") then ClaimAbility(player, "swap_form") end end
LairubAbilityDatas.swap_form.endingInterval = function (player) if LairubPlayerDatas[GetPlayerID(player)].enabledAbilityTime > 30 then ReleaseAbility(player, "swap_form") end end
LairubAbilityDatas.swap_form.onEnable = function (player)
	local playerID = GetPlayerID(player)
	if LairubPlayerDatas[playerID].form == 2 then
		LairubPlayerDatas[playerID].form = 1
		SetLairubOverlay(player, "ChangedToNormal")
	else
		LairubPlayerDatas[playerID].form = 2
		SetLairubOverlay(player, "ChangedToTakeSoul")
	end
	--player.Velocity = Vector(0, 0)
	player.ControlsCooldown = math.max(30, player.ControlsCooldown)
	UpdateCostume(player)
	UpdateCache(player)
end
LairubAbilityDatas.swap_form.onDisable = function (player)
	ClearLairubOverlay(player, "ChangedToTakeSoul")
	ClearLairubOverlay(player, "ChangedToNormal")
end

LairubAbilityDatas.release_souls = LairubAbilityData()
LairubAbilityDatas.release_souls.name = "release_souls"
LairubAbilityDatas.release_souls.startingInterval = function (player) if IsLairubButtonPressed(player,"release_souls") then ClaimAbility(player, "release_souls") end end
LairubAbilityDatas.release_souls.endingInterval = function (player) if not IsLairubButtonPressed(player,"release_souls") then ReleaseAbility(player, "release_souls") end end
LairubAbilityDatas.release_souls.onEnable = function (player)
	--player.Velocity = Vector(0, 0)
	SetLairubOverlay(player, "ReleaseSoul")
end
LairubAbilityDatas.release_souls.onDisable = function (player)
	ClearLairubOverlay(player, "ReleaseSoul")
end
LairubAbilityDatas.release_souls.enabledInterval = function (player)
	player.ControlsCooldown = math.max(1, player.ControlsCooldown)
	if SoulCount > 0 then
		CallForEveryEntity(function(entity)
			local NPC = entity:ToNPC()
			if NPC ~= nil and NPC:IsVulnerableEnemy() and not NPC:IsInvincible() and not NPC:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
				if (player.Position - NPC.Position):Length() < 192 or Game():GetLevel():GetStage() == 13 then
					SoulCount = SoulCount - 1
					NPC:TakeDamage(player.Damage, 0, EntityRef(player), 0)
					NPC:SetColor(Color(0, 0, 0, 1, 0, 0, 0), 30, 999, true, true)
					if SoulCount < 0 then
						SoulCount = 0
					end
				end
			end
		end)
	end
end

LairubAbilityDatas.soul_cross = LairubAbilityData()
LairubAbilityDatas.soul_cross.name = "soul_cross"
LairubAbilityDatas.soul_cross.startingInterval = function (player)
	if MonitKeyPress(player,"soul_cross") and (
		LairubPlayerDatas[GetPlayerID(player)].crossPlaced == nil or LairubPlayerDatas[GetPlayerID(player)].crossPlaced:IsDead()
	) then
		ClaimAbility(player, "soul_cross")
	end
end
LairubAbilityDatas.soul_cross.onEnable = function (player)
	--player.Velocity = Vector(0, 0)
	SetLairubOverlay(player, "ReadySpawnCross")
end
LairubAbilityDatas.soul_cross.onDisable = function (player)
	ClearLairubOverlay(player, "ReadySpawnCross")
end
LairubAbilityDatas.soul_cross.endingInterval = function (player)
	local playerID = GetPlayerID(player)
	if MonitKeyPress(player,"soul_cross") or (LairubPlayerDatas[GetPlayerID(player)].crossPlaced ~= nil and not LairubPlayerDatas[GetPlayerID(player)].crossPlaced:IsDead()) then
		ReleaseAbility(player, "soul_cross")
		return
	end
	
	local dirKeys = 0
	local offset = Vector(0,0)
	if MonitKeyPress(player,"up") then
		dirKeys = dirKeys + 1
		offset = Vector(0, -40)
	end
	if MonitKeyPress(player,"down") then
		dirKeys = dirKeys + 1
		offset = Vector(0, 40)
	end
	if MonitKeyPress(player,"left") then
		dirKeys = dirKeys + 1
		offset = Vector(-40, 0)
	end
	if MonitKeyPress(player,"right") then
		dirKeys = dirKeys + 1
		offset = Vector(40, 0)
	end
	
	if dirKeys ~= 1 then
		player.ControlsCooldown = math.max(1, player.ControlsCooldown)
		return
	end
	
	local pos = Vector(math.floor((player.Position.X + offset.X + 20)/40.0)*40, math.floor((player.Position.Y + offset.Y + 20)/40.0)*40)

	SFXManager():Play(2, 2, 0, false, 0.7 )
	LairubCross = Isaac.Spawn(EntityType.ENTITY_EFFECT, LairubSoulCross_Variant, 0, pos, Vector(0,0), player)
	LairubCross:GetData().cross_owner = player
	LairubCross:BloodExplode()
	if not LairubPlayerDatas[playerID].crossPlacedOnce then
		CallForEveryEntity(function (entity)
			local NPC = entity:ToNPC()
			if NPC ~= nil and NPC:IsVulnerableEnemy() then
				if (player.Position - NPC.Position):Length() < 90 then
					NPC:TakeDamage((player.Damage * 2), 0, EntityRef(player), 0)
				end
			end
		end)
	end
	LairubPlayerDatas[playerID].crossPlaced = LairubCross
	LairubPlayerDatas[playerID].crossPlacedOnce = true
	ReleaseAbility(player, "soul_cross")
end

LairubAbilityDatas.teleport_to_devil_room = LairubAbilityData()
LairubAbilityDatas.teleport_to_devil_room.name = "teleport_to_devil_room"
LairubAbilityDatas.teleport_to_devil_room.startingInterval = function (player) if IsLairubButtonPressed(player,"teleport_to_devil_room") then ClaimAbility(player, "teleport_to_devil_room") end end
LairubAbilityDatas.teleport_to_devil_room.onEnable = function (player)
	--player.Velocity = Vector(0, 0)
	SetLairubOverlay(player, "TeleportToDevilRoom")
end
LairubAbilityDatas.teleport_to_devil_room.onDisable = function (player)
	ClearLairubOverlay(player, "TeleportToDevilRoom")
end
LairubAbilityDatas.teleport_to_devil_room.endingInterval = function (player)
	if LairubPlayerDatas[GetPlayerID(player)].enabledAbilityTime > 360 then
		player:UseCard(Card.CARD_JOKER, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANNOUNCER)
		ReleaseAbility(player, "teleport_to_devil_room")
		return
	end
	if not IsLairubButtonPressed(player,"teleport_to_devil_room") then
		ReleaseAbility(player, "teleport_to_devil_room")
		return
	end
end
LairubAbilityDatas.teleport_to_devil_room.enabledInterval = function (player)
	player.ControlsCooldown = math.max(1, player.ControlsCooldown)
end

LairubAbilityDatas.dialogue = LairubAbilityData()
LairubAbilityDatas.dialogue.name = "dialogue"
LairubAbilityDatas.dialogue.onDisable = function (player)
	ClearLairubOverlay(player, "TalkNormal")
	ClearLairubOverlay(player, "TalkHappy")
	ClearLairubOverlay(player, "TalkFear")
	ClearLairubOverlay(player, "TalkSigh")
end
LairubAbilityDatas.dialogue.endingInterval = function (player)
	if MonitKeyPress(player,"step_dialogue") then
		LairubDialogueManager.step = LairubDialogueManager.step + 1
	end
end
LairubAbilityDatas.dialogue.enabledInterval = function (player)
	player.ControlsCooldown = math.max(1, player.ControlsCooldown)
	local dialogue = LairubDialogueDatas[LairubDialogueManager.onGoingDialogue]
	if dialogue == nil then
		return
	end
	local step = dialogue.steps[LairubDialogueManager.step]
	if step == nil then
		return
	end
	SetLairubOverlay(player, "Talk"..step.emote)
end

--==== Rendering ====--

function DebugMessageRendering()
	CallForEveryPlayer(function(player)
		if not IsLairub(player) then
			return
		end
		local screenxy = Game():GetRoom():WorldToScreenPosition(player.Position)
		local x, y = screenxy.X, screenxy.Y
		local str1 = "Enabled: "..tostring(LairubPlayerDatas[GetPlayerID(player)].enabledAbility)
		Explorite.RenderText(str1, x - Explorite.GetTextWidth(str1)/2, y + 6, 255, 255, 255, 255)
	end)
end

function StartingTipRendering()
	if Game():GetFrameCount() < 60 then
		local player = PlayerTypeFirstOneInGame(playerType_Lairub)
		if player == nil then
			return
		end
		local screenxy = Game():GetRoom():WorldToScreenPosition(player.Position)
		local x, y = screenxy.X, screenxy.Y
		local str1 = LairubLang:_("starting_tip1", LairubButtonName(player, "hide_ui"))
		local str2 = LairubLang:_("starting_tip2", LairubButtonName(player, "help"))
		Explorite.RenderText(str1, x - Explorite.GetTextWidth(str1)/2, y + 6, 255, 255, 255, 255)
		Explorite.RenderText(str2, x - Explorite.GetTextWidth(str2)/2, y + 16, 255, 255, 255, 255)
	end
end

function DialogueRendering()
	local player = PlayerTypeFirstOneInGame(playerType_Lairub)
	if player == nil then
		return
	end
	local dialogue = LairubDialogueDatas[LairubDialogueManager.onGoingDialogue]
	if dialogue == nil then
		return
	end
	local step = dialogue.steps[LairubDialogueManager.step]
	if step == nil then
		return
	end
	local screenxy = Game():GetRoom():WorldToScreenPosition(player.Position)
	local x, y = screenxy.X, screenxy.Y
	local lines = {}
	local steppingStr = LairubLang:_("dialogue_stepping_hint", LairubButtonName(player, "step_dialogue"))
	local maxWidth = Explorite.GetTextWidth(steppingStr)
	table.insert(lines, LairubLang:_("dialogue_title"))
	for i,val in ipairs(step.text) do
		local str = LairubLang:_(val)
		maxWidth = math.max(maxWidth, Explorite.GetTextWidth(str))
		table.insert(lines, str)
	end
	for i,val in ipairs(lines) do
		Explorite.RenderText(val, x - maxWidth/2, y - 74 - 10 * (#lines - i), 255, 255, 255, 255)
	end
	Explorite.RenderText(steppingStr, x - Explorite.GetTextWidth(steppingStr)/2, y - 64, 255, 255, 255, 255)
end

function HelpScreenRending()
	local player = PlayerFindFirst(function(player) return IsLairub(player) and IsLairubButtonPressed(player,"help") end)
	if player == nil then
		return
	end
	local string = LairubLang:_("help_screen",
	LairubButtonName(player, "swap_form"),
	LairubButtonName(player, "soul_cross"),
	LairubButtonName(player, "release_souls"),
	LairubButtonName(player, "teleport_to_devil_room"),
	string.format("%.2f", math.floor(0.5+player.Damage * 0.5 * 100) / 100),
	string.format("%.2f", math.floor(0.5+player.Damage * 2.0 * 100) / 100),
	string.format("%.2f", math.floor(0.5+player.Damage * 1.0 * 100) / 100)
	)
	local lineP = 0
	for line in string.gmatch(string, "([^\n]+)") do
		Explorite.RenderScaledText(line, 64, 76 + 10 * lineP, 1, 1, 1, 1, 1, 1)
		lineP = lineP + 1
	end
end

function AbilitiesCardRendering(pos, player)
	if not IsLairub(player) then
		return
	end
	local AttackIcon = LairubPlayerDatas[GetPlayerID(player)].sprites.AttackIcon
	local CrossIcon = LairubPlayerDatas[GetPlayerID(player)].sprites.CrossIcon
	local ReleaseIcon = LairubPlayerDatas[GetPlayerID(player)].sprites.ReleaseIcon
	local TeleportSign = LairubPlayerDatas[GetPlayerID(player)].sprites.TeleportSign
	--==AttackIcon==--
	if LairubPlayerDatas[GetPlayerID(player)].form ~= 2 then
		AttackIcon:SetFrame("Normal", 1)
	else
		AttackIcon:SetFrame("Take Soul", 1)
	end
	--==CrossIcon==--
	if LairubPlayerDatas[GetPlayerID(player)].crossPlaced == nil or LairubPlayerDatas[GetPlayerID(player)].crossPlaced:IsDead() then
		CrossIcon:SetFrame("Ready", 1)
	else
		CrossIcon:SetFrame("Locking", 1)
	end
	--==ReleaseIcon==--
	if SoulCount > 0 then
		ReleaseIcon:SetFrame("Ready", 1)
	elseif SoulCount <= 0 then
		ReleaseIcon:SetFrame("Locking", 1)
	end
	--==Teleport To Devil Room==--
	TeleportSign:SetFrame("TeleportSign", 1)

	AttackIcon:Render(pos + Vector(16*0, 16*1), Vector(0,0), Vector(0,0))
	CrossIcon:Render(pos + Vector(16*1, 16*0), Vector(0,0), Vector(0,0))
	ReleaseIcon:Render(pos +  Vector(16*2, 16*1), Vector(0,0), Vector(0,0))
	TeleportSign:Render(pos + Vector(16*1, 16*2), Vector(0,0), Vector(0,0))
end

function AbilitiesDisplayRendering()
	if PlayerFindFirst(function(player) return IsLairubButtonPressed(player,"hide_ui") end) ~= nil then
		return
	end
	local baseOffset = Vector(44,40)
	local offsetMod = Vector(20 * Options.HUDOffset, 12 * Options.HUDOffset)

	local soulDisplayPos = baseOffset + offsetMod + Vector(48, 48)
	SoulSign:Render(soulDisplayPos, Vector(0,0), Vector(0,0))
	Explorite.RenderTextB(tostring(SoulCount), soulDisplayPos.X + 8, soulDisplayPos.Y - 7, 1, 1, 1, 1, 0, false)

	local sortNum = 0
	CallForEveryPlayer(
		function(player)
			if IsLairub(player) then
				local offsetExtra = Vector(0, 0)
				if sortNum == 1 then
					offsetExtra = Vector(64, 0)
				elseif sortNum == 2 then
					offsetExtra = Vector(0, 64)
				elseif sortNum == 3 then
					offsetExtra = Vector(64, 64)
				end
				AbilitiesCardRendering(baseOffset + offsetMod + offsetExtra, player)
				sortNum = sortNum + 1
			end
		end
	)
end

function lairub:PostRender()
	if not Game():GetHUD():IsVisible() or not PlayerTypeExistInGame(playerType_Lairub) then
		return nil
	end
	StartingTipRendering()
	AbilitiesDisplayRendering()
	HuntedDownRendering()
	DialogueRendering()
	HelpScreenRending()
end
lairub:AddCallback(ModCallbacks.MC_POST_RENDER, lairub.PostRender)

function lairub:LairubSoulCrossUpdate(turretEntity)
	local Data = turretEntity:GetData()
	local player = Data.cross_owner
	if player == nil then
		return
	end
	if Data.NPCdis == nil then Data.NPCdis = 0 end
	if Data.FireCooldown == nil then Data.FireCooldown = 0 end
	Data.FireCooldown = math.max(0, Data.FireCooldown - 1)
	if Data.FireCooldown <= 0 then
		CallForEveryEntity(function(entity)
			local NPC = entity:ToNPC()
			if NPC ~= nil and NPC:IsVulnerableEnemy() then
				if (turretEntity.Position - NPC.Position):Length() < Data.NPCdis then
					local Laser = player:FireTechLaser(turretEntity.Position, 1, (NPC.Position - turretEntity.Position), false, true)
					Laser.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
					Laser.CollisionDamage = player.Damage * 0.5
					local LaserSprite = Laser:GetSprite()
					LaserSprite:ReplaceSpritesheet(0,"gfx/effects/effect_LairubLaserEffects.png")
					LaserSprite:LoadGraphics("gfx/effects/effect_LairubLaserEffects.png")
					Data.NPCdis = 0
				elseif (turretEntity.Position - NPC.Position):Length() > Data.NPCdis then
					Data.NPCdis = Data.NPCdis + 96
				end
			end
		end)
		Data.FireCooldown = math.ceil(player.MaxFireDelay)
	end
end
lairub:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, lairub.LairubSoulCrossUpdate, LairubSoulCross_Variant)

local function TickEventLairub(player)
	if IsLairub(player) then
		local playerID = GetPlayerID(player)
		local level = Game():GetLevel()
		local room = Game():GetRoom()
		UpdateMonitKeys(player)
		if LairubPlayerDatas[playerID].overlaySprite ~= nil then
			LairubPlayerDatas[playerID].overlayFrame = LairubPlayerDatas[playerID].overlayFrame + 1
		end
		MaintainOverlay(player)
		--==== Changed Tears ====--	
		--== Changed Icon==--
		--== Function ==--
		CallForEveryEntity(function(entity)
			local tear = entity:ToTear()
			if tear ~= nil and tear.Parent ~= nil then
				if tear.Parent.Type == EntityType.ENTITY_PLAYER then
					local player = tear.Parent:ToPlayer()
					if IsLairub(player)
					then
						local data = tear:GetData()
						if not data.tearInitedForLairub then
							data.tearInitedForLairub = true
							local tearSprite = tear:GetSprite()
							if LairubPlayerDatas[playerID].form == 2 then
								if tear.Variant == TearVariant.BLUE or tear.Variant == TearVariant.BLOOD then
									tearSprite:ReplaceSpritesheet(0,"gfx/Tears/Lairub_Tears_Normal.png")
									tearSprite:LoadGraphics("gfx/Tears/Lairub_Tears_Normal.png")
								elseif tear.Variant == TearVariant.EYE or tear.Variant == TearVariant.EYE_BLOOD then
									tearSprite:ReplaceSpritesheet(0,"gfx/Tears/Lairub_Tears_Pop_Normal.png")
									tearSprite:LoadGraphics("gfx/Tears/Lairub_Tears_Pop_Normal.png")
								elseif tear.Variant == TearVariant.NAIL or tear.Variant == TearVariant.NAIL_BLOOD then
									tearSprite:ReplaceSpritesheet(0,"gfx/Tears/Lairub_8inchnails_tears.png")
									tearSprite:LoadGraphics("gfx/Tears/Lairub_8inchnails_tears.png")
								elseif tear.Variant == TearVariant.SCHYTHE then
									tearSprite:ReplaceSpritesheet(0,"gfx/Tears/Lairub_Scythe_Tears.png")
									tearSprite:LoadGraphics("gfx/Tears/Lairub_Scythe_Tears.png")
								end
							else
								if tear.Variant == TearVariant.BLUE or tear.Variant == TearVariant.BLOOD then
									tearSprite:ReplaceSpritesheet(0,"gfx/Tears/Lairub_Tears_Normal.png")
									tearSprite:LoadGraphics("gfx/Tears/Lairub_Tears_Normal.png")
								elseif tear.Variant == TearVariant.EYE or tear.Variant == TearVariant.EYE_BLOOD then
									tearSprite:ReplaceSpritesheet(0,"gfx/Tears/Lairub_Tears_Pop_Normal.png")
									tearSprite:LoadGraphics("gfx/Tears/Lairub_Tears_Pop_Normal.png")
								elseif tear.Variant == TearVariant.NAIL or tear.Variant == TearVariant.NAIL_BLOOD then
									tearSprite:ReplaceSpritesheet(0,"gfx/Tears/Lairub_8inchnails_tears.png")
									tearSprite:LoadGraphics("gfx/Tears/Lairub_8inchnails_tears.png")
								elseif tear.Variant == TearVariant.SCHYTHE then
									tearSprite:ReplaceSpritesheet(0,"gfx/Tears/Lairub_Scythe_Tears.png")
									tearSprite:LoadGraphics("gfx/Tears/Lairub_Scythe_Tears.png")
								end
							end
							tearSprite:LoadGraphics()
							tearSprite.Rotation = tear.Velocity:GetAngleDegrees()
						end
					end
				end
			end
			local NPC = entity:ToNPC()
			if NPC ~= nil and NPC:IsDead() and LairubPlayerDatas[playerID].form == 2 then
				if NPC:IsBoss() or IsLairubButtonPressed(player,"release_souls") or level:GetStage() == 13 then
					--Do nothing
				else
					Isaac.Spawn(EntityType.ENTITY_EFFECT, LairubSoulEffect_Variant, 0, NPC.Position, Vector(0,0), player)
				end
			end
		end)

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

		for k,dialogue in pairs(LairubDialogueDatas) do
			if LairubDialogueManager.onGoingDialogue ~= nil then
				break
			end
			if dialogue.shouldFire() and not LairubFlags:HasFlag(dialogue.flag) then
				LairubDialogueManager.step = 1
				LairubDialogueManager.onGoingDialogue = k
				CallForEveryPlayer(function(player) ClaimAbility(player, "dialogue") end)
			end
		end
		local enabledAbility
		enabledAbility = LairubPlayerDatas[playerID].enabledAbility
		if enabledAbility ~= nil then
			LairubPlayerDatas[playerID].enabledAbilityTime = LairubPlayerDatas[playerID].enabledAbilityTime + 1
			LairubAbilityDatas[enabledAbility].endingInterval(player)
		end

		if LairubDialogueManager.onGoingDialogue ~= nil then
			local dialogue = LairubDialogueDatas[LairubDialogueManager.onGoingDialogue]
			if LairubDialogueManager.step > #dialogue.steps then
				LairubDialogueManager.step = nil
				LairubDialogueManager.onGoingDialogue = nil
				LairubFlags:AddFlag(dialogue.flag)
				CallForEveryPlayer(function(player) ReleaseAbility(player, "dialogue") end)
			end
		end

		for x,ability in pairs(LairubAbilityDatas) do
			if LairubPlayerDatas[playerID].enabledAbility ~= nil then
				break
			end
			ability.startingInterval(player)
		end

		enabledAbility = LairubPlayerDatas[playerID].enabledAbility
		if enabledAbility ~= nil then
			LairubAbilityDatas[enabledAbility].enabledInterval(player)
		end

		LairubPlayerDatas[playerID].justDisabledAbility = nil
	end
end

function lairub:PostPlayerUpdate(player)
	TickEventLairub(player)
end
lairub:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, lairub.PostPlayerUpdate)

local function LairubRendering(player, pos)
	if IsLairub(player) then
		local playerID = GetPlayerID(player)
		local sprite = LairubPlayerDatas[playerID].overlaySprite
		local offset = LairubPlayerDatas[playerID].overlayOffset
		local screenxy = Game():GetRoom():WorldToScreenPosition(player.Position)
		if sprite ~= nil then
			sprite:Render(screenxy + offset, Vector(0,0), Vector(0,0))
			while LairubPlayerDatas[playerID].overlayFrame > 1 do
				sprite:Update()
				LairubPlayerDatas[playerID].overlayFrame = LairubPlayerDatas[playerID].overlayFrame - 2
			end
			--local str = "OVERLAY "..LairubPlayerDatas[playerID].overlayName.." TESTING"
			--Explorite.RenderText(str, screenxy.X - Explorite.GetTextWidth(str)/2, screenxy.Y, 255, 255, 255, 255)
		end
	end
end

function lairub:PostPlayerRender(player, pos)
	LairubRendering(player, pos)
end
lairub:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, lairub.PostPlayerRender, 0)

function lairub:Functions()
	HuntedDownInterval()
end
lairub:AddCallback( ModCallbacks.MC_POST_UPDATE, lairub.Functions)

function lairub:OnDamage(tookDamage, damage, damageFlags, damageSourceRef)
	local player = tookDamage:ToPlayer()
	if player ~= nil then
		ReleaseAbility(player, "teleport_to_devil_room")
	end
end
lairub:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, lairub.OnDamage, EntityType.ENTITY_PLAYER)

--==Tainted==--

--UNFINISHED--
function lairub:UnfinishedPostRender()
	if PlayerTypeExistInGame(playerType_Tainted_Lairub) then
		Explorite.RenderText("Unfinished, please wait for the update.", 78, 70, 1, 0, 0, 255)
	end
end
lairub:AddCallback(ModCallbacks.MC_POST_RENDER, lairub.UnfinishedPostRender)

function lairub:UnfinishedUpdate(player)
	if IsLairubTainted(player) then
		player.ControlsEnabled = false
		player.Visible = false
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_PLAYER_UPDATE, lairub.UnfinishedUpdate)

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
				Explorite.RenderText(tostring(SoulCount), playerPos.X + 5, playerPos.Y - 46, 255, 255, 255, 255)
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
		CallForEveryEntity(function(entity)
			if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == 111 then
				entity:SetColor(Color(1, 1, 1, 1, 1, 1, 1), 0, 999, true, true)
			end
		end)
		--==Function==--
		--DMG To Every NPC
		if DMGtoEveryNPC == false then
			CallForEveryEntity(function(entity)
				local NPC = entity:ToNPC()
				if NPC ~= nil and NPC:IsVulnerableEnemy() and not NPC:IsBoss() then
					NPC:TakeDamage(9999, 0, EntityRef(player), 0)
					if NPC:IsDead() then
						Isaac.Spawn(EntityType.ENTITY_EFFECT, LairubSoulEffect_Variant, 0, NPC.Position, Vector(0,0), player)
					end
				end
			end)
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
			CallForEveryEntity(function(entity)
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
					Isaac.Spawn(EntityType.ENTITY_EFFECT, LairubSoulEffect_Variant, 0, NPC.Position, Vector(0,0), player)
				end
			end)
		end
		--====--
	end
end
lairub:AddCallback(ModCallbacks.MC_POST_UPDATE, lairub.LairubSoulStoneFunction)

--==Universal==--

function lairub:PostNPCDeath()
	local player = Isaac.GetPlayer(0)
	if IsLairub(player) and LairubPlayerDatas[GetPlayerID(player)].form == 2 and not IsLairubButtonPressed(player,"release_souls") then
		SoulCount = SoulCount + 1
	end
	if UsedLairubSoulStone == true then
		SoulCount = SoulCount + 1
	end
end
lairub:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, lairub.PostNPCDeath)

function lairub:PrePickupCollision(pickup, collider, low)
	local player = collider:ToPlayer()
	if player ~= nil and (IsLairub(player) or IsLairubTainted(player)) then
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
						player:AnimatePickup(pickup:GetSprite())
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
	UsedLairubSoulStone = false
	DMGtoEveryNPC = false
	BaseGameFrameCount = 0
	LevelKillCount = 0
	LevelDevourOnce = false
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
	
	if IsLairub(player) and not player:IsDead() then
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
	
	TriggeredCount = 0
	BaseFrameCount = 0
	RoomKillCount = 0
	BoneCount = 0

	for i=1,4 do
		LairubPlayerDatas[1].crossPlaced = nil
		LairubPlayerDatas[1].crossPlacedOnce = false
	end

	if gameInited then
		SaveLairubModData()
	end
end
lairub:AddCallback( ModCallbacks.MC_POST_NEW_ROOM, lairub.PostNewRoom)

-- 时间回溯
function lairub:UseGlowingHourGlass(itemId, itemRng, player, useFlags, activeSlot, customVarData)
	if itemId == CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS
	--and IsHexanow(player)
	then
		RewindLastRoomVar()
	end
end
lairub:AddCallback(ModCallbacks.MC_USE_ITEM, lairub.UseGlowingHourGlass)

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
