require('timers')

function TeleToDuel( trigger ) -- Handels all duel teleportations (to and from, despite the name)
	local name = trigger.caller:GetName()
	local unit = trigger.activator
	if name == "MAP_TELE_TO_DUEL_DIRE" then
		--dire duel entrance
		if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			local point = Entities:FindByName( nil, "DUEL_POINT_DIRE_IN" ):GetAbsOrigin()
			use_teleporter(unit, point)
		end
	elseif name == "MAP_TELE_TO_DUEL_RADIANT" then
		--radiant duel entrance
		if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			local point = Entities:FindByName( nil, "DUEL_POINT_RADIANT_IN" ):GetAbsOrigin()
			use_teleporter(unit, point)
		end
	elseif name == "MAP_TELE_FROM_DUEL_RADIANT" then
		--radiant duel exit
		if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and not unit:HasModifier("modifier_induel") then
			local point = Entities:FindByName( nil, "DUEL_POINT_RADIANT_OUT" ):GetAbsOrigin()
			use_teleporter(unit, point)
		end
	elseif name == "MAP_TELE_FROM_DUEL_DIRE" then
		--dire duel exit
		if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS and not unit:HasModifier("modifier_induel") then
			local point = Entities:FindByName( nil, "DUEL_POINT_DIRE_OUT" ):GetAbsOrigin()
			use_teleporter(unit, point)
		end
	end
end

function TeleToArenaSW(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_ARENA_SW" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function TeleToArenaNW(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_ARENA_NW" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function TeleToArenaNE(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_ARENA_NE" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function TeleToSkeletonsNorth(trigger) -- Called when the player teleports from forbidden one back to skeleton area (northern part)
	local point = Entities:FindByName( nil, "BOSS_ARENA_CENTER" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function TeleToArenaC(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_ARENA_C" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function TeleToGolemWest(trigger) -- Called when the player wants to teleport to the western golem area
	local point = Entities:FindByName( nil, "TELE_POINT_GOLEMS_W" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

--function OnStartTouch7(trigger)
--	local point = Entities:FindByName( nil, "TELE_POINT_ARENA_SW" ):GetAbsOrigin()
--	use_teleporter(trigger.activator, point)
--end

function TeleportToForbiddenOne(trigger) -- Called when the player wants to teleport to the forbidden one (frost orb dropper, after bladebane)
	local point = Entities:FindByName( nil, "TELE_POINT_FORBIDDEN_ONE" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function TeleToRapier(trigger) --rapier tele in
	print("Teleporting into Rapier area")
	if trigger.activator:GetLevel() >= 20 then
		trigger.activator:SetMana(0)
		local point = Entities:FindByName( nil, "TELE_POINT_RAPIER" ):GetAbsOrigin()
		use_teleporter(trigger.activator, point)
	else
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", trigger.activator:GetPlayerOwner())
	end
end

function TeleToSouthArena(trigger) --rapier tele out
	print("Teleporting out of rapier area.")
	local point = Entities:FindByName( nil, "TELE_POINT_ARENA_S" ):GetAbsOrigin()
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

function TeleToSkeleton(trigger) -- Called when the player wants to teleport to the skeleton area
	local point = Entities:FindByName( nil, "TELE_POINT_SKELETONS" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function TeleToNorthArena(trigger) -- Called when the player wants to teleport from skeleton area back to the arena.
	local point = Entities:FindByName( nil, "TELE_POINT_ARENA_N" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function TeleToArenaSE(trigger)
	local point = Entities:FindByName( nil, "TELE_POINT_ARENA_SE" ):GetAbsOrigin()
	use_teleporter(trigger.activator, point)
end

function TeleToGolemEast(trigger) -- Called when the player wants to teleport to the eastern golem area
	local point = Entities:FindByName( nil, "TELE_POINT_GOLEMS_E" ):GetAbsOrigin()
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