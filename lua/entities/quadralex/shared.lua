if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "quadralex", {
	Name = "Quadralex",
	Class = "quadralex",
	Category = "Respite"
} )

--Stats--
ENT.MoveType = 2
ENT.UseFootSteps = 1

ENT.FootAngles = 25
ENT.FootAngles2 = 25

ENT.Bone1 = "Quadralex_rfoot"
ENT.Bone2 = "Quadralex_lfoot"

ENT.CollisionHeight = 70
ENT.CollisionSide = 60

ENT.ModelScale = 1.0

ENT.Speed = 80

ENT.WalkSpeedAnimation = 1
ENT.FlinchSpeed = 30

ENT.health = 2000
ENT.Damage = 20

ENT.PhysForce = 100000
ENT.AttackRange = 170
ENT.InitialAttackRange = 160

ENT.DoorAttackRange = 100
ENT.HitPerDoor = 10

ENT.AttackFinishTime = 0.8

ENT.NextAttack = 1

ENT.volume = 150

ENT.Launches = true
ENT.Entrace = true

ENT.nextSpecial = 0

--Model Settings--
ENT.Model = "models/sin/quadralex.mdl"

ENT.AttackAnim = "shove"

ENT.WalkAnim = "walk1"

ENT.IdleAnim = "alertidle"

ENT.FlinchAnim = "charge_cancel"

--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"npc/quadralex/quad_slash1.wav",
	"npc/quadralex/quad_slash2.wav",
	"npc/quadralex/quad_slash3.wav"
}

ENT.throwSounds = {
	"npc/quadralex/quad_shockwave1.wav",
	"npc/quadralex/quad_shockwave2.wav"
}

ENT.alertSounds = {
	"npc/quadralex/quad_roar1.wav",
	"npc/quadralex/quad_roar2.wav",
	"npc/quadralex/quad_roar3.wav"
}

ENT.deathSounds = {
	"npc/quadralex/quad_death1.wav",
	"npc/quadralex/quad_death2.wav"
}

ENT.idleSounds = {
	--"npc/quadralex/quad_idle.wav"
}

ENT.painSounds = {
	"npc/quadralex/quad_duaghit1a.wav",
	"npc/quadralex/quad_duaghit1b.wav",
	"npc/quadralex/quad_duaghit1c.wav",
	"npc/quadralex/quad_duaghit1d.wav",
	"npc/quadralex/quad_duaghit2a.wav",
	"npc/quadralex/quad_duaghit2b.wav",
	"npc/quadralex/quad_duaghit2c.wav"
}

ENT.hitSounds = {
	"npc/zombie/claw_strike1.wav"
}

ENT.missSounds = {
	"npc/zombie/claw_miss1.wav"
}

function ENT:Initialize()

	self.breathing = CreateSound(self, "npc/quadralex/quad_run.wav")
	self.breathing:Play()
	--self.breathing:ChangePitch(60, 0)
	--self.breathing:ChangeVolume(0.6, 0)
	self:SetModel(self.Model)

	if SERVER then
	
	self:SetHealth(self.health)	
	self:SetModelScale( self.ModelScale, 0 )
	
	self.IsAttacking = false
	self.Flinching = false
	self.Entrance = true
	
	self:PhysicsInitShadow(true, true)
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(900)
	self.loco:SetDeceleration(900)
	
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	end
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
	
	if(dmginfo:GetDamage() > 70 and !self.Entrance) then
		self:Flinch()
	end
end

--idle loops, we handle that elsewhere.
function ENT:IdleSound()
end

function ENT:FootSteps()
	self:EmitSound("npc/quadralex/quad_step_heavy.wav", 100, math.random(80,90) )
end

function ENT:OnRemove()
	if (self.breathing) then
		self.breathing:Stop()
		self.breathing = nil
	end
end

function ENT:CustomDeath( dmginfo )
	nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))

	self:TransformRagdoll(dmginfo)
end

function ENT:Flinch()
	if ( self.NextFlinch or 0 ) < CurTime() then
		if !self:CheckValid( self ) then return end
		if !self:CheckStatus( 1 ) then return end
		self.Cancelled = true
		
		self:PlayFlinchSequence( self.FlinchAnim, 1, 0, 0, 1 )
		self.NextFlinch = CurTime() + 5
	end	
end

function ENT:PlayFlinchSequence( string, rate, cycle, speed, time )
	self.Flinching = true

	self:ResetSequence( string )
	self:SetCycle( cycle )
	self:SetPlaybackRate( rate )
	self.loco:SetDesiredSpeed( speed )
	
	timer.Simple(time, function() 
		if !self:IsValid() then return end
		if self:Health() < 0 then return end
		self:ResumeMovementFunctions()
		self.Flinching = false
	end)
end

function ENT:CheckStatus()
	
	if self.Throwing then 
		return false 
	end
	
	if self.Raging then 
		return false 
	end
	
	if self.Flinching then
		return false
	end
	
	return true
end

