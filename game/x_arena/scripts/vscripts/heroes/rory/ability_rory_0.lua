function bvo_rory_skill_0( keys )
	local caster = keys.caster
	local ability = keys.ability

	if not caster:HasModifier( "bvo_rory_skill_0_buff_modifier" ) then
		ability:ApplyDataDrivenModifier(caster, caster, "bvo_rory_skill_0_buff_modifier", {})
		caster:SetModifierStackCount( "bvo_rory_skill_0_buff_modifier", ability, 1 )
	else
		local current_stack = caster:GetModifierStackCount( "bvo_rory_skill_0_buff_modifier", ability )
		caster:SetModifierStackCount( "bvo_rory_skill_0_buff_modifier", ability, current_stack + 1 )

		local mods = caster:FindAllModifiers()
		for _,mod in pairs(mods) do
			if mod:GetName() == "bvo_rory_skill_0_buff_modifier" then
				mod:ForceRefresh()
				break
			end
		end
	end
end