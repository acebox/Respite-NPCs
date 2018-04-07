if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = true
ENT.AdminSpawnable   = true

--SpawnMenu--
list.Set( "NPC", "nz_dog", {
	Name = "Dog",
	Class = "nz_dog",
	Category = "Respite"
} )

--Stats--
ENT.FootAngles = 3
ENT.FootAngles2 = 3
ENT.CollisionHeight = 42
ENT.CollisionSide = 7
ENT.MoveType = 2
ENT.UseFootSteps = 2
ENT.FootStepTime = 0.3
ENT.Bone1 = "mixamorig:RightFoot"
ENT.Bone2 = "mixamorig:LeftFoot"
ENT.Speed = 290
ENT.WalkSpeedAnimation = 1
ENT.FlinchSpeed = 0

ENT.health = 80
ENT.Damage = 15

ENT.PhysForce = 15000
ENT.AttackRange = 90
ENT.InitialAttackRange = 80
ENT.DoorAttackRange = 50

ENT.NextAttack = 0.4

ENT.AttackFinishTime = 0.5 --how long it takes for an attack to finish

ENT.wanderType = 3

--Model Settings--
ENT.Model = "models/zombie/dog.mdl"
-- ENT.BoneMergeModel = "models/player/slow/amberlyn/re5/uroboro/slow_public.mdl"

ENT.AttackAnim = "attack"

ENT.WalkAnim = "crawl"
ENT.IdleAnim = "idle01"


ENT.AttackDoorAnim = "attack"

--Sounds--

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"dalrp/npc/dog/dogbite1.wav",
	"dalrp/npc/dog/dogbite2.wav"
}

ENT.alertSounds = {
	"dalrp/npc/dog/dogalert.wav",
	"dalrp/npc/dog/dogalert2.wav"
}

ENT.deathSounds = {
	"dalrp/npc/dog/dogdie1.wav",
	"dalrp/npc/dog/dogdie2.wav"
}

ENT.idleSounds = ENT.deathSounds

ENT.painSounds = {
	"dalrp/npc/dog/dogpain1.wav",
	"dalrp/npc/dog/dogpain2.wav",
	"dalrp/npc/dog/dogpain3.wav"
}

ENT.hitSounds = {
	"npc/infected_zombies/hit_punch_01.wav",
	"npc/infected_zombies/hit_punch_02.wav",
	"npc/infected_zombies/hit_punch_03.wav",
	"npc/infected_zombies/hit_punch_04.wav",
	"npc/infected_zombies/hit_punch_05.wav",
	"npc/infected_zombies/hit_punch_06.wav",
	"npc/infected_zombies/hit_punch_07.wav",
	"npc/infected_zombies/hit_punch_08.wav",
}

ENT.missSounds = {
	"npc/infected_zombies/claw_miss_1.wav",
	"npc/infected_zombies/claw_miss_2.wav",
}

function ENT:Initialize()
	if SERVER then

	--Stats--
	self:SetModel(self.Model)
	self:SetHealth(self.health)	
	
	self.loco:SetStepHeight(20)
	self.loco:SetAcceleration(900)
	self.loco:SetDeceleration(900)

	self:PhysicsInitShadow(true, false)
	   
	--Misc--
	self:Precache()
	
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	end
end

function ENT:CustomDeath( dmginfo )
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	
	if (math.random(1,4) == 1) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end	

	self:TransformRagdoll(dmginfo)
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
			
		if hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG then
			dmginfo:ScaleDamage(0.5)
		end
		
		if hitgroup == HITGROUP_HEAD then
			dmginfo:ScaleDamage(0.9)
		end
	end
end

function ENT:HitSound()
	local sound = self.hitSounds[ math.random( #self.hitSounds ) ]
	self:EmitSound(sound, 75, math.random(85,105))
end

function ENT:FootSteps()
	self:EmitSound("npc/demon/nhdemon_foot"..math.random(4)..".wav", 70)
end