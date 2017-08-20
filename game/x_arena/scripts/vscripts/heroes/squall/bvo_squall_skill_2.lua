bvo_squall_skill_2 = class ({})
LinkLuaModifier( "modifier_bvo_squall_skill_2_dash", "heroes/squall/modifiers/modifier_bvo_squall_skill_2_dash", LUA_MODIFIER_MOTION_HORIZONTAL )

function bvo_squall_skill_2:CastFilterResultLocation( vLocation )
	local caster = self:GetCaster()

	local canCast = false
	if caster:HasModifier("bvo_squall_skill_0_revolver_modifier") then
		canCast = true
	elseif caster:HasModifier("bvo_squall_skill_0_shear_trigger_modifier") then
		canCast = true
	elseif caster:HasModifier("bvo_squall_skill_0_flame_saber_modifier") then
		canCast = true
	elseif caster:HasModifier("bvo_squall_skill_0_punishment_modifier") then
		canCast = true
	elseif caster:HasModifier("bvo_squall_skill_0_lionheart_modifier") then
		canCast = true
	end

	if not canCast then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function bvo_squall_skill_2:GetCustomCastErrorLocation( vLocation )
	return "#dota_hud_error_need_gunblade"
end

function bvo_squall_skill_2:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function bvo_squall_skill_2:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier( caster, self, "modifier_bvo_squall_skill_2_dash", nil )

	bvo_squall_skill_2_cast( {
		caster = caster,
		ability = self,
		} )

	bvo_squall_skill_0_durability_down( {
			caster = caster,
			ability = caster:FindAbilityByName("bvo_squall_skill_0"),
			amount = self:GetSpecialValueFor( "durability_cost" ),
		} )
end

function bvo_squall_skill_0_durability_down( keys )
	local caster = keys.caster
	local ability = keys.ability
	local down = keys.amount

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

function bvo_squall_skill_2:OnProjectileHit( hTarget, vLocation )
	if hTarget == nil then return end
	
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	local multi = self:GetSpecialValueFor("agi_multi")

	local damage_multi_revolver = self:GetSpecialValueFor("damage_multi_revolver")
	local damage_multi_shear_trigger = self:GetSpecialValueFor("damage_multi_shear_trigger")
	local damage_multi_flame_saber = self:GetSpecialValueFor("damage_multi_flame_saber")
	local damage_multi_punishment = self:GetSpecialValueFor("damage_multi_punishment")
	local damage_multi_lionheart = self:GetSpecialValueFor("damage_multi_lionheart")

	local damage_multi = 100
	if caster:HasModifier("bvo_squall_skill_0_revolver_modifier") then
		damage_multi = damage_multi + damage_multi_revolver
	elseif caster:HasModifier("bvo_squall_skill_0_shear_trigger_modifier") then
		damage_multi = damage_multi + damage_multi_shear_trigger
	elseif caster:HasModifier("bvo_squall_skill_0_flame_saber_modifier") then
		damage_multi = damage_multi + damage_multi_flame_saber
	elseif caster:HasModifier("bvo_squall_skill_0_punishment_modifier") then
		damage_multi = damage_multi + damage_multi_punishment
	elseif caster:HasModifier("bvo_squall_skill_0_lionheart_modifier") then
		damage_multi = damage_multi + damage_multi_lionheart
	end

	hTarget:EmitSound("Hero_Magnataur.ShockWave.Target")

	local damageTable = {
		victim = hTarget,
		attacker = caster,
		damage = ( ( multi * caster:GetAgility() ) + damage ) * ( damage_multi / 100 ),
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
end

function bvo_squall_skill_2_cast(keys)
	local caster = keys.caster
	local ability = keys.ability

	ability.leap_direction = caster:GetForwardVector()
	ability.leap_distance = 700
	ability.leap_speed = 2250 * 1/30
	ability.leap_traveled = 0

	caster:EmitSound("Hero_Magnataur.ShockWave.Cast")
	caster:EmitSound("Hero_Magnataur.ShockWave.Particle")

	local info = 
	{
		Ability = ability,
    	EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = 700,
    	fStartRadius = 250,
    	fEndRadius = 250,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector():Normalized() * 2250,
		bProvidesVision = false,
		iVisionRadius = 100,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	caster.squall_skill_2_projectile = ProjectileManager:CreateLinearProjectile(info)
end