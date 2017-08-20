bvo_special_bonus_evasion_15_modifier = class ({})

function bvo_special_bonus_evasion_15_modifier:IsHidden()
	return true
end

function bvo_special_bonus_evasion_15_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
	}
 
	return funcs
end

function bvo_special_bonus_evasion_15_modifier:GetModifierEvasion_Constant( params )
	return 15
end