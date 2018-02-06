function bvo_perona_skill_ghost_phase( keys )
	local caster = keys.caster
	local ability = keys.ability

	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            350,
	            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		if unit:HasAbility("bvo_perona_skill_ghost_phase") then
			local abl = unit:GetAbilityByIndex(0)
			if abl:IsCooldownReady() then
				abl:StartCooldown(cooldown)
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_phased", {duration=10.0})
			end
		end
	end
end