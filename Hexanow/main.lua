Isaac.ConsoleOutput("Init mod hexanow")

local hexanowMod = RegisterMod("Hexanow", 1);

local playerTypeHexanow = Isaac.GetPlayerTypeByName("Hexanow")
--local hexanowItem = Isaac.GetItemIdByName( "Hexanow's Soul" )
local hexanowFlightTriggerItem = Isaac.GetItemIdByName( "Hexanow flight trigger" )
local hexanowHairCostume = Isaac.GetCostumeIdByPath("gfx/characters/HexanowHair.anm2")
local hexanowFateCostume = Isaac.GetCostumeIdByPath("gfx/characters/Hexanow_fate.anm2")

local entityVariantHeartsBlender = Isaac.GetEntityVariantByName("Hearts Blender")
local entityTypeHexanowPortal = Isaac.GetEntityTypeByName("Hexanow Blue Portal")

local MC_ENTITY_TAKE_DMG_Room = 0
local MC_ENTITY_TAKE_DMG_Forever = 0

local hexanowObjectives = {
["damageIncrease"] = 0.0
}

require("apioverride")
--[[ MALFUNCTIONING
local baseEntityPlayerHasCollectible = APIOverride.GetCurrentClassFunction(EntityPlayer, "HasCollectible")
APIOverride.OverrideClassFunction(EntityPlayer, "HasCollectible", function(interval, Type, IgnoreModifiers)	
    local result = baseEntityPlayerHasCollectible(interval, Type, IgnoreModifiers)
	if interval:GetPlayerType() == playerTypeHexanow
	and (  Type == CollectibleType.COLLECTIBLE_ANALOG_STICK
		or Type == CollectibleType.COLLECTIBLE_URANUS
		or Type == CollectibleType.COLLECTIBLE_NEPTUNUS
	) then
		result = true
	end
	return result
end)
]]

--[[
APIOverride.OverrideClassFunction(EntityPlayer, "GetMaxHearts", function()
    return 123456789
end)

APIOverride.OverrideClassFunction(EntityPlayer, "GetPlayerType", function()
    return PlayerType.PLAYER_AZAZEL 
end)
]]


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

		--return ( 770 - 77*TearDelay )/1062 临时方案
		--return ((-10*TearDelay)+math.sqrt(3)*math.sqrt(5867-260*TearDelay)+199)/60

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

--[[
function table.tostringex (t)
	local tableT = {"{"}

	function toStringF (k, v)
		if "number" == type(k) then
		elseif "string" == type(k) then
			table.insert(tableT, string.format("%s=", k))
		elseif "table" == type(k) then
			table.insert(tableT, string.format("table:%s=", k))
		elseif "function" == type(k) then
			table.insert(tableT, tostring(k))
		end

		if "table" == type(v) then
			table.insert(tableT, table.tostringex(v))
		elseif "number" == type(v) or "boolean" == type(v) then
			table.insert(tableT, tostring(v))
		else 
			table.insert(tableT, string.format("\"%s\"", tostring(v)))
		end

		table.insert(tableT, ",")
	end

	table.foreach(t, toStringF)
	table.remove(tableT, table.getn(tableT)) -- 删除逗号
	table.insert(tableT, "}")
	local tableStr = table.concat(tableT)
	return tableStr
end
function table.tostring (t, tabCountedP)
	local tableT = {"{\n"}
	if (nil == tabCountedP) then
		tabCounted = "    "
	else 
		tableT = {"\n", tabCounted, "{\n"}
	end

	function toStringF (k, v)
		table.insert(tableT, tabCounted)
		if "number" == type(k) then
			table.insert(tableT, string.format("[%s] = ", k))
		elseif "string" == type(k) then
			table.insert(tableT, string.format("\"%s\" = ", k))
		elseif "table" == type(k) then
			table.insert(tableT, string.format("table: %s = ", tostring(k)))
		end

		if "table" == type(v) then
			tabCounted = string.format("%s%s", tabCounted, "    ")
			returnStr = table.tostring(v, tabCounted)
			table.insert(tableT, returnStr)
			table.insert(tableT, ",") --分步添加，方便后面删除逗号
			table.insert(tableT, "\n")
		else
			table.insert(tableT, tostring(v))
			table.insert(tableT, ",")
			table.insert(tableT, "\n")
		end
	end

	--table.foreach(t, toStringF)
	for i,td in ipairs(t) do
		toStringF(i,td)
	end
	--table.remove(tableT, table.getn(tableT) -1) -- 删除逗号
	local manCount = 0
	for k,v in pairs(t) do
		manCount = manCount + 1
	end
	
	if manCount > 0 then
		table.remove(tableT, manCount -1) -- 删除逗号
	end
	tabCounted = string.sub(tabCounted, 1, -5) -- 缩进-1
	table.insert(tableT, string.format("%s}", tabCounted))
	local tableStr = table.concat(tableT)
	return tableStr, tabCounted
end
function stringToTable (stringP)
	local loadFunction = load("return " .. stringP)
	local loadTable = loadFunction()
	return loadTable
end

-- 读取mod数据
function LoadHexanowModData()
	local str = Isaac.LoadModData(hexanowMod)
	print("Load Readout: ", str)
	if str ~= nil and str ~= "" then
		hexanowObjectives = stringToTable()
	end
end

-- 存储mod数据
function SaveHexanowModData()
	local str = table.tostring(hexanowObjectives)
	print("Save Readout: ", str)
	Isaac.SaveModData(hexanowMod, str)
end
]]

