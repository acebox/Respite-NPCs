if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = true
ENT.AdminSpawnable   = true

--SpawnMenu--
list.Set( "NPC", "nz_leecher", {
	Name = "Leecher",
	Class = "nz_leecher",
	Category = "Respite"
} )

--Stats--
ENT.CollisionHeight = 70
ENT.CollisionSide = 30
ENT.MoveType = 2

ENT.UseFootSteps = 1

ENT.FootAngles = 0
ENT.FootAngles2 = 15

ENT.Bone1 = "ValveBiped.Bip01_R_Foot"
ENT.Bone2 = "ValveBiped.Bip01_L_Foot"

ENT.Speed = 60
ENT.WalkSpeedAnimation = 0.8

ENT.health = 1200
ENT.Damage = 20

ENT.HitPerDoor = 2
ENT.PhysForce = 15000
ENT.AttackRange = 105
ENT.InitialAttackRange = 95
ENT.DoorAttackRange = 70

ENT.LoseTargetDist	= 4500	-- How far the enemy has to be before we lose them
ENT.SearchRadius 	= 3000	-- How far to search for enemies

ENT.NextAttack = 2.0

ENT.AttackFinishTime = 1

ENT.pitch = 35
ENT.pitchVar = 15
ENT.Launches = true

--Model Settings--
ENT.Model = "models/zombie/poison.mdl"
ENT.BoneMergeModel = "models/player/slow/amberlyn/re5/uroboro/slow_public.mdl"

ENT.AttackAnim = (ACT_MELEE_ATTACK1)

ENT.WalkAnim = "walk"
ENT.FlinchAnim = ACT_SMALL_FLINCH

ENT.AttackDoorAnim = (ACT_RANGE_ATTACK2)

--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"deadzone/lepotitsa/attack1.wav",
	"deadzone/lepotitsa/attack2.wav",
	"deadzone/lepotitsa/attack3.wav",
	"deadzone/lepotitsa/attack4.wav"
}

ENT.deathSounds = {
	"deadzone/lepotitsa/death1.wav",
	"deadzone/lepotitsa/death2.wav",
	"deadzone/lepotitsa/death3.wav",
	"deadzone/lepotitsa/death4.wav"
}

ENT.alertSounds = {
	"deadzone/lepotitsa/alert1.wav",
	"deadzone/lepotitsa/alert2.wav",
	"deadzone/lepotitsa/alert3.wav",
	"deadzone/lepotitsa/alert4.wav"
}

ENT.idleSounds = {
	"deadzone/lepotitsa/pain1.wav",
	"deadzone/lepotitsa/pain2.wav",
	"deadzone/lepotitsa/attack4.wav",
	"dalrp/npc/leecher/leecher_vocal01.wav",
	"dalrp/npc/leecher/leecher_vocal02.wav"
}

ENT.painSounds = {
	"deadzone/lepotitsa/pain1.wav",
	"deadzone/lepotitsa/pain2.wav",
	"deadzone/lepotitsa/pain3.wav"
}

ENT.hitSounds = {
	"npc/infected_zombies/hit_punch_01.wav",
	"npc/infected_zombies/hit_punch_02.wav",
	"npc/infected_zombies/hit_punch_03.wav",
	"npc/infected_zombies/hit_punch_04.wav",
	"npc/infected_zombies/hit_punch_05.wav",
	"npc/infected_zombies/hit_punch_06.wav",
	"npc/infected_zombies/hit_punch_07.wav",
	"npc/infected_zombies/hit_punch_08.wav"
}

