AddCSLuaFile();

list.Set( "NPC", "resp_belmer", {
	Name = "Belmer",
	Class = "resp_belmer",
	Category = "Respite - Wraith"
} )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.classname = "resp_belmer"
ENT.Base = "chance_base";
ENT.Spawnable        = false
ENT.AdminSpawnable   = false
ENT.CollisionSide = 15
ENT.CollisionHeight = 85
ENT.Model = "models/chillax_sf2/silenthill/sh2/mannequin/mannequin.mdl"
ENT.MoveType = 1
ENT.WalkSpeedAnimation = 1
ENT.AttackRange = 80
ENT.InitialAttackRange = 70

ENT.UseFootSteps = 0
ENT.FootStepTime = 0

ENT.Speed = 0
ENT.health = nil
ENT.Damage = nil
ENT.wanderType = 3

ENT.AttackFinishTime = 0.6
ENT.NextAttack = 1

ENT.pitch = 100
ENT.wraith = true

ENT.AttackAnim = ACT_MELEE_ATTACK1
ENT.WalkAnim = nil
ENT.IdleAnim = ACT_IDLE

--Sounds
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"npc/strider/striderx_alert2.wav",
	"npc/strider/striderx_alert4.wav",
	"npc/strider/striderx_alert6.wav"	
}

ENT.deathSounds = {
	"npc/strider/striderx_pain8.wav"
}

ENT.alertSounds = {
	"npc/strider/striderx_pain8.wav"
}

ENT.idleSounds = {
	"npc/strider/creak3.wav",
	"npc/strider/creak2.wav"
}

ENT.painSounds = {
	"npc/strider/striderx_pain5.wav",
	"npc/strider/striderx_pain7.wav"
}

ENT.hitSounds = {
"respite/hit1.wav"
}

ENT.missSounds = {
"sh2/mannequin/mannequin_attack.wav"
}

-- sound.Add( {
	-- name = "static",
	-- channel = CHAN_AUTO,
	-- volume = 1.0,
	-- level = 65,
	-- pitch = { 80, 100 },
	-- sound = "sh2/shared/radio_static_light.wav"
-- } )


function ENT:Initialize()

	if( SERVER ) then 
		self:Precache()
		self.loco:SetStepHeight(35)
		self.loco:SetAcceleration(400)
		self.loco:SetDeceleration(400)
		self.loco:SetJumpHeight( 35 )
	end
	
	if math.random(0,1) == 1 then
	self.WalkAnim = ACT_RUN
	self.Speed = 220
	self.Damage = 3
	self.health = 130
	else
	self.WalkAnim = ACT_WALK
    self.Speed = 60
	self.Damage = 5
	self.health = 350
	end
	
	self:SetHealth(self.health)	
	self:SetModel(self.Model)
	
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	
	self:PhysicsInitShadow(true, true)
	
	self.WanderAttentionSpan = math.Rand( 3, 9 )
	self.ChaseAttentionSpan = math.Rand( 15, 25 )

	self.Flinching = false
	
	self.PlayerPositions = {}
end

function ENT:Shadow()
	self:SetBloodColor(DONT_BLEED)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderFX(kRenderFxDistort)
end

function ENT:OnSpawn()
	self:SetMaterial("models/props_lab/security_screens")
	self:Shadow()
end

function ENT:Flinch(dmginfo)
	if ( self.NextFlinch or 0 ) < CurTime() then	
	
		if !self:CheckValid( self ) then return end
		if self.Flinching then return end
	
		self:StartActivity( ACT_FLINCH_PHYSICS )
		self.loco:SetDesiredSpeed( 0 )
	    self:EmitSound("sh2/mannequin/mannequin_stun_01.wav")
		self.Flinching = true
	
		timer.Simple(1, function() 
			if !self:IsValid() then return end
			if self:Health() < 0 then return end
		
			self.loco:SetDesiredSpeed( self.Speed )	
		
			self.Flinching = false
			self:ResumeMovementFunctions()
		end)
		
		self.NextFlinch = CurTime() + 1
	end
end

function ENT:CustomThinkClient()
	if CLIENT then
		local pos = self:GetPos() + self:GetUp()
		local dlight = DynamicLight(self:EntIndex())
		dlight.Pos = pos
		dlight.r = 100
		dlight.g = 100
		dlight.b = 155
		dlight.Brightness = 1
		dlight.Size = 32
		dlight.Decay = 64
		dlight.style = 5
		dlight.DieTime = CurTime() + 1
	end
end


function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()

	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
	
	if(math.random(0,1) == 1) then
		self:Flinch(dmginfo)
	end
	
	local sound = self.painSounds[ math.random( #self.painSounds ) ]
	self:EmitSound(sound, 70, self.pitch)
	
end

function ENT:CustomDeath( dmginfo )

	if (math.random(0,2) == 2) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end
	
	local deathEffect = ents.Create("info_particle_system")
    deathEffect:SetKeyValue("effect_name", "striderbuster_break_lightning")
	deathEffect:SetParent(self)
	deathEffect:SetPos( self:GetPos() )
	deathEffect:Spawn()
	deathEffect:Activate()
	deathEffect:Fire("Start", "", 0)
	deathEffect:Fire("Kill", "", 3)
	
    SafeRemoveEntity(self)
	
end


function ENT:CheckProp( ent )
	return false
end
