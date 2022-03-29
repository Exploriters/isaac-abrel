
--== Soul Stone ==--

LairubMod.SoulStone = {}

local lairubSoulStoneID = Isaac.GetCardIdByName("Soul of Lairub")
local UsedLairubSoulStone = false
local TriggerDelay = 1
local TriggeredCount = 0
local BaseFrameCount = 0
local BaseGameFrameCount = 0
local DMGtoEveryNPC = false
local TotalRoomFrame = 0
local SoulCount = 0
local LastRoom = {}

-- Thanks for siiftun1857's help >w< --

function LairubMod.SoulStone.ApplyVar(objective)
	SoulCount = tonumber(objective:Read("SoulStoneSoulCount", "0"))
end

function LairubMod.SoulStone.RecieveVar(objective)
	objective:Write("SoulStoneSoulCount", tostring(SoulCount))
end

function LairubMod.SoulStone.UpdateLastRoomVar()
	LastRoom = {}
	LastRoom.SoulCount = SoulCount
end

function LairubMod.SoulStone.RewindLastRoomVar()
	SoulCount = LastRoom.SoulCount
end

function LairubMod.SoulStone.WipeTempVar()
	UsedLairubSoulStone = false
	TriggeredCount = 0
	BaseFrameCount = 0
	DMGtoEveryNPC = false
	BaseGameFrameCount = 0
end

function LairubMod.SoulStone:PostNewLevel()
	UsedLairubSoulStone = false
	DMGtoEveryNPC = false
	BaseGameFrameCount = 0
end
LairubMod:AddCallback( ModCallbacks.MC_POST_NEW_LEVEL, LairubMod.SoulStone.PostNewLevel)

function LairubMod.SoulStone:PostNewRoom()
	TriggeredCount = 0
	BaseFrameCount = 0
end
LairubMod:AddCallback( ModCallbacks.MC_POST_NEW_ROOM, LairubMod.SoulStone.PostNewRoom)


function LairubMod.SoulStone:UseLairubSoulStone(cardId, player, useFlags)
	local room = Game():GetRoom()
	BaseFrameCount = room:GetFrameCount()
	BaseGameFrameCount = Game():GetFrameCount()
	UsedLairubSoulStone = true
end
LairubMod:AddCallback(ModCallbacks.MC_USE_CARD, LairubMod.SoulStone.UseLairubSoulStone, lairubSoulStoneID)

function LairubMod.SoulStone:PostNPCDeath()
	if UsedLairubSoulStone == true then
		SoulCount = SoulCount + 1
	end
end
LairubMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, LairubMod.SoulStone.PostNPCDeath)

function LairubMod.SoulStone:SoulStonePostRender()
	local game = Game()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	local playerPos = room:WorldToScreenPosition(player.Position)
	if UsedLairubSoulStone == true then
		if player:GetPlayerType() ~= playerType_Lairub and player:GetPlayerType() ~= playerType_Tainted_Lairub then
			if true or not IsLairubButtonPressed(player,"hide_ui") then
				SoulSign:SetOverlayRenderPriority(true)
				SoulSign:SetFrame("SoulSign", 1)
				SoulSign:Render(Vector(playerPos.X - 5, playerPos.Y - 44), Vector(0,0), Vector(0,0))
				Explorite.RenderText(tostring(SoulCount), playerPos.X + 5, playerPos.Y - 46, 255, 255, 255, 255)
			end
		end
	end
end
LairubMod:AddCallback(ModCallbacks.MC_POST_RENDER, LairubMod.SoulStone.SoulStonePostRender)

function LairubMod.SoulStone:LairubSoulStonePostUpdate()
	local level = Game():GetLevel()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local roomEntities = Isaac.GetRoomEntities()
	if UsedLairubSoulStone == true then
		--==Spawn==--
		if (room:GetFrameCount() - BaseFrameCount) % TriggerDelay == 0 then
			TriggeredCount = TriggeredCount + 1
			Isaac.Spawn(EntityType.ENTITY_EFFECT, 111, 0, Vector(player.Position.X, player.Position.Y - 25), Vector(math.random(-8, 8), math.random(-8, 8)), player)
		end
		CallForEveryEntity(function(entity)
			if entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == 111 then
				entity:SetColor(Color(1, 1, 1, 1, 1, 1, 1), 0, 999, true, true)
			end
		end)
		--==Function==--
		--DMG To Every NPC
		if DMGtoEveryNPC == false then
			CallForEveryEntity(function(entity)
				local NPC = entity:ToNPC()
				if NPC ~= nil and NPC:IsVulnerableEnemy() and not NPC:IsBoss() then
					NPC:TakeDamage(9999, 0, EntityRef(player), 0)
					if NPC:IsDead() then
						Isaac.Spawn(EntityType.ENTITY_EFFECT, LairubSoulEffect_Variant, 0, NPC.Position, Vector(0,0), player)
					end
				end
			end)
			if room:IsClear() then
				DMGtoEveryNPC = true
			end
		end
		--
		TotalRoomFrame = Game():GetFrameCount() - BaseGameFrameCount
		if TotalRoomFrame >= 600 then
			UsedLairubSoulStone = false
			DMGtoEveryNPC = false
			TotalRoomFrame = 0
			BaseGameFrameCount = 0
			if player:GetPlayerType() ~= playerType_Lairub and player:GetPlayerType() ~= playerType_Tainted_Lairub then
				SoulCount = 0
			end
		elseif TotalRoomFrame < 600 then
			CallForEveryEntity(function(entity)
				local NPC = entity:ToNPC()
				if SoulCount > 0 then
					if NPC ~= nil and NPC:IsVulnerableEnemy() and not NPC:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
						if (player.Position - NPC.Position):Length() < 128 or level:GetStage() == 13 then
							SoulCount = SoulCount - 1
							NPC:TakeDamage((player.Damage * 1.5), 0, EntityRef(player), 0)
							NPC:SetColor(Color(0, 0, 0, 1, 0, 0, 0), 30, 999, true, true)
							if SoulCount < 0 then
								SoulCount = 0
							end
						end
					end
				end
				if NPC ~= nil and NPC:IsDead() and not NPC:IsBoss() then
					Isaac.Spawn(EntityType.ENTITY_EFFECT, LairubSoulEffect_Variant, 0, NPC.Position, Vector(0,0), player)
				end
			end)
		end
		--====--
	end
end
LairubMod:AddCallback(ModCallbacks.MC_POST_UPDATE, LairubMod.SoulStone.LairubSoulStonePostUpdate)
