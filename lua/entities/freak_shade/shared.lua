if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "freak"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "freak_shade", {
	Name = "Deformed Shade",
	Class = "freak_shade",
	Category = "Respite - Shade"
} )

ENT.classname = "freak_shade"
ENT.NiceName = "Deformed Shade"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:CustomDeath( dmginfo )
	if (math.random(0,4) == 4) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end
	util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	self:Remove()
end

--makes npcs look like different, call in OnSpawn()
function ENT:Shadow()
	--you need to put ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	--for this to work properly
	self.pitch = self.pitch - 30
	self:SetBloodColor(DONT_BLEED)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(0,0,0))
	self:SetRenderFX(kRenderFxDistort)
end

function ENT:OnSpawn()
	self:SetMaterial("models/effects/portalrift_sheet")
	self:Shadow()
end