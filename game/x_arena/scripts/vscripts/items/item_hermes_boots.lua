function item_hermes_boots_eat( keys )
	local caster = keys.caster
	local ability = keys.ability

	if not caster:HasModifier("item_shihoins_boots_perma_modifier") then
		ability:ApplyDataDrivenModifier(caster, caster, "item_shihoins_boots_perma_modifier", {} )
	end
end