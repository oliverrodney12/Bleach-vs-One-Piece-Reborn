modifier_induel = class({})

function modifier_induel:IsHidden()
	return false
end

function modifier_induel:IsDebuff()
	return true
end

function modifier_induel:IsPurgable()
	return false
end

function modifier_induel:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
	}
 
	return funcs
end

function modifier_induel:OnDeath( params )
	if IsServer() then
		params.unit.lostDuel = true
	end
	return 0
end