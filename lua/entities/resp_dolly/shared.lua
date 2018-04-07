AddCSLuaFile();

list.Set( "NPC", "resp_dolly", {
	Name = "Dolly",
	Class = "resp_dolly",
	Category = "Respite"
} )

ENT.classname = "resp_dolly"
ENT.Base = "chance_base";
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

ENT.UseFootSteps = 2
ENT.FootStepTime = 0.2

ENT.CollisionSide = 15
ENT.CollisionHeight = 25

ENT.Model = "models/Zombie/2.mdl"
ENT.MoveType = 2
ENT.WalkSpeedAnimation = 1

ENT.Speed = 180
ENT.health = 20
ENT.Damage = 4

ENT.AttackRange = 60
ENT.InitialAttackRange = 50

ENT.NextAttack = 0.1

ENT.AttackFinishTime = 0.4

ENT.pitch = 150

ENT.AttackAnim = ACT_RANGE_ATTACK1
ENT.WalkAnim = "run1"
ENT.IdleAnim = "idle01"

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.idleSounds = {
	"monsters/nosach/voice_nosach_3.mp3",
	"monsters/nosach/voice_nosach_4.mp3" 
}

ENT.attackSounds = { 
	"monsters/nosach/nosach_samec/nosach_t5_attack_2.mp3",
	"monsters/nosach/nosach_samec/nosach_t5_attack_1.mp3"
}

ENT.deathSounds = {
	"hczombie/zombie_die1.wav",
	"hczombie/ropp.wav"
}

ENT.painSounds = {
	"hczombie/idle1.wav"
}

ENT.alertSounds = ENT.idleSounds
		
ENT.missSounds = {
	"hczombie/miss1.wav",
	"hczombie/miss2.wav"
}

ENT.hitSounds = { 
	"hits/bullet_monster_rv2_1.mp3",
	"hits/bullet_monster_rv2_2.mp3",
	"hits/bullet_monster_rv2_3.mp3",
	"hits/bullet_monster_rv2_4.mp3",
	"hits/bullet_monster_rv2_5.mp3"
}

function ENT:Initialize()
	
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
	
	self:SetModel(self.Model)
	self:SetCollisionGroup( COLLISION_GROUP_NPC )
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	
	self:PhysicsInitShadow(true, true)
end


function ENT:CustomDeath( dmginfo )
	if (math.random(1,5) == 1) then
		nut.item.spawn("j_scrap_plastics", self:GetPos()+ Vector(0,0,20))
	end

	self:TransformRagdoll(dmginfo)
end

function ENT:FootSteps()
	self:EmitSound("bgo/post_grenade_fleshy_debris_0"..math.random(1, 2)..".wav", 55)
end
