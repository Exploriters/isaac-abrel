
local BlueEyesMod = RegisterMod("blue_eyes", 1);
local BlueEyesItem = Isaac.GetItemIdByName("Blue Eyes")

function BlueEyesMod:PostPlayerUpdate(player)
	if player.FrameCount % 2 == 0
	then
		return
	end
	if not player:HasCollectible(BlueEyesItem)
	and player:GetEffects():GetCollectibleEffectNum(BlueEyesItem) <= 0
	then
		return
	end
	local roomEntities = Isaac.GetRoomEntities()
	for i,entity in ipairs(roomEntities) do
		if entity:IsActiveEnemy(false)
		and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
		then
			local range = (player.Position - entity.Position):Length()
			if range < 100 then
				entity:AddSlowing(EntityRef(player), 1, 0.513, Color(1, 1, 1, 1, 0, 0, 0))
			end
		end
	end
end
BlueEyesMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BlueEyesMod.PostPlayerUpdate)
