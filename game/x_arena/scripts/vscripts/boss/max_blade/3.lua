function on_hit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if ability:IsCooldownReady() and not caster:IsSilenced() then
		if not target:HasModifier("boss_maximillian_bladebane_skill_3_burn_modifier") then
			ability:StartCooldown(10.0)
			ability:ApplyDataDrivenModifier(caster, target, "boss_maximillian_bladebane_skill_3_burn_modifier", {})
		end
	end
end

function checkLeash( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not caster:IsAlive() then
		target:RemoveModifierByName("boss_maximillian_bladebane_skill_3_burn_modifier")
		return
	end
	if (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() > 700 then
		target:RemoveModifierByName("boss_maximillian_bladebane_skill_3_burn_modifier")
	end
end