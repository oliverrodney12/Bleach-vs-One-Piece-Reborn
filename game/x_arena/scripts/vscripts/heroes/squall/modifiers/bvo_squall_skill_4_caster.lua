bvo_squall_skill_4_caster = class ({})

function bvo_squall_skill_4_caster:IsHidden()
	return false
end

function bvo_squall_skill_4_caster:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
 
	return state
end

function bvo_squall_skill_4_caster:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()

		caster:RemoveAbility("bvo_squall_skill_4_pull_trigger")

		while caster:FindAbilityByName("bvo_squall_skill_4_empty") ~= nil do
			caster:RemoveAbility("bvo_squall_skill_4_empty")
		end

		local squall_skill_1 = caster:AddAbility("bvo_squall_skill_1")
		squall_skill_1:SetLevel(caster.squall_skill_1)
		
		local squall_skill_2 = caster:AddAbility("bvo_squall_skill_2")
		squall_skill_2:SetLevel(caster.squall_skill_2)
		
		local squall_skill_3 = caster:AddAbility("bvo_squall_skill_3")
		squall_skill_3:SetLevel(caster.squall_skill_3)

		caster:FindAbilityByName("bvo_squall_skill_4"):SetHidden(false)

		local squall_skill_5 = caster:AddAbility("bvo_squall_skill_5")
		squall_skill_5:SetLevel(caster.squall_skill_5)

		local squall_skill_0 = caster:AddAbility("bvo_squall_skill_0")
		squall_skill_0:SetLevel(caster.squall_skill_0)
		
		caster:AddNewModifier(caster, self, "bvo_squall_skill_4_limit_modifier", {duration=4.0})
	end
end

