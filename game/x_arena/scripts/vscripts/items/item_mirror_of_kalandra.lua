function item_mirror_of_kalandra( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor("outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor("incoming_damage", ability:GetLevel() - 1 )

	local pid = caster:GetPlayerID()
	local unit_name = target:GetUnitName()

	local targetPos = target:GetAbsOrigin()
	local targetAngles = target:GetAngles()

	target:EmitSound("DOTA_Item.Manta.Activate")

	local illusion = CreateUnitByName(unit_name, targetPos, true, caster, nil, caster:GetTeamNumber())
	FindClearSpaceForUnit(illusion, targetPos, true )
	illusion:SetPlayerID(pid)
	illusion:SetControllableByPlayer(pid, true)

	illusion:SetAngles( targetAngles.x, targetAngles.y, targetAngles.z )
	
	for i = 1, (target:GetLevel() - 1) do
		illusion:HeroLevelUp(false)
	end

	illusion:SetAbilityPoints(0)
	for abilitySlot = 0, 15 do
		local ability = target:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			if illusionAbility ~= nil then
				illusionAbility:SetLevel(abilityLevel)
			end
		end
	end

	for itemSlot = 0, 5 do
		local item = target:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	if duration > 0 then
		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration=duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	else
		illusion:AddNewModifier(caster, ability, "modifier_illusion", { outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	end
	illusion:MakeIllusion()
	illusion:SetHealth(target:GetHealth())

	ability:ApplyDataDrivenModifier(caster, illusion, "item_mirror_of_kalandra_illu_modifier", {})
end

function item_mirror_of_kalandra_cd( keys )
	local caster = keys.caster
	local target = keys.target

	for itemSlot = 0, 5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			if itemName == "item_mirror_of_kalandra" then
				item:EndCooldown()
				item:StartCooldown(target:GetHealthPercent())
			end
		end
	end
end

function item_mirror_of_kalandra_cd_end( keys )
	local caster = keys.caster
	local target = keys.target

	for itemSlot = 0, 5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			if itemName == "item_mirror_of_kalandra" then
				item:EndCooldown()
				item:StartCooldown( item:GetCooldown(0) )
			end
		end
	end
end