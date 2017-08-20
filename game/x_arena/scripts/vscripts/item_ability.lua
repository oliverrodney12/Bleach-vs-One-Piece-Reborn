require('timers')
require('lib/duel_lib')

function ManaOnAttack (keys)
	local caster = keys.caster
	local mana = keys.ManaOA
	caster:GiveMana(mana)
end

function item_reiatsu_orb(keys)
	local caster = keys.caster
		
	caster:EmitSound("Item.GuardianGreaves.Activate")
	caster:GiveMana(caster:GetMaxMana())
end

function item_blink_custom(keys)
	local ability = keys.ability
	local caster = keys.caster
	local point = keys.target_points[1]
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local range = 600

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)

	local casterPosB = caster:GetAbsOrigin()
	if not GridNav:CanFindPath(casterPos, casterPosB) then
		ability:EndCooldown()
		FindClearSpaceForUnit(caster, casterPos, false)
    	return
	end

	for i = 0, 5 do
		local item = caster:GetItemInSlot(i)
		if item ~= nil then
			if item:GetName() == "item_blink_axe" then
				item:StartCooldown(ability:GetCooldownTimeRemaining())
			end
    	end
	end
end

function item_bladebane_armor_BerserkersCall( keys )
	local caster = keys.caster
	local target = keys.target

	-- Clear the force attack target
	target:SetForceAttackTarget(nil)

	-- Give the attack order if the caster is alive
	-- otherwise forces the target to sit and do nothing
	if caster:IsAlive() then
		local order = 
		{
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}
		ExecuteOrderFromTable(order)
	else
		target:Stop()
	end

	-- Set the force attack target to be the caster
	target:SetForceAttackTarget(caster)
end

-- Clears the force attack target upon expiration
function item_bladebane_armor_BerserkersCallEnd( keys )
	local target = keys.target
	target:SetForceAttackTarget(nil)
end

function item_bladebane_armor_DamageReturn(params)
	local damage = params.Damage
	local attacker = params.attacker
	local hero = params.caster
	local ability = params.ability
	local percent = params.percent
	local return_damage_percent = percent / 100

	if attacker:HasModifier("item_doom_1_modifier_buff") or attacker:IsInvulnerable() then
		return
	end

	if damage > 1 and attacker and hero and attacker~=hero then
		local real_damage = damage * return_damage_percent
		local new_health = attacker:GetHealth() - real_damage
		if new_health > 1 then
			attacker:SetHealth(new_health)
		else
			attacker:Kill(ability, hero)
		end
	end
end

function item_blood_sword_drain(keys)
	local caster = keys.caster
	local target = keys.unit
	local attacker = keys.attacker
	local ability = keys.ability
	local health_bonus_pct = ability:GetLevelSpecialValueFor("health_bonus_pct", (ability:GetLevel() - 1)) /100
	
	if caster:IsAlive() then
		local target_health = target:GetMaxHealth()
		local heal = target_health * health_bonus_pct
		caster:Heal(heal, caster)
	else
		local caster_health = caster:GetMaxHealth()
		local heal = caster_health * health_bonus_pct
		
		attacker:Heal(heal, caster)
	end
end