ENT.missSounds = {
	"npc/infected_zombies/claw_miss_1.wav",
	"npc/infected_zombies/claw_miss_2.wav"
}

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	if SERVER then
	self:Precache()
	
	--Stats--

	self:SetModel(self.Model)
	self:SetHealth(self.health)	
	
	self:SetColor(Color(0,0,0,0))
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetMaterial("models/weapons/v_smg1/texture5")	

	self.IsAttacking = false
	self.Flinching = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(400)
	self.loco:SetDeceleration(900)
    self.OverlayModel = ents.Create("prop_dynamic")
		zm = self.OverlayModel
		zm:SetParent(self)
		zm:SetModel( self.BoneMergeModel )
		zm.RenderGroup = RENDERGROUP_TRANSLUCENT
		zm:SetRenderMode(RENDERMODE_TRANSALPHA)
		--zm:SetColor(Color(255,255,255))
		--zm:SetRenderFX(kRenderFxDistort)

		zm:AddEffects(EF_BONEMERGE, EF_BONEMERGE_FASTCULL, EF_PARENT_ANIMATES )
		zm:SetBodygroup(1,1)
	
	self:SetModelScale( 2, 0 )
	
	self:PhysicsInitShadow(true, false)
	--Misc--

	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	end
end

function ENT:CustomDeath( dmginfo )
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	if (math.random(0,1) == 1) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end		
	
    local ragdoll = ents.Create("prop_ragdoll")
		if ragdoll:IsValid() then 
			ragdoll:SetPos(self:GetPos())
			ragdoll:SetModel(self.BoneMergeModel)
			ragdoll:SetAngles(self:GetAngles())
			ragdoll:Spawn()
			if self:GetModelScale() then
			ragdoll:SetModelScale( self:GetModelScale(), 0 )
			end
			local num = ragdoll:GetPhysicsObjectCount()-1
			local v = self.loco:GetVelocity()	
   
			for i=0, num do
				local bone = ragdoll:GetPhysicsObjectNum(i)

				if IsValid(bone) then
					local bp, ba = self:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
					if bp and ba then
						bone:SetPos(bp)
						bone:SetAngles(ba)
					end
					bone:SetVelocity(v)
				end
	  
			end
		
			ragdoll:SetBodygroup( 1, 1 )
			ragdoll:SetCollisionGroup( 1 )
		end
		
	ragdoll:EmitSound("npc/barnacle/barnacle_bark1.wav",90,math.random(20,40))
	ragdoll:EmitSound("npc/barnacle/barnacle_crunch2.wav",90,math.random(20,40))
	ragdoll:EmitSound("npc/barnacle/barnacle_crunch3.wav",90,math.random(20,40))
	ragdoll:EmitSound("npc/barnacle/barnacle_bark2.wav",90,math.random(20,40))
		
	ent = ents.Create("resp_leecher_small")	
	ent:SetPos(self:EyePos() + Vector(0,0,25) )
	ent:Spawn()
	ent:SetEnemy(self.Enemy)
	
	SafeRemoveEntity(self)
	
	timer.Simple(600, 
		function()
			SafeRemoveEntity( ragdoll )
		end
	)
end

function ENT:Flinch()
	if ( self.NextFlinch or 0 ) < CurTime() then	
	
		if !self:CheckValid( self ) then return end
		if self.Flinching then return end
	
		self:StartActivity( self.FlinchAnim )
	
		self.loco:SetDesiredSpeed( 0 )
	
		self.Flinching = true
	
		timer.Simple(0.6, function() 
			if !self:IsValid() then return end
			if self:Health() < 0 then return end
		
			self.loco:SetDesiredSpeed( self.Speed )	
		
			self.Flinching = false
			self:Enrage()
			self:ResumeMovementFunctions()
		end)
		
		self.NextFlinch = CurTime() + 3.5
	end
end


function ENT:CheckStatus()
	if self.Flinching then
		return false
	end
	
	return true
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
	
	if(dmginfo:GetDamage() > 50) then
		self:Flinch()
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
			
		if hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG then
			dmginfo:ScaleDamage(0.5)
		end
		
		if hitgroup == HITGROUP_HEAD then
			dmginfo:ScaleDamage(5)
		end
	end
end

function ENT:FootSteps()
	self:EmitSound("dalrp/npc/leecher/leecher_footstep0"..math.random(2)..".wav", 65, 110)
end

function ENT:Enrage()
	if(!self.Enraged) then
		self:EmitSound("deadzone/lepotitsa/pain3.wav", 100, math.random(self.pitch-self.pitchVar, self.pitch+self.pitchVar))
		self.Speed = 250
		self.WalkAnim = "run"
		self.wanderType = 1
		self.Enraged = true
	end
end