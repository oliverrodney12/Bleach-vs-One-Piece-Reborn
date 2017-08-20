function bvo_rem_skill_4( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local multiplier = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor("knockback_duration", ability:GetLevel() - 1 )
	local speed = ability:GetLevelSpecialValueFor("knockback_speed", ability:GetLevel() - 1 )

	ability:ApplyDataDrivenModifier(caster, target, "bvo_rem_skill_4_modifier", {duration=duration})

	caster.rem_skill_4_direction = caster:GetForwardVector()
	caster.rem_skill_4_speed = speed * 1/30

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage + caster:GetAgility() * multiplier,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage(damageTable)
end

function bvo_rem_skill_4_knockback( keys )
	local caster = keys.caster
	local target = keys.target

	local new_pos = target:GetAbsOrigin() + caster.rem_skill_4_direction * caster.rem_skill_4_speed
	if target:HasModifier("bvo_rem_skill_4_modifier") then
		if not GridNav:CanFindPath(target:GetAbsOrigin(), new_pos) then
			target:InterruptMotionControllers(true)
		else
			target:SetAbsOrigin(new_pos)
		end
	else
		target:InterruptMotionControllers(true)
	end
end