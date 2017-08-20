function item_dragon_lance_custom( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if caster:GetAttackCapability() == 1 then return end
	if caster:IsIllusion() and not caster:HasModifier("item_mirror_of_kalandra_illu_modifier") then return end

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            target:GetAbsOrigin(),
	            nil,
	            275,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	if ability:IsCooldownReady() then
		if #localUnits > 1 then
			ability:StartCooldown(caster:GetSecondsPerAttack())
		end
	
		for _,unit in pairs(localUnits) do
			if unit ~= target then
				caster:PerformAttack(unit, false, false, true, true, true, false, true)
				break
			end
		end
	end
end