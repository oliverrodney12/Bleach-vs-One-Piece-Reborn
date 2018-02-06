function bvo_akainu_skill_0(keys)
	local caster = keys.caster
	local ability = keys.ability
	local attacker = keys.attacker
	local reflect = ability:GetLevelSpecialValueFor("reflect", (ability:GetLevel() - 1)) / 100

	if not attacker:IsMagicImmune() then
		local damageTable = {
			victim = attacker,
			attacker = caster,
			damage = attacker:GetHealth() * reflect,
			damage_type = DAMAGE_TYPE_PURE,
		}
		ApplyDamage(damageTable)
	end
end