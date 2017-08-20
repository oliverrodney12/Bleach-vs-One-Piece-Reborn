require('timers')

function start(keys)
	local caster = keys.caster
	caster.ai_state = "idle"
	--items
	local item_list = {
		"item_boots",
		"item_belt_of_strength",
		"item_gloves",
		"item_belt_of_strength",
		"item_ogre_axe",
		"item_recipe_sange",
		"item_boots_of_elves",
		"item_blade_of_alacrity",
		"item_recipe_yasha",
		"item_lifesteal",
		"item_helm_of_iron_will",
		"item_vitality_booster",
	}
	--logical minimap info
	--creep camps
	local camp_points = {}
	for i = 1, 8 do
		camp_points[i] = Entities:FindByName( nil, "CREEP_SPAWNER_EASY_" .. i):GetAbsOrigin()
	end
	for i = 1, 4 do
		camp_points[i + 8] = Entities:FindByName( nil, "CREEP_SPAWNER_MEDIUM_" .. i):GetAbsOrigin()
	end
	for i = 1, 2 do
		--camp_points[i + 8 + 4] = Entities:FindByName( nil, "CREEP_SPAWNER_HARD_" .. i):GetAbsOrigin()
	end
	--camp_points[1 + 8 + 4 + 2] = Entities:FindByName( nil, "POINT_INFERNAL_CENTER"):GetAbsOrigin()
	caster.camp_points = camp_points
	caster.camp_info = {}
	caster.item_list = item_list
	--set base
	if GameRules.AddonTemplate.waygate == 1 then
		local base_point = Vector( 0, 0, 0 )
		if caster:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			base_point = Vector( -7040, -640, 257 )
		elseif caster:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			base_point = Vector( 7040, -640, 257 )
		end
		caster.base_point = base_point
	end
end

function think(keys)
	local caster = keys.caster
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return end
	--update info
	for _,point in pairs(caster.camp_points) do
		local localUnits = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,
		            point,
		            nil,
		            500,
		            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		            DOTA_UNIT_TARGET_BASIC,
		            DOTA_UNIT_TARGET_FLAG_NONE,
		            FIND_ANY_ORDER,
		            false)

		caster.camp_info[point] = #localUnits
	end
	--buy items if in base
	if (caster:GetAbsOrigin() - caster.base_point):Length2D() < 1000 and #caster.item_list > 0 then
		local cost_list = {}
		cost_list["item_boots"] = 500
		cost_list["item_gloves"] = 610
		cost_list["item_belt_of_strength"] = 450
		cost_list["item_blade_of_alacrity"] = 1000
		cost_list["item_boots_of_elves"] = 450
		cost_list["item_recipe_yasha"] = 800
		cost_list["item_ogre_axe"] = 1000
		cost_list["item_recipe_sange"] = 800
		cost_list["item_lifesteal"] = 900
		cost_list["item_helm_of_iron_will"] = 950
		cost_list["item_vitality_booster"] = 1100
		--buy item
		local item_cost = cost_list[caster.item_list[1]]
		if caster:GetGold() > item_cost then
			caster:AddItemByName( table.remove(caster.item_list, 1) )
			PlayerResource:SpendGold(caster:GetPlayerID(), item_cost, DOTA_ModifyGold_PurchaseItem)
		end
	end
	--act on state
	if caster.ai_state == "idle" then
		--get camp with most creeps
		local camp = caster.camp_points[1]
		for _,point in pairs(caster.camp_points) do
			if caster.camp_info[point] > caster.camp_info[camp] then
				camp = point
			end
		end
		--find closest waygate to camp
		local use_waygate = Vector( 0, 0, 0 )
		local base_waygate
		local waygate_point = {}
		for i = 1, 5 do
			waygate_point[i] = Entities:FindByName( nil, "TELE_POINT_" .. i):GetAbsOrigin()
		end
		for _,wp in pairs(waygate_point) do
			local difference = camp - wp
			if difference:Length2D() < (camp - use_waygate):Length2D() then
				use_waygate = wp
				for i = 1, 5 do
					if use_waygate == Entities:FindByName( nil, "TELE_POINT_" .. i):GetAbsOrigin() then
						base_waygate = Entities:FindByName( nil, "RADIANT_TELE_" .. i):GetAbsOrigin()
					end
				end
			end
		end
		--attack move
		if caster.base_point ~= nil and caster.base_point ~= Vector( 0, 0, 0 ) then
			CommandMoveToPosition(caster, caster.base_point, false)
			Timers:CreateTimer(4.0, function ()
				--move into waygate
				CommandMoveToPosition(caster, base_waygate, false)
				Timers:CreateTimer(4.0, function ()
					caster.current_camp = CommandMoveToPosition(caster, camp, true)
				end)
			end)
		else
			caster.current_camp = CommandMoveToPosition(caster, camp, true)
		end
		caster.ai_state = "farming"
	elseif caster.ai_state == "farming" then
		if caster.current_camp ~= nil then
			CommandMoveToPosition(caster, caster.current_camp, true)
			local difference = caster:GetAbsOrigin() - caster.current_camp
			if not caster:IsAttacking() and difference:Length2D() < 200 then
				local camp = Vector( 0, 0, 0 )
				for _,point in pairs(caster.camp_points) do
					if (caster:GetAbsOrigin() - point):Length2D() < (caster:GetAbsOrigin() - camp):Length2D() and point ~= caster.current_camp then
						camp = point
					end
				end
				caster.current_camp = CommandMoveToPosition(caster, camp, true)
			end
		end
	end
end

function CommandMoveToPosition(unit, vec, aggressive)
	if vec == nil then
		unit.ai_state = "idle"
		return
	end

	local z = GetGroundHeight( Vector( vec.x, vec.y, 128 ), nil)
	local o_vector = Vector( vec.x, vec.y, z )
	if aggressive then
		unit:MoveToPositionAggressive( o_vector )
		return o_vector
	else
		unit:MoveToPosition( o_vector )
		return o_vector
	end
end