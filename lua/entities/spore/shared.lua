if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false
ENT.RenderGroup = RENDERGROUP_BOTH

--SpawnMenu--
list.Set( "NPC", "spore", {
	Name = "Spore",
	Class = "spore",
	Category = "Respite"
} )

ENT.classname = "spore"
ENT.NiceName = "Spore"

--Stats--
ENT.MoveType = 2

ENT.UseFootSteps = 2
ENT.FootStepTime = 0.33

ENT.corpseTime = 12 --how long it takes for a corpse to disappear after death

ENT.FootAngles = 5
ENT.FootAngles2 = 5

ENT.Bone1 = "ball_r"
ENT.Bone2 = "ball_l"

ENT.CollisionHeight = 85
ENT.CollisionSide = 15

ENT.Speed = 40
ENT.WalkSpeedAnimation = 1.0

ENT.health = 200
ENT.Damage = 6

ENT.PhysForce = 30000
ENT.AttackRange = 65
ENT.InitialAttackRange = 60
ENT.DoorAttackRange = 25

ENT.NextAttack = 0.45
ENT.AttackFinishTime = 0.35 --how long it takes for an attack to finish

ENT.pitch = 70
ENT.pitchVar = 10 --the variance of the pitch
ENT.wanderType = 2

--Model Settings--
ENT.Model = "models/respite/spore.mdl"

ENT.WalkAnim = "run"

ENT.IdleAnim = "idle"

ENT.AttackAnim = "attack1"

--Sounds--

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.alertSounds = {
	"respite/spore/spore1.wav",
	"respite/spore/spore2.wav",
	"respite/spore/spore3.wav"
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
	"npc/zombie/claw_miss1.wav"
}

ENT.attackSounds = ENT.alertSounds
ENT.deathSounds = ENT.alertSounds
ENT.idleSounds = ENT.alertSounds
ENT.painSounds = ENT.alertSounds

function ENT:Initialize()

	self:SetModel(self.Model)
	
	if SERVER then

	self:SetHealth(self.health)	
	
	self.IsAttacking = false
	
	self.loco:SetStepHeight(40)
	self.loco:SetAcceleration(400)
	self.loco:SetDeceleration(900)

	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	self:PhysicsInitShadow(true, true)
	
	end
	
	self.PrevPos = self:GetPos()

	self.NeckBone = self:LookupBone("neck_01")
	self.HeadBone = self:LookupBone("head")
	
	self.PrevCycle = 0
	
	self.Twitcher = true
	
	-- if math.random(0,1) == 1 then
    -- self.Twitcher = true
    -- else
    -- self.Twitcher = false
    -- end
	
end

function ENT:OnSpawn()
end


function ENT:Draw()

	local TEMP_SelfAnim = self:GetSequence()
	local TEMP_Cyc = self:GetCycle()
	local TEMP_MoveX = 0
	local TEMP_MoveY = 0
	local TEMP_NewCyc = TEMP_Cyc
	
	local TEMP_HeadAng = Angle(0,0,0)
	local TEMP_HeadPos = Vector(0,0,0)
	local TEMP_NeckAng = Angle(0,0,0)
	local TEMP_NeckPos = Vector(0,0,0)
	local TEMP_LegR1Ang = Angle(0,0,0)
	local TEMP_LegL1Ang = Angle(0,0,0)
		
	local TEMP_ZPos = 0
	local TEMP_YAng = 0
	
	
	local TEMP_PosDiff = Vector((self:GetPos()-self.PrevPos).x,(self:GetPos()-self.PrevPos).y,0)
	
		TEMP_HeadAng = Angle(0,0,0)
		TEMP_HeadPos = Vector(0,0,0)
		TEMP_HeadScale = Vector(1,1,1)
		TEMP_NeckAng = Angle(0,3,0)
		TEMP_NeckPos = Vector(0,0,0)
		TEMP_LegR1Ang = Angle(0,0,0)
		TEMP_LegL1Ang = Angle(0,0,0)
     
	local twitch_ang1 = math.random(-5,5)
	
	TEMP_HeadAng = TEMP_HeadAng+Angle(twitch_ang1,twitch_ang1,twitch_ang1)
	TEMP_NeckAng = TEMP_HeadAng+Angle(twitch_ang1,twitch_ang1,twitch_ang1)
	
	-- if(self.PrevCycle==TEMP_Cyc) then
		-- TEMP_NewCyc = TEMP_NewCyc+0.01
	-- end
	
	if self.Twitcher then	
		self:ManipulateBoneAngles(self.HeadBone,TEMP_HeadAng)
		self:ManipulateBonePosition(self.HeadBone,TEMP_HeadPos)
		self:ManipulateBoneAngles(self.NeckBone,TEMP_NeckAng)
		self:ManipulateBonePosition(self.NeckBone,TEMP_NeckPos)
		-- self:ManipulateBoneScale( self.HeadBone,TEMP_HeadScale )
    end
	
	self:DrawModel()
	self:SetupBones()

	
	self.PrevCycle = TEMP_Cyc
	
end


function ENT:CustomDeath( dmginfo )
	if (math.random(0,4) == 4) then
		nut.item.spawn("food_monster_meat", self:GetPos()+ Vector(0,0,20))
	end
	util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(2,2,2), self:GetPos() - Vector(2,2,2))
	self:TransformRagdoll( dmginfo )
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	
	if ( dmginfo:IsBulletDamage() ) then
		local trace = {}
		trace.start = attacker:GetShootPos()			
		trace.endpos = trace.start + ( ( dmginfo:GetDamagePosition() - trace.start ) * 2 )  
		trace.mask = MASK_SHOT
		trace.filter = attacker
			
		local tr = util.TraceLine( trace )
		hitgroup = tr.HitGroup
						
	end	
	
	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
	
	-- if ( dmginfo:IsDamageType(DMG_CLUB) ) then
	-- if hitgroup == HITGROUP_HEAD then
		-- dmginfo:ScaleDamage(2)
		-- else
		-- dmginfo:ScaleDamage(0.7)
	-- end	
	-- end
	
	
	-- if ( dmginfo:IsDamageType(DMG_SLASH) ) then
	-- if hitgroup == HITGROUP_HEAD then
		-- dmginfo:ScaleDamage(2)
		-- else
		-- dmginfo:ScaleDamage(0.7)
	-- end	
	-- end
	
	if hitgroup == HITGROUP_HEAD then
		self:EmitSound("hits/headshot_"..math.random(9)..".wav", 60)
		dmginfo:ScaleDamage(2) --more damage
    else
	    dmginfo:ScaleDamage(0.6) --less damage
	end
	
	-- print(dmginfo:GetDamage())

end

function ENT:FootSteps()
	self:EmitSound( 'respite/spore/foot'  .. math.random(1,5) .. '.wav', 65, math.random(90,100) )
end