function bvo_orihime_skill_2_track(keys)
	local ability = keys.ability
	local target = ability.target
	
	if target ~= nil then
		ability.bvo_orihime_skill_2_hp_old = ability.bvo_orihime_skill_2_hp_old or target:GetMaxHealth()
		ability.bvo_orihime_skill_2_hp = ability.bvo_orihime_skill_2_hp or target:GetMaxHealth()

		ability.bvo_orihime_skill_2_hp_old = ability.bvo_orihime_skill_2_hp
		ability.bvo_orihime_skill_2_hp = target:GetHealth()
	end
end