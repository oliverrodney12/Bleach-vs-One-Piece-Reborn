bvo_special_bonus_attack_speed_80_modifier = class ({})

function bvo_special_bonus_attack_speed_80_modifier:IsHidden()
	return true
end

function bvo_special_bonus_attack_speed_80_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
 
	return funcs
end

function bvo_special_bonus_attack_speed_80_modifier:GetModifierAttackSpeedBonus_Constant( params )
	return 80
end