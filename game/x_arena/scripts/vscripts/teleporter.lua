require('timers')

function OnStartTouch0( trigger )
	local name = trigger.caller:GetName()
	local unit = trigger.activator
	if name == "MAP_TELE_12" then
		--dire duel entrance
		if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			local point = Entities:FindByName( nil, "DUEL_POINT_DIRE_IN" ):GetAbsOrigin()
			use_teleporter(unit, point)
		end
	elseif name == "MAP_TELE_13" then
		--radiant duel entrance
		if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			local point = Entities:FindByName( nil, "DUEL_POINT_RADIANT_IN" ):GetAbsOrigin()
			use_teleporter(unit, point)
		end
	elseif name == "MAP_TELE_14" then
		--radiant duel exit
		if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and not unit:HasModifier("modifier_induel") then
			local point = Entities:FindByName( nil, "DUEL_POINT_RADIANT_OUT" ):GetAbsOrigin()
			use_teleporter(unit, point)
		end
	elseif name == "MAP_TELE_16" then
		--dire duel exit
		if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS and not unit:HasModifier("modifier_induel") then
			local point = Entities:FindByName( nil, "DUEL_POINT_DIRE_OUT" ):GetAbsOrigin()
			use_teleporter(unit, point)
		end
	end
end

function OnStartTouch1(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_1" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function OnStartTouch2(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_2" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function OnStartTouch3(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_3" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function OnStartTouch4(trigger)
	local point = Entities:FindByName( nil, "BOSS_ARENA_CENTER" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function OnStartTouch5(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_5" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function OnStartTouch6(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_6" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function OnStartTouch7(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_1" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function OnStartTouch8(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_8" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function OnStartTouch9(trigger)--rapier tele in
	if trigger.activator:GetLevel() >= 20 then
		trigger.activator:SetMana(0)
		local point = Entities:FindByName( nil, "TELE_POINT_9" ):GetAbsOrigin()
		use_teleporter(trigger.activator, point)
	else
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", trigger.activator:GetPlayerOwner())
	end
end

function OnStartTouch10(trigger)--rapier tele out
	local point = Entities:FindByName( nil, "TELE_POINT_10" ):GetAbsOrigin()
	local unit = trigger.activator
	use_teleporter(trigger.activator, point)
	--rapier event
	for itemSlot=0,5 do
		local item = unit:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			if itemName == "item_rapier_custom" and _G.rapierEvent then
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

function OnStartTouch11(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_11" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function OnStartTouch12(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_12" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function OnStartTouch13(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_4" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function OnStartTouch14(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_13" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function use_teleporter(activator, point)
	if activator:GetClassname() == "npc_dota_hero_brewmaster" or activator:GetClassname() == "npc_dota_hero_legion_commander" then return end
	--activator:InterruptMotionControllers(true)
	FindClearSpaceForUnit(activator, point, false)
	activator:Stop()
	local playerid = activator:GetPlayerOwnerID()
	PlayerResource:SetCameraTarget(playerid, activator)
	Timers:CreateTimer(0.2, function()
		PlayerResource:SetCameraTarget(playerid, nil)
	end)
end