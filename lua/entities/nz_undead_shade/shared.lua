if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_undead_shade", {
	Name = "Shambling Shade",
	Class = "nz_undead_shade",
	Category = "Respite - Shade"
} )

--Stats--
ENT.MoveType = 2

ENT.FootAngles = 5

ENT.CollisionHeight = 66
ENT.CollisionSide = 11

ENT.Speed = 30
ENT.WalkSpeedAnimation = 1
ENT.FlinchSpeed = 0

ENT.health = 100
ENT.Damage = 10

ENT.PhysForce = 15000
ENT.AttackRange = 40
ENT.InitialAttackRange = 55
ENT.DoorAttackRange = 25

ENT.NextAttack = 2

ENT.pitch = 60
ENT.pitchVar = 10


--Model Settings--
ENT.Model = "models/freshdead/freshdead_01.mdl"

ENT.models = {
	"models/freshdead/freshdead_01.mdl",
	"models/freshdead/freshdead_02.mdl",
	"models/freshdead/freshdead_03.mdl",
	"models/freshdead/freshdead_04.mdl",
	"models/freshdead/freshdead_05.mdl",
	"models/freshdead/freshdead_06.mdl",
	"models/freshdead/freshdead_07.mdl"
}

ENT.GrabAnim = "enter_choke"
ENT.GrabFailAnim = "choke_miss"
ENT.HoldAnim = "choke_eat"

ENT.AttackAnim1 = "attacka"
ENT.AttackAnim2 = "attackb"
ENT.AttackAnim3 = "attackc"

ENT.HeadFlinch = "flinch_head"

ENT.RLegFlinch = "flinch_rightleg"
ENT.RArmFlinch = "flinch_rightarm"

ENT.LLegFlinch = "flinch_leftleg"
ENT.LArmFlinch = "flinch_leftarm"

--Sounds--
ENT.DoorBreak = Sound("ambient/wind/wind_hit1.wav")

ENT.alertSounds = {
	"ambient/wind/wind1.wav"
}

ENT.attackSounds = {
	"ambient/wind/wind_hit1.wav",
	"ambient/wind/wind_hit2.wav",
	"ambient/wind/wind_hit3.wav"
}

ENT.idleSounds = {
	"ambient/wind/wind_hit1.wav",
	"ambient/wind/wind_hit2.wav",
	"ambient/wind/wind_hit3.wav"
}

ENT.deathSounds = {
	"ambient/wind/wasteland_wind.wav"
}

ENT.painSounds = {
	"ambient/wind/wasteland_wind.wav"
}

ENT.hitSounds = {
	"ambient/wind/wind_hit1.wav",
	"ambient/wind/wind_hit2.wav",
	"ambient/wind/wind_hit3.wav"
}

ENT.missSounds = {
	"ambient/wind/wind_moan1.wav",
	"ambient/wind/wind_moan2.wav"
}

function ENT:Animations()

	self.WalkAnims = { "walk1", "walk2", "walk3", "walk4", "walk5", "walk6", "walk7", "walk8", "walk9", "walk10" }
	self.IdleAnimations =  { "idle01", "idle02", "idle03", "idle04" }
	
	self.WalkAnim = ( table.Random( self.WalkAnims ) )
	self.IdleAnim = ( table.Random( self.IdleAnimations ) )
	
	if self.WalkAnim == "walk8" then
	
		self.Speed = self.Speed - 10
		
	end

end

function ENT:Initialize()

	if SERVER then

	--Stats--
	self:SetBloodColor(DONT_BLEED)
	self:SetHealth(self.health)	
	
	local models = {
		self.Model,
		self.Model2,
		self.Model3,
		self.Model4,
		self.Model5,
		self.Model6,
		self.Model7,
	}
	
	self:SetModel( table.Random(models) )
	self:SetMaterial("models/angelsaur/ghosts/shadow")
	
	--self:SetColor(Color(0,0,0,255))
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderFX(kRenderFxStrobeSlow)	

	self.IsAttacking = false
	self.Flinching = false
	self.IsGrabbing = false
	self.Stumbling = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(200)
	self.loco:SetDeceleration(900)
	
	self:Animations()
	self.wanderType = math.random(2,3)
	
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	end
end

function ENT:CheckStatus()
	
	if self.Flinching then
		return false
	end
	
	if self.IsGrabbing then
		return false
	end
	
	return true
	
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,20) == 20) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end		
	util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	SafeRemoveEntity(self)
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
    // hack: get hitgroup
	local trace = {}
	trace.start = attacker:GetShootPos()
		
	trace.endpos = trace.start + ( ( dmginfo:GetDamagePosition() - trace.start ) * 2 )  
	trace.mask = MASK_SHOT
	trace.filter = attacker
		
	local tr = util.TraceLine( trace )
	hitgroup = tr.HitGroup
	
	if hitgroup == HITGROUP_HEAD then
		dmginfo:ScaleDamage(5)
	else
		dmginfo:ScaleDamage(0.70)
	end
		
	self:Flinch( dmginfo, hitgroup )
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
		self.loco:SetAcceleration(200)
		self:ResumeMovementFunctions()
		self.Flinching = false
		self.Stumbling = false
	end)
end

function ENT:CustomChaseEnemy()
	if self.Stumbling then
		self:BackUp( self.StumbleType )
	end
end
	