function item_blood_sword_extra(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local damage = keys.damage
	local ability = keys.ability
	local damage_increase_pct = ability:GetLevelSpecialValueFor("damage_increase_pct", (ability:GetLevel() - 1)) /100

	local new_health = caster:GetHealth() - (damage * damage_increase_pct)
	if new_health <= 1 then
		caster:Kill(ability, attacker)
	else
		caster:SetHealth(new_health)
	end
end

function item_horn_of_mana(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local burn = ability:GetLevelSpecialValueFor("burn", ability:GetLevel() - 1 )

	if caster:IsIllusion() and not caster:HasModifier("item_mirror_of_kalandra_illu_modifier") then return end
	--Manavoid
	if target:GetMaxMana() > 0 and not target:IsMagicImmune() then
		local max = target:GetMaxMana()
		local missing = max - target:GetMana()

		local damageTable = {
			victim = target,
			attacker = caster,
			damage = missing * 0.85,
			damage_type = DAMAGE_TYPE_PURE,
		}
		ApplyDamage(damageTable)
		target:EmitSound("Hero_Antimage.ManaVoid")

		--local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_manavoid.vpcf", PATTACH_POINT, target)
		--ParticleManager:SetParticleControl(particle, 0, Vector(0, 0, 0) )
		--ParticleManager:SetParticleControl(particle, 1, Vector(275, 0, 0) )
	end
end

function item_diffusal_blade(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local burn = ability:GetLevelSpecialValueFor("burn", ability:GetLevel() - 1 )

	--Manaburn
	if target:GetMaxMana() > 0 then
		if caster:IsIllusion() and not caster:HasModifier("item_mirror_of_kalandra_illu_modifier") then
			burn = burn / 2
		end
		local targetMana = target:GetMana()
		local burned = targetMana - burn
		if burned < 0 then burned = 0 end
		target:SetMana(burned)
		local burned_mana = targetMana - burned
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = burned_mana,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		ApplyDamage(damageTable)

		local particleName = "particles/generic_gameplay/generic_manaburn.vpcf"
		ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
	end
end

function item_ghost_ring_invis(keys)
	caster = keys.caster
	ability = keys.ability

	if not caster:HasModifier("item_ghost_ring_invis_fade_modifier") then
		ability:ApplyDataDrivenModifier(caster, caster, "item_ghost_ring_invis_modifier", nil)
	end
end

--item_orb_of_fire
--[[ ============================================================================================================
	Author: Rook
	Date: April 06, 2015
	Called when Chaos Meteor is cast.
	Additional parameters: keys.LandTime, keys.TravelSpeed, keys.VisionDistance, keys.EndVisionDuration, and
	    keys.BurnDuration
================================================================================================================= ]]
function invoker_chaos_meteor_datadriven_on_spell_start(keys)
	local casterUNIT = keys.caster
	local caster_point = keys.caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	
	local caster_point_temp = Vector(caster_point.x, caster_point.y, 0)
	local target_point_temp = Vector(target_point.x, target_point.y, 0)
	
	local point_difference_normalized = (target_point_temp - caster_point_temp):Normalized()
	local velocity_per_second = point_difference_normalized * keys.TravelSpeed
	
	keys.caster:EmitSound("Hero_Invoker.ChaosMeteor.Cast")
	keys.caster:EmitSound("Hero_Invoker.ChaosMeteor.Loop")

	--Create a particle effect consisting of the meteor falling from the sky and landing at the target point.
	local meteor_fly_original_point = (target_point - (velocity_per_second * keys.LandTime)) + Vector (0, 0, 1000)  --Start the meteor in the air in a place where it'll be moving the same speed when flying and when rolling.
	local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, meteor_fly_original_point)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, target_point)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(1.3, 0, 0))
	
	--Chaos Meteor's main and burn damage is dependent on the level of Exort.  This values are stored now since leveling up Exort while the meteor is in midair should have no effect.
	local main_damage = 0
	local burn_dps = 0
	local casterINT = casterUNIT:GetIntellect()
	main_damage = keys.ability:GetLevelSpecialValueFor("main_damage", 0)
	burn_dps = keys.ability:GetLevelSpecialValueFor("burn_dps", 0)
	burn_dps = burn_dps * casterINT
	
	
	--Chaos Meteor's travel distance is dependent on the level of Wex.  This value is stored now since leveling up Wex while the meteor is in midair should have no effect.
	local travel_distance = 0
	travel_distance = keys.ability:GetLevelSpecialValueFor("travel_distance", 0)
	
	--Spawn the rolling meteor after the delay.
	Timers:CreateTimer({
		endTime = keys.LandTime,
		callback = function()
			--Create a dummy unit will follow the path of the meteor, providing flying vision, sound, damage, etc.			
			local chaos_meteor_dummy_unit = CreateUnitByName("npc_dummy_unit", target_point, false, nil, nil, keys.caster:GetTeam())
			chaos_meteor_dummy_unit:AddAbility("invoker_chaos_meteor_datadriven")
			local chaos_meteor_unit_ability = chaos_meteor_dummy_unit:FindAbilityByName("invoker_chaos_meteor_datadriven")
			if chaos_meteor_unit_ability ~= nil then
				chaos_meteor_unit_ability:SetLevel(1)
				chaos_meteor_unit_ability:ApplyDataDrivenModifier(chaos_meteor_dummy_unit, chaos_meteor_dummy_unit, "modifier_invoker_chaos_meteor_datadriven_unit_ability", {duration = -1})
			end
			
			keys.caster:StopSound("Hero_Invoker.ChaosMeteor.Loop")
			chaos_meteor_dummy_unit:EmitSound("Hero_Invoker.ChaosMeteor.Impact")
			chaos_meteor_dummy_unit:EmitSound("Hero_Invoker.ChaosMeteor.Loop")  --Emit a sound that will follow the meteor.
			
			chaos_meteor_dummy_unit:SetDayTimeVisionRange(keys.VisionDistance)
			chaos_meteor_dummy_unit:SetNightTimeVisionRange(keys.VisionDistance)
			
			--Store the damage to deal in a variable attached to the dummy unit, so leveling Exort after Meteor is cast will have no effect.
			chaos_meteor_dummy_unit.invoker_chaos_meteor_main_damage = main_damage
			chaos_meteor_dummy_unit.invoker_chaos_meteor_burn_dps = burn_dps
			chaos_meteor_dummy_unit.invoker_chaos_meteor_parent_caster = keys.caster
		
			local chaos_meteor_duration = travel_distance / keys.TravelSpeed
			local chaos_meteor_velocity_per_frame = velocity_per_second * .03
			
			--It would seem that the Chaos Meteor projectile needs to be attached to a particle in order to move and roll and such.
			local projectile_information =  
			{
				EffectName = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
				Ability = chaos_meteor_unit_ability,
				vSpawnOrigin = target_point,
				fDistance = travel_distance,
				fStartRadius = 0,
				fEndRadius = 0,
				Source = chaos_meteor_dummy_unit,
				bHasFrontalCone = false,
				iMoveSpeed = keys.TravelSpeed,
				bReplaceExisting = false,
				bProvidesVision = true,
				iVisionTeamNumber = keys.caster:GetTeam(),
				iVisionRadius = keys.VisionDistance,
				bDrawsOnMinimap = false,
				bVisibleToEnemies = true, 
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_NONE ,
				fExpireTime = GameRules:GetGameTime() + chaos_meteor_duration + keys.EndVisionDuration,
			}
			
			projectile_information.vVelocity = velocity_per_second
			local chaos_meteor_projectile = ProjectileManager:CreateLinearProjectile(projectile_information)

			chaos_meteor_unit_ability:ApplyDataDrivenModifier(chaos_meteor_dummy_unit, chaos_meteor_dummy_unit, "modifier_invoker_chaos_meteor_datadriven_main_damage", nil)
			
			--Adjust the dummy unit's position every frame.
			local endTime = GameRules:GetGameTime() + chaos_meteor_duration
			Timers:CreateTimer({
				callback = function()
					chaos_meteor_dummy_unit:SetAbsOrigin(chaos_meteor_dummy_unit:GetAbsOrigin() + chaos_meteor_velocity_per_frame)
					if GameRules:GetGameTime() > endTime then
						--Stop the sound, particle, and damage when the meteor disappears.
						chaos_meteor_dummy_unit:StopSound("Hero_Invoker.ChaosMeteor.Loop")
						chaos_meteor_dummy_unit:StopSound("Hero_Invoker.ChaosMeteor.Destroy")
						chaos_meteor_dummy_unit:RemoveModifierByName("modifier_invoker_chaos_meteor_datadriven_main_damage")
					
						--Have the dummy unit linger in the position the meteor ended up in, in order to provide vision.
						Timers:CreateTimer({
							endTime = keys.EndVisionDuration,
							callback = function()
								chaos_meteor_dummy_unit:SetDayTimeVisionRange(0)
								chaos_meteor_dummy_unit:SetNightTimeVisionRange(0)
								
								--Remove the dummy unit after the burn damage modifiers are guaranteed to have all expired.
								Timers:CreateTimer({
									endTime = keys.BurnDuration,
									callback = function()
										chaos_meteor_dummy_unit:RemoveSelf()
									end
								})
							end
						})
						return 
					else 
						return .03
					end
				end
			})
		end
	})
