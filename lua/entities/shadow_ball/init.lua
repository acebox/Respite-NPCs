AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.LifeTime = 3
ENT.Damage = 10

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	local meats = {}
	meats[1] = ("models/dismemberment/gibs/torso/torso_left_lower.mdl")
	meats[2] = ("models/dismemberment/gibs/torso/torso_left_upper.mdl")
	meats[3] = ("models/Gibs/HGIBS.mdl")
	meats[4] = ("models/Gibs/HGIBS.mdl")
	self:SetModel(meats[math.random(1,4)])
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(0,0,0))
	--self:SetMaterial("models/effects/portalrift_sheet")
	self:SetRenderFX(kRenderFxDistort)
	self:SetModelScale(1, 0)
	self:PhysicsInitSphere(7)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(1)
		phys:SetBuoyancyRatio(0.001)
		phys:EnableMotion(true)
		phys:Wake()
	end

	self.DeathTime = CurTime() + 30
	self.ExplodeTime = CurTime() + self.LifeTime
end

function ENT:Think()
	if self.ExplodeTime <= CurTime() then
	self:Explode()
	end

	if self.DeathTime <= CurTime() then
	self:Remove()
	end

	self:NextThink(CurTime())
	return true
end

function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0
end

function ENT:PhysicsCollide(data, physobj)
	if SERVER then
	local sounds = {}
			sounds[1] = ("physics/flesh/flesh_squishy_impact_hard1.wav")
			sounds[2] = ("physics/flesh/flesh_squishy_impact_hard2.wav")
			sounds[3] = ("physics/flesh/flesh_squishy_impact_hard3.wav")
			sounds[4] = ("physics/flesh/flesh_squishy_impact_hard4.wav")
			self:EmitSound( sounds[math.random(1,4)] )
    util.Decal("scorch", self:GetPos(), self:GetPos() - Vector(50,50,50))			
	local ent = data.HitEntity
	if ent and ent:IsValid() and ent:IsPlayer() then
	
		local damage = DamageInfo()
		damage:SetDamageType(DMG_ACID)
		ent:TakeDamageInfo(damage, self)
		ent:TakeDamage(self.Damage, self)
		
		local painsounds = {}
			painsounds[1] = ("player/pl_pain7.wav")
			painsounds[2] = ("player/pl_pain6.wav")
			painsounds[3] = ("player/pl_pain5.wav")
			ent:EmitSound( painsounds[math.random(1,3)] )
		
		self:EmitSound("physics/flesh/flesh_bloody_break.wav")
		
		local moveAdd=Vector(0,0,150)
		if not ent:IsOnGround() then
		moveAdd=Vector(0,0,0)
		end
		ent:SetVelocity(moveAdd+((ent:GetPos()-self:GetPos()):GetNormal()*100)) -- apply the velocity
		
		self.ExplodeTime = 0
		self:NextThink(CurTime())
	else
		local normal = data.OurOldVelocity:GetNormalized()
		local DotProduct = data.HitNormal:Dot(normal * -1)

		physobj:SetVelocityInstantaneous((2 * DotProduct * data.HitNormal + normal) * math.max(100, data.Speed) * 0.9)
	end
	
	if ent and ent:IsValid() and ent:GetClass() == "prop_physics" then
	
	ent:TakeDamage(25, self)
	self:EmitSound("physics/flesh/flesh_bloody_break.wav")
	
	local phys = ent:GetPhysicsObject()
		if (phys != nil && phys != NULL && phys:IsValid()) then
		phys:ApplyForceCenter(ent:GetForward():GetNormalized()*15000 + Vector(0, 0, 2))
		end
		
	end
	
	end
end
