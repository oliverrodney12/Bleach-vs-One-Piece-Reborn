bvo_special_bonus_lifesteal_10_modifier = class ({})

function bvo_special_bonus_lifesteal_10_modifier:IsHidden()
	return true
end

function bvo_special_bonus_lifesteal_10_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
 
	return funcs
end

function bvo_special_bonus_lifesteal_10_modifier:OnAttackLanded( params )
	if IsServer() then
		local attacker = params.attacker
		if attacker:HasModifier("bvo_special_bonus_lifesteal_10_modifier") then
			local healGained = params.damage * 0.05
			attacker:Heal( healGained, nil)
			
			local particleName = "particles/generic_gameplay/generic_lifesteal.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:SetParticleControl(particle, 0, attacker:GetAbsOrigin())

			SendOverheadEventMessage(attacker, OVERHEAD_ALERT_HEAL, attacker, healGained, nil)
			--_G:PopupNumbers(attacker, "heal", Vector(0, 255, 0), 1.0, healGained, nil, nil, false)
		end
	end
end