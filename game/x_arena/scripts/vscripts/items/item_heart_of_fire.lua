function item_heart_of_fire(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local degen = ability:GetLevelSpecialValueFor("degen", 0 )

	if caster:IsRealHero() or caster:HasModifier("item_mirror_of_kalandra_illu_modifier") then
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = caster:GetMaxHealth() * (degen / 100) * 0.03,
			damage_type = DAMAGE_TYPE_PURE,
		}
		ApplyDamage(damageTable)
	end
end