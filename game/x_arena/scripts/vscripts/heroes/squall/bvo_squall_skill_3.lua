bvo_squall_skill_3 = class ({})

function bvo_squall_skill_3:CastFilterResult()
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

function bvo_squall_skill_3:GetCustomCastError()
	return "#dota_hud_error_need_gunblade"
end

function bvo_squall_skill_3:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function bvo_squall_skill_3:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function bvo_squall_skill_3:OnSpellStart()
	local caster = self:GetCaster()

	bvo_squall_skill_3_cast(self)

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

function bvo_squall_skill_3_cast(self)
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local str_multi = self:GetSpecialValueFor("str_multi")
	local agi_multi = self:GetSpecialValueFor("agi_multi")

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

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            radius,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			damage = ( ( agi_multi * caster:GetAgility() ) + ( str_multi * caster:GetStrength() ) ) * ( damage_multi / 100 ),
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		ApplyDamage(damageTable)
	end

	caster:EmitSound("Hero_Invoker.DeafeningBlast")

	local casterPos = caster:GetAbsOrigin()
	local particles = 12
	for i = 0, ( particles - 1 ) do
	    local rotation = QAngle( 0, ( 360 / particles ) * i, 0 )
		local rot_vector = RotatePosition(casterPos, rotation, casterPos + Vector(0, 100, 0))

		local info = 
		{
			ability = self,
	    	EffectName = "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf",
	    	vSpawnOrigin = casterPos,
	    	fDistance = radius,
	    	fStartRadius = 10,
	    	fEndRadius = 10,
	    	Source = caster,
	    	bHasFrontalCone = false,
	    	bReplaceExisting = false,
	    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
	    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    	iUnitTargetType = DOTA_UNIT_TARGET_NONE,
	    	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = (rot_vector - casterPos):Normalized() * 2000,
			bProvidesVision = false,
			iVisionRadius = 100,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(info)
	end
end