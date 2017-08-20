function bvo_rem_skill_3(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local fissure_range = ability:GetLevelSpecialValueFor("fissure_range", (ability:GetLevel() -1))
	local fissure_radius = ability:GetLevelSpecialValueFor("fissure_radius", (ability:GetLevel() -1))
	local fissure_duration = ability:GetLevelSpecialValueFor("fissure_duration", (ability:GetLevel() -1))
	local offset = ability:GetLevelSpecialValueFor("offset", (ability:GetLevel() -1))

	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", (ability:GetLevel() -1))
	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() -1))
	local multi = ability:GetLevelSpecialValueFor("str_multi", (ability:GetLevel() -1))
	
	-- Position and direction variables
	local direction = caster:GetForwardVector()
	local startPos = caster:GetAbsOrigin() + direction * offset
	local endPos = caster:GetAbsOrigin() + direction * fissure_range
	
	-- Renders the fissure particle in a line
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_fissure.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, startPos)
	ParticleManager:SetParticleControl(particle, 1, endPos)
	ParticleManager:SetParticleControl(particle, 2, Vector(fissure_duration, 0, 0 ))

	-- Units to be stunned and damaged by the fissure
	local units = FindUnitsInLine(caster:GetTeam(), startPos, endPos, nil, fissure_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
	
	-- Loops through the targets
	for j,unit in ipairs(units) do
		-- Applies the stun modifier to the target
		ability:ApplyDataDrivenModifier(caster, unit, "bvo_rem_skill_3_modifier", {duration=stun_duration})
		-- Applies the damage to the target
		ApplyDamage({
			victim = unit,
			attacker = caster,
			damage = damage + caster:GetStrength() * multi,
			damage_type = DAMAGE_TYPE_PHYSICAL
		})
	end
end