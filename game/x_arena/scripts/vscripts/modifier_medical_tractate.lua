modifier_medical_tractate = class({})

function modifier_medical_tractate:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
 
	return funcs
end

function modifier_medical_tractate:GetAttributes()
	local attrs = {
			MODIFIER_ATTRIBUTE_PERMANENT,
		}

	return attrs
end

function modifier_medical_tractate:AllowIllusionDuplicate()
	return true
end

function modifier_medical_tractate:IsHidden()
	return true
end

function modifier_medical_tractate:IsPurgable()
	return false
end

function modifier_medical_tractate:GetModifierHealthBonus(params)
	if self:GetCaster():IsIllusion() then
		return 0
	else
		local stacks = self:GetCaster().medical_tractates
		if not stacks then return 0 end
		return self.health_bonus*stacks
	end
end

function modifier_medical_tractate:OnCreated(event)
	if IsServer() then
		self.health_bonus = 35;
	end
end