end


--[[ ============================================================================================================
	Author: Rook
	Date: April 06, 2015
	Called regularly while the Chaos Meteor is rolling.
	Additional parameters: keys.AreaOfEffect
================================================================================================================= ]]
function modifier_invoker_chaos_meteor_datadriven_main_damage_on_interval_think(keys)
	local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.AreaOfEffect, DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	if keys.caster.invoker_chaos_meteor_parent_caster ~= nil then
		for i, individual_unit in ipairs(nearby_enemy_units) do
			individual_unit:EmitSound("Hero_Invoker.ChaosMeteor.Damage")
			
			if keys.caster.invoker_chaos_meteor_main_damage == nil then
				keys.caster.invoker_chaos_meteor_main_damage = 0
			end
			
			ApplyDamage({victim = individual_unit, attacker = keys.caster.invoker_chaos_meteor_parent_caster, damage = keys.caster.invoker_chaos_meteor_main_damage, damage_type = DAMAGE_TYPE_PURE,})
			
			keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_invoker_chaos_meteor_datadriven_burn_damage", nil)
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: April 06, 2015
	Called regularly a unit is still burned from a Chaos Meteor.
	Additional parameters: keys.BurnDamagePerInterval
================================================================================================================= ]]
function modifier_invoker_chaos_meteor_datadriven_burn_damage_on_interval_think(keys)
	if keys.caster.invoker_chaos_meteor_parent_caster ~= nil and keys.caster.invoker_chaos_meteor_burn_dps ~= nil then
		ApplyDamage({victim = keys.target, attacker = keys.caster.invoker_chaos_meteor_parent_caster, damage = keys.caster.invoker_chaos_meteor_burn_dps * keys.BurnDPSInterval, damage_type = DAMAGE_TYPE_PURE,})
	end
