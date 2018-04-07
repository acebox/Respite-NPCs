if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "pack"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

list.Set( "NPC", "pack_shade", {
	Name = "Pack Shade",
	Class = "pack_shade",
	Category = "Respite - Shade"
} )

ENT.classname = "pack_shade"
ENT.NiceName = "Pack Shade"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:CustomDeath( dmginfo )
	if (math.random(0,4) == 4) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end
	util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	SafeRemoveEntity(self)
end

--makes npcs look like different, call in OnSpawn()
function ENT:Shadow()
	--you need to put ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	--for this to work properly
	self.pitch = self.pitch - 50
	self:SetBloodColor(DONT_BLEED)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(0,0,0))
	self:SetRenderFX(kRenderFxDistort)
end


function ENT:OnSpawn()
	self:Shadow()
end