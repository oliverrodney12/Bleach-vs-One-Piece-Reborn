bvo_squall_skill_5_caster = class ({})

function bvo_squall_skill_5_caster:IsHidden()
	return false
end

function bvo_squall_skill_5_caster:IsDebuff()
	return true
end

function bvo_squall_skill_5_caster:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
 
	return state
end

function bvo_squall_skill_5_caster:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()

		local modifier
		if caster:HasModifier("bvo_squall_skill_0_revolver_modifier") then
			modifier = "bvo_squall_skill_0_revolver_modifier"
		elseif caster:HasModifier("bvo_squall_skill_0_shear_trigger_modifier") then
			modifier = "bvo_squall_skill_0_shear_trigger_modifier"
		elseif caster:HasModifier("bvo_squall_skill_0_flame_saber_modifier") then
			modifier = "bvo_squall_skill_0_flame_saber_modifier"
		elseif caster:HasModifier("bvo_squall_skill_0_punishment_modifier") then
			modifier = "bvo_squall_skill_0_punishment_modifier"
		elseif caster:HasModifier("bvo_squall_skill_0_lionheart_modifier") then
			modifier = "bvo_squall_skill_0_lionheart_modifier"
		end

		if modifier ~= nil then
			caster:RemoveModifierByName(modifier)
		end

		caster:SetAngles(0, 0, 0)
	end
end

