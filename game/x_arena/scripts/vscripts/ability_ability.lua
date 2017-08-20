require('timers')

function playAnimation(keys)
	local caster = keys.caster
	local animation = keys.animation
	
	if animation == "ACT_DOTA_CAST_ABILITY_1" then
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
	elseif animation == "ACT_DOTA_CAST_ABILITY_2" then
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
	elseif animation == "ACT_DOTA_CAST_ABILITY_3" then
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
	elseif animation == "ACT_DOTA_CAST_ABILITY_4" then
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
	elseif animation == "ACT_DOTA_CAST_ABILITY_5" then
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_5)
	elseif animation == "ACT_DOTA_ATTACK" then
		caster:StartGesture(ACT_DOTA_ATTACK)
	elseif animation == "ACT_DOTA_ATTACK2" then
		caster:StartGesture(ACT_DOTA_ATTACK2)
	elseif animation == "ACT_DOTA_IDLE_RARE" then
		caster:StartGesture(ACT_DOTA_IDLE_RARE)
	end
end

function bvo_start_game_init(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.hatAdjust == nil then
		caster.hatAdjust = true
		ability:ApplyDataDrivenModifier(caster, caster, "bvo_start_game_init", {duration=1.0} )
	end
end

function anti_camp_check(keys)
	local caster = keys.caster
	local ability = keys.ability

	if ability.currentPoint ~= nil then
		if caster:GetAbsOrigin() ~= ability.currentPoint then
			caster:RemoveModifierByName("afk_anti_camp_modifier")
			ability.currentPoint = nil
		end
	end
end

function anti_camp_init(keys)
	local caster = keys.caster
	local ability = keys.ability

	local base_point = Vector(0, 0, 0)
	if caster:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		base_point = Entities:FindByName( nil, "RADIANT_BASE"):GetAbsOrigin()
	elseif caster:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		base_point = Entities:FindByName( nil, "DIRE_BASE"):GetAbsOrigin()
	end
	FindClearSpaceForUnit(caster, base_point, false)
	ability.currentPoint = caster:GetAbsOrigin()
	caster:Stop();
end

function anti_camp_apply(keys)
	local caster = keys.caster
	local ability = keys.ability
	local time = ability:GetLevelSpecialValueFor("afk_timeout", 0)
	if not caster:HasModifier("afk_anti_camp_apply_modifier") and not caster:HasModifier("afk_anti_camp_modifier") then
		ability:ApplyDataDrivenModifier(caster, caster, "afk_anti_camp_apply_modifier", {duration=time} )
	end
end

function ManaOnAttack (keys)
	local caster = keys.caster
	caster:GiveMana(25)
end

function check_local_aggro(keys)
	local caster = keys.caster
	
	local AQRange = caster:GetAcquisitionRange()
	if caster:IsHero() then
		AQRange = 800
	end

	if caster.hasAggroOn ~= nil then
		local difference = caster:GetAbsOrigin() - caster.spawnOrigin
		if difference:Length2D() > AQRange then
			caster.hasAggroOn = nil
			caster:SetForceAttackTarget(nil)
			caster.returning = true
			local z = GetGroundHeight(Vector(caster.spawnOrigin.x, caster.spawnOrigin.y, 128), nil)
			local o_vector = Vector( caster.spawnOrigin.x, caster.spawnOrigin.y, z )
			caster:MoveToPosition(o_vector)
		end
	end

	if caster.returning then
		local difference = caster:GetAbsOrigin() - caster.spawnOrigin
		if difference:Length2D() < 250 then
			caster.returning = false
		end
	end

	if caster.hasAggroOn ~= nil then
		if caster.hasAggroOn:IsNull() or not caster.hasAggroOn:IsAlive() then
			caster.hasAggroOn = nil
			caster:SetForceAttackTarget(nil)
			caster.returning = true
			local z = GetGroundHeight(Vector(caster.spawnOrigin.x, caster.spawnOrigin.y, 128), nil)
			local o_vector = Vector( caster.spawnOrigin.x, caster.spawnOrigin.y, z )
			caster:MoveToPosition(o_vector)
		end
	end

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            AQRange,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_NONE,
	            FIND_CLOSEST,
	            false)

	for _,unit in pairs(localUnits) do
		local difference = unit:GetAbsOrigin() - caster.spawnOrigin
		if difference:Length2D() < AQRange and caster.hasAggroOn == nil and unit:IsAlive() then
			caster.hasAggroOn = unit
			caster:SetForceAttackTarget(unit)
			return
		end
	end
end

function extra_invis_check(keys)
	local caster = keys.target
	if not caster.parent:IsInvisible() then
		caster:RemoveModifierByName("bvo_extra_invis_modifier")
	end
end

