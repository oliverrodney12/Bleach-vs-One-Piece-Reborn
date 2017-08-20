require('timers')

doom_items = {
	"item_doom_1",
	"item_doom_2",
	"item_doom_3",
	"item_doom_4",
	"item_doom_5",
}

function item_doom_1(keys)
	local caster = keys.caster
	local ability = keys.ability

	for i = 0, 5 do
		local item = caster:GetItemInSlot(i)
		if item ~= nil then
			for _,name in pairs(doom_items) do
				if item:GetName() == name then
					item:StartCooldown(ability:GetCooldownTimeRemaining())
				end
			end
    	end
	end
end

function item_doom_2(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local percent = ability:GetLevelSpecialValueFor("percent_damage", 0 ) / 100
	
	if caster:IsIllusion() and not caster:HasModifier("item_mirror_of_kalandra_illu_modifier") then return end

	if not target:IsMagicImmune() and not target:HasModifier("bvo_creep_immune_modifier") then
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = target:GetHealth() * percent,
			damage_type = DAMAGE_TYPE_PURE,
		}
		ApplyDamage(damageTable)
	end
end

function item_doom_3(params)
	local damage = params.Damage
	local attacker = params.attacker
	local hero = params.caster
	local ability = params.ability
	local percent = ability:GetLevelSpecialValueFor("damage_return", 0 )
	local return_damage_percent = percent / 100

	if hero:IsIllusion() and not hero:HasModifier("item_mirror_of_kalandra_illu_modifier") then return end

	if not attacker:IsMagicImmune() then
		if damage > 1 and attacker and hero and attacker~=hero then 
			if attacker:GetHealth() < damage*return_damage_percent then
				ApplyDamage({ victim = attacker, attacker = hero, damage = attacker:GetHealth(),	damage_type = DAMAGE_TYPE_PURE })
			else
				ApplyDamage({ victim = attacker, attacker = attacker, damage = damage*return_damage_percent-1,	damage_type = DAMAGE_TYPE_PURE })
				ApplyDamage({ victim = attacker, attacker = hero, damage = 1, damage_type = DAMAGE_TYPE_PURE })
			end
		end
	end
end

function item_doom_5_fade(keys)
	local caster = keys.caster
	local ability = keys.ability

	if not caster:HasModifier("item_doom_5_fade_modifier") and not caster:HasModifier("item_doom_5_invisibility_modifier") then
		ability:ApplyDataDrivenModifier(caster, caster, "item_doom_5_fade_modifier", {duration=5.0})
	end
end