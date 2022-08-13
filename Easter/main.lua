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

--====LOCATE====--
local playerType_Easter = Isaac.GetPlayerTypeByName("Easter")
local costume_Easter_Body = Isaac.GetCostumeIdByPath("gfx/characters/EasterBody.anm2")
local costume_Easter_Head = Isaac.GetCostumeIdByPath("gfx/characters/EasterHead.anm2")

EasterMod.gameInited = false

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

--====FUNCTION====--
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

local function InitPlayerEaster(player)
	if IsEaster(player) then
		UpdateCostume(player)
		if not loadedFromSaves then
			--====BASE HEARTS====--
			player:AddBlackHearts(2)
			player:AddSoulHearts(2)
			player:AddMaxHearts(-2, true)
		end
	end
end

function EasterMod:PostGameStarted(loadedFromSaves)
	EasterMod.gameInited = true
	if not loadedFromSaves then
		CallForEveryPlayer(InitPlayerEaster)
	end
end
EasterMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, EasterMod.PostGameStarted)

function EasterMod:PreGameExit(shouldSave)
	EasterMod.gameInited = false
end
EasterMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, EasterMod.PreGameExit)

function EasterMod:PostPlayerInit(player)
	if EasterMod.gameInited then
		InitPlayerEaster(player)
	end
end
EasterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, EasterMod.PostPlayerInit)

local function TickEventEaster(player)
	if IsEaster(player) then
		local room = Game():GetRoom()
		if room:GetFrameCount() == 1 then
			UpdateCostume(player)
		end
		
		CallForEveryEntity(function(entity)
			local tear = entity:ToTear()
			if tear ~= nil and tear.Parent ~= nil then
				if tear.Parent.Type == EntityType.ENTITY_PLAYER then
					local player = tear.Parent:ToPlayer()
					if IsEaster(player)
					then
						local data = tear:GetData()
						if not data.tearInitedForEaster then
							data.tearInitedForEaster = true
							local tearSprite = tear:GetSprite()
							if tear.Variant == TearVariant.BLUE or tear.Variant == TearVariant.BLOOD then
								tearSprite:ReplaceSpritesheet(0,"gfx/tears/easter_tears.png")
								tearSprite:LoadGraphics("gfx/tears/easter_tears.png")
							end
							tearSprite:LoadGraphics()
							tearSprite.Rotation = tear.Velocity:GetAngleDegrees()
						end
					end
				end
			end
		end)
	end
end

function EasterMod:PostPlayerUpdate(player)
	TickEventEaster(player)
end
EasterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, EasterMod.PostPlayerUpdate)

require("scripts_easter/main")
require("scripts_easter/active_items")