function updateBounty(keys)
	local caster = keys.caster
	local ability = keys.ability

	local current_stack = caster:GetModifierStackCount( "bvo_bounty_modifier", ability )
	local difference_stack = 0
	local networth_radiant = 0
	local networth_dire = 0
	--calculate networth
	for _,hero in pairs(_G.tHeroesRadiant) do
		if not IsDisconnected(hero) then
			local networth = hero:GetGold() + hero.TotalMedals * 150
			for itemSlot=0,5 do
				local item = caster:GetItemInSlot(itemSlot)
				if item ~= nil then
					networth = networth + item:GetCost()
				end
			end
			networth_radiant = networth_radiant + networth
		end
	end
	for _,hero in pairs(_G.tHeroesDire) do
		if not IsDisconnected(hero) then
			local networth = hero:GetGold() + hero.TotalMedals * 150
			for itemSlot=0,5 do
				local item = caster:GetItemInSlot(itemSlot)
				if item ~= nil then
					networth = networth + item:GetCost()
				end
			end
			networth_dire = networth_dire + networth
		end
	end
	--update stacks
	if caster:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		local dif = networth_radiant - networth_dire
		difference_stack = math.ceil(dif / 1000)
	elseif caster:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		local dif = networth_dire - networth_radiant
		difference_stack = math.ceil(dif / 1000)
	end
	if difference_stack > current_stack then
		caster:SetModifierStackCount( "bvo_bounty_modifier", ability, difference_stack )
	end
end

function bvo_bounty_earn(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local attacker = keys.attacker

	if attacker == nil then return end

	if caster:GetHealth() == 0 and attacker:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS and not caster.ankh then
		local current_stack = caster:GetModifierStackCount( modifier, ability )
		caster:RemoveModifierByName(modifier)

		local player = attacker:GetPlayerOwner()
		if player ~= nil then
			local assigned_hero = player:GetAssignedHero()
			if assigned_hero ~= nil then
				if current_stack < 1 then current_stack = 1 end
				assigned_hero:ModifyGold(current_stack * 200, false, 0)
				assigned_hero:AddExperience(current_stack * 100, 0, false, true)
				if assigned_hero.medals ~= nil then
					local medal_award = math.floor(current_stack / 10)
					assigned_hero.medals = assigned_hero.medals + medal_award
					assigned_hero.TotalMedals = assigned_hero.TotalMedals + medal_award
					CustomGameEventManager:Send_ServerToPlayer(player, "display_medal", {msg=assigned_hero.medals} )
				end
			end
		end
	    --Start the particle and sound.
	    attacker:EmitSound("DOTA_Item.Hand_Of_Midas")
	    local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)  
	    ParticleManager:SetParticleControlEnt(midas_particle, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), false)

	    local difference_stack = 1
	    local new_target = nil
		local new_target_radiant = nil
		local new_target_dire = nil
		local biggest_networth_radiant = 0
		local biggest_networth_dire = 0
		local networth_radiant = 0
		local networth_dire = 0
		--calculate networth
		for _,hero in pairs(_G.tHeroesRadiant) do
			if not IsDisconnected(hero) then
				local networth = hero:GetGold() + hero.TotalMedals * 150
				for itemSlot=0,5 do
					local item = caster:GetItemInSlot(itemSlot)
					if item ~= nil then
						networth = networth + item:GetCost()
					end
				end
				if networth > biggest_networth_radiant then
					biggest_networth_radiant = networth
					new_target_radiant = hero
				end
				networth_radiant = networth_radiant + networth
			end
		end
		for _,hero in pairs(_G.tHeroesDire) do
			if not IsDisconnected(hero) then
				local networth = hero:GetGold() + hero.TotalMedals * 150
				for itemSlot=0,5 do
					local item = caster:GetItemInSlot(itemSlot)
					if item ~= nil then
						networth = networth + item:GetCost()
					end
				end
				if networth > biggest_networth_dire then
					biggest_networth_dire = networth
					new_target_dire = hero
				end
				networth_dire = networth_dire + networth
			end
		end
		--set new target
		if caster:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			new_target = new_target_radiant
			local dif = networth_radiant - networth_dire
			difference_stack = math.ceil(dif / 1000)
		elseif caster:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			new_target = new_target_dire
			local dif = networth_dire - networth_radiant
			difference_stack = math.ceil(dif / 1000)
		end
		if difference_stack < 1 then difference_stack = 1 end
		--wait for new target to be alive to apply bounty debuff
		if new_target ~= nil then
			local bounty_set = false
			Timers:CreateTimer(1.0, function()
				if not bounty_set then
					if new_target:IsAlive() then
						ability:ApplyDataDrivenModifier(new_target, new_target, modifier, {} )
						new_target:SetModifierStackCount( modifier, ability, difference_stack )
						bounty_set = true
					end
					return 1.0
				else
					return nil
				end
			end)
		end
	end
end

function IsDisconnected(unit)
    if not unit or not IsValidEntity(unit) then
        return false
    end

    local playerid = unit:GetPlayerOwnerID()
    if not playerid then 
        return false
    end

    if unit:HasModifier("afk_anti_camp_modifier") then
        return true
    end

    local connection_state = PlayerResource:GetConnectionState(playerid) 
    if connection_state == DOTA_CONNECTION_STATE_ABANDONED or connection_state == DOTA_CONNECTION_STATE_DISCONNECTED then
        return true
    else
        return false
    end
end

