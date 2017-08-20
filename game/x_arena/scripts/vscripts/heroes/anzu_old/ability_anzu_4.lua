function bvo_anzu_skill_4( keys )
	local caster = keys.caster

	for abilitySlot = 0, 2 do
		local ability = caster:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			ability:EndCooldown()
		end
	end
end