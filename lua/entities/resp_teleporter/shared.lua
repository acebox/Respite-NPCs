if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

list.Set( "NPC", "resp_teleporter", {
	Name = "Teleporting Shade",
	Class = "resp_teleporter",
	Category = "Respite - Shade"
} )

ENT.classname = "resp_teleporter"
ENT.NiceName = "Teleporting Shade"
ENT.Base = "chance_base";

ENT.Spawnable        = true
ENT.AdminSpawnable   = true

ENT.CollisionHeight = 60
ENT.CollisionSide = 15
ENT.Model = "models/predatorcz/amnesia/grunt.mdl"
ENT.MoveType = 2
ENT.WalkSpeedAnimation = 1.25
ENT.AttackRange = 140
ENT.InitialAttackRange = 90

ENT.UseFootSteps = 2
ENT.FootStepTime = 0.8

ENT.health = 250
ENT.Speed = 80
ENT.Damage = 10
ENT.Persistent = true

ENT.NextAttack = 0

ENT.AttackFinishTime = 0.9

ENT.AttackAnim = ACT_MELEE_ATTACK1
ENT.IdleAnim = "idle1"
ENT.WalkAnim = "walk"

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.deathSounds = {
	"chorror/bass_walls.wav"
}

ENT.idleSounds = {
	"horror/idle1.wav",
	"horror/idle2.wav",
	"horror/idle3.wav"
}

ENT.attackSounds = { 
	"chorror/psstright.wav",
	"chorror/psstleft.wav",
	"chorror/emily_reversed1.wav"
} 
		
ENT.painSOunds = {
	"chorror/stinger2.wav"
}

ENT.teleportSounds = {
	"chorror/screech.wav",
	"chorror/stinger2.wav",
	"chorror/metal3.wav"
}

function ENT:Initialize()

	ParticleEffectAttach("Advisor_Pod_Explosion_Smoke", 1, self, 1)

	if SERVER then
		self:SetMaterial("models/angelsaur/ghosts/shadow")
		self:SetBloodColor(DONT_BLEED)
		self:Precache()
		self:SetModel(self.Model)
		self:SetHealth(self.health)	
		-- self:SetBodygroup( 1, 1 )
		self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_DEBRIS )
		self:PhysicsInitShadow(true, true)
		self.loco:SetStepHeight( 45 )
		self.loco:SetJumpHeight( 55 )
		self.loco:SetAcceleration( 500 )
		self.loco:SetDeceleration( 300 )
	end
end

function ENT:TransformRagdoll( dmginfo )
	if !self:IsValid() then return end
	
	local ragdoll = ents.Create("prop_ragdoll")
		if ragdoll:IsValid() then 
			ragdoll:SetPos(self:GetPos())
			ragdoll:SetModel(self:GetModel())
			ragdoll:SetAngles(self:GetAngles())
			ragdoll:Spawn()
			ragdoll:SetSkin(self:GetSkin())
			ragdoll:SetColor(self:GetColor())
			ragdoll:SetMaterial(self:GetMaterial())
			
			local num = ragdoll:GetPhysicsObjectCount()-1
			local v = self.loco:GetVelocity()	
   
			for i=0, num do
				local bone = ragdoll:GetPhysicsObjectNum(i)

				if IsValid(bone) then
					local bp, ba = self:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
					if bp and ba then
						bone:SetPos(bp)
						bone:SetAngles(ba)
					end
					bone:SetVelocity(v)
				end
	  
			end
			
			ragdoll:SetBodygroup( 1, self:GetBodygroup(1) )
			ragdoll:SetBodygroup( 2, self:GetBodygroup(2) )
			ragdoll:SetBodygroup( 3, self:GetBodygroup(3) )
			ragdoll:SetBodygroup( 4, self:GetBodygroup(4) )
			ragdoll:SetBodygroup( 5, self:GetBodygroup(5) )
			ragdoll:SetBodygroup( 6, self:GetBodygroup(6) )
			
			ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			
			ragdoll:Fire("FadeAndRemove", 1)
		end
	SafeRemoveEntity( self )
end

function ENT:CustomDeath( dmginfo )
	self:TransformRagdoll( dmginfo )
end

function ENT:FootSteps()
	self:EmitSound("monsters/suitor/metal_walk0"..math.random(1, 3)..".mp3", 75) 
end

function ENT:TeleportShortThink(waitTime)
	
	if( !self.NextTeleport ) then self.NextTeleport = CurTime(); end
	
	if( CurTime() >= self.NextTeleport ) then
		local sound = self.teleportSounds[ math.random( #self.teleportSounds ) ]
		self:EmitSound( sound, 100, math.random(40,50), 1, CHAN_AUTO )
		
		self:TeleportShort()
		self.NextTeleport = CurTime() + waitTime;
	end
end

function ENT:TeleportShort()
	local location = self:GetPos() + Vector( math.random(-500, 500), math.random(-500, 500), 0 )
	if(!util.IsInWorld(location)) then
		location = self:GetPos() + Vector( math.random(-500, 500), math.random(-500, 500), 0 )
	end
	self:SetPos(location)
	util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	self:ResumeMovementFunctions()
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
	self:TeleportShort()
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
				-- self:BleedVisual2( 0.3, ent:GetPos() + Vector(0,0,50) )	
				if(self.Launches) then
					local moveAdd=Vector(0,0,350)
						if not ent:IsOnGround() then
							moveAdd=Vector(0,0,0)
						end
					ent:SetVelocity( moveAdd + ( ( self.Enemy:GetPos() - self:GetPos() ):GetNormal() * 150 ) )
				end

				self:HitSound()
			end
			
			if ent:IsPlayer() then
				ent:ViewPunch(Angle(math.random(-1, 1)*self.Damage, math.random(-1, 1)*self.Damage, math.random(-1, 1)*self.Damage))
				
				self:TeleportShort()
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
		timer.Simple( time + 0, function()
			if !self:IsValid() then return end
			if self:Health() < 0 then return end
			if !self:CheckValid( ent ) then return end
			if !self:CheckStatus() then return end
			
			self.IsAttacking = false
			self:ResumeMovementFunctions()
		end)
	end
end
