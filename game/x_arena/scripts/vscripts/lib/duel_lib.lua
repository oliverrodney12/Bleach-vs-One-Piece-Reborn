require('lib/teleport')
require('timers')
DuelLibrary = class({})

local init
local duel_active = false
local duel_interval = 240
local duel_draw_time = 60+3
local duel_count = 0
local duel_radiant_warriors = {}
local duel_dire_warriors = {}
local duel_radiant_heroes = {}
local duel_dire_heroes = {}
local duel_end_callback
local duel_victory_team = 0

local duel_points = {
    radiant = {
        "RADIANT_DUEL_TELEPORT",
    },
    dire = {
        "DIRE_DUEL_TELEPORT",
    },
}

local tribune_points = {
    radiant = {
        "RADIANT_TRIBUNE",
        "RADIANT_TRIBUNE_1",
        "RADIANT_TRIBUNE_2",
        "RADIANT_TRIBUNE_3",
        "RADIANT_TRIBUNE_4",
        "RADIANT_TRIBUNE_5",
    },

    dire = {
        "DIRE_TRIBUNE",
        "DIRE_TRIBUNE_1",
        "DIRE_TRIBUNE_2",
        "DIRE_TRIBUNE_3",
        "DIRE_TRIBUNE_4",
        "DIRE_TRIBUNE_5",
    },
}

local base_points = {
    radiant = "RADIANT_BASE",
    dire = "DIRE_BASE",
}

local duel_trigger = "trigger_box_duel"

--/////////////////////////////////////////////////////////////////////////////////////////FUNCTIONS //////////////////////////////////////////////////////

function GetHeroesCount(radiant_heroes, dire_heroes)
    local rp = 0
    local dp = 0
    
    if not radiant_heroes or not dire_heroes then return end
    for _, x in pairs(radiant_heroes) do
        if x and x:IsRealHero() and IsConnected(x) then rp = rp + 1 end
    end
    
    for _, x in pairs(dire_heroes) do
        if x and x:IsRealHero() and IsConnected(x) then dp = dp + 1 end
    end

    return rp, dp
end

function ClearDuelFromHeroes(heroes_table)
    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) and x:IsRealHero() then
            x.IsDueled = false
        end
    end
end

function GetAliveHeroesCount(heroes_table)
    if not heroes_table then 
        print("[DS]ERROR in GetAliveHeroesCount, invalid table(nil table)")
        return 0
    end
    local lc = 0
    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) and x:IsRealHero() and x:IsAlive() and IsConnected(x) then
            lc = lc + 1
        end
    end
    return lc
end

function MoveHeroesToTribune(heroes_table, tribune_points_table)
    local cur = 1
    local max = #tribune_points_table
    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) and x:IsAlive() then
            CustomInterruptCheck(x)
            --end
            x.duel_old_point = x:GetAbsOrigin()
            TeleportUnitToPointName(x, tribune_points_table[cur], true, false)
            x:AddNewModifier(x, nil, "modifier_stun", {})

            cur = cur + 1
            cur = cur + 1
            if cur >= max then cur = 1 end
        end
    end
end

function CustomInterruptCheck( x )
    x:Stop()
    x:InterruptMotionControllers(true)
    if x:HasModifier("bvo_ikkaku_skill_5_modifier") then
        x:RemoveModifierByName("bvo_ikkaku_skill_5_modifier")
        ProjectileManager:DestroyLinearProjectile(x.projectile5)
    end
    if x:HasModifier("bvo_brook_skill_4_dance_caster") then
        x:DestroyAllSpeechBubbles()
        x:RemoveModifierByName("bvo_brook_skill_4_dance_caster")
        if x.polka_target:IsAlive() then
            x.polka_target:RemoveModifierByName("bvo_brook_skill_4_dance_target")
        end
    end
    if x:HasModifier("bvo_squall_skill_4_caster") then
        x:RemoveModifierByName("bvo_squall_skill_4_caster")
        if x.limit_break_target:IsAlive() then
            x.limit_break_target:RemoveModifierByName("bvo_squall_skill_4_target")
        end
        CustomGameEventManager:Send_ServerToPlayer(x:GetPlayerOwner(), "hide_limit_break", {} )
    end
    if x.law_skill_4_health ~= nil then
        x.law_skill_4_health = x:GetMaxHealth()
    end
    if x:HasModifier("bvo_anzu_skill_3_modifier") then
        x:RemoveModifierByName("bvo_anzu_skill_3_modifier")
    end
