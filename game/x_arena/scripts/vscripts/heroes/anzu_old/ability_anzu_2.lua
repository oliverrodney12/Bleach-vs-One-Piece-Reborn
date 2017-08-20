function bvo_anzu_skill_2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local particle = ParticleManager:CreateParticle("particles/items2_fx/mekanism.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())

	caster:EmitSound("DOTA_Item.Mekansm.Target")

	if caster.c_target1 == nil then
		caster.c_target1 = target
	elseif caster.c_target2 == nil then
		caster.c_target2 = target
	else
		caster.c_target3 = target
	end
end