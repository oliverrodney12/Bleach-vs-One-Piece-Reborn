bvo_squall_skill_4 = class ({})

LinkLuaModifier( "bvo_squall_skill_4_caster", "heroes/squall/modifiers/bvo_squall_skill_4_caster", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bvo_squall_skill_4_target", "heroes/squall/modifiers/bvo_squall_skill_4_target", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bvo_squall_skill_4_limit_modifier", "heroes/squall/modifiers/bvo_squall_skill_4_limit_modifier", LUA_MODIFIER_MOTION_NONE )

function bvo_squall_skill_4:CastFilterResultTarget( hTarget )
	local caster = self:GetCaster()

	local nResult = UnitFilter( hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, caster:GetTeamNumber() )
	if nResult ~= UF_SUCCESS then return nResult end

	if caster:GetHealthPercent() >= 40 then
		return UF_FAIL_CUSTOM
	end

	local canCast = false
	if caster:HasModifier("bvo_squall_skill_0_revolver_modifier") then
		canCast = true
	elseif caster:HasModifier("bvo_squall_skill_0_shear_trigger_modifier") then
		canCast = true
	elseif caster:HasModifier("bvo_squall_skill_0_flame_saber_modifier") then
		canCast = true
	elseif caster:HasModifier("bvo_squall_skill_0_punishment_modifier") then
		canCast = true
	elseif caster:HasModifier("bvo_squall_skill_0_lionheart_modifier") then
		canCast = true
	end

	if not canCast then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function bvo_squall_skill_4:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster():GetHealthPercent() >= 40 then return "#dota_hud_error_under_40percent_hp" end

	return "#dota_hud_error_need_gunblade"
end

function bvo_squall_skill_4:GetCastAnimation()
	return ACT_DOTA_ATTACK2
end

function bvo_squall_skill_4:OnSpellStart()
	local caster = self:GetCaster()

	bvo_squall_skill_4_cast( {
		caster = caster,
		target = self:GetCursorTarget(),
		ability = self,
		hit_amount = self:GetSpecialValueFor("hit_amount"),
		} )

	bvo_squall_skill_0_durability_down( {
			caster = caster,
			ability = caster:FindAbilityByName("bvo_squall_skill_0"),
			amount = self:GetSpecialValueFor( "durability_cost" ),
		} )
end

function bvo_squall_skill_0_durability_down( keys )
	local caster = keys.caster
	local ability = keys.ability
	local down = keys.amount

	local modifier
	if caster:HasModifier("bvo_squall_skill_0_revolver_modifier") then
		modifier = "bvo_squall_skill_0_revolver_modifier"
	elseif caster:HasModifier("bvo_squall_skill_0_shear_trigger_modifier") then
		modifier = "bvo_squall_skill_0_shear_trigger_modifier"
	elseif caster:HasModifier("bvo_squall_skill_0_flame_saber_modifier") then
		modifier = "bvo_squall_skill_0_flame_saber_modifier"
	elseif caster:HasModifier("bvo_squall_skill_0_punishment_modifier") then
		modifier = "bvo_squall_skill_0_punishment_modifier"
	elseif caster:HasModifier("bvo_squall_skill_0_lionheart_modifier") then
		modifier = "bvo_squall_skill_0_lionheart_modifier"
	end

	if modifier ~= nil then
		local current_stack = caster:GetModifierStackCount(modifier, ability)
		if current_stack - down > 0 then
			caster:SetModifierStackCount(modifier, ability, current_stack - down)
		else
			caster:RemoveModifierByName(modifier)
		end
	end
end

