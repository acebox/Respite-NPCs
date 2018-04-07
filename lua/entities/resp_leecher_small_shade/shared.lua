if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "resp_leecher_small"
ENT.Spawnable        = true
ENT.AdminSpawnable   = true

--SpawnMenu--
list.Set( "NPC", "resp_leecher_small_shade", {
	Name = "Leecher Shade(Small)",
	Class = "resp_leecher_small_shade",
	Category = "Respite - Shade"
} )

ENT.pitch = 50

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:CustomDeath( dmginfo )
    util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	if (math.random(0,2) == 2) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end		

	SafeRemoveEntity(self)
end

function ENT:Initialize()

	if SERVER then
	--Stats--
	self:SetBloodColor(DONT_BLEED)
	self:SetModel(self.Model)
	self:SetHealth(self.health)	
	
	self.IsAttacking = false
	self.Flinching = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(400)
	self.loco:SetDeceleration(900)
  
     self.OverlayModel = ents.Create("prop_dynamic")
        zm=self.OverlayModel
	    zm:SetParent(self)
		zm:SetModel( self.BoneMergeModel )
		zm.RenderGroup = RENDERGROUP_TRANSLUCENT
		zm:SetColor(Color(0,0,0))
		zm:SetRenderFX(kRenderFxDistort)
		
		zm:AddEffects(EF_BONEMERGE)
	    zm:SetBodygroup(1,1)
      
	  self:PhysicsInitShadow(true, true)
	--Misc--
		self:Precache()
		self:SetMaterial("null")
		self:SetColor( Color( 0, 0, 0, 0 ) )
		self:SetRenderMode( RENDERMODE_TRANSALPHA ) 
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetMaterial("models/effects/portalrift_sheet")	
		self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	end
end
