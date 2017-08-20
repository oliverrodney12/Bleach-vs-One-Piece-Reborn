function bvo_anzu_skill_0( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1 )
	local duration_debuff = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )
	local dur_per_hero = ability:GetLevelSpecialValueFor("dur_per_hero", ability:GetLevel() - 1 )
	local dur_per_creep = ability:GetLevelSpecialValueFor("dur_per_creep", ability:GetLevel() - 1 )

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            radius,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
	            FIND_ANY_ORDER,
	            false)

	local duration_buff = 1
	for _,unit in pairs(localUnits) do
		if unit:IsHero() then
			duration_buff = duration_buff + dur_per_hero
		else
			duration_buff = duration_buff + dur_per_creep
		end
		ability:ApplyDataDrivenModifier(caster, unit, "bvo_anzu_skill_0_debuff_modifier", {duration=duration_debuff})
	end
	ability:ApplyDataDrivenModifier(caster, caster, "bvo_anzu_skill_0_buff_modifier", {duration=duration_buff})
end