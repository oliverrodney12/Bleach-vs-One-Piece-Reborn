bvo_special_bonus_reduced_damage_10_modifier = class ({})

function bvo_special_bonus_reduced_damage_10_modifier:IsHidden()
	return true
end

function bvo_special_bonus_reduced_damage_10_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
 
	return funcs
end

function bvo_special_bonus_reduced_damage_10_modifier:GetModifierIncomingDamage_Percentage( params )
	return -10
end