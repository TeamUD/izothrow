LinkLuaModifier( "modifier_physic_laws_disperse", "modifier/modifier_physic_laws_dispersion", LUA_MODIFIER_MOTION_NONE)

physic_laws = class({})

function physic_laws:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_spectre.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_spectre/spectre_dispersion.vpcf", context )
end

function physic_laws:Spawn()
	if not IsServer() then return end
end

function physic_laws:GetIntrinsicModifierName()
    return "modifier_physic_laws_dispersion"
end
