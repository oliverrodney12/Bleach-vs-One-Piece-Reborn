function fountain_protector( keys )
	local caster = keys.caster

	if caster.currentTarget ~= nil and not caster.currentTarget:IsNull() and not caster.currentTarget:IsAlive() then
		caster.currentTarget = nil
	end

	if caster.currentTarget == nil then
		local neutralUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	              caster:GetAbsOrigin(),
	              nil,
	              caster:GetAcquisitionRange(),
	              DOTA_UNIT_TARGET_TEAM_ENEMY,
	              DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
	              DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	              FIND_CLOSEST,
	              false)

		for _,unit in pairs(neutralUnits) do
			caster:SetForceAttackTarget(unit)
		end
	end
end

function fountain_protector_hit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, target, "bvo_fountain_protector_debuff_modifier", {duration=5.0} )
	if not target:HasModifier("bvo_fountain_protector_debuff_modifier") then
		target:SetModifierStackCount("bvo_fountain_protector_debuff_modifier", ability, 1 )
	else
		local current_stack = target:GetModifierStackCount( "bvo_fountain_protector_debuff_modifier", ability )
		target:SetModifierStackCount("bvo_fountain_protector_debuff_modifier", ability, current_stack + 1 )
	end
	local new_stack = target:GetModifierStackCount( "bvo_fountain_protector_debuff_modifier", ability )

	local new_health = target:GetHealth() - ( new_stack * 50 )
	if new_health <= 1 then
		target:Kill(ability, caster)
	else
		target:SetHealth(new_health)
	end

	--fck usopp
	local _usopp = target:FindAbilityByName("bvo_usopp_skill_0")
	if _usopp ~= nil then
		_usopp.damageTaken = 0
	end
end