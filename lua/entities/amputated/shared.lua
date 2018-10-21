if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false


list.Set( "NPC", "amputated", {
	Name = "Amputated",
	Class = "amputated",
	Category = "Respite"
} )

ENT.classname = "amputated"
ENT.NiceName = "Amputated"

ENT.MoveType = 3

ENT.UseFootSteps = 1

ENT.FootAngles = 0
ENT.FootAngles2 = 0

ENT.Bone1 = "Bip01_R Foot"
ENT.Bone2 = "Bip01_L Foot"

ENT.CollisionHeight = 70
ENT.CollisionSide = 11

ENT.Speed = 35
ENT.WalkSpeedAnimation = 1.0

ENT.health = 250
ENT.Damage = 12

ENT.PhysForce = 30000
ENT.AttackRange = 65
ENT.InitialAttackRange = 55
ENT.DoorAttackRange = 25

ENT.NextAttack = 0.5

ENT.AttackFinishTime = 0.5 --how long it takes for an attack to finish

ENT.pitch = 60
ENT.wanderType = 2

--Model Settings--

ENT.Model = "models/am_npc/amputated.mdl"

ENT.WalkAnim = "walk"
ENT.IdleAnim = "tantrum"

ENT.AttackAnim = ACT_MELEE_ATTACK1

--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"deadzone/lepotitsa/pain1.wav",
	"respite/scare20.wav"
}

ENT.alertSounds = {
	"soma/npc_soma_proxy/hunt_04.wav",
	"soma/npc_soma_proxy/hunt_06.wav",
	"soma/npc_soma_proxy/hunt_01.wav",
	"deadzone/lepotitsa/death2.wav",
	"respite/scare20.wav"
}

ENT.deathSounds = {
	"npc/infected/zombie_die1.wav",
	"npc/infected/zombie_die2.wav",
	"npc/infected/zombie_die3.wav",
	"npc/infected/zombie_die4.wav",
	"npc/infected/zombie_die5.wav",
	"npc/infected/zombie_die6.wav"
}

ENT.idleSounds = {
	"soma/npc_soma_proxy/hunt_02.wav",
	"soma/npc_soma_proxy/idle_close_03.wav" ,
	"npc/infected/zombie_voice_idle3.wav",
	"npc/infected/zombie_voice_idle4.wav",
	"npc/infected/zombie_voice_idle5.wav",
	"npc/infected/zombie_voice_idle6.wav",
	"npc/infected/zombie_voice_idle7.wav",
	"npc/infected/zombie_voice_idle8.wav"
}

ENT.painSounds = {
	"npc/infected/zombie_pain4.wav",
	"npc/infected/zombie_pain5.wav",
	"npc/infected/zombie_pain6.wav"
}

--[[
ENT.missSounds = {
	"npc/zombie/claw_miss1.wav"
}
--]]

ENT.hitSounds = {
	"npc/zombie/claw_strike1.wav"
}

function ENT:Initialize()

	self:SetModel(self.Model)
	self:SetHealth(self.health)	

	if SERVER then

	-- if ( math.random(1, 10) >= 5 ) then
    -- self:SetMaterial("models/player/slow/amberlyn/re5/uroboro/slow_meatball")
	-- else
	-- end
	
	self.IsAttacking = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(400)
	self.loco:SetDeceleration(900)
	self:PhysicsInitShadow(true, true)

	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	
	end
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,1) == 1) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end
	self:TransformRagdoll( dmginfo )
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
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
			dmginfo:ScaleDamage(20) --just kill the thing
		end
	end

end

function ENT:FootSteps()
	self:EmitSound( 'monsters/suitor/metal_run0'..math.random( 1, 3 )..'.mp3', 70, math.random(90, 110) )
end

--no miss sound for these
function ENT:MissSound()
end