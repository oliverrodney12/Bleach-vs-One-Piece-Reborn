function item_corrupted_desolator(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if ability:IsCooldownReady() then
		ability:StartCooldown(10.0)
		ability:ApplyDataDrivenModifier(caster, target, "item_corrupted_desolator_armor_modifier", {duration=4.0})
	end
end