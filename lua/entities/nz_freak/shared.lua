if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = true
ENT.AdminSpawnable   = true

--SpawnMenu--
list.Set( "NPC", "nz_freak", {
	Name = "Waste",
	Class = "nz_freak",
	Category = "Respite"
} )

--Stats--
ENT.FootAngles = 3
ENT.FootAngles2 = 3
ENT.CollisionHeight = 80
ENT.CollisionSide = 15
ENT.MoveType = 2
ENT.UseFootSteps = 1
ENT.Bone1 = "mixamorig:RightFoot"
ENT.Bone2 = "mixamorig:LeftFoot"
ENT.Speed = 33
ENT.WalkSpeedAnimation = 1
ENT.FlinchSpeed = 0

ENT.health = 150
ENT.Damage = 8

ENT.PhysForce = 15000
ENT.AttackRange = 55
ENT.InitialAttackRange = 40
ENT.DoorAttackRange = 40

ENT.NextAttack = 0.4

ENT.AttackFinishTime = 0.8 --how long it takes for an attack to finish

ENT.wanderType = 3
ENT.idleTime = 10

--Model Settings--
ENT.Model = "models/prosperity/freak.mdl"
-- ENT.BoneMergeModel = "models/player/slow/amberlyn/re5/uroboro/slow_public.mdl"

ENT.AttackAnim = (ACT_MELEE_ATTACK1)

ENT.WalkAnim = "walk01"
ENT.IdleAnim = "idle01"

ENT.FlinchAnim = (ACT_SMALL_FLINCH)

ENT.AttackDoorAnim = (ACT_RANGE_ATTACK2)

--Sounds--

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"dalrp/npc/freak/zombie_alert3.wav",
	"dalrp/npc/freak/zo_attack1.wav",
	"dalrp/npc/freak/zo_attack2.wav",
	"dalrp/npc/babu/alert2.wav"
}

ENT.alertSounds = {
	"dalrp/npc/freak/zombie_alert3.wav",
	"dalrp/npc/freak/zo_attack1.wav",
	"dalrp/npc/babu/alert2.wav",
	"deadzone/lepotitsa/alert4.wav"
}

ENT.deathSounds = {
	"deadzone/lepotitsa/death1.wav",
	"deadzone/lepotitsa/death2.wav",
	"deadzone/lepotitsa/death3.wav",
	"deadzone/lepotitsa/death4.wav",
}

ENT.idleSounds = {
	"npc/freshdead/male/alert_no_enemy1.wav",
	"npc/freshdead/male/alert_no_enemy2.wav",
	"npc/freshdead/male/pain2.wav",
	"npc/freshdead/male/pain4.wav",
}

ENT.painSounds = {
	"deadzone/lepotitsa/pain1.wav",
	"deadzone/lepotitsa/pain2.wav",
	"deadzone/lepotitsa/pain3.wav",
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
	self.loco:SetAcceleration(300)
	self.loco:SetDeceleration(600)

	self:PhysicsInitShadow(true, false)
	   
	--Misc--
    self:Switch()
	self:Precache()
	
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	end
end

function ENT:SelectAnim()
	local anim = math.random(1,4)
	if anim == 1 then
		self.WalkAnim = "walk01"
		self.IdleAnim = "idle02"
		self.Speed = 30
	elseif anim == 2 then
		self.WalkAnim = "walk02"
		self.IdleAnim = "idle01"
		self.Speed = 35
	elseif anim == 3 then
		self.WalkAnim = "crawl"
		self.Speed = 13
		self.wanderType = 4 --dont stop moving around
	elseif anim == 4 then
		self.WalkAnim = "crawl_run"
		self.Speed = 75
		self.wanderType = 4 --dont stop moving around
    end
end

function ENT:Switch()
	self:SelectAnim()
end

function ENT:CustomDeath( dmginfo )
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	
	if (math.random(0,4) == 4) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end	

	self:TransformRagdoll(dmginfo)
end

function ENT:CheckStatus()

	if self.Flinching then
		return false
	end
	
	return true

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
		    self:EmitSound("hits/headshot_"..math.random(9)..".wav", 70)
			dmginfo:ScaleDamage(10)
		end
		
	end

end

function ENT:HitSound()
	local sound = self.hitSounds[ math.random( #self.hitSounds ) ]
	self:EmitSound(sound, 75, math.random(85,105))
end