require('timers')

function essence_init(keys)
  local caster = keys.caster
  local ability = keys.ability

  caster:SetOriginalModel("models/props_gameplay/tango.vmdl")
  caster:SetModel("models/props_gameplay/tango.vmdl")
  local pos = caster:GetAbsOrigin()
  local adjust = Vector(pos.x, pos.y, pos.z + 72)
  caster:SetAbsOrigin(adjust)

  --motion
  local direction = Vector( RandomFloat(-1, 1), RandomFloat(-1, 1), 0 )
  local leap_direction = direction:Normalized()
  local leap_distance = RandomInt(800, 1400)
  local leap_speed = RandomInt(200, 600) * 1/30
  local leap_traveled = 0
  Timers:CreateTimer(0.03, function()
    if leap_traveled < leap_distance then
      local new_pos = caster:GetAbsOrigin() + leap_direction * leap_speed
      if GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
        caster:SetAbsOrigin(new_pos)
        leap_traveled = leap_traveled + leap_speed
        return 0.03
      else
        ability:ApplyDataDrivenModifier(caster, caster, "essence_dummy", {} )
        caster.particle_ground = ParticleManager:CreateParticle("particles/custom/items/item_essence/essence.vpcf", PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(caster.particle_ground, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(caster.particle_ground, 1, Vector(85, 85, 85))
        caster:EmitSound("Hero_Treant.LivingArmor.Target")
        return nil
      end
    else
      ability:ApplyDataDrivenModifier(caster, caster, "essence_dummy", {} )
      caster.particle_ground = ParticleManager:CreateParticle("particles/custom/items/item_essence/essence.vpcf", PATTACH_WORLDORIGIN, caster)
      ParticleManager:SetParticleControl(caster.particle_ground, 0, caster:GetAbsOrigin())
      ParticleManager:SetParticleControl(caster.particle_ground, 1, Vector(85, 85, 85))
      caster:EmitSound("Hero_Treant.LivingArmor.Target")
      return nil
    end
  end)
end

function essence_use(keys)
  local caster = keys.caster
  local ability = keys.ability

  if not ability:IsCooldownReady() then return end

  local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    150,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
                    FIND_CLOSEST,
                    false)

  for _,unit in pairs(localUnits) do
    ability:StartCooldown(10.0)
    
    unit.boss_1_essences = unit.boss_1_essences + 1
    CustomGameEventManager:Send_ServerToPlayer(unit:GetPlayerOwner(), "display_essence", {msg=unit.boss_1_essences} )
    local particle_id = caster.particle_ground
    --Start the particle and sound.
    unit:EmitSound("DOTA_Item.Tango.Activate")
    local essence_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_overgrowth_vines_small.vpcf", PATTACH_WORLDORIGIN, caster)  
    ParticleManager:SetParticleControl(essence_particle, 0, caster:GetAbsOrigin())

    caster:RemoveSelf()
    if particle_id ~= nil and particle_id > -1 then
      ParticleManager:DestroyParticle(particle_id, false)
    end
    break
  end
  
end