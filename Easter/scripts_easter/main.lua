--====LOCATE====--
local playerType_Easter = Isaac.GetPlayerTypeByName("Easter")
local costume_Easter_Body = Isaac.GetCostumeIdByPath("gfx/characters/EasterBody.anm2")
local costume_Easter_Head = Isaac.GetCostumeIdByPath("gfx/characters/EasterHead.anm2")
local EasterBlandishment = Isaac.GetItemIdByName("Blandishment")

local function IsEaster(player)
	return player ~= nil and player:GetPlayerType() == playerType_Easter
end

local function UpdateCostume(player)
	if IsEaster(player) then
		player:TryRemoveNullCostume(costume_Easter_Body)
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_JUPITER) then
			player:AddNullCostume(costume_Easter_Body)
			player:AddNullCostume(costume_Easter_Head)
		end
	else
		player:TryRemoveNullCostume(costume_Easter_Body)
		player:TryRemoveNullCostume(costume_Easter_Head)
	end
end

-- 初始化人物
local function InitPlayerEaster(player)
	if IsEaster(player) then
		if player:GetActiveItem(ActiveSlot.SLOT_POCKET) ~= EasterBlandishment
		then
			player:SetPocketActiveItem(EasterBlandishment, ActiveSlot.SLOT_POCKET, false)
		end
	end
end

--====FUNCTION====--

-- 在玩家被加载后运行
function EasterMod:PostPlayerInit(player)
	InitPlayerEaster(player)
end
EasterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, EasterMod.PostPlayerInit)

function EasterMod:EvaluateCache(player, cacheFlag)
	if IsEaster(player) then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + 0.4
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage - 1.5
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay * 0.85
		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_SHIELDED
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + 1
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			UpdateCostume(player)
		elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
			local maybeFamiliars = Isaac.GetRoomEntities()
			for m = 1, #maybeFamiliars do
				local variant = maybeFamiliars[m].Variant
				if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
					UpdateCostume(player)
				end
			end
		end
		UpdateCostume(player)
	end
end
EasterMod:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, EasterMod.EvaluateCache)
