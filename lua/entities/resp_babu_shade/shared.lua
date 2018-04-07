AddCSLuaFile();

list.Set( "NPC", "resp_babu_shade", {
	Name = "Babu Shade",
	Class = "resp_babu_shade",
	Category = "Respite - Shade"
} )

ENT.classname = "resp_babu_shade"
ENT.Base = "resp_babu"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

--disabled for now
function ENT:Summon()
end

function ENT:OnSpawn()
	self:Shadow()
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,2) == 2) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end
	self:Remove()
end