if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_thrasher", {
	Name = "Thrasher",
	Class = "nz_thrasher",
	Category = "Respite"
} )

--Stats--
ENT.FootAngles = 10
ENT.FootAngles2 = 10
ENT.UseFootSteps = 1

ENT.CollisionHeight = 64
ENT.CollisionSide = 7

ENT.Speed = 125
ENT.WalkSpeedAnimation = 1
ENT.FlinchSpeed = 0

ENT.health = 150
ENT.Damage = 5

ENT.PhysForce = 15000
ENT.AttackRange = 90
ENT.DoorAttackRange = 50

ENT.NextAttack = 0.2
ENT.AttackFinishTime = 0.1

ENT.pitch = 50

ENT.wanderType = 2 --find corner and stand in it.

--Model Settings--
ENT.Model = "models/_maz_ter_/deadspace/deadspacenecros/twitcher.mdl"

ENT.AttackAnim = "twitcher_attack_01"
ENT.FleshTossAnim = (ACT_IDLE_ON_FIRE)

ENT.IdleAnim = (ACT_IDLE)

ENT.WalkAnim = (ACT_WALK)

--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"respite/thrasher/exploder_alrt_04.wav",
	"respite/thrasher/exploder_alrt_02.wav",
	"respite/thrasher/exploder_alrt_00.wav"
}

ENT.alertSounds = {
	"respite/thrasher/exploder_alrt_04.wav",
	"respite/thrasher/exploder_alrt_02.wav",
	"respite/thrasher/exploder_alrt_00.wav"
}

ENT.deathSounds = {
	"respite/thrasher/exploder_death_03.wav"
}

ENT.idleSounds = {
}

ENT.painSounds = {
  "respite/thrasher/exploder_hurt_04.wav",
  "respite/thrasher/exploder_hurt_02.wav"
}

ENT.hitSounds = {
  "respite/thrasher/hit.wav"
}

ENT.missSounds = {
	"npc/demon/nhdemon_claw_miss1.wav"
}

--ENT.RenderGroup and the rendermode allow transparency. Right now just distort is onto make it twitchier
--ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	if SERVER then
	
	--Stats--
	self:SetModel(self.Model)
	self:SetMaterial("models/flesh")
	--self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderFX(kRenderFxDistort)
	self:SetColor(Color(150,150,150,255))
	
	self:SetHealth(self.health)	

	self.IsAttacking = false

	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(1200)
	self.loco:SetDeceleration(1200)
	
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	self:StartActivity(ACT_WALK)
	end
	
end

--called when the npc is chasing a target
function ENT:CustomChaseEnemy()
	if(!self.Enemy) then 
		self.Speed = 100
	
		self.MoveType = 1
		self.WalkAnim = ACT_WALK
	
		return 
	end
	
	if(!self.nextRefresh) then self.nextRefresh = 0 end
	
	if(self:GetRangeSquaredTo(self.Enemy:GetPos()) < 100000) then	--attacking
		if(self.WalkAnim == ACT_WALK) then
			self:StartActivity(2214) --makes it get up
			self.WalkAnim = ACT_RUN
			self:delay(0.245, self:ResumeMovementFunctions())
		end	
	
		self.Speed = 160
	
		self.MoveType = 2
		self.WalkAnim = "twitcher_attack_01"
		self:ResumeMovementFunctions()
		
		self:Flail()
	elseif(self:GetRangeSquaredTo(self.Enemy:GetPos()) < 400000) then --walking nearby
		if(self.WalkAnim == ACT_WALK) then
			self:StartActivity(2214) --had to use the numbers because ACT_LAY and ACT_LAY1 werent working
			self.WalkAnim = ACT_RUN
			self:delay(0.245, self:ResumeMovementFunctions())
		end
	
		self.Speed = 175

		self.MoveType = 1
		self.WalkAnim = ACT_RUN
		if(CurTime() > self.nextRefresh) then
			self:ResumeMovementFunctions()
			
			self.nextRefresh = CurTime() + 1
		end
	else --walking (crawling) far away.
		if(self.WalkAnim != ACT_WALK) then
			self:StartActivity(2213) --lay down
			
			self.WalkAnim = ACT_WALK
			self:delay(0.245, self:ResumeMovementFunctions())
		end	
	
		self.Speed = 200
	
		self.MoveType = 1
		self.WalkAnim = ACT_WALK
		
		if(CurTime() > self.nextRefresh) then
			self:ResumeMovementFunctions()
			
			self.nextRefresh = CurTime() + 1
		end
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

function ENT:Flail()
	if(!self.nextFlail) then self.nextFlail = CurTime() end
	
	if(CurTime() > self.nextFlail) then
		self:AttackEffect( 0.1, self.Enemy, self.Damage/2, 0, 1)
		
		local temp = function() 
			self:AttackEffect( 0.1, self.Enemy, self.Damage/2, 0, 1)
		end
		self:delay(0.25, temp)
		
		self.nextFlail = CurTime() + 0.6
	end
end

--main attack function. Plays animation, damage handled in AttackEffect
function ENT:Attack()
	if ( self.NextAttackTimer or 0 ) < CurTime() then	
		self.NextAttackTimer = CurTime() + self.NextAttack
		
		--self:AttackEffect( self.AttackFinishTime, self.Enemy, self.Damage/2, 0, 1)
		--self:AttackEffect( self.AttackFinishTime*2, self.Enemy, self.Damage/2, 0, 1)
	end
end

function ENT:OnAlert()
	self:Enrage()
end