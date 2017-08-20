function bvo_squall_skill_4_trigger( keys )
	local caster = keys.caster
	bvo_squall_skill_4_hit(caster, caster:FindAbilityByName("bvo_squall_skill_4"))
end

function bvo_squall_skill_4_hit( caster, ability )
	local durability_cost = ability:GetLevelSpecialValueFor("durability_cost", ability:GetLevel() - 1 )
	local str_multi = ability:GetLevelSpecialValueFor("str_multi", ability:GetLevel() - 1 )
	local agi_multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )

	local damage_multi_revolver = ability:GetLevelSpecialValueFor("damage_multi_revolver", ability:GetLevel() - 1 )
	local damage_multi_shear_trigger = ability:GetLevelSpecialValueFor("damage_multi_shear_trigger", ability:GetLevel() - 1 )
	local damage_multi_flame_saber = ability:GetLevelSpecialValueFor("damage_multi_flame_saber", ability:GetLevel() - 1 )
	local damage_multi_punishment = ability:GetLevelSpecialValueFor("damage_multi_punishment", ability:GetLevel() - 1 )
	local damage_multi_lionheart = ability:GetLevelSpecialValueFor("damage_multi_lionheart", ability:GetLevel() - 1 )

	local damage_multi = 100
	local damage_multi_add = 0
	local modifier
	if caster:HasModifier("bvo_squall_skill_0_revolver_modifier") then
		modifier = "bvo_squall_skill_0_revolver_modifier"
		damage_multi_add = damage_multi_revolver
	elseif caster:HasModifier("bvo_squall_skill_0_shear_trigger_modifier") then
		modifier = "bvo_squall_skill_0_shear_trigger_modifier"
		damage_multi_add = damage_multi_shear_trigger
	elseif caster:HasModifier("bvo_squall_skill_0_flame_saber_modifier") then
		modifier = "bvo_squall_skill_0_flame_saber_modifier"
		damage_multi_add = damage_multi_flame_saber
	elseif caster:HasModifier("bvo_squall_skill_0_punishment_modifier") then
		modifier = "bvo_squall_skill_0_punishment_modifier"
		damage_multi_add = damage_multi_punishment
	elseif caster:HasModifier("bvo_squall_skill_0_lionheart_modifier") then
		modifier = "bvo_squall_skill_0_lionheart_modifier"
		damage_multi_add = damage_multi_lionheart
	end

	if modifier ~= nil then
		local current_stack = caster:GetModifierStackCount(modifier, ability)
		if current_stack - durability_cost > 0 then
			caster:SetModifierStackCount(modifier, ability, current_stack - durability_cost)
		else
			caster:RemoveModifierByName(modifier)
		end
	end

	local pull_ok = false
	if caster.limit_break_timing >= 13 and caster.limit_break_timing <= 15 then
		pull_ok = true
		damage_multi = damage_multi + damage_multi_add
	end

	caster:RemoveAbility("bvo_squall_skill_4_pull_trigger")
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK2, 3.0)

	local break_damage = ( ( agi_multi * caster:GetAgility() ) + ( str_multi * caster:GetStrength() ) ) * ( damage_multi / 100 )
	local targetArmor = caster.limit_break_target:GetPhysicalArmorValue()
	local damageReduction = ((0.06 * targetArmor) / (1 + 0.06 * targetArmor))
	local damagePostReduction = break_damage * (1 - damageReduction)

	if pull_ok then
		caster:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
		local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_blood.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( fxIndex, 1, caster.limit_break_target:GetAbsOrigin() )
	else
		caster:EmitSound("Hero_Axe.Attack")
	end

	if not caster.limit_break_target:HasModifier("item_doom_1_modifier_buff") then
		local new_health = caster.limit_break_target:GetHealth() - damagePostReduction
		if new_health <= 1 then
			caster.limit_break_target:Kill(ability, caster)
		else
			caster.limit_break_target:SetHealth(new_health)
		end
	end
end