if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_horror_red", {
	Name = "Red Horror",
	Class = "nz_horror_red",
	Category = "Respite - Wraith"
} )

--Stats--
ENT.FootAngles = 10
ENT.FootAngles2 = 10
ENT.UseFootSteps = 1

ENT.CollisionHeight = 64
ENT.CollisionSide = 7

ENT.Speed = 50
ENT.WalkSpeedAnimation = 1
ENT.FlinchSpeed = 0

ENT.health = 25
ENT.Damage = 3

ENT.PhysForce = 15000
ENT.AttackRange = 55
ENT.DoorAttackRange = 25

ENT.NextAttack = 0.1
ENT.AttackFinishTime = 0.1

ENT.pitch = 150

ENT.SearchRadius = 500

--Model Settings--
ENT.Model = "models/horror/zm_f4zt.mdl"

ENT.AttackAnim = (ACT_MELEE_ATTACK1)
ENT.FleshTossAnim = (ACT_IDLE_ON_FIRE)

ENT.IdleAnim = (ACT_IDLE)

ENT.WalkAnim = (ACT_WALK)

--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"horror/alert_far1.wav",
	"horror/alert_far1.wav",
	"horror/alert_far1.wav"
}

ENT.alertSounds = {
	"horror/fz_frenzy1.wav",
	"horror/fz_frenzy2.wav",
	"horror/fz_frenzy3.wav",
	"horror/fz_frenzy4.wav",
	"horror/fz_frenzy5.wav",
	"horror/fz_frenzy6.wav",
	"horror/fz_frenzy7.wav"
}

ENT.deathSounds = {
	"horror/die1.wav",
	"horror/die2.wav",
	"horror/die3.wav",
	"horror/die4.wav"
}

ENT.idleSounds = {
	"horror/idle1.wav",
	"horror/idle2.wav",
	"horror/idle3.wav",
	"horror/screech.wav"
}

ENT.painSounds = {
	"horror/pain1.wav",
	"horror/pain2.wav",
	"horror/pain3.wav",
	"horror/pain4.wav"
}

ENT.hitSounds = {
	"horror/warp1.wav",
	"horror/warp2.wav",
	"horror/warp3.wav"
}

ENT.missSounds = {
	"horror/claw_miss1.wav",
	"horror/claw_miss2.wav"
}

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderFX(kRenderFxDistort)
	
	if SERVER then
		--Stats--
		self:SetModel(self.Model)
		self:SetMaterial("models/effects/splode1_sheet")
		self:SetColor(Color(255,93,0))
		
		self:SetHealth(self.health)	

		self.IsAttacking = false

		self.loco:SetStepHeight(35)
		self.loco:SetAcceleration(1800)
		self.loco:SetDeceleration(1800)
		
		self.loco:SetJumpHeight(90)
		
		--Misc--
		self:Precache()
		self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
		self:StartActivity(ACT_WALK)
	end
	
end

--called when the npc is chasing a target
function ENT:CustomChaseEnemy()
	if(!self.nextJump) then self.nextJump = CurTime() end
	
	if(self.nextJump < CurTime()) then
		self.loco:SetAcceleration(2000)
		self.loco:SetDesiredSpeed(1000)
		
		local temp = function()
			self.loco:Jump()
			
			self.loco:SetAcceleration(1800)
			self.loco:SetDesiredSpeed(self.Speed)
			
			self:ResumeMovementFunctions()
		end
		
		self:delay(0.3, temp)
		
		self.nextJump = self.nextJump + math.random(10,15)
	end
end

function ENT:CustomDeath( dmginfo )
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	if (math.random(0,4) == 4) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end
	self:TransformRagdoll( dmginfo )
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
			
		if hitgroup == HITGROUP_CHEST or HITGROUP_GEAR or HITGROUP_STOMACH then
			dmginfo:ScaleDamage(0.50)
		elseif hitgroup == HITGROUP_HEAD then
			dmginfo:ScaleDamage(7)
		end
	end
end

function ENT:FootSteps()
	self:EmitSound("horror/foot"..math.random(4)..".wav", 70)
end

function ENT:MeleeAttack( ent )
	if !self:CheckStatus() then return end

	self:RestartGesture( self.AttackAnim )
	
	self:AttackEffect( 0.1, self.Enemy, self.Damage, 0 )
end

function ENT:Attack()
	if ( self.NextAttackTimer or 0 ) < CurTime() then	
		
		if ( (self.Enemy:IsValid() and self.Enemy:Health() > 0 ) ) then
		
			if !self:CheckStatus() then return end	
		
			self:AttackSound()

			self:MeleeAttack( self.Enemy )
		end
		
		self.NextAttackTimer = CurTime() + self.NextAttack
	end		
end

function ENT:CustomThinkClient()
	if CLIENT then
		local pos = self:GetPos() + self:GetUp()
		local dlight = DynamicLight(self:EntIndex())
		dlight.Pos = pos
		dlight.r = 64
		dlight.g = 0
		dlight.b = 0
		dlight.Brightness = 1
		dlight.Size = 64
		dlight.Decay = 128
		dlight.style = 5
		dlight.DieTime = CurTime() + .1
	end
end

--get mad
function ENT:Enrage()
	self.Speed = 750
	self.WalkAnim = ACT_RUN
	self.wanderType = 1
	self.SearchRadius = 2000
end

function ENT:OnAlert()
	self:Enrage()
end