-- 读取mod数据
function LoadHexanowModData()
	--[[
	local str = Isaac.LoadModData(hexanowMod)
	print("Load Readout: ", str)
	]]
end

-- 存储mod数据
function SaveHexanowModData()
	--[[
	local str = "somethingWrong"
	-- print("Save Readout: ", str)
	Isaac.SaveModData(hexanowMod, str)
	
	-- 复原临时变量
	onceHoldingItem = false
	lastCanFly = nil
	]]
end

-- 测试
function TestDoDmg(player)
	--[[
	if hexanowObjectives["damageIncrease"] == nil then
		hexanowObjectives["damageIncrease"] = 0.0
	end
	hexanowObjectives["damageIncrease"] = hexanowObjectives["damageIncrease"] +0.01
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	]]
end

-- 更新玩家外观，按需执行
function UpdateCostumes(player)
	if player:GetPlayerType() == playerTypeHexanow then
		player:ClearCostumes()
		player:RemoveSkinCostume()
		player:TryRemoveNullCostume(hexanowHairCostume)
		player:AddNullCostume(hexanowHairCostume)
		
		player:TryRemoveNullCostume(hexanowFateCostume)
		if player.CanFly then
			player:AddNullCostume(hexanowFateCostume)
		end
	else
		player:TryRemoveNullCostume(hexanowHairCostume)
		player:TryRemoveNullCostume(hexanowFateCostume)
	end
end

-- 提交缓存更新请求
function UpdateCache(player)
	--[[
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:AddCacheFlags(CacheFlag.CACHE_SPEED)
	player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
	player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
	player:AddCacheFlags(CacheFlag.CACHE_RANGE)
	player:AddCacheFlags(CacheFlag.CACHE_FLYING)
	]]
end

-- 给予永恒之心
function ApplyEternalHearts(player)
	if player:GetEternalHearts() <= 0 then
		player:AddEternalHearts(1)
	end
end

-- 确保随从数量
function EnsureFamiliars(player)
	local roomEntities = Isaac.GetRoomEntities()
	local HBcount = 0
	local HBcountTarget = 0
	for i, entity in pairs(roomEntities) do
		if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == entityVariantHeartsBlender then
			HBcount = HBcount + 1
			if HBcount > HBcountTarget then
				entity:Remove()
			end
		end
	end
	-- if HBcount < HBcountTarget then
		for i=HBcount, HBcountTarget - 1, 1 do
			local e = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, entityVariantHeartsBlender, 0, player.Position, Vector(0, 0), player)
		end
	-- end
end

-- 将魂心处理为黑心，放置于骨心后
function RearrangeHearts(player)

	local soulHearts = player:GetSoulHearts()
	local blackHearts = player:GetBlackHearts()
	
	local totalHearts = math.ceil((player:GetHearts() + soulHearts)*0.5)
	
	local boneMisArrangeState = 0
	for i=0,totalHearts-1,1 do
		if boneMisArrangeState == 0 and not player:IsBoneHeart(i) then
			boneMisArrangeState = 1
		elseif boneMisArrangeState == 1 and player:IsBoneHeart(i) then
			boneMisArrangeState = 2
		end
	end
	
	if boneMisArrangeState == 2
	or blackHearts ~= 2^(math.ceil(soulHearts * 0.5)) - 1
	then
		player:AddSoulHearts(-soulHearts)
		player:AddBlackHearts(soulHearts) --math.ceil(soulHearts * 0.5)*2)
	end
	
	
	local num1,num2=math.modf(soulHearts*0.5)
    if num2 ~= 0 then
		player:AddBlackHearts(1)
		--[[
		player:TakeDamage(
			1,
			DamageFlag.DAMAGE_NOKILL | DamageFlag.DAMAGE_INVINCIBLE ,
			EntityRef(nil),
			0
			)
		]]
    end
	
	
end

-- 初始化人物
function InitPlayerHexanow(player)
	if player:GetPlayerType() == playerTypeHexanow then
		local itemPool = Game():GetItemPool()
		
		-- player:AddMaxHearts(6)
		-- player:AddGoldenHearts(0)
		ApplyEternalHearts(player)
		
		TickEventHexanow(player)
		
		player:AddHearts(-1)
		player:AddCard(Card.CARD_JUSTICE)
		player:AddTrinket(TrinketType.TRINKET_NO | 32768)
		-- player:AddCard(Card.CARD_SUN)
		-- player:AddTrinket(TrinketType.TRINKET_BIBLE_TRACT)
		
		-- print("PostGameStarted for", player:GetName())
		
		itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK)
		itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_URANUS)
		itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS)
		--itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_SOL)
		itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR)
		--itemPool:RemoveTrinket(TrinketType.TRINKET_NO)
		--[[
		for i=0,14,1 do
			itemPool:IdentifyPill(i)
		end
		]]
	end
