if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = true
ENT.AdminSpawnable   = true

--SpawnMenu--
list.Set( "NPC", "nz_hatred", {
	Name = "Hatred",
	Class = "nz_hatred",
	Category = "Respite"
} )

--Stats--
ENT.FootAngles = 3
ENT.FootAngles2 = 3
ENT.CollisionHeight = 80
ENT.CollisionSide = 7
ENT.MoveType = 2
ENT.UseFootSteps = 2
ENT.FootStepTime = 0.25
ENT.Bone1 = "mixamorig:RightFoot"
ENT.Bone2 = "mixamorig:LeftFoot"
ENT.Speed = 220
ENT.WalkSpeedAnimation = 1
ENT.FlinchSpeed = 0

ENT.health = 300
ENT.Damage = 10

ENT.PhysForce = 15000
ENT.AttackRange = 90
ENT.InitialAttackRange = 80
ENT.DoorAttackRange = 50

ENT.NextAttack = 0.4

ENT.AttackFinishTime = 0.4 --how long it takes for an attack to finish

ENT.pitch = 50

ENT.wanderType = 3

--Model Settings--
ENT.Model = "models/zombie/hatred.mdl"
-- ENT.BoneMergeModel = "models/player/slow/amberlyn/re5/uroboro/slow_public.mdl"

ENT.AttackAnim = "attacka"
ENT.AttackAnims = {
	"attacka",
	"attackb",
	"attackc"
}

ENT.WalkAnim = "a_walk2"
ENT.IdleAnim = "idle01"

ENT.AttackDoorAnim = "attacka"

--Sounds--

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"dalrp/npc/dog/dogbite1.wav",
	"dalrp/npc/dog/dogbite2.wav"
}

ENT.alertSounds = {
	"cof/taller/taller_alert.wav"
}

ENT.deathSounds = {
	"cof/taller/taller_die.wav"
}

ENT.idleSounds = ENT.deathSounds

ENT.painSounds = {
	"cof/taller/taller_pain.wav"
}

ENT.hitSounds = {
	"cof/taller/taller_player_impact.wav",
	"cof/taller/taller_player_punch.wav"
}

ENT.missSounds = {
	"cof/taller/taller_swing.wav"
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
	local anim = math.random(1,3)
	if anim == 1 then
		self.WalkAnim = "a_walk2"
		self.IdleAnim = "idle01"
	elseif anim == 2 then
		self.WalkAnim = "a_walk3"
		self.wanderType = 4 --dont stop moving around
	elseif anim == 3 then
		self.WalkAnim = "a_walk4"
		self.idleAnim = "idle02"
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

function ENT:FootSteps()
	self:EmitSound("cof/taller/taller_step.wav", 75)
end

function ENT:CustomAttack()
	self.AttackAnim = self.AttackAnims[ math.random( #self.AttackAnims ) ]
end
