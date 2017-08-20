function item_holy_guard_init( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability:GetCurrentCharges() > 0 then
		if not caster:HasModifier("item_holy_guard_buff_modifier") then
			ability:ApplyDataDrivenModifier(caster, caster, "item_holy_guard_buff_modifier", {})
		end
	end
end

function item_holy_guard_stack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local max = ability:GetLevelSpecialValueFor("max_stacks", 0 )

	local current_stack = ability:GetCurrentCharges()
	local new_stack = current_stack + 1

	if new_stack > max then return end

	ability:SetCurrentCharges(new_stack)
	if new_stack > 0 then
		if not caster:HasModifier("item_holy_guard_buff_modifier") then
			ability:ApplyDataDrivenModifier(caster, caster, "item_holy_guard_buff_modifier", {})
		end
	end
end

function item_holy_guard_damage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local heal = ability:GetLevelSpecialValueFor("heal", 0 )

	local current_stack = ability:GetCurrentCharges()
	local new_stack = current_stack - 1

	if new_stack >= 0 then
		caster:Heal(heal, ability)
		if not caster:HasModifier("item_holy_guard_cast_modifier") then
			ability:SetCurrentCharges(new_stack)
		end
	end
	if new_stack <= 0 then
		if caster:HasModifier("item_holy_guard_buff_modifier") then
			caster:RemoveModifierByName("item_holy_guard_buff_modifier")
		end
	end
end

function item_holy_guard_end( keys )
	local caster = keys.caster

	caster:RemoveModifierByName("item_holy_guard_buff_modifier")
end