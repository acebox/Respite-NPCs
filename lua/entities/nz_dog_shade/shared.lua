if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "nz_dog"
ENT.Spawnable        = true
ENT.AdminSpawnable   = true

--SpawnMenu--
list.Set( "NPC", "nz_dog_shade", {
	Name = "Dog Shade",
	Class = "nz_dog_shade",
	Category = "Respite - Shade"
} )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:OnSpawn()
	self:Shadow()
end

function ENT:CustomDeath( dmginfo )
	if (math.random(1,4) == 1) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end
	self:Remove()
end