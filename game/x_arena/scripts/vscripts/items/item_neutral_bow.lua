require('timers')

function item_neutral_bow( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	ability.targetpoint = point

	ability:ApplyDataDrivenModifier(caster, caster, "item_neutral_bow_buff_modifier", {})

	ability:ApplyDataDrivenModifier(caster, caster, "item_neutral_bow_charge_modifier", {})
	caster:SetModifierStackCount( "item_neutral_bow_charge_modifier", ability, 1 )

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_livingarmor.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
	caster.neutral_bow_particle = particle
end

function item_neutral_bow_charge( keys )
	local caster = keys.caster
	local ability = keys.ability

	local manaCost = caster:GetMaxMana() * 0.01
	if caster:GetMana() >= manaCost then 
		caster:SpendMana(manaCost, ability)
		local current_stack = caster:GetModifierStackCount( "item_neutral_bow_charge_modifier", ability )
		caster:SetModifierStackCount( "item_neutral_bow_charge_modifier", ability, current_stack + 1 )
	else
		ability:EndChannel(false)
	end
end

function item_neutral_bow_cast( keys )
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("hit_damage", 0 )
	local hit_radius = ability:GetLevelSpecialValueFor("hit_radius", 0 )
	local radius = ability:GetLevelSpecialValueFor("radius", 0 )
	local interval = ability:GetLevelSpecialValueFor("interval", 0 )
	local point = ability.targetpoint

	ParticleManager:DestroyParticle(caster.neutral_bow_particle, true)
	local current_stack = caster:GetModifierStackCount( "item_neutral_bow_charge_modifier", ability )
	caster:RemoveModifierByName("item_neutral_bow_buff_modifier")
	caster:RemoveModifierByName("item_neutral_bow_charge_modifier")

	local sound_dummys = {}
	for i = 1, current_stack do
		Timers:CreateTimer(interval * i, function ()
			local offset = Vector( RandomFloat(-1, 1), RandomFloat(-1, 1), 0 )
			local castpoint = point + ( offset:Normalized() * RandomInt(0, radius) )

			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(particle, 0, castpoint)
			ParticleManager:SetParticleControl(particle, 1, castpoint)
			ParticleManager:SetParticleControl(particle, 4, Vector( hit_radius, hit_radius, hit_radius ))

			local dummy = CreateUnitByName("npc_dummy_unit", castpoint, false, nil, nil, caster:GetTeam())
			dummy:AddAbility("custom_point_dummy")
			local abl = dummy:FindAbilityByName("custom_point_dummy")
			if abl ~= nil then abl:SetLevel(1) end
			dummy:EmitSound("Hero_LegionCommander.Overwhelming.Hero")
			table.insert(sound_dummys, dummy)

			local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
			            castpoint,
			            nil,
			            hit_radius,
			            DOTA_UNIT_TARGET_TEAM_ENEMY,
			            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			            FIND_ANY_ORDER,
			            false)

			for _,unit in pairs(localUnits) do
				local damageTable = {
					victim = unit,
					attacker = caster,
					damage = damage,
					damage_type = DAMAGE_TYPE_PURE,
				}
				ApplyDamage(damageTable)
			end
		end)
	end
	Timers:CreateTimer(20.0, function ()
		for _,sd in pairs(sound_dummys) do
			sd:RemoveSelf()
		end
	end)
end