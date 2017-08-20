require('timers')

function item_acid_bottle( keys )
	local caster = keys.caster
	local target = keys.target
	local item = CreateItem("item_acid_bottle", caster, caster)
	target.acidBottle = item

	local info = {
        Target = target,
        Source = caster,
        EffectName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile.vpcf",
        Ability = item,
        bDodgeable = false,
        bProvidesVision = false,
        iMoveSpeed = 1000,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
	}
	ProjectileManager:CreateTrackingProjectile( info )
end

function item_acid_bottle_hit( keys )
	local target = keys.target
	local dur = target.acidBottle:GetLevelSpecialValueFor("duration", 0 )

	if target ~= nil and not target:IsNull() then
		target:EmitSound("Hero_Alchemist.AcidSpray")
		target.acidBottle:ApplyDataDrivenModifier(target, target, "item_acid_bottle_modifier", {duration=dur})
	end
	
	Timers:CreateTimer(dur, function()
		if target ~= nil and not target:IsNull() then
			target:StopSound("Hero_Alchemist.AcidSpray")
			target.acidBottle:RemoveSelf()
			target.acidBottle = nil
		end 
	end)
end