function item_skadi_custom( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local dur_melee = ability:GetLevelSpecialValueFor("cold_duration_melee", 0 )
	local dur_ranged = ability:GetLevelSpecialValueFor("cold_duration_ranged", 0 )

	local dur = dur_ranged
	if caster:GetAttackCapability() == 1 then dur = dur_melee end

	ability:ApplyDataDrivenModifier(caster, target, "item_skadi_custom_slow_modifier", {duration=dur})
end