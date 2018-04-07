AddCSLuaFile();

list.Set( "NPC", "resp_vomit_shade", {
	Name = "Vomit Shade",
	Class = "resp_vomit_shade",
	Category = "Respite - Shade"
} )

ENT.classname = "resp_vomit_shade"
ENT.Base = "resp_vomit";

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:CustomDeath( dmginfo )
	
    util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	if (math.random(0,2) == 2) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end
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