function bvo_squall_skill_1( keys )
	local caster = keys.caster
	local ability = keys.ability
	local chance_revolver = ability:GetLevelSpecialValueFor("chance_revolver", ability:GetLevel() - 1 )
	local chance_shear_trigger = ability:GetLevelSpecialValueFor("chance_shear_trigger", ability:GetLevel() - 1 )
	local chance_flame_saber = ability:GetLevelSpecialValueFor("chance_flame_saber", ability:GetLevel() - 1 )
	local chance_punishment = ability:GetLevelSpecialValueFor("chance_punishment", ability:GetLevel() - 1 )
	local chance_lionheart = ability:GetLevelSpecialValueFor("chance_lionheart", ability:GetLevel() - 1 )

	local mod_roll = {}
	for i = 1, chance_revolver do
		table.insert(mod_roll, "bvo_squall_skill_0_revolver_modifier")
	end
	for i = 1, chance_shear_trigger do
		table.insert(mod_roll, "bvo_squall_skill_0_shear_trigger_modifier")
	end
	for i = 1, chance_flame_saber do
		table.insert(mod_roll, "bvo_squall_skill_0_flame_saber_modifier")
	end
	for i = 1, chance_punishment do
		table.insert(mod_roll, "bvo_squall_skill_0_punishment_modifier")
	end
	for i = 1, chance_lionheart do
		table.insert(mod_roll, "bvo_squall_skill_0_lionheart_modifier")
	end
	local roll = RandomInt(1, #mod_roll)
	caster:RemoveModifierByName("bvo_squall_skill_0_revolver_modifier")
	caster:RemoveModifierByName("bvo_squall_skill_0_shear_trigger_modifier")
	caster:RemoveModifierByName("bvo_squall_skill_0_flame_saber_modifier")
	caster:RemoveModifierByName("bvo_squall_skill_0_punishment_modifier")
	caster:RemoveModifierByName("bvo_squall_skill_0_lionheart_modifier")
	
	caster:FindAbilityByName("bvo_squall_skill_0"):ApplyDataDrivenModifier(caster, caster, mod_roll[roll], {})
end