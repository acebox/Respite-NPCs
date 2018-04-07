AddCSLuaFile();

list.Set( "NPC", "resp_baby", {
	Name = "Baby",
	Class = "resp_baby",
	Category = "Respite"
} )

ENT.classname = "resp_baby"
ENT.Base = "chance_base";
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

ENT.UseFootSteps = 2
ENT.FootStepTime = 0.4

ENT.CollisionSide = 15
ENT.CollisionHeight = 25
ENT.Model = "models/Zombie/zombibaba.mdl"
ENT.MoveType = 2
ENT.WalkSpeedAnimation = 1.0

ENT.Speed = 120
ENT.health = 15
ENT.Damage = 2

ENT.AttackRange = 55
ENT.InitialAttackRange = 50

ENT.AttackFinishTime = 0.5

ENT.pitch = 150
ENT.wanderType = 2

ENT.WalkAnim = ACT_WALK
ENT.AttackAnim = ACT_MELEE_ATTACK1
ENT.IdleAnim = "idle01"
ENT.IdleAnims = {
	"kes",
	"repulo",
	"idle01"
}

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.alertSounds = { 
	"baby/babyalert.wav", 
	"soma/npc_soma_proxy/spot_player_01.wav", 
	"soma/npc_soma_proxy/spot_player_02.wav",
	"soma/npc_soma_proxy/spot_player_03.wav",
	"soma/npc_soma_proxy/spot_player_04.wav",
	"soma/npc_soma_proxy/spot_player_05.wav",
	"soma/npc_soma_proxy/spot_player_06.wav" 
}

ENT.attackSounds = { 
	"baby/attack1.wav",
	"baby/attack2.wav",
	"soma/npc_soma_proxy/spot_player_02.wav",
	"soma/npc_soma_proxy/spot_player_05.wav",
	"soma/npc_soma_proxy/spot_player_06.wav" 
}

ENT.deathSounds = { 
	"baby/babydie.wav", 
	"baby/babydie2.wav", 
	"soma/npc_soma_proxy/hunt_04.wav", 
	"soma/npc_soma_proxy/hunt_05.wav", 
	"soma/npc_soma_proxy/hunt_06.wav"
}

ENT.idleSounds = { 
	"soma/npc_soma_proxy/idle_close_01.wav", 
	"soma/npc_soma_proxy/idle_close_02.wav", 
	"soma/npc_soma_proxy/idle_close_03.wav", 
	"soma/npc_soma_proxy/idle_close_04.wav", 
	"soma/npc_soma_proxy/idle_close_05.wav", 
	"soma/npc_soma_proxy/idle_close_06.wav", 
	"soma/npc_soma_proxy/idle_close_07.wav",
	"soma/npc_soma_proxy/idle_close_08.wav",
	"soma/npc_soma_proxy/idle_close_09.wav",
	"soma/npc_soma_proxy/idle_close_10.wav"
}

ENT.painSounds = { 
	"baby/baby_pain1.wav", 
	"soma/npc_soma_proxy/idle_close_09.wav", 
	"soma/npc_soma_proxy/idle_close_08.wav" 
}

ENT.missSounds = { 
	"baby/miss1.wav",
	"baby/miss2.wav"
}

ENT.hitSounds = { 
	"weapons/maniac_slash.wav"
}

function ENT:Initialize()
   	if math.random(1,2) == 1 then
		self.WalkAnim = "a_walk2"
		self.UseFootSteps = 0
	else
		self.WalkAnim = "a_walk3"
		self.FootStepTime = 0.25
	end
	
	self.IdleAnim = table.Random(self.IdleAnims)
	
	if( SERVER ) then 
		self:SetBloodColor(DONT_BLEED)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:Precache()
		self.loco:SetStepHeight(30)
		self.loco:SetAcceleration(400)
		self.loco:SetDeceleration(400)
		self.loco:SetJumpHeight( 30 )
	end
	
	self:SetHealth(self.health)	
	
	local color = Color( 75, 75, 75, 255 )
	
	-- self:SetColor(color)
	self:SetModel(self.Model)
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	
	self:PhysicsInitShadow(true, true)
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,5) == 5) then
		nut.item.spawn("j_scrap_plastics", self:GetPos()+ Vector(0,0,20))
	end	
	if (math.random(0,10) == 10) then
		nut.item.spawn("hl2_m_boneshiv", self:GetPos()+ Vector(0,0,20))
	end
	
	self:TransformRagdoll(dmginfo)
end

function ENT:FootSteps()
	self:EmitSound("babu/foot"..math.random(1, 4)..".wav", 65, 150)
end