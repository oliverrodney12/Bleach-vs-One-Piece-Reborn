modifier_bvohero = class({})

local PrevGoldLostToDeath = 0

function modifier_bvohero:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_bvohero:IsHidden()
	return true
end

function modifier_bvohero:IsBuff()
	return true
end

function modifier_bvohero:IsPurgable()
	return false
end

function modifier_bvohero:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
	}
 
	return funcs
end

function modifier_bvohero:OnDeath(kv)
	if IsServer() then
		local caster = self:GetCaster()
		local unit = kv.unit

		if caster == unit and unit:IsRealHero() then
			local gold_deathCost = PlayerResource:GetGoldLostToDeath(caster:GetPlayerID()) - PrevGoldLostToDeath
			PrevGoldLostToDeath = PlayerResource:GetGoldLostToDeath(caster:GetPlayerID())
			local gold_unreliable = PlayerResource:GetUnreliableGold(caster:GetPlayerID())

			PlayerResource:ModifyGold(caster:GetPlayerID(), gold_deathCost, true, 0)
		end
	end
end