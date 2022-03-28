local lairub = RegisterMod("Lairub", 1);

if Explorite == nil then
	function lairub:checkMissingExploriteStart(loadedFromSaves)
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
	lairub:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, lairub.checkMissingExploriteStart)

	function lairub:checkMissingExploriteRend()
		if Explorite == nil then
			Explorite.RenderText("Explorite utility is missing.", (Isaac.GetScreenWidth() - Explorite.GetTextWidth("Explorite utility is missing.")) / 2, Isaac.GetScreenHeight() / 2, 255, 0, 0, 255)
		end
	end
	lairub:AddCallback(ModCallbacks.MC_POST_RENDER, lairub.checkMissingExploriteRend)
	return
end

LairubFlags = Explorite.NewExploriteFlags()
LairubObjectives = Explorite.NewExploriteObjectives()

require("scripts/lang")
require("scripts/datas")
require("scripts/main")
