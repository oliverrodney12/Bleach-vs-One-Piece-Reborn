function BvOReborn:InitGameMode()
	print( "Loading addon..." )
	_G._self = self
    self.vUserIds = {}
    self.VoteTable = {}
    self.HeroBan = {}
    self.BannedHeroes = {}

    --Game rules
	GameRules:SetSafeToLeave(false)
    GameRules:SetShowcaseTime(0)
    GameRules:SetCustomGameSetupAutoLaunchDelay(0)
	GameRules:SetHeroSelectionTime(30)
	GameRules:SetStrategyTime(15)
	GameRules:SetPreGameTime(30)
    GameRules:SetPostGameTime(30)

	GameRules:SetHeroRespawnEnabled(true)
	GameRules:SetGoldTickTime(0.25)
	GameRules:SetTreeRegrowTime(176)
	GameRules:SetUseBaseGoldBountyOnHeroes(false)
    GameRules:SetCustomGameEndDelay(1)
	GameRules:SetSameHeroSelectionEnabled(false)
	GameRules:SetStartingGold(0)

	--Game mode
	local GameMode = GameRules:GetGameModeEntity()
	GameMode:SetFountainPercentageHealthRegen(10)
	GameMode:SetFountainPercentageManaRegen(10)
	GameMode:SetFountainConstantManaRegen(75)
	GameMode:SetUseCustomHeroLevels(true)  
	GameMode:SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
    GameMode:SetBuybackEnabled(false)
	GameMode:SetCustomHeroMaxLevel(100)
	GameMode:SetLoseGoldOnDeath(false)

	--Attribute derived values
	GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_DAMAGE, 1)--1
	GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP, 20)--20
	GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP_REGEN_PERCENT, 0.007)--0.007
	GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_STATUS_RESISTANCE_PERCENT, 0)--0.0015

	GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_DAMAGE, 1)--1
	GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ARMOR, 0.17)--0.17
	GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, 1)--1
	GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_MOVE_SPEED_PERCENT, 0)--0.0006

	GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_DAMAGE, 1)--1
	GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA, 12)--1
	GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN_PERCENT, 0.02)--0.02
	GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_SPELL_AMP_PERCENT, 0)--0.067
	GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MAGIC_RESISTANCE_PERCENT, 0)--0.0015

	--Filters
	GameMode:SetModifyGoldFilter( 			Dynamic_Wrap( BvOReborn, "FilterGold" ), self )
	GameMode:SetModifyExperienceFilter( 	Dynamic_Wrap( BvOReborn, "FilterExperience" ), self )

	-- Remove TP scrolls
	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(function(ctx, event)
	    local item = EntIndexToHScript(event.item_entindex_const)
	    if item:GetAbilityName() == "item_tpscroll" and item:GetPurchaser() == nil then return false end
	    return true
	end, self)

	--Random secret hero
	local randomSecretOn = false
	if randomSecretOn then
	 	Timers:CreateTimer(0.0, function ()
			RandomHeroThink()
			--End timer
			local flag = true
			for _,ply in pairs(self.vUserIds) do
				if ply:GetAssignedHero() == nil then
					flag = false
				end
				if flag then return nil end
			end
			return 0.03
		end)
	 end
	--Managers
	Timers:CreateTimer(1.0, function ()
		AbandonManager()
		TalentManager()
		return 1.0
	end)

	--Event hooks
	ListenToGameEvent('game_rules_state_change',		Dynamic_Wrap(BvOReborn, 'OnGameStateChange'), self)
	ListenToGameEvent('entity_killed',					Dynamic_Wrap(BvOReborn, 'OnEntityKilled'), self)
	ListenToGameEvent('npc_spawned',					Dynamic_Wrap(BvOReborn, 'OnHeroIngame'), self)
	ListenToGameEvent('dota_player_pick_hero', 			Dynamic_Wrap(BvOReborn, 'OnHeroPicked'), self)
	ListenToGameEvent('dota_item_picked_up',			Dynamic_Wrap(BvOReborn, 'OnPickUpItem'), self)
	ListenToGameEvent('player_chat', 					Dynamic_Wrap(BvOReborn, 'PlayerSay'), self)
	ListenToGameEvent('player_connect_full', 			Dynamic_Wrap(BvOReborn, 'OnConnectFull'), self)
	ListenToGameEvent('dota_rune_activated_server', 	Dynamic_Wrap(BvOReborn, 'OnRunePickup'), self)
	--ListenToGameEvent('player_team', 					Dynamic_Wrap(BvOReborn, 'OnTeamChange'), self)
	ListenToGameEvent('dota_item_purchased', 			Dynamic_Wrap(BvOReborn, 'OnItemPurchase'), self)
	--ListenToGameEvent('player_reconnected', 			Dynamic_Wrap(BvOReborn, 'OnPlayerReconnected'), self)
	ListenToGameEvent('dota_player_used_ability', 		ApplyCooldownReduction, {} )

	--Register UI Listener
	CustomGameEventManager:RegisterListener( "setting_vote", 	Dynamic_Wrap(BvOReborn, "OnSettingVote"))--gamemodes
	CustomGameEventManager:RegisterListener( "heroban_vote", 	Dynamic_Wrap(BvOReborn, "OnHeroBanVote"))--hero ban
	CustomGameEventManager:RegisterListener( "buy_custom_item", Dynamic_Wrap(BvOReborn, "BuyCustomItem"))--secret/medal shop
	CustomGameEventManager:RegisterListener( "buy_custom_item_2", Dynamic_Wrap(BvOReborn, "BuyCustomItem2"))--side/essence shop
	--CustomGameEventManager:RegisterListener( "token_pick", 		Dynamic_Wrap(BvOReborn, "OnTokenPick"))--pick token hero
	--CustomGameEventManager:RegisterListener( "vote_survey", 		Dynamic_Wrap(BvOReborn, "OnSurvey"))--survey 1
	CustomGameEventManager:RegisterListener( "cosmetic_change", 		Dynamic_Wrap(BvOReborn, "OnCosmeticChange"))--changed cosmetic
	CustomGameEventManager:RegisterListener( "custom_random_pick", 		Dynamic_Wrap(BvOReborn, "OnCustomRandomPick"))--clicked random button

	--Lua Modifiers
	LinkLuaModifier( "modifier_stun", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_medical_tractate", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_induel", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_lostduel", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_dueldelay", "modifiers/modifier_dueldelay", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_creepbuff", "modifiers/modifier_creepbuff", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_bvohero", "modifiers/modifier_bvohero", LUA_MODIFIER_MOTION_NONE )

	LinkLuaModifier( "bvo_rem_skill_2_modifier", "heroes/rem/modifiers/bvo_rem_skill_2_modifier", LUA_MODIFIER_MOTION_NONE )
	--Talents
	LinkLuaModifier( "bvo_special_bonus_magic_resist_25_modifier", "talents/bvo_special_bonus_magic_resist_25_modifier", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "bvo_special_bonus_armor_15_modifier", "talents/bvo_special_bonus_armor_15_modifier", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "bvo_special_bonus_health_650_modifier", "talents/bvo_special_bonus_health_650_modifier", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "bvo_special_bonus_evasion_15_modifier", "talents/bvo_special_bonus_evasion_15_modifier", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "bvo_special_bonus_attack_speed_80_modifier", "talents/bvo_special_bonus_attack_speed_80_modifier", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "bvo_special_bonus_damage_75_modifier", "talents/bvo_special_bonus_damage_75_modifier", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "bvo_special_bonus_lifesteal_10_modifier", "talents/bvo_special_bonus_lifesteal_10_modifier", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "bvo_special_bonus_reduced_damage_10_modifier", "talents/bvo_special_bonus_reduced_damage_10_modifier", LUA_MODIFIER_MOTION_NONE )

	--spawn icon dummys
	CreateUnitByName("npc_dota_tele_dummy_blue", Entities:FindByName( nil, "MAP_TELE_TO_GOLEMS_W"):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS) -- arena sw
	CreateUnitByName("npc_dota_tele_dummy_blue", Entities:FindByName( nil, "MAP_TELE_TO_ARENA_SW"):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS) -- golems sw

	CreateUnitByName("npc_dota_tele_dummy_green", Entities:FindByName( nil, "MAP_TELE_TO_SKELETON"):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS) -- arena to skeletons
	CreateUnitByName("npc_dota_tele_dummy_green", Entities:FindByName( nil, "MAP_TELE_TO_NORTH_ARENA"):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS) -- skeletons to arena

	CreateUnitByName("npc_dota_tele_dummy_red", Entities:FindByName( nil, "MAP_TELE_TO_RAPIER"):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS) -- arena to rapier
	CreateUnitByName("npc_dota_tele_dummy_red", Entities:FindByName( nil, "MAP_TELE_TO_SOUTH_ARENA"):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS) -- rapier to arena

	CreateUnitByName("npc_dota_tele_dummy_yellow", Entities:FindByName( nil, "MAP_TELE_TO_FORBIDDEN_ONE"):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS) -- skeletons to forbidden one
	CreateUnitByName("npc_dota_tele_dummy_yellow", Entities:FindByName( nil, "MAP_TELE_TO_SKELETONS_NORTH"):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS) -- forbidden one to skeletons
	--spawn rapier
	local rapier_spawn = Entities:FindByName( nil, "RAPIER_SPAWN"):GetAbsOrigin()
	_G:CreateDrop("item_rapier_custom", rapier_spawn, false)
	CreateUnitByName("npc_dota_vision_dummy", rapier_spawn, true, nil, nil, DOTA_TEAM_GOODGUYS)
	CreateUnitByName("npc_dota_vision_dummy", rapier_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)
	--AddFOWViewer( DOTA_TEAM_GOODGUYS, rapier_spawn, 8000, 600, false)
	--vision dummy rapier area
	local tele_point_9 = Entities:FindByName( nil, "TELE_POINT_RAPIER"):GetAbsOrigin() -- rapier area
	CreateUnitByName("npc_dota_vision_dummy", tele_point_9, true, nil, nil, DOTA_TEAM_GOODGUYS)
	CreateUnitByName("npc_dota_vision_dummy", tele_point_9, true, nil, nil, DOTA_TEAM_BADGUYS)
	--spawn fountain
	local fountain_spawn = Entities:FindByName( nil, "SPAWN_FOUNTAIN"):GetAbsOrigin()
	CreateUnitByName("npc_dota_neutral_fountain", fountain_spawn, true, nil, nil, DOTA_TEAM_NEUTRALS)
	--vision dummys mid
	--local midv_r = CreateUnitByName("npc_dota_vision_dummy", fountain_spawn, true, nil, nil, DOTA_TEAM_GOODGUYS)
	--local midv_d = CreateUnitByName("npc_dota_vision_dummy", fountain_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)
	--add mid truesight
	local gem_r = CreateItem("item_gem_custom", midv_r, midv_r)
	gem_r:ApplyDataDrivenModifier(midv_r, midv_r, "modifier_truesight_custom", {})
	gem_r:ApplyDataDrivenModifier(midv_d, midv_d, "modifier_truesight_custom", {})
	--vision dummy infernal
	local infernal_spawn = Entities:FindByName( nil, "POINT_INFERNAL_CENTER"):GetAbsOrigin()
	CreateUnitByName("npc_dota_vision_dummy", infernal_spawn, true, nil, nil, DOTA_TEAM_GOODGUYS)
	CreateUnitByName("npc_dota_vision_dummy", infernal_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)
	--vision dummy skeleton
	local skeleton_spawn = Entities:FindByName( nil, "POINT_SKELETON_CENTER"):GetAbsOrigin()
	CreateUnitByName("npc_dota_vision_dummy", skeleton_spawn, true, nil, nil, DOTA_TEAM_GOODGUYS)
	CreateUnitByName("npc_dota_vision_dummy", skeleton_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)
	--spawn oz
	local oz_boss = CreateUnitByName("npc_dota_oz_11", infernal_spawn, true, nil, nil, DOTA_TEAM_NEUTRALS)
	oz_boss.spawnOrigin = infernal_spawn
	oz_boss.unitName = "npc_dota_oz_11"
	oz_boss.gold_coins = 4
	--vision duel arena
	local arena_spawn = Entities:FindByName( nil, "DUEL_ARENA_CENTER"):GetAbsOrigin()
	local duel_vision_dummy1 = CreateUnitByName("npc_dota_vision_dummy", arena_spawn, true, nil, nil, DOTA_TEAM_GOODGUYS)
	local duel_vision_dummy2 = CreateUnitByName("npc_dota_vision_dummy", arena_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)
	--boss duel arena
	arena_spawn = Entities:FindByName( nil, "BOSS_ARENA_CENTER"):GetAbsOrigin()
	CreateUnitByName("npc_dota_vision_dummy", arena_spawn, true, nil, nil, DOTA_TEAM_GOODGUYS)
	CreateUnitByName("npc_dota_vision_dummy", arena_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)
	--add duel truesight
	gem_r:ApplyDataDrivenModifier(duel_vision_dummy1, duel_vision_dummy1, "modifier_truesight_custom_duel", {})
	gem_r:ApplyDataDrivenModifier(duel_vision_dummy2, duel_vision_dummy2, "modifier_truesight_custom_duel", {})
    gem_r:RemoveSelf()
	--corners
	local point_vision = {}
	for i = 1, 8 do
		point_vision[i] = Entities:FindByName( nil, "VISION_POINT_" .. i):GetAbsOrigin()
		CreateUnitByName("npc_dota_vision_dummy", point_vision[i], true, nil, nil, DOTA_TEAM_GOODGUYS)
		CreateUnitByName("npc_dota_vision_dummy", point_vision[i], true, nil, nil, DOTA_TEAM_BADGUYS)
	end
	--vision dummy fogotten one
	local TELE_POINT_FORBIDDEN_ONE = Entities:FindByName( nil, "TELE_POINT_FORBIDDEN_ONE"):GetAbsOrigin() -- forbidden one
	CreateUnitByName("npc_dota_vision_dummy", TELE_POINT_FORBIDDEN_ONE, true, nil, nil, DOTA_TEAM_GOODGUYS)
	CreateUnitByName("npc_dota_vision_dummy", TELE_POINT_FORBIDDEN_ONE, true, nil, nil, DOTA_TEAM_BADGUYS)
	--custom shop icons
	local custom_shop_point1 = Entities:FindByName( nil, "CUSTOM_SHOP_1"):GetAbsOrigin()
	CreateUnitByName("npc_dota_custom_shop_icon_dummy", custom_shop_point1, true, nil, nil, DOTA_TEAM_GOODGUYS)
	local custom_shop_point2 = Entities:FindByName( nil, "CUSTOM_SHOP_2"):GetAbsOrigin()
	CreateUnitByName("npc_dota_custom_shop_icon_dummy", custom_shop_point2, true, nil, nil, DOTA_TEAM_BADGUYS)
	local custom_shop_point3 = Entities:FindByName( nil, "CUSTOM_SHOP_3"):GetAbsOrigin()
	CreateUnitByName("npc_dota_custom_shop_icon_dummy", custom_shop_point3, true, nil, nil, DOTA_TEAM_GOODGUYS)
	CreateUnitByName("npc_dota_custom_shop_icon_dummy", custom_shop_point3, true, nil, nil, DOTA_TEAM_BADGUYS)
	--Setup rapier event
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
		for i = 1, 18 do
			if unit:GetName() == ("Siege_golem_" .. i) then
				unit:AddNewModifier(unit, nil, "modifier_stun", {})
				unit.originalPos = unit:GetAbsOrigin()
				unit.spawnOrigin = unit:GetAbsOrigin()
				unit.unitName = "npc_dota_siege_golem"
				table.insert(_G.rapierUnits, unit)
			end
		end
		if unit:GetName() == "forgotten_one" then
			unit.originalPos = unit:GetAbsOrigin()
			unit.spawnOrigin = unit:GetAbsOrigin()
			unit.unitName = "npc_dota_forgotten_one"
		end
	end
	--Setup custom hero pick
	--GameMode:SetCustomGameForceHero("npc_dota_hero_jakiro")
	--Reminder
	--[[
	local model_preview_units = {}
	local offset_x = (#hero_model_done / 2) * -128 - 64
	for _,mdl in pairs(hero_model_done) do
		local modelrow = Entities:FindByName(nil, "MODEL_ROW"):GetAbsOrigin()
		local modelpos = Vector(modelrow.x + offset_x, modelrow.y, modelrow.z)
		CreateUnitByName("npc_dota_vision_dummy_small", modelpos, true, nil, nil, DOTA_TEAM_GOODGUYS)
		CreateUnitByName("npc_dota_vision_dummy_small", modelpos, true, nil, nil, DOTA_TEAM_BADGUYS)
		local model = CreateUnitByName(mdl, modelpos, true, nil, nil, DOTA_TEAM_NEUTRALS)
		offset_x = offset_x + 128
		model:AddAbility("bvo_mana_on_hit")
		model:FindAbilityByName("bvo_mana_on_hit"):SetLevel(1)
		model:FindAbilityByName("bvo_mana_on_hit"):ApplyDataDrivenModifier(model, model, "bvo_model_dummy", {})
		table.insert(model_preview_units, model)
	end
	local anim_index = 1
	Timers:CreateTimer(5.0, function ()
		local activity = anim_index
		for _,munit in pairs(model_preview_units) do
			munit:StartGesture(hero_preview_animation[anim_index])
		end
		Timers:CreateTimer(4.0, function ()
			for _,munit in pairs(model_preview_units) do
				munit:RemoveGesture(hero_preview_animation[activity])
			end
		end)
		anim_index = anim_index + 1
		if anim_index > #hero_preview_animation then anim_index = 1 end
		return 5.0
	end)
	]]
	--Stats collection
	if GameRules:IsCheatMode() or IsInToolsMode() then
		print("Detected lobby with cheats on. No rating will be recorded.")
        IsStatsCollectionOn = false

        RECORD_RATING = false
	end
end

function _G:SayRunePickup( player, rune, hero )
	local color
	local runeName
	if rune == "haste" then
		color = "#ff0000"
		runeName = "Haste"
	elseif rune == "doubledamage" then
		color = "#00b4ff"
		runeName = "Double Damage"
	elseif rune == "regen" then
		color = "#00ff00"
		runeName = "Regen"
	elseif rune == "illusion" then
		color = "#ffff00"
		runeName = "Illusion"
	elseif rune == "invisibility" then
		color = "#8000ff"
		runeName = "Invisibility"
	else
		return
	end
	local hero_type = name_lookup[ hero:GetClassname() ]
	GameRules:SendCustomMessageToTeam("<font color='#00ff00'>" .. player .. "(" .. hero_type .. ")</font> activated a <font color='" .. color .. "'>" .. runeName .. "</font> rune.", hero:GetTeamNumber(), 0, 0)
end

function _G:PlaySoundFile( soundName, caller )
	for _,hero in pairs(_G.tHeroesRadiant) do
		if hero.playHeroVoice == 1 then
			if (caller:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < 3000 then
				EmitSoundOnClient(soundName, hero:GetPlayerOwner())
			end
		end
	end
	for _,hero in pairs(_G.tHeroesDire) do
		if hero.playHeroVoice == 1 then
			if (caller:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < 3000 then
				EmitSoundOnClient(soundName, hero:GetPlayerOwner())
			end
		end
	end
end

function _G:ToggleAbilities( hero, ability_visible, ability_hidden )
	local ability_visible_handle = hero:FindAbilityByName(ability_visible)

	local ability_visible_level = ability_visible_handle:GetLevel()
	local ability_visible_cooldown = ability_visible_handle:GetCooldownTimeRemaining()
	hero:RemoveAbility(ability_visible)

	local ability_hidden_handle = hero:AddAbility(ability_hidden)
	ability_hidden_handle:SetLevel(ability_visible_level)
	ability_hidden_handle:StartCooldown(ability_visible_cooldown)
end

function _G:CreateDrop(itemName, pos, launch)
   	local newItem = CreateItem(itemName, nil, nil)
   	newItem:SetPurchaseTime(0)
   	newItem.originalPos = pos
   	local drop = CreateItemOnPositionSync( pos, newItem )
   	if launch then
   		local direction = Vector( RandomInt(-10, 10), RandomInt(-10, 10), 0)
   		local vec = direction:Normalized() * 64
   		newItem:LaunchLoot(true, 256, 0.75, pos + vec)
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

function BvOReborn:OnPickUpItem(event)
	if event.HeroEntityIndex ~= nil and event.ItemEntityIndex ~= nil then

		local item = EntIndexToHScript(event.ItemEntityIndex)
		local hero = EntIndexToHScript(event.HeroEntityIndex)

		if event.itemname == "item_rapier_custom" then
			if _G.rapierEvent then
				local max = hero:GetMaxHealth()
				local current = hero:GetHealth()
				if max * 0.4 < current then
					hero:SetHealth(max * 0.4)
				end

				for _,unit in pairs(_G.rapierUnits) do
					unit:RemoveModifierByName("modifier_stun")
				end
			end
		end
	end
end

function sendWinInfo()
	local wincon = GameRules.AddonTemplate.win_con
	if wincon == 1 then
   		CustomGameEventManager:Send_ServerToAllClients("display_win_con", {mode=wincon, info=killLimit} )
   	elseif wincon == 2 then
		CustomGameEventManager:Send_ServerToAllClients("display_win_con", {mode=wincon, info="∞"} )
	elseif wincon == 3 then
		local winInfo = _G.RadiantWonDuels .. ":" .. _G.DireWonDuels
		CustomGameEventManager:Send_ServerToAllClients("display_win_con", {mode=wincon, info=winInfo} )
	end
end

function _G:ApplyCustomCosmetics(player, hero)
	if player ~= nil and player.cosmetics ~= nil then
		--Hat
		local hat_id = player.cosmetics["hat"]
		if hat_id == 1 then
			local particleName = "particles/hat/crown_alt.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, hero)
		elseif hat_id == 2 then
			local particleName = "particles/hat/halo.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, hero)
		end
		--Wings
		local wings_id = player.cosmetics["wings"]
		if wings_id == 1 then
			--local particleName = "particles/wings/holy_wings.vpcf"
			--local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, hero)
			--[[
			attachCosmetic( {
						unit = hero,
						scale = 1.0,
						pitch = 0,
						yaw = 90,
						roll = 0,
						attachPoint = "follow_origin",
						offset = Vector(0,0,0),
						model = "models/heroes/omniknight/omniknightwings.vmdl",
						} )
						]]
		end
		--Trail
		local trail_id = player.cosmetics["trail"]
		if trail_id == 1 then
			local particleName = "particles/trail/trail_grass.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, hero)
		end
	end
end

function InitHeroSetup(event)
	local hero = EntIndexToHScript(event.heroindex)

	if hero then
		if hero:GetTeamNumber() == DOTA_TEAM_NEUTRALS then return end --or else brewmaster would be counted aswell
		if not hero:IsRealHero() or hero:IsIllusion() then return end

		--Cosmetics
		_G:ApplyCustomCosmetics( PlayerResource:GetPlayer(event.player-1), hero )

		if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
	   		table.insert(tHeroesRadiant, hero)
	   		tHeroesRadiant[#tHeroesRadiant].medical_tractates = 0
	   		tHeroesRadiant[#tHeroesRadiant].medals = 0
	   		tHeroesRadiant[#tHeroesRadiant].TotalMedals = 0
	   		tHeroesRadiant[#tHeroesRadiant].permaAtt = false

	   		tHeroesRadiant[#tHeroesRadiant].boss_1_essences = 0

	   		tHeroesRadiant[#tHeroesRadiant].abandonCounter = 0
	   		tHeroesRadiant[#tHeroesRadiant].HasAbandoned = false
	   	elseif hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
	   		table.insert(tHeroesDire, hero)
	   		tHeroesDire[#tHeroesDire].medical_tractates = 0
	   		tHeroesDire[#tHeroesDire].medals = 0
	   		tHeroesDire[#tHeroesDire].TotalMedals = 0
	   		tHeroesDire[#tHeroesDire].permaAtt = false

	   		tHeroesDire[#tHeroesDire].boss_1_essences = 0

	   		tHeroesDire[#tHeroesDire].abandonCounter = 0
	   		tHeroesDire[#tHeroesDire].HasAbandoned = false
	   	end

	   	sendWinInfo()

	   	local attachPoint = "attach_head"
	   	local attachZ = 138
	   	local attachX = 8
	   	local attachY = 0
	   	local attachSize = 1.0

	   	local count = PlayerResource:GetPlayerCountForTeam(hero:GetTeamNumber())
	   	hero:SetGold(4800 / count, true)
	   	hero:AddAbility("bvo_mana_on_hit")
	   	local ai_skill = hero:FindAbilityByName("bvo_mana_on_hit")
		ai_skill:SetLevel(1)
		if PlayerResource:IsFakeClient(hero:GetPlayerID()) then
			--ai_skill:ApplyDataDrivenModifier(hero, hero, "bvo_bot_ai_modifier", {} )
		end

		hero.ankh = false
		--Add extra skills
		local name = hero:GetUnitName()
		if name == "npc_dota_hero_juggernaut" then
			hero:FindAbilityByName("bvo_ichigo_skill_0"):SetLevel(1)
			hero:AddAbility("bvo_ichigo_skill_4_extra")
			hero:FindAbilityByName("bvo_ichigo_skill_4_extra"):SetHidden(true)

			hero:AddAbility("bvo_ichigo_skill_4")
			hero:FindAbilityByName("bvo_ichigo_skill_4"):SetHidden(true)
			hero:AddAbility("bvo_ichigo_skill_5")
			hero:FindAbilityByName("bvo_ichigo_skill_5"):SetHidden(true)
	
			attachZ = 178
	   		attachX = 30
	   		attachSize = 1.5

		elseif name == "npc_dota_hero_zuus" then
			hero:FindAbilityByName("bvo_enel_skill_0"):SetLevel(1)

			attachZ = 178
	   		attachX = -14
	   		attachSize = 1.5

		elseif name == "npc_dota_hero_ember_spirit" then
			hero:FindAbilityByName("bvo_ace_skill_0"):SetLevel(1)

			attachZ = 156
	   		attachX = 0
	   		attachY = 4
	   		attachSize = 1.0

		elseif name == "npc_dota_hero_antimage" then
			hero:FindAbilityByName("bvo_mihawk_skill_0"):SetLevel(1)

			attachZ = 176
	   		attachX = 10
	   		attachY = 2
	   		attachSize = 1.5

		elseif name == "npc_dota_hero_luna" then
			hero:FindAbilityByName("bvo_orihime_skill_0"):SetLevel(1)

			attachZ = 150
   			attachX = 10
   			attachY = -14
   			attachSize = 1.0
		elseif name == "npc_dota_hero_sniper" then
			hero:FindAbilityByName("bvo_ishida_skill_0"):SetLevel(1)

			attachZ = 162
   			attachX = 6
   			attachY = -2
   			attachSize = 1.0
		elseif name == "npc_dota_hero_doom_bringer" then
			hero:FindAbilityByName("bvo_yamamoto_skill_0"):SetLevel(1)

			attachZ = 156
   			attachX = 4
   			attachY = 0
   			attachSize = 1.0
		elseif name == "npc_dota_hero_dragon_knight" then
			hero:FindAbilityByName("bvo_zaraki_skill_0"):SetLevel(1)
			hero:AddAbility("bvo_zaraki_skill_3_extra")
			hero:FindAbilityByName("bvo_zaraki_skill_3_extra"):SetLevel(1)
			hero:FindAbilityByName("bvo_zaraki_skill_3_extra"):SetHidden(true)
			hero:AddAbility("bvo_zaraki_skill_5")
			hero:FindAbilityByName("bvo_zaraki_skill_5"):SetHidden(true)

			attachZ = 160
   			attachX = 22
   			attachY = 0
   			attachSize = 1.0
		elseif name == "npc_dota_hero_riki" then
			hero:FindAbilityByName("bvo_luffy_skill_0"):SetLevel(1)
			hero:FindAbilityByName("bvo_luffy_skill_0"):SetHidden(true)
			
			hero:FindAbilityByName("bvo_luffy_skill_4_soru"):SetLevel(1)
			hero:FindAbilityByName("bvo_luffy_skill_4_soru"):SetHidden(true)

			attachZ = 150
   			attachX = -6
   			attachY = -2
   			attachSize = 1.5
		elseif name == "npc_dota_hero_sven" then
			hero:FindAbilityByName("bvo_zoro_skill_0"):SetLevel(1)

			attachZ = 166
   			attachX = 14
   			attachY = 0
   			attachSize = 1.0
		elseif name == "npc_dota_hero_lycan" then
			hero:FindAbilityByName("bvo_crocodile_skill_0"):SetLevel(1)

			attachZ = 190
   			attachX = 4
   			attachY = 0
   			attachSize = 1.0
		elseif name == "npc_dota_hero_phantom_assassin" then
			hero:FindAbilityByName("bvo_soifon_skill_0"):SetLevel(1)

			attachZ = 138
   			attachX = -2
   			attachY = 0
   			attachSize = 1.0
		elseif name == "npc_dota_hero_kunkka" then
			hero:FindAbilityByName("bvo_byakuya_skill_0"):SetLevel(1)
			hero:AddAbility("bvo_byakuya_skill_1_off")
			hero:FindAbilityByName("bvo_byakuya_skill_1_off"):SetLevel(1)
			hero:FindAbilityByName("bvo_byakuya_skill_1_off"):SetHidden(true)
			hero:AddAbility("bvo_byakuya_skill_4_off")
			hero:FindAbilityByName("bvo_byakuya_skill_4_off"):SetLevel(1)
			hero:FindAbilityByName("bvo_byakuya_skill_4_off"):SetHidden(true)

			attachZ = 142
   			attachX = 38
   			attachY = 0
   			attachSize = 1.0
		elseif name == "npc_dota_hero_skeleton_king" then
			hero:FindAbilityByName("bvo_toshiro_skill_0"):SetLevel(1)
			hero:AddAbility("bvo_toshiro_skill_2_bankai")
			hero:FindAbilityByName("bvo_toshiro_skill_2_bankai"):SetLevel(1)
			hero:FindAbilityByName("bvo_toshiro_skill_2_bankai"):SetHidden(true)
			hero:AddAbility("bvo_toshiro_skill_4")
			hero:FindAbilityByName("bvo_toshiro_skill_4"):SetHidden(true)

			hero:AddAbility("bvo_toshiro_skill_5")
			hero:FindAbilityByName("bvo_toshiro_skill_5"):SetHidden(true)

			attachPoint = "follow_overhead"
			attachZ = 120
   			attachX = 20
   			attachSize = 2.0
		elseif name == "npc_dota_hero_naga_siren" then
			hero:FindAbilityByName("bvo_rukia_skill_0"):SetLevel(1)
			hero:AddAbility("bvo_rukia_skill_5")
			hero:FindAbilityByName("bvo_rukia_skill_5"):SetHidden(true)

			attachZ = 138
   			attachX = -4
   			attachY = -2
   			attachSize = 1.0
		elseif name == "npc_dota_hero_slark" then
			hero:FindAbilityByName("bvo_hollow_skill_0"):SetLevel(1)
			hero:AddAbility("bvo_hollow_skill_1_bankai")
			hero:FindAbilityByName("bvo_hollow_skill_1_bankai"):SetHidden(true)
			hero:AddAbility("bvo_hollow_skill_4_extra")
			hero:FindAbilityByName("bvo_hollow_skill_4_extra"):SetHidden(true)
			hero:AddAbility("bvo_hollow_skill_5")
			hero:FindAbilityByName("bvo_hollow_skill_5"):SetHidden(true)
			hero:AddAbility("bvo_hollow_skill_5_extra")
			hero:FindAbilityByName("bvo_hollow_skill_5_extra"):SetHidden(true)

			attachZ = 178
	   		attachX = 30
	   		attachSize = 1.5
		elseif name == "npc_dota_hero_night_stalker" then
			hero:FindAbilityByName("bvo_lucci_skill_0"):SetLevel(1)

			attachZ = 146
   			attachX = 36
   			attachY = -8
   			attachSize = 1.0
		elseif name == "npc_dota_hero_bane" then
			hero:FindAbilityByName("bvo_moria_skill_0"):SetLevel(1)

			attachZ = 224
   			attachX = 6
   			attachY = -2
   			attachSize = 1.0
		elseif name == "npc_dota_hero_elder_titan" then
			hero:FindAbilityByName("bvo_sanji_skill_0"):SetLevel(1)
			hero:AddAbility("bvo_sanji_skill_4")
			hero:FindAbilityByName("bvo_sanji_skill_4"):SetHidden(true)
			hero:AddAbility("bvo_sanji_skill_5")
			hero:FindAbilityByName("bvo_sanji_skill_5"):SetHidden(true)

			attachZ = 166
   			attachX = 12
   			attachY = 0
   			attachSize = 1.0
		elseif name == "npc_dota_hero_techies" then
			hero:FindAbilityByName("bvo_usopp_skill_0"):SetLevel(1)
			hero:AddAbility("bvo_usopp_skill_0_use")
			hero:FindAbilityByName("bvo_usopp_skill_0_use"):SetLevel(1)
			hero:FindAbilityByName("bvo_usopp_skill_0_use"):SetHidden(true)

			hero:AddAbility("bvo_usopp_skill_5_extra")
			hero:FindAbilityByName("bvo_usopp_skill_5_extra"):SetHidden(true)

			hero:FindAbilityByName("bvo_usopp_skill_5"):SetLevel(0)

			attachZ = 148
   			attachX = 20
   			attachY = 0
   			attachSize = 1.0
		elseif name == "npc_dota_hero_lina" then
			hero:FindAbilityByName("bvo_nami_skill_0"):SetLevel(1)

			attachZ = 154
   			attachX = -10
   			attachY = -4
   			attachSize = 1.5
		elseif name == "npc_dota_hero_phantom_lancer" then
			hero:FindAbilityByName("bvo_aokiji_skill_0"):SetLevel(1)

			attachZ = 178
   			attachX = -4
   			attachY = 0
   			attachSize = 1.0
		elseif name == "npc_dota_hero_spectre" then
			hero:FindAbilityByName("bvo_yoruichi_skill_0"):SetLevel(1)
			hero:AddAbility("bvo_yoruichi_skill_5")
			hero:FindAbilityByName("bvo_yoruichi_skill_5"):SetHidden(true)

			attachZ = 156
   			attachX = 0
   			attachY = 0
   			attachSize = 1.0
		elseif name == "npc_dota_hero_queenofpain" then
			hero:FindAbilityByName("bvo_shinobu_skill_0"):SetLevel(1)

			attachZ = 132
   			attachX = 0
   			attachY = 4
   			attachSize = 1.5
		elseif name == "npc_dota_hero_keeper_of_the_light" then
			hero:FindAbilityByName("bvo_kuma_skill_0"):SetLevel(1)

			attachZ = 212
   			attachX = 0
   			attachY = 0
   			attachSize = 1.0
		elseif name == "npc_dota_hero_beastmaster" then
			hero:FindAbilityByName("bvo_brook_skill_0"):SetLevel(1)

			attachZ = 138
	   		attachX = -8
	   		attachSize = 1.0
		elseif name == "npc_dota_hero_mirana" then
			hero:FindAbilityByName("bvo_robin_skill_0"):SetLevel(1)
			
			attachZ = 156
	   		attachX = -4
	   		attachSize = 1.5
	   		--
	   		local heroPos2 = hero:GetAbsOrigin()
	   		local heroForward2 = hero:GetForwardVector()

			local dummy2 = CreateUnitByName("npc_dummy_unit", heroPos2, false, nil, nil, hero:GetTeam())
			dummy2:SetForwardVector(heroForward2)
			dummy2:AddAbility("custom_point_dummy")
			local abl = dummy2:FindAbilityByName("custom_point_dummy")
			if abl ~= nil then abl:SetLevel(1) end
			dummy2:SetModel("models/heroes/omniknight/omniknightwings.vmdl")
			dummy2:SetOriginalModel("models/heroes/omniknight/omniknightwings.vmdl")
			dummy2:SetModelScale(1.0)
			local vec_up2 = Vector( heroPos2.x, heroPos2.y, heroPos2.z + 130 )
			local rotation2 = QAngle( 0, 90, 0 )
			local rot_vector2 = RotatePosition(heroPos2, rotation2, heroPos2 + heroForward2 * 100)
 			local pos12 = ((rot_vector2 - heroPos2):Normalized() * 0)
			dummy2:SetAbsOrigin(vec_up2 + heroForward2 * 0 + pos12)
			dummy2:SetParent(hero, "attach_origin")
			hero.wing_dummy = dummy2
			hero.wing_dummy.parent = hero
			dummy2:AddNoDraw()
		elseif name == "npc_dota_hero_troll_warlord" then
			hero:FindAbilityByName("bvo_ikkaku_skill_0"):SetLevel(1)
			hero:AddAbility("bvo_ikkaku_skill_4")
			hero:FindAbilityByName("bvo_ikkaku_skill_4"):SetHidden(true)
			hero:AddAbility("bvo_ikkaku_skill_5")
			hero:FindAbilityByName("bvo_ikkaku_skill_5"):SetHidden(true)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_terrorblade" then
			hero:FindAbilityByName("bvo_tousen_skill_0"):SetLevel(1)
			hero:AddAbility("bvo_tousen_skill_1_off")
			hero:FindAbilityByName("bvo_tousen_skill_1_off"):SetHidden(true)
			hero:AddAbility("bvo_tousen_skill_4_off")
			hero:FindAbilityByName("bvo_tousen_skill_4_off"):SetHidden(true)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_bloodseeker" then
			hero:FindAbilityByName("bvo_renji_skill_0"):SetLevel(1)
			hero:AddAbility("bvo_renji_skill_1_off")
			hero:FindAbilityByName("bvo_renji_skill_1_off"):SetHidden(true)
			hero:AddAbility("bvo_renji_skill_4_off")
			hero:FindAbilityByName("bvo_renji_skill_4_off"):SetHidden(true)
			hero:AddAbility("bvo_renji_skill_3_off")
			hero:FindAbilityByName("bvo_renji_skill_3_off"):SetHidden(true)
			hero:AddAbility("bvo_renji_skill_5")
			hero:FindAbilityByName("bvo_renji_skill_5"):SetHidden(true)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_slardar" then
			hero:FindAbilityByName("bvo_sado_skill_0"):SetLevel(1)
			hero:AddAbility("bvo_sado_skill_5")
			hero:FindAbilityByName("bvo_sado_skill_5"):SetHidden(true)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_windrunner" then
			hero:FindAbilityByName("bvo_megumin_skill_0"):SetLevel(1)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_axe" then
			hero:FindAbilityByName("bvo_squall_skill_0"):SetLevel(1)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_necrolyte" then
			hero:AddAbility("bvo_mayuri_skill_1_cast")
			hero:FindAbilityByName("bvo_mayuri_skill_1_cast"):SetLevel(1)
			hero:FindAbilityByName("bvo_mayuri_skill_1_cast"):SetHidden(true)

			hero:FindAbilityByName("bvo_mayuri_skill_0"):SetLevel(1)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_huskar" then
			hero:FindAbilityByName("bvo_law_skill_0"):SetLevel(1)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_earthshaker" then
			hero:FindAbilityByName("bvo_whitebeard_skill_0"):SetLevel(1)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_centaur" then
			hero:FindAbilityByName("bvo_aizen_skill_0"):SetLevel(1)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_templar_assassin" then
			hero:FindAbilityByName("bvo_rory_skill_0"):SetLevel(1)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_enigma" then
			hero:FindAbilityByName("bvo_ulquiorra_skill_0"):SetLevel(1)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_enchantress" then
			hero:FindAbilityByName("bvo_anzu_skill_0"):SetLevel(1)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_vengefulspirit" then
			hero:FindAbilityByName("bvo_rem_skill_0"):SetLevel(1)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_phoenix" then
			hero:FindAbilityByName("bvo_kissshot_skill_0"):SetLevel(1)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_ursa" then
			hero:FindAbilityByName("bvo_akainu_skill_0"):SetLevel(1)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		elseif name == "npc_dota_hero_dark_willow" then
			hero:FindAbilityByName("bvo_perona_skill_0"):SetLevel(1)

			--attachZ = 138
	   		--attachX = -8
	   		--attachSize = 1.0
		end

		--put santa hat on
	   	local putHatOn = false
	   	if putHatOn then
	   		local heroPos = hero:GetAbsOrigin()
	   		local heroForward = hero:GetForwardVector()

			local dummy = CreateUnitByName("npc_dummy_unit", heroPos, false, nil, nil, hero:GetTeam())
			dummy:SetForwardVector(heroForward)
			dummy:AddAbility("custom_point_dummy")
			local abl = dummy:FindAbilityByName("custom_point_dummy")
			if abl ~= nil then abl:SetLevel(1) end
			dummy:SetModel("models/santa_hat/santa_hat.vmdl")
			dummy:SetOriginalModel("models/santa_hat/santa_hat.vmdl")
			dummy:SetModelScale(attachSize)
			local vec_up = Vector( heroPos.x, heroPos.y, heroPos.z + attachZ )
			local rotation = QAngle( 0, 90, 0 )
			local rot_vector = RotatePosition(heroPos, rotation, heroPos + heroForward * 100)
 			local pos1 = ((rot_vector - heroPos):Normalized() * attachY)
			dummy:SetAbsOrigin(vec_up + heroForward * attachX + pos1)
			dummy:SetParent(hero, attachPoint)
			hero.santa_hat = dummy
			hero.santa_hat.parent = hero
		end

		--
		--hero:AddNewModifier(hero, nil, "modifier_bvohero", {})

		if IsStatsCollectionOn then
			local url = BaseAPI .. "ver=" .. StatsCollectionVersion .. "&id=2&gamemode=" .. _G.GameModeCombination .. "&hero=" .. hero:GetClassname()
			local req = CreateHTTPRequest("POST", url)
			req:Send(function(result)
				--callback(result.Body)
			end)
		end

		--fix primary attribute
		--hero:SetPrimaryAttribute(primary_attributes[name])

		--Group screenshot setup
		if IsInToolsMode() then
			local grp_screenshot = true
			if grp_screenshot and name == "npc_dota_hero_queenofpain" then
				local all_heroes = {
					"npc_dota_hero_juggernaut",
					"npc_dota_hero_zuus",
					"npc_dota_hero_ember_spirit",
					"npc_dota_hero_antimage",
					"npc_dota_hero_luna",
					"npc_dota_hero_sniper",
					"npc_dota_hero_doom_bringer",
					"npc_dota_hero_dragon_knight",
					"npc_dota_hero_riki",
					"npc_dota_hero_sven",
					"npc_dota_hero_lycan",
					"npc_dota_hero_phantom_assassin",
					"npc_dota_hero_kunkka",
					"npc_dota_hero_skeleton_king",
					"npc_dota_hero_naga_siren",
					"npc_dota_hero_slark",
					"npc_dota_hero_night_stalker",
					"npc_dota_hero_bane",
					"npc_dota_hero_elder_titan",
					"npc_dota_hero_techies",
					"npc_dota_hero_lina",
					"npc_dota_hero_phantom_lancer",
					"npc_dota_hero_spectre",
					"npc_dota_hero_keeper_of_the_light",
					"npc_dota_hero_beastmaster",
					"npc_dota_hero_mirana",
					"npc_dota_hero_troll_warlord",
					"npc_dota_hero_terrorblade",
					"npc_dota_hero_bloodseeker",
					"npc_dota_hero_slardar",
					"npc_dota_hero_axe",
					"npc_dota_hero_necrolyte",
					"npc_dota_hero_huskar",
					"npc_dota_hero_earthshaker",
					"npc_dota_hero_templar_assassin",
					"npc_dota_hero_enigma",
					"npc_dota_hero_centaur",
					"npc_dota_hero_drow_ranger",
					"npc_dota_hero_ursa",
					"npc_dota_hero_enchantress",
					"npc_dota_hero_windrunner",
					"npc_dota_hero_phoenix",
					--"npc_dota_hero_queenofpain",
				}
				local spawnPosGrp = Entities:FindByName(nil, "SPAWN_FOUNTAIN"):GetAbsOrigin()
				for _,grp in pairs(all_heroes) do
					local grp_hero = CreateUnitByName(grp, spawnPosGrp, true, hero, nil, hero:GetTeamNumber())
					grp_hero:SetPlayerID(hero:GetPlayerID())
					grp_hero:SetControllableByPlayer(hero:GetPlayerID(), true)

					--local particleName = "particles/wings/holy_wings.vpcf"
					--local particle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, grp_hero)

					if false then
						attachCosmetic( {
							unit = grp_hero,
							scale = 1.0,
							pitch = 0,
							yaw = 90,
							roll = 0,
							attachPoint = "attach_head",
							offset = Vector(0,0,20),
							model = "models/santa_hat/santa_hat.vmdl",
							} )
					end
				end
			end
		end
	end
end

function attachCosmetic( keys )
	local unit = keys.unit
	local scale = keys.scale
	local pitch = keys.pitch
	local yaw = keys.yaw
	local roll = keys.roll
	local attachPoint = keys.attachPoint
	local offset = keys.offset * scale * unit:GetModelScale()

	local attach = unit:ScriptLookupAttachment(attachPoint)

	local hat = Entities:CreateByClassname("prop_dynamic")
	hat:SetModel(keys.model)
	hat:SetModelScale(scale)

	local angles = unit:GetAttachmentAngles(attach)
	angles = QAngle(angles.x, angles.y, angles.z)
	angles = RotateOrientation( angles, RotationDelta( QAngle(pitch, yaw, roll), QAngle(0,0,0) ) )
	
	local attach_pos = unit:GetAttachmentOrigin(attach)
	attach_pos = attach_pos + RotatePosition(Vector(0,0,0), angles, offset)

	hat:SetAbsOrigin(attach_pos)
	hat:SetAngles(angles.x,angles.y,angles.z)

	hat:SetParent(unit, attachPoint)
end

function BvOReborn:OnHeroPicked(event)
	--Wait a bit for illusions to become real illusions
	Timers:CreateTimer(0.2, function ()
		InitHeroSetup(event)
	end)
end

function BvOReborn:OnGameStateChange()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    	--Spawn timers
		Timers:CreateTimer(0, function() -- timer for neutral spawn
			SpawnNeutrals()
			return creepSpawnTime
		end)

		Timers:CreateTimer(0, function() -- timer for infernal spawn
			SpawnInfernals()
			return 5.0
		end)

		Timers:CreateTimer(0, function() -- timer for skeleton spawn
			SpawnSkeleton()
			return 5.0
		end)

		Timers:CreateTimer(0, function() -- timer for rune spawn
			SpawnRune()
			return RUNE_SPAWN_INTERVAL
		end)

		--[[
		Timers:CreateTimer(DUEL_INTERVAL, function()
        	--StartDuel()
        	local max_alives = DuelLibrary:GetMaximumAliveHeroes(tHeroesRadiant, tHeroesDire)
        	if max_alives < 1 then 
        		max_alives = 1 
        	end

        	local c = RandomInt(1, max_alives)
        	nCOUNTDOWNTIMER = DUEL_NOBODY_WINS
        	DuelLibrary:StartDuel(tHeroesRadiant, tHeroesDire, c, DUEL_NOBODY_WINS, function(err_arg) DeepPrintTable(err_arg) end, function(winner_side)
        		OnDuelEnd(winner_side)

       		end)
            return nil
        end)
        CustomGameEventManager:Send_ServerToAllClients("display_timer", {msg="#bvo_duel_next", duration=DUEL_INTERVAL, mode=0, endfade=true, position=0, warning=5, paused=false, sound=true} )
        ]]

        if GAMEVOTE_DUELS_ACTIVE == 1 then
	        CustomGameEventManager:Send_ServerToAllClients("display_timer", {msg="#bvo_duel_next", duration=DUEL_INTERVAL, mode=0, endfade=true, position=0, warning=5, paused=false, sound=true} )
	        Timers:CreateTimer(DUEL_INTERVAL, function()
	        	DuelStart(tHeroesRadiant, tHeroesDire)
	        	CustomGameEventManager:Send_ServerToAllClients("display_timer", {msg="#bvo_duel_next", duration=DUEL_INTERVAL, mode=0, endfade=true, position=0, warning=5, paused=false, sound=true} )
	        	return DUEL_INTERVAL
	    	end)
	    end
		--spawn mini-bosses
		local point_mini = {}
		for i = 1, 2 do
			point_mini[i] = Entities:FindByName( nil, "MAP_BOSS_" .. i):GetAbsOrigin()
			local mini = CreateUnitByName("npc_dota_hero_brewmaster", point_mini[i], true, nil, nil, DOTA_TEAM_NEUTRALS)
			mini.spawnOrigin = point_mini[i]
			mini.itemG = 0
			mini.enrage = false
			mini:FindAbilityByName("bvo_creep_hero_aggro"):SetLevel(1)
			mini:FindAbilityByName("bvo_brewmaster_enrage"):SetLevel(1)
		end
		--spawn extra bosses
		local boss_point = Entities:FindByName( nil, "BOSS_ARENA_CENTER" ):GetAbsOrigin()
		local boss = CreateUnitByName("npc_boss_maximillian_bladebane", boss_point, true, nil, nil, DOTA_TEAM_NEUTRALS)
		boss.spawnOrigin = boss_point
		boss.unitName = "npc_boss_maximillian_bladebane"
		--Game start phase
		if IsStatsCollectionOn then
			local url = BaseAPI .. "ver=" .. StatsCollectionVersion .. "&id=5&gamemode=" .. _G.GameModeCombination
			local req = CreateHTTPRequest("POST", url)
			req:Send(function(result)
				--callback(result.Body)
			end)
		end
    elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
    	if RECORD_RATING then
	    	InitialAPILoad()
	    else
	    	local body = "71330797:-4|21"
	    	for _,data in pairs(split(body, ",")) do
	    		if string.len(data) > 0 then
					local d_split = split(data, ":")
					
					local d_id = d_split[1]

					local d_split2 = split(d_split[2], "|")

					local d_honor = d_split2[1]
					local d_rank = d_split2[2]

					--print(d_id .. " - " .. d_honor .. " - " .. d_rank)

					for _,ply in pairs(_G._self.vUserIds) do
						local pid = ply:GetPlayerID()
	    				local steam_id = PlayerResource:GetSteamAccountID(pid)

	    				if steam_id == tonumber(d_id) then
							CustomGameEventManager:Send_ServerToPlayer(ply, "set_honor_points", {honor=d_honor, rank=d_rank} )
						end
					end
				end
			end
	    end

		local mode 	= GameRules.AddonTemplate
		local votes = mode.VoteTable
		--Select gamemodes based on vote
		for category, pidVoteTable in pairs(votes) do
			
			-- Tally the votes into a new table
			local voteCounts = {}
			for pid, vote in pairs(pidVoteTable) do
				if not voteCounts[vote] then voteCounts[vote] = 0 end
				voteCounts[vote] = voteCounts[vote] + 1
			end

			--print(" ----- " .. category .. " ----- ")
			--PrintTable(voteCounts)

			-- Find the key that has the highest value (key=vote value, value=number of votes)
			local highest_vote = 0
			local highest_key = nil
			for k, v in pairs(voteCounts) do
				if v > highest_vote then
					highest_key = k
					highest_vote = v
				end
			end

			-- Check for a tie by counting how many values have the highest number of votes
			local tieTable = {}
			for k, v in pairs(voteCounts) do
				if v == highest_vote then
					table.insert(tieTable, k)
				end
			end

			-- Resolve a tie by selecting the default value
			--TODO Refactor this mess
			if table.getn(tieTable) > 1 or highest_key == nil then
				--defaults without vote
				if GetMapName() == "bvo_final_boss" then
					if category == "creep_respawn" then
						highest_key = 1
					elseif category == "win_con" then
						highest_key = 2
					elseif category == "waygate" then
						highest_key = 1
					elseif category == "allrandom" then
						highest_key = 0
					elseif category == "duel" then
						highest_key = 1
					end
				elseif GetMapName() == "bvo_final_boss_x1" then
					if category == "creep_respawn" then
						highest_key = 0
					elseif category == "win_con" then
						highest_key = 2
					elseif category == "waygate" then
						highest_key = 1
					elseif category == "allrandom" then
						highest_key = 0
					elseif category == "duel" then
						highest_key = 1
					end
				else
					if category == "creep_respawn" then
						highest_key = 0
					elseif category == "win_con" then
						highest_key = 1
					elseif category == "waygate" then
						highest_key = 1
					elseif category == "allrandom" then
						highest_key = 0
					elseif category == "duel" then
						highest_key = 1
					end
				end
			end

			-- Act on the winning vote
			if category == "creep_respawn" then
				mode.creep_respawn = highest_key
				if adminDefault then
					mode.creep_respawn = 0
				end
				doubleReward = highest_key
			elseif category == "win_con" then
				mode.win_con = highest_key
				killLimit = 100
			elseif category == "waygate" then
				mode.waygate = highest_key
				if highest_key == 0 then
					for i = 1, 5 do
						Entities:FindByName( nil, "RADIANT_TELE_" .. i ):RemoveSelf()
						Entities:FindByName( nil, "DIRE_TELE_" .. i ):RemoveSelf()
					end
				end
			elseif category == "allrandom" then
				mode.allrandom = highest_key
				if highest_key == 1 then
					for _,ply in pairs(self.vUserIds) do
						PlayerResource:SetHasRandomed(ply:GetPlayerID())
						ply:MakeRandomHeroSelection()
					end
				end
			elseif category == "duel" then
				mode.duel = highest_key
				GAMEVOTE_DUELS_ACTIVE = highest_key
			end
			--print(category .. ": " .. highest_key)
		end
		--Ban heroes based on vote
		--Get unique amount of nominated heroes and weight
		local ban_nominated_unique_heroes = {}
		local ban_nominated_weight_heroes = {}
		for _,hero in pairs(mode.HeroBan) do
			local ban_flag = false
			for __,ban in pairs(ban_nominated_unique_heroes) do
				if hero == ban then ban_flag = true end
			end
			if not ban_flag then table.insert(ban_nominated_unique_heroes, hero) end
			table.insert(ban_nominated_weight_heroes, hero)
		end
		--Ban half of them
		local heroes_to_ban = #ban_nominated_unique_heroes / 2
		if #ban_nominated_unique_heroes % 2 == 1 then heroes_to_ban = math.ceil(heroes_to_ban) end
		--Shuffle weight for balance
		for i=#ban_nominated_weight_heroes, 2, -1 do
			local j = RandomInt( 1, i )
			ban_nominated_weight_heroes[i], ban_nominated_weight_heroes[j] = ban_nominated_weight_heroes[j], ban_nominated_weight_heroes[i]
		end
		--Start banning based on weight
		local banned_heroes_info = {}
		for i = 1, heroes_to_ban do
			local _hero = table.remove( ban_nominated_weight_heroes, 1 )
			table.insert(mode.BannedHeroes, _hero)
			table.insert(banned_heroes_info, "#bvo_banned_" .. _hero)
			--Remove duplicates
			for x = 1, #ban_nominated_weight_heroes do
				if ban_nominated_weight_heroes[x] == _hero then table.remove(ban_nominated_weight_heroes, x) end
			end
			--Ban heroes
			CustomGameEventManager:Send_ServerToAllClients( "ban_heroid", {id=_hero} )
		end
		--Display result
		Timers:CreateTimer(1.0, function()
			for _,info in pairs(banned_heroes_info) do
				GameRules:SendCustomMessage(info, 0, 0)
			end
			displayGamemodes()
		end)
		--auto hero
		if auto_hero ~= nil then
			for _,ply in pairs(_G._self.vUserIds) do
				local pid = ply:GetPlayerID()
				local steam_id = PlayerResource:GetSteamAccountID(pid)
				if steam_id == 71330797 then
					if ply:GetAssignedHero() == nil and not PlayerResource:IsHeroSelected(auto_hero) then
						BvOReborn:OnCustomRandomPick({ pID = pid })
					end
					break
				end
			end
		end
		--send gamemode
		if IsStatsCollectionOn then
			_G.GameModeCombination = mode.creep_respawn .. "_" .. mode.win_con .. "_" .. mode.waygate .. "_" .. mode.allrandom
			local url = BaseAPI .. "ver=" .. StatsCollectionVersion .. "&id=4&gamemode=" .. _G.GameModeCombination
			local req = CreateHTTPRequest("POST", url)
			req:Send(function(result)
				--callback(result.Body)
			end)
		end
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		local mode 	= GameRules.AddonTemplate
		if not mode.VoteTable["creep_respawn"] then mode.VoteTable["creep_respawn"] = {} end
		if not mode.VoteTable["win_con"] then mode.VoteTable["win_con"] = {} end
		if not mode.VoteTable["waygate"] then mode.VoteTable["waygate"] = {} end
		if not mode.VoteTable["allrandom"] then mode.VoteTable["allrandom"] = {} end
		if not mode.VoteTable["duel"] then mode.VoteTable["duel"] = {} end
		--setup default
		--bvo_final_boss settings
		--does not matter as a tie happens
		mode.creep_respawn = 1
		mode.win_con = 2
		mode.waygate = 1
		mode.allrandom = 0
		mode.duel = 1
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_TEAM_SHOWCASE then
        --random heroes for player who did not pick
		for _,ply in pairs(_G._self.vUserIds) do
			local pid = ply:GetPlayerID()
			if ply:GetAssignedHero() == nil then
				BvOReborn:OnCustomRandomPick({ pID = pid })
			end
		end
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		displayGamemodes()
		--add bots
		--[[
		local hero_list = {
			"npc_dota_hero_juggernaut",
			"npc_dota_hero_zuus",
			"npc_dota_hero_ember_spirit",
			"npc_dota_hero_antimage",
			"npc_dota_hero_luna",
			"npc_dota_hero_sniper",
			"npc_dota_hero_doom_bringer",
			"npc_dota_hero_dragon_knight",
			"npc_dota_hero_riki",
			"npc_dota_hero_sven",
			"npc_dota_hero_lycan",
			"npc_dota_hero_phantom_assassin",
			"npc_dota_hero_kunkka",
			"npc_dota_hero_skeleton_king",
			"npc_dota_hero_naga_siren",
			"npc_dota_hero_slark",
			"npc_dota_hero_night_stalker",
			"npc_dota_hero_bane",
			"npc_dota_hero_elder_titan",
			"npc_dota_hero_techies",
			"npc_dota_hero_lina",
			"npc_dota_hero_phantom_lancer",
			"npc_dota_hero_spectre",
			"npc_dota_hero_keeper_of_the_light",
			"npc_dota_hero_beastmaster",
			"npc_dota_hero_mirana",
		}
		for i=#hero_list, 2, -1 do
			local j = RandomInt( 1, i )
			hero_list[i], hero_list[j] = hero_list[j], hero_list[i]
		end
		for i = 1, 10 do
			local ply = PlayerResource:GetPlayer(i)
			if ply ~= nil then
				local pid = ply:GetPlayerID()
				if PlayerResource:IsFakeClient(pid) then
					while PlayerResource:IsHeroSelected(hero_list[1]) do
						table.remove(hero_list, 1)
					end
					CreateHeroForPlayer(table.remove(hero_list, 1), ply)
				end
			end
		end
		]]
	end
end

function InitialAPILoad()
    Timers:CreateTimer(1.0, function ()
    	--get honor points and rank
    	RequestFullHonorUpdate()
		--get most recent vip list
		RequestFullVIPUpdate()
	end)
end

function RequestFullHonorUpdate()
	local timeout = true

	local ids = ""
	for _,ply in pairs(_G._self.vUserIds) do
		local pid = ply:GetPlayerID()
	    local steam_id = PlayerResource:GetSteamAccountID(pid)
	    ids = ids .. steam_id .. ","
	end
	local req = CreateHTTPRequestScriptVM("GET", "https://nine9dev.herokuapp.com/api.php?data=" .. ids)
	req:Send(function(result)
		timeout = false

		local body = result.Body
		for _,data in pairs(split(body, ",")) do
    		if string.len(data) > 0 then
				local d_split = split(data, ":")
				
				local d_id = d_split[1]

				local d_split2 = split(d_split[2], "|")

				local d_honor = d_split2[1]
				local d_rank = d_split2[2]

				for _,ply in pairs(_G._self.vUserIds) do
					local pid = ply:GetPlayerID()
    				local steam_id = PlayerResource:GetSteamAccountID(pid)

    				if steam_id == tonumber(d_id) then
						CustomGameEventManager:Send_ServerToPlayer(ply, "set_honor_points", {honor=d_honor, rank=d_rank} )
					end
				end
			end
		end
	end)
	Timers:CreateTimer(5.0, function ()
		if timeout then
			--CustomGameEventManager:Send_ServerToAllClients("server_timeout", {} )
		end
	end)
end

function RequestFullVIPUpdate()
	local timeout = true
	local req = CreateHTTPRequestScriptVM("GET", "https://bvo-reborn.herokuapp.com/api.php")
	req:Send(function(result)
		timeout = false

		local body = result.Body
		local vips = {}
		for id in string.gmatch(body, '%d+') do
			table.insert(vips, id)
		end

		CustomGameEventManager:Send_ServerToAllClients("update_vips", {vips=vips} )
	end)
	Timers:CreateTimer(5.0, function ()
		if timeout then
			CustomGameEventManager:Send_ServerToAllClients("server_timeout", {} )
		end
	end)
end

function split(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function RequestHonorCosmeticUpdate( player )
	--update honor points
	CustomGameEventManager:Send_ServerToPlayer(player, "set_honor_points", {honor=player.honorPoints, rank=ply.rank} )
	--get most recent vip list
	local timeout = true
	local req = CreateHTTPRequestScriptVM("GET", "https://bvo-reborn.herokuapp.com/api.php")
	req:Send(function(result)
		timeout = false

		local body = result.Body
		local vips = {}
		for id in string.gmatch(body, '%d+') do
			table.insert(vips, id)
		end
		CustomGameEventManager:Send_ServerToPlayer(player, "update_vips", {vips=vips} )
	end)
	Timers:CreateTimer(5.0, function ()
		if timeout then
			CustomGameEventManager:Send_ServerToPlayer(player, "server_timeout", {} )
		end
	end)
end

function displayGamemodes()
	local mode 	= GameRules.AddonTemplate
	GameRules:SendCustomMessage("#bvo_help_stuck_message", 0, 0)
	if mode.creep_respawn == 1 then GameRules:SendCustomMessage("#bvo_gamemode_1_on", 0, 0)
	else GameRules:SendCustomMessage("#bvo_gamemode_1_off", 0, 0) end

	if mode.win_con == 1 then GameRules:SendCustomMessage("#bvo_gamemode_2_1", 0, killLimit)
	elseif mode.win_con == 2 then GameRules:SendCustomMessage("#bvo_gamemode_2_2", 0, 0)
	else GameRules:SendCustomMessage("#bvo_gamemode_2_3", 0, 0) end

	if mode.waygate == 1 then GameRules:SendCustomMessage("#bvo_gamemode_3_on", 0, 0)
	else GameRules:SendCustomMessage("#bvo_gamemode_3_off", 0, 0) end

	if mode.allrandom == 1 then GameRules:SendCustomMessage("#bvo_gamemode_4_on", 0, 0)
	else GameRules:SendCustomMessage("#bvo_gamemode_4_off", 0, 0) end

	if mode.duel == 1 then GameRules:SendCustomMessage("#bvo_gamemode_5_on", 0, 0)
	else GameRules:SendCustomMessage("#bvo_gamemode_5_off", 0, 0) end

	GameRules:SendCustomMessage("#bvo_help_commands_message", 0, 0)
	--GameRules:SendCustomMessage("If you play till the end, you earn <font color='#ff0000'>1 Token</font>.", 0, 0)
end

function SetGameEnd(winner)
	if not _G.IsGameFinished then
		_G.IsGameFinished = true
		--END GAME
		if winner == DOTA_TEAM_GOODGUYS then
			GameRules:SetCustomVictoryMessage("Radiant Victory")
			GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		elseif winner == DOTA_TEAM_BADGUYS then
			GameRules:SetCustomVictoryMessage("Dire Victory")
			GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		else
			GameRules:SetCustomVictoryMessage("DRAW!")
			GameRules:SetGameWinner(DOTA_TEAM_NEUTRALS)
		end
		GameRules:SetSafeToLeave(true)

		if RECORD_RATING then
			--don't record if not enought players
			if #tHeroesRadiant > 0 and #tHeroesDire > 0 then
				--record rating
				local __self = _G._self

				local firstWinner = true
				local dataWinners = "w:"
		
				local firstLoser = true			
				local dataLosers = "%20l:"
				
				for _,ply in pairs(__self.vUserIds) do
					local pid = ply:GetPlayerID()
					local connection_state = PlayerResource:GetConnectionState(pid)
					local sendData = true
					local isPlayerLoser = ply:GetTeamNumber() == winner

				    if connection_state == DOTA_CONNECTION_STATE_ABANDONED or connection_state == DOTA_CONNECTION_STATE_DISCONNECTED then
				        sendData = false
				    end
				    local steam_id = PlayerResource:GetSteamAccountID(pid)

				    if sendData or isPlayerLoser then
						if not isPlayerLoser then
							if firstWinner then
								firstWinner = false
								dataWinners = dataWinners .. steam_id
							else
								dataWinners = dataWinners .. "," .. steam_id
							end
						else
							if firstLoser then
								firstLoser = false
								dataLosers = dataLosers .. steam_id
							else
								dataLosers = dataLosers .. "," .. steam_id
							end
						end
					end
				end

				local url = BaseAPI .. "data=" .. dataWinners .. dataLosers
				local req = CreateHTTPRequestScriptVM("POST", url)
				req:Send(function(result)
					GameRules:SendCustomMessage(result.Body, 0, 0)
				end)
			end
		end

		--[[
		local __self = _G._self
		if IsStatsCollectionOn then
			--Game end phase
			local url = BaseAPI .. "ver=" .. StatsCollectionVersion .. "&id=6&gamemode=" .. _G.GameModeCombination .. "&length=" .. GameRules:GetGameTime()
			local req = CreateHTTPRequest("POST", url)
			req:Send(function(result)
				--callback(result.Body)
			end)
			for _,ply in pairs(__self.vUserIds) do
				local pid = ply:GetPlayerID()
				local connection_state = PlayerResource:GetConnectionState(pid)
				local sendData = true

			    if connection_state == DOTA_CONNECTION_STATE_ABANDONED or connection_state == DOTA_CONNECTION_STATE_DISCONNECTED then
			        sendData = false
			    end
			    local steam_id = PlayerResource:GetSteamAccountID(pid)

			    if sendData then
					local win = 0
					if ply:GetTeamNumber() == winner then
						win = 1
					end
					local hero = ply:GetAssignedHero()
					local name = ""
					if hero ~= nil then
						name = hero:GetClassname()
					end

					local url = BaseAPI .. "ver=" .. StatsCollectionVersion .. "&id=3&steam_id=" .. steam_id .. "&gamemode=" .. _G.GameModeCombination .. "&win=" .. win .. "&hero=" .. name
					local req = CreateHTTPRequest("POST", url)
					req:Send(function(result)
						--callback(result.Body)
					end)

					for itemSlot=0,5 do
						local item = hero:GetItemInSlot(itemSlot)
						if item ~= nil then
							local url2 = BaseAPI .. "ver=" .. StatsCollectionVersion .. "&id=8&gamemode=" .. _G.GameModeCombination .. "&win=" .. win .. "&item=" .. item:GetName()
							local req = CreateHTTPRequest("POST", url2)
							req:Send(function(result)
								--callback(result.Body)
							end)
						end
					end
				end
			end
		end
		]]
	end
end

function OnDuelEnd( winner_side)
	nCOUNTDOWNTIMER = DUEL_INTERVAL
    local duel_count = DuelLibrary:GetDuelCount()

	if winner_side == DOTA_TEAM_GOODGUYS then
		GiveGoldToTeam(tHeroesRadiant, DUEL_WINNER_GOLD_MULTIPLER * duel_count)
		_G.RadiantWonDuels = _G.RadiantWonDuels + 1
		GameRules:SendCustomMessage("#bvo_radiant_duel_won_message", 0, (DUEL_WINNER_GOLD_MULTIPLER * duel_count))
	elseif winner_side == DOTA_TEAM_BADGUYS then
		GiveGoldToTeam(tHeroesDire, DUEL_WINNER_GOLD_MULTIPLER * duel_count)
		_G.DireWonDuels = _G.DireWonDuels + 1
		GameRules:SendCustomMessage("#bvo_dire_duel_won_message", 0, (DUEL_WINNER_GOLD_MULTIPLER * duel_count))
	end

	sendWinInfo()

	if GameRules.AddonTemplate.win_con == 3 then
		if _G.RadiantWonDuels >= 5 then
			SetGameEnd(DOTA_TEAM_GOODGUYS)
		elseif _G.DireWonDuels >= 5 then
			SetGameEnd(DOTA_TEAM_BADGUYS)
		end
	end

	Timers:CreateTimer(DUEL_INTERVAL, function ()
		nCOUNTDOWNTIMER = DUEL_NOBODY_WINS
		local max_alives = DuelLibrary:GetMaximumAliveHeroes(tHeroesRadiant, tHeroesDire)
      	if max_alives < 1 then max_alives = 1 end
      	local c = RandomInt(1, max_alives)
        DuelLibrary:StartDuel(tHeroesRadiant, tHeroesDire, c, DUEL_NOBODY_WINS, function(err_arg) DeepPrintTable(err_arg) end, function(win_side)
         	OnDuelEnd(win_side)
        end)
        return nil
	end)
end

function GiveGoldToTeam(team_table, gold)
	for _, x in pairs(team_table) do
		if x then
			PlayerResource:ModifyGold( x:GetPlayerID(), gold, true, 0)
		end
	end
end

function _G:GiveTeamGold(team_number, gold)
	local team_table = nil
	if team_number == DOTA_TEAM_GOODGUYS then
		team_table = tHeroesRadiant
	elseif team_number == DOTA_TEAM_BADGUYS then
		team_table = tHeroesDire
	end

	if team_table ~= nil then
		for _, x in pairs(team_table) do
			if x then
				PlayerResource:ModifyGold( x:GetPlayerID(), gold, true, 0)
			end
		end
	end
end

function BvOReborn:OnEntityKilled(event)
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killer = nil

	if event.entindex_attacker ~= nil then
		killer = EntIndexToHScript( event.entindex_attacker )
	end

	if IsUnitCreep(killedUnit:GetUnitName()) then
		OnCreepDeathGlobal()
	end
	local index = 1
	for _,unit in pairs(rapierUnits) do
		if unit == killedUnit then
			table.remove(rapierUnits, index)
			break
		end
		index = index + 1
	end

	if killedUnit:GetUnitName() == "npc_dota_infernal" then
		OnInfernalDeathGlobal(killedUnit)
	elseif killedUnit:GetUnitName() == "npc_dota_skeleton" then
		OnSkeletonDeathGlobal()
	elseif killedUnit:GetUnitName() == "npc_dota_forgotten_one" then
		_G:CreateDrop("item_orb_of_frost", killedUnit.originalPos, false)
		CreateGoldCoin(killedUnit.originalPos, 20)
	elseif killedUnit:GetUnitName() == "npc_dota_mimic" then
		_G:CreateDrop("item_rapier_custom", killedUnit:GetAbsOrigin(), false)
	end

	if killedUnit:GetUnitName() == "npc_dota_kyuubi" then
		if killedUnit.radiant_damage > killedUnit.dire_damage then
			SetGameEnd(DOTA_TEAM_GOODGUYS)
		elseif killedUnit.dire_damage > killedUnit.radiant_damage then
			SetGameEnd(DOTA_TEAM_BADGUYS)
		else
			SetGameEnd(DOTA_TEAM_NEUTRALS)
		end
	end

	if killedUnit:IsRealHero() and not killedUnit:IsReincarnating() then
		-- prevent hero from losing gold
		killedUnit.goldLostToDeaths = killedUnit.goldLostToDeaths or 0
		local goldLostToLastDeath = PlayerResource:GetGoldLostToDeath(killedUnit:GetPlayerID()) - killedUnit.goldLostToDeaths
		killedUnit:ModifyGold( goldLostToLastDeath, false, DOTA_ModifyGold_Unspecified)
		killedUnit.goldLostToDeaths = PlayerResource:GetGoldLostToDeath(killedUnit:GetPlayerID())


    	-- Handle the actual dying part
		killedUnit:SetTimeUntilRespawn(3)
		--game end
		if GameRules.AddonTemplate.win_con == 1 then
	    	local goodguys_kills = PlayerResource:GetTeamKills(DOTA_TEAM_GOODGUYS)
	    	local badguys_kills = PlayerResource:GetTeamKills(DOTA_TEAM_BADGUYS)

			if goodguys_kills >= killLimit then
		    	SetGameEnd(DOTA_TEAM_GOODGUYS)
		   	elseif badguys_kills >= killLimit then
				SetGameEnd(DOTA_TEAM_BADGUYS)
			end
		end
		if killedUnit:GetClassname() == "npc_dota_hero_brewmaster" then
			killedUnit:SetTimeUntilRespawn(120)
			--Loot
			local coins = ( killedUnit.itemG + 1 ) * 2
			CreateGoldCoin(killedUnit:GetAbsOrigin(), coins)
		end
		--award medals
		if killer then
			local player = killer:GetPlayerOwner()
			local assigned_hero = nil
			if player ~= nil then
				assigned_hero = player:GetAssignedHero()
			else
				if killer:GetPlayerOwnerID() ~= nil then
					if killer:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
						for _,hero in pairs(tHeroesRadiant) do
							if killer:GetPlayerOwnerID() == hero:GetPlayerOwnerID() then
								assigned_hero = hero
								break
							end
						end
					elseif killer:GetTeamNumber() == DOTA_TEAM_BADGUYS then
						for _,hero in pairs(tHeroesDire) do
							if killer:GetPlayerOwnerID() == hero:GetPlayerOwnerID() then
								assigned_hero = hero
								break
							end
						end
					end
				end
			end
			--assign medal to killer
			local medal_reward = 1
			if assigned_hero ~= nil then
				if assigned_hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
					for _,hero in pairs(tHeroesRadiant) do
						if assigned_hero == hero then
							if assigned_hero ~= killedUnit then
								if IsInDuelArena(assigned_hero) then
									medal_reward = medal_reward * 2
									GiveGoldToTeam(tHeroesRadiant, killedUnit:GetLevel() * 10)
								end

								hero.medals = hero.medals + medal_reward
								hero.TotalMedals = hero.TotalMedals + medal_reward
								CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "display_medal", {msg=hero.medals} )
							end
						end
					end
				elseif assigned_hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
					for _,hero in pairs(tHeroesDire) do
						if assigned_hero == hero then
							if assigned_hero ~= killedUnit then
								if IsInDuelArena(assigned_hero) then
									medal_reward = medal_reward * 2
									GiveGoldToTeam(tHeroesDire, killedUnit:GetLevel() * 10)
								end

								hero.medals = hero.medals + medal_reward
								hero.TotalMedals = hero.TotalMedals + medal_reward
								CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "display_medal", {msg=hero.medals} )
							end
						end
					end
				end
			end
		end
    end
end

function IsInDuelArena(hero)
	local duel_point = Entities:FindByName( nil, "DUEL_POINT_RADIANT_IN"):GetAbsOrigin()
	if GridNav:CanFindPath(duel_point, hero:GetAbsOrigin()) then
		return true
	end
	return false
end

unitsToScale = {
	"Wildwing_level_1",
	"Wildwing_level_4",
	"Worg_level_1",
	"Worg_level_4",
	"Harpy_level_5",
	"Ogre_level_5",
	"Ogre_level_6",
	"Dragon_level_8",
	"Dragon_level_13",
	"Troll_level_11",
}

function BvOReborn:OnHeroIngame(unit)
	local spawnedUnit = EntIndexToHScript( unit.entindex )

	Timers:CreateTimer(0.1, function ()
		--Remove illus
		if spawnedUnit ~= nil and not spawnedUnit:IsNull() and spawnedUnit:IsIllusion() then
			Timers:CreateTimer(75.1, function ()
				if not spawnedUnit:IsNull() and spawnedUnit ~= nil then
					spawnedUnit:RemoveSelf()
				end
			end)
		end
		--Scale creeps
		if spawnedUnit.unitName ~= nil then
			for _,name in pairs(unitsToScale) do
				if spawnedUnit.unitName == name then

					spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_creepbuff", {})

					break
				end
			end
		end
	end)

	if spawnedUnit then
		if not(spawnedUnit.medical_tractates) then
			spawnedUnit.medical_tractates = 0
		end
		spawnedUnit:RemoveModifierByName("modifier_medical_tractate")
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_medical_tractate", nil)

		spawnedUnit.ankh = false

		if spawnedUnit.lostDuel then
			spawnedUnit.lostDuel = false
			spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_lostduel", {duration=20.0})
		end
	end

	if spawnedUnit:IsHero() then

		if spawnedUnit:GetClassname() ~= "npc_dota_hero_brewmaster" then
			--Update model
			if model_lookup[ spawnedUnit:GetName() ] ~= nil and spawnedUnit:GetModelName() ~= model_lookup[ spawnedUnit:GetName() ] then
		    	Timers:CreateTimer(0.1, function ()
		    		spawnedUnit:SetOriginalModel(model_lookup[ spawnedUnit:GetName() ])
		    		spawnedUnit:SetModel(model_lookup[ spawnedUnit:GetName() ])			
					spawnedUnit:MoveToPosition(spawnedUnit:GetAbsOrigin())
		    	end)
		    end
			--Apply bot AI
			--if PlayerResource:IsFakeClient(spawnedUnit:GetPlayerID()) then
			--	local ai_skill = spawnedUnit:FindAbilityByName("bvo_mana_on_hit")
	   		--	if not spawnedUnit:HasModifier("bvo_bot_ai_modifier") and ai_skill ~= nil then
	   		--		ai_skill:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "bvo_bot_ai_modifier", {} )
	   		--	end
	   		--	spawnedUnit.ai_state = "idle"
	   		--end
		else
			if spawnedUnit.spawnOrigin ~= nil then
				if spawnedUnit.enrage then
					spawnedUnit:SetAbsOrigin( Vector(0, 0, 0) )
					spawnedUnit:FindAbilityByName("bvo_brewmaster_enrage"):ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "bvo_brewmaster_enrage_remove_modifier", {})
				else
					spawnedUnit:SetAbsOrigin(spawnedUnit.spawnOrigin)
				end
				if spawnedUnit.itemG == 0 then
					for i = 1, 4 do
						spawnedUnit:HeroLevelUp(false)
					end
				else
					for i = 1, 5 do
						spawnedUnit:HeroLevelUp(false)
					end
				end
				if spawnedUnit.itemG < 10 then
					spawnedUnit.itemG = spawnedUnit.itemG + 1
					if spawnedUnit.itemG == 1 then
						spawnedUnit:AddItemByName("item_sange_and_yasha")
					elseif spawnedUnit.itemG == 2 then
						spawnedUnit:AddItemByName("item_dominator_custom")
					elseif spawnedUnit.itemG == 3 then
						spawnedUnit:AddItemByName("item_heart_of_the_bount")
					elseif spawnedUnit.itemG == 4 then
						spawnedUnit:AddItemByName("item_butterfly_custom")
					elseif spawnedUnit.itemG == 5 then
						spawnedUnit:AddItemByName("item_bladebane_armor")
					elseif spawnedUnit.itemG == 6 then
						spawnedUnit:RemoveItem(spawnedUnit:GetItemInSlot(1))
						spawnedUnit:AddItemByName("item_satanic_custom")
					elseif spawnedUnit.itemG == 7 then
						spawnedUnit:RemoveItem(spawnedUnit:GetItemInSlot(2))
						spawnedUnit:AddItemByName("item_maximillian")
					elseif spawnedUnit.itemG == 8 then
						spawnedUnit:RemoveItem(spawnedUnit:GetItemInSlot(3))
						spawnedUnit:AddItemByName("item_red_butterfly")
					elseif spawnedUnit.itemG == 9 then
						spawnedUnit:AddItemByName("item_killer_axe")
					elseif spawnedUnit.itemG == 10 then
						spawnedUnit:RemoveItem(spawnedUnit:GetItemInSlot(0))
						spawnedUnit:AddItemByName("item_basher")
					end
				end
				--enrage
				if spawnedUnit:GetLevel() == 100 then
					spawnedUnit:RemoveItem(spawnedUnit:GetItemInSlot(2))
					spawnedUnit:RemoveItem(spawnedUnit:GetItemInSlot(4))
					spawnedUnit:AddItemByName("item_emperor_maximillian_bladebane_armor")
					spawnedUnit:AddItemByName("item_ultima_sword")
					spawnedUnit.enrage = true
				end
			end
		end
	end
end

function BvOReborn:OnConnectFull(keys)
	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)

	ply.cosmetics = {}
	ply.cosmetics["hat"] = 0
	ply.cosmetics["wings"] = 0
	ply.cosmetics["trail"] = 0

	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()

	-- Update the user ID table with this user
	_G._self.vUserIds[keys.userid] = ply

	local steam_id = PlayerResource:GetSteamAccountID(playerID)
	--register player
	if IsStatsCollectionOn then
		local url = BaseAPI .. "ver=" .. StatsCollectionVersion .. "&id=0&steam_id=" .. steam_id
		local req = CreateHTTPRequest("POST", url)
		req:Send(function(result)
			--callback(result.Body)
		end)
		--get tokens
		--[[
		local url = BaseAPI .. "ver=" .. StatsCollectionVersion .. "&id=10&steam_id=" .. steam_id
		local req = CreateHTTPRequest("GET", url)
		req:Send(function(result)
			local _body = result.Body
			local t_s, t_e = string.find(_body, "Token:")
			local t_l
			for i = t_e + 1, #_body do
			    local c = string.sub(_body, i, i)
			    if c == '!' then
			    	t_l = i - 1 - t_e
			    	break
			    end
			end
			ply.tokenAmount = tonumber(string.sub(_body, t_e + 1, t_e + t_l))
		end)
		]]
	end
	--[[
	if IsInToolsMode() then
		ply.tokenAmount = 10
	end
	]]

	--print("Decryption: " .. crypt(crypted,array,true));
end

function BvOReborn:PlayerSay(keys)
	local teamonly = keys.teamonly
	local userID = keys.userid
	if userID == -1 then return end
	local playerID = _G._self.vUserIds[userID]:GetPlayerID()
	local text = keys.text
	local player = PlayerResource:GetPlayer(playerID)
	local steam_id = PlayerResource:GetSteamAccountID(playerID)

	-- Author commands
	if steam_id == 71330797 then
		if text == "-default" then
			adminDefault = true
		end
		if text == "-end" then
			SetGameEnd(DOTA_TEAM_GOODGUYS)
		end
		if string.match(text, CMD_AUTOPICK) then
			local heroToPick = string.lower(string.sub(text, string.len(CMD_AUTOPICK) + 1))

			local heroID = nil
			for key,value in pairs(name_lookup) do
				if key == heroToPick or string.lower(value) == heroToPick then
					heroID = key
					break
				end
			end
			if heroID ~= nil then
				auto_hero = heroID
			end
		end
		if text == "-random" then
			BvOReborn:OnCustomRandomPick({ pID = playerID })
		end
	end

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
		if text == "-changeteam" then
			if player:GetTeam() == DOTA_TEAM_BADGUYS then
				local count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
				if count < 5 then
					PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_GOODGUYS)
					PlayerResource:UpdateTeamSlot(playerID, DOTA_TEAM_GOODGUYS, count + 1)
				end
			else
				local count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
				if count < 5 then
					PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_BADGUYS)
					PlayerResource:UpdateTeamSlot(playerID, DOTA_TEAM_BADGUYS, count + 1)
				end
			end
		end
	else
		-- Commands only while game is ongoing
		if text == "megumin is love, megumin is life" then
			if teamonly == 0 then
				CustomGameEventManager:Send_ServerToPlayer( player, "unlock_secret", {} )
			end
		end

		if text == "-killme" then
			if player:GetAssignedHero() ~= nil then
				local hero = player:GetAssignedHero()
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
				local forgotten_point = Entities:FindByName( nil, "TELE_POINT_FORBIDDEN_ONE"):GetAbsOrigin()
				local infernal_point = Entities:FindByName( nil, "POINT_INFERNAL_CENTER"):GetAbsOrigin()
				local rapier_point = Entities:FindByName( nil, "TELE_POINT_RAPIER"):GetAbsOrigin()
				local duel_point = Entities:FindByName( nil, "DUEL_POINT_RADIANT_IN"):GetAbsOrigin()
				local skeleton_point = Entities:FindByName( nil, "POINT_SKELETON_CENTER"):GetAbsOrigin()

				if GridNav:CanFindPath(forgotten_point, stuckPoint) or GridNav:CanFindPath(infernal_point, stuckPoint) or GridNav:CanFindPath(rapier_point, stuckPoint) or GridNav:CanFindPath(skeleton_point, stuckPoint) then
					IsHeroStuck = false
				end

				if GridNav:CanFindPath(duel_point, stuckPoint) then
					IsHeroStuck = false
				end

				if IsHeroStuck then
					FindClearSpaceForUnit(hero, base_point, false)
				end
			end
		end
	end
	-- Bots [WIP]
	if IsInToolsMode() then
		if text == "-addbot good" then
			if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION and self.vUserIds[1] == player then
				local count = PlayerResource:GetPlayerCount()
				if count < 10 then
					Tutorial:AddBot("npc_dota_hero_dragon_knight", "mid", "easy", true);
				end
			end
		elseif text == "-addbot bad" then
			if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION and self.vUserIds[1] == player then
				local count = PlayerResource:GetPlayerCount()
				if count < 10 then
					Tutorial:AddBot("npc_dota_hero_dragon_knight", "mid", "easy", false);
				end
			end
		end
	end
end

function BvOReborn:OnSettingVote(keys)
	local pid 	= keys.PlayerID
	local mode 	= GameRules.AddonTemplate

	if not mode.VoteTable[keys.category] then mode.VoteTable[keys.category] = {} end
	mode.VoteTable[keys.category][pid] = keys.vote
end

function BvOReborn:OnHeroBanVote(keys)
	local pid 	= keys.PlayerID
	local mode 	= GameRules.AddonTemplate

	if not mode.HeroBan[pid] then mode.HeroBan[pid] = {} end
	mode.HeroBan[pid] = keys.heroid
end

function BvOReborn:FilterGold( filterTable )
	local reason = filterTable.reason_const
	local pid = filterTable.player_id_const
	local gold = filterTable.gold

	local gold_multi = 1

	local get_gold = true
	local hero = nil
	if pid ~= nil then
		local ply = PlayerResource:GetPlayer(pid)
		if ply ~= nil then

			local steam_id = PlayerResource:GetSteamAccountID(pid)
			if steam_id == 81157050 or steam_id == 81288400 then
				gold_multi = 0.8
			end

			hero = ply:GetAssignedHero()
			if hero ~= nil then
				if hero:HasModifier("modifier_lostduel") then get_gold = false end
			end
		end
	end

	if doubleReward == 1 then gold = gold * 2 end

	--Custom gold
	if get_gold and hero ~= nil and gold > 0 then
		_G:PopupNumbers(hero, "gold", Vector(255, 200, 33), 1.0, gold, POPUP_SYMBOL_PRE_PLUS, nil, false)
		--SendOverheadEventMessage(hero, OVERHEAD_ALERT_GOLD, hero, gold, nil)
		hero:ModifyGold(gold * gold_multi, false, reason)
	end

	return false
end

function BvOReborn:FilterExperience( filterTable )
	local experience = filterTable.experience
	local reason = filterTable.reason_const
	local pid = filterTable.player_id_const

	local exp_multi = 1

	local get_exp = true
	local hero = nil
	if pid ~= nil then
		local ply = PlayerResource:GetPlayer(pid)
		if ply ~= nil then

			local steam_id = PlayerResource:GetSteamAccountID(pid)
			if steam_id == 81157050 or steam_id == 81288400 then
				exp_multi = 0.8
			end

			hero = ply:GetAssignedHero()
			if hero ~= nil then
				if hero:HasModifier("modifier_lostduel") then get_exp = false end
			end
		end
	end

	if doubleReward == 1 then experience = experience * 2 end

	if experience > 1250 then experience = 1250 end
	--Custom exp
	if not get_exp or hero == nil or experience < 0 then
		filterTable.experience = 0
	end

	filterTable.experience = experience * exp_multi
	
	return true
end

POPUP_SYMBOL_PRE_PLUS = 0
POPUP_SYMBOL_PRE_MINUS = 1
POPUP_SYMBOL_PRE_SADFACE = 2
POPUP_SYMBOL_PRE_BROKENARROW = 3
POPUP_SYMBOL_PRE_SHADES = 4
POPUP_SYMBOL_PRE_MISS = 5
POPUP_SYMBOL_PRE_EVADE = 6
POPUP_SYMBOL_PRE_DENY = 7
POPUP_SYMBOL_PRE_ARROW = 8

POPUP_SYMBOL_POST_EXCLAMATION = 0
POPUP_SYMBOL_POST_POINTZERO = 1
POPUP_SYMBOL_POST_MEDAL = 2
POPUP_SYMBOL_POST_DROP = 3
POPUP_SYMBOL_POST_LIGHTNING = 4
POPUP_SYMBOL_POST_SKULL = 5
POPUP_SYMBOL_POST_EYE = 6
POPUP_SYMBOL_POST_SHIELD = 7
POPUP_SYMBOL_POST_POINTFIVE = 8
function _G:PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol, all)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)

    local pidx
    if all then
		pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target)
	else
		pidx = ParticleManager:CreateParticleForPlayer(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target, target:GetOwner())
	end

    local digits = 0
    if number ~= nil then
        digits = #tostring(number)
    end
    if presymbol ~= nil then
        digits = digits + 1
    end
    if postsymbol ~= nil then
        digits = digits + 1
    end

    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end

function BvOReborn:OnItemPurchase(keys)
	if keys.itemname ~= nil then
		if IsStatsCollectionOn then
			local url = BaseAPI .. "ver=" .. StatsCollectionVersion .. "&id=7&gamemode=" .. _G.GameModeCombination .. "&item=" .. keys.itemname
			local req = CreateHTTPRequest("POST", url)
			req:Send(function(result)
				--callback(result.Body)
			end)
		end
	end
end

function BvOReborn:OnPlayerReconnected(keys)
	local pid = keys.PlayerID

	local player = PlayerResource:GetPlayer(pid)

	for _,hero in pairs(GameRules.AddonTemplate.BannedHeroes) do
		CustomGameEventManager:Send_ServerToPlayer( player, "ban_heroid", {id=hero} )
	end

	--RequestHonorCosmeticUpdate(player)

	--[[
	CustomGameEventManager:Send_ServerToPlayer( player, "display_essence", {msg=caster.boss_1_essences} )
	CustomGameEventManager:Send_ServerToPlayer( player, "display_medal", {msg=caster.medals} )

	local wincon = GameRules.AddonTemplate.win_con
	if wincon == 1 then
   		CustomGameEventManager:Send_ServerToPlayer( player, "display_win_con", {mode=wincon, info=killLimit} )
   	elseif wincon == 2 then
		CustomGameEventManager:Send_ServerToPlayer( player, "display_win_con", {mode=wincon, info="∞"} )
	elseif wincon == 3 then
		local winInfo = _G.RadiantWonDuels .. ":" .. _G.DireWonDuels
		CustomGameEventManager:Send_ServerToPlayer( player, "display_win_con", {mode=wincon, info=winInfo} )
	end
	]]
end

function BvOReborn:OnRunePickup(keys)
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local rune = keys.rune
	local hero = player:GetAssignedHero()
	if hero:GetClassname() == "npc_dota_hero_skeleton_king" then
		Timers:CreateTimer(2.15, function ()
			if hero.dummy_wings ~= nil and not hero.dummy_wings:IsNull() then
				hero:FindAbilityByName("bvo_mana_on_hit"):ApplyDataDrivenModifier(hero, hero.dummy_wings, "bvo_extra_invis_modifier", {duration=45.0} )
			end
		end)
	end
	if hero.santa_hat ~= nil then
		Timers:CreateTimer(2.15, function ()
			if hero.santa_hat ~= nil and not hero.santa_hat:IsNull() then
				hero:FindAbilityByName("bvo_mana_on_hit"):ApplyDataDrivenModifier(hero, hero.santa_hat, "bvo_extra_invis_modifier", {duration=45.0} )
			end
		end)
	end
end

function RandomHeroThink()
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_HERO_SELECTION then
		for _,ply in pairs(_G._self.vUserIds) do
			local pid = ply:GetPlayerID()
			if PlayerResource:HasRandomed(pid) then
				if not ply.trySecret then
					ply.trySecret = true
					local pool_roll = RandomInt(1, 100)
					local pool_chance = 10
					if pool_roll <= pool_chance then
						local roll = RandomInt(1, #secret_hero_pool)
						ply.sayRandom = true

						CreateHeroForPlayer(secret_hero_pool[roll], ply)
						local name = secret_hero_pool[roll]
						local random_hero = "#bvo_randomed_" .. name
						GameRules:SendCustomMessage(random_hero, pid, 0)
						table.remove(secret_hero_pool, roll)
					end
				end
			end
			if PlayerResource:HasRandomed(pid) and PlayerResource:GetSelectedHeroName(pid) ~= nil then
				if not ply.sayRandom then
					ply.sayRandom = true
					local name = PlayerResource:GetSelectedHeroName(pid)
					if name ~= nil then
						local random_hero = "#bvo_randomed_" .. name
						GameRules:SendCustomMessage(random_hero, pid, 0)
					end
				end
			end
		end
	end
end

function ApplyCooldownReduction( _, event )
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if player == nil then return end
    local hero = player:GetAssignedHero()

    for _,cdItem in pairs(cd_reduction_items) do
	    if hero:HasItemInInventory(cdItem) then
	    	local ability = hero:FindAbilityByName( event.abilityname )
	    	--reduction
	    	local item = CreateItem(cdItem, hero, hero)
			local reduction = item:GetLevelSpecialValueFor("cd_reduction", 0 )
		    item:RemoveSelf()
		    reduction = reduction / 100
	    	--item cd
	    	if ability == nil then
	    		for i = 0, 5 do
		    		local item = hero:GetItemInSlot(i)
		    		if item ~= nil and item:GetName() == event.abilityname then
			    		ability = item
			    		if ability:GetCooldownTimeRemaining() > 0 then
					        local cdDefault = ability:GetCooldown( ability:GetLevel() - 1 )
					        local cdReduced = cdDefault * ( 1.0 - reduction )
					        local cdRemaining = ability:GetCooldownTimeRemaining()

					        if cdRemaining > cdReduced then
					            cdRemaining = cdRemaining - cdDefault * reduction
					            ability:StartCooldown( cdRemaining )
					        end
					    end
			    	end
		    	end
	    	end
	    	--skill cd
		    if ability ~= nil and ability:GetCooldownTimeRemaining() > 0 then
		        local cdDefault = ability:GetCooldown( ability:GetLevel() - 1 )
		        local cdReduced = cdDefault * ( 1.0 - reduction )
		        local cdRemaining = ability:GetCooldownTimeRemaining()

		        if cdRemaining > cdReduced then
		            cdRemaining = cdRemaining - cdDefault * reduction
		            ability:EndCooldown()
		            ability:StartCooldown( cdRemaining )
		        end
		    end
	    end
	end
end

function BvOReborn:OnSurvey(keys)
	local pid = keys.pID
	local survey = keys.sID
	local vote = keys.pVote

	local steam_id = PlayerResource:GetSteamAccountID(pid)
	local url = BaseAPI .. "ver=" .. StatsCollectionVersion .. "&id=12&steam_id=" .. steam_id .. "&survey=" .. survey .. "&vote=" .. vote
	local req = CreateHTTPRequest("POST", url)
	req:Send(function(result)
		--callback(result.Body)
	end)
end

function BvOReborn:BuyCustomItem(keys)
	if GameRules:IsGamePaused() then return end

	local pid = keys.pID
	local player = PlayerResource:GetPlayer(pid)
	local caster = player:GetAssignedHero()

	if not caster:IsAlive() then return end
	
	local amount = keys.amount
	local item = keys.item

	local itemCost = 0
	if item == '1' then
		itemCost = 2 * amount
	elseif item == '2' then
		itemCost = 2 * amount
	elseif item == '3' then
		itemCost = 2 * amount
	elseif item == '4' then
		itemCost = 2 * amount
	elseif item == '5' then
		itemCost = 1 * amount
	elseif item == '6' then
		itemCost = 7
	elseif item == '7' then
		itemCost = 7
	elseif item == '8' then
		itemCost = 30
	elseif item == '9' then
		itemCost = 10000
	end

	if item == '6' and caster:GetLevel() == 100 then
		return
	end
	if item == '8' and caster.permaAtt then
		return
	end

	if item ~= '9' then
		if caster.medals >= itemCost then
			caster.medals = caster.medals - itemCost
			if item == '1' then
				caster:ModifyStrength(2 * amount)
			elseif item == '2' then
				caster:ModifyAgility(2 * amount)
			elseif item == '3' then
				caster:ModifyIntellect(4 * amount)
			elseif item == '4' then
				caster:ModifyStrength(1 * amount)
				caster:ModifyAgility(1 * amount)
  				caster:ModifyIntellect(1 * amount)
			elseif item == '5' then
				if not(caster.medical_tractates) then
					caster.medical_tractates = 0
				end

				caster.medical_tractates = caster.medical_tractates + 1 * amount
				  
				caster:RemoveModifierByName("modifier_medical_tractate") 
				while (caster:HasModifier("modifier_medical_tractate")) do
					caster:RemoveModifierByName("modifier_medical_tractate") 
				end
				caster:AddNewModifier(caster, nil, "modifier_medical_tractate", null)
			elseif item == '6' then
				local level = caster:GetLevel()
				local exp_for_level = XP_PER_LEVEL_TABLE[level + 1] - XP_PER_LEVEL_TABLE[level]
				caster:AddExperience(exp_for_level, 0, false, true)
			elseif item == '7' then
				SendOverheadEventMessage( caster, OVERHEAD_ALERT_GOLD, caster, 2000, nil )
				caster:ModifyGold(2000, false, 0)
			elseif item == '8' then
				local primary = caster:GetPrimaryAttribute()
				if primary == 0 then caster:ModifyStrength(100) end
				if primary == 1 then caster:ModifyAgility(100) end
				if primary == 2 then caster:ModifyIntellect(100) end
				caster.permaAtt = true
				caster:FindAbilityByName("bvo_mana_on_hit"):ApplyDataDrivenModifier(caster, caster, "bvo_perma_att_modifier", {})
			end
			CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "display_medal", {msg=caster.medals} )

			caster:EmitSound("Hero_Omniknight.Purification")
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(125,125,125))
		else
			EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", caster:GetPlayerOwner())
		end
	else
		if caster:GetGold() >= itemCost then
			caster:SpendGold(itemCost, 3)
			caster.medals = caster.medals + 30
			CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "display_medal", {msg=caster.medals} )

			caster:EmitSound("DOTA_Item.Hand_Of_Midas")
    		local particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)  
   			ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
		else
			EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", caster:GetPlayerOwner())
		end
	end
end

function BvOReborn:BuyCustomItem2(keys)
	if GameRules:IsGamePaused() then return end

	local pid = keys.pID
	local player = PlayerResource:GetPlayer(pid)
	local caster = player:GetAssignedHero()

	if not caster:IsAlive() then return end
	
	local item = keys.item

	local needEmptySlot
	local partList = {}
	local itemCost = 0
	if item == 'item_emperor_maximillian_bladebane_armor' then
		needEmptySlot = false
		itemCost = 10
		table.insert(partList, "item_bladebane_armor")
		table.insert(partList, "item_maximillian")
	elseif item == 'item_megumins_eyepatch' then
		needEmptySlot = true
		itemCost = 7
	elseif item == 'item_allerias_sacred_butterfly' then
		needEmptySlot = false
		itemCost = 10
		table.insert(partList, "item_red_butterfly")
		table.insert(partList, "item_allerias_sacred_sight")
	end

	local hasEmptySlot = false
	local hasParts = 0
	for i = 0, 5 do
	 	local itemSlot = caster:GetItemInSlot(i)
	 	if itemSlot ~= nil then
	    	for _,part in pairs(partList) do
	    		if itemSlot:GetName() == part then
	    			hasParts = hasParts + 1
	    		end
			end
	 	else
	 		hasEmptySlot = true
	 	end
	end

	if needEmptySlot and not hasEmptySlot then
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", caster:GetPlayerOwner())
		return
	end
	if hasParts == #partList and caster.boss_1_essences >= itemCost then
		for i = 0, 5 do
		 	local itemSlot = caster:GetItemInSlot(i)
		 	if itemSlot ~= nil then
		    	for _,part in pairs(partList) do
		    		if itemSlot:GetName() == part then
		    			caster:RemoveItem(itemSlot)
		    			break
		    		end
				end
		 	end
		end
		caster:AddItemByName(item)
		caster.boss_1_essences = caster.boss_1_essences - itemCost
		CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "display_essence", {msg=caster.boss_1_essences} )

		caster:EmitSound("Hero_LegionCommander.Duel.Victory")
		ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	else
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", caster:GetPlayerOwner())
	end
end

function BvOReborn:OnCustomRandomPick(keys)
	if GameRules:IsGamePaused() then return end

	local pid = keys.pID
	local player = PlayerResource:GetPlayer(pid)

	if PlayerResource:HasRandomed(pid) or player:GetAssignedHero() then return end

	--try to roll secret
	--local rolledSecret = false
	--local roll = RandomInt(1, 100)
	--if roll <= 1 then
	--	rolledSecret = true
	--end
	--all possible picks
	local possible_picks = {
		"npc_dota_hero_juggernaut",
		"npc_dota_hero_zuus",
		"npc_dota_hero_ember_spirit",
		"npc_dota_hero_antimage",
		"npc_dota_hero_luna",
		"npc_dota_hero_sniper",
		"npc_dota_hero_doom_bringer",
		"npc_dota_hero_dragon_knight",
		"npc_dota_hero_riki",
		"npc_dota_hero_sven",
		"npc_dota_hero_lycan",
		"npc_dota_hero_phantom_assassin",
		"npc_dota_hero_kunkka",
		"npc_dota_hero_skeleton_king",
		"npc_dota_hero_naga_siren",
		"npc_dota_hero_slark",
		"npc_dota_hero_night_stalker",
		"npc_dota_hero_bane",
		"npc_dota_hero_elder_titan",
		"npc_dota_hero_techies",
		"npc_dota_hero_lina",
		"npc_dota_hero_phantom_lancer",
		"npc_dota_hero_spectre",
		"npc_dota_hero_keeper_of_the_light",
		"npc_dota_hero_beastmaster",
		"npc_dota_hero_mirana",
		"npc_dota_hero_troll_warlord",
		"npc_dota_hero_terrorblade",
		"npc_dota_hero_bloodseeker",
		"npc_dota_hero_slardar",
		"npc_dota_hero_axe",
		"npc_dota_hero_necrolyte",
		"npc_dota_hero_huskar",
		"npc_dota_hero_earthshaker",
		"npc_dota_hero_templar_assassin",
		"npc_dota_hero_enigma",
		"npc_dota_hero_centaur",
		--"npc_dota_hero_drow_ranger",
		--"npc_dota_hero_ursa",
		"npc_dota_hero_enchantress",
		"npc_dota_hero_vengefulspirit",
		"npc_dota_hero_windrunner",
		"npc_dota_hero_queenofpain",
	}
	--Shuffle
	for i=#possible_picks, 2, -1 do
		local j = RandomInt( 1, i )
		possible_picks[i], possible_picks[j] = possible_picks[j], possible_picks[i]
	end
	--get random hero
	local index = 1
	local thero = possible_picks[index]
	--
	--if rolledSecret then thero = "npc_dota_hero_phoenix" end
	--try to pick till we get a free hero
	local validPick = false
	while not validPick do
		--try to pick if free
		if not PlayerResource:IsHeroSelected(thero) then
			--pick
			validPick = true
			
			PlayerResource:SetHasRandomed(pid)
			CreateHeroForPlayer(thero, player)
			--remove duplicates
			local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                              Vector(0, 0, 0),
                              nil,
                              FIND_UNITS_EVERYWHERE,
                              DOTA_UNIT_TARGET_TEAM_BOTH,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)

			for _,unit in pairs(units) do
				if unit:IsRealHero() and unit:GetClassname() == thero then
					UTIL_Remove(unit)
				end
			end
			--show in chat
			local random_hero = "#bvo_randomed_" .. thero
			GameRules:SendCustomMessage(random_hero, pid, 0)
		else
			--get next hero
			index = index + 1
			thero = possible_picks[index]
		end
	end
end

function BvOReborn:OnTokenPick(keys)
	if GameRules:IsGamePaused() then return end

	local pid = keys.pID
	local player = PlayerResource:GetPlayer(pid)
	local thero = keys.thero

	if player:GetAssignedHero() == nil and not PlayerResource:IsHeroSelected(thero) then
		if player.tokenAmount ~= nil and player.tokenAmount >= 10 then
			player.tokenAmount = player.tokenAmount - 10
			CustomGameEventManager:Send_ServerToPlayer(player, "update_tokens", {msg=player.tokenAmount} )
			CreateHeroForPlayer(thero, player)
		end
	end
end

function BvOReborn:OnCosmeticChange(keys)
	local pid = keys.pid
	local ctype = keys.ctype
	local id = keys.id

	local player = PlayerResource:GetPlayer(pid)
	player.cosmetics[ctype] = id
end

const_talents = {
	"bvo_special_bonus_magic_resist_25",
	"bvo_special_bonus_armor_15",
	"bvo_special_bonus_health_650",
	"bvo_special_bonus_damage_75",
	"bvo_special_bonus_evasion_15",
	"bvo_special_bonus_attack_speed_80",
	"bvo_special_bonus_lifesteal_10",
	"bvo_special_bonus_reduced_damage_10",
}

function TalentManager()
	for _,hero in pairs(tHeroesRadiant) do
		if hero ~= nil and not hero:IsNull() then
			for __,talent in pairs(const_talents) do
				if not hero:HasModifier(talent .. "_modifier") then
					local ability = hero:FindAbilityByName(talent)
					if ability:GetLevel() >= 1 then
						hero:AddNewModifier(hero, nil, talent .. "_modifier", {})
					end
				end
			end
		end
	end
	for _,hero in pairs(tHeroesDire) do
		if hero ~= nil and not hero:IsNull() then
			for __,talent in pairs(const_talents) do
				if not hero:HasModifier(talent .. "_modifier") then
					local ability = hero:FindAbilityByName(talent)
					if ability:GetLevel() >= 1 then
						hero:AddNewModifier(hero, nil, talent .. "_modifier", {})
					end
				end
			end
		end
	end
end

function AbandonManager()
	if GameRules:State_Get() < DOTA_GAMERULES_STATE_GAME_IN_PROGRESS or GameRules:IsGamePaused() then return end
	if #tHeroesRadiant == 0 or #tHeroesDire == 0 then return end
	--Count counter up radiant
	for _,hero in pairs(tHeroesRadiant) do
		--Check only if not abandoned
		if hero ~= nil and not hero:IsNull() and not hero.HasAbandoned then
			local pid = hero:GetPlayerID()
			local connection_state = PlayerResource:GetConnectionState(pid)
			
		    if connection_state == DOTA_CONNECTION_STATE_ABANDONED then
		        hero.HasAbandoned = true
		        GameRules:SendCustomMessage("#bvo_abandon_timeup", pid, ABANDON_TIMELIMIT )
		    end

			if hero:HasModifier("afk_anti_camp_modifier") or connection_state == DOTA_CONNECTION_STATE_DISCONNECTED then
				hero.abandonCounter = hero.abandonCounter + 1
				if hero.abandonCounter % 60 == 0 then
					if hero.abandonCounter < ABANDON_TIMELIMIT then
						GameRules:SendCustomMessage("#bvo_abandon_timeleft", pid, ( ABANDON_TIMELIMIT / 60 ) - (hero.abandonCounter / 60) )
					end
				end
				if hero.abandonCounter >= ABANDON_TIMELIMIT then
					hero.HasAbandoned = true
					GameRules:SendCustomMessage("#bvo_abandon_timeup", pid, ABANDON_TIMELIMIT )
				end
			end
		end
	end
    --Count counter up dire
	for _,hero in pairs(tHeroesDire) do
		--Check only if not abandoned
		if hero ~= nil and not hero:IsNull() and not hero.HasAbandoned then
			local pid = hero:GetPlayerID()
			local connection_state = PlayerResource:GetConnectionState(pid)
			
		    if connection_state == DOTA_CONNECTION_STATE_ABANDONED then
		        hero.HasAbandoned = true
		        GameRules:SendCustomMessage("#bvo_abandon_timeup", pid, ABANDON_TIMELIMIT )
		    end

			if hero:HasModifier("afk_anti_camp_modifier") or connection_state == DOTA_CONNECTION_STATE_DISCONNECTED then
				hero.abandonCounter = hero.abandonCounter + 1
				if hero.abandonCounter % 60 == 0 then
					if hero.abandonCounter < ABANDON_TIMELIMIT then
						GameRules:SendCustomMessage("#bvo_abandon_timeleft", pid, ( ABANDON_TIMELIMIT / 60 ) - (hero.abandonCounter / 60) )
					end
				end
				if hero.abandonCounter >= ABANDON_TIMELIMIT then
					hero.HasAbandoned = true
					GameRules:SendCustomMessage("#bvo_abandon_timeup", pid, ABANDON_TIMELIMIT )
				end
			end
		end
	end
	--Test for game end condition dire
	local dire_wins = true
	for _,hero in pairs(tHeroesRadiant) do
		if hero ~= nil and not hero:IsNull() then
			local pid = hero:GetPlayerID()
			local connection_state = PlayerResource:GetConnectionState(pid)
			if not ( hero.HasAbandoned and ( hero:HasModifier("afk_anti_camp_modifier") or connection_state == DOTA_CONNECTION_STATE_DISCONNECTED or connection_state == DOTA_CONNECTION_STATE_ABANDONED ) ) then
				dire_wins = false
				break
			end
		end
	end
	if dire_wins then SetGameEnd(DOTA_TEAM_BADGUYS) end
	--Test for game end condition radiant
	local radiant_wins = true
	for _,hero in pairs(tHeroesDire) do
		if hero ~= nil and not hero:IsNull() then
			local pid = hero:GetPlayerID()
			local connection_state = PlayerResource:GetConnectionState(pid)
			if not ( hero.HasAbandoned and ( hero:HasModifier("afk_anti_camp_modifier") or connection_state == DOTA_CONNECTION_STATE_DISCONNECTED or connection_state == DOTA_CONNECTION_STATE_ABANDONED ) ) then
				radiant_wins = false
				break
			end
		end
	end
	if radiant_wins then SetGameEnd(DOTA_TEAM_GOODGUYS) end
end

function _G:RefreshMod(hero, mod, all)
	local mods = hero:FindAllModifiers()
	for _,m in pairs(mods) do
		if m:GetName() == mod then
			m:ForceRefresh()
			if not all then break end
		end
	end
end

function _G:PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..":")
                _G:PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                _G:PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                else
                    print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end

--[[
-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- licensed under the terms of the LGPL2

-- character table string
local base64_b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
function base64_enc(data)
    return ((data:gsub('.', function(x) 
        local r,base64_b='',x:byte()
        for i=8,1,-1 do r=r..(base64_b%2^i-base64_b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return base64_b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function base64_dec(data)
    data = string.gsub(data, '[^'..base64_b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(base64_b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end
]]