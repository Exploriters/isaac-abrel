
function IsKeyboardInput(controllerIndex)
	return controllerIndex == 0
end

function Tears2TearDelay(Tears)
	if Tears <= 0.77 then
		return 16 - 6 * Tears
	elseif Tears < 0 then
		return 16 - 6 * math.sqrt( Tears * 1.3 + 1 ) - 6 * Tears
	else
		return 16 - 6 * math.sqrt( Tears * 1.3 + 1 )
	end
end

function TearDelay2Tears(TearDelay)
	if TearDelay <= 10 then
		return ( ( - ( TearDelay - 16 ) / 6 )^2 - 1 )/1.3
	elseif TearDelay < 20.62 then
		return -(10*TearDelay+math.sqrt(3)*math.sqrt(5867-260*TearDelay)-199)/60
	else
		return ( 16 - TearDelay ) / 6
	end
end

function ApplyTears2TearDelay(TearDelay, Tears)
	return Tears2TearDelay(TearDelay2Tears(TearDelay) + Tears)
end

function GetPlayerID(player)
	if player == nil then
		return
	end
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		if GetPtrHash(Isaac.GetPlayer(i)) == GetPtrHash(player) then
			return i + 1
		end
	end
end

function GetParentPlayer(player)
	if player == nil then
		return
	end
	if player.Parent ~= nil then
		return player.Parent
	end
	if  GetPtrHash(player:GetMainTwin()) ~= GetPtrHash(player) then
		return player:GetMainTwin()
	end
end

function GetMainPlayer(player)
	local parent = GetParentPlayer(player)
	if parent ~= nil then
		return parent
	end
	return player
end

function GetGamePlayerID(player)
	if player == nil then
		return
	end
	local parent = GetParentPlayer(player)
	if parent ~= nil then
		player = parent
	end

	local pNumber = 0
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		local p = Isaac.GetPlayer(i)
		if GetParentPlayer(p) == nil
		then
			pNumber = pNumber + 1
			if GetPtrHash(p) == GetPtrHash(player) then
				return pNumber
			end
		end
	end
end

function GetGamePlayerID(player)
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		if Isaac.GetPlayer(i).Index == player.Index then
			return i + 1
		end
	end
	return nil
end

function GetPlayerSameTryeID(player)
	local numPlayers = Game():GetNumPlayers()
	local sameType = 1
	for i=0,numPlayers-1,1 do
		local p = Isaac.GetPlayer(i)
		if GetPtrHash(p) == GetPtrHash(player) then
			return sameType
		end
		if p:GetPlayerType() == player:GetPlayerType() then
			sameType = sameType + 1
		end
	end
	return nil
end

function GetGamePlayerSameTryeID(player)
	local playerID = GetGamePlayerID(player)
	local numPlayers = Game():GetNumPlayers()
	local sameType = 1
	local foundId = {}
	for i=0,numPlayers-1,1 do
		local p = Isaac.GetPlayer(i)
		if GetPtrHash(p) == GetPtrHash(player) then
			return sameType
		end
		if p:GetPlayerType() == player:GetPlayerType()
		then
			local pId = GetGamePlayerID(p)
			if pId ~= playerID
			and not foundId[pId]
			then
				foundId[pId] = true
				sameType = sameType + 1
			end
		end
	end
	return nil
end

function GetDimensionOfRoomDesc(roomDesc)
	local roomDescHash = GetPtrHash(roomDesc)
    for dim=0, 2 do
        if roomDescHash == GetPtrHash(Game():GetLevel():GetRoomByIdx(roomDesc.SafeGridIndex, dim)) then return dim end
    end
end

local lastDim = 0
function GetCurrentDimension()
	local dim = GetDimensionOfRoomDesc(Game():GetLevel():GetCurrentRoomDesc())
	if dim ~= nil then
		lastDim = dim
	end
	return lastDim
end

-- 为每个玩家执行目标函数
function CallForEveryPlayer(func)
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		func(Isaac.GetPlayer(i))
	end
end

-- 为每个实体执行目标函数
function CallForEveryEntity(func)
	local roomEntities = Isaac.GetRoomEntities()
	for i,entity in ipairs(roomEntities) do
		func(entity)
	end
end

-- 查找游戏中第一个符合断言的玩家的玩家
function PlayerFindFirst(predicate)
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		if predicate(Isaac.GetPlayer(i)) then
			return Isaac.GetPlayer(i)
		end
	end
	return nil
end

function GetPlayerByGamePlayerID(ID)
	return PlayerFindFirst(function (player) return GetGamePlayerID(player) == ID end)
end

-- 查找游戏中第一个目标玩家类型的玩家
function PlayerTypeFirstOneInGame(playerType)
	return PlayerFindFirst(function (player) return player:GetPlayerType() == playerType end)
end

-- 检测游戏中是否存在指定的玩家类型
function PlayerTypeExistInGame(playerType)
	return PlayerTypeFirstOneInGame(playerType) ~= nil
end

-- 检测游戏中是否存在指定的玩家类型以外的玩家类型
function PlayerTypeUniqueInGame(playerType)
	local atLeastOne = false
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		if Isaac.GetPlayer(i):GetPlayerType() == playerType then
			atLeastOne = true
		else
			return false
		end
	end
	return atLeastOne
end

-- 检测游戏中是否存在指定的玩家类型以外的玩家类型
function PlayerTypeExistButNotUniqueInGame(playerType)
	return PlayerTypeExistInGame(playerType) and not PlayerTypeUniqueInGame(playerType)
end

