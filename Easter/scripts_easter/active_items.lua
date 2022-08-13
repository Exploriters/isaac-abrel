local EasterBlandishment = Isaac.GetItemIdByName("Blandishment")

function EasterMod:UseBlandishment(itemId, itemRng, player, useFlags, activeSlot, customVarData)
	local result = {
		Discharge = true,
		Remove = false,
		ShowAnim = true,
	}

	CallForEveryEntity(function(entity)
		if (entity:ToProjectile() ~= nil) or (entity:ToNPC() ~= nil and entity:IsVulnerableEnemy() and not entity:IsInvincible() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
			if (player.Position - entity.Position):Length() <= 100 then
				entity:AddFreeze(EntityRef(player), 30)
			end
		end
	end)

	return result
end
EasterMod:AddCallback(ModCallbacks.MC_USE_ITEM, EasterMod.UseBlandishment, EasterBlandishment)