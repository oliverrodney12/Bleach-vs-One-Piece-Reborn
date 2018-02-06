require('timers')

function respawn_self( keys )
	local caster = keys.caster
	local unit_point = caster.spawnOrigin
	local unit_name = caster.unitName
	local time = keys.time

	local model = "models/props_gameplay/tombstoneb01.vmdl"
	local grave = Entities:CreateByClassname("prop_dynamic")
	grave:SetModel(model)
	grave:SetAbsOrigin(unit_point)

	Timers:CreateTimer(time, function ()
		grave:RemoveSelf()
		local unit = CreateUnitByName(unit_name, unit_point, true, nil, nil, DOTA_TEAM_NEUTRALS)
		unit.originalPos = unit_point
		unit.spawnOrigin = unit_point
		unit.unitName = unit_name
	end)
end

function drop_item( keys )
	local caster = keys.caster
	local item = keys.item

	local newItem = CreateItem(item, nil, nil)
   	newItem:SetPurchaseTime(0)
   	local drop = CreateItemOnPositionSync( caster:GetAbsOrigin(), newItem )
end

function create_essence( keys )
	local caster = keys.caster
	local amount = keys.Amount

	local casterPos = caster:GetAbsOrigin()
	for i = 1 , amount do
		local dummy = CreateUnitByName("npc_dummy_unit", casterPos, false, nil, nil, DOTA_TEAM_NEUTRALS)
	    dummy:AddAbility("custom_essence_dummy")
	    local abl = dummy:FindAbilityByName("custom_essence_dummy")
	    if abl ~= nil then abl:SetLevel(1) end
	end
end