function bvo_squall_skill_4_cast(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local hit_amount = keys.hit_amount

	caster:Stop()
	target:Stop()
	caster:AddNewModifier(caster, ability, "bvo_squall_skill_4_caster", {duration=7.0})
	target:AddNewModifier(caster, ability, "bvo_squall_skill_4_target", {duration=7.0})

	target:EmitSound("Hero_Riki.Blink_Strike")

	--store skill levels and make space
	local squall_skill_0 = caster:FindAbilityByName("bvo_squall_skill_0")
	caster.squall_skill_0 = squall_skill_0:GetLevel()
	caster:RemoveAbility("bvo_squall_skill_0")

	local squall_skill_1 = caster:FindAbilityByName("bvo_squall_skill_1")
	caster.squall_skill_1 = squall_skill_1:GetLevel()
	caster:RemoveAbility("bvo_squall_skill_1")

	local squall_skill_2 = caster:FindAbilityByName("bvo_squall_skill_2")
	caster.squall_skill_2 = squall_skill_2:GetLevel()
	caster:RemoveAbility("bvo_squall_skill_2")

	local squall_skill_3 = caster:FindAbilityByName("bvo_squall_skill_3")
	caster.squall_skill_3 = squall_skill_3:GetLevel()
	caster:RemoveAbility("bvo_squall_skill_3")

	local squall_skill_5 = caster:FindAbilityByName("bvo_squall_skill_5")
	caster.squall_skill_5 = squall_skill_5:GetLevel()
	caster:RemoveAbility("bvo_squall_skill_5")

	caster:FindAbilityByName("bvo_squall_skill_4"):SetHidden(true)

	for i = 1, 3 do
		local emptySkill = caster:AddAbility("bvo_squall_skill_4_empty")
		emptySkill:SetLevel(1)
	end
	local triggerSkill = caster:AddAbility("bvo_squall_skill_4_pull_trigger")
	triggerSkill:SetLevel(1)

	CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "display_limit_break", {} )

	caster.limit_break_target = target
	local strike = 0
	local timing = ( strike * 5 ) .. '%'
	CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "move_timer", {pos=timing} )
	caster.limit_break_timing = strike
	local hits = 0
	Timers:CreateTimer(0.05, function()
		local modifier
		if caster:HasModifier("bvo_squall_skill_0_revolver_modifier") then
			modifier = "bvo_squall_skill_0_revolver_modifier"
		elseif caster:HasModifier("bvo_squall_skill_0_shear_trigger_modifier") then
			modifier = "bvo_squall_skill_0_shear_trigger_modifier"
		elseif caster:HasModifier("bvo_squall_skill_0_flame_saber_modifier") then
			modifier = "bvo_squall_skill_0_flame_saber_modifier"
		elseif caster:HasModifier("bvo_squall_skill_0_punishment_modifier") then
			modifier = "bvo_squall_skill_0_punishment_modifier"
		elseif caster:HasModifier("bvo_squall_skill_0_lionheart_modifier") then
			modifier = "bvo_squall_skill_0_lionheart_modifier"
		end

		if modifier ~= nil then
			if strike < 19 and caster:FindAbilityByName("bvo_squall_skill_4_pull_trigger") ~= nil then
				strike = strike + 1

				if not caster:HasModifier("bvo_squall_skill_4_caster") then
					CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "hide_limit_break", {} )
					return nil
				end

				if not caster.limit_break_target:IsAlive() then
					caster:RemoveModifierByName("bvo_squall_skill_4_caster")
					if caster.limit_break_target:IsAlive() then
						caster.limit_break_target:RemoveModifierByName("bvo_squall_skill_4_target")
					end
					CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "hide_limit_break", {} )
					return nil
				end

				timing = ( strike * 5 ) .. '%'
				CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "move_timer", {pos=timing} )
				caster.limit_break_timing = strike
				return 0.05
			else
				hits = hits + 1
				if hits < hit_amount then
					strike = 0
					timing = ( strike * 5 ) .. '%'
					CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "move_timer", {pos=timing} )
					caster.limit_break_timing = strike
					if caster:FindAbilityByName("bvo_squall_skill_4_pull_trigger") ~= nil then
						bvo_squall_skill_4_hit(caster, ability)
					end
					local newTrigger = caster:AddAbility("bvo_squall_skill_4_pull_trigger")
					newTrigger:SetLevel(1)
					return 0.05
				else
					CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "hide_limit_break", {} )
					caster:RemoveModifierByName("bvo_squall_skill_4_caster")
					target:RemoveModifierByName("bvo_squall_skill_4_target")
					return nil
				end
			end
		else
			CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "hide_limit_break", {} )
			caster:RemoveModifierByName("bvo_squall_skill_4_caster")
			target:RemoveModifierByName("bvo_squall_skill_4_target")
			return nil
		end
	end)