function respawnOZ(keys)
	local caster = keys.caster
	local newPos = caster:GetAbsOrigin()
	if caster.spawnOrigin ~= nil then
		newPos = caster.spawnOrigin
	end

	local new_oz = ""
	if caster.unitName == "npc_dota_oz_11" then new_oz = "npc_dota_oz_22"
	elseif caster.unitName == "npc_dota_oz_22" then new_oz = "npc_dota_oz_33"
	elseif caster.unitName == "npc_dota_oz_33" then new_oz = "npc_dota_oz_44"
	elseif caster.unitName == "npc_dota_oz_44" then new_oz = "npc_dota_oz_55"
	elseif caster.unitName == "npc_dota_oz_55" then new_oz = "npc_dota_oz_66"
	elseif caster.unitName == "npc_dota_oz_66" then new_oz = "npc_dota_oz_77"
	elseif caster.unitName == "npc_dota_oz_77" then new_oz = "npc_dota_oz_88"
	elseif caster.unitName == "npc_dota_oz_88" then new_oz = "npc_dota_oz_99"
	elseif caster.unitName == "npc_dota_oz_99" then new_oz = "npc_dota_oz_100"
	elseif caster.unitName == "npc_dota_oz_100" then
		new_oz = "npc_dota_kyuubi"
	end

	CreateGoldCoin(caster:GetAbsOrigin(), caster.gold_coins)
	
	_G:GiveTeamGold(keys.attacker:GetTeamNumber(), caster:GetGoldBounty())

	if new_oz ~= "" then
		Timers:CreateTimer(60.0, function ()
			local oz_boss = CreateUnitByName(new_oz, newPos, true, nil, nil, DOTA_TEAM_NEUTRALS)
			oz_boss.spawnOrigin = newPos
			oz_boss.unitName = new_oz
			oz_boss.gold_coins = caster.gold_coins + 4

			if new_oz == "npc_dota_kyuubi" then
				_G.kyuubiSpawn = true

				MinimapEvent( DOTA_TEAM_GOODGUYS, oz_boss, oz_boss:GetAbsOrigin().x, oz_boss:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 4 )
				MinimapEvent( DOTA_TEAM_BADGUYS, oz_boss, oz_boss:GetAbsOrigin().x, oz_boss:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 4 )

				if GameRules.AddonTemplate.win_con == 2 then
					GameRules:SendCustomMessage("#bvo_kyuubi_spawn_message_win", 0, 0)
					CustomGameEventManager:Send_ServerToAllClients("display_healthbar", {} )
				else
					GameRules:SendCustomMessage("#bvo_kyuubi_spawn_message", 0, 0)
				end

				local neutralUnits = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,
	                              Vector(0, 0, 0),
	                              nil,
	                              FIND_UNITS_EVERYWHERE,
	                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)

	   			for _,unit in pairs(neutralUnits) do
	   				if unit.unitName == "npc_dota_infernal" then
						unit:Kill(nil, oz_boss)
					end
				end
			end
		end)
	end
end

function bvo_oz_single_stun_ai(keys)
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() then

		local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            800,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_CLOSEST,
	            false)

		for _,unit in pairs(localUnits) do

			local info = 
			{
				Target = unit,
				Source = caster,
				Ability = ability,	
				EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf",
		        iMoveSpeed = 1200,
				vSourceLoc= caster:GetAbsOrigin(),                -- Optional (HOW)
				bDrawsOnMinimap = false,                          -- Optional
		        bDodgeable = false,                                -- Optional
		        bIsAttack = false,                                -- Optional
		        bVisibleToEnemies = true,                         -- Optional
		        bReplaceExisting = false,                         -- Optional
		        flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
				bProvidesVision = false,                           -- Optional
				iVisionRadius = 400,                              -- Optional
				iVisionTeamNumber = caster:GetTeamNumber()        -- Optional
			}
			ProjectileManager:CreateTrackingProjectile(info)

			ability:StartCooldown(15.0)
			break
		end
	end
end

function bvo_kyuubi_aoe_stun_ai(keys)
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() then

		local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            600,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_CLOSEST,
	            false)

		if #localUnits > 0 then
			for _,unit in pairs(localUnits) do
				ability:ApplyDataDrivenModifier(caster, unit, "bvo_kyuubi_aoe_stun_modifier", {duration=2.0} )
			end
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle, 0, Vector(800, 0, 800))
			caster:EmitSound("Hero_Centaur.HoofStomp")
			ability:StartCooldown(20.0)
		end
	end
end

function CreateGoldCoin(pos, amount)
	local gc_table = {}
	for i = 1 , amount do
		local dummy = CreateUnitByName("npc_dummy_unit", pos, false, nil, nil, DOTA_TEAM_NEUTRALS)
		FindClearSpaceForUnit(dummy, pos, false)
	    dummy:AddAbility("custom_gold_coin_dummy")
	    local abl = dummy:FindAbilityByName("custom_gold_coin_dummy")
	    if abl ~= nil then abl:SetLevel(1) end
	    table.insert(gc_table, dummy)
	end
	for _,coin in pairs(gc_table) do
		local ability = coin:FindAbilityByName("custom_gold_coin_dummy")
		ability:ApplyDataDrivenModifier(coin, coin, "custom_phased_modifier", {} )
	end
end