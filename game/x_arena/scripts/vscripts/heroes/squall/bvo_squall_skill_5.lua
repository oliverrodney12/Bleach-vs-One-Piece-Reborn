bvo_squall_skill_5 = class ({})

LinkLuaModifier( "bvo_squall_skill_5_caster", "heroes/squall/modifiers/bvo_squall_skill_5_caster", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bvo_squall_skill_5_target", "heroes/squall/modifiers/bvo_squall_skill_5_target", LUA_MODIFIER_MOTION_NONE )

function bvo_squall_skill_5:CastFilterResultTarget( hTarget )
	local caster = self:GetCaster()

	local nResult = UnitFilter( hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, caster:GetTeamNumber() )
	if nResult ~= UF_SUCCESS then return nResult end

	if caster:GetHealthPercent() >= 40 then
		return UF_FAIL_CUSTOM
	end

	if not caster:HasModifier("bvo_squall_skill_0_lionheart_modifier") then
		return UF_FAIL_CUSTOM
	end

	if not caster:HasModifier("bvo_squall_skill_4_limit_modifier") then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function bvo_squall_skill_5:GetCustomCastErrorTarget( hTarget )
	local caster = self:GetCaster()

	if caster:GetHealthPercent() >= 40 then return "#dota_hud_error_under_40percent_hp" end

	if not caster:HasModifier("bvo_squall_skill_0_lionheart_modifier") then return "#dota_hud_error_need_lionheart" end

	if not caster:HasModifier("bvo_squall_skill_4_limit_modifier") then return "#dota_hud_error_require_limit_break" end

	return ""
end

function bvo_squall_skill_5:GetCastAnimation()
	return ACT_DOTA_ATTACK2
end

function bvo_squall_skill_5:OnSpellStart()
	local caster = self:GetCaster()

	bvo_squall_skill_5_cast( {
		caster = caster,
		target = self:GetCursorTarget(),
		ability = self,
		} )
end

function bvo_squall_skill_5_cast( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local str_multi = ability:GetSpecialValueFor("str_multi")
	local agi_multi = ability:GetSpecialValueFor("agi_multi")
	local damage = ability:GetSpecialValueFor("damage")

	caster:Stop()
	target:Stop()
	caster:AddNewModifier(caster, ability, "bvo_squall_skill_5_caster", {duration=3.0})
	target:AddNewModifier(caster, ability, "bvo_squall_skill_5_target", {duration=3.0})

	target:EmitSound("Hero_Riki.Blink_Strike")

	local centerPoint = target:GetAbsOrigin()
	local hit_amount = 30
	local interval = 0.1

	local leap_direction = caster:GetForwardVector():Normalized()
	local leap_speed = 2000 * 1/30
	Timers:CreateTimer(0.03, function()
		if target:HasModifier("bvo_squall_skill_5_target") then
			local new_pos = target:GetAbsOrigin() + leap_direction * leap_speed
			if GridNav:CanFindPath(target:GetAbsOrigin(), new_pos) then
				target:SetAbsOrigin(new_pos)
			end
			return 0.03
		else
			FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)
			local damageTable = {
				victim = target,
				attacker = caster,
				damage = damage + ( agi_multi * caster:GetBaseAgility() ) + ( str_multi * caster:GetBaseStrength() ),
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage(damageTable)
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(particle, 0, Vector(275, 0, 275))
			target:EmitSound("Hero_Centaur.HoofStomp")
			return nil
		end
	end)
	for i = 1, hit_amount do
		Timers:CreateTimer(i * interval, function ()
			leap_direction = Vector(RandomFloat(-1, 1), RandomFloat(-1, 1), 0)
			local difference = caster:GetAbsOrigin() - target:GetAbsOrigin()
			
			local temp_pos = caster:GetAbsOrigin()
			FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)
			if not GridNav:CanFindPath(caster:GetAbsOrigin(), temp_pos) then
				FindClearSpaceForUnit(caster, temp_pos, false)
			end

			caster:SetForwardVector(difference)
			caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK2, 3.0)
			caster:EmitSound("Hero_Axe.Attack")
		end)
	end
end