end

function MoveToDuel(duel_heroes, team_heroes, duel_points_table)
    local cur = 1
    local max = #duel_points_table 
    local first_time = false
    --port hero
    for _, x in pairs(duel_heroes) do
        CustomInterruptCheck(x)
        TeleportUnitToPointName(x, duel_points_table[cur], true, false)
        
        if x.duel_able_summons ~= nil then
            for _,summon in pairs(x.duel_able_summons) do
                TeleportUnitToPointName(summon, duel_points_table[cur], true, false)
                summon:AddNewModifier(hero, nil, "modifier_stun", {})
            end
        end
        --x.duel_cooldowns = SaveAbilitiesCooldowns(x)
        --ResetAllAbilitiesCooldown(x)
        Timers:CreateTimer(2.0, function()
            x:SetHealth(9999999)
            x:SetMana(9999999)
        end)

        local timer_info = {
            endTime = 1,
            callback = function()
                IsHeroOnDuel(x)
            return 1
        end
        }
        Timers:CreateTimer("duel_check_id" .. x:GetPlayerOwnerID(), timer_info)

        local duel_info = {
            endTime = draw_time,
            callback = function()
                EndDuel(radiant_heroes, dire_heroes, radiant_warriors, dire_warriors, end_duel_callback, 0)
                return nil
            end
        }
        Timers:CreateTimer("DS_DRAW_ITERNAL",duel_info)

        cur = cur + 1
        if cur >= max then cur = 1 end

        if first_time == false then
            for _, y in pairs(team_heroes) do
                SetPlayerCameraToEntity(y:GetPlayerOwnerID(), x)
            end
            first_time = true
        end
    end
end

function MoveToDuelHero(hero)
    if not hero or not IsValidEntity(hero) or not hero:IsRealHero() then
        print("[DS] Duel system error, this unit is not hero or not valid entity(iternal func MoveToDuelHero)");
        return
    end

    TeleportUnitToPointName(hero, "DUEL_ARENA_CENTER", true, true)
    hero:RemoveModifierByName("modifier_stun")
end

function IsHeroOnDuel(hero) 
    local point = hero:GetAbsOrigin() 
    local flag = true --NORMAL = FALSE
    for _,thing in pairs(Entities:FindAllInSphere(point, 10) )  do
        if (thing:GetName() == duel_trigger) then
            flag = true
        end
    end

    if not flag then MoveToDuelHero(hero) end
end

function RemoveHeroesFromDuel(heroes_table)
    if not heroes_table or type(heroes_table) ~= type({}) then
        print("[DS]Error, removeheroesfromduel, invalid heroes table!")
        return
    end

    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) then
            local point = x.duel_old_point
            if not point then
                point = Entities:FindByName(nil,  GetTeamPointNameByTeamNumber(base_points, x:GetTeamNumber())):GetAbsOrigin()
            end

            if x.duel_cooldowns then
                --SetAbilitiesCooldowns(x, x.duel_cooldowns)
                x.duel_cooldowns = nil
            end
            if x:IsAlive() then
                x:RemoveModifierByName('modifier_stun')
            end
            if point then
                if x:IsAlive() or x.ankh then
                    CustomInterruptCheck(x)
                    TeleportUnitToVector(x, point, true, true)
                end
                --port back summons
                if x.duel_able_summons ~= nil then
                    for _,summon in pairs(x.duel_able_summons) do
                        TeleportUnitToVector(summon, point, true, true)
                        summon:RemoveModifierByName('modifier_stun')
                    end
                end

                x.duel_old_point = nil
            else
                print("[DS] Duel system error, base points not found!")
            end
        end
    end
