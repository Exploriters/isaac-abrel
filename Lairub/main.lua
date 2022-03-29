LairubMod = RegisterMod("Lairub", 1);

if Explorite == nil then
	function LairubMod:checkMissingExploriteStart(loadedFromSaves)
		local numPlayers = Game():GetNumPlayers()
		for i=0,numPlayers-1,1 do
			local player = Isaac.GetPlayer(i)
			if player:GetPlayerType() == Isaac.GetPlayerTypeByName("Lairub")
			or player:GetPlayerType() == Isaac.GetPlayerTypeByName("Tainted Lairub", true)
			then
				player:AddControlsCooldown(2147483647)
				if not loadedFromSaves then
					player.Visible = false
					player:AddBrokenHearts(2147483647)
				end
			end
		end
	end
	LairubMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, LairubMod.checkMissingExploriteStart)

	function LairubMod:checkMissingExploriteRend()
		if Explorite == nil then
			Isaac.RenderText("Explorite utility is missing.", (Isaac.GetScreenWidth() - Isaac.GetTextWidth("Explorite utility is missing.")) / 2, Isaac.GetScreenHeight() / 2, 255, 0, 0, 255)
		end
	end
	LairubMod:AddCallback(ModCallbacks.MC_POST_RENDER, LairubMod.checkMissingExploriteRend)
	return
end

LairubFlags = Explorite.NewExploriteFlags()
LairubObjectives = Explorite.NewExploriteObjectives()

require("scripts/lang")
require("scripts/datas")
require("scripts/main")
require("scripts/tainted")
require("scripts/soulstone")

LairubMod.Core = {}

local gameInited = false

--==== Store mod Data ====--

local function UpdateLastRoomVar()
	LairubMod.Main.UpdateLastRoomVar()
	LairubMod.Tainted.UpdateLastRoomVar()
	LairubMod.SoulStone.UpdateLastRoomVar()
end

local function RewindLastRoomVar()
	LairubMod.Main.RewindLastRoomVar()
	LairubMod.Tainted.RewindLastRoomVar()
	LairubMod.SoulStone.RewindLastRoomVar()

	UpdateLastRoomVar()
end

local function WipeTempVar()
	LairubMod.Main.WipeTempVar()
	LairubMod.Tainted.WipeTempVar()
	LairubMod.SoulStone.WipeTempVar()

	UpdateLastRoomVar()
end

function LairubObjectives:Apply()
	LairubFlags:Wipe()
	LairubFlags:LoadFromString(self:Read("Flags", ""))
	LairubMod.Main.ApplyVar(self)
	LairubMod.Tainted.ApplyVar(self)
	LairubMod.SoulStone.ApplyVar(self)
end

function LairubObjectives:Recieve()
	self:Write("Flags", LairubFlags:ToString())
	LairubMod.Main.RecieveVar(self)
	LairubMod.Tainted.RecieveVar(self)
	LairubMod.SoulStone.RecieveVar(self)
end

--==Read==--
function LoadLairubModData()
	local str = ""
	if Isaac.HasModData(LairubMod) then
		str = Isaac.LoadModData(LairubMod)
	end
	LairubObjectives:Wipe()
	LairubObjectives:LoadFromString(str)
	LairubObjectives:Apply()
end
--==Write==--
function SaveLairubModData()
	LairubObjectives:Recieve()
	local str = LairubObjectives:ToString()
	Isaac.SaveModData(LairubMod, str)
end
--==Post game started==--
function LairubMod.Core:PostGameStarted(loadedFromSaves)
	WipeTempVar()
	LoadLairubModData()
	if not loadedFromSaves then -- Only new games
		WipeTempVar()
		SaveLairubModData()
	end
	gameInited = true
end
LairubMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, LairubMod.Core.PostGameStarted)

--==Pre game exit==--
function LairubMod.Core:PreGameExit(shouldSave)
	SaveLairubModData()
	gameInited = false
end
LairubMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, LairubMod.Core.PreGameExit)

--==Post game started==--
function LairubMod.Core:PostGameStarted(loadedFromSaves)
	WipeTempVar()
	LoadLairubModData()
	if not loadedFromSaves then -- Only new games
		WipeTempVar()
		SaveLairubModData()
	end
	gameInited = true
end
LairubMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, LairubMod.Core.PostGameStarted)

--==Pre game exit==--
function LairubMod.Core:PreGameExit(shouldSave)
	SaveLairubModData()
	gameInited = false
end
LairubMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, LairubMod.Core.PreGameExit)

function LairubMod.Core:PostNewLevel()
	if gameInited then
		SaveLairubModData()
	end
end
LairubMod:AddCallback( ModCallbacks.MC_POST_NEW_LEVEL, LairubMod.Core.PostNewLevel)

function LairubMod.Core:PostNewRoom()
	if gameInited then
		SaveLairubModData()
	end
end
LairubMod:AddCallback( ModCallbacks.MC_POST_NEW_ROOM, LairubMod.Core.PostNewRoom)

-- 时间回溯
function LairubMod.Core:UseGlowingHourGlass(itemId, itemRng, player, useFlags, activeSlot, customVarData)
	if itemId == CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS
	then
		RewindLastRoomVar()
	end
end
LairubMod:AddCallback(ModCallbacks.MC_USE_ITEM, LairubMod.Core.UseGlowingHourGlass)
