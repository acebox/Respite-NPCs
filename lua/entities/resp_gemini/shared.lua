if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

list.Set( "NPC", "resp_gemini", {
	Name = "Gemini",
	Class = "resp_gemini",
	Category = "Respite"
} )

ENT.classname = "resp_gemini"

--Stats--
ENT.MoveType = 2

ENT.UseFootSteps = 1

ENT.FootAngles = 10
ENT.FootAngles2 = 10

ENT.Bone1 = "foot.r"
ENT.Bone2 = "foot.l"

ENT.CollisionHeight = 65
ENT.CollisionSide = 25

ENT.Speed = 130
ENT.WalkSpeedAnimation = 0.8

ENT.health = 300
ENT.Damage = 10

ENT.PhysForce = 30000
ENT.AttackRange = 60
ENT.InitialAttackRange = 50
ENT.DoorAttackRange = 50

ENT.NextAttack = 0.4

ENT.AttackFinishTime = 0.5

ENT.pitch = 120
ENT.pitchVar = 20

ENT.wanderType = 3

--Model Settings--
ENT.Model = "models/zombie/gemini.mdl"

ENT.WalkAnim = "walk"

ENT.IdleAnim = "idle"
ENT.AttackAnim = "bite"


--Sounds--
ENT.attackSounds = {
	"respite/brute/brute3.wav",
	"respite/brute/brute1.wav"
}

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.alertSounds = {
	"respite/brute/brute5.wav",
	"respite/brute/brute6.wav"
}

ENT.deathSounds = {
	"respite/brute/brute1.wav",
	"respite/brute/brute2.wav"
}

ENT.idleSounds = {
	"respite/brute/brute3.wav",
	"respite/brute/brute2.wav"
}

ENT.painSounds = {
	"respite/brute/brute3.wav",
	"respite/brute/brute4.wav"
}

ENT.hitSounds = {
	"npc/zombie/claw_strike1.wav"
}

ENT.missSounds = {
	"npc/zombie/claw_miss1.wav"
}

function ENT:Initialize()

	if SERVER then

	--Stats--
	self:SetModel(self.Model)

	self:SetHealth(self.health)	
	
	self.IsAttacking = false

	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(500)
	self.loco:SetDeceleration(900)
	
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	self:PhysicsInitShadow(true, true)
	end
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,1) == 1) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end
	util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	self:TransformRagdoll( dmginfo )
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
end

function ENT:FootSteps()
	local random = math.random( 1, 3 )
	self:EmitSound( 'monsters/suitor/metal_run0'  .. random .. '.mp3', 85, math.random(85, 95) )
end

function ENT:Enrage()
	self.Speed = 330
	self.WalkAnim = "run"
	self.wanderType = 1
	self.WalkSpeedAnimation = 1
end

function ENT:OnAlert()
	self:Enrage()
end