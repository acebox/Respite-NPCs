if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "housewife", {
	Name = "Housewife",
	Class = "housewife",
	Category = "Respite"
} )

ENT.classname = "housewife"
ENT.NiceName = "Housewife"
--Stats--
ENT.MoveType = 2

ENT.UseFootSteps = 1

ENT.FootAngles = 11
ENT.FootAngles2 = 11

ENT.Bone1 = "mixamorig:RightFoot"
ENT.Bone2 = "mixamorig:LeftFoot"

ENT.CollisionHeight = 85
ENT.CollisionSide = 13

ENT.Speed = 180
ENT.WalkSpeedAnimation = 1.0

ENT.health = 100
ENT.Damage = 10

ENT.PhysForce = 30000
ENT.AttackRange = 75
ENT.InitialAttackRange = 60
ENT.DoorAttackRange = 60

ENT.NextAttack = 0.6
ENT.AttackFinishTime = 0.8 --how long it takes for an attack to finish

ENT.pitch = 70
ENT.pitchVar = 15 --the variance of the pitch
ENT.wanderType = 2

--Model Settings--
ENT.Model = "models/spite/housewife.mdl"

ENT.WalkAnim = "run"

ENT.IdleAnim = "idle"

ENT.AttackAnim = ACT_MELEE_ATTACK1


--Sounds--

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.alertSounds = {
	"respite/housewife/01.wav",
	"respite/housewife/02.wav",
	"respite/housewife/03.wav"
}

ENT.hitSounds = {
	"weapons/maniac_slash.wav"
}

ENT.missSounds = {
	"npc/zombie/claw_miss1.wav"
}

ENT.attackSounds = ENT.alertSounds
ENT.deathSounds = ENT.alertSounds
ENT.idleSounds = ENT.alertSounds
ENT.painSounds = ENT.alertSounds

function ENT:Initialize()

	self:SetModel(self.Model)
	if SERVER then

	self:SetHealth(self.health)	
	
	self.IsAttacking = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(500)
	self.loco:SetDeceleration(900)

	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	self:PhysicsInitShadow(true, true)
	
	end
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,4) == 4) then
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
	self:EmitSound( 'monsters/suitor/metal_run0'  .. math.random(1,3) .. '.mp3', 75, math.random(80, 95) )
end