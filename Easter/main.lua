EasterMod = RegisterMod("Easter", 1);
--====CHECK!====--
if not REPENTANCE then
	return
end

if Explorite == nil then
	function EasterMod:checkMissingExploriteStart(loadedFromSaves)
		local numPlayers = Game():GetNumPlayers()
		for i=0,numPlayers-1,1 do
			local player = Isaac.GetPlayer(i)
			if player:GetPlayerType() == Isaac.GetPlayerTypeByName("Easter")
			then
				player:AddControlsCooldown(2147483647)
				if not loadedFromSaves then
					player.Visible = false
					player:AddBrokenHearts(2147483647)
				end
			end
		end
	end
	EasterMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, EasterMod.checkMissingExploriteStart)

	function EasterMod:checkMissingExploriteRend()
		if Explorite == nil then
			Isaac.RenderText("Explorite utility is missing.", (Isaac.GetScreenWidth() - Isaac.GetTextWidth("Explorite utility is missing.")) / 2, Isaac.GetScreenHeight() / 2, 255, 0, 0, 255)
		end
	end
	EasterMod:AddCallback(ModCallbacks.MC_POST_RENDER, EasterMod.checkMissingExploriteRend)
	return
end

require("scripts_easter/main")
require("scripts_easter/active_items")
