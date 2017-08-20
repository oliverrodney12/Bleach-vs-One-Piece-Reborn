function item_dark_urn( keys )
	local target = keys.target

	target.dark_urn_health = target:GetHealth()
end

function item_dark_urn_gain( keys )
	local target = keys.target

	if target:GetHealth() > target.dark_urn_health then
		target:SetHealth(target.dark_urn_health)
	else
		target.dark_urn_health = target:GetHealth()
	end
end