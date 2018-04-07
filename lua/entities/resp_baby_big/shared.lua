AddCSLuaFile();

list.Set( "NPC", "resp_baby_big", {
	Name = "Baby (Big)",
	Class = "resp_baby_big",
	Category = "Respite"
} )

ENT.classname = "resp_baby_big"
ENT.Base = "resp_baby"

ENT.health = 50

function ENT:CustomDeath( dmginfo )
	if (math.random(0,2) == 2) then
		nut.item.spawn("j_scrap_plastics", self:GetPos()+ Vector(0,0,5))
	end
	if (math.random(0,6) == 6) then
		nut.item.spawn("hl2_m_boneshiv", self:GetPos()+ Vector(0,0,5))
	end
	
	ent = ents.Create("resp_baby")	
	local pos = self:EyePos() + Vector(0,0,10)
	ent:SetPos(pos)
	ent:Spawn()
	timer.Simple(0.7, 
		function()
			ent = ents.Create("resp_baby")	
			ent:Spawn()
			ent:SetPos(pos)
		end
	)
	
	self:TransformRagdoll()
end

function ENT:OnSpawn()
	self:SetModelScale( 1.8 )
	self.pitch = self.pitch - 20
end