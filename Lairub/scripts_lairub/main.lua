
LairubMod.Main = {}

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

--= Game item IDs =--
local costume_Lairub_Body = Isaac.GetCostumeIdByPath("gfx/characters/LairubBody.anm2")
local costume_Lairub_Head = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead.anm2")
local costume_Lairub_Head_TakeSoul = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead_TakeSoul.anm2")
local costume_Lairub_Head_TakeSoulBase = Isaac.GetCostumeIdByPath("gfx/characters/LairubHead_TakeSoulBase.anm2")

local LairubSoulCross_Variant = Isaac.GetEntityVariantByName("LairubSoulCross")
local LairubSoulEffect_Variant = Isaac.GetEntityVariantByName("LairubSoulEffect")

--= Sprite =--
local SoulSign = Sprite()
SoulSign:Load("gfx/Lairub_SoulSign.anm2", true)
SoulSign:SetOverlayRenderPriority(true)
SoulSign:SetFrame("SoulSign", 1)

--= Data =--
local LairubAbilityDatas = {}

--= Value conifg =--
local HuntedDownThreshold = 60 * 30 -- Exceeded this value result damage overtime
local HuntedDownDamageRate = 3 * 30 -- For ever amount of frames, dealt damage
local HuntedDownDamagePerShot = 2 -- Damage value

--= Classes and constructors =--
local lairubAbilityData = {}
lairubAbilityData.__index = lairubAbilityData
local function LairubAbilityData()
	local cted = {}
	setmetatable(cted, lairubAbilityData)
	cted.name = ""
	cted.displayAllowsEnable = function (player) return false end
	cted.startingInterval = function (player) end
	cted.endingInterval = function (player) end
	cted.enabledInterval = function (player) end
	cted.onEnable = function (player) end
	cted.onDisable = function (player) end
	return cted
end

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
	cted.noEnemiesBouns = true
	cted.form = 1
	cted.needchangeformcostume=false
	cted.changedformcostume=false
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
	
	cted.coinsNum = 0
	cted.canTeleportToDevilRoom = false
	cted.tryingTeleportToDevilRoom = false
	cted.renderedWarning = false
	cted.startWarningTick = 0

	cted:UpdateLastRoomVar()
	cted:GenSpriteCaches()
	return cted
end

--==== Temporary values ====--

--==HuntedDown==--
local HuntedDownReadout = "none" -- none, safe, BOSS, Vigilant, DANGER
local HuntedDownReadoutNumber = 0

--==== Saved values ====--

local SoulCount = 0
local HuntedDownFrame = -1

--[[
Explorite.RegistSideBar("LairubSouls", function()
	if not PlayerTypeExistInGame(playerType_Lairub) then return nil end
	return SoulSign, Parse00(SoulCount)
end)
]]

local LairubDialogueManager = {}
LairubDialogueManager.onGoingDialogue = nil
LairubDialogueManager.step = 0

local LairubPlayerDatas = {}
local LastRoom = {}

LairubPlayerDatas[1] = LairubPlayerData()
LairubPlayerDatas[2] = LairubPlayerData()
LairubPlayerDatas[3] = LairubPlayerData()
LairubPlayerDatas[4] = LairubPlayerData()

Explorite.RegistPlyaerAnmiOverride(playerType_Lairub, function (player)
	if LairubPlayerDatas[GetGamePlayerID(player)].form ~= 2 then
		return "gfx/characters/LairubRoot_form1.anm2"
	else
		return "gfx/characters/LairubRoot_form2.anm2"
	end
end)

--==== Data Management ====--

function LairubMod.Main.ApplyVar(objective)
	SoulCount = tonumber(objective:Read("SoulCount", "0"))
	HuntedDownReadout = objective:Read("HuntedDownReadout", "none")
	HuntedDownReadoutNumber = tonumber(objective:Read("HuntedDownReadoutNumber", "0"))
end

function LairubMod.Main.RecieveVar(objective)
	objective:Write("SoulCount", tostring(SoulCount))
	objective:Write("HuntedDownReadout", HuntedDownReadout)
	objective:Write("HuntedDownReadoutNumber", tostring(HuntedDownReadoutNumber))
end

function LairubMod.Main.UpdateLastRoomVar()
	LastRoom = {}
	LastRoom.SoulCount = SoulCount
	for playerID=1,4 do
		LairubPlayerDatas[playerID]:UpdateLastRoomVar()
	end
end

function LairubMod.Main.RewindLastRoomVar()
	SoulCount = LastRoom.SoulCount
	for playerID=1,4 do
		LairubPlayerDatas[playerID]:RewindLastRoomVar()
	end
end

function LairubMod.Main.WipeTempVar()
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
end

function LairubMod.Main.AddSoulCount(num)
	SoulCount = SoulCount + num
