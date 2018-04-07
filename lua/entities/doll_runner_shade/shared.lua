if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "doll_runner"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "doll_runner_shade", {
	Name = "Doll Shade (Running)",
	Class = "doll_runner_shade",
	Category = "Respite - Shade"
} )

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