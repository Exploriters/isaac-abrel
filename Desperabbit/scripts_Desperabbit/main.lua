DesperabbitMod.Main = {}

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

Explorite.RegistPlyaerAnmiOverride(playerType_Desperabbit, "gfx/characters/anmiOverride/anmiOverride_desperabbitPlayer.anm2")



--==== CLASSES AND CONSTRUCTORS ====--
local DesperabbitAbilityData = {}
DesperabbitAbilityData.__index = DesperabbitAbilityData
local function DesperabbitAbilityData()
	local cted = {}
	setmetatable(cted, DesperabbitAbilityData)
	cted.name = ""
	cted.displayAllowsEnable = function (player) return false end
	cted.startingInterval = function (player) end
	cted.endingInterval = function (player) end
	cted.enabledInterval = function (player) end
	cted.onEnable = function (player) end
	cted.onDisable = function (player) end
	
	return cted
end

local desperabbitPlayerData = {
}
desperabbitPlayerData.__index = desperabbitPlayerData

function desperabbitPlayerData:UpdateLastRoomVar()
	self.lastRoom = {}
	self.lastRoom.form = self.form
end
function desperabbitPlayerData:RewindLastRoomVar()
	self.form = self.lastRoom.form
	self:UpdateLastRoomVar()
end

local function DesperabbitPlayerData()
	local cted = {}
	setmetatable(cted, desperabbitPlayerData)

	cted.overlayName = nil
	cted.overlaySprite = nil
	cted.overlayOffset = nil
	cted.overlayFrame = 0
	cted.overlayWearoff = 0
	
	cted.isDead = false
	cted.canRevive = false
	cted.HPlimit = 6

	return cted
end

local DesperabbitPlayerDatas = {}

DesperabbitPlayerDatas[1] = DesperabbitPlayerData()
DesperabbitPlayerDatas[2] = DesperabbitPlayerData()
DesperabbitPlayerDatas[3] = DesperabbitPlayerData()
DesperabbitPlayerDatas[4] = DesperabbitPlayerData()

function DesperabbitMod.Main.UpdateLastRoomVar()
	LastRoom = {}
	for playerID=1,4 do
		DesperabbitPlayerDatas[playerID]:UpdateLastRoomVar()
	end
end

function DesperabbitMod.Main.RewindLastRoomVar()
	for playerID=1,4 do
		DesperabbitPlayerDatas[playerID]:RewindLastRoomVar()
	end
end

function DesperabbitMod.Main.WipeTempVar()
	DesperabbitFlags:Wipe()
	DesperabbitPlayerDatas = {}

	DesperabbitPlayerDatas[1] = DesperabbitPlayerData()
	DesperabbitPlayerDatas[2] = DesperabbitPlayerData()
	DesperabbitPlayerDatas[3] = DesperabbitPlayerData()
	DesperabbitPlayerDatas[4] = DesperabbitPlayerData()
end

function DesperabbitMod.Main.ApplyVar(objective)
	for playerID=1,4 do
		DesperabbitPlayerDatas[playerID].HPlimit = tonumber(objective:Read("Player"..playerID.."-HPlimit", "6"))
	end
end

function DesperabbitMod.Main.RecieveVar(objective)
	for playerID=1,4 do
		objective:Write("Player"..playerID.."-HPlimit", tostring(DesperabbitPlayerDatas[playerID].HPlimit))
	end
end

--==== OVERLAY CLAIM ====--

