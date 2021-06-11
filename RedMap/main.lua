
local RedMapMod = RegisterMod("RedMap", 1);
local RedMapItem = Isaac.GetItemIdByName("Red Map")

local keyGenCount = 0

function RedMapMod.RevealUltraSecretRoom()
	local level = Game():GetLevel()
	local redsecretIndex = level:QueryRoomTypeIndex(RoomType.ROOM_ULTRASECRET, false, RNG(), true)
	local redsecretRoom = level:GetRoomByIdx(redsecretIndex)
	redsecretRoom.DisplayFlags = redsecretRoom.DisplayFlags | 1 << 0 | 1 << 1 | 1 << 2 
	level:UpdateVisibility()
end

-- 在玩家进入新房间后运行
function RedMapMod:PostNewRoom()
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasCollectible(RedMapItem, false) then
			RedMapMod.RevealUltraSecretRoom()
			return nil
		end
	end
end
RedMapMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RedMapMod.PostNewRoom)

-- 在玩家进入新楼层后运行
function RedMapMod:PostNewLevel()
	keyGenCount = 0
	self:SaveHexanowModData()
end
RedMapMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, RedMapMod.PostNewLevel)

-- 读取mod数据
function RedMapMod:LoadHexanowModData()
	local str = "0"
	if Isaac.HasModData(self) then
		str = Isaac.LoadModData(self)
	end
	local num = tonumber(str)
	if num == nil or num < 0 then
		num = 0
	end
	keyGenCount = num
end

-- 存储mod数据
function RedMapMod:SaveHexanowModData()
	local str = tostring(keyGenCount)
	Isaac.SaveModData(self, str)
end

-- 在游戏被初始化后运行
function RedMapMod:PostGameStarted(loadedFromSaves)	
	keyGenCount = 0
	if not loadedFromSaves then
		self:SaveHexanowModData()
	else
		self:LoadHexanowModData()
	end
end
RedMapMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, RedMapMod.PostGameStarted)

-- 在游戏退出前运行
function RedMapMod:PreGameExit(shouldSave)
	if not shouldSave then
		keyGenCount = 0
	end
	self:SaveHexanowModData()
	keyGenCount = 0
end
RedMapMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, RedMapMod.PreGameExit)

function RedMapMod:PostUpdate()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	local redmapCount = 0
	local numPlayers = Game():GetNumPlayers()
	for i=0,numPlayers-1,1 do
		redmapCount = redmapCount + Isaac.GetPlayer(i):GetCollectibleNum(RedMapItem, false)
	end
	local checked = false
	
	while redmapCount - keyGenCount > 0 do
		local pos = room:GetRandomPosition(40)
		local posX = math.floor((pos.X + 20)/40.0)*40
		local posY = math.floor((pos.Y + 20)/40.0)*40
		pos = Vector(posX, posY)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, pos, Vector(0, 0), nil)
		keyGenCount = keyGenCount + 1
		
		if not checked then
			RedMapMod.RevealUltraSecretRoom()
			checked = true
		end
	end
	if checked then
		self:SaveHexanowModData()
	end
	
end
RedMapMod:AddCallback(ModCallbacks.MC_POST_UPDATE, RedMapMod.PostUpdate)