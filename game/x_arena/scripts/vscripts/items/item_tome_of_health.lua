function item_tome_of_health( keys )
	local caster = keys.caster
	local ability = caster:FindAbilityByName("bvo_mana_on_hit")

	local mods = caster:FindAllModifiers()
	local stacks = 0
	for _,mod in pairs(mods) do
		if mod:GetName() == "bvo_tome_of_health_modifier" then
			stacks = stacks + 1
		end
	end
	for i = 1, stacks do
		caster:RemoveModifierByName("bvo_tome_of_health_modifier")
	end
	if stacks > 0 then
		local current_stack = caster:GetModifierStackCount( "bvo_tome_of_health_stack_modifier", ability )
		caster:RemoveModifierByName("bvo_tome_of_health_stack_modifier")
		ability:ApplyDataDrivenModifier(caster, caster, "bvo_tome_of_health_stack_modifier", {})
		caster:SetModifierStackCount( "bvo_tome_of_health_stack_modifier", ability, current_stack + stacks )
	end
end