function item_stout_shield_custom_init( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability:GetCurrentCharges() > 0 then
		if not caster:HasModifier("item_stout_shield_custom_buff_modifier") then
			ability:ApplyDataDrivenModifier(caster, caster, "item_stout_shield_custom_buff_modifier", {})
		end
	end
end

function item_stout_shield_custom_stack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local max = ability:GetLevelSpecialValueFor("max_stacks", 0 )

	local current_stack = ability:GetCurrentCharges()
	local new_stack = current_stack + 1

	if new_stack > max then return end

	ability:SetCurrentCharges(new_stack)
	if new_stack > 0 then
		if not caster:HasModifier("item_stout_shield_custom_buff_modifier") then
			ability:ApplyDataDrivenModifier(caster, caster, "item_stout_shield_custom_buff_modifier", {})
		end
	end
end

function item_stout_shield_custom_damage( keys )
	local caster = keys.caster
	local ability = keys.ability

	local current_stack = ability:GetCurrentCharges()
	local new_stack = current_stack - 1

	if new_stack >= 0 then
		ability:SetCurrentCharges(new_stack)
	end
	if new_stack <= 0 then
		if caster:HasModifier("item_stout_shield_custom_buff_modifier") then
			caster:RemoveModifierByName("item_stout_shield_custom_buff_modifier")
		end
	end
end

function item_stout_shield_custom_end( keys )
	local caster = keys.caster

	caster:RemoveModifierByName("item_stout_shield_custom_buff_modifier")
end