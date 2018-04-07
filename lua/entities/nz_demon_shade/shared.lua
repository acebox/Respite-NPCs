if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "nz_demon"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "nz_demon_shade", {
	Name = "Demon Shade",
	Class = "nz_demon_shade",
	Category = "Respite - Shade"
} )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:OnSpawn()
	self:Shadow()
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,4) == 4) then
		nut.item.spawn("j_scrap_memory", self:GetPos()+ Vector(0,0,20))
	end
	util.Decal("scorch", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	self:Remove()
end

function ENT:MeleeAttack( ent )

	if !self:CheckStatus() then return end

	self:RestartGesture( self.AttackAnim )
	
	self:AttackEffect( 0.1, self.Enemy, self.Damage, 0 )
	
end

function ENT:Attack()
		
	if ( self.NextAttackTimer or 0 ) < CurTime() then	
		
		if ( (self.Enemy:IsValid() and self.Enemy:Health() > 0 ) ) then
		
			if !self:CheckStatus() then return end	
		
			self:AttackSound()
			
			self:MeleeAttack( self.Enemy )
		
		end
		
		self.NextAttackTimer = CurTime() + self.NextAttack
	end		
		
end