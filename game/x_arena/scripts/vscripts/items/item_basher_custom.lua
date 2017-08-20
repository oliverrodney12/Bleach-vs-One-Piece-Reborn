function item_basher_custom( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ranged_stun = ability:GetLevelSpecialValueFor("ranged_stun", ability:GetLevel() - 1 )
	local melee_stun = ability:GetLevelSpecialValueFor("melee_stun", ability:GetLevel() - 1 )
	local melee_chance = ability:GetLevelSpecialValueFor("melee_chance", ability:GetLevel() - 1 )
	local ranged_chance = ability:GetLevelSpecialValueFor("ranged_chance", ability:GetLevel() - 1 )

	local chance = ranged_chance
	local dur = ranged_stun
	if caster:GetAttackCapability() == 1 then
		chance = melee_chance
		dur = melee_stun
	end

	local roll = RandomInt(1, 100)
	if roll <= chance then
		if caster:IsRealHero() or caster:HasModifier("item_mirror_of_kalandra_illu_modifier") then
			if ability:IsCooldownReady() then
				ability:StartCooldown(ability:GetCooldown( ability:GetLevel() - 1 ))
				ability:ApplyDataDrivenModifier(caster, target, "item_basher_custom_stun_modifier", {duration=dur})
			end
		end
	end
end