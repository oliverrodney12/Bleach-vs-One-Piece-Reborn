require('timers')

function item_elemental_conflux(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("chain_damage", ability:GetLevel() - 1 )
	local jumps = ability:GetLevelSpecialValueFor("chain_jumps", ability:GetLevel() - 1 )
	local leap_radius = ability:GetLevelSpecialValueFor("chain_leap", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("chain_multi", ability:GetLevel() - 1 )
	local frost_stun = ability:GetLevelSpecialValueFor("frost_stun", ability:GetLevel() - 1 )
	local burn_duration = ability:GetLevelSpecialValueFor("burn_duration", ability:GetLevel() - 1 )

	if caster:IsIllusion() and not caster:HasModifier("item_mirror_of_kalandra_illu_modifier") then return end
	if not ability:IsCooldownReady() then return end
	ability:StartCooldown(ability:GetCooldown( ability:GetLevel() - 1 ))

	local hit_units = {}
	table.insert(hit_units, target)
	
	local primary = caster:GetPrimaryAttribute()
	local stats = caster:GetIntellect() 
	if primary == 0 then stats = caster:GetStrength()
	elseif primary == 1 then stats = caster:GetAgility() end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage + ( stats * multi ),
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage(damageTable)

	target:EmitSound("Hero_Zuus.ArcLightning.Cast")
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))

	target:EmitSound("Hero_Invoker.SunStrike.Ignite")
	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle2, 0, Vector(75, 0, 0))

	ability:ApplyDataDrivenModifier(caster, target, "item_elemental_conflux_freeze_modifier", {duration=frost_stun})
	ability:ApplyDataDrivenModifier(caster, target, "item_elemental_conflux_burn_modifier", {duration=burn_duration})

	Timers:CreateTimer(0.2, function()
		item_elemental_conflux_chain(caster, target, jumps - 1, hit_units, ability)
	end)
end

function item_elemental_conflux_chain(caster, target, jumps, hit_units, ability)
	jumps = jumps - 1

	local damage = ability:GetLevelSpecialValueFor("chain_damage", ability:GetLevel() - 1 )
	local leap_radius = ability:GetLevelSpecialValueFor("chain_leap", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("chain_multi", ability:GetLevel() - 1 )
	local frost_stun = ability:GetLevelSpecialValueFor("frost_stun", ability:GetLevel() - 1 )
	local burn_duration = ability:GetLevelSpecialValueFor("burn_duration", ability:GetLevel() - 1 )

	local primary = caster:GetPrimaryAttribute()
	local stats = caster:GetIntellect() 
	if primary == 0 then stats = caster:GetStrength()
	elseif primary == 1 then stats = caster:GetAgility() end

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            target:GetAbsOrigin(),
	            nil,
	            leap_radius,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
	            FIND_ANY_ORDER,
	            false)

	if #localUnits > 0 then
		for _,unit in pairs(localUnits) do

			local hit_check = false

			for _,hit in pairs(hit_units) do
				if unit == hit then
					hit_check = true
					break
				end
			end

			if not hit_check then
				local damageTable = {
					victim = unit,
					attacker = caster,
					damage = damage + ( stats * multi ),
					damage_type = DAMAGE_TYPE_MAGICAL,
				}
				ApplyDamage(damageTable)

				target:EmitSound("Hero_Zuus.ArcLightning.Cast")
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(particle, 0, Vector(unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, unit:GetAbsOrigin().z + unit:GetBoundingMaxs().z ))   
				ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))

				unit:EmitSound("Hero_Invoker.SunStrike.Ignite")
				local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
				ParticleManager:SetParticleControl(particle2, 0, Vector(75, 0, 0))

				ability:ApplyDataDrivenModifier(caster, unit, "item_elemental_conflux_freeze_modifier", {duration=frost_stun})
				ability:ApplyDataDrivenModifier(caster, unit, "item_elemental_conflux_burn_modifier", {duration=burn_duration})

				target = unit
				table.insert(hit_units, unit)
				break
			end
		end
	end

	if #localUnits == 1 and localUnits[1] == target then jumps = 0 end

	if jumps > 0 then
		Timers:CreateTimer(0.2, function()
			item_elemental_conflux_chain(caster, target, jumps, hit_units, ability)
		end)
	end
end

function item_elemental_conflux_burn( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local burn_dps_multi = ability:GetLevelSpecialValueFor("burn_dps_multi", ability:GetLevel() - 1 )

	local primary = caster:GetPrimaryAttribute()
	local stats = caster:GetIntellect() 
	if primary == 0 then stats = caster:GetStrength()
	elseif primary == 1 then stats = caster:GetAgility() end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = ( stats * burn_dps_multi ) / 2,
		damage_type = DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damageTable)
end