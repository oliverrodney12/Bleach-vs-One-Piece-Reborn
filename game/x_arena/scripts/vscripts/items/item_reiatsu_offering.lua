function item_reiatsu_offering( keys )
	local attacker = keys.attacker
	local ability = keys.ability
	local damage = keys.damage
	local manasteal = ability:GetLevelSpecialValueFor("manasteal", ability:GetLevel() - 1 ) * 0.01

	local particleName = "particles/custom/generic_manasteal.vpcf"
	local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControl(particle, 0, attacker:GetAbsOrigin())

	attacker:GiveMana( damage * manasteal )
end