bvo_special_bonus_damage_75_modifier = class ({})

function bvo_special_bonus_damage_75_modifier:IsHidden()
	return true
end

function bvo_special_bonus_damage_75_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
 
	return funcs
end

function bvo_special_bonus_damage_75_modifier:GetModifierPreAttack_BonusDamage( params )
	return 75
end