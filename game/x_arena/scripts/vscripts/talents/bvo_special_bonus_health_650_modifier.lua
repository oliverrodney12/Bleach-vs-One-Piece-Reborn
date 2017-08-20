bvo_special_bonus_health_650_modifier = class ({})

function bvo_special_bonus_health_650_modifier:IsHidden()
	return true
end

function bvo_special_bonus_health_650_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
 
	return funcs
end

function bvo_special_bonus_health_650_modifier:GetModifierHealthBonus( params )
	return 650
end