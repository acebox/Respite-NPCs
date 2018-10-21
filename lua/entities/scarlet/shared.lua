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

ENT.AttackFinishTime = 0.9

ENT.Summons = {}

ENT.wanderType = 1
ENT.pitch = 115
ENT.pitchVar = 15

--Model Settings--
ENT.Model = "models/spite/scarlet.mdl"

ENT.IdleAnim = "idle"
ENT.WalkAnim = "run"
ENT.AttackAnim = ACT_MELEE_ATTACK1



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
	
	self.Summons = {}
	
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

function ENT:FootSteps()
	self:EmitSound("monsters/suitor/metal_walk0"..math.random(1, 3)..".mp3", 85) 
end

function ENT:Summon( )
	posSummons = {
		"resp_dolly",
		"resp_babu",
		"resp_baby"
	}

	local ent = ents.Create(table.Random(posSummons))
		
	table.insert(self.Summons, ent)
		
	if ent:IsValid() and self:IsValid() then
		local pos = self:FindSpot( "random", { type = 'hiding', radius = 5000 } )
		if(!pos) then
			return
		end
		ent:SetPos(self:GetPos() + self:GetForward() * 50)
		ent:Spawn()
		ent:SetOwner( self )
	end
	
	self:IdleSound()
	self:IdleSound()
end

function ENT:OnAlert()
	for k, v in pairs(self.Summons) do
		if(v:IsValid()) then
			v:SetEnemy(self.Enemy)
		end
	end
end

function ENT:CustomThink()
	if((self.summonTime or 0) < CurTime() and table.Count(self.Summons) < 7 and !self:HaveEnemy()) then
		self:Summon() --summons npcs
		self.summonTime = CurTime() + 5
	end
end
	
function ENT:OnRemove()
	if(self:Health() > 0) then
		for k, v in pairs(self.Summons) do
			if(v:IsValid()) then
				v:Remove()
			end
		end
	else
		for k, v in pairs(self.Summons) do
			if(v:IsValid()) then
				v:TakeDamage(100, self, self)
			end
		end
	end
end