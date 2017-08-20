modifier_lostduel = class({})

function modifier_lostduel:IsHidden()
	return false
end

function modifier_lostduel:IsDebuff()
	return true
end

function modifier_lostduel:IsPurgable()
	return false
end