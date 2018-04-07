if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "resp_kuszo", {
	Name = "Ghoul",
	Class = "resp_kuszo",
	Category = "Respite"
} )

--Stats--
ENT.CollisionSide = 15
ENT.CollisionHeight = 25

ENT.UseFootSteps = 2
ENT.FootStepTime = 0.7

ENT.LoseTargetDist	= 4500	-- How far the enemy has to be before we lose them
ENT.SearchRadius 	= 3000	-- How far to search for enemies

ENT.AttackFinishTime = 0.25

ENT.Speed = 45
ENT.Damage = 5
ENT.health = 110

ENT.Model = "models/zombie/kuszo.mdl"

ENT.AttackAnim = "attackb"
ENT.WalkAnim = ACT_WALK
ENT.IdleAnim = "idle01"

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.alertSounds = {  
	"dalrp/npc/kuszo/alert1.wav", 
	"dalrp/npc/kuszo/alert2.wav"
}

ENT.attackSounds = { 
	"dalrp/npc/kuszo/hurt1.wav",
	"dalrp/npc/kuszo/hurt2.wav"
}

ENT.deathSounds = { 
	"dalrp/npc/kuszo/die1.wav", 
	"dalrp/npc/kuszo/die2.wav"
}

ENT.idleSounds = ENT.deathSounds

ENT.painSounds = { 
	"dalrp/npc/kuszo/hurt1.wav", 
	"dalrp/npc/kuszo/hurt2.wav"
}

ENT.missSounds = { 
	"dalrp/npc/kuszo/claw_miss1.wav",
	"dalrp/npc/kuszo/claw_miss2.wav"
}

ENT.hitSounds = { 
	"dalrp/npc/kuszo/claw_strike1.wav",
	"dalrp/npc/kuszo/claw_strike2.wav",
	"dalrp/npc/kuszo/claw_strike3.wav"
}

function ENT:Initialize()
	if ( SERVER ) then
		self:Precache()
		self.loco:SetStepHeight(30)
		self.loco:SetAcceleration(400)
		self.loco:SetDeceleration(400)
	end
	
	self:SetHealth( self.health )	
	self:SetModel( self.Model )
	
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
end

function ENT:FootSteps()
	self:EmitSound("dalrp/npc/kuszo/foot"..math.random(1,4)..".wav", 55)
end

ENT.nextPrint = CurTime() + 20

function ENT:CustomThink()
	if(self.nextPrint < CurTime()) then
		util.Decal("BloodHandprint"..math.random(1,2), self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
		self.nextPrint = CurTime() + math.random(10,20)
	end
end

function ENT:CustomDeath()
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	
	if (math.random(1,4) == 1) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end		
	
    self:TransformRagdoll( )
end

--get mad
function ENT:Enrage()
	self.Speed = 170
	self.WalkSpeedAnimation = 1.25
	self.wanderType = 2
	self.FootStepTime = 0.3
end

function ENT:OnAlert()
	self:Enrage()
end