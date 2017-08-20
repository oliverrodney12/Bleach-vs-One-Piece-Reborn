require('timers')

function spell_start( keys )
	local caster = keys.caster
	local ability = keys.ability

	local neutralUnits = FindUnitsInRadius(caster:GetTeamNumber(),
              caster:GetAbsOrigin(),
              nil,
              1000,
              DOTA_UNIT_TARGET_TEAM_ENEMY,
              DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
              DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
              FIND_ANY_ORDER,
              false)

	if #neutralUnits == 0 then return end

	if caster:IsSilenced() or not ability:IsCooldownReady() then return end
	ability:StartCooldown(8.0)
	
	for i = 1, 16 do
		Timers:CreateTimer(i / 8, function()
			if caster == nil or caster:IsNull() then return nil end

			local direction = Vector( RandomFloat(-1, 1), RandomFloat(-1, 1), 0)
			local point_cast = caster:GetAbsOrigin() + ( direction:Normalized() * RandomInt(500, 1000) )

			local particleName = "particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath_start.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(particle , 0, point_cast)
			ParticleManager:SetParticleControl(particle , 1, point_cast)
			ParticleManager:SetParticleControl(particle , 2, point_cast)

			Timers:CreateTimer(0.3, function()
				if caster == nil or caster:IsNull() then return nil end

				local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
					            point_cast,
					            nil,
					            225,
					            DOTA_UNIT_TARGET_TEAM_ENEMY,
					            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
					            FIND_ANY_ORDER,
					            false)

				for _,unit in pairs(localUnits) do
					local damageTable = {
						victim = unit,
						attacker = caster,
						damage = 500,
						damage_type = DAMAGE_TYPE_PURE,
					}

					ApplyDamage(damageTable)
				end

				local dummy = CreateUnitByName("npc_dummy_unit", point_cast, false, nil, nil, caster:GetTeam())
				dummy:AddAbility("custom_point_dummy")
				local abl = dummy:FindAbilityByName("custom_point_dummy")
				if abl ~= nil then abl:SetLevel(1) end
				dummy:EmitSound("Hero_Zuus.LightningBolt")
				Timers:CreateTimer(3.0, function ()
					dummy:RemoveSelf()
				end)
			end)
		end)
	end
end