end

-- local lastMaxHearts = nil
-- local updatedCostumesOvertime = false
local onceHoldingItem = false
local lastCanFly = nil
local roomClearBounsEnabled = false
-- 永久性确保项目，每一帧执行
function TickEventHexanow(player)
	if player:GetPlayerType() == playerTypeHexanow then
		local game = Game()
		local level = game:GetLevel()
		local room = game:GetRoom()
		local roomEntities = Isaac.GetRoomEntities()
		
		if game == nil
		or level == nil
		or room == nil
		or roomEntities == nil
		then
			return nil
		end
		
		--[[
		if not player:IsFlying() and Game():GetRoom():IsClear() and not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
			
			-- player:UseActiveItem(CollectibleType.COLLECTIBLE_BIBLE,false,true,true,false)
			-- player:UseCard(Card.CARD_HANGED_MAN)
			--if not player:HasCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE) then
			--	player:AddCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE, 0, false)
			--	player:AddCacheFlags(CacheFlag.CACHE_FLYING)
			--	player:RemoveCollectible(CollectibleType.COLLECTIBLE_TRANSCENDENCE)
			--end
			
			--player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_TRANSCENDENCE, false, 1)
			--player:AddCacheFlags(CacheFlag.CACHE_FLYING)
			
			-- player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_TRANSCENDENCE)
		end
		]]
		if Game():GetRoom():IsClear() and not roomClearBounsEnabled then
			roomClearBounsEnabled = true
			player:RemoveCollectible(hexanowFlightTriggerItem)
		end
		
		if roomClearBounsEnabled and not player:IsFlying() then
			player:RemoveCollectible(hexanowFlightTriggerItem)
		end
		
		--[[
		-- player:UseActiveItem(CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR,false,true,true,false)

		-- player:AddCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG, 0, false)
		-- player:AddCollectible(CollectibleType.COLLECTIBLE_MOMS_PURSE, 0, false)
		-- player:AddCollectible(CollectibleType.COLLECTIBLE_POLYDACTYLY, 0, false)
		-- player:AddCollectible(CollectibleType.COLLECTIBLE_PRAYER_CARD, 0, false)
		]]
		
		--[[
		if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
			player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_ANALOG_STICK, false)
		end
		]]
		--if room:GetBackdropType() ~= 59 and room:GetBackdropType() ~= 58 then
			if not player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK, true) then
				player:AddCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK, 0, false)
				UpdateCostumes(player)
			end
			if not player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS, true) then
				player:AddCollectible(CollectibleType.COLLECTIBLE_URANUS, 0, false)
				UpdateCostumes(player)
			end
			if not player:HasCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS, true) then
				player:AddCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS, 0, false)
				UpdateCostumes(player)
			end
			--if not player:HasCollectible(CollectibleType.COLLECTIBLE_SOL, true) then
			--	player:AddCollectible(CollectibleType.COLLECTIBLE_SOL, 0, false)
			--	UpdateCostumes(player)
			--end
		--end
		
		
		local VREntityNotTraced = true
		local roomEntities = Isaac.GetRoomEntities()
				
		if player:HasCollectible(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR, true) then
			VREntityNotTraced = false
		end
		
		for i,entity in ipairs(roomEntities) do
			local pickup = entity:ToPickup()
			if pickup ~= nil then
				if pickup.Type == EntityType.ENTITY_PICKUP 
				and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE 
				and pickup.SubType == CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR
				then
					if not VREntityNotTraced then
						entity:Remove()
					end
					VREntityNotTraced = false
				end
			end
		end
		
		if VREntityNotTraced
		and player:GetActiveItem() == CollectibleType.COLLECTIBLE_NULL
		-- and not player:HasTrinket(TrinketType.TRINKET_BUTTER)
		then
			player:AddCollectible(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR, 0, false)
		end
		
			--[[
			if lastMaxHearts ~= player:GetMaxHearts() then
				print("Max hearts mismatching detected ( from ", lastMaxHearts, " to ", player:GetMaxHearts(), "), cache update queued.")
				UpdateCache(player)
				lastMaxHearts = player:GetMaxHearts()
			end
			]]
			
			-- TestDoDmg(player)
			
		if player:IsDead() then
			--player:Revive()
		end
		
		if room:GetFrameCount() == 1 then
			ApplyEternalHearts(player)
			UpdateCostumes(player)
		else
			
			if room:GetAliveEnemiesCount() <= 0 then
				ApplyEternalHearts(player)
			end
			
			--[[ --Malfunction
			if  ( player.Velocity.X < 0.05 and player.Velocity.X > -0.05)
			and ( player.Velocity.Y < 0.05 and player.Velocity.Y > -0.05)
			and ( player:GetRecentMovementVector().X < 0.05 and player:GetRecentMovementVector().X > -0.05)
			and ( player:GetRecentMovementVector().Y < 0.05 and player:GetRecentMovementVector().Y > -0.05)
			then
				if player.FireDelay < 0 and not updatedCostumesOvertime then
					UpdateCostumes(player)
					updatedCostumesOvertime = true
				end
			else
				updatedCostumesOvertime = false
			end
			]]
			
			if player:IsHoldingItem()
			then
				onceHoldingItem = true
			elseif onceHoldingItem then
				UpdateCostumes(player)
				onceHoldingItem = false
			end
			
			if lastCanFly ~= player.CanFly then
				UpdateCostumes(player)
				lastCanFly = player.CanFly
			end
			
		end
		
		--[[
		for i,entity in ipairs(roomEntities) do
			local tear = entity:ToTear()
		end
		]]
		
		RearrangeHearts(player)
		
		-- EnsureFamiliars(player)
		
	end
