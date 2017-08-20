function rune_invisibility(keys)
	local caster = keys.target
	local ability = keys.ability
	local dur = ability:GetLevelSpecialValueFor("invisibility_duration", ability:GetLevel() - 1 )
	local fade_time = ability:GetLevelSpecialValueFor("invisibility_fade_time", ability:GetLevel() - 1 )

	ability:ApplyDataDrivenModifier(caster, caster, "item_rune_invisibility_fade_modifier", {duration=fade_time})
	if caster:GetClassname() == "npc_dota_hero_skeleton_king" then
		Timers:CreateTimer(2.15, function ()
			if caster.dummy_wings ~= nil and not caster.dummy_wings:IsNull() then
				caster:FindAbilityByName("bvo_mana_on_hit"):ApplyDataDrivenModifier(caster, caster.dummy_wings, "bvo_extra_invis_modifier", {duration=dur} )
			end
		end)
	end
	if caster.santa_hat ~= nil then
		Timers:CreateTimer(2.15, function ()
			if caster.santa_hat ~= nil and not caster.santa_hat:IsNull() then
				caster:FindAbilityByName("bvo_mana_on_hit"):ApplyDataDrivenModifier(caster, caster.santa_hat, "bvo_extra_invis_modifier", {duration=dur} )
			end
		end)
	end
end