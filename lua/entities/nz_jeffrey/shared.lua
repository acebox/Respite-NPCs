if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_jeffrey", {
	Name = "Jeffrey",
	Class = "nz_jeffrey",
	Category = "Respite - Wraith"
} )

ENT.Summons = {}

--Stats--
ENT.FootAngles = 10
ENT.FootAngles2 = 10

ENT.UseFootSteps = 2
ENT.FootStepTime = 0.6

ENT.MoveType = 2

ENT.CollisionHeight = 64
ENT.CollisionSide = 7

ENT.ModelScale = 3

ENT.Speed = 80
ENT.WalkSpeedAnimation = 0.75
ENT.FlinchSpeed = 10

ENT.health = 3000
ENT.Damage = 80
ENT.HitPerDoor = 2

ENT.PhysForce = 300000
ENT.AttackRange = 135
ENT.InitialAttackRange = 130
ENT.DoorAttackRange = 100

ENT.NextAttack = 1.5

ENT.AttackAnimSpeed = 0.75
ENT.AttackFinishTime = 1.25

ENT.pitch = 30
ENT.wanderType = 4
ENT.Launches = true

--Model Settings--
ENT.Model = "models/Zombie/poison.mdl"

ENT.AttackAnim = "melee_01"
ENT.WalkAnim = "firewalk"
ENT.IdleAnim = (ACT_IDLE)
ENT.FlinchAnim = ACT_SMALL_FLINCH

--Sounds--

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"npc/zombie_poison/pz_warn2.wav"
}

ENT.deathSounds = {
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav"
}

ENT.alertSounds = {
	"npc/zombie_poison/pz_alert1.wav",
	"npc/zombie_poison/pz_alert2.wav"
}
	
ENT.idleSounds = {
	"npc/zombie_poison/pz_idle2.wav",
	"npc/zombie_poison/pz_idle3.wav",
	"npc/zombie_poison/pz_idle4.wav"
}

ENT.painSounds = {
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav"
}

ENT.hitSounds = {
	"npc/zombie/claw_strike1.wav"
}

ENT.missSounds = {
	"npc/zombie/claw_miss1.wav"
}

function ENT:Initialize()

	local bones = {
		"ValveBiped.Bip01_L_UpperArm",
		"ValveBiped.Bip01_L_Forearm",
		"ValveBiped.Bip01_L_Hand",
		"ValveBiped.Bip01_L_Finger1",
		"ValveBiped.Bip01_L_Finger11",
		"ValveBiped.Bip01_L_Finger12",
		"ValveBiped.Bip01_L_Finger2",
		"ValveBiped.Bip01_L_Finger21",
		"ValveBiped.Bip01_L_Finger22",
		"ValveBiped.Bip01_L_Finger3",
		"ValveBiped.Bip01_L_Finger31",
		"ValveBiped.Bip01_L_Finger32",
		"ValveBiped.Bip01_R_UpperArm",
		"ValveBiped.Bip01_R_Forearm",
		"ValveBiped.Bip01_R_Hand",
		"ValveBiped.Bip01_R_Finger1",
		"ValveBiped.Bip01_R_Finger11",
		"ValveBiped.Bip01_R_Finger12",
		"ValveBiped.Bip01_R_Finger2",
		"ValveBiped.Bip01_R_Finger21",
		"ValveBiped.Bip01_R_Finger22",
		"ValveBiped.Bip01_R_Finger3",
		"ValveBiped.Bip01_R_Finger31",
		"ValveBiped.Bip01_R_Finger32"
	}

	for _, bone in pairs(bones) do
		local boneid = self:LookupBone(bone)
		if boneid and boneid > 0 then
			self:ManipulateBoneScale(boneid, Vector(2,2,2))
		end
	end	

	if SERVER then
		--Stats--
		self:SetModel(self.Model)
		self:SetHealth(self.health)	
		self:SetModelScale( self.ModelScale, 0 )
		self:SetMaterial("models/props_lab/security_screens")
		
		self.IsAttacking = false
		
		self.loco:SetStepHeight(35)
		self.loco:SetAcceleration(900)
		self.loco:SetDeceleration(900)
		
		--Misc--
		self:Precache()
		self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	
		self:SetBloodColor(DONT_BLEED)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetRenderFX(kRenderFxDistort)
	end
end

function ENT:CustomDeath( dmginfo )
	local deathEffect = ents.Create("info_particle_system")
	deathEffect:SetKeyValue("effect_name", "aurora_shockwave")
	deathEffect:SetParent(v)
	deathEffect:SetPos( self:GetPos() )
	deathEffect:Spawn()
	deathEffect:Activate()
	deathEffect:Fire("Start", "", 0)
	deathEffect:Fire("Kill", "", 5)

	nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	
	if(math.random(0,1) == 1) then
		nut.item.spawn("shard_dust", self:GetPos()+ Vector(0,0,20))
	end
	
	SafeRemoveEntity(self)
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()

	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
	
	if(dmginfo:GetDamage() > 50) then
		self:Flinch(dmginfo)
	end
	
	local bleed = ents.Create("info_particle_system")
	bleed:SetKeyValue("effect_name", "striderbuster_break_lightning")
	bleed:SetParent(self)
	bleed:SetPos( dmginfo:GetDamagePosition() )
	bleed:Spawn()
	bleed:Activate()
	bleed:Fire("Start", "", 0)
	bleed:Fire("Kill", "", 1)
