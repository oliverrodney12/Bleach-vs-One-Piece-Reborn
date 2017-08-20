function bvo_anzu_skill_qqw( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )

	--caster:EmitSound("Hero_Warlock.FatalBonds")

	caster.c_target1.anzu_qqw_target = caster.c_target3
	caster.c_target2.anzu_qqw_target = caster.c_target3

	caster.c_target3.anzu_qqw_source1 = caster.c_target1
	caster.c_target3.anzu_qqw_source2 = caster.c_target2

	ability:ApplyDataDrivenModifier(caster, caster.c_target1, "bvo_anzu_skill_QQW_modifier", {duration=duration})
	ability:ApplyDataDrivenModifier(caster, caster.c_target2, "bvo_anzu_skill_QQW_modifier", {duration=duration})
	ability:ApplyDataDrivenModifier(caster, caster.c_target3, "bvo_anzu_skill_QQW_target_modifier", {duration=duration})
end

function bvo_anzu_skill_qqw_heal( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	local percent = ability:GetLevelSpecialValueFor("percent", ability:GetLevel() - 1 )
	local damage = keys.Damage
	local damagePercent = percent / 100

	if attacker.anzu_qqw_target ~= nil and attacker.anzu_qqw_target:IsAlive() then
		attacker.anzu_qqw_target:Heal(damage * damagePercent, ability)

		local particleName = "particles/generic_gameplay/generic_lifesteal.vpcf"
		local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, attacker.anzu_qqw_target)
		ParticleManager:SetParticleControl(particle, 0, attacker:GetAbsOrigin())
	end
end

function bvo_anzu_skill_qqw_end( keys )
	local target = keys.target

	target.anzu_qqw_target = nil
end

function bvo_anzu_skill_qqw_source_end( keys )
	local target = keys.target

	if target ~= nil and not target:IsNull() then
		if target.anzu_qqw_source1 ~= nil and not target.anzu_qqw_source1:IsNull() then
			target.anzu_qqw_source1:RemoveModifierByName("bvo_anzu_skill_QQW_modifier")
		end
	end
	if target ~= nil and not target:IsNull() then
		if target.anzu_qqw_source2 ~= nil and not target.anzu_qqw_source2:IsNull() then
			target.anzu_qqw_source2:RemoveModifierByName("bvo_anzu_skill_QQW_modifier")
		end
	end

	target.anzu_qqw_source1 = nil
	target.anzu_qqw_source2 = nil
end