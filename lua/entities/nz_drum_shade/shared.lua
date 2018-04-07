if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "nz_drum"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_drum_shade", {
	Name = "Drum (Shade)",
	Class = "nz_drum_shade",
	Category = "Respite - Shade"
} )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:OnSpawn()
	self:SetMaterial("")
	self:Shadow()
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,2) == 2) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end
    util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	SafeRemoveEntity(self)
end


function ENT:CustomDeath( dmginfo )
	--self:DeathAnimation( "nz_deathanim_zss", self:GetPos(), ACT_HL2MP_WALK_CROUCH_ZOMBIE_05, self.ModelScale )
	for k, v in pairs(self.Summons) do
		if(v:IsValid()) then
			v:TakeDamage(100, self, self)
		end
	end
	--if (math.random(0,1) == 1) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	--end
	util.Decal("scorch" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	
	SafeRemoveEntity(self)
end


function ENT:ThrowGrenade( velocity )
	posSummons = {}
	posSummons[1] = "shade_crawlsmoke"

	local ent = ents.Create(table.Random(posSummons))
	
	table.insert(self.Summons, ent)
	
	if ent:IsValid() and self:IsValid() then
		ent:SetPos(self:EyePos() + Vector(0,0,15) - ( self:GetRight() * 25 ) + ( self:GetForward() * 10 ) )
		ent:Spawn()
		ent:SetOwner( self )
		timer.Simple(1,
			function()
				ent:SetEnemy(self.Enemy)
			end
		)
		--local phys = ent:GetPhysicsObject()
		
		--if phys:IsValid() then
		
			local ang = self:EyeAngles()
			ang:RotateAroundAxis(ang:Forward(), math.Rand(-10, 10))
			ang:RotateAroundAxis(ang:Up(), math.Rand(-10, 10))
			--phys:SetVelocityInstantaneous(ang:Forward() * math.Rand( velocity, velocity + 300 ))
				
		--end
		self:EmitSound( "npc/zombie_poison/pz_throw" ..math.random(2,3).. ".wav", 100, math.random(30,40) )
		util.Decal("scorch" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	end
	
end

function ENT:CustomChaseEnemy()
	local enemy = self:GetEnemy()
	
	if (!IsValid(enemy)) then return end
	if self.Attacking then return end
	
	if self:IsLineOfSightClear( enemy ) then
	
		if (table.Count(self.Summons) < 5 and self:GetRangeTo( enemy ) > self.InitialAttackRange and self:GetRangeTo( enemy ) < 600) then
		
			if ( self.NextThrow or 0 ) < CurTime() then
	
				self:RestartGesture( ACT_GMOD_GESTURE_TAUNT_ZOMBIE )
				self.Throwing = true
	
				timer.Simple( 0.6, function()
					if !self:IsValid() then return end
					if self:Health() < 0 then return end
					if self.Attacking then return end
					self:ThrowGrenade( math.random(500, 600) )
					self.Throwing = false
				end)
			
				self.NextThrow = CurTime() + 5
			end
		end	
	end
end