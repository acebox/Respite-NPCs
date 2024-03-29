if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "chance_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_creeper", {
	Name = "Creeper",
	Class = "nz_creeper",
	Category = "Respite"
} )

--Stats--
ENT.FootAngles = 10
ENT.FootAngles2 = 10
ENT.UseFootSteps = 1

ENT.CollisionHeight = 64
ENT.CollisionSide = 7

ENT.Speed = 70
ENT.WalkSpeedAnimation = .5
ENT.FlinchSpeed = 0

ENT.health = 300
ENT.Damage = 20

ENT.PhysForce = 15000
ENT.AttackRange = 70
ENT.DoorAttackRange = 25

ENT.NextAttack = 1

ENT.pitch = 150
ENT.pitchVar = 10
ENT.wanderType = 3

--Model Settings--
ENT.Model = "models/nh2zombies/creeper.mdl"

ENT.AttackAnim = (ACT_MELEE_ATTACK1)

ENT.IdleAnim = (ACT_IDLE)

ENT.WalkAnim = (ACT_WALK)
ENT.AttackAnim = (ACT_MELEE_ATTACK1)

ENT.FlinchAnim = (ACT_PHYS_FLINCH)

ENT.AttackDoorAnim = (ACT_MELEE_ATTACK1)

--Sounds--
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.attackSounds = {
	"NH2/screamerzombie2.mp3",
	"NH2/screamerzombie3.mp3"
}

ENT.alertSounds = {
	"npc/leperkin/stage2_alertfar1.mp3",
	"npc/leperkin/stage2_alertfar2.mp3",
	"npc/leperkin/stage2_alertfar3.mp3",
	"npc/demon/nhdemon_fz_scream1.wav"
}

ENT.deathSounds = {
	"NH2/screamerzombie1.mp3",
	"NH2/demonsnew.mp3",
	"chorror/cryscreams.mp3"
}

ENT.idleSounds = {
	"NH2/screamerzombie2.mp3",
	"NH2/screamerzombie3.mp3"
}

ENT.painSounds = {
	"npc/demon/nhdemon_fz_frenzy1.wav"
}

ENT.hitSounds = {
	"npc/demon/nhdemon_claw_strike3.wav"
}

ENT.missSounds = {
	"npc/demon/nhdemon_claw_miss1.wav"
}

function ENT:Initialize()

	if SERVER then

	--Stats--
	self:SetBloodColor(DONT_BLEED)
	self:SetModel(self.Model)
	self:SetMaterial("models/alyx/emptool_glow")
	self:SetColor(Color(128,0,0))
	
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderFX(kRenderFxHologram)
	self:SetHealth(self.health)	
	
	self.IsAttacking = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(900)
	self.loco:SetDeceleration(900)
	
	--Misc--
	self:Precache()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_PLAYER )
	self:StartActivity(self.WalkAnim)
	
	self.Summons = {}
	end
	
end

function ENT:CustomDeath( dmginfo )
	for k, v in pairs(self.Summons) do
		if(v:IsValid()) then
			v:TakeDamage(100, self, self)
		end
	end

	if (math.random(1,8) == 1) then
		nut.item.spawn("shard_dust", self:GetPos()+ Vector(0,0,20))
	end
	SafeRemoveEntity(self)
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

function ENT:CustomThinkClient()
	if CLIENT then
		local pos = self:GetPos() + self:GetUp()
		local dlight = DynamicLight(self:EntIndex())
		dlight.Pos = pos
		dlight.r = 128
		dlight.g = 0
		dlight.b = 0
		dlight.Brightness = 1
		dlight.Size = 32
		dlight.Decay = 64
		dlight.style = 5
		dlight.DieTime = CurTime() + .1
	end
end

ENT.ragdollThink = 0
function ENT:CustomThink()
	if(self.ragdollThink < CurTime()) then
		local search = ents.FindInSphere(self:GetPos(), 1000)
		for k, v in pairs(search) do
			if(v:GetClass() == "prop_ragdoll") then
				ParticleEffectAttach("striderbuster_shotdown_trail", 1, v, 1)
				v:EmitSound("ambient/machines/electric_machine.wav", 75, 100)
				timer.Simple(3, function()
					if(!self) then return end
					v:EmitSound("ambient/energy/zap" ..math.random(1,3).. ".wav", 75, 50)
					for i=1,8 do
						local flesh = ents.Create("flesh_ball") 
						if flesh:IsValid() then
							flesh:SetPos( v:GetPos() + Vector(0,0,20) )
							flesh:SetOwner(self)
							flesh:Spawn()
						
							flesh.DeathTime = CurTime() + 1.5
			
							local phys = flesh:GetPhysicsObject()
							if phys:IsValid() then
								local ang = self:EyeAngles()
								ang:RotateAroundAxis(ang:Forward(), math.Rand(-205, 205))
								ang:RotateAroundAxis(ang:Up(), math.Rand(-205, 205))
								phys:SetVelocityInstantaneous(ang:Forward() * math.Rand( 200, 250 ))
							end
						end
					end
					
					local summon = ents.Create("resp_kuszo")
					summon:SetPos( v:GetPos() + Vector(0,0,20) )
					summon:SetOwner(self)
					summon.pitch = summon.pitch + 50
					summon:Spawn()
					
					summon:SetMaterial("models/props_lab/warp_sheet")
					summon:SetColor(Color(190,0,0))
					summon:SetHealth(10)
					
					table.insert(self.Summons, summon)
					
					v:Remove()
				end)
				break
			end
		end
		
		self.ragdollThink = CurTime() + 5
	end
end

function ENT:OnRemove()
	if(SERVER) then
		for k, v in pairs(self.Summons) do
			if(v:IsValid()) then
				v:Remove()
			end
		end
	end
end