end

--================================--

--==Be Hunted Down In Stage10, BackdropType14(Sheol) And Stage11, BackdropType16(DarkRoom)==--

local function HuntedDownInterval()
	local level = Game():GetLevel()
	local room = Game():GetRoom()

	-- if not in Sheol or Dark Room, hide timer
	if not PlayerTypeExistInGame(playerType_Lairub)
	or not (
		(level:GetStage() == LevelStage.STAGE5 and level:GetStageType() == StageType.STAGETYPE_ORIGINAL)
	 or (level:GetStage() == LevelStage.STAGE6 and level:GetStageType() == StageType.STAGETYPE_ORIGINAL)
	)then
		HuntedDownReadout = "none"
		HuntedDownReadoutNumber = 0
		HuntedDownFrame = -1
		return nil
	end

	LairubFlags:AddFlag("FIRE_HUNTDOWN_DIALOGUE")

	-- if room is clear, stop timer
	if room:IsClear() then
		HuntedDownReadout = "safe"
		HuntedDownReadoutNumber = math.ceil(HuntedDownThreshold / 30)
		HuntedDownFrame = -1
		return nil
	end

	-- if room is boss room, stop timer
	if room:GetType() == RoomType.ROOM_BOSS then
		HuntedDownReadout = "boss"
		HuntedDownReadoutNumber = 0
		HuntedDownFrame = -1
		return nil
	end

	-- if all invalid testing are passed, timing

	HuntedDownFrame = HuntedDownFrame + 1

	-- if time below threshold, stop trigger damage
	if HuntedDownFrame < HuntedDownThreshold then
		HuntedDownReadout = "vigilant"
		HuntedDownReadoutNumber = math.ceil((HuntedDownThreshold - HuntedDownFrame) / 30)
		return nil
	end

	-- execute damage
	HuntedDownReadout = "danger"
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

--==== Overlay claim ====--

local function MaintainOverlay(player)
	local playerID = GetGamePlayerID(player)
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
	local playerID = GetGamePlayerID(player)
	if type(LairubOverlayDatas[overlayName]) == "function" then
		LairubPlayerDatas[playerID].overlayName = overlayName
		LairubPlayerDatas[playerID].overlaySprite = nil
		LairubPlayerDatas[playerID].overlayFrame = 0
		LairubPlayerDatas[playerID].overlayWearoff = 0
		MaintainOverlay(player)
	end
end
local function ClearLairubOverlay(player, overlayName)
	local playerID = GetGamePlayerID(player)
	if LairubPlayerDatas[playerID].overlayName == overlayName then
		LairubPlayerDatas[playerID].overlayName = nil
		MaintainOverlay(player)
	end
end

function LairubMod.Main:LairubSoulEffectUpdate(entity)
	entity:GetSprite():Play("SoulEffect", false)
	if entity:GetSprite():WasEventTriggered("End") then
		entity:Remove()
	end
end
LairubMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, LairubMod.Main.LairubSoulEffectUpdate, LairubSoulEffect_Variant)

--==== Ability claim ====--

local function DisplayCanEnableAbility(player, ability)
	local playerID = GetGamePlayerID(player)
	if LairubAbilityDatas[ability] == nil or player == nil then
		return false
	end
	if not IsLairub(player) then
		return false
	end
	if player:IsDead() then
		return false
	end
	if player:IsCoopGhost() then
		return false
	end
	return LairubAbilityDatas[ability].displayAllowsEnable(player)
end

local function CanEnableAbility(player, ability)
	local playerID = GetGamePlayerID(player)
	if LairubAbilityDatas[ability] == nil or player == nil then
		return false
	end
	if not IsLairub(player) then
		return false
	end
	if player:IsDead() then
		return false
	end
	if player:IsCoopGhost() then
		return false
	end
	if ability == "dialogue" then
		return true
	end
	if not player.ControlsEnabled then
		return false
	end
	return LairubPlayerDatas[playerID].justDisabledAbility ~= ability and (LairubPlayerDatas[playerID].enabledAbility == nil or LairubPlayerDatas[playerID].enabledAbility == ability)
end

local function IsAbilityEnabled(player, ability)
	return LairubPlayerDatas[GetGamePlayerID(player)].enabledAbility == ability
end

local function ReleaseAbility(player, ability)
	local playerID = GetGamePlayerID(player)
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
	local playerID = GetGamePlayerID(player)
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
	if player == nil then
		return ""
	end
	if IsKeyboardInput(player.ControllerIndex) then
		if name == "hide_ui" then
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
		end
	else
		if name == "hide_ui" then
			return "BACK"
		elseif name == "swap_form" then
			return "RT + ↑"
		elseif name == "soul_cross" then
			return "RT + ←"
		elseif name == "release_souls" then
			return "RT + →"
		elseif name == "up" then
			return "Y"
		elseif name == "down" then
			return "A"
		elseif name == "left" then
			return "X"
		elseif name == "right" then
			return "B"
		elseif name == "teleport_to_devil_room" then
			return "RT + ↓"
		elseif name == "step_dialogue" then
			return "RT"
		elseif name == "help" then
			return "BACK"
		end
	end
	return ""
