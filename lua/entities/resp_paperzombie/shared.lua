if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "resp_paperzombie", {
	Name = "Paper Zombie",
	Class = "resp_paperzombie",
	Category = "Respite"
} )
ENT.UseFootSteps = 0

ENT.MoveType = 2

ENT.LoseTargetDist	= 4500	-- How far the enemy has to be before we lose them
ENT.SearchRadius 	= 3000	-- How far to search for enemies

ENT.CollisionHeight = 70
ENT.CollisionSide = 11

ENT.Model = "models/respite/paperzombie.mdl"

ENT.ChaseSpeed = 160
ENT.Speed = 30
ENT.health = 1
ENT.Damage = 5

ENT.pitch = 70
ENT.pitchVar = 10

ENT.IdleAnim = "idle01"
ENT.WalkAnim = "a_walk2"
ENT.AttackAnim = "attacka"

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.alertSounds = { 
	"cof/faceless/faceless_alert10.wav",
	"cof/faceless/faceless_alert20.wav",
	"cof/faceless/faceless_alert30.wav"
}

ENT.attackSounds = { 
	"cof/faceless/faceless_attack1.wav",
	"cof/faceless/faceless_attack2.wav"
}

ENT.painSounds = { 
	"cof/faceless/faceless_pain1.wav",
	"cof/faceless/faceless_pain2.wav",
}

ENT.missSounds = { 
	"cof/faceless/fist_miss1.wav",
	"cof/faceless/fist_miss2.wav"
}

ENT.hitSounds = { 
	"cof/faceless/fist_strike1.wav",
	"cof/faceless/fist_strike2.wav",
	"cof/faceless/fist_strike3.wav"
}

function ENT:DeathSound()

end

function ENT:IdleSound()

end

function ENT:Initialize()

	if ( SERVER ) then
		self:Precache()
	end
	
	self:SetHealth(self.health)	
	self:SetModel(self.Model)
	
    self:PhysicsInitShadow(true, false)
	
    self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
end

function ENT:CustomDeath()
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	
    self:TransformRagdoll()
end

--get mad
function ENT:Enrage()
	self.Speed = 250
	self.wanderType = 3
end

function ENT:OnAlert()
	self:Enrage()
end
