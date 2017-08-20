require('timers')

function item_vayus_lightning_quiver( keys )
	local caster = keys.caster
	local ability = keys.ability
	local hit_radius = ability:GetLevelSpecialValueFor("hit_radius", 0 )
	local hit_damage = ability:GetLevelSpecialValueFor("hit_damage", 0 )
	local radius = ability:GetLevelSpecialValueFor("radius", 0 )
	local chain_leap = ability:GetLevelSpecialValueFor("chain_leap", 0 )
	local int_multi = ability:GetLevelSpecialValueFor("int_multi", 0 )
	local agi_multi = ability:GetLevelSpecialValueFor("agi_multi", 0 )

	if not ability:IsCooldownReady() then return end
	if caster:IsIllusion() and not caster:HasModifier("item_mirror_of_kalandra_illu_modifier") then return end

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            radius,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
	            FIND_CLOSEST,
	            false)

	if #localUnits > 0 then
		ability:StartCooldown(ability:GetCooldown(0))
		for _,unit in pairs(localUnits) do
			local castpoint = unit:GetAbsOrigin()
			
			if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
				local tell = ParticleManager:CreateParticleForTeam("particles/custom/items/item_vayus_quiver/vayus_quiver_tell.vpcf", PATTACH_WORLDORIGIN, caster, DOTA_TEAM_GOODGUYS)
				ParticleManager:SetParticleControl(tell , 0, castpoint)
				ParticleManager:SetParticleControl(tell , 1, Vector(hit_radius, 0, 100))

				local tellbad = ParticleManager:CreateParticleForTeam("particles/custom/items/item_vayus_quiver/vayus_quiver_tell_bad.vpcf", PATTACH_WORLDORIGIN, caster, DOTA_TEAM_BADGUYS)
				ParticleManager:SetParticleControl(tellbad , 0, castpoint)
				ParticleManager:SetParticleControl(tellbad , 1, Vector(hit_radius, 0, 100))
			elseif caster:GetTeam() == DOTA_TEAM_BADGUYS then
				local tell = ParticleManager:CreateParticleForTeam("particles/custom/items/item_vayus_quiver/vayus_quiver_tell.vpcf", PATTACH_WORLDORIGIN, caster, DOTA_TEAM_BADGUYS)
				ParticleManager:SetParticleControl(tell , 0, castpoint)
				ParticleManager:SetParticleControl(tell , 1, Vector(hit_radius, 0, 100))

				local tellbad = ParticleManager:CreateParticleForTeam("particles/custom/items/item_vayus_quiver/vayus_quiver_tell_bad.vpcf", PATTACH_WORLDORIGIN, caster, DOTA_TEAM_GOODGUYS)
				ParticleManager:SetParticleControl(tellbad , 0, castpoint)
				ParticleManager:SetParticleControl(tellbad , 1, Vector(hit_radius, 0, 100))
			else
				local tell = ParticleManager:CreateParticle("particles/custom/items/item_vayus_quiver/vayus_quiver_tell.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(tell , 0, castpoint)
				ParticleManager:SetParticleControl(tell , 1, Vector(hit_radius, 0, 100))
			end

			Timers:CreateTimer(1.0, function ()
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(particle, 0, castpoint)
				ParticleManager:SetParticleControl(particle, 1, Vector( castpoint.x, castpoint.y, castpoint.z + 2000 ) )

				unit:EmitSound("Hero_Zuus.LightningBolt")
				
				local hitUnits = FindUnitsInRadius(caster:GetTeamNumber(),
				            castpoint,
				            nil,
				            hit_radius,
				            DOTA_UNIT_TARGET_TEAM_ENEMY,
				            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				            FIND_ANY_ORDER,
				            false)

				for _,hit in pairs(hitUnits) do
					local damageTable = {
						victim = hit,
						attacker = caster,
						damage = ( caster:GetIntellect() * int_multi ) + ( caster:GetAgility() * agi_multi ) + hit_damage,
						damage_type = DAMAGE_TYPE_PURE,
					}
					ApplyDamage(damageTable)
				end

				--chain
				local chainUnits = FindUnitsInRadius(caster:GetTeamNumber(),
				            unit:GetAbsOrigin(),
				            nil,
				            chain_leap,
				            DOTA_UNIT_TARGET_TEAM_ENEMY,
				            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
				            FIND_ANY_ORDER,
				            false)

				unit:EmitSound("Hero_Zuus.ArcLightning.Cast")

				for _,ctarget in pairs(chainUnits) do
					local flag = false
					for _,l_unit in pairs(hitUnits) do
						if ctarget == l_unit then
							flag = true
							break
						end
					end
					if not flag then
						local chain = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_WORLDORIGIN, unit)
						ParticleManager:SetParticleControl(chain, 0, Vector(unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, unit:GetAbsOrigin().z + unit:GetBoundingMaxs().z ))
						ParticleManager:SetParticleControl(chain, 1, Vector(ctarget:GetAbsOrigin().x, ctarget:GetAbsOrigin().y, ctarget:GetAbsOrigin().z + ctarget:GetBoundingMaxs().z ))

						local damageTable2 = {
							victim = ctarget,
							attacker = caster,
							damage = ( ( caster:GetIntellect() * int_multi ) + ( caster:GetAgility() * agi_multi ) + hit_damage ) / 2,
							damage_type = DAMAGE_TYPE_MAGICAL,
						}
						ApplyDamage(damageTable2)
					end
				end
			end)

			break
		end
	end
end