end

local function IsLairubButtonPressed(player, name)
	if player == nil then
		return false
	end
	if IsKeyboardInput(player.ControllerIndex) then
		if name == "hide_ui" then
			return Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex)
		elseif name == "help" then
			return Input.IsButtonPressed(Keyboard.KEY_H, player.ControllerIndex)
		elseif name == "step_dialogue" then
			return Input.IsButtonPressed(Keyboard.KEY_Z, player.ControllerIndex)
		elseif name == "up" then
			return Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex)
		elseif name == "down" then
			return Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
		elseif name == "left" then
			return Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)
		elseif name == "right" then
			return Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex)
		elseif name == "swap_form" then
			return CanEnableAbility(player, "swap_form") and Input.IsButtonPressed(Keyboard.KEY_LEFT_SHIFT, player.ControllerIndex)
		elseif name == "soul_cross" then
			return CanEnableAbility(player, "soul_cross") and Input.IsButtonPressed(Keyboard.KEY_LEFT_CONTROL, player.ControllerIndex)
		elseif name == "release_souls" then
			return CanEnableAbility(player, "release_souls") and Input.IsButtonPressed(Keyboard.KEY_LEFT_ALT, player.ControllerIndex)
		elseif name == "teleport_to_devil_room" then
			return CanEnableAbility(player, "teleport_to_devil_room") and Input.IsButtonPressed(Keyboard.KEY_X, player.ControllerIndex)
		end
	else
		if name == "hide_ui" then
			return Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex)
		elseif name == "help" then
			return Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex)
		elseif name == "step_dialogue" then
			return Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex)
		elseif name == "up" then
			return Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex)
		elseif name == "down" then
			return Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
		elseif name == "left" then
			return Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)
		elseif name == "right" then
			return Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex)
		elseif name == "swap_form" then
			return CanEnableAbility(player, "swap_form") and Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) and Input.IsActionPressed(ButtonAction.ACTION_UP, player.ControllerIndex)
		elseif name == "soul_cross" then
			return CanEnableAbility(player, "soul_cross") and Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) and (IsAbilityEnabled(player,"soul_cross") or Input.IsActionPressed(ButtonAction.ACTION_LEFT, player.ControllerIndex))
		elseif name == "release_souls" then
			return CanEnableAbility(player, "release_souls") and (Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) or IsAbilityEnabled(player,"release_souls")) and Input.IsActionPressed(ButtonAction.ACTION_RIGHT, player.ControllerIndex)
		elseif name == "teleport_to_devil_room" then
			return CanEnableAbility(player, "teleport_to_devil_room") and (Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) or IsAbilityEnabled(player,"teleport_to_devil_room")) and Input.IsActionPressed(ButtonAction.ACTION_DOWN, player.ControllerIndex)
		end
	end
	return false
end

local function UpdateMonitKey(player, name)
	local playerID = GetGamePlayerID(player)
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
	return LairubPlayerDatas[GetGamePlayerID(player)].pressedKeys:HasFlag(name)
end

local function MonitKeyRelease(player, name)
	return LairubPlayerDatas[GetGamePlayerID(player)].releasedKeys:HasFlag(name)
end

local function UpdateMonitKeys(player)
	local playerID = GetGamePlayerID(player)
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

local function UpdateCostume(player)
	--[[
	if IsLairub(player) then
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_JUPITER) then
			player:AddNullCostume(costume_Lairub_Body)
		end
		if LairubPlayerDatas[GetGamePlayerID(player)].form ~= 2 then
			player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
			player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
			--player:TryRemoveNullCostume(costume_Lairub_Head)
			player:AddNullCostume(costume_Lairub_Head)
		else
			--player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
			--player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
			player:AddNullCostume(costume_Lairub_Head_TakeSoul)
			player:AddNullCostume(costume_Lairub_Head_TakeSoulBase)
		end
	else
		player:TryRemoveNullCostume(costume_Lairub_Body)
		player:TryRemoveNullCostume(costume_Lairub_Head)
		player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
		player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
	end
	]]
end

function LairubMod.Main:PostPlayerInit(player)
	if IsLairub(player) then
		UpdateCostume(player)
	end
end
LairubMod:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, LairubMod.Main.PostPlayerInit)

