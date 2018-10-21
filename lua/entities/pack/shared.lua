if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

list.Set( "NPC", "pack", {
	Name = "Pack",
	Class = "pack",
	Category = "Respite"
} )


ENT.classname = "pack"
ENT.NiceName = "Pack"

--Stats--
ENT.MoveType = 3

ENT.UseFootSteps = 1

ENT.FootAngles = 7
ENT.FootAngles2 = 7

ENT.Bone1 = "mixamorig:RightFoot"
ENT.Bone2 = "mixamorig:LeftFoot"

ENT.CollisionHeight = 50
ENT.CollisionSide = 6

ENT.Speed = 50
ENT.WalkSpeedAnimation = 1.0

ENT.health = 100
ENT.Damage = 8

ENT.PhysForce = 30000
ENT.AttackRange = 65
ENT.InitialAttackRange = 60
ENT.DoorAttackRange = 25

ENT.NextAttack = 0.5

ENT.AttackFinishTime = 1

ENT.pitch = 130
ENT.pitchVar = 10
ENT.wanderType = 2

--Model Settings--
ENT.Model = "models/spite/pack.mdl"

ENT.WalkAnim = "walk1"

ENT.IdleAnim = "idle1"

ENT.AttackAnim = ACT_MELEE_ATTACK1


--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"dalrp/npc/baby/babydie2.wav",
	"dalrp/npc/baby/babyalert.wav"
}

ENT.alertSounds = {
	"dalrp/npc/baby/babyalert.wav",
	"dalrp/npc/baby/babydie.wav",
	"cof/faster/faster_alert1.wav",
	"cof/faster/faster_alert2.wav",
	"cof/faceless/faceless_alert10.wav",
	"cof/faceless/faceless_alert20.wav",
	"cof/faceless/faceless_alert30.wav"
}

ENT.deathSounds = {
	"dalrp/npc/baby/babydie2.wav"
}

ENT.idleSounds = {
	"soma/npc_soma_proxy/hunt_02.wav",
	"soma/npc_soma_proxy/idle_close_03.wav",
	"dalrp/npc/nurse/nurse_vocal02.wav",
	"dalrp/npc/nurse/nurse_vocal03.wav",
	"dalrp/npc/nurse/nurse_vocal08.wav"
}

ENT.painSounds = {
	"dalrp/npc/baby/baby_pain1.wav",
	"dalrp/npc/nurse/nurse_vocal02.wav",
	"dalrp/npc/nurse/nurse_vocal03.wav",
	"dalrp/npc/nurse/nurse_vocal08.wav"
}

ENT.hitSounds = {
	"npc/zombie/claw_strike1.wav"
}

ENT.missSounds = {
	"npc/zombie/claw_miss1.wav"
}

function ENT:Initialize()

	if SERVER then
	self.loco:SetMaxYawRate(300)
	
	--Stats--
	
	self:SetModel(self.Model)
	self:SetHealth(self.health)	

	self.IsAttacking = false

	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(900)
	self.loco:SetDeceleration(900)
	self:PhysicsInitShadow(true, true)
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	
	end
	
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,4) == 4) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end
	if (math.random(0,9) == 9) then
		nut.item.spawn("j_monster_claw", self:GetPos()+ Vector(0,0,20))
	end	
	util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	self:TransformRagdoll( dmginfo )
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	if ( dmginfo:IsBulletDamage() ) then

		// hack: get hitgroup
		local trace = {}
		trace.start = attacker:GetShootPos()
			
		trace.endpos = trace.start + ( ( dmginfo:GetDamagePosition() - trace.start ) * 2 )  
		trace.mask = MASK_SHOT
		trace.filter = attacker
			
		local tr = util.TraceLine( trace )
		hitgroup = tr.HitGroup
				
		if hitgroup == HITGROUP_HEAD then
			self:EmitSound("hits/headshot_"..math.random(9)..".wav", 70)
			dmginfo:ScaleDamage(10)
		end
	end
end

function ENT:FootSteps()
	self:EmitSound( 'monsters/suitor/metal_run0'..math.random( 1, 3 )..'.mp3', 70, math.random(90, 110) )
end

--get mad
function ENT:Enrage()
	self.Speed = 350
	self.WalkAnim = "run"
	self.wanderType = 4
end

function ENT:Calm() --unenrage
	self.Speed = 55
	self.WalkAnim = "walk1"
	self.wanderType = 2
end

function ENT:OnAlert()
	self:Enrage()
end