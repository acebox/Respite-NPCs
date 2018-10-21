if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "resp_floater", {
	Name = "Floater",
	Class = "resp_floater",
	Category = "Respite"
} )

ENT.CollisionHeight = 70
ENT.CollisionSide = 11

ENT.UseFootSteps = 0

ENT.AttackRange = 80
ENT.InitialAttackRange = 70

ENT.NextAttack = 0

ENT.health = 100
ENT.Damage = 7
ENT.Speed = 30

ENT.AttackFinishTime = 0.4
ENT.AttackAnimSpeed = 2

ENT.idleTime = 3

ENT.LoseTargetDist	= 4500	-- How far the enemy has to be before we lose them
ENT.SearchRadius 	= 3000	-- How far to search for enemies

ENT.models = {
	"models/zombie/classic2.mdl",
	"models/zombie/classic3.mdl",
	"models/zombie/classic4.mdl"
}

ENT.AttackAnim = "attacka"
ENT.WalkAnim = ACT_WALK
ENT.IdleAnim = "idle01"

ENT.AttackAnims = {
	"attacka",
	"attackb"
}

ENT.wanderType = 3

ENT.pitch = 90
ENT.pitchVar = 10

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.alertSounds = { 
	"npc/seekers/alert1.wav", 
	"npc/seekers/alert2.wav", 
	"npc/seekers/alert3.wav", 
	"npc/seekers/alert4.wav"
}

ENT.attackSounds = { 
	"npc/seekers/attack1.wav",
	"npc/seekers/attack2.wav",
	"npc/seekers/attack3.wav",
	"npc/seekers/attack4.wav"
}

ENT.deathSounds = { 
	"npc/infected_zombies/death_17.wav", 
	"npc/infected_zombies/death_18.wav", 
	"npc/infected_zombies/death_19.wav", 
	"npc/infected_zombies/death_20.wav", 
	"npc/infected_zombies/death_21.wav", 
	"npc/infected_zombies/death_22.wav", 
	"npc/infected_zombies/death_23.wav", 
	"npc/infected_zombies/death_24.wav", 
	"npc/infected_zombies/death_25.wav", 
	"npc/infected_zombies/death_26.wav", 
	"npc/infected_zombies/death_27.wav", 
	"npc/infected_zombies/death_28.wav", 
	"npc/infected_zombies/death_29.wav", 
	"npc/infected_zombies/death_30.wav", 
	"npc/infected_zombies/death_31.wav", 
	"npc/infected_zombies/death_32.wav", 
	"npc/infected_zombies/death_33.wav", 
	"npc/infected_zombies/death_34.wav", 
	"npc/infected_zombies/death_35.wav"
}

ENT.idleSounds = { 
	"npc/infected_zombies/rage_at_victim20.wav",
	"npc/infected_zombies/rage_at_victim21.wav",
	"npc/infected_zombies/rage_at_victim22.wav",
	"npc/infected_zombies/rage_at_victim23.wav",
	"npc/infected_zombies/rage_at_victim24.wav",
	"npc/infected_zombies/rage_at_victim25.wav",
	"npc/infected_zombies/rage_at_victim26.wav",
	"npc/infected_zombies/rage_at_victim27.wav",
	"npc/infected_zombies/rage_at_victim28.wav",
	"npc/infected_zombies/rage_at_victim29.wav",
	"npc/infected_zombies/rage_at_victim30.wav",
	"npc/infected_zombies/rage_at_victim31.wav",
	"npc/infected_zombies/rage_at_victim32.wav",
	"npc/infected_zombies/rage_at_victim33.wav",
	"npc/infected_zombies/rage_at_victim34.wav",
	"npc/infected_zombies/rage_at_victim35.wav",
	"npc/infected_zombies/rage_at_victim36.wav",
	"npc/infected_zombies/rage_at_victim37.wav"
}

ENT.painSounds = { 
	"npc/infected_zombies/pain1.wav", 
	"npc/infected_zombies/pain2.wav", 
	"npc/infected_zombies/pain3.wav", 
	"npc/infected_zombies/pain4.wav", 
	"npc/infected_zombies/pain5.wav", 
	"npc/infected_zombies/pain6.wav", 
	"npc/infected_zombies/pain7.wav", 
	"npc/infected_zombies/pain8.wav", 
	"npc/infected_zombies/pain9.wav"
}

ENT.missSounds = { 
	"fx/melee_miss5.mp3"
}

ENT.hitSounds = { 
	"weapons/maniac_slash.wav"
}

function ENT:Initialize()

	if ( SERVER ) then
	self:Precache()
	end
	
	self:SetModel( table.Random( self.models ) )
	
	self.NextMoan = 0;
	
	if( SERVER ) then 
		self:Precache()
		self.loco:SetStepHeight(30)
		self.loco:SetAcceleration(400)
		self.loco:SetDeceleration(400)
		self.loco:SetJumpHeight( 60 )
		
		self:SetHealth(self.health)
	end
	
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	
    self:PhysicsInitShadow(true, false)
end

--called when the npc is chasing a target
function ENT:CustomChaseEnemy()
	if(!self.Enemy or !IsValid(self.Enemy)) then return end

	if(self:GetRangeSquaredTo(self.Enemy:GetPos()) < 100000) then
		if(!self.nextJump) then self.nextJump = CurTime() end
	
		if(self.nextJump < CurTime()) then
			self.loco:SetAcceleration(2000)
			self.loco:SetDesiredSpeed(500)
				
			local temp = function()
				self.loco:FaceTowards(self.Enemy:GetPos())
				self.loco:Jump()
				
				self.loco:SetAcceleration(900)
				self.loco:SetDesiredSpeed(self.Speed)
					
				self:ResumeMovementFunctions()
			end
				
			self:delay(0.3, temp)
			
			self.nextJump = self.nextJump + math.random(5,10)
		end
	end
end

function ENT:CustomDeath()
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	
	if (math.random(0,4) == 4) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end		
	
	if (math.random(0,10) == 10) then
		nut.item.spawn("hl2_m_boneshiv", self:GetPos()+ Vector(0,0,20))
	end
	
    self:TransformRagdoll( )
end

--get mad
function ENT:Enrage()
	self.Speed = 250
	self.wanderType = 4
end

function ENT:OnAlert()
	self:Enrage()
end

function ENT:CustomAttack()
	self.AttackAnim = self.AttackAnims[ math.random( #self.AttackAnims ) ]
end