function LairubMod.Main:EvaluateCache(player, cacheFlag)
	if IsLairub(player) then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed - 0.3
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 1.09
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
		if LairubPlayerDatas[GetGamePlayerID(player)].form == 2 then
			if cacheFlag == CacheFlag.CACHE_SPEED and not LairubPlayerDatas[GetGamePlayerID(player)].noEnemiesBouns then
				player.MoveSpeed = player.MoveSpeed - 0.2
			elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage * 1.31
			elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = player.MaxFireDelay + 8
			end
			if LairubPlayerDatas[GetGamePlayerID(player)].needchangeformcostume == true then
				UpdateCostume(player)
				--LairubPlayerDatas[GetGamePlayerID(player)].changedformcostume = true
				LairubPlayerDatas[GetGamePlayerID(player)].needchangeformcostume = false
			end
		end
		--UpdateCostume(player)
	end
end
LairubMod:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, LairubMod.Main.EvaluateCache)

--==== Abilities ====--

LairubAbilityDatas.swap_form = LairubAbilityData()
LairubAbilityDatas.swap_form.name = "swap_form"
LairubAbilityDatas.swap_form.displayAllowsEnable = function (player) return true end
LairubAbilityDatas.swap_form.startingInterval = function (player) if MonitKeyPress(player,"swap_form") then ClaimAbility(player, "swap_form") end end
LairubAbilityDatas.swap_form.endingInterval = function (player) if LairubPlayerDatas[GetGamePlayerID(player)].enabledAbilityTime > 30 then ReleaseAbility(player, "swap_form") end end
LairubAbilityDatas.swap_form.onEnable = function (player)
	local playerID = GetGamePlayerID(player)
	if LairubPlayerDatas[playerID].form == 2 then
		LairubPlayerDatas[playerID].form = 1
		SetLairubOverlay(player, "ChangedToNormal")
	else
		LairubPlayerDatas[playerID].form = 2
		SetLairubOverlay(player, "ChangedToTakeSoul")
	end
	--player.Velocity = Vector(0, 0)
	player.ControlsCooldown = math.max(30, player.ControlsCooldown)
	--UpdateCostume(player)
	UpdateCache(player)
end
LairubAbilityDatas.swap_form.onDisable = function (player)
	ClearLairubOverlay(player, "ChangedToTakeSoul")
	ClearLairubOverlay(player, "ChangedToNormal")
end

LairubAbilityDatas.release_souls = LairubAbilityData()
LairubAbilityDatas.release_souls.name = "release_souls"
LairubAbilityDatas.release_souls.displayAllowsEnable = function (player) return SoulCount > 0 end
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
LairubAbilityDatas.soul_cross.displayAllowsEnable = function (player) return LairubPlayerDatas[GetGamePlayerID(player)].crossPlaced == nil or LairubPlayerDatas[GetGamePlayerID(player)].crossPlaced:IsDead() end
LairubAbilityDatas.soul_cross.startingInterval = function (player)
	if MonitKeyPress(player,"soul_cross") and (
		LairubPlayerDatas[GetGamePlayerID(player)].crossPlaced == nil or LairubPlayerDatas[GetGamePlayerID(player)].crossPlaced:IsDead()
	) then
		ClaimAbility(player, "soul_cross")
	end
end
LairubAbilityDatas.soul_cross.onEnable = function (player)
	local dirKeys = 0
	if IsLairubButtonPressed(player,"up") then
		dirKeys = dirKeys + 1
	end
	if IsLairubButtonPressed(player,"down") then
		dirKeys = dirKeys + 1
	end
	if IsLairubButtonPressed(player,"left") then
		dirKeys = dirKeys + 1
	end
	if IsLairubButtonPressed(player,"right") then
		dirKeys = dirKeys + 1
	end
	
	if dirKeys == 1 then
		return
	end
	--player.Velocity = Vector(0, 0)
	SetLairubOverlay(player, "ReadySpawnCross")
end
LairubAbilityDatas.soul_cross.onDisable = function (player)
	ClearLairubOverlay(player, "ReadySpawnCross")
end
LairubAbilityDatas.soul_cross.endingInterval = function (player)
	local playerID = GetGamePlayerID(player)
	if MonitKeyPress(player,"soul_cross") or (LairubPlayerDatas[GetGamePlayerID(player)].crossPlaced ~= nil and not LairubPlayerDatas[GetGamePlayerID(player)].crossPlaced:IsDead()) then
		ReleaseAbility(player, "soul_cross")
		return
	end
	
	local dirKeys = 0
	local offset = Vector(0,0)
	if IsLairubButtonPressed(player,"up") then
		dirKeys = dirKeys + 1
		offset = Vector(0, -40)
	end
	if IsLairubButtonPressed(player,"down") then
		dirKeys = dirKeys + 1
		offset = Vector(0, 40)
	end
	if IsLairubButtonPressed(player,"left") then
		dirKeys = dirKeys + 1
		offset = Vector(-40, 0)
	end
	if IsLairubButtonPressed(player,"right") then
		dirKeys = dirKeys + 1
		offset = Vector(40, 0)
	end
	
	if dirKeys ~= 1 then
		player.ControlsCooldown = math.max(1, player.ControlsCooldown)
		player.FireDelay = math.floor(player.MaxFireDelay)
		return
	end
	
	local pos = Vector(math.floor((player.Position.X + offset.X + 20)/40.0)*40, math.floor((player.Position.Y + offset.Y + 20)/40.0)*40)

	SFXManager():Play(2, 2, 0, false, 0.7 )
	LairubCross = Isaac.Spawn(EntityType.ENTITY_EFFECT, LairubSoulCross_Variant, 0, pos, Vector(0,0), player)
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector(0,0), nil)
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
LairubAbilityDatas.teleport_to_devil_room.displayAllowsEnable = function (player) return true end