end

function GetHeroesToDuelFromTeamTable(heroes_table, hero_count)
    if GetAliveHeroesCount(heroes_table) < hero_count then
        print("[DS] Duel system error, alive heroes < hero count. Fix it!")
        return
    end

    local counter_local = 0;
    local output_table = {}
    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) and x:IsRealHero() and x:IsAlive() and x.IsDueled == false and IsConnected(x) then --x.IsDisconnect == false then
            x.IsDueled = true
            table.insert(output_table, x)
            counter_local = counter_local + 1
            if counter_local == hero_count then 
                return output_table 
            end
        end
    end

    if counter_local < hero_count then -- if some heroes already dueled
        ClearDuelFromHeroes(heroes_table) 
        return GetHeroesToDuelFromTeamTable(heroes_table, hero_count)
    end
end

function DuelLibrary:IsDuelActive()
    return duel_active
end

function DuelLibrary:ToTribune(hero)
    if not hero or not IsValidEntity(hero) or not hero:IsRealHero() then 
        print("[DS]Duel system error, invalid unit, expected hero (global func ToTribune)")
        return
    end
    local team = hero:GetTeamNumber()
    if team == DOTA_TEAM_GOODGUYS then
        for _, x in pairs(tribune_points.radiant) do
            TeleportUnitToPointName(hero, x, true, true)
            hero:AddNewModifier(hero, nil, "modifier_stun", {})
            return
        end
    else
        for _, x in pairs(tribune_points.dire) do
            TeleportUnitToPointName(hero, x, true, true)
            hero:AddNewModifier(hero, nil, "modifier_stun", {})
            return
        end
    end
end

function DuelLibrary:IsHeroDuelWarrior(hero)
    if not hero or not IsValidEntity(hero) or not hero:IsRealHero() then 
        return false
    end
    for _, x in pairs(duel_radiant_warriors) do
        if x == hero then return true end
    end
    for _, x in pairs(duel_dire_warriors) do
        if x == hero then return true end
    end
    return false
end

function EndDuel(radiant_heroes, dire_heroes, radiant_warriors, dire_warriors, end_duel_callback, duel_victory_team)
    duel_active = false
    if radiant_heroes and dire_heroes then
        if duel_victory_team ~= -1 then
            RemoveHeroesFromDuel(radiant_heroes)
            RemoveHeroesFromDuel(dire_heroes)
            for _, x in pairs(radiant_warriors) do
                Timers:RemoveTimer("duel_check_id".. x:GetPlayerOwnerID())
            end

            for _, x in pairs(dire_warriors) do
                Timers:RemoveTimer("duel_check_id".. x:GetPlayerOwnerID())
            end
            duel_radiant_warriors = {}
            duel_dire_warriors = {}
            duel_radiant_heroes = {}
            duel_dire_heroes = {}
        end
        if type(end_duel_callback) == "function" then
            end_duel_callback(duel_victory_team)
        end
    else
        print("[DS] ERROR, INVALID HEROES TABLE(EndDuel(...))")
    end
    --GameRules:SendCustomMessage("#duel_end", 0, 0) 
    Timers:RemoveTimer("DS_DRAW_ITERNAL")
    CustomGameEventManager:Send_ServerToAllClients("display_timer", {msg="#bvo_duel_next", duration=duel_interval, mode=0, endfade=true, position=0, warning=5, paused=false, sound=true} )
    --[[
    Timers:CreateTimer(2.0, function ()
        for _,hero in pairs(_G.tHeroesRadiant) do
            instant_anti_stuck(hero)
        end
        for _,hero in pairs(_G.tHeroesDire) do
            instant_anti_stuck(hero)
        end
    end)
    ]]
end

