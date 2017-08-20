function bvo_usopp_skill_0_track(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster.bvo_usopp_skill_0_hp_old = caster.bvo_usopp_skill_0_hp_old or caster:GetMaxHealth()
	caster.bvo_usopp_skill_0_hp = caster.bvo_usopp_skill_0_hp or caster:GetMaxHealth()

	caster.bvo_usopp_skill_0_hp_old = caster.bvo_usopp_skill_0_hp
	caster.bvo_usopp_skill_0_hp = caster:GetHealth()
end

function bvo_usopp_skill_0_damage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = keys.damage

	ability.damageTaken = ability.damageTaken + damage

	local new_health = caster.bvo_usopp_skill_0_hp_old
	if new_health > caster:GetMaxHealth() then
		new_health = caster:GetMaxHealth()
	end
	caster:SetHealth(new_health)
end