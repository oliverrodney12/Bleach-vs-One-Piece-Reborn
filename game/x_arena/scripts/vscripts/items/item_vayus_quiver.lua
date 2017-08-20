require('timers')

function item_vayus_quiver( keys )
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("hit_damage", 0 )
	local hit_radius = ability:GetLevelSpecialValueFor("hit_radius", 0 )
	local radius = ability:GetLevelSpecialValueFor("radius", 0 )

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
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(particle, 0, castpoint)
				ParticleManager:SetParticleControl(particle, 1, castpoint)
				ParticleManager:SetParticleControl(particle, 4, Vector( hit_radius, hit_radius, hit_radius ))

				unit:EmitSound("Hero_LegionCommander.Overwhelming.Hero")

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
						damage = damage,
						damage_type = DAMAGE_TYPE_PURE,
					}
					ApplyDamage(damageTable)
				end
			end)

			

			break
		end
	end
end