function instant_anti_stuck(stuckUnit)
    local hero = stuckUnit
    local base_point = Vector( 0, 0, 0 )
    if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        base_point = Entities:FindByName( nil, "RADIANT_BASE"):GetAbsOrigin()
    else
        base_point = Entities:FindByName( nil, "DIRE_BASE"):GetAbsOrigin()
    end
    
    --anti abuse
    local IsHeroStuck = false
    local stuckPoint = hero:GetAbsOrigin()
    if not GridNav:CanFindPath(base_point, stuckPoint) then
        IsHeroStuck = true
    end

    --except areas with teleporter
    local forgotten_point = Entities:FindByName( nil, "TELE_POINT_8"):GetAbsOrigin()
    local infernal_point = Entities:FindByName( nil, "POINT_INFERNAL_CENTER"):GetAbsOrigin()
    local rapier_point = Entities:FindByName( nil, "TELE_POINT_9"):GetAbsOrigin()
    local duel_point = Entities:FindByName( nil, "DUEL_ARENA_CENTER"):GetAbsOrigin()
    local boss_point = Entities:FindByName( nil, "BOSS_ARENA_CENTER"):GetAbsOrigin()
    local skeleton_point = Entities:FindByName( nil, "POINT_SKELETON_CENTER"):GetAbsOrigin()

    if GridNav:CanFindPath(forgotten_point, stuckPoint) or GridNav:CanFindPath(infernal_point, stuckPoint) or GridNav:CanFindPath(rapier_point, stuckPoint) or GridNav:CanFindPath(skeleton_point, stuckPoint) then
        IsHeroStuck = false
    end

    if GridNav:CanFindPath(duel_point, stuckPoint) and DuelLibrary:IsDuelActive() then
        IsHeroStuck = false
    end

    if GridNav:CanFindPath(boss_point, stuckPoint) and _G.IsBossArenaActive then
        IsHeroStuck = false
    end

    if IsHeroStuck then
        FindClearSpaceForUnit(hero, base_point, false)
    end
end

function DuelLibrary:GetDuelCount()
    return duel_count
end

