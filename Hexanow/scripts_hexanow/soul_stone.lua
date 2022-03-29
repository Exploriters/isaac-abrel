
HexanowMod.SoulStone = {}

local hexanowSoulStoneID = Isaac.GetCardIdByName("Soul of Hexanow")

local LastRoom = {}

function HexanowMod.SoulStone.UpdateLastRoomVar()
	LastRoom = {}
end

function HexanowMod.SoulStone.RewindLastRoomVar()
end

-- 抹除临时变量
function HexanowMod.SoulStone.WipeTempVar()
end

function HexanowMod.SoulStone.ApplyVar(objective)
end

function HexanowMod.SoulStone.RecieveVar(objective)
end

-- 使用灵魂石的效果
function HexanowMod.SoulStone:UseHexanowSoulStone(cardId, player, useFlags)
	SFXManager():Play(564, 1, 0, false, 1 )
	SFXManager():Play(564, 1, 0, false, 1 )
	SFXManager():Play(564, 1, 0, false, 1 )
	SFXManager():Play(548, 1, 0, false, 1 )
	SFXManager():Play(187, 1, 0, false, 1 )

	--player:AddBrokenHearts(100)
	HexanowFlags:AddFlag("HEXANOW_SOULSTONE_P"..tostring(GetPlayerID(player)).."_ACTIVED")
end
HexanowMod:AddCallback(ModCallbacks.MC_USE_CARD, HexanowMod.SoulStone.UseHexanowSoulStone, hexanowSoulStoneID)