function ENT:BackUp( type )
	local enemy = self:GetEnemy()
	while( self.Stumbling ) do
		
		if type == 1 then
			local back = self:GetPos() + self:GetAngles():Forward() * -778
			self.loco:Approach(back, 100)
		elseif type == 2 then
			local back = self:GetPos() + self:GetAngles():Forward() * 778
			self.loco:Approach(back, 100)	
		end
			
		coroutine.wait(0.05)
	end
	coroutine.yield()
end	

function ENT:Flinch( dmginfo, hitgroup )
	
	if ( self.NextFlinch or 0 ) < CurTime() then
	
		if !self:CheckValid( self ) then return end
		if !self:CheckStatus() then return end
	
		if hitgroup == HITGROUP_HEAD then
			self:PlayFlinchSequence( self.HeadFlinch, 1, 0, 0, 0.7 )
		elseif hitgroup == HITGROUP_LEFTLEG then
			self:PlayFlinchSequence( self.LLegFlinch, 1, 0, 0, 2.5 )
		elseif hitgroup == HITGROUP_RIGHTLEG then
			self:PlayFlinchSequence( self.RLegFlinch, 1, 0, 0, 1.6 )
		elseif hitgroup == HITGROUP_LEFTARM then
			self:PlayFlinchSequence( self.LArmFlinch, 1, 0, 0, 0.7 )
		elseif hitgroup == HITGROUP_RIGHTARM then
			self:PlayFlinchSequence( self.RArmFlinch, 1, 0, 0, 0.7 )
		elseif hitgroup == HITGROUP_CHEST or HITGROUP_GEAR or HITGROUP_STOMACH then
			
			local enemy = dmginfo:GetAttacker()
			
			if enemy:IsValid() then
				if enemy:IsPlayer() then
				
					local enemyforward = enemy:GetForward()
					local forward = self:GetForward() 
					
					if enemyforward:Distance( forward ) < 1 then
						self:PlayFlinchSequence( "shovereactbehind", 1, 0, self.Speed -  25, 1.6 )
						self.loco:SetAcceleration(1000)
						self.Stumbling = true
						self.StumbleType = 2
					else
						self:PlayFlinchSequence( "shovereact", 1, 0, self.Speed - 25, 1.6 )
						self.loco:SetAcceleration(1000)
						self.Stumbling = true
						self.StumbleType = 1
					end
				
				end
			end
			
		end
		
		self.NextFlinch = CurTime() + 3	
	end	
	
end

function ENT:FootSteps()
	self:EmitSound("HL1/ambience/des_wind2.wav", 75, 50)
end

function ENT:IdleSound()

end

function ENT:CustomDoorAttack( ent )

	if ( self.NextDoorAttackTimer or 0 ) < CurTime() then
	
		if !self:CheckStatus() then return end
	
		self:AttackSound()
	
		self:Melee( ent, 2 )
		
		self.NextDoorAttackTimer = CurTime() + self.NextAttack
	end
	
end
	
function ENT:CustomPropAttack( ent )

	if ( self.NextPropAttackTimer or 0 ) < CurTime() then

		if !self:CheckStatus() then return end
	
		self:AttackSound()
	
		self:Melee( ent, 1 )
	
		self.NextPropAttackTimer = CurTime() + self.NextAttack
	end
	
end

function ENT:AttackEffect( time, ent, dmg, type )

	timer.Simple(time, function() 
		if !self:IsValid() then return end
		if self:Health() < 0 then return end
		if !self:CheckValid( ent ) then return end
		if !self:CheckStatus() then return end
		
		if self:GetRangeTo( ent ) < self.AttackRange then
			
			ent:TakeDamage( self.Damage, self )
			
			if ent:IsPlayer() or ent:IsNPC() then
				self:BleedVisual( 0.2, ent:GetPos() + Vector(0,0,50) )	
				self:EmitSound( "ambient/wind/wind_hit"..math.random(1,3)..".wav", 75, 200 )
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
			self:EmitSound( "ambient/wind/wind_moan"..math.random(1,2)..".wav", 75, math.random(50,70) )
		end
		
	end)
end

function ENT:Melee( ent, type )
	local attack = math.random(1,3)
	if attack == 1 then
		self:AttackEffect( 0.8, ent, self.Damage, type )
		self:PlaySequenceAndWait( self.AttackAnim1, 1 )
	elseif attack == 2 then
		self:AttackEffect( 0.7, ent, self.Damage - 10, type )
		self:AttackEffect( 1.2, ent, self.Damage - 10, type )
		self:PlaySequenceAndWait( self.AttackAnim2, 1 )
	elseif attack == 3 then
		self:AttackEffect( 0.8, ent, self.Damage - 10, type )
		self:AttackEffect( 1.6, ent, self.Damage - 10, type )
		self:PlaySequenceAndWait( self.AttackAnim3, 1 )
	end
	
	self.IsAttacking = false
	self:ResumeMovementFunctions()
end

function ENT:Attack()
	if ( self.NextAttackTimer or 0 ) < CurTime() then	
		
		if ( (self.Enemy:IsValid() and self.Enemy:Health() > 0 ) ) then
		
			if !self:CheckStatus() then return end
			
			self:AttackSound()
			self.IsAttacking = true
	
			self:Melee( self.Enemy, 0 )
			
		end
		
		self.NextAttackTimer = CurTime() + self.NextAttack
	end	
end
