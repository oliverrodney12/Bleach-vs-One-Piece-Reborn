function kyuubi_healthbar_init( keys )
	local caster = keys.caster

	caster.radiant_damage = 0
	caster.dire_damage = 0
end

function kyuubi_healthbar( keys )
	local caster = keys.caster
	local damage = keys.damage
	local attacker = keys.attacker

	local max_damage = 10000

	if damage > max_damage then
		caster:Heal(damage - max_damage, caster)
		damage = max_damage
	end

	if attacker:IsIllusion() then
		attacker:Kill(attacker, attacker)
	end

	if attacker:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		caster.radiant_damage = caster.radiant_damage + damage
	elseif attacker:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		caster.dire_damage = caster.dire_damage + damage
	end

	local radiantDamage = caster.radiant_damage
	local direDamage = caster.dire_damage

	local w_Radiant = 50
	local w_Dire = 50
	if radiantDamage > direDamage then
		w_Radiant = 50 + ( ( ( 1 - ( direDamage / radiantDamage ) ) / 2 ) * 100 )
		w_Radiant = math.ceil(w_Radiant)
		w_Dire = 100 - w_Radiant
	elseif direDamage > radiantDamage then
		w_Dire = 50 + ( ( ( 1 - ( radiantDamage / direDamage ) ) / 2 ) * 100 )
		w_Dire = math.ceil(w_Dire)
		w_Radiant = 100 - w_Dire
	end

	local str_wRadiant = w_Radiant .. '%'
	local str_wDire = w_Dire .. '%'

	CustomGameEventManager:Send_ServerToAllClients("update_healthbar", {radiant=str_wRadiant, dire=str_wDire} )
end