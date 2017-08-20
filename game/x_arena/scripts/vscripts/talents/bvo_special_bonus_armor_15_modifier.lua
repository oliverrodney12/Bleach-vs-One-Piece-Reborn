bvo_special_bonus_armor_15_modifier = class ({})

function bvo_special_bonus_armor_15_modifier:IsHidden()
	return true
end

function bvo_special_bonus_armor_15_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
 
	return funcs
end

function bvo_special_bonus_armor_15_modifier:GetModifierPhysicalArmorBonus( params )
	return 15
end