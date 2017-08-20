function bvo_rem_skill_0( keys )
	local caster = keys.caster
	local ability = keys.ability
	local stack_per_percent = ability:GetLevelSpecialValueFor("stack_per_percent", ability:GetLevel() - 1 )
	local armor = ability:GetLevelSpecialValueFor("armor", ability:GetLevel() - 1 )
	local ms = ability:GetLevelSpecialValueFor("ms", ability:GetLevel() - 1 )

	local stacks = (100 / stack_per_percent) - math.ceil(caster:GetHealthPercent() / stack_per_percent)
	if stacks > 0 then
		if not caster:HasModifier("bvo_rem_skill_0_buff_modfier") then
			ability:ApplyDataDrivenModifier(caster, caster, "bvo_rem_skill_0_buff_modfier", {})
		end
		caster:SetModifierStackCount("bvo_rem_skill_0_buff_modfier", ability, stacks)
	else
		caster:RemoveModifierByName("bvo_rem_skill_0_buff_modfier")
	end
end