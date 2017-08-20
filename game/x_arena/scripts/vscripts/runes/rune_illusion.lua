function rune_illusion(keys)
	local caster = keys.target
	local ability = keys.ability
	local dur = ability:GetLevelSpecialValueFor("illusion_duration", ability:GetLevel() - 1 )
	local outgoing_damage = ability:GetLevelSpecialValueFor("illusion_outgoing_damage", ability:GetLevel() - 1 )
	local incoming_damage_melee = ability:GetLevelSpecialValueFor("illusion_incoming_damage_melee", ability:GetLevel() - 1 )
	local incoming_damage_ranged = ability:GetLevelSpecialValueFor("illusion_incoming_damage_ranged", ability:GetLevel() - 1 )

	local unit_name = caster:GetUnitName()
	local casterOrigin = caster:GetAbsOrigin()
	local casterAngles = caster:GetAngles()
	
	for i = 1, 2 do
		-- handle_UnitOwner needs to be nil, else it will crash the game.
		local illusion = CreateUnitByName(unit_name, casterOrigin, true, caster, nil, caster:GetTeamNumber())
		illusion:SetPlayerID(caster:GetPlayerID())
		illusion:SetControllableByPlayer(caster:GetPlayerID(), true)

		illusion:SetAngles( casterAngles.x, casterAngles.y, casterAngles.z )
		
		-- Level Up the unit to the casters level
		local casterLevel = caster:GetLevel()
		for i = 1, casterLevel - 1 do
			illusion:HeroLevelUp(false)
		end

		-- Set the skill points to 0 and learn the skills of the caster
		illusion:SetAbilityPoints(0)
		for abilitySlot = 0, 15 do
			local ability = caster:GetAbilityByIndex(abilitySlot)
			if ability ~= nil then 
				local abilityLevel = ability:GetLevel()
				local abilityName = ability:GetAbilityName()
				local illusionAbility = illusion:FindAbilityByName(abilityName)
				if illusionAbility ~= nil then
					illusionAbility:SetLevel(abilityLevel)
				end
			end
		end

		-- Recreate the items of the caster
		for itemSlot = 0, 5 do
			local item = caster:GetItemInSlot(itemSlot)
			if item ~= nil then
				local itemName = item:GetName()
				local newItem = CreateItem(itemName, illusion, illusion)
				illusion:AddItem(newItem)
			end
		end

		-- Set the unit as an illusion
		-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
		if caster:GetAttackCapability() == 1 then
			illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = dur, outgoing_damage = outgoing_damage, incoming_damage = incoming_damage_melee })
		else
			illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = dur, outgoing_damage = outgoing_damage, incoming_damage = incoming_damage_ranged })
		end
		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		illusion:MakeIllusion()
		-- Set the illusion hp to be the same as the caster
		illusion:SetHealth(caster:GetHealth())

		--Apply custom cosmetics
		_G:ApplyCustomCosmetics( caster:GetPlayerOwner(), illusion)
	end
end