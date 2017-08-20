function item_barrier_stone( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local particleName = keys.Particle
	local health_per_int = ability:GetLevelSpecialValueFor("health_per_int", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )

	target:EmitSound("Hero_Medusa.ManaShield.On")
	ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)

	if not target:HasModifier("item_barrier_stone_modifier") then
		ability:ApplyDataDrivenModifier(caster, target, "item_barrier_stone_modifier", {duration=duration})
	end

	local current_stack = target:GetModifierStackCount( "item_barrier_stone_modifier", ability )
	target:SetModifierStackCount( "item_barrier_stone_modifier", ability, current_stack + caster:GetIntellect() )
	target:Heal(health_per_int * caster:GetIntellect(), caster)
end