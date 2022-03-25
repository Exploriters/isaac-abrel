
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
		if p.Index == player.Index then
			return sameType
		end
		if p:GetPlayerType() == player:GetPlayerType() then
			sameType = sameType + 1
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

function GetCurrentDimension()
	return GetDimensionOfRoomDesc(Game():GetLevel():GetCurrentRoomDesc())
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

-- 检测游戏中是否存在指定的玩家类型
function PlayerTypeExistInGame(playerType)
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		if Isaac.GetPlayer(i):GetPlayerType() == playerType then
			return true
		end
	end
	return false
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