function item_greater_stone_of_essence(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local int_multi = ability:GetLevelSpecialValueFor("int_multi", ability:GetLevel() - 1 )
	local damage = caster:GetIntellect() * int_multi

	if caster:IsIllusion() and not caster:HasModifier("item_mirror_of_kalandra_illu_modifier") then return end
	if not target:HasModifier("item_greater_stone_of_essence_debuff_modifier") then return end
	
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damageTable)

	local particleName = "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf"
	local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	target:EmitSound("Hero_Zuus.StaticField")
end