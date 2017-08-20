function rune_regen_end( keys )
	local caster = keys.target
	if caster:GetHealth() == caster:GetMaxHealth() and caster:GetMana() == caster:GetMaxMana() then
		caster:RemoveModifierByName("custom_rune_regen_modifier")
	end
end

function rune_regen_force_end( keys )
	keys.unit:RemoveModifierByName("custom_rune_regen_modifier")
end