AddCSLuaFile();

list.Set( "NPC", "resp_babu_wraith", {
	Name = "Babu Wraith",
	Class = "resp_babu_wraith",
	Category = "Respite - Wraith"
} )

ENT.classname = "resp_babu_broken"
ENT.Base = "resp_babu"
ENT.Speed = 400


ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.alertSounds = {
	"cof/slower3/slower_alert10.wav",
	"cof/slower3/slower_alert20.wav",
	"cof/slower3/slower_alert30.wav"

}

--disabled for now
function ENT:Summon()
end

--makes npcs look like different, call in OnSpawn()
function ENT:Shadow()
	--you need to put ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	--for this to work properly
	self.pitch = self.pitch + 80
	self:SetBloodColor(DONT_BLEED)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderFX(kRenderFxDistort)
end

function ENT:OnSpawn()
	self.Speed = math.random(5,100)
	self:SetMaterial("models/props_lab/security_screens")
	self:Shadow()
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,2) == 2) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end
	self:TransformRagdoll()
end

function ENT:OnAlert()
	self.wanderType = 1
	self.Speed = 400
end