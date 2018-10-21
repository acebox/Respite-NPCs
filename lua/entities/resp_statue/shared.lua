AddCSLuaFile();

list.Set( "NPC", "resp_statue", {
	Name = "Statue",
	Class = "resp_statue",
	Category = "Respite - Experimental"
} )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Base = "base_nextbot";
ENT.Spawnable        = false
ENT.AdminSpawnable   = false
ENT.Model = "models/props_mall/mall_mannequin_female_torso3.mdl"
ENT.painSound = "sh2/nurse/nurse_stun_01.wav"
ENT.health = 500

sound.Add( {
	name = "loop1",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 70,
	pitch = {70, 85},
	sound = "ambient/energy/force_field_loop1.wav"
} )

function ENT:Precache()

	util.PrecacheModel(self.Model)
	util.PrecacheSound(self.painSound)

end

function ENT:Initialize()

    if SERVER then
    
	self:Precache()
	self:SetModel(self.Model)
	self:SetHealth(self.health)	
	self:SetModelScale( 1.8, 0 )
	self:Shadow()
	
	self.Summons = {}
	
	end
	
end

function ENT:OnInjured( dmginfo )

		local bleed = ents.Create("info_particle_system")
		bleed:SetKeyValue("effect_name", "striderbuster_attach")
		bleed:SetParent(self)
		bleed:SetPos( self:GetPos() )
		bleed:Spawn()
		bleed:Activate()
		bleed:Fire("Start", "", 0)
		bleed:Fire("Kill", "", 3)
		
		self:EmitSound(self.painSound, 70, math.random(95,105))
		
end

function ENT:Shadow()

	self:SetBloodColor(DONT_BLEED)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderFX(kRenderFxDistort)
	self:SetMaterial("models/shadertest/shader4")
	self.Ignites = false
	
end

ENT.ragdollThink = 0

function ENT:Summon()

if(self.ragdollThink < CurTime()) then

		local search = ents.FindInSphere(self:GetPos(), 800)
		for k, v in pairs(search) do
			if(v:GetClass() == "prop_ragdoll") then
				ParticleEffectAttach("striderbuster_shotdown_trail", 1, v, 1)
				v:EmitSound( "loop1" )
				timer.Simple(3, function()
					if(!self) then return end
					v:EmitSound("ambient/energy/zap" ..math.random(1,3).. ".wav", 75, 50)
					v:StopSound("loop1")
					for i=1,8 do
						local flesh = ents.Create("flesh_ball") 
						if flesh:IsValid() then
							flesh:SetPos( v:GetPos() + Vector(0,0,20) )
							flesh:SetOwner(self)
							flesh:Spawn()
						
							flesh.DeathTime = CurTime() + 2
			
							local phys = flesh:GetPhysicsObject()
							if phys:IsValid() then
								local ang = self:EyeAngles()
								ang:RotateAroundAxis(ang:Forward(), math.Rand(-205, 205))
								ang:RotateAroundAxis(ang:Up(), math.Rand(-205, 205))
								phys:SetVelocityInstantaneous(ang:Forward() * math.Rand( 200, 250 ))
							end
						end
					end
					
					local summon = ents.Create("spore")
					summon:SetPos( v:GetPos() + Vector(0,0,20) )
					summon:SetOwner(self)
					summon.pitch = summon.pitch + 40
					summon:Spawn()
					
					summon:SetMaterial("models/props_lab/warp_sheet")
					summon:SetColor(Color(100,0,0))
					summon:SetHealth(120)
					
					table.insert(self.Summons, summon)
					
					v:Remove()
				end)
				break
			end
		end
		
		self.ragdollThink = CurTime() + 5
		
	end
end



function ENT:OnKilled( dmginfo )

	for k, v in pairs(self.Summons) do
		if(v:IsValid()) then
			v:TakeDamage(1000, self, self)
		end
	end

	if (math.random(1,8) == 1) then
		nut.item.spawn("shard_dust", self:GetPos()+ Vector(0,0,20))
	end
	
	SafeRemoveEntity(self)
	
end


function ENT:RunBehaviour()

	while ( true ) do
	
	    self:Summon()
	
		coroutine.yield()
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