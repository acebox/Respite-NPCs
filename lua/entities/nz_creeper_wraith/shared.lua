if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "nz_creeper"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_creeper_wraith", {
	Name = "Creeper (Wraith)",
	Class = "nz_creeper_wraith",
	Category = "Respite - Wraith"
} )

ENT.Speed = 250
ENT.health = 50
ENT.Damage = 5

ENT.WalkAnim = (ACT_RUN)

--makes npcs look like different, call in OnSpawn()
function ENT:Shadow()
	--you need to put ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	--for this to work properly
	self.pitch = self.pitch - 100
	self:SetBloodColor(DONT_BLEED)
end

function ENT:OnSpawn()
	self:SetMaterial("models/props_combine/tpballglow")
	self:Shadow()
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,2) == 2) then
		nut.item.spawn("ichor", self:GetPos()+ Vector(0,0,20))
	end		
	SafeRemoveEntity(self)
end

ENT.nextAlpha = 0

function ENT:CustomThink()
	if(self.nextAlpha <= CurTime()) then
		local ranColor = math.random(0,255)
		self:SetColor( Color( ranColor, ranColor, ranColor, 255 ) )
		self.nextAlpha = CurTime() + 1
	end
end

function ENT:CustomThinkClient()
	if CLIENT then
		local pos = self:GetPos() + self:GetUp()
		local dlight = DynamicLight(self:EntIndex())
		dlight.Pos = pos
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.Brightness = 1
		dlight.Size = 32
		dlight.Decay = 64
		dlight.style = 5
		dlight.DieTime = CurTime() + .1
	end
end