function DuelLibrary:StartDuel(radiant_heroes, dire_heroes, hero_count, draw_time, error_callback, end_duel_callback)
    if not radiant_heroes or not dire_heroes then 
        local err ="[DS] Duel system error, {} tables of heroes! "
        print(err)
        return 
    end
    if duel_active == true then
        local err ="[DS] Duel system error, duel already started "
        print(err)
        if type(error_callback) == "function" then
            error_callback({ err_code = -1, err_string = err})
        end
        return
    end
    local radiant_count, dire_count = GetHeroesCount(radiant_heroes, dire_heroes)
    if (radiant_count < hero_count) or (dire_count < hero_count) or (hero_count <= 0) then 
        local err = "[DS] Duel system error, not enought players / invalid players count waiting for " .. hero_count .. " got rh = " .. radiant_count .. " dh = " .. dire_count
        print(err)
        --print_d(err)
        --GameRules:SendCustomMessage("#duel_error", 0, 0)
        EndDuel(radiant_heroes, dire_heroes, {}, {}, end_duel_callback, -1)
        if type(error_callback) == "function" then
            error_callback({ err_code = -2, err_string = err})
        end
        return
    end


    local radiant_warriors = GetHeroesToDuelFromTeamTable(radiant_heroes, hero_count)
    local dire_warriors = GetHeroesToDuelFromTeamTable(dire_heroes, hero_count)

    if (not radiant_warriors) or (not dire_warriors) then 
        local err = "[DS] Duel system error, not enought heroes for duel[2]. waiting "
        print(err)
        --print_d(err)
        --GameRules:SendCustomMessage("#duel_error", 0, 0) 
        EndDuel(radiant_heroes, dire_heroes, {}, {}, end_duel_callback, -1)
        if type(error_callback) == "function" then
            error_callback({ err_code = -2, err_string = err})
        end
        return
    end

    --GameRules:SendCustomMessage("#duel_start", 0, 0) 

    --remove illusions
    local allUnits = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                Vector(0, 0, 0),
                nil,
                FIND_UNITS_EVERYWHERE,
                DOTA_UNIT_TARGET_TEAM_BOTH,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)

    for _,unit in pairs(allUnits) do
        if unit:IsIllusion() then
            unit:RemoveSelf()
        end
    end

    duel_radiant_warriors = radiant_warriors
    duel_dire_warriors = dire_warriors
    duel_end_callback = end_duel_callback
    duel_radiant_heroes = radiant_heroes
    duel_dire_heroes = dire_heroes

    duel_count = duel_count + 1
    duel_active = true

    MoveHeroesToTribune(radiant_heroes, tribune_points.radiant)
    MoveHeroesToTribune(dire_heroes, tribune_points.dire)
    MoveToDuel(radiant_warriors, radiant_heroes, duel_points.radiant)
    MoveToDuel(dire_warriors, dire_heroes, duel_points.dire)

    local duel_info = {
        endTime = draw_time,
        callback = function()
            EndDuel(radiant_heroes, dire_heroes, radiant_warriors, dire_warriors, end_duel_callback, 0)
            return nil
        end
    }

    Timers:CreateTimer("DS_DRAW_ITERNAL",duel_info)

    CustomGameEventManager:Send_ServerToAllClients("display_timer", {msg="#bvo_duel_prep", duration=3, mode=0, endfade=true, position=0, warning=3, paused=false, sound=true} )
    Timers:CreateTimer(3.0, function ()
        for i,hero in pairs(radiant_warriors) do
            hero:RemoveModifierByName("modifier_stun")
            if hero.duel_able_summons ~= nil then
                for _,summon in pairs(hero.duel_able_summons) do
                    summon:RemoveModifierByName("modifier_stun")
                end
            end
        end
        for i,hero in pairs(dire_warriors) do
            hero:RemoveModifierByName("modifier_stun")
            if hero.duel_able_summons ~= nil then
                for _,summon in pairs(hero.duel_able_summons) do
                    summon:RemoveModifierByName("modifier_stun")
                end
            end
        end
        
        CustomGameEventManager:Send_ServerToAllClients("display_timer", {msg="#bvo_duel_draw", duration=duel_draw_time-3, mode=0, endfade=true, position=0, warning=5, paused=false, sound=true} )
    end)
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function _OnHeroDeathOnDuel(warriors_table, hero )
    for i, x in pairs(warriors_table) do
        if x == hero then
            table.remove(warriors_table, i)
            Timers:RemoveTimer("duel_check_id".. x:GetPlayerOwnerID())
            if #warriors_table == 0 then
                duel_victory_team = ((x:GetTeamNumber() == DOTA_TEAM_GOODGUYS) and DOTA_TEAM_BADGUYS) or ((x:GetTeamNumber() == DOTA_TEAM_BADGUYS) and DOTA_TEAM_GOODGUYS)
                EndDuel(duel_radiant_heroes, duel_dire_heroes, duel_radiant_warriors, duel_dire_warriors, duel_end_callback, duel_victory_team )
                --print("team victory = " , duel_victory_team)
            end
            return
        end
    end
end

function DeathListener( event )
    if not duel_active then return end
    local killedUnit = EntIndexToHScript( event.entindex_killed )
    local killedTeam = killedUnit:GetTeam()

    if event.entindex_attacker == nil then return end

    local hero = EntIndexToHScript( event.entindex_attacker )
    local heroTeam = hero:GetTeam()
    
    if not killedUnit or not IsValidEntity(killedUnit) or not killedUnit:IsRealHero() then return end

    if DuelLibrary:IsDuelActive() and not killedUnit.ankh then
       _OnHeroDeathOnDuel(duel_radiant_warriors, killedUnit )
       _OnHeroDeathOnDuel(duel_dire_warriors, killedUnit )
    end
end

function GetTeamPointNameByTeamNumber(table_of_points, teamnumber)
    if teamnumber == DOTA_TEAM_GOODGUYS then
        return table_of_points.radiant
    elseif teamnumber == DOTA_TEAM_BADGUYS then
        return table_of_points.dire
    else
    end
end

