
local RegistedPlyaerAnmiOverride = {}

function Explorite.RegistPlyaerAnmiOverride(playerType, anmiPath)
	RegistedPlyaerAnmiOverride[playerType] = anmiPath
end

--[[
Explorite.RegistPlyaerAnmiOverride(playerTypeHexanow, "gfx/characters/HexanowRoot.anm2")
]]

local function ExecuteOverrides(player)
	local path = RegistedPlyaerAnmiOverride[player:GetPlayerType()]
	if type(path) ~= "string" then
		return
	end
	local sprite = player:GetSprite()
	if player:GetSprite():GetFilename() ~= path then
		sprite:Load(path, true)
	end
end
local function ExecuteOverridesCallback(_, player)
	return ExecuteOverrides(player)
end

local function ExecuteOverridesForAll()
	CallForEveryPlayer(ExecuteOverrides)
end

Explorite.ExploriteMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, ExecuteOverridesCallback)
Explorite.ExploriteMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, ExecuteOverridesCallback)
Explorite.ExploriteMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ExecuteOverridesForAll)

-- 使用口袋物品
local function UseCardPill(_, id, player, useFlags)
	ExecuteOverrides(player)
end
Explorite.ExploriteMod:AddCallback(ModCallbacks.MC_USE_CARD, UseCardPill)
Explorite.ExploriteMod:AddCallback(ModCallbacks.MC_USE_PILL, UseCardPill)

-- 使用物品
local function UseItem(_, itemId, itemRng, player, useFlags, activeSlot, customVarData)
	ExecuteOverrides(player)
end
Explorite.ExploriteMod:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem)