LairubAbilityDatas.teleport_to_devil_room.startingInterval = function (player)
	if IsLairubButtonPressed(player,"teleport_to_devil_room") then
	
		LairubPlayerDatas[GetGamePlayerID(player)].coinsNum = player:GetNumCoins()
		LairubPlayerDatas[GetGamePlayerID(player)].tryingTeleportToDevilRoom = true
		
		if LairubPlayerDatas[GetGamePlayerID(player)].coinsNum >= 13 then
			LairubPlayerDatas[GetGamePlayerID(player)].canTeleportToDevilRoom = true
			ClaimAbility(player, "teleport_to_devil_room")
		else
			LairubPlayerDatas[GetGamePlayerID(player)].startWarningTick = Game():GetFrameCount()
			LairubPlayerDatas[GetGamePlayerID(player)].canTeleportToDevilRoom = false
		end
	else
		LairubPlayerDatas[GetGamePlayerID(player)].tryingTeleportToDevilRoom = false
	end
end

LairubAbilityDatas.teleport_to_devil_room.onEnable = function (player)
	--player.Velocity = Vector(0, 0)
	SetLairubOverlay(player, "TeleportToDevilRoom")
end
LairubAbilityDatas.teleport_to_devil_room.onDisable = function (player)
	ClearLairubOverlay(player, "TeleportToDevilRoom")
end

LairubAbilityDatas.teleport_to_devil_room.endingInterval = function (player)
	if LairubPlayerDatas[GetGamePlayerID(player)].enabledAbilityTime > 360 then
		player:UseCard(Card.CARD_JOKER, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANNOUNCER)
		player:AddCoins(-13)
		LairubPlayerDatas[GetGamePlayerID(player)].tryingTeleportToDevilRoom = false
		ReleaseAbility(player, "teleport_to_devil_room")
		return
	end
	if not IsLairubButtonPressed(player,"teleport_to_devil_room") then
		LairubPlayerDatas[GetGamePlayerID(player)].tryingTeleportToDevilRoom = false
		ReleaseAbility(player, "teleport_to_devil_room")
		return
	end
end

LairubAbilityDatas.teleport_to_devil_room.enabledInterval = function (player)
	player.ControlsCooldown = math.max(1, player.ControlsCooldown)
end


LairubAbilityDatas.dialogue = LairubAbilityData()
LairubAbilityDatas.dialogue.name = "dialogue"
LairubAbilityDatas.dialogue.displayAllowsEnable = function (player) return false end
LairubAbilityDatas.dialogue.startingInterval = function (player)
	if LairubDialogueManager.onGoingDialogue ~= nil then
		ClaimAbility(player, "dialogue")
	end
end
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
	if LairubDialogueManager.onGoingDialogue ~= nil then
		ReleaseAbility(player, "dialogue")
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
		local screenxy = Isaac.WorldToScreen(player.Position)
		local x, y = screenxy.X, screenxy.Y
		local str1 = "Enabled: "..tostring(LairubPlayerDatas[GetGamePlayerID(player)].enabledAbility)
		Explorite.RenderText(str1, x - Explorite.GetTextWidth(str1)/2, y + 6, 255, 255, 255, 255)
	end)
end

function StartingTipRendering()
	if Game():GetFrameCount() < 60 then
		local player = PlayerTypeFirstOneInGame(playerType_Lairub)
		if player == nil then
			return
		end
		local screenxy = Isaac.WorldToScreen(player.Position)
		local x, y = screenxy.X, screenxy.Y
		local str1 = LairubLang:_("starting_tip1", LairubButtonName(player, "hide_ui"))
		local str2 = LairubLang:_("starting_tip2", LairubButtonName(player, "help"))
		Explorite.RenderText(str1, x - Explorite.GetTextWidth(str1)/2, y + 6, 255, 255, 255, 255)
		Explorite.RenderText(str2, x - Explorite.GetTextWidth(str2)/2, y + 16, 255, 255, 255, 255)
	end
