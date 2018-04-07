if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "nz_thrower"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_thrower_shade", {
	Name = "Thrower Shade",
	Class = "nz_thrower_shade",
	Category = "Respite - Shade"
} )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:OnSpawn()
	self:SetMaterial("")
	self:Shadow()
end

function ENT:CustomDeath( dmginfo )
	for i=1,4 do
	flesh = ents.Create("shadow_ball") 
		if flesh:IsValid() then
		flesh:SetPos(self:EyePos())
		flesh:SetOwner(self)
		flesh:Spawn()
	
		local phys = flesh:GetPhysicsObject()
			if phys:IsValid() then
				local ang = self:EyeAngles()
				ang:RotateAroundAxis(ang:Forward(), math.Rand(-100, 100))
				ang:RotateAroundAxis(ang:Up(), math.Rand(-100, 100))
				phys:SetVelocityInstantaneous(ang:Forward() * math.Rand(225, 390))
			end
		end
	end
	
	if (math.random(0,2) == 2) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end		
	util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	SafeRemoveEntity(self)
end

function ENT:ThrowGrenade( velocity )

	local ent = ents.Create("shadow_ball")
	
	if ent:IsValid() and self:IsValid() then
		ent:SetPos(self:EyePos() + Vector(0,0,30) - ( self:GetRight() * 25 ) + ( self:GetForward() * 10 ) )
		ent:Spawn()
		ent:SetOwner( self )
				
		local phys = ent:GetPhysicsObject()
		
		if phys:IsValid() then
			local ang = self:EyeAngles()
			ang:RotateAroundAxis(ang:Forward(), math.Rand(-10, 10))
			ang:RotateAroundAxis(ang:Up(), math.Rand(-10, 10))
			phys:SetVelocityInstantaneous(ang:Forward() * math.Rand( velocity, velocity + 200 ))	
		end
	end
end

function ENT:EjectBlood( dmginfo, amount, reduction )
end