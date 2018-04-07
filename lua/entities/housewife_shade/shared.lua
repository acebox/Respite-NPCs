if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "housewife"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

--SpawnMenu--
list.Set( "NPC", "housewife_shade", {
	Name = "Housewife Shade",
	Class = "housewife_shade",
	Category = "Respite - Shade"
} )

ENT.classname = "housewife_shade"
ENT.NiceName = "Housewife Shade"

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