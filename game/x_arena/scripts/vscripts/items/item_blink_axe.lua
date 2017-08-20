function item_blink_axe(keys)
	local ability = keys.ability
	local caster = keys.caster
	local point = keys.target_points[1]
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local big_cooldown = ability:GetLevelSpecialValueFor("big_cooldown", 0 )
	local range_big = ability:GetLevelSpecialValueFor("blink_range_big", 0 )
	local range_small = ability:GetLevelSpecialValueFor("blink_range_small", 0 )

	local range = range_big
	if ability:GetCurrentCharges() > 0 then
		range = range_small
	end

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)

	local casterPosB = caster:GetAbsOrigin()
	if not GridNav:CanFindPath(casterPos, casterPosB) then
		ability:EndCooldown()
		FindClearSpaceForUnit(caster, casterPos, false)
    	return
	end

	if range == range_big then
		ability:SetCurrentCharges(big_cooldown)
	end

	for i = 0, 5 do
		local item = caster:GetItemInSlot(i)
		if item ~= nil then
			if item:GetName() == "item_blink_custom" then
				item:StartCooldown(ability:GetCooldownTimeRemaining())
			end
    	end
	end
end

function item_blink_axe_stack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local big_cooldown = ability:GetLevelSpecialValueFor("big_cooldown", 0 )

	local current_stack = ability:GetCurrentCharges()
	local new_stack = current_stack - 1

	if new_stack < 0 then new_stack = 0 end

	ability:SetCurrentCharges(new_stack)
end