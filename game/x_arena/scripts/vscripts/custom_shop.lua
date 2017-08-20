function OnEnter(trigger)
  local unit = trigger.activator
  if unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS then
    local player = unit:GetPlayerOwner()
    if player then
      CustomGameEventManager:Send_ServerToPlayer(player, "display_shop", {} )
    end
  end
end

function OnLeave(trigger)
  local unit = trigger.activator
  if unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS then
    local player = unit:GetPlayerOwner()
    if player then
      CustomGameEventManager:Send_ServerToPlayer(player, "close_shop", {} )
    end
  end
end

function OnEnter2(trigger)
  local unit = trigger.activator
  if unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS then
    local player = unit:GetPlayerOwner()
    if player then
      CustomGameEventManager:Send_ServerToPlayer(player, "display_shop_2", {} )
    end
  end
end

function OnLeave2(trigger)
  local unit = trigger.activator
  if unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS then
    local player = unit:GetPlayerOwner()
    if player then
      CustomGameEventManager:Send_ServerToPlayer(player, "close_shop_2", {} )
    end
  end
end