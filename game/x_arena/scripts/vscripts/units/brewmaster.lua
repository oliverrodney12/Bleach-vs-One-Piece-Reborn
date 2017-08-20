function enrage_init( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster.enrage and not caster:HasModifier("bvo_brewmaster_enrage_buff_modifier") then
		ability:ApplyDataDrivenModifier(caster, caster, "bvo_brewmaster_enrage_buff_modifier", {})
	end
end

function enrage_start( keys )
	local caster = keys.caster
	caster:SetModelScale(1.5)
end

function remove( keys )
	keys.caster:AddNoDraw()
end

function enrage_roam( keys )
	local caster = keys.caster
	if caster.enrage then
		--roam map
	end
end