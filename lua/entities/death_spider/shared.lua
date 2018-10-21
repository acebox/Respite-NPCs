if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "nz_deathanim_base"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false
ENT.AutomaticFrameAdvance = true 

function ENT:Initialize()
	self:SetHealth( self.health )
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
end

function ENT:RunBehaviour()
	while ( true ) do	
	if SERVER then
	
	self:PlaySequenceAndWait( "die1", 1 ) 
	
	coroutine.wait( 120 )
	
	self:Remove()
	end
	end
end	