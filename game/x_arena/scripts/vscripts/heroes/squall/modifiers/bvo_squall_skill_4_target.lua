bvo_squall_skill_4_target = class ({})

function bvo_squall_skill_4_target:IsHidden()
	return false
end

function bvo_squall_skill_4_target:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
 
	return state
end