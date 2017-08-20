require('timers')

function item_orb_of_lightning(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("zeus_damage", ability:GetLevel() - 1 )
	local jumps = ability:GetLevelSpecialValueFor("zeus_jumps", ability:GetLevel() - 1 )
	local leap_radius = ability:GetLevelSpecialValueFor("zeus_leap_radius", ability:GetLevel() - 1 )
	local int_multi = ability:GetLevelSpecialValueFor("int_multi", ability:GetLevel() - 1 )

	if caster:IsIllusion() and not caster:HasModifier("item_mirror_of_kalandra_illu_modifier") then return end
	if not ability:IsCooldownReady() then return end
	ability:StartCooldown(ability:GetCooldown( ability:GetLevel() - 1 ))

	local hit_units = {}
	table.insert(hit_units, target)
	
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage + ( caster:GetIntellect() * int_multi ),
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage(damageTable)

	target:EmitSound("Hero_Zuus.ArcLightning.Cast")
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))   
	ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))

	Timers:CreateTimer(0.2, function()
		item_orb_of_lightning_chain(caster, target, jumps - 1, damage, hit_units, leap_radius, int_multi)
	end)
end

function item_orb_of_lightning_chain(caster, target, jumps, damage, hit_units, leap_radius, multi)
	jumps = jumps - 1

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
					damage = damage + ( caster:GetIntellect() * multi ),
					damage_type = DAMAGE_TYPE_MAGICAL,
				}
				ApplyDamage(damageTable)

				target:EmitSound("Hero_Zuus.ArcLightning.Cast")
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(particle, 0, Vector(unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, unit:GetAbsOrigin().z + unit:GetBoundingMaxs().z ))   
				ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))

				target = unit
				table.insert(hit_units, unit)
				break
			end
		end
	end

	if #localUnits == 1 and localUnits[1] == target then jumps = 0 end

	if jumps > 0 then
		Timers:CreateTimer(0.2, function()
			item_orb_of_lightning_chain(caster, target, jumps, damage, hit_units, leap_radius, multi)
		end)
	end
end