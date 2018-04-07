if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "resp_floater"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "resp_floater_shade", {
	Name = "Floater Shade",
	Class = "resp_floater_shade",
	Category = "Respite - Shade"
} )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:CustomDeath()
    util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	
	if (math.random(0,6) == 6) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end		
	
	if (math.random(0,10) == 10) then
		nut.item.spawn("hl2_m_boneshiv", self:GetPos()+ Vector(0,0,20))
	end
	
	SafeRemoveEntity(self)
end

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