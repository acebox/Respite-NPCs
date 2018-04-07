if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "resp_kuszo"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

ENT.Model = "models/Zombie/kuszo.mdl"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

--SpawnMenu--
list.Set( "NPC", "resp_kuszo_shade", {
	Name = "Ghoul Shade",
	Class = "resp_kuszo_shade",
	Category = "Respite - Shade"
} )

--makes npcs look like different, call in OnSpawn()
function ENT:Shadow()
	--you need to put ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	--for this to work properly
	self.pitch = self.pitch - 40
	self:SetBloodColor(DONT_BLEED)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(0,0,0))
	self:SetRenderFX(kRenderFxDistort)
end


function ENT:CustomDeath(dmginfo)

	if (math.random(0,2) == 2) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end
	
    SafeRemoveEntity(self)
end

function ENT:OnSpawn()
	self:SetMaterial("models/effects/portalrift_sheet")
	self:Shadow()
end
