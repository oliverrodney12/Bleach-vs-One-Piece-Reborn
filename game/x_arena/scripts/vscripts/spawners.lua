local creeps_count = 0
local infernal_count = 0
local skeleton_count = 0

local easy_creeps = 
{
	"Wildwing_level_1",
	"Wildwing_level_4",
	"Worg_level_1",
	"Worg_level_4",
}

function SpawnNeutrals()
	if creeps_count > _G.CREEPS_LIMIT then
		return
	end
	SpawnEasyStack()
	SpawnMediumStack()
	SpawnHardStack()
end

function SpawnEasyStack()
	local point_easy = {}
	for i = 1, 8 do
		point_easy[i] = Entities:FindByName( nil, "CREEP_SPAWNER_EASY_" .. i):GetAbsOrigin()
	end

	local min = 2
	local max = 4

	if GameRules:GetGameTime() > 300 then -- 5 min
		local min = 3
		local max = 5
	end

	if GameRules:GetGameTime() > 600 then -- 10 min
		local min = 4
		local max = 6
	end

	if GameRules:GetGameTime() > 1200 then -- 20 min
		local min = 6
		local max = 8
	end

	local ds
	local cu
	for i = 1, 8 do
		ds = RandomInt(min, max)
		for x = 1, ds do
			cu = RandomInt(1, 4)
			local unit = CreateUnitByName(easy_creeps[cu], point_easy[i], true, nil, nil, DOTA_TEAM_NEUTRALS)
			unit.spawnOrigin = point_easy[i]
			unit.unitName = easy_creeps[cu]
		end
		creeps_count = creeps_count + ds
	end
end

local medium_creeps = 
{
	"Ogre_level_5",
	"Ogre_level_6",
	"Harpy_level_5",
}
local medium_spawners =
{
	"CREEP_SPAWNER_MEDIUM_1",
	"CREEP_SPAWNER_MEDIUM_2",
	"CREEP_SPAWNER_MEDIUM_3",
	"CREEP_SPAWNER_MEDIUM_4",
}
function SpawnMediumStack()
	local point_medium = {}
	for i = 1, #medium_spawners do
		point_medium[i] = Entities:FindByName( nil, medium_spawners[i]):GetAbsOrigin()
	end

	local min = 1
	local max = 3

	if GameRules:GetGameTime() > 300 then -- 5 min
		local min = 2
		local max = 4
	end

	if GameRules:GetGameTime() > 600 then -- 10 min
		local min = 3
		local max = 5
	end

	if GameRules:GetGameTime() > 1200 then -- 20 min
		local min = 5
		local max = 7
	end

	local ds
	local cu
	for i = 1, #point_medium do
		ds = RandomInt(min, max)
		for x = 1, ds do
			cu = RandomInt(1, #medium_creeps)
			local unit = CreateUnitByName(medium_creeps[cu], point_medium[i], true, nil, nil, DOTA_TEAM_NEUTRALS)
			unit.spawnOrigin = point_medium[i]
			unit.unitName = medium_creeps[cu]
		end
		creeps_count = creeps_count + ds
	end
end

local hard_creeps = 
{
	"Dragon_level_8",
	"Dragon_level_13",
	"Troll_level_11",
}
local hard_spawners =
{
	"CREEP_SPAWNER_HARD_1",
	"CREEP_SPAWNER_HARD_2",
}
function SpawnHardStack()
	local point_hard = {}
	for i = 1, #hard_spawners do
		point_hard[i] = Entities:FindByName( nil, hard_spawners[i]):GetAbsOrigin()
	end

	local min = 1
	local max = 1

	if GameRules:GetGameTime() > 300 then -- 5 min
		local min = 1
		local max = 2
	end

	if GameRules:GetGameTime() > 600 then -- 10 min
		local min = 2
		local max = 3
	end

	if GameRules:GetGameTime() > 1200 then -- 20 min
		local min = 3
		local max = 4
	end

	for i = 1, #point_hard do
		local ds = RandomInt(min, max)
		for x = 1, ds do
			local cu = RandomInt(1, #hard_creeps)
			local unit = CreateUnitByName(hard_creeps[cu], point_hard[i], true, nil, nil, DOTA_TEAM_NEUTRALS)
			unit.spawnOrigin = point_hard[i]
			unit.unitName = hard_creeps[cu]
		end
		creeps_count = creeps_count + ds
	end
end

function SpawnInfernals()
	if infernal_count >= 17 or _G.kyuubiSpawn then
		return
	end

	local point_infernal = Entities:FindByName( nil, "POINT_INFERNAL_CENTER"):GetAbsOrigin()
	local area_offset = Vector( RandomInt(-1700,1700), RandomInt(-900, 900), 0 )
	point_infernal = point_infernal + area_offset

	local unit = CreateUnitByName("npc_dota_infernal", point_infernal, true, nil, nil, DOTA_TEAM_NEUTRALS)
	unit.spawnOrigin = point_infernal
	unit.unitName = "npc_dota_infernal"
	infernal_count = infernal_count + 1
end

function SpawnSkeleton()
	if skeleton_count >= 9 then
		return
	end

	local point_skeleton = Entities:FindByName( nil, "POINT_SKELETON_CENTER"):GetAbsOrigin()
	local area_offset = Vector( RandomInt(-1472,1472), RandomInt(-1696, 1696), 0 )
	point_skeleton = point_skeleton + area_offset

	local unit = CreateUnitByName("npc_dota_skeleton", point_skeleton, true, nil, nil, DOTA_TEAM_NEUTRALS)
	unit.spawnOrigin = point_skeleton
	unit.unitName = "npc_dota_skeleton"
	skeleton_count = skeleton_count + 1
end

function IsUnitCreep(unit_name)
	for i = 1, 4 do
		if easy_creeps[i] == unit_name then
			return true
		end
	end
	for i = 1, 2 do
		if medium_creeps[i] == unit_name then
			return true
		end
	end
	for i = 1, 2 do
		if hard_creeps[i] == unit_name then
			return true
		end
	end
end

function OnCreepDeathGlobal()
	creeps_count = creeps_count - 1
end

function OnInfernalDeathGlobal(unit)
	infernal_count = infernal_count - 1

	if infernal_count == 0 and not _G.SHINOBU_EVENT_LEFT_LEG then
		_G.SHINOBU_EVENT_LEFT_LEG = true

		--_G:CreateDrop("item_shinobu_left_leg", unit:GetAbsOrigin(), false)
	end
end

function OnSkeletonDeathGlobal()
	skeleton_count = skeleton_count - 1
end

local all_runes = {
	--"bounty",
	"doubledamage",
	--"arcane",
	"haste",
	"illusion",
	"invisibility",
	"regen",
}

function SpawnRune()
	for i = 1, 4 do
		local pos = Entities:FindByName( nil, "RUNE_" .. i):GetAbsOrigin()

		local roll_rune = RandomInt(1, #all_runes)

		local dummy = CreateUnitByName("npc_dummy_unit", pos, false, nil, nil, DOTA_TEAM_NEUTRALS)
		dummy.rune_type = all_runes[roll_rune]

	    dummy:AddAbility("custom_rune_dummy")
	    local abl = dummy:FindAbilityByName("custom_rune_dummy")
	    if abl ~= nil then abl:SetLevel(1) end
	end
end