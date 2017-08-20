function bvo_rem_skill_2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )

	target:AddNewModifier(caster, ability, "bvo_rem_skill_2_modifier", {duration=duration})
	target:EmitSound("Hero_Oracle.FalsePromise.Healed")
end