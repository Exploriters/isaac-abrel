
function Explorite.RenderResourceBox(icon, str, pos)
	icon:Render(pos, Vector(0,0), Vector(0,0))
	Explorite.RenderTextB(str, pos.X + 13, pos.Y - 2, 1, 1, 1, 1, 0, false)
end

local RegistedSideBars = {}

function Explorite.RegistSideBar(name, func)
	RegistedSideBars[name] = func
end

local function SidebarResourceBoxRendering(_)
	if not Game():GetHUD():IsVisible() then
		return nil
	end

	local offsetModStat = Vector(20 * Options.HUDOffset, 12 * Options.HUDOffset)
	local baseOffset = Vector(3,35)

	local lineNum = 3

	if PlayerTypeExistInGame(PlayerType.PLAYER_BETHANY) then lineNum = lineNum + 1 end
	if PlayerTypeExistInGame(PlayerType.PLAYER_BETHANY_B) then lineNum = lineNum + 1 end
	if PlayerTypeUniqueInGame(PlayerType.PLAYER_BLUEBABY_B) then lineNum = lineNum + 1 end

	local lineRange = 12
	if lineNum > 3 then
		lineRange = 11
	end

	for key, value in pairs(RegistedSideBars) do
		local sprite, str = value()
		if sprite ~= nil and str ~= nil then
			Explorite.RenderResourceBox(sprite, str, baseOffset + offsetModStat + Vector(0, lineRange * lineNum))
			lineNum = lineNum + 1
		end
	end
end
Explorite.ExploriteMod:AddCallback(ModCallbacks.MC_POST_RENDER, SidebarResourceBoxRendering)