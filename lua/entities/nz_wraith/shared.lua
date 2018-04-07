if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_wraith", {
	Name = "Wraith",
	Class = "nz_wraith",
	Category = "Respite - Wraith"
} )

--Stats--
ENT.FootAngles = 10
ENT.FootAngles2 = 10
ENT.UseFootSteps = 0

ENT.MoveType = 2

ENT.CollisionHeight = 64
ENT.CollisionSide = 7

ENT.Speed = 40
ENT.WalkSpeed = 50
ENT.WalkSpeedAnimation = 1
ENT.FlinchSpeed = 10

ENT.health = 100
ENT.Damage = 10
ENT.HitPerDoor = 5

ENT.PhysForce = 2000
ENT.AttackRange = 140
ENT.InitialAttackRange = 130
ENT.DoorAttackRange = 90

ENT.NextAttack = 1

ENT.AttackFinishTime = 0.6

ENT.pitch = 45

--Model Settings--
ENT.Model = "models/predatorcz/amnesia/grunt.mdl"

ENT.WalkAnim = "walk"
ENT.AttackAnim = "attack1"

ENT.AttackAnims = {
	"attack1",
	"attack2"
}

ENT.IdleAnims = {
	"idle1",
	"idle2",
	"idle3",
	"idle4",
}

ENT.IdleAnim = ACT_IDLE 

ENT.SearchRadius = 1000

--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"ambient/levels/canals/windchime2.wav",
	"ambient/levels/canals/windchime4.wav"
}

ENT.deathSounds = {
	"ambient/machines/wall_move1.wav",
	"ambient/machines/wall_move2.wav",
	"ambient/machines/wall_move3.wav"
}

ENT.alertSounds = {
	"ambient/fire/ignite.wav",
	"ambient/fire/gascan_ignite1.wav",
	"ambient/gas/steam2.wav"
}

ENT.idleSounds = {
	"ambient/levels/canals/toxic_slime_sizzle1.wav",
	"ambient/levels/canals/toxic_slime_sizzle2.wav",
	"ambient/levels/canals/toxic_slime_sizzle3.wav",
	"ambient/levels/canals/toxic_slime_sizzle4.wav"
}

ENT.painSounds = {
	"ambient/levels/labs/machine_stop1.wav",
	"ambient/machines/teleport4.wav",
	"ambient/machines/teleport1.wav"
}

ENT.hitSounds = {
	"ambient/levels/canals/windchine1.wav"
}

ENT.missSounds = {
	"ambient/levels/canals/windchine1.wav"
}

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()

	if SERVER then

	--Stats--
	self:SetModel(self.Model)
	self:SetHealth(self.health)	
	self:SetMaterial("models/props_combine/tpballglow")
	self:SetBloodColor(DONT_BLEED)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)

	--self:SetColor( Color( math.random(100,255), math.random(100,255), math.random(100,255), 255 ) )
	self:SetColor( Color( 150,150,150, 255 ) )
	
	self.IsAttacking = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(600)
	self.loco:SetDeceleration(600)
	
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	end
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,1) == 1) then
		nut.item.spawn("ichor", self:GetPos()+ Vector(0,0,20))
	end		

	self:Remove()
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
end

function ENT:FootSteps()
	self:EmitSound("npc/zombie_poison/pz_right_foot1.wav", 75)
end

function ENT:CustomThinkClient()
	if CLIENT then
		local pos = self:GetPos() + self:GetUp()
		local dlight = DynamicLight(self:EntIndex())
		dlight.Pos = pos
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.Brightness = 1
		dlight.Size = 32
		dlight.Decay = 64
		dlight.style = 5
		dlight.DieTime = CurTime() + .1
	end
end

ENT.nextAlpha = CurTime()

function ENT:CustomThink()
	if(self.nextAlpha <= CurTime()) then
		local ranColor = math.random(0,255)
		self:SetColor( Color( ranColor, ranColor, ranColor, 255 ) )
		self.nextAlpha = CurTime() + 1
	end
end

function ENT:Enrage()
	self.WalkAnim = "run_all"
	self.Speed = 180
	self.WanderType = 4
end

function ENT:OnAlert()
	self:Enrage()
end

function ENT:CustomAttack()
	self.AttackAnim = self.AttackAnims[ math.random( #self.AttackAnims ) ]
end

function ENT:Idle()
	if(self.nextIdle < CurTime()) then
		self.IdleAnim = self.IdleAnims[ math.random( #self.IdleAnims ) ]
		self:IdleSound()
		self.nextIdle = CurTime() + 5
	end
	self:MovementFunctions( 2, self.IdleAnim, self.Speed, self.WalkSpeedAnimation )	
end