end

-- 自定义命令行
function hexanowMod:ExecuteCmd(cmd, params)
	if cmd == "hexanow" then
		local pnum = tonumber(params)
		if pnum == nil then
			Isaac.ConsoleOutput("Invalid args")
		else
			-- TODO EFFECTS
		end
	end
	if cmd == "t2td" then
		local pnum = tonumber(params)
		if pnum == nil then
			Isaac.ConsoleOutput("Invalid args")
		else
			Isaac.ConsoleOutput(Tears2TearDelay(pnum))
		end
	end
	if cmd == "td2t" then
		local pnum = tonumber(params)
		if pnum == nil then
			Isaac.ConsoleOutput("Invalid args")
		else
			Isaac.ConsoleOutput(TearDelay2Tears(pnum))
		end
	end
	if cmd == "reportpos" then
		local roomEntities = Isaac.GetRoomEntities()
				
		for i,entity in ipairs(roomEntities) do
			if entity.Type == EntityType.ENTITY_PICKUP then
				print("Pickup : ", entity.Position.X, ", ", entity.Position.Y)
			elseif entity.Type == EntityType.ENTITY_TEAR then
				print("Tear : ", entity.Position.X, ", ", entity.Position.Y)
			end
		end
	end
	if cmd == "reportpickup" then
		local roomEntities = Isaac.GetRoomEntities()
				
		for i,entity in ipairs(roomEntities) do
			if entity.Type == EntityType.ENTITY_PICKUP then
				local pickup = entity:ToPickup()
				print(entity.Type,".",entity.Variant,".",entity.SubType,"(", pickup.State, ")")
			end
		end
	end
	if cmd == "reportentity" then
		local roomEntities = Isaac.GetRoomEntities()
				
		for i,entity in ipairs(roomEntities) do
			print(entity.Type,".",entity.Variant,".",entity.SubType,"(", entity.Position.X, ",", entity.Position.Y, ")")
		end
	end
	if cmd == "reportentityne" then
		local roomEntities = Isaac.GetRoomEntities()
				
		for i,entity in ipairs(roomEntities) do
			if entity.Type ~= 1000 then
				print(entity.Type,".",entity.Variant,".",entity.SubType,"(", entity.Position.X, ",", entity.Position.Y, ")")
			end
		end
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, hexanowMod.ExecuteCmd);

-- 在游戏被初始化后运行
function hexanowMod:PostGameStarted(loadedFromSaves)	
	
	if not loadedFromSaves then -- 仅限新游戏
		CallForEveryPlayer(InitPlayerHexanow)
	else -- 仅限从存档中读取
		LoadHexanowModData()
	end
	
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, hexanowMod.PostGameStarted)

-- 在游戏退出前运行
function hexanowMod:PreGameExit(shouldSave)
	SaveHexanowModData()
	roomClearBounsEnabled = false
	portalBlue = nil
	portalOrange = nil
	teledProjectiles = {}
end
hexanowMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, hexanowMod.PreGameExit)

-- 在玩家被加载后运行
function hexanowMod:PostPlayerInit(player)
	UpdateCostumes(player)
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, hexanowMod.PostPlayerInit)

-- 在玩家进入新楼层后运行
function hexanowMod:PostNewLevel()
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerTypeHexanow then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR, false, true, true, false)
			end
		end
	)
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, hexanowMod.PostNewLevel)

-- 在玩家进入新房间后运行
function hexanowMod:PostNewRoom()
	CallForEveryPlayer(
		function(player)
			UpdateCostumes(player)
			if player:GetPlayerType() == playerTypeHexanow then
				ApplyEternalHearts(player)
				if not Game():GetRoom():IsClear() then
					roomClearBounsEnabled = false
					player:RemoveCollectible(hexanowFlightTriggerItem)
				end
			end
		end
	)
	
	if PlayerTypeExistInGame(playerTypeHexanow) then
		CallForEveryEntity(
			function(entity)
				if entity.Type == EntityType.ENTITY_EFFECT
				and entity.Variant == EffectVariant.WOMB_TELEPORT
				then
					local portalFound = false
					
					CallForEveryEntity(
						function(entity2)
							if entity2.Type == entityTypeHexanowPortal
							and entity2.Position:Distance(entity.Position) <= 20
							then
								portalFound = true
								return nil
							end
						end
					)
					
					if not portalFound then
						local portalEntity = Isaac.Spawn(entityTypeHexanowPortal, entity.SubType, 0, entity.Position, Vector(0,0), entity)
					end
					
					entity.Visible = false
				end
			end
		)
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, hexanowMod.PostNewRoom)

