function bvo_squall_skill_0_durability( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local durability = keys.durability

	caster:SetModifierStackCount(modifier, ability, durability)
end

function bvo_squall_skill_0_durability_down( keys )
	local caster = keys.caster
	local ability = keys.ability
	local down = keys.amount

	if not caster:IsRealHero() then return end

	local modifier
	if caster:HasModifier("bvo_squall_skill_0_revolver_modifier") then
		modifier = "bvo_squall_skill_0_revolver_modifier"
	elseif caster:HasModifier("bvo_squall_skill_0_shear_trigger_modifier") then
		modifier = "bvo_squall_skill_0_shear_trigger_modifier"
	elseif caster:HasModifier("bvo_squall_skill_0_flame_saber_modifier") then
		modifier = "bvo_squall_skill_0_flame_saber_modifier"
	elseif caster:HasModifier("bvo_squall_skill_0_punishment_modifier") then
		modifier = "bvo_squall_skill_0_punishment_modifier"
	elseif caster:HasModifier("bvo_squall_skill_0_lionheart_modifier") then
		modifier = "bvo_squall_skill_0_lionheart_modifier"
	end

	if modifier ~= nil then
		local current_stack = caster:GetModifierStackCount(modifier, ability)
		if current_stack - down > 0 then
			caster:SetModifierStackCount(modifier, ability, current_stack - down)
		else
			caster:RemoveModifierByName(modifier)
		end
	end
end

function bvo_squall_skill_0_flame_saber_damage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage_flame_saber", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("agi_multi_flame_saber", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = ( multi * caster:GetAgility() ) + damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage(damageTable)
end