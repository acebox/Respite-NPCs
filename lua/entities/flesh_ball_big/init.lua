AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.LifeTime = 2
ENT.Damage = 20

function ENT:Initialize()
	self:SetModel("models/gibs/humans/mgib_01.mdl")
	self:SetColor(Color(155, 255, 155, 255))
	self:SetMaterial("models/flesh")
	self:SetModelScale(3, 0)
	self:PhysicsInitSphere(27)
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
			for i=1,4 do
			flesh = ents.Create("flesh_ball") 
				if flesh:IsValid() then
				flesh:SetPos(self:EyePos())
				flesh:SetOwner(self)
				flesh:Spawn()
			
				local phys = flesh:GetPhysicsObject()
					if phys:IsValid() then
						local ang = self:EyeAngles()
						ang:RotateAroundAxis(ang:Forward(), math.Rand(-100, 100))
						ang:RotateAroundAxis(ang:Up(), math.Rand(-100, 100))
						phys:SetVelocityInstantaneous(ang:Forward() * math.Rand(225, 390))
					end
				end
			end	
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
    util.Decal("bloodpool1", self:GetPos(), self:GetPos() - Vector(50,50,50))			
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
