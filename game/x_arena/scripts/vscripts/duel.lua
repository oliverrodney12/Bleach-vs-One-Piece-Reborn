require('timers')

DUEL_DURATION_MIN = 20
DUEL_INTERVAL = 240 -- 4min = 240
DUEL_DELAY = 3

function DuelStart(tHeroesRadiant, tHeroesDire)
	local DUEL_POINT_RADIANT = Entities:FindByName( nil, "DUEL_POINT_RADIANT_IN" ):GetAbsOrigin()
	local DUEL_POINT_DIRE = Entities:FindByName( nil, "DUEL_POINT_DIRE_IN" ):GetAbsOrigin()

	for _,hero in pairs(tHeroesRadiant) do
		if hero ~= nil and not hero:IsNull() and IsValidEntity(hero) and hero:IsRealHero() and hero:IsAlive() and IsConnected(hero) then
			CustomInterruptCheck(hero)
			FindClearSpaceForUnit(hero, DUEL_POINT_RADIANT, false)

			local pid = hero:GetPlayerOwnerID()
			PlayerResource:SetCameraTarget(pid, hero)
			Timers:CreateTimer(0.2, function()
				PlayerResource:SetCameraTarget(pid, nil)
			end)
			Timers:CreateTimer(2.0, function()
				hero:SetHealth(hero:GetMaxHealth())
            	hero:SetMana(hero:GetMaxMana())
            end)

            hero:AddNewModifier(hero, nil, "modifier_induel", {duration=DUEL_DURATION_MIN})
            hero:AddNewModifier(hero, nil, "modifier_dueldelay", {duration=DUEL_DELAY})
		end
	end
	for _,hero in pairs(tHeroesDire) do
		if hero ~= nil and not hero:IsNull() and IsValidEntity(hero) and hero:IsRealHero() and hero:IsAlive() and IsConnected(hero) then
			CustomInterruptCheck(hero)
			FindClearSpaceForUnit(hero, DUEL_POINT_DIRE, false)

			local pid = hero:GetPlayerOwnerID()
			PlayerResource:SetCameraTarget(pid, hero)
			Timers:CreateTimer(0.2, function()
				PlayerResource:SetCameraTarget(pid, nil)
			end)
			Timers:CreateTimer(2.0, function()
				hero:SetHealth(hero:GetMaxHealth())
            	hero:SetMana(hero:GetMaxMana())
            end)

            hero:AddNewModifier(hero, nil, "modifier_induel", {duration=DUEL_DURATION_MIN})
            hero:AddNewModifier(hero, nil, "modifier_dueldelay", {duration=DUEL_DELAY})
		end
	end
end
--[[
function GetMaximumAliveHeroes()
    local alive_radiant = 0
    for _,hero in pairs(_G:tHeroesRadiant) do
        if hero and IsValidEntity(hero) and hero:IsRealHero() and hero:IsAlive() and IsConnected(hero) then alive_radiant = alive_radiant + 1 end
    end

    local alive_dire = 0
    for _,hero in pairs(_G:tHeroesDire) do
        if hero and IsValidEntity(hero) and hero:IsRealHero() and hero:IsAlive() and IsConnected(hero) then alive_dire = alive_dire + 1 end
    end

    if alive_radiant > alive_dire then 
        return alive_radiant
    else 
        return alive_dire
    end
end
]]
function IsConnected(unit)
    return not IsDisconnected(unit)
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