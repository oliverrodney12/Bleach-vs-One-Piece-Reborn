require('timers')

function bvo_anzu_skill_0_init( keys )
	keys.caster.choreography = ""
end

function bvo_anzu_skill_0_update( keys )
	local point = keys.target_points[1]
	keys.caster.last_castPoint = point
end

function bvo_anzu_skill_0( keys )
	local caster = keys.caster
	local target = keys.target
	local cast_ability = keys.event_ability
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )

	if cast_ability == nil or cast_ability:IsNull() or cast_ability:IsItem() then return end	

	local combo = false
	if cast_ability:GetName() == "bvo_anzu_skill_1" then
		combo = true
	elseif cast_ability:GetName() == "bvo_anzu_skill_2" then
		combo = true
	elseif cast_ability:GetName() == "bvo_anzu_skill_3" then
		combo = true
	end
	if not combo then return end

	local mods = caster:FindAllModifiers()
	for _,mod in pairs(mods) do
		if mod:GetName() == "bvo_anzu_skill_0_hyper_modifier" then
			mod:ForceRefresh()
			break
		end
	end

	ability:ApplyDataDrivenModifier(caster, caster, "bvo_anzu_skill_0_hyper_modifier", {duration=duration})
 
	Timers:CreateTimer(0.1, function ()

		if cast_ability:GetName() == "bvo_anzu_skill_1" then
			caster.choreography = caster.choreography .. "Q"
		elseif cast_ability:GetName() == "bvo_anzu_skill_2" then
			caster.choreography = caster.choreography .. "W"
		elseif cast_ability:GetName() == "bvo_anzu_skill_3" then
			caster.choreography = caster.choreography .. "E"
		end

		if string.len(caster.choreography) == 3 then
			print("cast skill: " .. caster.choreography)

			local c_ability = caster:AddAbility("bvo_anzu_skill_" .. caster.choreography)
			if c_ability ~= nil then
				c_ability:SetLevel(1)

				local castType = string.sub(caster.choreography, 3, 3)

				caster:CastAbilityImmediately(c_ability, caster:GetPlayerOwnerID())
				--[[
				if castType == "Q" then
					caster:CastAbilityOnTarget(target, c_ability, caster:GetPlayerOwnerID())
				elseif castType == "W" then
					caster:CastAbilityOnTarget(target, c_ability, caster:GetPlayerOwnerID())
				elseif castType == "E" then
					caster:CastAbilityOnPosition(caster.last_castPoint, c_ability, caster:GetPlayerOwnerID())
				end
				]]
			end

			caster:RemoveModifierByName("bvo_anzu_skill_0_hyper_modifier")
		end

	end)
end

function bvo_anzu_skill_0_reset( keys )
	local caster = keys.caster

	caster.choreography = ""
	caster.c_target1 = nil
	caster.c_target2 = nil
	caster.c_target3 = nil
end

function bvo_anzu_skill_0_cast( keys )
	keys.caster:RemoveAbility(keys.ability:GetName())
end