function bvo_perona_skill_3( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if caster.summons ~= nil then
		for _,unit in pairs(caster.summons) do
			FindClearSpaceForUnit(unit, caster:GetAbsOrigin(), false)
		end
	end
end