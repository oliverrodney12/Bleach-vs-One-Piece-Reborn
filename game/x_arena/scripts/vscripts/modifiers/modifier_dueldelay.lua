modifier_dueldelay = class({})

function modifier_dueldelay:IsHidden()
	return false
end

function modifier_dueldelay:IsBuff()
	return true
end

function modifier_dueldelay:IsPurgable()
	return false
end

function modifier_dueldelay:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
 
	return funcs
end

function modifier_dueldelay:GetModifierIncomingDamage_Percentage( params )
	return -100
end