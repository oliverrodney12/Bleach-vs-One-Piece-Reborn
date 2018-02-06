modifier_creepbuff = class({})

local stacks = 0

function modifier_creepbuff:IsHidden()
	return true
end

function modifier_creepbuff:IsBuff()
	return true
end

function modifier_creepbuff:IsPurgable()
	return false
end

function modifier_creepbuff:OnCreated(kv)
	if IsServer() then
		stacks = math.floor(self:GetCreationTime() / 60)

		local caster = self:GetCaster()

		caster:SetMinimumGoldBounty(caster:GetMinimumGoldBounty() + (stacks * 1))
		caster:SetMaximumGoldBounty(caster:GetMaximumGoldBounty() + (stacks * 1))

		caster:SetBaseMaxHealth(caster:GetMaxHealth() + (stacks * 40))
		caster:SetHealth(caster:GetMaxHealth())

		--caster:SetModelScale(1.0 + 0.01 * stacks)
	end
end

function modifier_creepbuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
	}
 
	return funcs
end

function modifier_creepbuff:GetModifierBaseAttack_BonusDamage( params )
	return 4 * stacks
end