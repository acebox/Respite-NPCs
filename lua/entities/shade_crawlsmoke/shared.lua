if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

list.Set( "NPC", "shade_crawlsmoke", {
	Name = "Crawler - Smoke",
	Class = "shade_crawlsmoke",
	Category = "Respite - Shade"
} )

ENT.classname = "shade_crawlsmoke"
ENT.NiceName = "Crawler"
ENT.Base = "chance_base";

ENT.Spawnable        = true
ENT.AdminSpawnable   = true
ENT.CollisionHeight = 60
ENT.CollisionSide = 15
ENT.Model = "models/angelsaur/ghost_girl.mdl"
ENT.MoveType = 3
ENT.WalkSpeedAnimation = 1.0
ENT.AttackRange = 140
ENT.InitialAttackRange = 90

ENT.UseFootSteps = 2
ENT.FootStepTime = 1

ENT.health = 10
ENT.Speed = 15
ENT.Damage = 15
ENT.Persistent = true

ENT.NextAttack = 0

ENT.AttackAnim = "crawl"
ENT.IdleAnim = "idle01"
ENT.WalkAnim = "crawl"

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
		self:SetBloodColor(DONT_BLEED)
		self:Precache()
		self:SetModel(self.Model)
		self:SetHealth(self.health)	
		-- self:SetBodygroup( 1, 1 )
		self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
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

function ENT:IdleFunction()
	self:Idle()
	self:TeleportShortThink(3.5)
end

function ENT:CustomDeath( dmginfo )
	self:TransformRagdoll( dmginfo )
end

function ENT:FootSteps()
	self:EmitSound("horror/foot"..math.random(1, 4)..".wav", 70) 
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
	--util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
end

function ENT:CustomChaseEnemy()
	self:TeleportShortThink(10)
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
			--self:EmitSound("npc/infected_zombies/claw_miss_"..math.random(2)..".wav", math.random(75,95), math.random(65,95))
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