function SpawnListener(event)
    if not duel_active then return end
    local spawnedUnit = EntIndexToHScript( event.entindex )
    if not spawnedUnit or not IsValidEntity(spawnedUnit) or not spawnedUnit:IsRealHero() then
        return
    end

    Timers:CreateTimer(0.1, function ()
        if spawnedUnit:IsRealHero() and spawnedUnit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS then
            if DuelLibrary:IsDuelActive() and not DuelLibrary:IsHeroDuelWarrior(spawnedUnit) then
                DuelLibrary:ToTribune(spawnedUnit)
            end
        end
    end)
end

function SaveAbilitiesCooldowns(unit)
    if not unit then
        return
    end
    
    local savetable = {}
    local abilities = unit:GetAbilityCount() - 1
    for i = 0, abilities do
        if unit:GetAbilityByIndex(i) then
            savetable[i] = unit:GetAbilityByIndex(i):GetCooldownTimeRemaining()
            --print("Save Ability Cooldown abilityname='" .. unit:GetAbilityByIndex(i):GetAbilityName() .. "' cooldown = " .. savetable[i])
        end
    end

    return savetable
end

function SetAbilitiesCooldowns(unit, settable)
    local abilities = unit:GetAbilityCount() - 1
    if not settable or not unit then
        return
    end
    for i = 0, abilities do
        if unit:GetAbilityByIndex(i) then
            unit:GetAbilityByIndex(i):StartCooldown(settable[i])
            if settable[i] == 0 then 
                unit:GetAbilityByIndex(i):EndCooldown() 
            end
          --print("Set Ability Cooldown abilityname='" .. unit:GetAbilityByIndex(i):GetAbilityName() .. "' cooldown old = " .. settable[i])
        end
    end
end

function ResetAllAbilitiesCooldown(unit)

    if not unit then return end

    local abilities = unit:GetAbilityCount() - 1
    for i = 0, abilities do
        if unit:GetAbilityByIndex(i) then
            unit:GetAbilityByIndex(i):EndCooldown()
        end
    end
    for i = 0, 6 do
        if unit:GetItemInSlot(i) then
            unit:GetItemInSlot(i):EndCooldown()
        end
    end
end

function DuelLibrary:GetMaximumAliveHeroes(hero_table1, hero_table2)
    local alive_max = 0
    for _, x in pairs(hero_table1) do
        if x and IsValidEntity(x) and x:IsRealHero() and x:IsAlive() and IsConnected(x) then alive_max = alive_max + 1 end
    end

    local al = alive_max
    alive_max = 0
    for _, x in pairs(hero_table2) do
        if x and IsValidEntity(x) and x:IsRealHero() and x:IsAlive() and IsConnected(x) then alive_max = alive_max + 1 end
    end
    if alive_max > al then 
        return al 
    else 
        return alive_max 
    end
end


function IsConnected(unit)
    --[[if not unit or not IsValidEntity(unit) then return false end

    local playerid = unit:GetPlayerOwnerID()
    if not playerid then return false end

    local connection_state = PlayerResource:GetConnectionState(playerid) 
    if connection_state == DOTA_CONNECTION_STATE_CONNECTED then 
        return true 
    else 
        return false
    end]]
    return not IsDisconnected(unit)
end

function IsDisconnected(unit)
    if not unit or not IsValidEntity(unit) then
        return false
    end

    if _G.IsBossArenaActive ~= nil and unit == _G.IsBossArenaActive then
        return true
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

function IsAbadoned(unit)
    if not unit or not IsValidEntity(unit) then return false end

    local playerid = unit:GetPlayerOwnerID()
    if not playerid then return false end
    local connection_state = PlayerResource:GetConnectionState(playerid) 

    if connection_state == DOTA_CONNECTION_STATE_ABANDONED then 
        return true 
    else 
        return false
    end
end

ListenToGameEvent("entity_killed", DeathListener, nil)
ListenToGameEvent('npc_spawned', SpawnListener, nil )


function print_d(text)
    --CustomGameEventManager:Send_ServerToAllClients("DebugMessage", { msg = text})
end
