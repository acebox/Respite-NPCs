if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "scarlet"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

list.Set( "NPC", "scarlet_crawl", {
	Name = "Scarlet (Crawl)",
	Class = "scarlet_crawl",
	Category = "Respite"
} )

ENT.classname = "scarlet_crawl"
ENT.NiceName = "Scarlet"

--Stats--
ENT.MoveType = 2

ENT.UseFootSteps = 2
ENT.FootStepTime = 0.6

ENT.FootAngles = 90
ENT.FootAngles2 = 90

ENT.Bone1 = "mixamorig:RightFoot"
ENT.Bone2 = "mixamorig:LeftFoot"

ENT.CollisionHeight = 90
ENT.CollisionSide = 17

ENT.Speed = 100
ENT.WalkSpeedAnimation = 1.0

ENT.health = 300
ENT.Damage = 10

ENT.PhysForce = 30000
ENT.AttackRange = 100
ENT.InitialAttackRange = 90
ENT.DoorAttackRange = 75

ENT.NextAttack = 1.2

ENT.AttackFinishTime = 0.9

ENT.wanderType = 1
ENT.pitch = 115
ENT.pitchVar = 15

--Model Settings--

ENT.Model = "models/spite/scarlet.mdl"

ENT.IdleAnim = "idle"
ENT.WalkAnim = "crawl"
ENT.AttackAnim = ACT_MELEE_ATTACK1

function ENT:Initialize()
	if SERVER then

	--Stats--
	self:SetBloodColor(DONT_BLEED)
	self:SetModel(self.Model)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	
	self:SetHealth(self.health)	
	
	self.IsAttacking = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(400)
	self.loco:SetDeceleration(400)
	
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	self:PhysicsInitShadow(true, true)
	end
end