if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_reanimated", {
	Name = "Reanimated",
	Class = "nz_reanimated",
	Category = "Respite"
} )

--Stats--
ENT.MoveType = 2

ENT.CollisionHeight = 68
ENT.CollisionSide = 7

ENT.Speed = 50
ENT.WalkSpeedAnimation = 1
ENT.FlinchSpeed = 20

ENT.health = 140
ENT.Damage = 15

ENT.PhysForce = 10000
ENT.HitPerDoor = 2

ENT.AttackRange = 50
ENT.InitialAttackRange = 55
ENT.DoorAttackRange = 25

ENT.NextAttack = 1.3

ENT.SearchRadius = 500

ENT.AttackFinishTime = 0.8

--Model Settings--
ENT.Model = "models/zombie/reanimated.mdl"

ENT.SleepAnim = "slump_a"
ENT.RiseAnim = "slumprise_a"

ENT.SleepAnim1 = "slump_a"
ENT.SleepAnim2 = "slump_b"

ENT.RiseAnim1 = "slumprise_a2"
ENT.RiseAnim2 = "slumprise_a"
ENT.RiseAnim3 = "slumprise_b"

ENT.AttackAnims = {
	"swatleftlow",
	"swatleftmid",
	"swatrightlow",
	"swatrightmid"
}

ENT.WalkAnim = "walk"
ENT.WalkAnim1 = "walk"
ENT.WalkAnim2 = "walk2"
ENT.WalkAnim3 = "walk3"
ENT.WalkAnim4 = "walk4"

ENT.ChestFlinch1 = "physflinch1"
ENT.ChestFlinch2 = "physflinch2"
ENT.ChestFlinch3 = "physflinch3"

ENT.HeadFlinch = "flinch_head"

ENT.RLegFlinch = "flinch_rightleg"
ENT.RArmFlinch = "flinch_rightarm"

ENT.LLegFlinch = "flinch_leftleg"
ENT.LArmFlinch = "flinch_leftarm"

ENT.wanderType = 4

--Sounds--

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.deathSounds = {
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav"
}

ENT.painSounds = {
	"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain5.wav"
}

ENT.hitSounds = {
	"npc/zombie/claw_strike1.wav"
}
ENT.missSounds = {
	"npc/zombie/claw_miss1.wav"
}

function ENT:AlertSound()
end
function ENT:AttackSound()
end
function ENT:IdleSound()
end

function ENT:Initialize()

	if SERVER then

	--Stats--
	self:SetModel(self.Model)
	self:SetHealth(self.health)	
	
	local anim = math.random(1,4)
	if anim == 1 then
		self.WalkAnim = self.WalkAnim1
	elseif anim == 2 then
		self.WalkAnim = self.WalkAnim2
	elseif anim == 3 then
		self.WalkAnim = self.WalkAnim3
	elseif anim == 4 then
		self.WalkAnim = self.WalkAnim4
	end
	
	local sleepanim = math.random(1,3)
	if sleepanim == 1 then
		self.SetSleepAnim = self.SleepAnim
		self.SetRiseAnim = self.RiseAnim
	elseif sleepanim == 2 then
		self.SetSleepAnim = self.SleepAnim2
		self.SetRiseAnim = self.RiseAnim3
	elseif sleepanim == 3 then
		self.SetSleepAnim = self.SleepAnim
		self.SetRiseAnim = self.RiseAnim1
	end
	
	self.IsAttacking = false
	self.Flinching = false
	self.Entrance = true
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(200)
	self.loco:SetDeceleration(900)
	
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	
	end
	
end

function ENT:CheckStatus( attacking )

	if self.Flinching then
		return false
	end
	
	if self.Entrance then
		return false
	end
	
	if attacking != 1 then
		if self.IsAttacking then
			return false
		end
	end
	
	return true

end

function ENT:CustomDeath( dmginfo )	
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	
	if (math.random(0,4) == 4) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end	
	
	self:TransformRagdoll( dmginfo )
end

function ENT:CustomInjure( dmginfo )
	
	if dmginfo:GetDamage() > 30 then
		self:Flinch( dmginfo, hitgroup )
	end
	
	if ( dmginfo:IsBulletDamage() ) then
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
			dmginfo:ScaleDamage(6)
			self:EmitSound("hits/headshot_"..math.random(9)..".wav", 70)
		else
			dmginfo:ScaleDamage(0.60)
		end
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

function ENT:Flinch( dmginfo, hitgroup )
	
	if ( self.NextFlinch or 0 ) < CurTime() then
	
		if !self:CheckValid( self ) then return end
		if !self:CheckStatus( 1 ) then return end
	
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
			if math.random(1,3) == 1 then
				self:PlayFlinchSequence( self.ChestFlinch1, 1, 0, 0, 0.5 )
			elseif math.random(1,3) == 2 then
				self:PlayFlinchSequence( self.ChestFlinch2, 1, 0, 0, 0.6 )
			elseif math.random(1,3) == 3 then
				self:PlayFlinchSequence( self.ChestFlinch3, 1, 0, 0, 0.6 )
			end
		end
		
		self.NextFlinch = CurTime() + 2	
	end	
		
end

function ENT:FootSteps()
	self:EmitSound("npc/zombie/foot"..math.random(3)..".wav", 70)
end

function ENT:IdleFunction()
	if self.Entrance then
		self:PlaySequenceAndWait( self.SetSleepAnim, 1 )
		return
	end

	if (self.wanderType == 1) then --just stand there
		self:Idle()
		
	elseif (self.wanderType == 2) then --find a hiding spot and then just stand there
		if(!self.Hiding) then --find a spot.
			self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
			local spot = self:FindSpot( "random", { type = 'hiding', radius = 5000 } )
			self:GoToLocation(spot)
			self.Hiding = true
		else --just stand there if you're in a spot.
			self:Idle()
		end
		
	elseif (self.wanderType == 3) then --walk around aimlessly, pausing every so often.
		if(CurTime() > self.nextWander) then
			self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )			
			self:Wander(self:GetPos() + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400) -- Walk to a random place within about 400 units (yielding)
		else --hang out for awhile
			self:Idle()
		end
		
	else --just run around like an idiot i guess
		self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )	
		self:Wander(self:GetPos() + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400) -- Walk to a random place within about 400 units (yielding)
	end
end

function ENT:CustomAttack()
	self.AttackAnim = self.AttackAnims[ math.random( #self.AttackAnims ) ]
end

function ENT:WakeUp()
	self:PlaySequenceAndWait(self.SetRiseAnim, 1)
	self.Entrance = false
	self.loco:SetDesiredSpeed( 0 )

	self.loco:SetDesiredSpeed( self.Speed )
	self:ResumeMovementFunctions()
	
	self.SearchRadius = 2000
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
				self:WakeUp()
			end
			self:IdleFunction()
		end
		coroutine.yield()
	end
end