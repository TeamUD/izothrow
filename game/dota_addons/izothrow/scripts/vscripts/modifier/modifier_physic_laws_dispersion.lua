modifier_physic_laws_dispersion = class({})

function modifier_physic_laws_dispersion:IsHidden()
	return true
end

function modifier_physic_laws_dispersion:IsDebuff()
	return false
end

function modifier_physic_laws_dispersion:IsStunDebuff()
	return false
end

function modifier_physic_laws_dispersion:IsPurgable()
	return false
end

function modifier_physic_laws_dispersion:OnCreated( kv )
	self.parent = self:GetParent()

	-- references
	self.reflect = self:GetAbility():GetSpecialValueFor( "damage_reflection_pct" )
	self.min_radius = self:GetAbility():GetSpecialValueFor( "min_radius" )
	self.max_radius = self:GetAbility():GetSpecialValueFor( "max_radius" )
	self.delta = self.max_radius-self.min_radius

	if not IsServer() then return end
	-- for shard
	self.attacker = {}

	-- precache damage
	self.damageTable = {
		-- victim = target,
		attacker = self.parent,
		-- damage = 500,
		-- damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility(), --Optional.
		damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION, --Optional.
	}
end

function modifier_physic_laws_dispersion:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_physic_laws_dispersion:OnRemoved()
end

function modifier_physic_laws_dispersion:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_physic_laws_dispersion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}

	return funcs
end

function modifier_physic_laws_dispersion:GetModifierIncomingDamage_Percentage( params )
	if self.parent:PassivesDisabled() then return 0 end

	-- find enemies
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.max_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		-- get distance percentage damage
		local distance = (enemy:GetOrigin()-self.parent:GetOrigin()):Length2D()
		local pct = (self.max_radius-distance)/self.delta
		pct = math.min( pct, 1 )

		-- apply damage
		self.damageTable.victim = enemy
		self.damageTable.damage = params.damage * pct * self.reflect/100
		self.damageTable.damage_type = params.damage_type
		ApplyDamage( self.damageTable )

		-- play effects
		self:PlayEffects( enemy )
	end

	return -self.reflect
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_physic_laws_dispersion:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_spectre/spectre_dispersion.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self.parent,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	-- ParticleManager:SetParticleControl( effect_cast, 1, vControlVector )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end