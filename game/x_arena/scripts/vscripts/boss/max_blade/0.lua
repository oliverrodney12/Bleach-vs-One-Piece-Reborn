function max_blade_dead( keys )
	local point = Entities:FindByName( nil, "BOSS_ARENA_CENTER" ):GetAbsOrigin()
	local cut_trees_at = Vector( point.x, point.y + 640, point.z )
	GridNav:DestroyTreesAroundPoint(cut_trees_at, 800, false)
end