function item_emperor_maximillian_bladebane_armor_ai(keys)
	local caster = keys.caster
	local ability = keys.ability

	if caster:GetClassname() == "npc_dota_hero_brewmaster" then
		if ability:IsCooldownReady() then
			--cast if some1 is nearby
			local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
			            caster:GetAbsOrigin(),
			            nil,
			            425,
			            DOTA_UNIT_TARGET_TEAM_ENEMY,
			            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			            FIND_ANY_ORDER,
			            false)

			if #localUnits > 0 then
				caster:CastAbilityNoTarget(ability, caster:GetPlayerID())
			end
		end
	end
end