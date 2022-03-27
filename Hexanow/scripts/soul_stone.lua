
local hexanowSoulStoneID = Isaac.GetCardIdByName("Soul of Hexanow")
-- 使用灵魂石的效果
function HexanowMod:UseHexanowSoulStone(cardId, player, useFlags)
	SFXManager():Play(564, 1, 0, false, 1 )
	SFXManager():Play(564, 1, 0, false, 1 )
	SFXManager():Play(564, 1, 0, false, 1 )
	SFXManager():Play(548, 1, 0, false, 1 )
	SFXManager():Play(187, 1, 0, false, 1 )

	--player:AddBrokenHearts(100)
	HexanowFlags:AddFlag("HEXANOW_SOULSTONE_P"..tostring(GetPlayerID(player)).."_ACTIVED")
end
HexanowMod:AddCallback(ModCallbacks.MC_USE_CARD, HexanowMod.UseHexanowSoulStone, hexanowSoulStoneID)
