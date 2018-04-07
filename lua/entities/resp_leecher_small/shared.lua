if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = true
ENT.AdminSpawnable   = true

--SpawnMenu--
list.Set( "NPC", "resp_leecher_small", {
	Name = "Leecher (Small)",
	Class = "resp_leecher_small",
	Category = "Respite"
} )

--Stats--
ENT.CollisionHeight = 85
ENT.CollisionSide = 15

ENT.MoveType = 1

ENT.UseFootSteps = 1
ENT.Bone1 = "ValveBiped.Bip01_R_Foot"
ENT.Bone2 = "ValveBiped.Bip01_L_Foot"
ENT.FootAngles = 5
ENT.FootAngles2 = 5

ENT.Speed = 55
ENT.WalkSpeedAnimation = 1

ENT.health = 300
ENT.Damage = 10

ENT.HitPerDoor = 5
ENT.PhysForce = 15000
ENT.AttackRange = 80
ENT.InitialAttackRange = 70
ENT.DoorAttackRange = 70

ENT.pitch = 50
ENT.pitchVar = 10

ENT.NextAttack = 1.0

ENT.AttackFinishTime = 0.9

--Model Settings--
ENT.Model = "models/zombie/grabber_01.mdl"
ENT.BoneMergeModel = "models/player/slow/amberlyn/re5/uroboro/slow_public.mdl"

ENT.AttackAnim = (ACT_MELEE_ATTACK1)

ENT.WalkAnim = ACT_WALK
--ENT.WalkAnim = "walk_upper"

ENT.FlinchAnims = {
	"flinch1",
	"flinch2",
	"flinch3",
	"flinch_head",
	"flinch_leftarm",
	"flinch_leftleg",
	"flinch_rightarm",
	"flinch_rightleg"
}

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
	"npc/freshdead/male/alert_no_enemy1.wav",
	"npc/freshdead/male/alert_no_enemy2.wav",
	"npc/freshdead/male/pain2.wav",
	"npc/freshdead/male/pain4.wav"
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

function ENT:Initialize()

	if SERVER then
	--Stats--
	self:SetModel(self.Model)
	self:SetHealth(self.health)	
	
	self.IsAttacking = false
	self.Flinching = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(400)
	self.loco:SetDeceleration(900)
  
     self.OverlayModel = ents.Create("prop_dynamic")
        zm=self.OverlayModel
	    zm:SetParent(self)
		zm:SetModel( self.BoneMergeModel )
		zm.RenderGroup = RENDERGROUP_OPAQUE

		zm:AddEffects(EF_BONEMERGE)
	    zm:SetBodygroup(1,1)
      
	  self:PhysicsInitShadow(true, true)
	--Misc--
		self:Precache()
		self:SetMaterial("null")
		self:SetColor( Color( 0, 0, 0, 0 ) )
		self:SetRenderMode( RENDERMODE_TRANSALPHA ) 
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetMaterial("models/weapons/v_smg1/texture5")	
		self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	end
end


function ENT:CustomDeath( dmginfo )
    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	if (math.random(0,2) == 2) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end		

	self:Remove()
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

	ragdoll:EmitSound("npc/barnacle/barnacle_bark1.wav",90,math.random(40,50))
	ragdoll:EmitSound("npc/barnacle/barnacle_crunch2.wav",90,math.random(40,50))
	ragdoll:EmitSound("npc/barnacle/barnacle_crunch3.wav",90,math.random(40,50))
	ragdoll:EmitSound("npc/barnacle/barnacle_bark2.wav",90,math.random(40,50))
		
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
		
		self:Enrage()
		
		local flinchAnim = table.Random(self.FlinchAnims)
		
		self:PlayFlinchSequence( flinchAnim, 1, 0, 0, 0.5 )
		
		self.NextFlinch = CurTime() + 3.5
	end
		
end

function ENT:PlayFlinchSequence( string, rate, cycle, speed, time )
	self.Flinching = true

	self:ResetSequence( string )
	self:SetCycle( cycle )
	self:SetPlaybackRate( rate )
	self.loco:SetDesiredSpeed( speed )
	
	timer.Simple(time, function() 
		if !self:IsValid() then return end
		if self:Health() < 0 then return end
		self.loco:SetAcceleration(500)
		self:ResumeMovementFunctions()
		self.Flinching = false
		self.Stumbling = false
	end)
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
	
	if dmginfo:GetDamage() > 30 then
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
			dmginfo:ScaleDamage(0.55)
		end
		
		if hitgroup == HITGROUP_HEAD then
			dmginfo:ScaleDamage(5)
		end
	end
end

function ENT:FootSteps()
	self:EmitSound("dalrp/npc/leecher/leecher_footstep0"..math.random(2)..".wav", 60, 170)
end

--get mad
function ENT:Enrage()
	self.Speed = 250
	self.WalkAnim = ACT_RUN
	self.wanderType = 1
end

function ENT:WakeUp()
	self.UseFootSteps = 0
	self.Flinching = true
	self:PlaySequenceAndWait("slumprise_b", 1)
	self.loco:SetDesiredSpeed( 0 )

	self.UseFootSteps = 1
	self.Flinching = false
	self.loco:SetDesiredSpeed( self.Speed )
	self:ResumeMovementFunctions()
end

function ENT:OnSpawn()
	self:WakeUp()
end