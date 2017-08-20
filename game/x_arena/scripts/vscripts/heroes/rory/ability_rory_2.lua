function bvo_rory_skill_2( keys )
	local caster = keys.caster
	local ability = caster:FindAbilityByName("bvo_rory_skill_0")
	local max_stack_get = keys.ability:GetLevelSpecialValueFor("max_stack_get", keys.ability:GetLevel() - 1 )

	local particle = ParticleManager:CreateParticle("particles/items2_fx/soul_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(20, 0, 0))

	if not caster:HasModifier( "bvo_rory_skill_0_buff_modifier" ) then
		ability:ApplyDataDrivenModifier(caster, caster, "bvo_rory_skill_0_buff_modifier", {})
		caster:SetModifierStackCount( "bvo_rory_skill_0_buff_modifier", ability, max_stack_get )
	else
		local current_stack = caster:GetModifierStackCount( "bvo_rory_skill_0_buff_modifier", ability )
		caster:SetModifierStackCount( "bvo_rory_skill_0_buff_modifier", ability, current_stack + max_stack_get )

		local mods = caster:FindAllModifiers()
		for _,mod in pairs(mods) do
			if mod:GetName() == "bvo_rory_skill_0_buff_modifier" then
				mod:ForceRefresh()
				break
			end
		end
	end
end

function bvo_rory_skill_2_heal(keys)
	local caster = keys.caster
	local ability = keys.ability
	local SelfDamagePercent = ability:GetLevelSpecialValueFor("self_damage_percent", ability:GetLevel() - 1 )
	local OverTime = ability:GetLevelSpecialValueFor("over_time", ability:GetLevel() - 1 )

	local HealthRegenPercentPerSecond = SelfDamagePercent / OverTime
	
	if caster:IsRealHero() or caster:HasModifier("item_mirror_of_kalandra_illu_modifier")  then
		caster:Heal(caster:GetMaxHealth() * (HealthRegenPercentPerSecond / 100) * 0.03, caster)
	end
end