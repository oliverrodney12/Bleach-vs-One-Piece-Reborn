function bvo_soifon_skill_1(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetLevelSpecialValueFor("bonus_damage", ability:GetLevel() - 1 )

	if ability:IsCooldownReady() then
		ability:StartCooldown( ability:GetCooldown( ability:GetLevel() - 1 ) )

		ability:ApplyDataDrivenModifier(caster, target, "bvo_soifon_skill_1_stun_modifier", {duration=0.1})
		ability:ApplyDataDrivenModifier(caster, caster, "bvo_soifon_skill_1_crit_modifier", {})

		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		ApplyDamage(damageTable)
	end
end