end

--end

function item_sacrifical_wand(keys)
	local caster = keys.caster

	local str = caster:GetBaseStrength()
	local agi = caster:GetBaseAgility()
	local int = caster:GetBaseIntellect()


	Timers:CreateTimer(15.0, function()
		caster:ModifyStrength(str * 0.9)
		caster:ModifyAgility(agi * 0.9)
		caster:ModifyIntellect(-str * 0.9 + -agi * 0.9)
	end)

	caster:ModifyStrength(-str * 0.9)
	caster:ModifyAgility(-agi * 0.9)
	caster:ModifyIntellect(str * 0.9 + agi * 0.9)
end

function item_drop_on_death(keys)
	local caster = keys.caster
	if not caster:IsRealHero() then return end
	local item = keys.ability
	local casterPos = caster:GetAbsOrigin()

	if caster.ankh then return end

	if item:GetName() == "item_rapier_custom" then
		if _G.rapierEvent then
			for _,unit in pairs(_G.rapierUnits) do
				local max = unit:GetMaxHealth()
				unit:SetHealth(max)
				FindClearSpaceForUnit(unit, unit.originalPos, false)
				unit:AddNewModifier(unit, nil, "modifier_stun", {})
			end
			local newItem = CreateItem(item:GetName(), nil, nil)
		   	newItem:SetPurchaseTime(0)
		   	newItem.originalPos = item.originalPos
		   	local drop = CreateItemOnPositionSync( item.originalPos, newItem )
		   	caster:RemoveItem(item)
			return
		else
			if not DuelLibrary:IsDuelActive() then
				local newItem = CreateItem(item:GetName(), nil, nil)
			   	newItem:SetPurchaseTime(0)
			   	newItem.originalPos = item.originalPos
			   	local drop = CreateItemOnPositionSync( caster:GetAbsOrigin(), newItem )
			   	caster:RemoveItem(item)
			   	return
			end
		end
	end
	if not DuelLibrary:IsDuelActive() then
		local newItem = CreateItem(item:GetName(), nil, nil)
	   	newItem:SetPurchaseTime(0)
	   	newItem.originalPos = item.originalPos
	   	local drop = CreateItemOnPositionSync( caster:GetAbsOrigin(), newItem )
	   	caster:RemoveItem(item)
	end
end

function item_ancient_staff_of_mythology(keys)
	local caster = keys.caster
	local ability = keys.ability

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            FIND_UNITS_EVERYWHERE,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	for _,hero in pairs(localUnits) do
		if not hero:IsRealHero() then
			hero:Kill(caster, ability)
		else
			ability:ApplyDataDrivenModifier(caster, hero, "item_ancient_staff_of_mythology_hex_modifier", {duration=4.0} )
			
			hero.asomModel = hero:GetModelName()
			hero.asomScale = hero:GetModelScale()

			hero:SetOriginalModel("models/items/hex/sheep_hex/sheep_hex.vmdl")
			hero:SetModel("models/items/hex/sheep_hex/sheep_hex.vmdl")
			hero:SetModelScale(0.75)
		end
	end
