function item_allerias_sacred_butterfly_track( keys )
	local caster = keys.caster

	caster.allerias_butterfly_hp_old = caster.allerias_butterfly_hp_old or caster:GetMaxHealth()
	caster.allerias_butterfly_hp = caster.allerias_butterfly_hp or caster:GetMaxHealth()

	caster.allerias_butterfly_hp_old = caster.allerias_butterfly_hp
	caster.allerias_butterfly_hp = caster:GetHealth()
end

function item_allerias_sacred_butterfly_heal( keys )
	local caster = keys.caster

	caster:SetHealth(caster.allerias_butterfly_hp_old)
end