-- 在房间被清理后运行
function hexanowMod:PreSpawnCleanAward(Rng, SpawnPos)
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerTypeHexanow then
				ApplyEternalHearts(player)
			end
		end
	)
end
hexanowMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, hexanowMod.PreSpawnCleanAward)

-- 在玩家得到物品后运行
function hexanowMod:PostGetCollectible(SelectedCollectible, PoolType, Decrease, Seed)
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerTypeHexanow then
				UpdateCostumes(player)
			end
		end
	)
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, hexanowMod.PostGetCollectible)

-- 在玩家得到饰品后运行
function hexanowMod:GetTrinket(SelectedTrinket, TrinketRNG)
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerTypeHexanow then
				UpdateCostumes(player)
			end
		end
	)
end
hexanowMod:AddCallback(ModCallbacks.MC_GET_TRINKET, hexanowMod.GetTrinket)

-- 在玩家受伤时运行
function hexanowMod:EntityTakeDmg(TookDamage, DamageAmount, DamageFlag, DamageSource, DamageCountdownFrames)
	if TookDamage.Type == EntityType.ENTITY_PLAYER then
		local player = TookDamage:ToPlayer()
		local room = Game():GetRoom()
		if player:GetPlayerType() == playerTypeHexanow then
			RearrangeHearts(player)
			local num1,num2=math.modf( math.max(player:GetSoulHearts() - DamageAmount, 0)*0.5 )
			if num2 ~= 0 then
				player:AddBlackHearts(-1)
			end
			--[[
			if room:GetAliveEnemiesCount() <= 0 and room:IsClear() then
				ApplyEternalHearts(player)
			end
			]]
		end
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG , hexanowMod.EntityTakeDmg)

-- 在生物被移除时运行
function hexanowMod:PostEntityRemove(entity)
	if entity.Type == 963 then
		CallForEveryPlayer(
			function(player)
				ApplyEternalHearts(player)
				--[[
				if player:GetEternalHearts() <= 0 then
					player:AddEternalHearts(1)
				elseif player:GetMaxHearts() > player:GetHearts() then
					player:AddHearts(1)
				end
				]]
			end
		)
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE , hexanowMod.PostEntityRemove)

-- 干涉掉落物生成
function hexanowMod:PostPickupSelection(Pickup, Variant, SubType)
	if PlayerTypeExistInGame(playerTypeHexanow) then
		--[[
		if Variant == PickupVariant.PICKUP_HEART and 
		(
			SubType == HeartSubType.HEART_FULL or
			SubType == HeartSubType.HEART_HALF or
			SubType == HeartSubType.HEART_SOUL or
			SubType == HeartSubType.HEART_HALF_SOUL or
			SubType == HeartSubType.HEART_SCARED or
			SubType == HeartSubType.HEART_BLACK
		)
		then
			return {Variant, HeartSubType.HEART_BLENDED}
		end
		]]
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION , hexanowMod.PostPickupSelection)

-- 改变眼泪碰撞行为
function hexanowMod:PreTearCollision(tear, collider, low)
	if tear.Parent ~= nil then
		local player = tear.Parent:ToPlayer()
		if player ~= nil
		and player:GetPlayerType() == playerTypeHexanow
		and collider.Type == 963
		then
			return true
		end
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION , hexanowMod.PreTearCollision)

-- 改变掉落物拾取行为
function hexanowMod:PrePickupCollision(pickup, collider, low)
	local player = collider:ToPlayer()
	if player ~= nil
	and player:GetPlayerType() == playerTypeHexanow
	then
		if pickup.Variant == PickupVariant.PICKUP_HEART then
			if pickup.SubType == HeartSubType.HEART_ETERNAL
			and player:GetMaxHearts() >= 24 
			and player:GetHearts() < player:GetMaxHearts()
			and player:GetEternalHearts() >= 1 then
				-- SFXManager():Play(SoundEffect.SOUND_SUPERHOLY, 1, 0, false, 1 )
				-- pickup:GetSprite():Play("Collect", true)
				--player:AddEternalHearts(1)
				--pickup:PlayPickupSound()
				--print("DESTROYING")
				--pickup:Destroy()
				if player:GetMaxHearts() - player:GetHearts() == 1 then
					-- player:AddEternalHearts(1)
				end
				player:AddMaxHearts(-1)
				return nil
			else
			--[[
				pickup.SubType == HeartSubType.HEART_FULL or
				pickup.SubType == HeartSubType.HEART_HALF or
				pickup.SubType == HeartSubType.HEART_SOUL or
				pickup.SubType == HeartSubType.HEART_HALF_SOUL or
				pickup.SubType == HeartSubType.HEART_SCARED or
				pickup.SubType == HeartSubType.HEART_BLACK or
				
				(pickup.SubType == HeartSubType.HEART_BONE and player:GetMaxHearts() >= 24) or
				pickup.SubType == HeartSubType.HEART_DOUBLEPACK
			]]
			end
		end
		return nil
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION , hexanowMod.PrePickupCollision)

