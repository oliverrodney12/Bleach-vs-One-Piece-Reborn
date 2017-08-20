function bvo_anzu_skill_qqq( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )

	caster:EmitSound("Hero_Warlock.FatalBonds")

	if caster.anzu_qqq_targets == nil then caster.anzu_qqq_targets = {} end

	local targets_to_link = {}
	table.insert(targets_to_link, caster.c_target1)
	table.insert(targets_to_link, caster.c_target2)
	table.insert(targets_to_link, caster.c_target3)
	for _,link in pairs(targets_to_link) do
		local needLink = true
		for _,linked in pairs(caster.anzu_qqq_targets) do
			if link == linked then needLink = false end
		end
		if needLink then table.insert(caster.anzu_qqq_targets, link) end
		if link:HasModifier("bvo_anzu_skill_QQQ_modifier") then
			_G:RefreshMod(link, "bvo_anzu_skill_QQQ_modifier", false)
		else
			ability:ApplyDataDrivenModifier(caster, link, "bvo_anzu_skill_QQQ_modifier", {duration=duration})
		end
	end

	if caster:HasModifier("bvo_anzu_skill_QQQ_link_modifier") then
		_G:RefreshMod(caster, "bvo_anzu_skill_QQQ_link_modifier", false)
	else
		ability:ApplyDataDrivenModifier(caster, caster, "bvo_anzu_skill_QQQ_link_modifier", {duration=duration})
	end
end

function bvo_anzu_skill_qqq_share( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local target = keys.unit
	local ability = keys.ability
	local percent = ability:GetLevelSpecialValueFor("percent", ability:GetLevel() - 1 )
	local damage = keys.Damage
	local damagePercent = percent / 100

	if target:HasModifier("item_doom_1_modifier_buff") or target:IsInvulnerable() then
		return
	end

	if damage > 1 and attacker ~= nil then
		local real_damage = damage * damagePercent
		for _,share in pairs(caster.anzu_qqq_targets) do
			if not share:HasModifier("item_doom_1_modifier_buff") and not share:IsInvulnerable() and share ~= target and share:HasModifier("bvo_anzu_skill_QQQ_modifier") then
				local new_health = share:GetHealth() - real_damage
				if new_health > 1 then
					share:SetHealth(new_health)
				else
					share:Kill(ability, attacker)
				end
			end
		end
	end
end

function bvo_anzu_skill_qqq_end( keys )
	local target = keys.target

	target.anzu_qqq_targets = nil
end

function bvo_anzu_skill_qqq_link_end( keys )
	local target = keys.target

	target.anzu_qqq_targets = nil
end