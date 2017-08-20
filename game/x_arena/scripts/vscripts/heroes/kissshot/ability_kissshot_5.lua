function bvo_kissshot_skill_5(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:Kill(ability, caster)
end