local function MaintainOverlay(player)
	local playerID = GetGamePlayerID(player)
	local overlayName = DesperabbitPlayerDatas[playerID].overlayName
	if type(DesperabbitOverlayDatas[overlayName]) ~= "function" then
		overlayName = nil
		DesperabbitPlayerDatas[playerID].overlayName = nil
	end
	if overlayName == nil then
		if DesperabbitPlayerDatas[playerID].overlaySprite ~= nil then
			if DesperabbitPlayerDatas[playerID].overlayWearoff < 4 then
				DesperabbitPlayerDatas[playerID].overlayWearoff = DesperabbitPlayerDatas[playerID].overlayWearoff + 1
			else
				DesperabbitPlayerDatas[playerID].overlayWearoff = 0
				DesperabbitPlayerDatas[playerID].overlaySprite = nil
				DesperabbitPlayerDatas[playerID].overlayOffset = nil
				DesperabbitPlayerDatas[playerID].overlayFrame = 0
			end
		end
	else
		if DesperabbitPlayerDatas[playerID].overlaySprite == nil then
			DesperabbitPlayerDatas[playerID].overlaySprite, DesperabbitPlayerDatas[playerID].overlayOffset = DesperabbitOverlayDatas[overlayName]()
		end
		player:SetColor(Color(1, 1, 1, 0, 255, 255, 255), 2, 1, false, false)
	end
	if DesperabbitPlayerDatas[playerID].overlaySprite ~= nil then
		player.ControlsCooldown = math.max(1, player.ControlsCooldown)
	end
end
local function SetDesperabbitOverlay(player, overlayName)
	local playerID = GetGamePlayerID(player)
	if type(DesperabbitOverlayDatas[overlayName]) == "function" then
		DesperabbitPlayerDatas[playerID].overlayName = overlayName
		DesperabbitPlayerDatas[playerID].overlaySprite = nil
		DesperabbitPlayerDatas[playerID].overlayFrame = 0
		DesperabbitPlayerDatas[playerID].overlayWearoff = 0
		MaintainOverlay(player)
	end
end
local function ClearDesperabbitOverlay(player, overlayName)
	local playerID = GetGamePlayerID(player)
	if DesperabbitPlayerDatas[playerID].overlayName == overlayName then
		DesperabbitPlayerDatas[playerID].overlayName = nil
		MaintainOverlay(player)
	end
end

--[[DesperabbitPlayerDatas.isDead = function (player)
	local playerID = GetGamePlayerID(player)
	if DesperabbitPlayerDatas[playerID].isDead == true and DesperabbitPlayerDatas[playerID].canRevive == false then
		SetDesperabbitOverlay(player, "DeathAnimation")
		DesperabbitPlayerDatas[playerID].isDead = false
	end
	--player.Velocity = Vector(0, 0)
	--player.ControlsCooldown = math.max(30, player.ControlsCooldown)
	UpdateCostume(player)
	UpdateCache(player)
end]]--

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
--			nothing here
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
	local playerID = GetGamePlayerID(player)

	if IsDesperabbit(player) then
		--Update Costume
		local room = Game():GetRoom()
		if room:GetFrameCount() == 1 then
			UpdateCostume(player)
		end
		
		--Change tear variant
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
		
		--Anmi override
		if DesperabbitPlayerDatas[playerID].overlaySprite ~= nil then
			DesperabbitPlayerDatas[playerID].overlayFrame = DesperabbitPlayerDatas[playerID].overlayFrame +1
		end
		
		MaintainOverlay(player)
		
		if player:IsDead() and DesperabbitPlayerDatas[playerID].overlayName ~= "DeathAnimation" then
		--	DesperabbitPlayerDatas[playerID].isDead = true
			DesperabbitPlayerDatas[playerID].HPlimit = 6
			SetDesperabbitOverlay(player, "DeathAnimation")
		end
		--if DesperabbitPlayerDatas[playerID].isDead == true and DesperabbitPlayerDatas[playerID].canRevive == false then
		--	SetDesperabbitOverlay(player, "DeathAnimation")
		--end
		
		--HP limit
		--Thanks for Cuerzor's help <3
		if player:GetMaxHearts() > 0 then
			if player:GetHearts() > 0 then
				player:AddHearts(-player:GetHearts())
				player:AddMaxHearts(-player:GetMaxHearts())
			else
				player:AddMaxHearts(-player:GetMaxHearts())
			end
		end
		--while player:GetBlackHearts() > 0 do
		--	player:AddBlackHearts(-1, true)
		--end
		if player:GetEternalHearts() > 0 then
			player:AddEternalHearts(-player:GetEternalHearts())
		end
		if player:GetBoneHearts() > 0 then
			player:AddBoneHearts(-player:GetBoneHearts())
		end
		
		local soulHearts = player:GetSoulHearts()
		if (soulHearts > DesperabbitPlayerDatas[playerID].HPlimit) then
			player:AddSoulHearts(DesperabbitPlayerDatas[playerID].HPlimit - soulHearts)
		end
	end
