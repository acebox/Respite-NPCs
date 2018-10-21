if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "amputated"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false


list.Set( "NPC", "amputated_shade", {
	Name = "Amputated Shade",
	Class = "amputated_shade",
	Category = "Respite - Shade"
} )

ENT.classname = "amputated_shade"
ENT.NiceName = "Amputated Shade"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:OnSpawn()
	self:Shadow()
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,8) == 8) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end
	
	util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	SafeRemoveEntity(self)
end