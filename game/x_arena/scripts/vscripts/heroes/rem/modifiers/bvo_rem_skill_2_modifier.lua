bvo_rem_skill_2_modifier = class ({})

function bvo_rem_skill_2_modifier:IsBuff()
	return true
end

function bvo_rem_skill_2_modifier:IsHidden()
	return false
end

function bvo_rem_skill_2_modifier:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_purifyingflames.vpcf"
end

function bvo_rem_skill_2_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

function bvo_rem_skill_2_modifier:GetModifierConstantHealthRegen()
	return self.intellect * self.multiplier
end

function bvo_rem_skill_2_modifier:OnCreated( kv )
	if IsServer() then
		self.intellect = self:GetCaster():GetIntellect()
		self.multiplier = self:GetAbility():GetSpecialValueFor("heal_int_multi")
	end
end