
local wombTeleportPinMod = RegisterMod("wombTeleportPin", 1);

function wombTeleportPinMod:PostUpdate()
	local roomEntities = Isaac.GetRoomEntities()
	if Game():GetRoom():GetBackdropType() == 57 then
		for i,entity in ipairs(roomEntities) do
			if entity.Type == EntityType.ENTITY_EFFECT
			and entity.Variant == EffectVariant.WOMB_TELEPORT
			then				
				local posX = math.floor(entity.Position.X/40.0)*40
				local posY = math.floor(entity.Position.Y/40.0)*40
				entity.Position = Vector(posX, posY)
				entity.Velocity = Vector(0, 0)
			end
		end
	end
end
wombTeleportPinMod:AddCallback(ModCallbacks.MC_POST_UPDATE, wombTeleportPinMod.PostUpdate)
