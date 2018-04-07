if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_phantom", {
	Name = "Phantom",
	Class = "nz_phantom",
	Category = "Respite - Wraith"
} )

--Stats--
ENT.MoveType = 2

ENT.FootAngles = 5

ENT.CollisionHeight = 66
ENT.CollisionSide = 11

ENT.Speed = 30
ENT.WalkSpeedAnimation = 1
ENT.FlinchSpeed = 0

ENT.health = 110
ENT.Damage = 10

ENT.PhysForce = 15000
ENT.AttackRange = 60
ENT.InitialAttackRange = 55
ENT.DoorAttackRange = 25

ENT.NextAttack = 2

ENT.AttackFinishTime = 0.5
ENT.pitch = 35

--Model Settings--
ENT.Model = "models/zombie/junkie_01.mdl"

ENT.GrabAnim = "enter_choke"
ENT.GrabFailAnim = "choke_miss"
ENT.HoldAnim = "choke_eat"

ENT.AttackAnim = "seq_baton_swing"

ENT.HeadFlinch = "flinch_head"

ENT.RLegFlinch = "flinch_rightleg"
ENT.RArmFlinch = "flinch_rightarm"

ENT.LLegFlinch = "flinch_leftleg"
ENT.LArmFlinch = "flinch_leftarm"

--Sounds--
ENT.attackSounds = {
	"npc/demon/nhdemon_fz_frenzy1.wav",
	"npc/demon/nhdemon_fz_alert_close1.wav"
}

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.alertSounds = {
	"horror/fz_alert_close1.wav",
	"horror/fz_scream1.wav",
	"horror/leap2.wav",
	"horror/alert_far1.wav",
	"horror/alert_far2.wav"
}

ENT.deathSounds = {
	"horror/die1.wav",
	"horror/die2.wav",
	"horror/die3.wav",
	"horror/die4.wav"
}

ENT.idleSounds = {
	"npc/demon/nhdemon_idle1.wav",
	"npc/demon/nhdemon_idle2.wav",
	"npc/demon/nhdemon_idle3.wav"
}

ENT.painSounds = {
	"horror/pain1.wav",
	"horror/pain2.wav",
	"horror/pain3.wav",
	"horror/pain4.wav"
}

ENT.hitSounds = {
	"physics/flesh/flesh_squishy_impact_hard1.wav",
	"physics/flesh/flesh_squishy_impact_hard2.wav",
	"physics/flesh/flesh_squishy_impact_hard3.wav",
	"physics/flesh/flesh_squishy_impact_hard4.wav",
	"physics/body/body_medium_break2.wav",
	"physics/body/body_medium_break3.wav",
	"physics/body/body_medium_break4.wav"
}

ENT.missSounds = {
	"npc/demon/nhdemon_claw_miss1.wav"
}

function ENT:Animations()
	self.WalkAnims = { "walk1", "walk2", "walk3", "walk4", "walk5", "walk6", "walk7", "walk8", "walk9", "walk10" }
	self.IdleAnimations =  { "idle01", "idle02", "idle03", "idle04" }
	
	self.WalkAnim = ( table.Random( self.WalkAnims ) )
	self.IdleAnim = ( table.Random( self.IdleAnimations ) )
	
	if self.WalkAnim == "walk8" then
	
		self.Speed = self.Speed - 10
		
	end
end

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()

	if SERVER then

	--Stats--
	self:SetHealth(self.health)	
	self:SetBloodColor(DONT_BLEED)
	self:SetModel(self.Model)
	
	self:SetMaterial("models/effects/comball_glow1")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	
	self.LoseTargetDist	= (self.LoseTargetDist)
	self.SearchRadius 	= (self.SearchRadius)
	
	self.IsAttacking = false
	self.Flinching = false
	self.IsGrabbing = false
	self.Stumbling = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(200)
	self.loco:SetDeceleration(900)
	
	self:Animations()
	
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderFX(kRenderFxDistort)
	
	--Misc--
	self:Precache()
	self:EquipWeapon()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	end
end

function ENT:EquipWeapon()
	local wep = ents.Create("nz_ent_weapon")
	wep:SetOwner(self)
	wep:SetPos(self:GetPos())
	wep:Spawn()
	wep:SetSolid(SOLID_NONE)
	wep:SetParent(self)
	wep:Fire("setparentattachment", "anim_attachment_RH")
	wep:AddEffects(EF_BONEMERGE)
	wep:SetAngles( self:GetForward():Angle() )
	wep:SetOwner( self )
	wep:SetMaterial("models/effects/comball_glow1")
	local weapons = math.random(1,4)
	if weapons == 1 then
		wep:SetModel( "models/weapons/w_knife_ct.mdl" )	
		self.Damage = 10
		self.hitSounds = {"weapons/maniac_slash.wav"}
		self.WalkSpeedAnimation = 1.5
		self.Speed = self.Speed * 1.5
		self.AttackRange = 50
		self.AttackAnim = "attacka"
	elseif weapons == 2 then
		wep:SetModel( "models/axe/w_axe.mdl" )
		self.Damage = 30
	elseif weapons == 3 then
		wep:SetModel( "models/props_canal/mattpipe.mdl" )
		self.Damage = 20
	elseif weapons == 4 then
		wep:SetModel( "models/weapons/w_crowbar.mdl" )
		self.Damage = 20
	end
	
	self.Weapon = wep
