function bvo_anzu_skill_1( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1 )

	local particle = ParticleManager:CreateParticle("particles/neutral_fx/ursa_thunderclap.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 1, Vector(radius*2, radius*2, radius*2))

	caster:EmitSound("Hero_Brewmaster.ThunderClap")

	if caster.c_target1 == nil then
		caster.c_target1 = target
	elseif caster.c_target2 == nil then
		caster.c_target2 = target
	else
		caster.c_target3 = target
	end
end