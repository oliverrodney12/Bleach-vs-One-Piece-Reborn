function item_gem_eat( keys )
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability

	if not target:HasModifier("modifier_truesight_perma_custom") then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_truesight_perma_custom", {} )
	end
end