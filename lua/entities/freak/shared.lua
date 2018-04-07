if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "freak", {
	Name = "Deformed",
	Class = "freak",
	Category = "Respite"
} )

ENT.classname = "freak"
ENT.NiceName = "Deformed"

--Stats--
ENT.MoveType = 3

ENT.UseFootSteps = 1

ENT.FootAngles = 15
ENT.FootAngles2 = 45

ENT.Bone1 = "mixamorig:RightFoot"
ENT.Bone2 = "mixamorig:LeftFoot"

ENT.CollisionHeight = 70
ENT.CollisionSide = 11

ENT.Speed = 15
ENT.WalkSpeedAnimation = 1.0

ENT.health = 200
ENT.Damage = 5

ENT.PhysForce = 30000
ENT.AttackRange = 75
ENT.InitialAttackRange = 70
ENT.DoorAttackRange = 25

ENT.NextAttack = 0.3

ENT.AttackFinishTime = 0.5

ENT.pitch = 50
ENT.wanderType = 2

--Model Settings--
ENT.Model1 = "models/spite/freak01.mdl"
ENT.Model2 = "models/spite/freak02.mdl"
ENT.Model3 = "models/spite/freak03.mdl"
ENT.Model4 = "models/spite/freak04.mdl"

ENT.models = {
	"models/spite/freak01.mdl",
	"models/spite/freak02.mdl",
	"models/spite/freak03.mdl",
	"models/spite/freak04.mdl"
}

ENT.WalkAnim = "walk"

ENT.IdleAnim = "idle"
ENT.AttackAnim = "attack"


--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"deadzone/lepotitsa/pain1.wav",
	"respite/scare20.wav"
}

ENT.alertSounds = {
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
	"npc/infected/zombie_voice_idle3.wav",
	"npc/infected/zombie_voice_idle4.wav",
	"npc/infected/zombie_voice_idle5.wav",
	"npc/infected/zombie_voice_idle6.wav",
	"npc/infected/zombie_voice_idle7.wav",
	"npc/infected/zombie_voice_idle8.wav"
}

ENT.painSounds = {
	"soma/npc_soma_proxy/hunt_04.wav",
	"soma/npc_soma_proxy/hunt_06.wav",
	"soma/npc_soma_proxy/hunt_01.wav",
	"npc/infected/zombie_pain4.wav",
	"npc/infected/zombie_pain5.wav",
	"npc/infected/zombie_pain6.wav"
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
	
	local model = math.random(1,4)
	if model == 1 then 
		self:SetModel(self.models[1])
		self.Damage = 3
		self.health = 120
	elseif model == 2 then 
		self:SetModel(self.models[2])
		self.Damage = 5
		self.health = 200
	elseif model == 3 then 
		self:SetModel(self.models[3])
		self.Damage = 4
		self.health = 135
	elseif model == 4 then 
		self:SetModel(self.models[4])
		self.Damage = 4
		self.health = 160
	end

	self:SetHealth(self.health)	
	
	self.IsAttacking = false

	self:PhysicsInitShadow(true, true)
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(400)
	self.loco:SetDeceleration(900)
	
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	
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
	self:Enrage()
	
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
			dmginfo:ScaleDamage(6)
		end
	end
end


function ENT:FootSteps()
	self:EmitSound( 'monsters/suitor/metal_run0' .. math.random(1,3) .. '.mp3', 75, math.random(90, 115) )
end

--get mad
function ENT:Enrage()
	self.Speed = 200
	self.WalkAnim = "run"
	self.wanderType = 1
	self:ResumeMovementFunctions()
end

--look at the victim, approach location they were killed from
function ENT:BuddyKilled( victim, attacker )
	self:SetEnemy(attacker)
	self.OldPos = victim:GetPos()
	self.wanderType = 4
end

--called when another thing dies
function ENT:OnOtherKilled( victim, dmginfo )
	if(self:HaveEnemy()) then
		self:Enrage()
	else
		if (baseclass.Get(victim:GetClass()).Base == "chance_base") and victim != self then
			local attacker = dmginfo:GetAttacker()
			
			if(attacker:IsPlayer() or attacker:IsNPC()) then
				self:BuddyKilled(victim, attacker)
			end
		end
	end
end