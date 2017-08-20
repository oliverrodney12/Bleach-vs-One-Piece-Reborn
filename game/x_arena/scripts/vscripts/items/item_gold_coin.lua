function gold_coin_init(keys)
  local caster = keys.caster

  caster:SetOriginalModel("models/props_gameplay/gold_coin001.vmdl")
  caster:SetModel("models/props_gameplay/gold_coin001.vmdl")
  local pos = caster:GetAbsOrigin()
  local adjust = Vector(pos.x, pos.y, pos.z + 72)
  caster:SetAbsOrigin(adjust)
end

function gold_coin_use(keys)
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

    unit:ModifyGold(250, true, 13)
    --overhead alert
    _G:PopupNumbers(unit, "gold", Vector(255, 200, 33), 1.0, 250, POPUP_SYMBOL_PRE_PLUS, nil, false)
    --Start the particle and sound.
    unit:EmitSound("DOTA_Item.Hand_Of_Midas")
    local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)  
    ParticleManager:SetParticleControlEnt(midas_particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), false)
    caster:RemoveSelf()
    break   
  end
end