end

function TeleportWarning()
	CallForEveryPlayer(function(player)
		if not IsLairub(player) then
			return
		end
		
		local startTick = LairubPlayerDatas[GetGamePlayerID(player)].startWarningTick
		
		if LairubPlayerDatas[GetGamePlayerID(player)].canTeleportToDevilRoom == false and LairubPlayerDatas[GetGamePlayerID(player)].tryingTeleportToDevilRoom == true then
			if LairubPlayerDatas[GetGamePlayerID(player)].renderedWarning == false then
				LairubPlayerDatas[GetGamePlayerID(player)].renderedWarning = true
			end
		end
		if LairubPlayerDatas[GetGamePlayerID(player)].renderedWarning == true then
			local screenxy = Isaac.WorldToScreen(player.Position)
			local x, y = screenxy.X, screenxy.Y
			local str = LairubLang:_("teleport_warning")
			Explorite.RenderText(str, x - Explorite.GetTextWidth(str)/2, y - 72, 1, 0.1, 0.1, (1-0.1*(Game():GetFrameCount()-startTick)))
			if (Game():GetFrameCount() - startTick)/30 >= 2 then
				LairubPlayerDatas[GetGamePlayerID(player)].renderedWarning = false
			end
		end
	end)
end

function DialogueRendering()
	local player = PlayerFindFirst(function(player) return IsLairub(player) and IsAbilityEnabled(player,"dialogue") end)
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
	local screenxy = Isaac.WorldToScreen(player.Position)
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
	local AttackIcon = LairubPlayerDatas[GetGamePlayerID(player)].sprites.AttackIcon
	local CrossIcon = LairubPlayerDatas[GetGamePlayerID(player)].sprites.CrossIcon
	local ReleaseIcon = LairubPlayerDatas[GetGamePlayerID(player)].sprites.ReleaseIcon
	local TeleportSign = LairubPlayerDatas[GetGamePlayerID(player)].sprites.TeleportSign
	--==AttackIcon==--
	--[[if not DisplayCanEnableAbility(player, "swap_form") then
		AttackIcon:SetFrame("Locking", 1)
	else]]if LairubPlayerDatas[GetGamePlayerID(player)].form ~= 2 then
		AttackIcon:SetFrame("Normal", 1)
	else
		AttackIcon:SetFrame("Take Soul", 1)
	end
	--==CrossIcon==--
	if DisplayCanEnableAbility(player, "soul_cross") then
		CrossIcon:SetFrame("Ready", 1)
	else
		CrossIcon:SetFrame("Locking", 1)
	end
	--==ReleaseIcon==--
	if DisplayCanEnableAbility(player, "release_souls") then
		ReleaseIcon:SetFrame("Ready", 1)
	else
		ReleaseIcon:SetFrame("Locking", 1)
	end
	--==Teleport To Devil Room==--
	TeleportSign:SetFrame("TeleportSign", 1)

	AttackIcon:Render(pos + Vector(16*1, 16*0), Vector(0,0), Vector(0,0))
	CrossIcon:Render(pos + Vector(16*0, 16*1), Vector(0,0), Vector(0,0))
	ReleaseIcon:Render(pos +  Vector(16*2, 16*1), Vector(0,0), Vector(0,0))
	TeleportSign:Render(pos + Vector(16*1, 16*2), Vector(0,0), Vector(0,0))
end

function AbilitiesDisplayRendering()
	if PlayerFindFirst(function(player) return IsLairubButtonPressed(player,"hide_ui") end) ~= nil then
		return
	end
	local baseOffset = Vector(44,40)
	local offsetMod = Vector(20 * Options.HUDOffset, 12 * Options.HUDOffset)
	if PlayerTypeExistInGame(PlayerType.PLAYER_ISAAC_B)
	or PlayerTypeExistInGame(PlayerType.PLAYER_BLUEBABY_B)
	then
		offsetMod = offsetMod + Vector(0, 24)
	end
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
	--local soulDisplayPos = baseOffset + offsetMod + Vector(48, 48)
	local soulDisplayPos = baseOffset + offsetMod + Vector(16*1, 16*2)
	SoulSign:Render(soulDisplayPos, Vector(0,0), Vector(0,0))
	Explorite.RenderTextB(tostring(SoulCount), soulDisplayPos.X + 8, soulDisplayPos.Y - 7, 1, 1, 1, 1, 0, false)

end

