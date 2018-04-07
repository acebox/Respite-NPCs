if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

list.Set( "NPC", "scarlet", {
	Name = "Scarlet",
	Class = "scarlet",
	Category = "Respite"
} )

ENT.classname = "scarlet"
ENT.NiceName = "Scarlet"

--Stats--
ENT.MoveType = 2

ENT.UseFootSteps = 1

ENT.FootAngles = 45
ENT.FootAngles2 = 45

ENT.Bone1 = "mixamorig:RightFoot"
ENT.Bone2 = "mixamorig:LeftFoot"

ENT.CollisionHeight = 90
ENT.CollisionSide = 17

ENT.Speed = 250
ENT.WalkSpeedAnimation = 1.0

ENT.health = 250
ENT.Damage = 8

ENT.PhysForce = 30000
ENT.AttackRange = 100
ENT.InitialAttackRange = 90
ENT.DoorAttackRange = 70

ENT.NextAttack = 1.0

ENT.AttackFinishTime = 1.1

ENT.wanderType = 1
ENT.pitch = 115
ENT.pitchVar = 15

--Model Settings--
ENT.Model = "models/spite/scarlet.mdl"

ENT.IdleAnim = "idle"
ENT.WalkAnim = "run"
ENT.AttackAnim = "attack1"

--Sounds--

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.alertSounds = {
	"dalrp/npc/gemini/die1.wav",
	"dalrp/npc/gemini/die2.wav",
	"dalrp/npc/gemini/pain1.wav",
	"dalrp/npc/gemini/pain2.wav",
	"dalrp/npc/gemini/pain3.wav"
}

ENT.hitSounds = {
	"npc/zombie/claw_strike1.wav"
}
ENT.missSounds = {
	"npc/zombie/claw_miss1.wav"
}

ENT.attackSounds = ENT.alertSounds
ENT.deathSounds = ENT.alertSounds

ENT.idleSounds = {
	"physics/plastic/plastic_box_break1.wav",
	"physics/plastic/plastic_box_break2.wav",
	"npc/strider/strider_legstretch1.wav",
	"npc/strider/strider_legstretch2.wav",
	"npc/strider/strider_legstretch3.wav"
}

ENT.painSounds = ENT.alertSounds

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
	self.loco:SetDeceleration(700)
	
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	self:PhysicsInitShadow(true, true)
	end

end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,4) == 4) then
		nut.item.spawn("medical_plastic", self:GetPos()+ Vector(0,0,20))
	end
	if (math.random(0,4) == 4) then
		nut.item.spawn("j_monster_claw", self:GetPos()+ Vector(0,0,20))
	end	
	self:TransformRagdoll( dmginfo )
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
end

function ENT:Enrage()
	self.Speed = 300
	self.WalkAnim = "run"
	self.wanderType = 1
end

function ENT:OnAlert()
	self:Enrage()
end