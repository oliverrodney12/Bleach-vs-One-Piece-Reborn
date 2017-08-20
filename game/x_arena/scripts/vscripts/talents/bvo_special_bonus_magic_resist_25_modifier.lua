bvo_special_bonus_magic_resist_25_modifier = class ({})

function bvo_special_bonus_magic_resist_25_modifier:IsHidden()
	return true
end

function bvo_special_bonus_magic_resist_25_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
 
	return funcs
end

function bvo_special_bonus_magic_resist_25_modifier:GetModifierMagicalResistanceBonus( params )
	return 30
end