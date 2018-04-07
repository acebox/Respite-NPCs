if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_haunt", {
	Name = "Haunt",
	Class = "nz_haunt",
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

ENT.health = 80
ENT.Damage = 8
ENT.HitPerDoor = 5

ENT.PhysForce = 2000
ENT.AttackRange = 120
ENT.InitialAttackRange = 110
ENT.DoorAttackRange = 80

ENT.NextAttack = 1

ENT.AttackFinishTime = 0.8

ENT.pitch = 45
ENT.volume = 90

ENT.memoryPos = nil

--Model Settings--
ENT.Model = "models/tnb/citizens/male_04.mdl"

ENT.models = {
	"models/tnb/citizens/male_04.mdl",
	"models/player/zombie_classic.mdl",
	"models/player/soldier_stripped.mdl",
	"models/player/corpse1.mdl"
}

ENT.WalkAnim = "zombie_walk_01"
ENT.AttackAnim = "zombie_attack_01"

ENT.AttackAnims = {
	"zombie_attack_01_original",
	"zombie_attack_02_original",
	"zombie_attack_06_original"
}

ENT.WalkAnims = {
	"zombie_walk_01",
	"zombie_walk_02",
	"zombie_walk_03",
	"zombie_walk_04",
	"zombie_walk_05",
	"zombie_walk_06"
}

ENT.IdleAnim = "zombie_idle_01" 

ENT.SearchRadius = 1000

--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"ambient/machines/squeak_1.wav",
	"ambient/machines/squeak_2.wav",
	"ambient/machines/squeak_3.wav",
	"ambient/machines/squeak_4.wav",
	"ambient/machines/squeak_5.wav",
	"ambient/machines/squeak_6.wav",
	"ambient/machines/squeak_7.wav",
	"ambient/machines/squeak_8.wav"
}

ENT.deathSounds = {
	"ambient/misc/creak1.wav",
	"ambient/misc/creak2.wav",
	"ambient/misc/creak3.wav",
	"ambient/misc/creak4.wav",
	"ambient/misc/creak5.wav"
}

ENT.alertSounds = {
	"ambient/misc/metal_rattle1.wav",
	"ambient/misc/metal_rattle3.wav",
	"ambient/misc/metal_rattle4.wav"
}

ENT.idleSounds = {
	"ambient/misc/metal_str1.wav",
	"ambient/misc/metal_str2.wav",
	"ambient/misc/metal_str3.wav",
	"ambient/misc/metal_str4.wav",
	"ambient/misc/metal_str5.wav"
}

ENT.painSounds = {
	"ambient/weather/thunder1.wav",
	"ambient/weather/thunder2.wav",
	"ambient/weather/thunder3.wav",
	"ambient/weather/thunder4.wav",
	"ambient/weather/thunder5.wav",
	"ambient/weather/thunder6.wav"
}

ENT.hitSounds = {
	"ambient/misc/metal2.wav",
	"ambient/misc/metal3.wav",
	"ambient/misc/metal6.wav",
	"ambient/misc/metal7.wav",
	"ambient/misc/metal8.wav",
	"ambient/misc/metal9.wav"
}

ENT.missSounds = {
	"npc/zombie/claw_miss1.wav"
}

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	if SERVER then
	
	self.TV=ents.Create("prop_physics")
	self.TV:SetModel("models/props_c17/tv_monitor01.mdl")
	self.TV:SetPos(self:GetPos())
	self.TV:SetParent(self, 1)
	self.TV:SetMoveType(MOVETYPE_NONE)
	self.TV:SetMaterial("models/props_lab/security_screens")
	
	self.WalkAnim = table.Random(self.WalkAnims)
	
	--Stats--
	self:SelectModel()
	self:SetHealth(self.health)	
	self:SetMaterial("models/props_lab/security_screens")
	self:SetBloodColor(DONT_BLEED)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	
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
	if (math.random(0,2) == 2) then
		nut.item.spawn("j_scrap_memory", self:GetPos() + Vector(0,0,20))
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
		local ranColor = math.random(100,255)
		--self:SetColor( Color( ranColor, ranColor, ranColor, 255 ) )
		self.nextAlpha = CurTime() + 1
	end
end

function ENT:CustomAttack()
	self.AttackAnim = self.AttackAnims[ math.random( #self.AttackAnims ) ]
end
		
ENT.nextReturn = 0
function ENT:CustomThink()
	if(self.Enemy) then
		if(self.nextReturn < CurTime()) then
			if(!self.memoryPos) then
				self.memoryPos = self:GetPos()
			else
				self:SetPos(self.memoryPos)
				self:PainSound()
				self:Enrage()
				
				timer.Simple(5, function()
					if(self:IsValid()) then
						self:Calm()
					end
				end)
				
				self.memoryPos = nil
			end
			self.nextReturn = CurTime() + math.random(2,3)
		end
	end
end

--get mad
function ENT:Enrage()
	self.Speed = 400
	self.WalkSpeedAnimation = 5
end

function ENT:Calm() --unenrage
	self.Speed = 40
	self.WalkSpeedAnimation = 1
end

function ENT:CheckProp( ent )
	return false
end
