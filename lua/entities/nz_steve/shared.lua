if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = true
ENT.AdminSpawnable   = true

--SpawnMenu--
list.Set( "NPC", "nz_steve", {
	Name = "Steve",
	Class = "nz_steve",
	Category = "Respite"
} )

--Stats--
ENT.FootAngles = 3
ENT.FootAngles2 = 3
ENT.CollisionHeight = 60
ENT.CollisionSide = 7
ENT.MoveType = 2
ENT.UseFootSteps = 0
ENT.Speed = 180
ENT.WalkSpeedAnimation = 1
ENT.FlinchSpeed = 0

ENT.health = 400
ENT.Damage = 8

ENT.PhysForce = 15000
ENT.AttackRange = 75
ENT.InitialAttackRange = 65
ENT.DoorAttackRange = 50

ENT.NextAttack = 0.4

ENT.AttackFinishTime = 0.25 --how long it takes for an attack to finish

ENT.pitch = 50
ENT.volume = 90

ENT.wanderType = 3

--Model Settings--
ENT.Model = "models/zombie/steve.mdl"
-- ENT.BoneMergeModel = "models/player/slow/amberlyn/re5/uroboro/slow_public.mdl"

ENT.AttackAnim = "attacka"

ENT.WalkAnim = "a_walk2"
ENT.IdleAnim = "idle01"

ENT.AttackDoorAnim = "attacka"

--Sounds--

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"cof/faceless/faceless_attack1.wav",
	"cof/faceless/faceless_attack2.wav"
}

ENT.alertSounds = {
	"cof/faceless/faceless_alert10.wav",
	"cof/faceless/faceless_alert20.wav",
	"cof/faceless/faceless_alert30.wav"
}

ENT.deathSounds = {
	"cof/faceless/faceless_pain1.wav",
	"cof/faceless/faceless_pain2.wav"
}

ENT.idleSounds = ENT.alertSounds

ENT.painSounds = {
	"cof/faceless/faceless_pain1.wav",
	"cof/faceless/faceless_pain2.wav"
}

ENT.hitSounds = {
	"cof/faceless/fist_strike1.wav",
	"cof/faceless/fist_strike2.wav",
	"cof/faceless/fist_strike3.wav"
}

ENT.missSounds = {
	"cof/faceless/fist_miss1.wav",
	"cof/faceless/fist_miss2.wav"
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
		self.IdleAnim = "idle01"
	elseif anim == 2 then
		self.IdleAnim = "idle02"
    end
end

function ENT:Switch()
	self:SelectAnim()
end

function ENT:CustomDeath( dmginfo )
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	
	if (math.random(1,2) == 1) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
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

function ENT:Enrage()
	self.wanderType = 4
end

function ENT:Calm() --unenrage
end

function ENT:OnAlert()
	self:Enrage()
end