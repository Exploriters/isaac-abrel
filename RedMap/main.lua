
local RedMapMod = RegisterMod("RedMap", 1);
local RedMapItem = Isaac.GetItemIdByName("Red Map")

local checked = false

function RedMapMod:RevealUltraSecretRoom()
	local level = Game():GetLevel()
	local redsecretIndex = level:QueryRoomTypeIndex(RoomType.ROOM_ULTRASECRET, false, RNG(), true)
	local redsecretRoom = level:GetRoomByIdx(redsecretIndex)
	redsecretRoom.DisplayFlags = redsecretRoom.DisplayFlags | 1 << 0 | 1 << 1 | 1 << 2 
	level:UpdateVisibility()
end

function RedMapMod:CheckToDO()
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasCollectible(RedMapItem, false) then
			RedMapMod:RevealUltraSecretRoom()
			checked = true
			return nil
		end
	end
end

-- 在玩家进入新房间后运行
function RedMapMod:PostNewRoom()
	checked = false
	RedMapMod:CheckToDO()
end
RedMapMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RedMapMod.PostNewRoom)

function RedMapMod:PostUpdate()
	if not checked then
		RedMapMod:CheckToDO()
	end
end

RedMapMod:AddCallback(ModCallbacks.MC_POST_UPDATE, RedMapMod.PostUpdate)