end

function ENT:CheckStatus()
	if self.Flinching then
		return false
	end
	
	return true
end

function ENT:CustomDeath( dmginfo )
	if (math.random(1,5) == 1) then
		nut.item.spawn("ichor", self:GetPos()+ Vector(0,0,20))
	end		
	
	SafeRemoveEntity( self )
	--self:DropWeapon()
end

function ENT:DropWeapon()
	local ent = ents.Create( "ent_fakeweapon" )
	
	if ent:IsValid() and self:IsValid() then	
	
		ent:SetModel( self.Weapon:GetModel() )
		ent:SetPos( self:GetPos() + Vector( 0,0,50 ) )
		ent:Spawn()
	
		ent:Spawn()
		ent:SetOwner( self )
		ent:SetMaterial("models/effects/comball_glow1")
		local phys = ent:GetPhysicsObject()
		
		if phys:IsValid() then
		
			local ang = self:EyeAngles()
			ang:RotateAroundAxis(ang:Forward(), math.Rand(-100, 100))
			ang:RotateAroundAxis(ang:Up(), math.Rand(-100, 100))
			phys:SetVelocityInstantaneous(ang:Forward() * math.Rand( 200, 200 ))
				
		end
	end
	
	self.Weapon:Remove()
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	if (attacker:IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end

	// hack: get hitgroup
	local trace = {}
	trace.start = attacker:GetShootPos()
			
	trace.endpos = trace.start + ( ( dmginfo:GetDamagePosition() - trace.start ) * 2 )  
	trace.mask = MASK_SHOT
	trace.filter = attacker
			
	local tr = util.TraceLine( trace )
	hitgroup = tr.HitGroup
		
	self:Flinch(dmginfo, hitgroup)
		
	if ( dmginfo:IsBulletDamage() ) then
		if hitgroup == HITGROUP_HEAD then
			dmginfo:ScaleDamage(3)
		else
			dmginfo:ScaleDamage(0.7)		
		end
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
		self.loco:SetAcceleration(200)
		self:ResumeMovementFunctions()
		self.Flinching = false
		self.Stumbling = false
	end)
end
	
function ENT:BackUp( type )
	
	local enemy = self:GetEnemy()
	while( self.Stumbling ) do
		
		if type == 1 then
			local back = self:GetPos() + self:GetAngles():Forward() * -778
			self.loco:Approach(back, 100)
		elseif type == 2 then
			local back = self:GetPos() + self:GetAngles():Forward() * 778
			self.loco:Approach(back, 100)	
		end
			
		coroutine.wait(0.05)
	end
	
	coroutine.yield()
end	

function ENT:Flinch( dmginfo, hitgroup )
	
	if ( self.NextFlinch or 0 ) < CurTime() then
	
		if !self:CheckValid( self ) then return end
		if !self:CheckStatus() then return end
	
		if hitgroup == HITGROUP_HEAD then
			self:PlayFlinchSequence( self.HeadFlinch, 1, 0, 0, 0.7 )
		elseif hitgroup == HITGROUP_LEFTLEG then
			self:PlayFlinchSequence( self.LLegFlinch, 1, 0, 0, 2.5 )
		elseif hitgroup == HITGROUP_RIGHTLEG then
			self:PlayFlinchSequence( self.RLegFlinch, 1, 0, 0, 1.6 )
		elseif hitgroup == HITGROUP_LEFTARM then
			self:PlayFlinchSequence( self.LArmFlinch, 1, 0, 0, 0.7 )
		elseif hitgroup == HITGROUP_RIGHTARM then
			self:PlayFlinchSequence( self.RArmFlinch, 1, 0, 0, 0.7 )
		elseif hitgroup == HITGROUP_CHEST or HITGROUP_GEAR or HITGROUP_STOMACH then
			
			local enemy = dmginfo:GetAttacker()
			
			if enemy:IsValid() then
				if enemy:IsPlayer() then
				
					local enemyforward = enemy:GetForward()
					local forward = self:GetForward() 
					
					if enemyforward:Distance( forward ) < 1 then
						self:PlayFlinchSequence( "shovereactbehind", 1, 0, self.Speed -  25, 1.6 )
						self.loco:SetAcceleration(1000)
						self.Stumbling = true
						self.StumbleType = 2
					else
						self:PlayFlinchSequence( "shovereact", 1, 0, self.Speed - 25, 1.6 )
						self.loco:SetAcceleration(1000)
						self.Stumbling = true
						self.StumbleType = 1
					end
				end
			end
		end
		self.NextFlinch = CurTime() + 3	
	end
end

function ENT:FootSteps()
	self:EmitSound("npc/zombie/foot"..math.random(3)..".wav", 70)
end