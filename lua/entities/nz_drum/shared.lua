if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_drum", {
	Name = "Drum",
	Class = "nz_drum",
	Category = "Respite"
} )

ENT.Summons = {}

--Stats--
ENT.FootAngles = 10
ENT.FootAngles2 = 10

ENT.MoveType = 2

ENT.CollisionHeight = 64
ENT.CollisionSide = 7

ENT.ModelScale = 1.8 

ENT.Speed = 40
ENT.WalkSpeedAnimation = 0.75
ENT.FlinchSpeed = 10

ENT.health = 600
ENT.Damage = 45
ENT.HitPerDoor = 2

ENT.PhysForce = 100000
ENT.AttackRange = 120
ENT.InitialAttackRange = 110
ENT.DoorAttackRange = 100

ENT.NextAttack = 1.5

ENT.AttackFinishTime = 1

ENT.pitch = 55
ENT.wanderType = 4
ENT.Launches = true

--Model Settings--
ENT.Model = "models/zombie/zombineplayer.mdl"

ENT.WalkAnim = "zombie_walk_06"
ENT.AttackAnim = ACT_GMOD_GESTURE_RANGE_ZOMBIE 
ENT.IdleAnim = ACT_HL2MP_IDLE_ZOMBIE 

--Sounds--

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"npc/zombie_poison/pz_throw2.wav",
	"npc/zombie_poison/pz_throw3.wav"
}

ENT.deathSounds = {
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav",
	"npc/zombie_poison/pz_die1.wav"
}

ENT.alertSounds = {
	"npc/zombie_poison/pz_alert1.wav",
	"npc/zombie_poison/pz_alert2.wav",
	"hczombie/alert3.wav"
}

ENT.idleSounds = {
	"npc/fast_zombie/idle1.wav",
	"npc/fast_zombie/idle2.wav",
	"npc/fast_zombie/idle3.wav"
}

ENT.painSounds = {
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombine/pain3.wav"
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
	self:SetModel(self.Model)
	self:SetHealth(self.health)	
	self:SetModelScale( self.ModelScale, 0 )
	self:SetMaterial("models/flesh")
	
	self:SetColor( Color( 130, 220, 130, 255 ) )
	
	self.IsAttacking = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(600)
	self.loco:SetDeceleration(600)
	
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	self.Summons = {}
	
	end
end

function ENT:CustomDeath( dmginfo )
	nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))

	util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	
	self:TransformRagdoll()
end

function ENT:ThrowGrenade( velocity )
	local posSummons = {}
	posSummons[1] = "nz_thrower"
	posSummons[2] = "nz_freak"
	posSummons[3] = "spore"
	posSummons[4] = "freak"

	local ent = ents.Create(table.Random(posSummons))
	
	table.insert(self.Summons, ent)
	
	if ent:IsValid() and self:IsValid() then
		ent:SetPos(self:EyePos() + Vector(0,0,40) - ( self:GetRight() * 25 ) + ( self:GetForward() * 20 ) )
		ent:Spawn()
		ent:SetMaterial("models/flesh")
		ent:SetColor( Color( 130, 220, 130, 255 ) )
		ent:SetOwner( self )
		timer.Simple(0.5,
			function()
				ent:SetEnemy(self.Enemy)
			end
		)

		self:AttackSound()
		util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	end
	
end



function ENT:CustomChaseEnemy()
	local enemy = self:GetEnemy()
	
	if (!IsValid(enemy)) then return end
	if self.Attacking then return end
	
	if self:IsLineOfSightClear( enemy ) then
	
		if (table.Count(self.Summons) < 5 and self:GetRangeTo( enemy ) > self.InitialAttackRange and self:GetRangeTo( enemy ) < 1000) then
		
			if ( self.NextThrow or 0 ) < CurTime() then
				self:RestartGesture( ACT_GMOD_GESTURE_TAUNT_ZOMBIE )
				self.Throwing = true
	
				timer.Simple( 0.6, function()
					if !self:IsValid() then return end
					if self:Health() < 0 then return end
					if self.Attacking then return end
					self:ThrowGrenade( math.random(500, 600) )
					self.Throwing = false
				end)
			
				self.NextThrow = CurTime() + 15
			end
		end	
	end
end


function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()

	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
	
	if ( dmginfo:IsBulletDamage() ) then
		dmginfo:ScaleDamage(0.5)
	end
end

function ENT:FootSteps()
	if(math.random(1) == 1) then
		self:EmitSound("npc/zombie_poison/pz_left_foot1.wav", 75)
	else
		self:EmitSound("npc/zombie_poison/pz_right_foot1.wav", 75)
	end
end

function ENT:EnrageSound()
	local sounds = {}
		sounds[1] = (self.Enrage1)
		sounds[2] = (self.Enrage2)
		self:EmitSound( sounds[math.random(1,2)], 100, math.random(50,60)  )
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

function ENT:Attack()
	if ( self.NextAttackTimer or 0 ) < CurTime() then	
		if ( (self.Enemy:IsValid() and self.Enemy:Health() > 0 ) ) then
		
			self:AttackSound()
			self.IsAttacking = true
			self:RestartGesture(self.AttackAnim)
		
			self:AttackEffect( 0.9, self.Enemy, self.Damage, 0 )
		
		end
		
		self.NextAttackTimer = CurTime() + self.NextAttack
	end	
end

--called when a prop is being attacked
function ENT:CustomPropAttack( ent )
	if ( self.NextPropAttackTimer or 0 ) < CurTime() then
		self:AttackSound()
		self.loco:SetDeceleration(0)
		self.IsAttacking = true
		
		self:RestartGesture(self.AttackAnim)
		
		self:AttackEffect( self.AttackFinishTime, ent, self.Damage, 1, 1 )
		self.loco:SetDeceleration(900)
		
		self.NextPropAttackTimer = CurTime() + self.NextAttack
	end
end