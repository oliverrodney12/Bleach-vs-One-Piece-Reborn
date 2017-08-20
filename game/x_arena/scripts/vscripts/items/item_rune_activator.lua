all_runes = {}
all_runes["bounty"] = "models/props_gameplay/rune_goldxp.vmdl"
all_runes["doubledamage"] = "models/props_gameplay/rune_doubledamage01.vmdl"
all_runes["arcane"] = "models/props_gameplay/rune_arcane.vmdl"
all_runes["haste"] = "models/props_gameplay/rune_haste01.vmdl"
all_runes["illusion"] = "models/props_gameplay/rune_illusion01.vmdl"
all_runes["invisibility"] = "models/props_gameplay/rune_invisibility01.vmdl"
all_runes["regen"] = "models/props_gameplay/rune_regeneration01.vmdl"

all_runes_pfc = {}
all_runes_pfc["bounty"] = "particles/generic_gameplay/rune_bounty.vpcf"
all_runes_pfc["doubledamage"] = "particles/generic_gameplay/rune_doubledamage.vpcf"
all_runes_pfc["arcane"] = "particles/generic_gameplay/rune_arcane.vpcf"
all_runes_pfc["haste"] = "particles/generic_gameplay/rune_haste.vpcf"
all_runes_pfc["illusion"] = "particles/generic_gameplay/rune_illusion.vpcf"
all_runes_pfc["invisibility"] = "particles/generic_gameplay/rune_invisibility.vpcf"
all_runes_pfc["regen"] = "particles/generic_gameplay/rune_regeneration.vpcf"

all_rune_sfx = {}
all_rune_sfx["bounty"] = "Rune.Bounty"
all_rune_sfx["doubledamage"] = "Rune.DD"
all_rune_sfx["arcane"] = "Rune.Arcane"
all_rune_sfx["haste"] = "Rune.Haste"
all_rune_sfx["illusion"] = "Rune.Illusion"
all_rune_sfx["invisibility"] = "Rune.Invis"
all_rune_sfx["regen"] = "Rune.Regen"

function rune_init(keys)
  local caster = keys.caster
  local rune_type = caster.rune_type

  if rune_type == "" then
    caster:RemoveSelf()
    return
  end

  local model = all_runes[rune_type]
  local particleName = all_runes_pfc[rune_type]

  caster:SetOriginalModel( model )
  caster:SetModel( model )

  local pos = caster:GetAbsOrigin()
  local adjust = Vector(pos.x, pos.y, pos.z + 72)
  caster:SetAbsOrigin(adjust)

  --particle
  local particle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
  --remove old rune
  local localUnits = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,
              caster:GetAbsOrigin(),
              nil,
              150,
              DOTA_UNIT_TARGET_TEAM_BOTH,
              DOTA_UNIT_TARGET_ALL,
              DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
              FIND_ANY_ORDER,
              false)

  for _,rune_unit in pairs(localUnits) do
    if rune_unit ~= caster and rune_unit:FindAbilityByName("custom_rune_dummy") ~= nil then
      rune_unit:RemoveSelf()
    end
  end
end

function rune_use(keys)
  local caster = keys.caster
  local ability = keys.ability
  local rune_type = caster.rune_type

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

    unit:EmitSound( all_rune_sfx[rune_type] )

    ability:ApplyDataDrivenModifier(caster, unit, "custom_rune_" .. rune_type .. "_modifier", {})
    local pid = unit:GetPlayerID()
    local name = PlayerResource:GetPlayerName(pid)
    _G:SayRunePickup( name, rune_type, unit )
    --[[
    unit:ModifyGold(250, true, 13)
    
    local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)  
    ParticleManager:SetParticleControlEnt(midas_particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), false)
    ]]
    caster:RemoveSelf()
    break   
  end
end