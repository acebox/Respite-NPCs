if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_thrower", {
	Name = "Thrower",
	Class = "nz_thrower",
	Category = "Respite"
} )

--Stats--
ENT.FootAngles = 10
ENT.FootAngles2 = 10

ENT.MoveType = 1

ENT.CollisionHeight = 64
ENT.CollisionSide = 7

ENT.ModelScale = 1.2

ENT.Speed = 75
ENT.WalkSpeedAnimation = 1.5
ENT.FlinchSpeed = 10

ENT.health = 150
ENT.Damage = 45
ENT.HitPerDoor = 1

ENT.PhysForce = 30000
ENT.AttackRange = 65
ENT.InitialAttackRange = 75
ENT.DoorAttackRange = 25

ENT.NextAttack = 1.5

ENT.AttackFinishTime = 0.9

ENT.Launches = true

ENT.pitch = 30
ENT.pitchVar = 10

ENT.wanderType = 4

--Model Settings--
ENT.Model = "models/player/zombie_fast.mdl"

ENT.WalkAnim = ACT_HL2MP_WALK_ZOMBIE_01
ENT.AttackAnim = ACT_GMOD_GESTURE_RANGE_ZOMBIE 

ENT.IdleAnim = ACT_HL2MP_IDLE_ZOMBIE 

--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"npc/zombie_poison/pz_warn1.wav",
	"npc/zombie_poison/pz_warn2.wav"
}

ENT.alertSounds = {
	"npc/zombie_poison/pz_alert1.wav",
	"npc/zombie_poison/pz_alert2.wav"
}

ENT.deathSounds = {
	"npc/zombie_poison/pz_die2.wav",
	"npc/zombie_poison/pz_die2.wav",
	"npc/zombie_poison/pz_die2.wav"
}

ENT.idleSounds = {
	"npc/zombie/zombie_voice_idle1.wav",
	"npc/zombie/zombie_voice_idle2.wav",
	"npc/zombie/zombie_voice_idle3.wav",
	"npc/zombie/zombie_voice_idle4.wav",
	"npc/zombie/zombie_voice_idle5.wav",
	"npc/zombie/zombie_voice_idle6.wav",
	"npc/zombie/zombie_voice_idle7.wav",
	"npc/zombie/zombie_voice_idle8.wav",
	"npc/zombie/zombie_voice_idle9.wav"
}

ENT.painSounds = {
	"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain5.wav",
	"npc/zombie/zombie_pain6.wav"
}

ENT.hitSounds = {
	"npc/junk_zombie/hit3.wav"
}

ENT.missSounds = {
	"npc/zombie/claw_miss1.wav"
}

function ENT:Initialize()
	if SERVER then
	
	self:Precache()
	--Stats--
	self:SetModel(self.Model)
	self:SetHealth(self.health)	
	self:SetModelScale( self.ModelScale, 0 )
	self:SetMaterial("models/flesh")	
	self:SetColor(Color(155, 255, 155, 255)) -- greenish color

	self.IsAttacking = false

	self.Throwing = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(600)
	self.loco:SetDeceleration(600)
	
	--Misc--

	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	end
end

function ENT:CustomDeath( dmginfo )
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
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

	if (math.random(0,2) == 2) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end		
	
	self:TransformRagdoll( dmginfo )
end

function ENT:ThrowGrenade( velocity )

	local ent = ents.Create("flesh_ball")
	
	if ent:IsValid() and self:IsValid() then
		ent:SetPos(self:EyePos() + Vector(0,0,30) - ( self:GetRight() * 25 ) + ( self:GetForward() * 10 ) )
		ent:Spawn()
		ent:SetOwner( self )
				
		local phys = ent:GetPhysicsObject()
		
		if phys:IsValid() then
		
			local ang = self:EyeAngles()
			ang:RotateAroundAxis(ang:Forward(), math.Rand(-10, 10))
			ang:RotateAroundAxis(ang:Up(), math.Rand(-10, 10))
			phys:SetVelocityInstantaneous(ang:Forward() * math.Rand( velocity, velocity + 200 ))
				
		end
	end
	
end

function ENT:CustomChaseEnemy()

	local enemy = self:GetEnemy()

	if(!enemy) then return end
	if self.Attacking then return end
	
	if self:GetRangeTo( enemy ) > self.InitialAttackRange and self:GetRangeTo( enemy ) < 500 then
		
		if ( self.NextThrow or 0 ) < CurTime() then
	
			self:RestartGesture( ACT_GMOD_GESTURE_ITEM_THROW )
			self.Throwing = true
	
			timer.Simple( 0.6, function()
				if !self:IsValid() then return end
				if self:Health() < 0 then return end
				if self.Attacking then return end
				self:ThrowGrenade( math.random(500, 600) )
				self.Throwing = false
			end)
			
			self.NextThrow = CurTime() + 2	
		end
	end	
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
	
	if ( dmginfo:IsBulletDamage() ) then
        // hack: get hitgroup
		local trace = {}
		trace.start = attacker:GetShootPos()
			
		trace.endpos = trace.start + ( ( dmginfo:GetDamagePosition() - trace.start ) * 2 )  
		trace.mask = MASK_SHOT
		trace.filter = attacker
			
		local tr = util.TraceLine( trace )
		hitgroup = tr.HitGroup

		self:EjectBlood( dmginfo, 1, math.random(3,5) )	
	end
end

function ENT:EjectBlood( dmginfo, amount, reduction )
	
	if ( self.NextEject or 0 ) < CurTime() then
	
		self:SetHealth( self:Health() + reduction )
		self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 72, math.Rand(85, 95))	
			
		for i=1,amount do
			local flesh = ents.Create("nz_projectile_blood") 
				if flesh:IsValid() then
					flesh:SetPos( self:GetPos() + Vector(0,0,30) )
					flesh:SetOwner(self)
					flesh:Spawn()
	
					local phys = flesh:GetPhysicsObject()
					if phys:IsValid() then
						local ang = self:EyeAngles()
						ang:RotateAroundAxis(ang:Forward(), math.Rand(-205, 205))
						ang:RotateAroundAxis(ang:Up(), math.Rand(-205, 205))
						phys:SetVelocityInstantaneous(ang:Forward() * math.Rand( 260, 360 ))
					end
				end
					
			end
		
		self.NextEject = CurTime() + 1	
	end		
end

function ENT:FootSteps()
	self:EmitSound("npc/zombie_poison/pz_right_foot1.wav", 65)
end

function ENT:Attack()
	if ( self.NextAttackTimer or 0 ) < CurTime() then	
		if ( (self.Enemy:IsValid() and self.Enemy:Health() > 0 ) ) then
		
			self:AttackSound()
			self.IsAttacking = true
			self:RestartGesture(self.AttackAnim)
		
			self:AttackEffect( 0.9, self.Enemy, self.Damage, 0 )
		
		end
		
		self.NextAttackTimer = CurTime() + self.NextAttack
	end	
end