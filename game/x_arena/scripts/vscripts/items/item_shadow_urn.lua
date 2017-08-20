function item_shadow_urn( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )

	if not target:HasModifier("item_shadow_urn_modifier") then
		target.shadow_urn_health = target:GetHealth()
		ability:ApplyDataDrivenModifier(caster, target, "item_shadow_urn_modifier", {duration=duration})
	else
		local mods = target:FindAllModifiers()
		for _,mod in pairs(mods) do
			if mod:GetName() == "item_shadow_urn_modifier" then
				mod:ForceRefresh()
				break
			end
		end
	end
end

function item_shadow_urn_gain( keys )
	local target = keys.target

	if target:GetHealth() > target.shadow_urn_health then
		target:SetHealth(target.shadow_urn_health)
	else
		target.shadow_urn_health = target:GetHealth()
	end
end