end

function item_ancient_staff_of_mythology_end(keys)
	local target = keys.target
	
	target:SetOriginalModel(target.asomModel)
	target:SetModel(target.asomModel)
	target:SetModelScale(target.asomScale)

	target.asomModel = nil
	target.asomScale = nil
end

function item_rapier_mimic(keys)
	local ability = keys.ability
	local caster = keys.caster
	if ability.castOnce == nil then
		ability.castOnce = true
		local rapier_spawn = Entities:FindByName( nil, "RAPIER_SPAWN"):GetAbsOrigin()
		local mimic = CreateUnitByName("npc_dota_mimic", rapier_spawn, true, nil, nil, DOTA_TEAM_NEUTRALS)
		mimic.spawnOrigin = rapier_spawn
		mimic.unitName = "npc_dota_mimic"
	end
end

function item_windrunner(keys)
	local caster = keys.caster
	if caster:GetClassname() == "npc_dota_hero_skeleton_king" then
		if caster.dummy_wings ~= nil and not caster.dummy_wings:IsNull() then
			caster:FindAbilityByName("bvo_mana_on_hit"):ApplyDataDrivenModifier(caster, caster.dummy_wings, "bvo_extra_invis_modifier", {duration=7.0} )
		end
	end
	if caster.santa_hat ~= nil and not caster.santa_hat:IsNull() then
		caster:FindAbilityByName("bvo_mana_on_hit"):ApplyDataDrivenModifier(caster, caster.santa_hat, "bvo_extra_invis_modifier", {duration=7.0} )
	end
end

function checkItemCombine(keys)
	local caster = keys.caster
	local item = keys.ability

	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local rapierItems = {
				"item_zanbato",
				"item_corrupted_desolator",
				"item_blood_sword",
				"item_frostmourne",
				"item_divine_bow",
				"item_greater_stone_of_essence",
			}
			for _,ri in pairs(rapierItems) do
				if itemName == ri and _G.rapierEvent then
					_G.rapierEvent = false

					local rapier_spawn = Entities:FindByName( nil, "RAPIER_SPAWN"):GetAbsOrigin()
					for i = 1, 6 do
						Timers:CreateTimer(i * 0.2, function ()

							local rotation = QAngle( 0, i * 60, 0 )
			   				local demon_pos = Vector( rapier_spawn.x, rapier_spawn.y + 512, rapier_spawn.z )
			   				local demon_pos_rot = Vector( demon_pos.x, demon_pos.y + 256, demon_pos.z )
			   				local rot_vector = RotatePosition(demon_pos, rotation, demon_pos_rot)
			   				
							local demon_guard = CreateUnitByName("npc_dota_demon_guard", rot_vector, true, nil, nil, DOTA_TEAM_NEUTRALS)
							demon_guard.spawnOrigin = rapier_spawn
							demon_guard.unitName = "npc_dota_demon_guard"
						end)
					end

				   	Timers:CreateTimer(1.5, function ()
					   	local newItem = CreateItem("item_rapier_custom_mimic", nil, nil)
					   	newItem:SetPurchaseTime(0)
					   	newItem.originalPos = rapier_spawn
					   	local drop = CreateItemOnPositionSync( rapier_spawn, newItem )
			   		end)

				end
			end
		end
	end
end

function item_zanbato(keys)
	local attacker = keys.attacker
	local cleave = keys.cleave
	local aoe = keys.area
	if attacker:GetAttackCapability() == 2 then return end
	local ability = keys.ability
	local target = keys.target
	local damage = keys.damage
	
	DoCleaveAttack(attacker, target, ability, damage * (cleave / 100), aoe, aoe, aoe, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf" )
end

function killer_axe(keys)
	local attacker = keys.attacker
	local ability = keys.ability
	local target = keys.target

	if attacker:IsRealHero() or attacker:HasModifier("item_mirror_of_kalandra_illu_modifier") then
		if ability:IsCooldownReady() then
			ability:ApplyDataDrivenModifier(attacker, target, "item_killer_axe_stun_modifier", {duration=0.1} )
			ability:StartCooldown(0.3)
		end
	end
end