-- 后期处理属性缓存
function hexanowMod:EvaluateCache(player, cacheFlag, tear)
	if player:GetPlayerType() == playerTypeHexanow then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			if roomClearBounsEnabled then
				player.MoveSpeed = player.MoveSpeed + 0.15 --  * (1.0 + 0.15 * player:GetMaxHearts() / 24.0)
			else
				player.MoveSpeed = player.MoveSpeed - 0.15
			end
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 3 -- (1.0 + 2.5 * player:GetMaxHearts() / 24.0 - 0.5)
		elseif cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 3
		elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed - 0.15 -- * (1.0 - 0.3 * player:GetMaxHearts() / 24.0 + 0.15)
		elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
			--player.MaxFireDelay = math.ceil(
			--		(player.MaxFireDelay + (player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) and {2} or {0})[1]
			--		) * 2 -- * (1.0 + 1.5 * player:GetMaxHearts() / 24.0 - 0.5)
			--	)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
				player.MaxFireDelay = ApplyTears2TearDelay(player.MaxFireDelay, -0.34999972571835 -0.6666666666666)
			else
				player.MaxFireDelay = ApplyTears2TearDelay(player.MaxFireDelay, -0.6666666666666)
			end
			--player.MaxFireDelay = player.MaxFireDelay * 2
		elseif cacheFlag == CacheFlag.CACHE_RANGE  then
			player.TearHeight = player.TearHeight * 3 -- (1 + 2.5 * player:GetMaxHearts() / 24.0 - 0.5)
			--player.TearFallingSpeed = player.TearFallingSpeed -- + 5.0 -- * player:GetMaxHearts() / 24.0 
			--player.TearFallingAcceleration = math.min(player.TearFallingAcceleration, - 0.2 / 3)
		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING | TearFlags.TEAR_PERSISTENT | TearFlags.TEAR_SPECTRAL
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			--[[if Game():GetRoom():IsClear() then
				player.CanFly = true
			else
				player.CanFly = false
			end]]
			if roomClearBounsEnabled then
				player.CanFly = true
			end
			 UpdateCostumes(player)
		elseif cacheFlag == CacheFlag.CACHE_FAMILIARS then
			local maybeFamiliars = Isaac.GetRoomEntities()
			for m = 1, #maybeFamiliars do
				local variant = maybeFamiliars[m].Variant
				if variant == (FamiliarVariant.GUILLOTINE) or variant == (FamiliarVariant.ISAACS_BODY) or variant == (FamiliarVariant.SCISSORS) then
					player:TryRemoveNullCostume(hexanowHairCostume)
					player:AddNullCostume(hexanowHairCostume)
				else
					player:TryRemoveNullCostume(hexanowHairCostume)
				end
			end
			
			EnsureFamiliars(player)
		elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = Color(1, 1, 1, 1, 0, 0, 0)
		end
		
	end
end
hexanowMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, hexanowMod.EvaluateCache)


