AddCSLuaFile();

list.Set( "NPC", "resp_vomit", {
	Name = "Vomit",
	Class = "resp_vomit",
	Category = "Respite"
} )

ENT.classname = "resp_vomit"
ENT.Base = "chance_base";
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

ENT.UseFootSteps = 2
ENT.FootStepTime = 0.4

ENT.CollisionSide = 20
ENT.CollisionHeight = 80
ENT.Model = "models/zombie/zombie_vomit.mdl"
ENT.MoveType = 1
ENT.WalkSpeedAnimation = 1.0

ENT.Speed = 90
ENT.health = 110
ENT.Damage = 2

ENT.AttackRange = 300

ENT.AttackAnim = ACT_MELEE_ATTACK1
ENT.WalkAnim = ACT_WALK
ENT.IdleAnim = "Idle01"

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = { 
	"deadzone/lepotitsa/death4.wav",
	"deadzone/lepotitsa/death3.wav"
}

ENT.idleSounds = {
	"deadzone/lepotitsa/alert2.wav",
	"deadzone/lepotitsa/pain2.wav"
}

ENT.missSounds = {
	"npc/zombie/claw_miss1.wav"
}

ENT.alertSounds = ENT.idleSounds
ENT.deathSounds = ENT.idleSounds
ENT.painSounds = ENT.idleSounds

function ENT:Initialize()

	if( SERVER ) then 
		self:Precache()
		self.loco:SetStepHeight(30)
		self.loco:SetAcceleration(400)
		self.loco:SetDeceleration(400)
		self.loco:SetJumpHeight( 30 )
	end
	
	self:SetHealth(self.health)	
	self:SetModel(self.Model)
	
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	
	self:PhysicsInitShadow(true, true)
end

function ENT:CustomDeath( dmginfo )
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	if (math.random(0,2) == 2) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end
	
	self:TransformRagdoll( )
end


function ENT:FootSteps()
	self:EmitSound("babu/foot"..math.random(1, 4)..".wav", 55)
end

function ENT:RangedAttack()

    self:RestartGesture( self.AttackAnim )
	self.loco:SetDesiredSpeed( self.Speed - 30 )
	
	timer.Simple( 0.3, function()
		if !self:IsValid() then return end
		if self:Health() < 0 then return end
		if !self:CheckStatus() then return end
		
		self.loco:SetDesiredSpeed( self.Speed )
		self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 72, math.Rand(85, 95))	
		for i = 1, math.random(3,5) do
			local flesh = ents.Create("nz_projectile_necrotic") 
			if flesh:IsValid() then
				flesh:SetPos( self:GetPos() + Vector(0,5,50) )
				flesh:SetOwner(self)
				flesh:Spawn()		
			
				local phys = flesh:GetPhysicsObject()
				if phys:IsValid() then
				local ang = self:EyeAngles()
				ang:RotateAroundAxis(ang:Forward(), math.Rand(-10, 10))
				ang:RotateAroundAxis(ang:Up(), math.Rand(-10, 10))
				phys:SetVelocityInstantaneous(ang:Forward() * math.Rand(790, 1000))
				end
			end
		end
	end)
end

function ENT:CustomChaseEnemy()

	local enemy = self:GetEnemy()

	if(!enemy) then return end
	if self.Attacking then return end
	
	if self:GetRangeTo( enemy ) < self.AttackRange then
		
		if ( self.NextThrow or 0 ) < CurTime() then
			self.Throwing = true
			self:RangedAttack()
	
			timer.Simple( 0.3, function()
				if !self:IsValid() then return end
				if self:Health() < 0 then return end
				if self.Attacking then return end
				self.Throwing = false
			end)
			
			self.NextThrow = CurTime() + 1.5
		end
	end	
end

function ENT:HitSound()

end