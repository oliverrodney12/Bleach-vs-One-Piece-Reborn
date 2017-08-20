function bvo_anzu_skill_4(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )

	caster:EmitSound("BleachVsOnePieceReborn.AnzuSkill4")

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            radius,
	            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	            DOTA_UNIT_TARGET_HERO,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		unit:EmitSound("Hero_TemplarAssassin.Trap.Trigger")

		ability:ApplyDataDrivenModifier(caster, unit, "bvo_anzu_skill_4_effect_modifier", {duration=duration})
		unit:SetModifierStackCount( "bvo_anzu_skill_4_effect_modifier", ability, #localUnits )
	end
end