local portalBlue = nil
local portalOrange = nil
local teledProjectiles = {}
--local fireworksToWipe = {}
--local rainbowFireworkRng = RNG()
--local tempt = 0
-- 在每一帧后执行
function hexanowMod:PostUpdate()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	
	CallForEveryPlayer(
		function(player)
			if player:GetPlayerType() == playerTypeHexanow then		
				TickEventHexanow(player)
			end
		end
	)
	
	if PlayerTypeExistInGame(playerTypeHexanow) then
		--if room:GetType() == RoomType.PLANETARIUM then
		--[[
		if room:GetType() == 24 then
			local restockFound = false
			
			CallForEveryEntity(
				function(entity)
					if entity.Type == EntityType.ENTITY_SLOT
					and entity.Variant == 10
					then
						restockFound = true
						return nil
					end
				end
			)
			
			if not restockFound then
				Isaac.Spawn(EntityType.ENTITY_SLOT, 10, 0, Vector(320,200), Vector(0,0), nil)
			end
		end
		]]
		
		CallForEveryEntity(
			function(entity)
				if entity.Type == EntityType.ENTITY_EFFECT
				and entity.Variant == EffectVariant.WOMB_TELEPORT
				then
					local portalFound = false
					
					CallForEveryEntity(
						function(entity2)
							if entity2.Type == entityTypeHexanowPortal
							and entity2.Position:Distance(entity.Position) <= 20
							then
								portalFound = true
								return nil
							end
						end
					)
					
					if not portalFound then
						Isaac.Spawn(entityTypeHexanowPortal, entity.SubType, 0, entity.Position, Vector(0,0), entity)
					end
					
					entity.Visible = false
				end
			end
		)
	end
	
	CallForEveryEntity(
		function(entity)
			if entity.Type == entityTypeHexanowPortal then
				if entity.Variant ~= 0
				and entity.Variant ~= 1
				then
					entity:Remove()
				end
				
				local sprite = entity:GetSprite()

				if entity.FrameCount == 1 then
				end
				
				local wombTeleportFound = false
				
				if PlayerTypeExistInGame(playerTypeHexanow) then
					CallForEveryEntity(
						function(entity2)
							if entity2.Type == EntityType.ENTITY_EFFECT
							and entity2.Variant == EffectVariant.WOMB_TELEPORT
							and entity2.Position:Distance(entity.Position) <= 20
							then
								wombTeleportFound = true
								return nil
							end
						end
					)
				end
				
				if not wombTeleportFound then
					entity.SubType = 1
				end
				
				if entity.SubType == 1 then
					if portalBlue == entity then
						portalBlue = nil
					end
					if portalOrange == entity then
						portalOrange = nil
					end
					if not sprite:IsPlaying("Death") and not sprite:IsFinished("Death") then
						sprite:Play("Death", true)
					elseif sprite:IsFinished("Death") and sprite:GetFrame() > 0 then
						entity:Remove()
					end
				else
					if sprite:IsFinished("Appear") and sprite:GetFrame() > 0 then
						sprite:Play("Idle", false)
					end
					
					if entity.FrameCount > 20 then
						if entity.Variant == 0 then
							--entity:SetColor(Color(9,132,255,1, 0, 0, 0), 0, 999, false, false)
							portalBlue = entity
						elseif entity.Variant == 1 then
							--entity:SetColor(Color(234,135,0,1, 0, 0, 0), 0, 999, false, false)
							portalOrange = entity
						end
					end
				
						--entity.SubType = 1
					--if entity.FrameCount%10 == 0 then
					--	SFXManager():Play(tempt, 3, 0, false, 1 )
					--	print("Playing",tempt)
					--	tempt = tempt + 1
					--end
				end
				
			end
		end
	)
	if portalBlue ~= nil and not portalBlue:Exists() then
		portalBlue = nil
	end
	if portalOrange ~= nil and not portalOrange:Exists() then
		portalOrange = nil
	end
	
	if portalBlue ~= nil and portalOrange ~= nil then
		CallForEveryEntity(
			function(entity)
				if entity.Type == EntityType.ENTITY_TEAR
				or entity.Type == EntityType.ENTITY_BOMBDROP
				--or entity.Type == EntityType.ENTITY_KNIFE
				or entity.Type == EntityType.ENTITY_PROJECTILE  
				then
					if entity.Parent ~= nil and entity.Parent.Type == EntityType.ENTITY_PLAYER then
						local closeToBlue = false
						local closeToOrange = false
						
						local traced = false
						for k,v in ipairs(teledProjectiles) do
							if v == entity.Index then
								traced = true
								break
							end
						end
						
						if not traced then
							if entity.Position:Distance(portalBlue.Position + Vector(20, 20)) <= 20 then
								closeToBlue = true
							end
							if entity.Position:Distance(portalOrange.Position + Vector(20, 20)) <= 20 then
								closeToOrange = true
							end
							
							if closeToBlue and not closeToOrange then
								entity.Position = portalBlue.Position - entity.Position + portalOrange.Position
								table.insert(teledProjectiles, entity.Index)
							elseif closeToOrange and not closeToBlue then
								entity.Position = portalOrange.Position - entity.Position + portalBlue.Position
								table.insert(teledProjectiles, entity.Index)
							end
						else
							if entity.Position:Distance(portalBlue.Position + Vector(20, 20)) <= 40 then
								closeToBlue = true
							end
							if entity.Position:Distance(portalOrange.Position + Vector(20, 20)) <= 40 then
								closeToOrange = true
							end
							if not closeToBlue and not closeToOrange then
								for k,v in ipairs(teledProjectiles) do
									if v == entity.Index then
										table.remove(teledProjectiles, k)
										break
									end
								end
							end
						end
					end
				end
			end
		)
	else
		teledProjectiles = {}
	end
	--[[
	local hexanowExist = PlayerTypeExistInGame(playerTypeHexanow)
	
	for i,entity in ipairs(fireworksToWipe) do
		if entity ~= nil then
			entity:Remove()
		end
	end
	fireworksToWipe = {}
	
	local roomEntities = Isaac.GetRoomEntities()
	for i,entity in ipairs(roomEntities) do
		
		if hexanowExist then
			local npc = entity:ToNPC()
			if npc ~= nil then
				local fireworkEntity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FIREWORKS, 5, entity.Position, entity.Velocity, entity)
				
				local r,g,b,h
				h = rainbowFireworkRng:RandomInt(359)
				
				if     h < 60 then
					r = 1
					g = (h - 0) / 30.0
					b = 0
				elseif h < 120 then
					r = 1 - (h - 60) / 30.0
					g = 1
					b = 0
				elseif h < 180 then
					r = 0
					g = 1
					b = (h - 120) / 30.0
				elseif h < 240 then
					r = 0
					g = 1 - (h - 180) / 30.0
					b = 1
				elseif h < 270 then
					r = (h - 240) / 30.0
					g = 0
					b = 1
				elseif h < 360 then
					r = 1
					g = 0
					b = 1 - (h - 270) / 30.0
				end
				
				fireworkEntity.Visible = false
				fireworkEntity:SetColor(Color(r,g,b,
					1, 0, 0, 0), 0, 999, false, false)
				table.insert(
					fireworksToWipe,
					fireworkEntity
					)
			end
		end
		
		local tear = entity:ToTear()
		if tear ~= nil then
			if      tear.Parent.Type == EntityType.ENTITY_PLAYER then
				local player = tear.Parent:ToPlayer()
				if player:GetPlayerType() == playerTypeHexanow
				then
					-- tear.Height = tear.Height + tear.FallingSpeed * 2 / 3
					-- local roomEntities = Isaac.GetRoomEntities()
					-- print("HomingFriction: ", tear.HomingFriction)
					
					if tear.Variant ~= TearVariant.BLUE then
						local tearSprite = tear:GetSprite()
						tear:ChangeVariant(TearVariant.BLUE)
						
						tearSprite:ReplaceSpritesheet(0,"gfx/Hexanow_tears.png")
						tearSprite:LoadGraphics("gfx/Hexanow_tears.png")
						tearSprite.Rotation = tear.Velocity:GetAngleDegrees()
					end
					
					
					for i,entity in ipairs(roomEntities) do
						local pickup = entity:ToPickup()
						if pickup ~= nil then
							if pickup.Type == EntityType.ENTITY_PICKUP 
							and pickup.Variant == PickupVariant.PICKUP_HEART
							and pickup.SubType ~= HeartSubType.HEART_BLENDED
							and (
								pickup.SubType == HeartSubType.HEART_FULL or
								pickup.SubType == HeartSubType.HEART_HALF or
								pickup.SubType == HeartSubType.HEART_SOUL or
								pickup.SubType == HeartSubType.HEART_HALF_SOUL or
								pickup.SubType == HeartSubType.HEART_SCARED or
								pickup.SubType == HeartSubType.HEART_BLACK or
								(pickup.SubType == HeartSubType.HEART_ETERNAL and player:GetMaxHearts() >= 24 and player:GetEternalHearts() >= 1) or
								(pickup.SubType == HeartSubType.HEART_BONE and player:GetMaxHearts() >= 24) or
								pickup.SubType == HeartSubType.HEART_DOUBLEPACK
							)
							then
								if tear.Position:Distance(pickup.Position) < 20
								then
									if pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
										Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED, pickup.Position, Vector(0.005, 0.005), player)
										pickup:AddVelocity(Vector(-0.005, -0.005))
									end
									pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED, true)
								end
							end
						end
					end
			
				end
			elseif  tear.Parent.Type == EntityType.ENTITY_FAMILIAR
				and tear.Parent.Variant == entityVariantHeartsBlender
				then
				local fam = tear.Parent:ToFamiliar()
				-- SOME THING TO DO
			end
		end
	end
	]]
	
	--SaveHexanowModData()
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_UPDATE, hexanowMod.PostUpdate)