local function HuntedDownRendering()
	if LairubFlags:HasFlag("DIALOGUE_OVER_HUNTDOWN") and HuntedDownReadout ~= "none" and PlayerFindFirst(function(player) return IsLairubButtonPressed(player,"hide_ui") end) == nil then
		-- safe: white
		-- BOSS: pink
		-- Vigilant: pink
		-- DANGER: red
		local R, G, B, A = 1, 1, 1, 1
		if HuntedDownReadout == "boss" or HuntedDownReadout == "vigilant" then
			R, G, B, A = 1, 0.5, 0.5, 0.8
		end
		if HuntedDownReadout == "danger" then
			R, G, B, A = 1, 0, 0, 0.8
		end

		-- use computed result from game interval function, instead of compute them in render function
		local displayNumber = Parse00(HuntedDownReadoutNumber)
		local displayText = LairubLang:_("hunteddown_readout_"..HuntedDownReadout)

		--Explorite.RenderScaledText(displayNumber, (Isaac.GetScreenWidth() - Explorite.GetTextWidth(displayNumber)*2) / 2, 60, 2, 2, R, G, B, A)
		--Explorite.RenderScaledText(HuntedDownReadout, (Isaac.GetScreenWidth() - Explorite.GetTextWidth(HuntedDownReadout)) / 2, 80, 1, 1, R, G, B, A)
		Explorite.RenderScaledText(displayText.." ", Isaac.GetScreenWidth() / 2 - Explorite.GetTextWidth(displayText), 12 * Options.HUDOffset, 1, 1, R, G, B, A)
		Explorite.RenderScaledText(" "..displayNumber, Isaac.GetScreenWidth() / 2, 12 * Options.HUDOffset, 1, 1, R, G, B, A)
	end
end

function LairubMod.Main:PostRender()
	if not ShouldDisplayHUD()
	or not PlayerTypeExistInGame(playerType_Lairub)
	then
		return
	end
	StartingTipRendering()
	AbilitiesDisplayRendering()
	HuntedDownRendering()
	DialogueRendering()
	HelpScreenRending()
	TeleportWarning()
end
LairubMod:AddCallback(ModCallbacks.MC_POST_RENDER, LairubMod.Main.PostRender)

function LairubMod.Main:LairubSoulCrossUpdate(turretEntity)
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
					Laser.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING | TearFlags.TEAR_SPECTRAL
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
LairubMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, LairubMod.Main.LairubSoulCrossUpdate, LairubSoulCross_Variant)

local function TickEventLairub(player)
	if IsLairub(player) then
		local playerID = GetGamePlayerID(player)
		local level = Game():GetLevel()
		local room = Game():GetRoom()
		if room:GetAliveEnemiesCount() > 0 then
			if LairubPlayerDatas[playerID].noEnemiesBouns then
				LairubPlayerDatas[playerID].noEnemiesBouns = false
				UpdateCache(player, CacheFlag.CACHE_SPEED)
			end
		else
			if not LairubPlayerDatas[playerID].noEnemiesBouns then
				LairubPlayerDatas[playerID].noEnemiesBouns = true
				UpdateCache(player, CacheFlag.CACHE_SPEED)
			end
		end
		UpdateMonitKeys(player)
		if LairubPlayerDatas[playerID].overlaySprite ~= nil then
			LairubPlayerDatas[playerID].overlayFrame = LairubPlayerDatas[playerID].overlayFrame + 1
		end
		MaintainOverlay(player)
		if player:IsDead() or player:IsCoopGhost() then
			if LairubPlayerDatas[playerID].enabledAbility ~= nil then
				ReleaseAbility(player, LairubPlayerDatas[playerID].enabledAbility)
			end
			if LairubPlayerDatas[playerID].form ~= 1 then
				LairubPlayerDatas[GetGamePlayerID(player)].needchangeformcostume = true
				UpdateCache(player)
			end
		end
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
							if LairubPlayerDatas[playerID].form ~= 2 then
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
									tearSprite:ReplaceSpritesheet(0,"gfx/Tears/Lairub_Tears_TakeSoul.png")
									tearSprite:LoadGraphics("gfx/Tears/Lairub_Tears_TakeSoul.png")
								elseif tear.Variant == TearVariant.EYE or tear.Variant == TearVariant.EYE_BLOOD then
									tearSprite:ReplaceSpritesheet(0,"gfx/Tears/Lairub_Tears_Pop_TakeSoul.png")
									tearSprite:LoadGraphics("gfx/Tears/Lairub_Tears_Pop_TakeSoul.png")
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

		--==Abilities and dialogue==--
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

function LairubMod.Main:PostPlayerUpdate(player)
	TickEventLairub(player)
end
LairubMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, LairubMod.Main.PostPlayerUpdate)

local function LairubRendering(player, pos)
	if IsLairub(player) then
		local playerID = GetGamePlayerID(player)
		local sprite = LairubPlayerDatas[playerID].overlaySprite
		local offset = LairubPlayerDatas[playerID].overlayOffset
		local screenxy = Isaac.WorldToScreen(player.Position)
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

function LairubMod.Main:PostPlayerRender(player, pos)
	LairubRendering(player, pos)
