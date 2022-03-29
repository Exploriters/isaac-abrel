HexanowMod = RegisterMod("Hexanow", 1);

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