if not BvOReborn then
	_G.BvOReborn = class({})
end

local requires = {
	"precache",
	"constants",
	"timers",
	"spawners",
	"lib/teleport",
	--"lib/duel_lib",
	"duel",
	"BvOReborn",
}
for _, r in pairs(requires) do
   require(r)
end

function Precache( context )
	for k, v in pairs( model_lookup ) do
		PrecacheModel( v, context )
		PrecacheUnitByNameSync(k, context)
	end
	for k, v in pairs( particle_precache ) do
		PrecacheResource( "particle", v, context )
	end
	for k, v in pairs( soundfile_precache ) do
		PrecacheResource( "soundfile", v, context )
	end
	for k, v in pairs( model_precache ) do
		PrecacheResource( "model", v, context )
	end
end

function Activate()
	GameRules.AddonTemplate = BvOReborn()
	BvOReborn:InitGameMode()
end