end

function bvo_squall_skill_4_hit( caster, ability )
	local durability_cost = ability:GetLevelSpecialValueFor("durability_cost", ability:GetLevel() - 1 )
	local str_multi = ability:GetLevelSpecialValueFor("str_multi", ability:GetLevel() - 1 )
	local agi_multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )

	local damage_multi_revolver = ability:GetLevelSpecialValueFor("damage_multi_revolver", ability:GetLevel() - 1 )
	local damage_multi_shear_trigger = ability:GetLevelSpecialValueFor("damage_multi_shear_trigger", ability:GetLevel() - 1 )
	local damage_multi_flame_saber = ability:GetLevelSpecialValueFor("damage_multi_flame_saber", ability:GetLevel() - 1 )
	local damage_multi_punishment = ability:GetLevelSpecialValueFor("damage_multi_punishment", ability:GetLevel() - 1 )
	local damage_multi_lionheart = ability:GetLevelSpecialValueFor("damage_multi_lionheart", ability:GetLevel() - 1 )

	local damage_multi = 100
	local damage_multi_add = 0
	local modifier
	if caster:HasModifier("bvo_squall_skill_0_revolver_modifier") then
		modifier = "bvo_squall_skill_0_revolver_modifier"
		damage_multi_add = damage_multi_revolver
	elseif caster:HasModifier("bvo_squall_skill_0_shear_trigger_modifier") then
		modifier = "bvo_squall_skill_0_shear_trigger_modifier"
		damage_multi_add = damage_multi_shear_trigger
	elseif caster:HasModifier("bvo_squall_skill_0_flame_saber_modifier") then
		modifier = "bvo_squall_skill_0_flame_saber_modifier"
		damage_multi_add = damage_multi_flame_saber
	elseif caster:HasModifier("bvo_squall_skill_0_punishment_modifier") then
		modifier = "bvo_squall_skill_0_punishment_modifier"
		damage_multi_add = damage_multi_punishment
	elseif caster:HasModifier("bvo_squall_skill_0_lionheart_modifier") then
		modifier = "bvo_squall_skill_0_lionheart_modifier"
		damage_multi_add = damage_multi_lionheart
	end

	if modifier ~= nil then
		local current_stack = caster:GetModifierStackCount(modifier, ability)
		if current_stack - durability_cost > 0 then
			caster:SetModifierStackCount(modifier, ability, current_stack - durability_cost)
		else
			caster:RemoveModifierByName(modifier)
		end
	end

	local pull_ok = false
	if caster.limit_break_timing >= 13 and caster.limit_break_timing <= 15 then
		pull_ok = true
		damage_multi = damage_multi + damage_multi_add
	end

	caster:RemoveAbility("bvo_squall_skill_4_pull_trigger")
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK2, 3.0)

	local break_damage = ( ( agi_multi * caster:GetAgility() ) + ( str_multi * caster:GetStrength() ) ) * ( damage_multi / 100 )
	local targetArmor = caster.limit_break_target:GetPhysicalArmorValue()
	local damageReduction = ((0.06 * targetArmor) / (1 + 0.06 * targetArmor))
	local damagePostReduction = break_damage * (1 - damageReduction)

	if pull_ok then
		caster:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
		local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_blood.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( fxIndex, 1, caster.limit_break_target:GetAbsOrigin() )
	else
		caster:EmitSound("Hero_Axe.Attack")
	end

	if not caster.limit_break_target:HasModifier("item_doom_1_modifier_buff") then
		local new_health = caster.limit_break_target:GetHealth() - damagePostReduction
		if new_health <= 1 then
			caster.limit_break_target:Kill(ability, caster)
		else
			caster.limit_break_target:SetHealth(new_health)
		end
	end
end