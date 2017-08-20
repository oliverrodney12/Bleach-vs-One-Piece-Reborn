function spell_ai( keys )
	local caster = keys.caster
	local ability = keys.ability

	localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            1200,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		if ability:IsCooldownReady() and ( caster:GetAbsOrigin() - unit:GetAbsOrigin() ):Length2D() > 250 and not caster:IsSilenced() and not caster:IsStunned() then
			caster:CastAbilityOnTarget(unit, ability, caster:GetTeamNumber())
		end
	end
end

function Leap( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	ability:StartCooldown(12.0)
	ProjectileManager:ProjectileDodge(caster)

	ability.leap_direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()

	local difference = target:GetAbsOrigin() - caster:GetAbsOrigin()

	ability.leap_distance = difference:Length2D()

	ability.leap_speed = 700 * 1/30
	ability.leap_traveled = 0
	ability.leap_z = 0
end

function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		caster:InterruptMotionControllers(true)
		localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		            caster:GetAbsOrigin(),
		            nil,
		            400,
		            DOTA_UNIT_TARGET_TEAM_ENEMY,
		            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		            FIND_ANY_ORDER,
		            false)

		for _,unit in pairs(localUnits) do
			local damageTable = {
				victim = unit,
				attacker = caster,
				damage = 2500,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage(damageTable)
			ability:ApplyDataDrivenModifier(caster, unit, "boss_maximillian_bladebane_skill_2_slow_modifier", {duration=2.0})
		end
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 0, Vector(475, 0, 475))
		caster:EmitSound("Hero_Centaur.HoofStomp")
		caster:RemoveModifierByName("boss_maximillian_bladebane_skill_2_freeze_modifier")
	end
end

function LeapVertical( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance/2 then
		ability.leap_z = ability.leap_z + ability.leap_speed/2
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	else
		ability.leap_z = ability.leap_z - ability.leap_speed/2
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	end
end