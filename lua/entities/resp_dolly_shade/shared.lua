if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "resp_dolly"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "resp_dolly_shade", {
	Name = "Dolly Shade",
	Class = "resp_dolly_shade",
	Category = "Respite - Shade"
} )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:CustomDeath()
    util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	
	if (math.random(1,5) == 1) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end
	
	SafeRemoveEntity(self)
end

function ENT:OnSpawn()
	self:Shadow()
end