function bvo_whitebeard_skill_0(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = keys.damage
	local health_percent = ability:GetLevelSpecialValueFor("health_percent", ability:GetLevel() - 1 ) / 100
	local dur = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )

	if ability:IsCooldownReady() and damage >= caster:GetHealth() * health_percent then
		ability:StartCooldown( ability:GetCooldown(0) )
		ability:ApplyDataDrivenModifier(caster, caster, "bvo_whitebeard_skill_0_buff_modifier", {duration=dur})
	end
end