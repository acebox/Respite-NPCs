if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_demon", {
	Name = "Demon",
	Class = "nz_demon",
	Category = "Respite"
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

ENT.health = 50
ENT.Damage = 5

ENT.PhysForce = 15000
ENT.AttackRange = 55
ENT.DoorAttackRange = 25

ENT.NextAttack = 1
ENT.AttackFinishTime = 0.1

ENT.pitch = 85

--Model Settings--
ENT.Model = "models/nh2zombies/friendly.mdl"

ENT.AttackAnim = (ACT_MELEE_ATTACK1)
ENT.FleshTossAnim = (ACT_IDLE_ON_FIRE)

ENT.IdleAnim = (ACT_IDLE)

ENT.WalkAnim = (ACT_WALK)

--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"npc/demon/nhdemon_fz_frenzy1.wav",
	"npc/demon/nhdemon_fz_alert_close1.wav"
}

ENT.alertSounds = {
	"npc/demon/nhdemon_fz_alert_close1.wav",
	"npc/demon/nhdemon_fz_alert_far1.wav",
	"npc/demon/nhdemon_fz_frenzy1.wav",
	"npc/demon/nhdemon_fz_scream1.wav"
}

ENT.deathSounds = {
	"npc/demon/nhdemon_fz_frenzy1.wav"
}

ENT.idleSounds = {
	"npc/demon/nhdemon_idle1.wav",
	"npc/demon/nhdemon_idle2.wav",
	"npc/demon/nhdemon_idle3.wav"
}

ENT.painSounds = {
	"npc/demon/nhdemon_fz_frenzy1.wav"
}

ENT.hitSounds = {
	"npc/demon/nhdemon_claw_strike3.wav"
}

ENT.missSounds = {
	"npc/demon/nhdemon_claw_miss1.wav"
}

function ENT:Initialize()

	if SERVER then

	--Stats--
	self:SetModel(self.Model)

	self:SetHealth(self.health)	

	self.IsAttacking = false

	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(900)
	self.loco:SetDeceleration(900)
	
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	self:StartActivity(ACT_WALK)
	end
	
end

function ENT:CustomDeath( dmginfo )
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	if (math.random(0,4) == 4) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end
	if (math.random(0,4) == 4) then
		nut.item.spawn("hl2_m_monstertalon", self:GetPos()+ Vector(0,0,20))
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
	self:EmitSound("npc/demon/nhdemon_foot"..math.random(4)..".wav", 70)
end

function ENT:RangeAttack( ent )
	
	if !self:CheckStatus() then return end

   self:RestartGesture(self.FleshTossAnim)
	self.loco:SetDesiredSpeed( 0)
	
	timer.Simple( 0.3, function()
		if !self:IsValid() then return end
		if self:Health() < 0 then return end
		if !self:CheckStatus() then return end
		
		self.loco:SetDesiredSpeed( 0 )
		self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 72, math.Rand(85, 95))	

		for i=1,12 do
			local flesh = ents.Create("nz_projectile_blood") 
			if flesh:IsValid() then
			flesh:SetPos( self:GetPos() + Vector(0,5,50) )
			flesh:SetOwner(self)
			flesh:Spawn()
		
				local phys = flesh:GetPhysicsObject()
				if phys:IsValid() then
				local ang = self:EyeAngles()
					ang:RotateAroundAxis(ang:Forward(), math.Rand(-30, 30))
					ang:RotateAroundAxis(ang:Up(), math.Rand(-30, 30))
					phys:SetVelocityInstantaneous(ang:Forward() * math.Rand(650, 1180))
				end
			end
		end
	end)
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
		
			local attack = math.random(1,2)
			if attack == 1 then self:MeleeAttack( self.Enemy )
			elseif attack == 2 then self:RangeAttack( self.Enemy )
			end
		
		end
		
		self.NextAttackTimer = CurTime() + self.NextAttack
	end		
end

--get mad
function ENT:Enrage()
	self.Speed = 250
	self.WalkAnim = ACT_RUN
	self.wanderType = 1
end

function ENT:OnAlert()
	self:Enrage()
end