function bvo_anzu_skill_2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local int_heal = ability:GetLevelSpecialValueFor("int_heal", ability:GetLevel() - 1 )

	local heal = caster:GetIntellect() * int_heal
	target:Heal(heal, ability)
	_G:PopupNumbers(target, "heal", Vector(50, 255, 5), 1.0, heal, POPUP_SYMBOL_PRE_PLUS, nil, true)
end

function bvo_anzu_skill_2_tick( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1 )

	caster:EmitSound("n_creep_ForestTrollHighPriest.Heal")

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            radius,
	            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	            DOTA_UNIT_TARGET_HERO,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		local projTable = {
	        EffectName = "particles/custom/anzu/anzu_skill_1/anzu_spell_storm_bolt.vpcf",
	        Ability = ability,
	        Target = unit,
	        Source = caster,
	        bDodgeable = false,
	        bProvidesVision = false,
	        vSpawnOrigin = caster:GetAbsOrigin(),
	        iMoveSpeed = 2000,
	        iVisionRadius = 0,
	        iVisionTeamNumber = caster:GetTeamNumber(),
	        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	    }
	    ProjectileManager:CreateTrackingProjectile(projTable)
	end
end