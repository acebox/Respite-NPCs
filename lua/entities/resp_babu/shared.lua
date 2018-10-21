AddCSLuaFile();

list.Set( "NPC", "resp_babu", {
	Name = "Babu",
	Class = "resp_babu",
	Category = "Respite"
} )

ENT.classname = "resp_babu"
ENT.Base = "chance_base";
ENT.Spawnable        = false
ENT.AdminSpawnable   = false
ENT.CollisionSide = 10
ENT.CollisionHeight = 80
ENT.Model = "models/zombie/babu.mdl"
ENT.MoveType = 1
ENT.WalkSpeedAnimation = 1.0
ENT.AttackRange = 85
ENT.InitialAttackRange = 75

ENT.UseFootSteps = 2
ENT.FootStepTime = 0.6

ENT.Speed = 45
ENT.health = 180
ENT.Damage = 8
ENT.wanderType = 3

ENT.AttackFinishTime = 0.5

ENT.pitch = 95

ENT.AttackAnim = ACT_MELEE_ATTACK1
ENT.WalkAnim = ACT_WALK
ENT.IdleAnim = "idle01"

ENT.Summons = {}

--Sounds
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"babu/attack1.wav",
	"babu/attack2.wav"
}

ENT.deathSounds = {
	"babu/die1.wav",
	"babu/die2.wav"
}

ENT.alertSounds = {
	"babu/loop1.wav",
	"babu/loop2.wav"
}

ENT.idleSounds = {
	"babu/attack1.wav",
	"babu/attack2.wav"
}

ENT.painSounds = {
	"babu/pain1.wav",
	"babu/pain2.wav"
}

ENT.hitSounds = {
	"npc/zombie/claw_strike1.wav"
}

ENT.missSounds = {
	"babu/miss1.wav",
	"babu/miss2.wav"
}

function ENT:Initialize()
	if( SERVER ) then 
		self:SetBloodColor(DONT_BLEED)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:Precache()
		self.loco:SetStepHeight(35)
		self.loco:SetAcceleration(400)
		self.loco:SetDeceleration(400)
		self.loco:SetJumpHeight( 35 )
	end
	
	self:SetHealth(self.health)	
	self:SetModel(self.Model)
	
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	
	self:PhysicsInitShadow(true, true)
	
	self.WanderAttentionSpan = math.Rand( 3, 9 )
	self.ChaseAttentionSpan = math.Rand( 15, 25 )

	self.Flinching = false
	
	self.PlayerPositions = {}
	self.Summons = {}
end

function ENT:CustomDeath( dmginfo )
	for k, v in pairs(self.Summons) do
		if(v:IsValid()) then
			v:TakeDamage(500, self, self)
		end
	end
	
	if (math.random(0,1) == 1) then
		nut.item.spawn("j_scrap_plastics", self:GetPos()+ Vector(0,0,20))
	end
	
	self:TransformRagdoll()
end

function ENT:FootSteps()
	self:EmitSound("babu/foot"..math.random(1, 4)..".wav", 55)
end

function ENT:CustomChaseEnemy()
	local enemy = self:GetEnemy()
	
	if (!IsValid(enemy)) then return end
	if self.Attacking then return end
	
	if self:IsLineOfSightClear( enemy ) then
	
		if (table.Count(self.Summons) < 5 and self:GetRangeTo( enemy ) > self.InitialAttackRange and self:GetRangeTo( enemy ) < 600) then
		
			if ( self.NextThrow or 0 ) < CurTime() then
	
				self:RestartGesture( ACT_GMOD_GESTURE_TAUNT_ZOMBIE )
				self.Throwing = true
	
				timer.Simple( 0.6, function()
					if !self:IsValid() then return end
					if self:Health() < 0 then return end
					if self.Attacking then return end
					self:Summon()
					self.Throwing = false
				end)
			
				self.NextThrow = CurTime() + 15
			end
		end	
	end
end

function ENT:Summon()
	local posSummons = {
		"resp_dolly",
		"resp_baby"
	}

	local ent = ents.Create(table.Random(posSummons))
	
	table.insert(self.Summons, ent)
	
	if ent:IsValid() and self:IsValid() then
		ent:SetPos(self:EyePos() + Vector(0,0,15) - ( self:GetRight() * 25 ) + ( self:GetForward() * 10 ) )
		ent:Spawn()
		ent:SetOwner( self )
		timer.Simple(1,
			function()
				if(ent and ent:IsValid()) then
					ent:SetEnemy(self.Enemy)
				end
			end
		)

		local ang = self:EyeAngles()
		ang:RotateAroundAxis(ang:Forward(), math.Rand(-10, 10))
		ang:RotateAroundAxis(ang:Up(), math.Rand(-10, 10))

		self:EmitSound( "dalrp/npc/gemini/die1.wav", 80, 200)
	end
	
end

function ENT:OnRemove()
	for k, v in pairs(self.Summons) do
		if(v:IsValid()) then
			v:Remove()
		end
	end
end