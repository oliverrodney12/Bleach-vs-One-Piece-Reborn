require('timers')

function bvo_kissshot_skill_0( keys )
	local caster = keys.caster
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local abilityManaCost = ability:GetManaCost(ability:GetLevel() - 1 )
	local reincarnate_time = ability:GetLevelSpecialValueFor( "reincarnate_time", ability:GetLevel() - 1 )

	if not caster:IsRealHero() then return end

	local casterHP = caster:GetHealth()
	local casterMana = caster:GetMana()

	if casterHP == 0 and ability:IsCooldownReady() and casterMana >= abilityManaCost  then

		-- Custom ankh flag
		caster.ankh = true
		-- Variables for Reincarnation
		local respawnPosition = caster:GetAbsOrigin() + Vector(0, 0, 128)
		
		-- Start cooldown on the passive
		ability:StartCooldown(cooldown)

		-- Kill, counts as death for the player but doesn't count the kill for the killer unit
		caster:SetHealth(1)
		caster:Kill(caster, nil)

		-- Set the short respawn time and respawn position
		caster:SetTimeUntilRespawn(reincarnate_time) 
		caster:SetRespawnPosition(respawnPosition - Vector(0, 0, 128)) 

		-- Grave and particles
		local model = "models/heroes/phoenix/phoenix_egg.vmdl"
		local grave = Entities:CreateByClassname("prop_dynamic")
    	grave:SetModel(model)
    	grave:SetAbsOrigin(respawnPosition)

    	local particleName = "particles/units/heroes/hero_phoenix/phoenix_supernova_egg.vpcf"
		caster.ReincarnateParticle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )

		-- End
		caster:EmitSound("Hero_Phoenix.SuperNova.Begin")
		Timers:CreateTimer(reincarnate_time, function()
			grave:RemoveSelf()

			ParticleManager:DestroyParticle(caster.ReincarnateParticle, false)

			local particleName = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"
			ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, caster)

			caster:EmitSound("Hero_Phoenix.SuperNova.Explode")
		end)
	elseif casterHP == 0 then
		-- On death without reincarnation, set the respawn time
		caster:SetTimeUntilRespawn(3)
	end
end