function StringConvertToBoolean(str)
    if str == nil then
        return false
	end
	str = string.lower(str)
	if str == 'true' then
		return true
    elseif str == 'false' then
		return false
	else
		return nil
	end
end

function ReverseTable(tab)
	local tmp = {}
	for i = 1, #tab do
		local key = #tab
		tmp[i] = table.remove(tab)
	end

	return tmp
end

function BreakStringByLine(str)
	local strTable = {}
	local lastPoint = 0
	while true do
		local point1,point2 = string.find(str, "[^\n]+", lastPoint + 1)
		if point1 == nil then
			break
		end
		lastPoint = point2
		table.insert(strTable, string.sub(str, point1, point2))
	end
	return strTable
end

function ComputeIntersection(start1, end1, start2, end2) -- start end start end
	local ax, ay, bx, by, cx, cy, dx, dy = start1.X, start1.Y, end1.X, end1.Y, start2.X, start2.Y, end2.X, end2.Y
    local d = (ax-bx)*(cy-dy)-(ay-by)*(cx-dx)
    if d == 0 then return end  -- they are parallel
    local a, b = ax*by-ay*bx, cx*dy-cy*dx
    local x = (a*(cx-dx) - b*(ax-bx))/d
    local y = (a*(cy-dy) - b*(ay-by))/d
    if x <= math.max(ax, bx) and x >= math.min(ax, bx) and
        x <= math.max(cx, dx) and x >= math.min(cx, dx) then
        -- between start and end of both lines
        return Vector(x,y)
    end
end

function Parse00(value)
	local str = tostring(value)
	local num = tonumber(value)
	if num ~= nil and num % 1 == 0 and num <= 9 and num >= 0 then
		str = "0"..str
	end
	return str
end

function GetPlayerShotCount(player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20)
	or player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE)
	or player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
	or player:GetPlayerType() == PlayerType.PLAYER_KEEPER
	or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B
	then
		return 2
		+ math.max(0, player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) - 1)
		+ player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE)
		+ player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) * 2
		+ player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_INNER_EYE)
		+ player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) * 2
		+ (player:GetPlayerType() == PlayerType.PLAYER_KEEPER and {1} or {0})[1]
		+ (player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B and {2} or {0})[1]
	end
	return 1
end

-- 提交缓存更新请求
function UpdateCache(player, flags)
	--player:RemoveCollectible(statTriggerItem)
	--[[
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:AddCacheFlags(CacheFlag.CACHE_SPEED)
	player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
	player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
	player:AddCacheFlags(CacheFlag.CACHE_RANGE)
	player:AddCacheFlags(CacheFlag.CACHE_FLYING)
	]]
	if flags == nil then
		flags = CacheFlag.CACHE_ALL
	end
	player:AddCacheFlags(flags)
	player:EvaluateItems()
end

function ShouldDisplayHUD()
	return Game():GetHUD():IsVisible() and not Game():GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD)
end

function ShouldDisplayFoundHUD()
	return Options.FoundHUD and ShouldDisplayHUD() and not (Game():GetLevel():GetAbsoluteStage() == LevelStage.STAGE8 and Game():GetRoom():GetType() == RoomType.ROOM_DUNGEON)
end

function ExecutePickup(player, pickup, func)
	if pickup:IsShopItem() then
		if player:GetNumCoins() >= pickup.Price and not player:IsHoldingItem() then
			player:AddCoins(-pickup.Price)
			player:AnimatePickup(pickup:GetSprite())
		else
			return true
		end
	end
	if func ~= nil then
		func()
	end
	pickup:PlayPickupSound()
	--print("DESTROYING")
	if pickup:IsShopItem() then
	--	--pickup:Morph(pickup.Type, pickup.Variant, 0, true)
	--	pickup.SubType = 0
		pickup:Remove()
		player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT)
		--[[
		if player:HasCollectible(CollectibleType.COLLECTIBLE_RESTOCK) then
		end
		]]
	else
		pickup:GetSprite():Play("Collect", true)
		--pickup:Remove()
		pickup:Die()
	end
	return true --pickup:IsShopItem()
end

function Room2GridIndex(room)
	if room == nil then return nil end
	if room.GridIndex < 0 then
		return room.GridIndex
	else
		return room.SafeGridIndex
	end
end

function ListIndex2GridIndex(listIndex)
	local room = Game():GetLevel():GetRooms():Get(listIndex)
	if room == nil then return nil end
	return Room2GridIndex(room)
end

function AngleDegreeByTwoDegree(a, b)
	local result = math.abs(a - b)
	if result > 180 then
		return 360 - result
	end
	return result
end

function RoomShapeCellCounts(roomShape)
	if roomShape == RoomShape.ROOMSHAPE_1x1
	or roomShape == RoomShape.ROOMSHAPE_IH
	or roomShape == RoomShape.ROOMSHAPE_IV
	then
		return 1
	elseif roomShape == RoomShape.ROOMSHAPE_1x2
	or roomShape == RoomShape.ROOMSHAPE_IIV
	or roomShape == RoomShape.ROOMSHAPE_2x1
	or roomShape == RoomShape.ROOMSHAPE_IIH
	then
		return 2
	elseif roomShape == RoomShape.ROOMSHAPE_2x2
	then
		return 4
	elseif roomShape == RoomShape.ROOMSHAPE_LTL
	or roomShape == RoomShape.ROOMSHAPE_LTR
	or roomShape == RoomShape.ROOMSHAPE_LBL
	or roomShape == RoomShape.ROOMSHAPE_LBR
	then
		return 3
	else
		return 0
	end
end