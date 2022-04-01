HexanowMod = RegisterMod("Hexanow", 1);

if not REPENTANCE then
	return
end

if Explorite == nil then
	function HexanowMod:checkMissingExploriteStart(loadedFromSaves)
		local numPlayers = Game():GetNumPlayers()
		for i=0,numPlayers-1,1 do
			local player = Isaac.GetPlayer(i)
			if player:GetPlayerType() == Isaac.GetPlayerTypeByName("Hexanow") then
				player:AddControlsCooldown(2147483647)
				if not loadedFromSaves then
					player.Visible = false
					player:AddBrokenHearts(2147483647)
				end
			end
		end
	end
	HexanowMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, HexanowMod.checkMissingExploriteStart)

	function HexanowMod:checkMissingExploriteRend()
		if Explorite == nil then
			Isaac.RenderText("Explorite utility is missing.", (Isaac.GetScreenWidth() - Isaac.GetTextWidth("Explorite utility is missing.")) / 2, Isaac.GetScreenHeight() / 2, 255, 0, 0, 255)
		end
	end
	HexanowMod:AddCallback(ModCallbacks.MC_POST_RENDER, HexanowMod.checkMissingExploriteRend)
	return
end

HexanowFlags = Explorite.NewExploriteFlags()
HexanowObjectives = Explorite.NewExploriteObjectives()

require("scripts_hexanow/room_wall")
require("scripts_hexanow/lang")
require("scripts_hexanow/apioverride")
require("scripts_hexanow/main")
require("scripts_hexanow/soul_stone")

HexanowMod.Core = {}

HexanowMod.gameInited = false

------------------------------------------------------------
---------- 数据存档
----------

local function UpdateLastRoomVar()
	HexanowMod.Main.UpdateLastRoomVar()
	HexanowMod.SoulStone.UpdateLastRoomVar()
end

local function RewindLastRoomVar()
	HexanowMod.Main.RewindLastRoomVar()
	HexanowMod.SoulStone.RewindLastRoomVar()
	UpdateLastRoomVar()
end

-- 抹除临时变量
local function WipeTempVar()
	HexanowFlags:Wipe()
	HexanowMod.gameInited = false
	HexanowMod.Main.WipeTempVar()
	HexanowMod.SoulStone.WipeTempVar()
	UpdateLastRoomVar()
end

function HexanowObjectives:Apply()
	HexanowFlags:Wipe()
	HexanowFlags:LoadFromString(self:Read("Flags", ""))
	HexanowMod.Main.ApplyVar(self)
	HexanowMod.SoulStone.ApplyVar(self)
end

function HexanowObjectives:Recieve()
	self:Write("Flags", HexanowFlags:ToString())
	HexanowMod.Main.RecieveVar(self)
	HexanowMod.SoulStone.RecieveVar(self)
end

-- 读取mod数据
local function LoadHexanowModData()
	local str = ""
	if Isaac.HasModData(HexanowMod) then
		str = Isaac.LoadModData(HexanowMod)
	end
	HexanowObjectives:Wipe()
	HexanowObjectives:LoadFromString(str)
	HexanowObjectives:Apply()
	UpdateLastRoomVar()
end

-- 存储mod数据
local function SaveHexanowModData()
	HexanowObjectives:Recieve()
	local str = HexanowObjectives:ToString(true)
	Isaac.SaveModData(HexanowMod, str)
end

-- 在游戏被初始化后运行
function HexanowMod.Core:PostGameStarted(loadedFromSaves)
	WipeTempVar()
	LoadHexanowModData()
	if not loadedFromSaves then -- 仅限新游戏
		WipeTempVar()
	end
	HexanowMod.Main.PostGameStarted(self, loadedFromSaves)
	SaveHexanowModData()
	HexanowMod.gameInited = true
end
HexanowMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, HexanowMod.Core.PostGameStarted)

-- 在游戏退出前运行
function HexanowMod.Core:PreGameExit(shouldSave)
	if not shouldSave then
		WipeTempVar()
	end
	SaveHexanowModData()
	WipeTempVar()
	HexanowMod.gameInited = false
end
HexanowMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, HexanowMod.Core.PreGameExit)

-- 在玩家进入新楼层后运行
function HexanowMod.Core:PostNewLevel()
	if HexanowMod.gameInited then
		SaveHexanowModData()
	end
end
HexanowMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, HexanowMod.Core.PostNewLevel)

-- 在玩家进入新房间后运行
function HexanowMod.Core:PostNewRoom()
	if HexanowMod.gameInited then
		SaveHexanowModData()
	end
end
HexanowMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, HexanowMod.Core.PostNewRoom)

-- 时间回溯
function HexanowMod.Core:UseGlowingHourGlass(itemId, itemRng, player, useFlags, activeSlot, customVarData)
	RewindLastRoomVar()
end
HexanowMod:AddCallback(ModCallbacks.MC_USE_ITEM, HexanowMod.Core.UseGlowingHourGlass, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)
