AddCSLuaFile();

list.Set( "NPC", "resp_dolly_big", {
	Name = "Dolly (Big)",
	Class = "resp_dolly_big",
	Category = "Respite"
} )

ENT.classname = "resp_dolly_big"
ENT.Base = "resp_dolly"

ENT.health = 60

function ENT:CustomDeath( dmginfo )
	if (math.random(0,2) == 2) then
		nut.item.spawn("j_scrap_plastics", self:GetPos()+ Vector(0,0,20))
	end
	
	ent = ents.Create("resp_dolly")	
	local pos = self:EyePos() + Vector(0,0,10)
	ent:SetPos(pos)
	ent:Spawn()
	timer.Simple(0.8, 
		function()
			ent = ents.Create("resp_dolly")	
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