function ENT:ThrowSound()
	local sound = self.throwSounds[ math.random( #self.throwSounds ) ]
	if(!sound) then return end
	
	self:EmitSound(sound, self.volume, math.random(self.pitch-self.pitchVar, self.pitch+self.pitchVar))
end

function ENT:AttackEffect( time, ent, dmg, type, reset )
	timer.Simple(time, function() 
		if !self:IsValid() then return end
		if self:Health() < 0 then return end
		if !self:CheckValid( ent ) then return end
		if !self:CheckStatus() then return end
		
		if self:GetRangeTo( ent ) < self.AttackRange then
			
			ent:TakeDamage(dmg, self)	
			
			if ent:IsPlayer() or ent:IsNPC() then
				if(self.Launches) then
					local moveAdd=Vector(0,0,350)
						if not ent:IsOnGround() then
							moveAdd=Vector(0,0,0)
						end
					ent:SetVelocity( moveAdd + ( ( self.Enemy:GetPos() - self:GetPos() ):GetNormal() * 150 ) )
				end

				self:Slow(1, ent)
				self:HitSound()
			end
			
			if ent:IsPlayer() then
				ent:ViewPunch(Angle(math.random(-1, 1)*self.Damage, math.random(-1, 1)*self.Damage, math.random(-1, 1)*self.Damage))
			end
			
			if type == 1 then
				local phys = ent:GetPhysicsObject()
				if (phys != nil && phys != NULL && phys:IsValid() ) then
					phys:ApplyForceCenter(self:GetForward():GetNormalized()*(self.PhysForce) + Vector(0, 0, 2))
					ent:EmitSound(self.DoorBreak)
				end
			elseif type == 2 then
				if ent != NULL and ent.Hitsleft != nil then
					if ent.Hitsleft > 0 then
						ent.Hitsleft = ent.Hitsleft - self.HitPerDoor	
						ent:EmitSound(self.DoorBreak)
					end
				end
			end
							
		else	
			self:MissSound()
		end
		
	end)

	if reset == 1 then
		timer.Simple( time + 0.6, function()
			if !self:IsValid() then return end
			if self:Health() < 0 then return end
			if !self:CheckValid( ent ) then return end
			if !self:CheckStatus() then return end
			
			self.IsAttacking = false
			self:ResumeMovementFunctions()
		end)
	end
end

function ENT:Slow( time, ent )

	if !ent.Slowed then
		local walk = ent:GetWalkSpeed()
		local run = ent:GetRunSpeed()
		ent.Slowed = true
			
		ent:SetWalkSpeed( 15 )
		ent:SetRunSpeed( 15 )		
					
		timer.Simple( time, function()
			ent.Slowed = false
			
			if !ent:IsValid() then return end
			if ent:Health() < 0 then return end
			
			ent:SetWalkSpeed( walk )
			ent:SetRunSpeed( run )
		end)
	end
end

function ENT:Slam()
	self.NextFlinch = CurTime() + 5 --no flinching
	self.IsAttacking = true
	self:ThrowSound()

	self:ResetSequence( "shockwave_attack" )
	self:SetCycle( 0 )
	
	timer.Simple(3.25, function()
		if(self:IsValid()) then
			local search = ents.FindInSphere(self:GetPos(), 1000)

			for k, v in pairs(search) do
				if(v:IsPlayer()) then
					local moveAdd=Vector(0,0,600)
						if not v:IsOnGround() then
							moveAdd=Vector(0,0,0)
						else --only deal damage if they're on the ground.
							v:TakeDamage(10, self)	
						end
					v:SetVelocity( moveAdd + ( ( v:GetPos() - self:GetPos() ):GetNormal() * 600 ) )
					v:ViewPunch( Angle(math.random(160,180), math.random(160,180), math.random(160,180) ) )
					self:Slow(3, v)
				end
			end
			
			util.ScreenShake(self:GetPos(), 100, 5, 1, 2000)
			
			local bleed = ents.Create("info_particle_system")
			bleed:SetKeyValue("effect_name", "building_explosion")
			bleed:SetParent(self)
			bleed:SetPos( self:GetPos() )
			bleed:Spawn()
			bleed:Activate()
			bleed:Fire("Start", "", 0)
			bleed:Fire("Kill", "", 10)
			
			self.IsAttacking = false
		end
	end)
	
	self:SetPlaybackRate( 1 )
	self.loco:SetDesiredSpeed( 0 )
end

function ENT:Yell()
	self.loco:FaceTowards(self.Enemy:GetPos())
	self.loco:SetDesiredSpeed( 0 )
	self:AlertSound()
	self:PlaySequenceAndWait( "roar", 1)
	
	self.Entrance = false
	self.loco:SetDesiredSpeed( self.Speed )
	self:ResumeMovementFunctions()
end

function ENT:Enrage()
	self.WalkAnim = "running"
	self.Speed = 400
	self.wanderType = 1
end

function ENT:OnAlert()
	self:Enrage()
end

function ENT:RunBehaviour()
	self:SpawnIn()

	while ( true ) do
		if(!self.Entrance) then
			local enemy = self:HaveEnemy()
			
			if (enemy and enemy:IsValid() and enemy:Health() > 0) then
				self.Hiding = false
				
				pos = enemy:GetPos()

				if self:CheckStatus() then
					self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
				end

				local opts = {	lookahead = 0,
					tolerance = 5,
					draw = false,
					maxage = 20,
					repath = 0.3	}
						
				self:ChaseEnemy( pos, opts )
			else
				self.Enemy = nil
				
				self:IdleFunction()
			end
		else
			if(self:HaveEnemy()) then
				self:Yell()
			end
			self:IdleFunction()
		end
		coroutine.yield()
	end
end

function ENT:CustomChaseEnemy()
	local enemy = self.Enemy
	if(enemy) then
		local pos = enemy:GetPos()
		if(self:GetPos():DistToSqr(enemy:GetPos()) < 1000 * 1000) then
			if(self.nextSpecial < CurTime()) then
				self:Slam()
				self.nextSpecial = CurTime() + 25
			end
		end
	end
end