AddCSLuaFile();

list.Set( "NPC", "resp_chimera", {
	Name = "Chimera",
	Class = "resp_chimera",
	Category = "Respite"
} )

ENT.classname = "resp_chimera"
ENT.Base = "chance_base";
ENT.Spawnable        = false
ENT.AdminSpawnable   = false
ENT.CorpseFadeTime = 120
ENT.CollisionSide = 10
ENT.CollisionHeight = 70
ENT.Model = "models/ninja/signalvariance/monsters/chimera.mdl"
ENT.MoveType = 2
ENT.WalkSpeedAnimation = 1.0
ENT.AttackRange = 80
ENT.InitialAttackRange = 75
ENT.UseFootSteps = 2
ENT.FootStepTime = 0.2

ENT.Speed = 100
ENT.health = 150
ENT.Damage = 10

ENT.pitch = 140
ENT.pitchVar = 20

ENT.AttackFinishTime = 0.5

ENT.AttackAnim = ACT_MELEE_ATTACK1
ENT.IdleAnim = "idle"
ENT.IdleAnims = {
	"idle",
	"frustration",
	"distractidle2",
	"distractidle3",
	"distractidle4"
}
ENT.WalkAnim = "walk_all"

--sounds
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.alertSounds = { 
	"monsters/nosach/nosach_stancia_0.mp3",
	"monsters/nosach/nosach_voice_2.mp3",
	"monsters/nosach/nosach_samec/nosach_t3_attack_1.mp3",
	"monsters/nosach/nosach_samec/nosach_t3_attack_3.mp3",
	"monsters/nosach/nosach_samec/nosach_t3_attack_2.mp3",
	"monsters/nosach/nosach_samec/nos_male_attack_1.mp3",
	"monsters/nosach/nosach_samec/nos_male_attack_2.mp3",
	"monsters/nosach/nosach_samec/nos_male_attack_3.mp3"
}

ENT.attackSounds = { 
	"monsters/nosach/nosach_samec/nos_male_attack_1.mp3",
	"monsters/nosach/nosach_samec/nos_male_attack_2.mp3",
	"monsters/nosach/nosach_samec/nos_male_attack_3.mp3",
	"monsters/nosach/nosach_samec/nosach_t3_attack_1.mp3",
	"monsters/nosach/nosach_samec/nosach_t3_attack_3.mp3",
	"monsters/nosach/nosach_samec/nosach_t3_attack_2.mp3",
	"monsters/nosach/nosach_samec/nosach_t4_attack_1.mp3",
	"monsters/nosach/nosach_samec/nosach_t4_attack_2.mp3",
	"monsters/nosach/nosach_samec/nosach_t5_attack_1.mp3",
	"monsters/nosach/nosach_samec/nosach_t5_attack_2.mp3",
	"monsters/nosach/nosach_samec/nosach_t5_attack_3.mp3"
}

ENT.idleSounds = { 
	"monsters/nosach/nosach_voice_0.mp3",
	"monsters/nosach/nosach_voice_1.mp3",
	"monsters/nosach/nosach_voice_2.mp3",
	"monsters/nosach/voice_nosach_0.mp3",
	"monsters/nosach/voice_nosach_1.mp3",
	"monsters/nosach/voice_nosach_2.mp3",
	"monsters/nosach/voice_nosach_3.mp3",
	"monsters/nosach/voice_nosach_4.mp3",
	"monsters/nosach/nosach_samec/nos_idle_food_0.mp3",
	"monsters/nosach/nosach_samec/nos_idle_food_1.mp3",
	"monsters/nosach/nosach_samec/nos_idle_food_2.mp3",
	"monsters/nosach/nosach_samec/nos_idle_food_up.mp3",
	"monsters/nosach/nosach_samec/nos_idle_food_up_back.mp3",
	"monsters/nosach/nosach_samec/nos_idle_food_up_left_gav.mp3",
	"monsters/nosach/nosach_samec/nos_idle_food_up_left.mp3",
	"monsters/nosach/nosach_samec/nos_idle_food_up_right.mp3"
}

ENT.deathSounds = { 
	"monsters/nosach/nosach_die_0.mp3",
	"monsters/nosach/nosach_die_1.mp3",
	"monsters/nosach/nosach_samec/nosach_t4_death_1.mp3",
	"monsters/nosach/nosach_samec/nosach_t4_death_2.mp3",
	"monsters/nosach/nosach_samec/nosach_t4_death_3.mp3",
	"monsters/nosach/nosach_samec/nosach_t5_death_1.mp3",
	"monsters/nosach/nosach_samec/nosach_t5_death_2.mp3",
}

ENT.painSounds = { 
	"monsters/nosach/nosach_hit_1.mp3",
	"monsters/nosach/nosach_samec/nosach_t3_hit_1.mp3",
	"monsters/nosach/nosach_samec/nosach_t3_hit_2.mp3",
	"monsters/nosach/nosach_samec/nosach_t3_hit_3.mp3",
	"monsters/nosach/nosach_samec/nosach_t4_hit_1.mp3",
	"monsters/nosach/nosach_samec/nosach_t4_hit_2.mp3",
	"monsters/nosach/nosach_samec/nosach_t4_hit_3.mp3",
	"monsters/nosach/nosach_samec/nosach_t5_hit_1.mp3",
	"monsters/nosach/nosach_samec/nosach_t5_hit_2.mp3",
	"monsters/nosach/nosach_samec/nosach_t5_hit_3.mp3",
	"monsters/nosach/nosach_samec/nosach_t5_hit_4.mp3"
}

ENT.missSounds = { 
	"npc/zombie/claw_miss1.wav"
}

ENT.hitSounds = { 
	"hits/bullet_monster_rv2_1.mp3",
	"hits/bullet_monster_rv2_2.mp3",
	"hits/bullet_monster_rv2_3.mp3",
	"hits/bullet_monster_rv2_4.mp3",
	"hits/bullet_monster_rv2_5.mp3"
}

function ENT:Precache()

	util.PrecacheModel(self.Model)

end

function ENT:Initialize()
	if( SERVER ) then 
	
		self:Precache()
		self.loco:SetStepHeight( 40 )
		self.loco:SetAcceleration( 500 )
		self.loco:SetDeceleration( 300 )
		self.loco:SetJumpHeight( 35 )
	
	end
	self.IdleAnim = table.Random(self.IdleAnims)
	
	self:SetHealth( self.health )	
	
	local color = Color( 150, 100, 100, 255 )
	
	self:SetColor( color )
	self:SetModel( self.Model )
	
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	
	self:PhysicsInitShadow( true, true )

	self.PlayerPositions = { };
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,1) == 1) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end	
	if (math.random(0,4) == 4) then
		nut.item.spawn("hl2_m_monstertalon", self:GetPos()+ Vector(0,0,20))
	end
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	self:TransformRagdoll( dmginfo )
end

function ENT:FootSteps()
	self:EmitSound("footsteps/medium_concrete_"..math.random(1, 7)..".mp3", 65)
end

--get mad
function ENT:Enrage()
	self.Speed = 250
	if(math.random(1) == 1) then
		self.WalkAnim = "run_all"
	else
		self.WalkAnim = "runagitated"
	end
	self.wanderType = 1
	self.FootStepTime = 0.2
end

function ENT:OnAlert()
	self:Enrage()
end