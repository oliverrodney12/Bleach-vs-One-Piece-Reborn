function mimic_spawn( keys )
	local caster = keys.caster
	local ability = keys.ability

	local neutralUnits = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,
              Vector(0, 0, 0),
              nil,
              FIND_UNITS_EVERYWHERE,
              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
              DOTA_UNIT_TARGET_ALL,
              DOTA_UNIT_TARGET_FLAG_NONE,
              FIND_ANY_ORDER,
              false)

	local guards = 0
	for _,unit in pairs(neutralUnits) do
		if unit.unitName ~= nil and unit.unitName == "npc_dota_demon_guard" then
			ability:ApplyDataDrivenModifier(caster, unit, "bvo_mimic_guard_leash_modifier", {} )
			guards = guards + 1
		end
	end
	if guards > 0 then
		ability:ApplyDataDrivenModifier(caster, caster, "bvo_mimic_guard_buff_modifier", {} )
	end
end

function mimic_guard_die( keys )
	local caster = keys.caster

	local neutralUnits = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,
              Vector(0, 0, 0),
              nil,
              FIND_UNITS_EVERYWHERE,
              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
              DOTA_UNIT_TARGET_ALL,
              DOTA_UNIT_TARGET_FLAG_NONE,
              FIND_ANY_ORDER,
              false)

	local guards = 0
	for _,unit in pairs(neutralUnits) do
		if unit.unitName ~= nil and unit.unitName == "npc_dota_demon_guard" then
			guards = guards + 1
		end
	end
	if guards == 0 then
		caster:RemoveModifierByName("bvo_mimic_guard_buff_modifier")
	end
end