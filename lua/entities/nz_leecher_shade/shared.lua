if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "nz_leecher"
ENT.Spawnable        = true
ENT.AdminSpawnable   = true

--SpawnMenu--
list.Set( "NPC", "nz_leecher_shade", {
	Name = "Leecher Shade",
	Class = "nz_leecher_shade",
	Category = "Respite - Shade"
} )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

--makes npcs look like different, call in OnSpawn()
function ENT:Shadow()
	--you need to put ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	--for this to work properly
	self.pitch = self.pitch - 20
	self:SetBloodColor(DONT_BLEED)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(0,0,0))
	self:SetRenderFX(kRenderFxDistort)
end

function ENT:OnSpawn()
	self:Shadow()
end

function ENT:Initialize()
alpha = Color(0,0,0,0)
	if SERVER then
	self:Precache()
	--Stats--
	self:SetBloodColor(DONT_BLEED)
	self.isShadow = false
	self:SetModel(self.Model)
	self:SetHealth(self.health)	
	
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(0,0,0))
	self:SetRenderFX(kRenderFxDistort)
	self:SetMaterial("models/alyx/emptool_glow")	
	
	self.LoseTargetDist	= (self.LoseTargetDist)
	self.SearchRadius 	= (self.SearchRadius)
	self.IsAttacking = false
	self.HasNoEnemy = false
	self.BrokeLeg = false
	self.Flinching = false
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(400)
	self.loco:SetDeceleration(900)
    self.OverlayModel = ents.Create("prop_dynamic")
        zm = self.OverlayModel
	    zm:SetParent(self)
		zm:SetModel( self.BoneMergeModel )
		zm.RenderGroup = RENDERGROUP_TRANSLUCENT
		zm:SetRenderMode(RENDERMODE_TRANSALPHA)
		zm:SetColor(Color(0,0,0))
		zm:SetRenderFX(kRenderFxDistort)

		zm:AddEffects(EF_BONEMERGE, EF_BONEMERGE_FASTCULL, EF_PARENT_ANIMATES )
	    zm:SetBodygroup(1,1)
		self:SetModelScale( 2, 0 )
      
	   self:PhysicsInitShadow(true, false)
	--Misc--
	
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	end
end

function ENT:CustomDeath( dmginfo )	
	self:EmitSound("npc/barnacle/barnacle_bark1.wav",90,math.random(20,40))
	self:EmitSound("npc/barnacle/barnacle_crunch2.wav",90,math.random(20,40))
	self:EmitSound("npc/barnacle/barnacle_crunch3.wav",90,math.random(20,40))
	self:EmitSound("npc/barnacle/barnacle_bark2.wav",90,math.random(20,40))
	
	if (math.random(0,2) == 2) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end		
	
	ent = ents.Create("resp_leecher_small_shade")	
	ent:SetPos(self:EyePos() + Vector(0,0,25) )
	ent:Spawn()
	ent:SetEnemy(self.Enemy)
	
	util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	SafeRemoveEntity(self)
end
