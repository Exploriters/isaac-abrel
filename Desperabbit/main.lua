DesperabbitMod = RegisterMod("Desperabbit", 1);
--====CHECK!====--
if Explorite == nil then
	function DesperabbitMod:checkMissingExploriteStart(loadedFromSaves)
		local numPlayers = Game():GetNumPlayers()
		for i=0,numPlayers-1,1 do
			local player = Isaac.GetPlayer(i)
			if player:GetPlayerType() == Isaac.GetPlayerTypeByName("Desperabbit")
			then
				player:AddControlsCooldown(2147483647)
				if not loadedFromSaves then
					player.Visible = false
					player:AddBrokenHearts(2147483647)
				end
			end
		end
	end
	DesperabbitMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, DesperabbitMod.checkMissingExploriteStart)

	function DesperabbitMod:checkMissingExploriteRend()
		if Explorite == nil then
			Isaac.RenderText("Explorite utility is missing.", (Isaac.GetScreenWidth() - Isaac.GetTextWidth("Explorite utility is missing.")) / 2, Isaac.GetScreenHeight() / 2, 255, 0, 0, 255)
		end
	end
	DesperabbitMod:AddCallback(ModCallbacks.MC_POST_RENDER, DesperabbitMod.checkMissingExploriteRend)
	return
end

--====LOCATE====--
local playerType_Desperabbit = Isaac.GetPlayerTypeByName("Desperabbit")
local costume_desperabbit_body = Isaac.GetCostumeIdByPath("gfx/characters/desperabbit_body.anm2")
local costume_desperabbit_ears = Isaac.GetCostumeIdByPath("gfx/characters/desperabbit_ears.anm2")
local costume_desperabbit_head = Isaac.GetCostumeIdByPath("gfx/characters/desperabbit_head.anm2")

local function IsDesperabbit(player)
	return player ~= nil and player:GetPlayerType() == playerType_Desperabbit
end

local function UpdateCostume(player)
	if IsDesperabbit(player) then
		player:TryRemoveNullCostume(costume_desperabbit_body)
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_JUPITER) then
			player:AddNullCostume(costume_desperabbit_body)
			player:AddNullCostume(costume_desperabbit_ears)
			player:AddNullCostume(costume_desperabbit_head)
		end
	else
		player:TryRemoveNullCostume(costume_desperabbit_body)
		player:TryRemoveNullCostume(costume_desperabbit_ears)
		player:TryRemoveNullCostume(costume_desperabbit_head)
	end
end

--====FUNCTION====--
function DesperabbitMod:EvaluateCache(player, cacheFlag)
	if IsDesperabbit(player) then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed * 0.9
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 1.08
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay * 0.9
--		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
--			player.TearFlags = player.TearFlags
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 4
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
DesperabbitMod:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, DesperabbitMod.EvaluateCache)

local function TickEventDesperabbit(player)
	if IsDesperabbit(player) then
		local room = Game():GetRoom()
		if room:GetFrameCount() == 1 then
			UpdateCostume(player)
		end
		
		CallForEveryEntity(function(entity)
			local tear = entity:ToTear()
			if tear ~= nil and tear.Parent ~= nil then
				if tear.Parent.Type == EntityType.ENTITY_PLAYER then
					local player = tear.Parent:ToPlayer()
					if IsDesperabbit(player)
					then
						local data = tear:GetData()
						if not data.tearInitedForDesperabbit then
							data.tearInitedForDesperabbit = true
							local tearSprite = tear:GetSprite()
							if tear.Variant == TearVariant.BLUE then
								tear:ChangeVariant(TearVariant.BLOOD)
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

function DesperabbitMod:PostPlayerUpdate(player)
	TickEventDesperabbit(player)
end
DesperabbitMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, DesperabbitMod.PostPlayerUpdate)