-- 初始化随从
local function FamiliarInit(_, fam)
	print("Initiating Hearts Blender")
end
hexanowMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, FamiliarInit, entityVariantHeartsBlender)

-- 更新随从行为
local function FamiliarUpdate(_, fam)
	local roomEntities = Isaac.GetRoomEntities()
	
	local targetPos = nil
	local dis = nil
	
    local parent = fam.Player
	--[[if parent:ToPlayer() ~= nil then
		parent = fam.Parent:ToPlayer()
	end]]
	
	--[[
	for i,entity in ipairs(roomEntities) do
		local pickup = entity:ToPickup()
		if pickup ~= nil then
			if pickup.Type == EntityType.ENTITY_PICKUP 
			and (pickup.Variant == PickupVariant.PICKUP_HEART and (
				-- HeartSubType.HEART_BLENDED or
				pickup.SubType == HeartSubType.HEART_FULL or
				pickup.SubType == HeartSubType.HEART_HALF or
				pickup.SubType == HeartSubType.HEART_SOUL or
				pickup.SubType == HeartSubType.HEART_HALF_SOUL or
				pickup.SubType == HeartSubType.HEART_SCARED or
				pickup.SubType == HeartSubType.HEART_BLACK or
				-- (pickup.SubType == HeartSubType.HEART_ETERNAL and parent:GetMaxHearts() >= 24 and parent:GetEternalHearts() >= 1) or
				-- (pickup.SubType == HeartSubType.HEART_BONE and parent:GetMaxHearts() >= 24) or
				false
			))
			then
				if targetPos == nil
				or fam.Position:Distance(pickup.Position) < dis or dis ~= nil
				then
					if fam.Position:Distance(pickup.Position) < 10 -- and not pickup.IsShopItem () and parent.Position:Distance(pickup.Position) > 100
					then
						pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED, true)
						-- pickup.Position = parent.Position
					else
						targetPos = pickup.Position
						dis = fam.Position:Distance(pickup.Position)
					end
				end
			end
		end
	end
	]]
	
	if targetPos ~= nil then
		--  targetPos = parent.Position
		fam:FollowPosition(targetPos)
		-- fam.Position = targetPos
	else
		fam:FollowParent()
	end

    if fam.FrameCount%300 == 0 then
    end
end
hexanowMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, FamiliarUpdate, entityVariantHeartsBlender)

-- 更新眼泪行为，在每一帧后执行
function hexanowMod:PostTearUpdate(tear)
end
hexanowMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE , hexanowMod.PostTearUpdate)