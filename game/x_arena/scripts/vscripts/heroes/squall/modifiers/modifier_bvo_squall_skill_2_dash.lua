modifier_bvo_squall_skill_2_dash = class ({})

function modifier_bvo_squall_skill_2_dash:IsHidden()
	return true
end

function modifier_bvo_squall_skill_2_dash:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
	}
 
	return funcs
end

function modifier_bvo_squall_skill_2_dash:OnCreated( kv )
	if IsServer() then
		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
		end
	end
end

function modifier_bvo_squall_skill_2_dash:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		local caster = me
		local ability = me:FindAbilityByName("bvo_squall_skill_2")

		if ability.leap_traveled < ability.leap_distance then
			local new_pos = caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed
			if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
				caster:InterruptMotionControllers(true)
				ProjectileManager:DestroyLinearProjectile(caster.squall_skill_2_projectile)
			else
				caster:SetAbsOrigin(new_pos)
				ability.leap_traveled = ability.leap_traveled + ability.leap_speed
			end
		else
			caster:InterruptMotionControllers(true)
		end
	end
end

function modifier_bvo_squall_skill_2_dash:OnDeath()
	self:GetCaster():InterruptMotionControllers(true)
end

function modifier_bvo_squall_skill_2_dash:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end