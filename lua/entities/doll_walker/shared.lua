if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "doll_walker", {
	Name = "Doll (Walking)",
	Class = "doll_walker",
	Category = "Respite"
} )


ENT.classname = "doll_walker"
ENT.NiceName = "Doll"
--Stats--
ENT.MoveType = 2

ENT.UseFootSteps = 1

ENT.FootAngles = 15
ENT.FootAngles2 = 45

ENT.Bone1 = "mixamorig:RightFoot"
ENT.Bone2 = "mixamorig:LeftFoot"

ENT.CollisionHeight = 80
ENT.CollisionSide = 11

ENT.Speed = 280
ENT.WalkSpeedAnimation = 1.0

ENT.health = 120
ENT.Damage = 6

ENT.PhysForce = 30000
ENT.AttackRange = 85
ENT.InitialAttackRange = 90
ENT.DoorAttackRange = 50

ENT.NextAttack = 1

ENT.wanderType = 1

--Model Settings--
ENT.Model = "models/spite/doll.mdl"

ENT.WalkAnim = "walk"
ENT.IdleAnim = "idle"

ENT.AttackAnim = "attack2"

ENT.AttackFinishTime = 0.7

--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"respite/scare9.wav",
	"respite/scare20.wav"
}

ENT.alertSounds = {
	"respite/scare9.wav",
	"respite/scare20.wav"
}

ENT.deathSounds = {
	"dalrp/npc/gemini/die1.wav",
	"dalrp/npc/gemini/die2.wav"
}

ENT.idleSounds = {
	"physics/plastic/plastic_box_break1.wav",
	"physics/plastic/plastic_box_break2.wav",
	"npc/strider/strider_legstretch1.wav",
	"npc/strider/strider_legstretch2.wav",
	"npc/strider/strider_legstretch3.wav"
}

ENT.painSounds = {
	"respite/scare6.wav",
	"dalrp/npc/gemini/die1.wav",
	"dalrp/npc/gemini/die2.wav"
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
	self:SetBloodColor(DONT_BLEED)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetModel(self.Model)
	
	if(math.random(0,1) == 1) then
		self:SetMaterial("phoenix_storms/mrref2")
	else
		self:SetMaterial("models/props_buildings/plasterwall021a")
	end

	self.Speed = self.Speed - 240
	self:SetHealth(self.health)
	
	self.IsAttacking = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(400)
	self.loco:SetDeceleration(900)
	
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	self:PhysicsInitShadow(true, true)
	end
	
	self:SetBodygroup(1,math.random(0,1))
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,3) == 3) then
		nut.item.spawn("j_scrap_plastics", self:GetPos()+ Vector(0,0,20))
	end
	self:TransformRagdoll( dmginfo )
	hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() ) 
	
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
end

function ENT:FootSteps()
	self:EmitSound( 'monsters/suitor/metal_run0'..math.random(1,3)..'.mp3', 75, math.random(90, 115) )
end