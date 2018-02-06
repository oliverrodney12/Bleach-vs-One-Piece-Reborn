function bvo_perona_skill_5( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local extraHealth = ability:GetLevelSpecialValueFor("extra_health", ability:GetLevel() - 1 )

	if caster.summons == nil then caster.summons = {} end

	local abilityLevel = ability:GetLevel()

	target:SetBaseMaxHealth(target:GetMaxHealth() + extraHealth)
	target:SetHealth(target:GetMaxHealth())

	target:GetAbilityByIndex(1):SetLevel(abilityLevel)

	table.insert(caster.summons, target)
end