function modifier_item_heart_datadriven_regen_on_interval_think(keys)
	local caster = keys.caster
	if caster:IsRealHero() or caster:HasModifier("item_mirror_of_kalandra_illu_modifier")  then
		caster:Heal(caster:GetMaxHealth() * (keys.HealthRegenPercentPerSecond / 100) * keys.HealInterval, caster)
	end
end