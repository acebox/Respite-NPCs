if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = true
ENT.AdminSpawnable   = true

--SpawnMenu--
list.Set( "NPC", "nz_roller", {
	Name = "Roller",
	Class = "nz_roller",
	Category = "Respite"
} )

--Stats--
ENT.FootAngles = 3
ENT.FootAngles2 = 3
ENT.CollisionHeight = 30
ENT.CollisionSide = 7
ENT.MoveType = 2
ENT.UseFootSteps = 0
ENT.Speed = 150
ENT.WalkSpeedAnimation = 1
ENT.FlinchSpeed = 0

ENT.health = 50
ENT.Damage = 5

ENT.PhysForce = 15000
ENT.AttackRange = 80
ENT.InitialAttackRange = 70
ENT.DoorAttackRange = 50

ENT.NextAttack = 0.4

ENT.AttackFinishTime = 0.5 --how long it takes for an attack to finish

ENT.pitch = 50

ENT.wanderType = 4

--Model Settings--
ENT.Model = "models/zombie/gurulo.mdl"
-- ENT.BoneMergeModel = "models/player/slow/amberlyn/re5/uroboro/slow_public.mdl"

ENT.AttackAnim = "attacka"
ENT.AttackAnims = {
	"attacka",
	"attackb",
	"attackc"
}

ENT.WalkAnim = "a_walk2"
ENT.IdleAnim = "idle"

ENT.AttackDoorAnim = "attacka"

--Sounds--

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"cof/faster/faster_attack.wav"
}

ENT.alertSounds = {
	"cof/faster/faster_alert1.wav",
	"cof/faster/faster_alert2.wav"
}

ENT.deathSounds = {
	"cof/faster/faster_death.wav"
}

ENT.idleSounds = ENT.alertSounds

ENT.painSounds = {
	"cof/faster/faster_pain.wav"
}

ENT.hitSounds = {
	"npc/infected_zombies/hit_punch_01.wav",
	"npc/infected_zombies/hit_punch_02.wav",
	"npc/infected_zombies/hit_punch_03.wav",
	"npc/infected_zombies/hit_punch_04.wav",
	"npc/infected_zombies/hit_punch_05.wav",
	"npc/infected_zombies/hit_punch_06.wav",
	"npc/infected_zombies/hit_punch_07.wav",
	"npc/infected_zombies/hit_punch_08.wav"
}

ENT.missSounds = {
	"cof/faster/faster_miss.wav"
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
	self:Switch()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	end
end

function ENT:SelectAnim()
	local anim = math.random(1,2)
	if anim == 1 then
		self.WalkAnim = "a_walk2"
	elseif anim == 2 then
		self.WalkAnim = "a_walk3"
    end
end

function ENT:Switch()
	self:SelectAnim()
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
			dmginfo:ScaleDamage(3)
		end
	end
end

function ENT:CustomAttack()
	self.AttackAnim = self.AttackAnims[ math.random( #self.AttackAnims ) ]
end