end

function ENT:FootSteps()
	if(math.random(1) == 1) then
		self:EmitSound("npc/zombie_poison/pz_left_foot1.wav", 75)
	else
		self:EmitSound("npc/zombie_poison/pz_right_foot1.wav", 75)
	end
end

function ENT:Flinch(dmginfo)
	if ( self.NextFlinch or 0 ) < CurTime() then	
	
		if !self:CheckValid( self ) then return end
		if self.Flinching then return end
	
		self:StartActivity( self.FlinchAnim )
	
		self.loco:SetDesiredSpeed( 0 )
	
		self.Flinching = true
	
		timer.Simple(0.7, function() 
			if !self:IsValid() then return end
			if self:Health() < 0 then return end
		
			self.loco:SetDesiredSpeed( self.Speed )	
		
			self.Flinching = false
			self:ResumeMovementFunctions()
		end)
		
		local bleed = ents.Create("info_particle_system")
		bleed:SetKeyValue("effect_name", "striderbuster_attach")
		bleed:SetParent(self)
		bleed:SetPos( dmginfo:GetDamagePosition() )
		bleed:Spawn()
		bleed:Activate()
		bleed:Fire("Start", "", 0)
		bleed:Fire("Kill", "", 1)
		
		self.NextFlinch = CurTime() + 3.5
	end
end


function ENT:CheckStatus()
	if self.Flinching then
		return false
	end
	
	return true
end

function ENT:Shout()
	self.NextFlinch = CurTime() + 5 --no flinching
	self.IsAttacking = true

	self:ResetSequence( "releasecrab" )
	self:PainSound()
	self:SetCycle( 0 )
	
	timer.Simple(1, function()
		if(self:IsValid()) then
			local search = ents.FindInSphere(self:GetPos(), 1000)
			local count = 0
			for k, v in pairs(search) do
				if(baseclass.Get(v:GetClass()).Base == "chance_base") then
					local pos = v:GetPos()
					if(v:GetAttachment(1)) then
						pos = v:GetAttachment(1).Pos
					end
					
					v:SetHealth(v:Health() + v:GetMaxHealth()/10)
					v:Enrage()
					v:SetMaterial(self:GetMaterial())
					v:PainSound()
					v.Damage = v.Damage + 5
					v:SetEnemy(self.Enemy)
					v:SetBloodColor(DONT_BLEED)
					v.wraith = true
					
					if(count < 10) then --reduces lag due to lots of particles
						local healEffect = ents.Create("info_particle_system")
						healEffect:SetKeyValue("effect_name", "striderbuster_break_lightning")
						healEffect:SetParent(v)
						healEffect:SetPos( pos )
						healEffect:Spawn()
						healEffect:Activate()
						healEffect:Fire("Start", "", 0)
						healEffect:Fire("Kill", "", 5)
					end
					
					count = count + 1
				end
			end
			
			if(count == 1) then --no non wraith/shade nextbots to convert
				self:Summon() --summons npcs
			end
			
			util.ScreenShake(self:GetPos(), 100, 5, 1, 1000)
			self.IsAttacking = false

			self:EmitSound("npc/combine_soldier/pain3.wav", 100, 50)
			
			timer.Simple(0.8, function()
				self:ResumeMovementFunctions()
			end)
		end
	end)
	
	self:SetPlaybackRate( 1 )
	self.loco:SetDesiredSpeed( 0 )
end

function ENT:Summon()
	posSummons = {
		"resp_babu_broken",
		"nz_haunt"
	}

	for i = 1, 5 do
		local ent = ents.Create(table.Random(posSummons))
		
		table.insert(self.Summons, ent)
		
		if ent:IsValid() and self:IsValid() then
			local pos = self:FindSpot( "random", { type = 'hiding', radius = 5000 } )
			if(!pos) then
				return
			end
			ent:SetPos(pos)
			ent:Spawn()
			ent:SetOwner( self )
			timer.Simple(0.5,
				function()
					ent:SetEnemy(self.Enemy)
				end
			)
		end
	end
	
end

function ENT:CustomChaseEnemy()
	local enemy = self.Enemy
	if(enemy) then
		local pos = enemy:GetPos()
		if(!self.nextSpecial) then
			self.nextSpecial = CurTime() + 1
		end
		
		if(self:GetPos():DistToSqr(enemy:GetPos()) < 1000 * 1000) then
			if(self.nextSpecial < CurTime() and !self.Flinching) then
				self:Shout()
				self.nextSpecial = CurTime() + 15
			end
		end
	end
end

function ENT:OnRemove()
	for k, v in pairs(self.Summons) do
		if(v:IsValid()) then
			v:Remove()
		end
	end
end