if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "scarlet"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

list.Set( "NPC", "scarlet_shade", {
	Name = "Scarlet Shade",
	Class = "scarlet_shade",
	Category = "Respite - Shade"
} )

ENT.classname = "scarlet_shade"
ENT.NiceName = "Scarlet Shade"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:CustomDeath( dmginfo )
	if (math.random(0,4) == 4) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end
	util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	SafeRemoveEntity(self)
end

function ENT:OnSpawn()
	self:Shadow()
end