end

function DesperabbitMod.Main:RabbitHurt(TookDamage, DamageAmount, DamageFlags, DamageSource, DamageCountdownFrames)
	local player = TookDamage:ToPlayer()
	
	if player ~= nil and IsDesperabbit(player) then
		local playerID = GetGamePlayerID(player)
		DesperabbitPlayerDatas[playerID].HPlimit = DesperabbitPlayerDatas[playerID].HPlimit - 2
	end
end
DesperabbitMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG , DesperabbitMod.Main.RabbitHurt)

function DesperabbitMod.Main:NPCbleed(TookDamage, DamageAmount, DamageFlags, DamageSource, DamageCountdownFrames)
	local NPC = TookDamage:ToNPC()
	if NPC ~= nil and DamageSource.Entity ~= nil and DamageSource.Entity.Parent ~= nil and DamageSource.Entity.Parent:ToPlayer() ~= nil then
		local player = DamageSource.Entity.Parent:ToPlayer()
		local playerID = GetGamePlayerID(player)
		if IsDesperabbit(player) then
		--	预期效果：
		--	*兔兔的幸运越低，造成流血的概率反而越高。当大等于0时，兔兔造成流血的概率则固定为5%(每发)。
		--	*在幸运小于0的情况下，兔兔每降低一点幸运，他能够造成流血的概率就+5%(每发)。也就是说他应该初始具有25%(每发)的概率对敌人造成流血效果。
		--	*如果这个数值是不合理的，就修改它直到平衡>w<
			if player.Luck >= 0 then
				local Chance = math.random(100)
				if Chance <= 5 then
					NPC:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
				end
			else
				local Chance = math.random(100)
				if Chance <= (-5 * player.Luck + 5) then
					NPC:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
				end
			end
		end
	end
end
DesperabbitMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG , DesperabbitMod.Main.NPCbleed)

function DesperabbitMod:PostPlayerUpdate(player)
	TickEventDesperabbit(player)
end
DesperabbitMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, DesperabbitMod.PostPlayerUpdate)

function DesperabbitMod.Main:PrePickupCollision(pickup, collider, low)
	local player = collider:ToPlayer()
	if player ~= nil and IsDesperabbit(player) then
		if pickup.Variant == PickupVariant.PICKUP_HEART then
			return false
		elseif pickup.Variant == PickupVariant.PICKUP_BED and pickup.SubType == BedSubType.BED_ISAAC then
			return false
		end
	end
end
DesperabbitMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, DesperabbitMod.Main.PrePickupCollision)

--==== ANIMATION RENDERING ====--
local function DesperabbitRendering(player, pos)
	if IsDesperabbit(player) then
		local playerID = GetGamePlayerID(player)
		local sprite = DesperabbitPlayerDatas[playerID].overlaySprite
		local offset = DesperabbitPlayerDatas[playerID].overlayOffset
		local screenxy = Isaac.WorldToScreen(player.Position)
		if sprite ~= nil then
			sprite:Render(screenxy + offset, Vector(0,0), Vector(0,0))
			while DesperabbitPlayerDatas[playerID].overlayFrame > 1 do
				sprite:Update()
				DesperabbitPlayerDatas[playerID].overlayFrame = DesperabbitPlayerDatas[playerID].overlayFrame - 2
			end
			--local str = "OVERLAY "..DesperabbitPlayerDatas[playerID].overlayName.." TESTING"
			--Explorite.RenderText(str, screenxy.X - Explorite.GetTextWidth(str)/2, screenxy.Y, 255, 255, 255, 255)
		end
	end
end

function DesperabbitMod.Main:PostPlayerRender(player, pos)
	DesperabbitRendering(player, pos)
end
DesperabbitMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, DesperabbitMod.Main.PostPlayerRender, 0)