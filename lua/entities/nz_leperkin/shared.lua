if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_leperkin", {
	Name = "Hunter",
	Class = "nz_leperkin",
	Category = "Respite"
} )

--Stats--
ENT.UseFootSteps = 2
ENT.FootStepTime = 0.39
ENT.FootAngles = 10
ENT.FootAngles2 = 10

ENT.MoveType = 2

ENT.CollisionHeight = 64
ENT.CollisionSide = 7

ENT.Speed = 200
ENT.WalkSpeedAnimation = 1
ENT.FlinchSpeed = .5

ENT.health = 150
ENT.Damage = 15

ENT.PhysForce = 15000
ENT.AttackRange = 80
ENT.DoorAttackRange = 50

ENT.NextAttack = 1

ENT.wanderType = 3
ENT.idleTime = 2

ENT.AttackFinishTime = 0.5

--Model Settings--
ENT.Model = "models/sin/leperkin.mdl"

ENT.AttackAnim = "melee"

ENT.AttackAnims = {
	"melee",
	"melee_fast",
	"melee_medium",
	"melee_blunt_weapon",
	"melee_01",
	"melee_01_fast",
	"melee_01_medium",
	"melee_01_blunt_weapon",
	"frenzy_attack"
}

ENT.IdleAnim = "idle"

ENT.WalkAnim = "walk"
ENT.WalkAnims = {
	"walk",
	"walk_all",
	"walk_fast",
	"walk_fast_blunt_weapon",
	"run"
}

ENT.FlinchAnim = (ACT_FLINCHHEAD)

ENT.AttackDoorAnim = (ACT_MELEE01_MEDIUM)

--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"npc/leperkin/leperkin_attack1.mp3",
	"npc/leperkin/leperkin_attack2.mp3",
	"npc/leperkin/leperkin_attack3.mp3"
}

ENT.alertSounds = {
	"npc/leperkin/stage2_frenzyattack1.mp3",
	"npc/leperkin/stage2_frenzyattack2.mp3",
	"npc/leperkin/stage2_frenzyattack3.mp3",
	"npc/leperkin/stage2_frenzyattack4.mp3"
}

ENT.deathSounds = {
	"npc/leperkin/leperkin_death1.mp3",
	"npc/leperkin/leperkin_death2.mp3",
	"npc/leperkin/leperkin_death3.mp3"
}

ENT.idleSounds = {
	"npc/leperkin/stage2_turn1.mp3",
	"npc/leperkin/stage2_turn2.mp3",
	"npc/leperkin/stage2_pain7.mp3"
}

ENT.painSounds = {
	"npc/leperkin/stage2_pain1.mp3",
	"npc/leperkin/stage2_pain2.mp3",
	"npc/leperkin/stage2_pain3.mp3",
	"npc/leperkin/stage2_pain4.mp3",
	"npc/leperkin/stage2_pain5.mp3",
	"npc/leperkin/stage2_pain6.mp3",
	"npc/leperkin/stage2_pain7.mp3"
}

ENT.hitSounds = {
	"npc/leperkin/leperkin_hit3.mp3"
}

ENT.missSounds = {
	"npc/leperkin/leperkin_whoosh1.mp3"
}

function ENT:Initialize()

	if SERVER then

		--Stats--
		self:SetBloodColor(BLOOD_COLOR_YELLOW)
		
		self.WalkAnim = table.Random(self.WalkAnims)
		self:SetModel(self.Model)
		if(math.random() == 1) then
			self:SetBodygroup(1, 1)
		end
		
		self:SetHealth(self.health)	
		
		self.IsAttacking = false
		
		self.loco:SetStepHeight(35)
		self.loco:SetAcceleration(900)
		self.loco:SetDeceleration(900)
		
		--Misc--
		self:Precache()
		self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	end
end

function ENT:CustomDeath( dmginfo )
    util.Decal("YellowBlood", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	
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
			dmginfo:ScaleDamage(5)
		end
	end
end

function ENT:EjectBlood( dmginfo, amount, reduction )
	
	if ( self.NextEject or 0 ) < CurTime() then
	
		self:SetHealth( self:Health() + reduction )
		self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 72, math.Rand(85, 95))	
			
		for i=1,amount do
			local flesh = ents.Create("nz_projectile_blood") 
				if flesh:IsValid() then
					flesh:SetPos( self:GetPos() + Vector(0,0,30) )
					flesh:SetOwner(self)
					flesh:Spawn()
	
					local phys = flesh:GetPhysicsObject()
					if phys:IsValid() then
						local ang = self:EyeAngles()
						ang:RotateAroundAxis(ang:Forward(), math.Rand(-205, 205))
						ang:RotateAroundAxis(ang:Up(), math.Rand(-205, 205))
						phys:SetVelocityInstantaneous(ang:Forward() * math.Rand( 260, 360 ))
					end
				end
					
			end
		
		self.NextEject = CurTime() + 1	
	end		
		
end

function ENT:FootSteps()
	self:EmitSound("npc/leperkin/leperkin_step"..math.random(4)..".mp3", 65)
end

function ENT:RangeAttack( ent )
	
	if !self:CheckStatus() then return end

	self:RestartGesture(ACT_FLINCHHEAD2)
	--self.loco:SetDesiredSpeed( 0)
	
--	timer.Simple( 0.3, function()
	if !self:IsValid() then return end
	if self:Health() < 0 then return end
	if !self:CheckStatus() then return end
	
	--self.loco:SetDesiredSpeed( 0 )
	self:EmitSound("npc/leperkin/stage2_spitgest1"..math.random(1, 2)..".mp3", 72, math.Rand(85, 95))	

	--for i=1,12 do
	local spit = ents.Create("nz_projectile_blood") 
		if spit:IsValid() then
		spit:SetPos( self:GetPos() + Vector(0,5,50) )
		spit:SetOwner(self)
		spit:Spawn()
	
			--[[local phys = spit:GetPhysicsObject()
			if phys:IsValid() then
			local ang = self:EyeAngles()
				ang:RotateAroundAxis(ang:Forward(), math.Rand(-30, 30))
				ang:RotateAroundAxis(ang:Up(), math.Rand(-30, 30))
				phys:SetVelocityInstantaneous(ang:Forward() * math.Rand(650, 1180))
			end--]]
		end
		
		
	--end
	
--	end)
end

function ENT:CustomAttack()
	self.AttackAnim = self.AttackAnims[ math.random( #self.AttackAnims ) ]
	self.WalkAnim = self.WalkAnims[ math.random( #self.WalkAnims ) ]
end
