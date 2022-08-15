DesperabbitMod = RegisterMod("Desperabbit", 1);

--====CHECK!====--

if not REPENTANCE then
	return
end

if Explorite == nil then
	function DesperabbitMod:checkMissingExploriteStart(loadedFromSaves)
		local numPlayers = Game():GetNumPlayers()
		for i=0,numPlayers-1,1 do
			local player = Isaac.GetPlayer(i)
			if player:GetPlayerType() == Isaac.GetPlayerTypeByName("Desperabbit")
			then
				player:AddControlsCooldown(2147483647)
				if not loadedFromSaves then
					player.Visible = false
					player:AddBrokenHearts(2147483647)
				end
			end
		end
	end
	DesperabbitMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, DesperabbitMod.checkMissingExploriteStart)

	function DesperabbitMod:checkMissingExploriteRend()
		if Explorite == nil then
			Isaac.RenderText("Explorite utility is missing.", (Isaac.GetScreenWidth() - Isaac.GetTextWidth("Explorite utility is missing.")) / 2, Isaac.GetScreenHeight() / 2, 255, 0, 0, 255)
		end
	end
	DesperabbitMod:AddCallback(ModCallbacks.MC_POST_RENDER, DesperabbitMod.checkMissingExploriteRend)
	return
end

DesperabbitFlags = Explorite.NewExploriteFlags()
DesperabbitObjectives = Explorite.NewExploriteObjectives()

require("scripts_Desperabbit/datas")
require("scripts_Desperabbit/main")

DesperabbitMod.Core = {}

local gameInited = false

--==== Store mod Data ====--

local function UpdateLastRoomVar()
	DesperabbitMod.Main.UpdateLastRoomVar()
end

local function RewindLastRoomVar()
	DesperabbitMod.Main.RewindLastRoomVar()
	UpdateLastRoomVar()
end

local function WipeTempVar()
	DesperabbitFlags:Wipe()
	gameInited = false
	DesperabbitMod.Main.WipeTempVar()
	UpdateLastRoomVar()
end

function DesperabbitObjectives:Apply()
--	DesperabbitFlags:Wipe()
--	DesperabbitFlags:LoadFromString(self:Read("Flags", ""))
--	DesperabbitMod.Main.ApplyVar(self)
end

function DesperabbitObjectives:Recieve()
--	self:Write("Flags", DesperabbitFlags:ToString())
--	DesperabbitMod.Main.RecieveVar(self)
end

--==Read==--
function LoadDesperabbitModData()
	local str = ""
	if Isaac.HasModData(DesperabbitMod) then
		str = Isaac.LoadModData(DesperabbitMod)
	end
	DesperabbitObjectives:Wipe()
	DesperabbitObjectives:LoadFromString(str)
	DesperabbitObjectives:Apply()
end
--==Write==--
function SaveDesperabbitModData()
	DesperabbitObjectives:Recieve()
	local str = DesperabbitObjectives:ToString()
	Isaac.SaveModData(DesperabbitMod, str)
end

--==Post game started==--
function DesperabbitMod.Core:PostGameStarted(loadedFromSaves)
	WipeTempVar()
	LoadDesperabbitModData()
	if not loadedFromSaves then -- Only new games
		WipeTempVar()
		SaveDesperabbitModData()
	end
	gameInited = true
end
DesperabbitMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, DesperabbitMod.Core.PostGameStarted)

--==Pre game exit==--
function DesperabbitMod.Core:PreGameExit(shouldSave)
	SaveDesperabbitModData()
	gameInited = false
end
DesperabbitMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, DesperabbitMod.Core.PreGameExit)

function DesperabbitMod.Core:PostNewLevel()
	if gameInited then
		SaveDesperabbitModData()
	end
end
DesperabbitMod:AddCallback( ModCallbacks.MC_POST_NEW_LEVEL, DesperabbitMod.Core.PostNewLevel)

function DesperabbitMod.Core:PostNewRoom()
	if gameInited then
		SaveDesperabbitModData()
	end
end
DesperabbitMod:AddCallback( ModCallbacks.MC_POST_NEW_ROOM, DesperabbitMod.Core.PostNewRoom)

-- 时间回溯
function DesperabbitMod.Core:UseGlowingHourGlass(itemId, itemRng, player, useFlags, activeSlot, customVarData)
	if itemId == CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS
	then
		RewindLastRoomVar()
	end
end
DesperabbitMod:AddCallback(ModCallbacks.MC_USE_ITEM, DesperabbitMod.Core.UseGlowingHourGlass)