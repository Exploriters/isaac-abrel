
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
