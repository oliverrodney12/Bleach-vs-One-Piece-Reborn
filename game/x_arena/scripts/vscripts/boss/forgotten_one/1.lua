function boss_forgotten_one_skill_1( keys )
	local caster = keys.caster
	local ability = keys.ability
	local amount = ability:GetLevelSpecialValueFor("amount", ability:GetLevel() - 1 )
	local dur = ability:GetLevelSpecialValueFor("add_duration", ability:GetLevel() - 1 )

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
	
	for _,unit in pairs(neutralUnits) do
		for i = 1, amount do
			local spawnpos = unit:GetAbsOrigin()
	    	local rotation = QAngle( 0, (360 / amount) * i, 0 )
			local rot_vector = RotatePosition(spawnpos, rotation, spawnpos + Vector(0, 80, 0))

			local add = CreateUnitByName("npc_dota_forgotten_plague", rot_vector, false, nil, nil, caster:GetTeam())
			ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_ward_spawn.vpcf", PATTACH_ABSORIGIN, add)
			FindClearSpaceForUnit(add, rot_vector, true)
			ability:ApplyDataDrivenModifier(caster, add, "boss_forgotten_one_skill_1_add_modifier", {duration=dur})
		end
		unit:EmitSound("Hero_Venomancer.Plague_Ward")

		break
	end
end

function boss_forgotten_one_skill_1_kill( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:Kill(ability, caster)
end

function boss_forgotten_one_skill_1_add_stack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local dur = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )

	if not target:HasModifier("boss_forgotten_one_add_skill_1_poison_modifier") then
		ability:ApplyDataDrivenModifier(caster, target, "boss_forgotten_one_add_skill_1_poison_modifier", {duration=dur})
		target:SetModifierStackCount( "boss_forgotten_one_add_skill_1_poison_modifier", ability, 1 )
	else
		local current_stack = target:GetModifierStackCount( "boss_forgotten_one_add_skill_1_poison_modifier", ability )
		target:SetModifierStackCount( "boss_forgotten_one_add_skill_1_poison_modifier", ability, current_stack + 1 )
	end

	local mods = target:FindAllModifiers()
	for _,mod in pairs(mods) do
		if mod:GetName() == "boss_forgotten_one_add_skill_1_poison_modifier" then
			mod:ForceRefresh()
			break
		end
	end
end