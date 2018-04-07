if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "nz_leperkin"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_leperkin_shade", {
	Name = "Hunter Shade",
	Class = "nz_leperkin_shade",
	Category = "Respite - Shade"
} )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

--makes npcs look like different, call in OnSpawn()
function ENT:Shadow()
	--you need to put ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	--for this to work properly
	self.pitch = self.pitch - 60
	self:SetBloodColor(DONT_BLEED)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(0,0,0))
	self:SetRenderFX(kRenderFxDistort)
end

function ENT:OnSpawn()
	self:Shadow()
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,4) == 4) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end		
    util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	SafeRemoveEntity(self)
end