end
LairubMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, LairubMod.Main.PostPlayerRender, 0)

function LairubMod.Main:Functions()
	HuntedDownInterval()
end
LairubMod:AddCallback( ModCallbacks.MC_POST_UPDATE, LairubMod.Main.Functions)

function LairubMod.Main:OnDamage(tookDamage, damage, damageFlags, damageSourceRef)
	local player = tookDamage:ToPlayer()
	if player ~= nil then
		ReleaseAbility(player, "teleport_to_devil_room")
	end
end
LairubMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, LairubMod.Main.OnDamage, EntityType.ENTITY_PLAYER)

--==Universal==--

local function SoulCollecting(entity)
	if
		PlayerFindFirst(function (player)
			return IsLairub(player) and LairubPlayerDatas[GetGamePlayerID(player)].form == 2
		end) == nil
	then
		return
	end
	if
		PlayerFindFirst(function (player)
			return IsLairub(player) and IsAbilityEnabled(player,"release_souls")
		end) ~= nil
	then
		return
	end
	SoulCount = SoulCount + 1
	if entity ~= nil and not entity:IsBoss() and Game():GetLevel():GetStage() ~= 13 then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, LairubSoulEffect_Variant, 0, entity.Position, Vector(0,0), nil)
	end
end

function LairubMod.Main:PostNPCDeath(entity)
	if not entity:IsEnemy()
	or entity.Type == EntityType.ENTITY_FROZEN_ENEMY
	or entity.Type == EntityType.ENTITY_SHOPKEEPER
	then
		return
	end
	SoulCollecting(entity)
end
LairubMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, LairubMod.Main.PostNPCDeath)

function LairubMod.Main:PrePickupCollision(pickup, collider, low)
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
				local totalHearts = math.ceil((player:GetHearts() + soulHearts)*0.5)
				local countBone = 0
				for i=0,totalHearts-1,1 do
					if player:IsBoneHeart(i) then
						countBone = countBone + 1
					end
				end
				if soulHearts + countBone * 2 >= player:GetHeartLimit() then
					return pickup:IsShopItem()
				end
				return ExecutePickup(player, pickup, function()
					player:AddBlackHearts(2)
					if pickup.SubType == HeartSubType.HEART_BLENDED then
						SFXManager():Play(SoundEffect.SOUND_UNHOLY, 1, 0, false, 1 )
					end
				end)
			end
		elseif pickup.Variant == PickupVariant.PICKUP_BED and pickup.SubType == BedSubType.BED_ISAAC then
			return false
		end
	end
end
LairubMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, LairubMod.Main.PrePickupCollision)

function LairubMod.Main:PostNewLevel()
	SoulCount = 0
	local level = Game():GetLevel()

	if PlayerTypeExistInGame(playerType_Lairub) then
		level:AddAngelRoomChance(-20000)
	end
	if level:GetStage() == 13 then
		CallForEveryPlayer(function(player)
			if IsLairub(player) then
				player:AddBlackHearts(6)
			end
		end)
	end
end
LairubMod:AddCallback( ModCallbacks.MC_POST_NEW_LEVEL, LairubMod.Main.PostNewLevel)

function LairubMod.Main:PostNewRoom()
	for i=1,4 do
		LairubPlayerDatas[i].crossPlaced = nil
		LairubPlayerDatas[i].crossPlacedOnce = false
	end
	CallForEveryPlayer(
		function(player)
			UpdateCostume(player)
			if IsLairub(player) then
				UpdateCache(player)
				UpdateCostume(player)
			end
		end
	)
end
LairubMod:AddCallback( ModCallbacks.MC_POST_NEW_ROOM, LairubMod.Main.PostNewRoom)

--[[
function LairubMod.Main:PostGameEnd()
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == Isaac.GetPlayerTypeByName("Lairub")
		or player:GetPlayerType() == Isaac.GetPlayerTypeByName("Tainted Lairub", true)
		then
			player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoul)
			player:TryRemoveNullCostume(costume_Lairub_Head_TakeSoulBase)
			player:TryRemoveNullCostume(costume_Lairub_Head)
			player:AddNullCostume(costume_Lairub_Head)
			player:TryRemoveNullCostume(costume_Lairub_Body)
			player:AddNullCostume(costume_Lairub_Body)
		end
	end
end
LairubMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, LairubMod.Main.PostGameEnd)
]]
--???

function LairubMod.Main:ExecuteCmd(cmd, params)
	if cmd == "soulcount" then
		if tonumber(params) ~= nil then
			SoulCount = tonumber(params)
			Isaac.ConsoleOutput("=u=")
		else
			Isaac.ConsoleOutput("qnp")
		end
	end
end
LairubMod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, LairubMod.Main.ExecuteCmd)
