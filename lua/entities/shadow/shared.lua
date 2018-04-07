AddCSLuaFile();

list.Set( "NPC", "shadow", {
	Name = "Wandering Shadow",
	Class = "shadow",
	Category = "Respite - Shade"
} )

MONSTRUM_FIEND_AffectedLights = {}

sound.Add( {
	name = "spook3",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 80,
	pitch = 50,
	sound = "respite/horror2.mp3"
} )


ENT.classname = "shadow"
ENT.NiceName = "Shadow"

ENT.Base = "base_nextbot";

ENT.Spawnable        = true
ENT.AdminSpawnable   = true
ENT.CollisionHeight = 75
ENT.CollisionSide = 17
ENT.Model = "models/Humans/Group01/Male_04.mdl"
ENT.MoveType = 3
ENT.WalkSpeedAnimation = 1.0
ENT.Speed = nil
ENT.Damage = nil
ENT.AttackRange = 80
ENT.DamageRange = 90
ENT.Dist = 370
ENT.AttackAnim = ACT_MELEE_ATTACK1
ENT.FS = 0
ENT.FSTime = 0
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

function ENT:Precache()
util.PrecacheModel(self.Model)
end


function ENT:Initialize()
	self.WalkAnim = "walk"
	self.Speed = 55
	self.Damage = 0
	self.FSTime = 0.51

	-- self:SetColor( Color (0, 0, 255, 5) )
	self:EmitSound( "spook3" )
	
	if SERVER then
	self:Precache()
	self:SetBloodColor(DONT_BLEED)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	
	self:SetModel(self.Model)
	self:SetMaterial("models/angelsaur/ghosts/shadow")
	self:SetHealth(999999999)	
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, 16  )
	self:PhysicsInitShadow(true, true)
	self.loco:SetStepHeight( 30 )
	self.loco:SetJumpHeight( 30 )
	self.loco:SetAcceleration( 100 )
	self.loco:SetDeceleration( 200 )
	self.WanderAttentionSpan = math.Rand( 3, 7 )
	self.ChaseAttentionSpan = math.Rand( 6, 10 )
		timer.Create( "fiend_reset_affected_lights", 0.05, 0, function() 
			for i, v in pairs( MONSTRUM_FIEND_AffectedLights ) do
				local ent = Entity( i )
				
				if !IsValid( ent ) then
					MONSTRUM_FIEND_AffectedLights[ i ] = nil
					continue
				end
				
				if v > CurTime() then
					ent:SetOn( math.random( 1, 4 ) == 1 )
					continue
				end

				//if ent:GetClass() == "gmod_light" then
					ent:SetOn( true )
				//end
				
				MONSTRUM_FIEND_AffectedLights[ i ] = nil
			end
		end )
	end
	ParticleEffectAttach("Advisor_Pod_Explosion_Smoke", 1, self, 1)
	self.PlayerPositions = { };
    self.teleportPos = self:GetPos()
    self.startPos = self:GetPos()
end

-- function ENT:ChooseRandPoses()
	-- self.RandPoses = {}
	
	-- for P=1, 4 do
		-- self.RandPoses[P] = Vector(math.Rand(-1,1),math.Rand(-1,1),0):GetNormalized()*math.random(30,100)
	-- end
-- end

-- function ENT:Draw()
	-- local TEMP_RealPos = self:GetPos()
	-- local TEMP_RealAng = self:GetAngles()
	-- local TEMP_RandVec = Vector(0,0,0)
	
	-- if(LocalPlayer():GetNWFloat("MayhemHorrorNPCEffects",0)>0&&LocalPlayer():Alive()) then
		-- if(!istable(self.RandPoses)) then
			-- self:ChooseRandPoses()
		-- end
		
		-- TEMP_RandVec = (VectorRand()*math.random(5,10))
		
		-- for P=1, #self.RandPoses do
			-- self:SetPos(TEMP_RealPos+self.RandPoses[P]+(VectorRand()*math.random(5,10)))
			-- self:SetAngles(TEMP_RealAng)
			-- self:SetupBones()
			-- self:DrawModel()
		-- end
		
	-- else
	    -- self.RandPoses = nil
	-- end

	-- self:SetPos(TEMP_RealPos+TEMP_RandVec)
	-- self:SetAngles(TEMP_RealAng)
	-- self:SetupBones()
	-- self:DrawModel()
	
	
	-- self:SetPos(TEMP_RealPos)
-- end


function ENT:CollisionSetup( collisionside, collisionheight, collisiongroup )
	self:SetCollisionGroup( collisiongroup )
	self:SetCollisionBounds( Vector(-collisionside,-collisionside,0), Vector(collisionside,collisionside,collisionheight) )
end

function ENT:MovementFunctions( type, act, speed, playbackrate )
	if type == 1 then
		self:StartActivity( act )
		self:SetPoseParameter("move_x", playbackrate )		
	elseif type == 2 then
		self:ResetSequence( act )
		self.IsMoving = true
		self:SetPlaybackRate( playbackrate )
		self:SetPoseParameter("move_x", playbackrate )
	elseif type == 3 then
     	self:ResetSequence( act )
        self:SetSequence(act)
		self:SetPoseParameter("move_x", playbackrate )
end
	self.loco:SetDesiredSpeed( speed )
end


function ENT:ResumeMovementFunctions()
	self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
end

function ENT:BehaveAct()

end

function ENT:Think()
	if SERVER then
			for i, v in pairs( ents.FindInSphere( self:GetPos(), 500 ) ) do
			if !IsValid( v ) then continue end
			if ( v:GetClass() == "gmod_light" || v:GetClass() == "gmod_lamp" ) && v:GetOn() then
				MONSTRUM_FIEND_AffectedLights[ v:EntIndex() ] = CurTime() + 1
			end
		end
end
end

function ENT:BodyUpdate()
	
	self:BodyMoveXY();
	
end

function ENT:OnKilled( dmginfo )
	SafeRemoveEntity( self )
	self:EmitSound("chorror/bass_walls.wav", 60, 50)
	self:StopSound( "spook3" )
end

function ENT:OnStuck()
end

function ENT:MovementThink()

	if self:WaterLevel() == 3 then
        self:Remove()
    end
	
	if ( self.loco:IsStuck() ) then
		
		if( !self.StuckTime ) then
			
			self.StuckTime = CurTime();
			
		end
		
        self.loco:Jump()
		
	else
		
		self.StuckTime = nil;
		
	end
	
	if( self.StuckTime and CurTime() >= self.StuckTime + 4 ) then
		
			
			self:Remove();
			return;
			
		
    end
	
	if self.FS == 1 then
	if !self.nxtThink then self.nxtThink = 0 end
	if ( self.loco:IsStuck() ) then return end
	if CurTime() < self.nxtThink then return end
	self:FootSteps()
	self.nxtThink = CurTime() + self.FSTime
	end

end

function ENT:FootSteps()
	
end


function ENT:TeleportLongThink()
	
	if( !self.NextTeleport ) then self.NextTeleport = CurTime(); end
	
	if( CurTime() >= self.NextTeleport ) then
		teleportsound = { "chorror/screech.wav", "chorror/metal3.wav" }
		local snd = teleportsound[math.random( 1, #teleportsound )]
		self:EmitSound( snd, 100, math.random(90,100), 1, CHAN_AUTO );
		self:TeleportLong()
		self.NextTeleport = CurTime() + 4;
	end
	
end

function ENT:TeleportShortThink()
	
	if( !self.NextTeleport ) then self.NextTeleport = CurTime(); end
	
	if( CurTime() >= self.NextTeleport ) then
		teleportsound = { "chorror/psstright.wav", "chorror/psstleft.wav" }
		local snd = teleportsound[math.random( 1, #teleportsound )]
		self:EmitSound( snd, 100, math.random(90,100), 1, CHAN_AUTO );
		self:TeleportShort()
		self.NextTeleport = CurTime() + 2;
	end
	
end



function ENT:StuckThink()
	
end


function ENT:Wander( rad )
	
	local r = math.random( 0, 360 );
	
	local x = math.cos( r ) * rad;
	local y = math.sin( r ) * rad;
	
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( 6 );
	path:SetGoalTolerance( 35 );
	path:Compute( self, self:GetPos() + Vector( x, y, 0 ) );
	
	if( !path:IsValid() ) then return "failed" end
	
	while( path:IsValid() ) do

		path:Update( self );
		
		self:MovementThink();
		
		self:UpdatePlayerPositions();
		local ret, ply = self:GetBestEnemy();
		
		if( ret != false ) then
			
			return "found", ply;
			
		end
		
		if( self.loco:IsStuck() ) then
			
			if( self:HandleStuck() ) then
				
				return "stuck";
				
			end
			
		end
		
		if( path:GetAge() > self.WanderAttentionSpan ) then return "timeout" end
		
		coroutine.yield();
	
	end
	
	return "ok"
	
end

function ENT:TeleportLong()
local nextTeleport = 0
local delay = 4
if CurTime() < nextTeleport then return end 
self:SetPos( self:GetPos() + Vector( math.random(-555, 555), math.random(-555, 555), 0 ) )
nextTeleport = CurTime() + delay
end

function ENT:TeleportShort()
local nextTeleport = 0
local delay = 4
if CurTime() < nextTeleport then return end 
self:SetPos( self:GetPos() + Vector( math.random(-250, 250), math.random(-250, 250), 0 ) )
nextTeleport = CurTime() + delay
end


function ENT:Idle( delay )
	
	local t = CurTime() + delay;
	local poses = { "idle01", "idle02" }
	local len = self:SetSequence( self:LookupSequence( poses[ math.random( 1, #poses ) ] ) );
	self.NextTime = CurTime() + 5
	self.IsMoving = false
	self:ResetSequenceInfo();
	self:SetCycle( 0 );
	self:SetPlaybackRate( 1 );

	while( CurTime() < t ) do

		
		self:AttackThink();
		self:TeleportLongThink();
		self:UpdatePlayerPositions();
		local ret, ply = self:GetBestEnemy();
		
		if( ret != false ) then
			
			return "found", ply;
			
		end
		
		coroutine.yield();
	
	end
	
end

function ENT:OnRemove()
-- self:EmitSound("chorror/bass_walls.wav")
self:StopSound( "spook3" )
end


function ENT:PathDistanceToPos( pos )
	
	if( true ) then
		
		return ( self:GetPos() - pos ):Length();
		
	else
		
		local path = Path( "Follow" );
		path:SetMinLookAheadDistance( 0 );
		path:SetGoalTolerance( 20 );
		path:Compute( self, pos );
		
		return path:GetLength();
		
	end
	
end


function ENT:RunBehaviour()

	while ( true ) do
					
				local opts = {	lookahead = 300,
					tolerance = 6,
					draw = false,
					maxage = 1,
					repath = 1	}

		self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
		 local pos = self:FindSpot( "random", { type = 'hiding', radius = 2000 } )
		         -- if the position is valid
        if ( pos ) then
            self:StartActivity( ACT_WALK )                                            -- run anim
            self.loco:SetDesiredSpeed( 35 )                                        -- run speed
            self:MoveToPos( pos )                     
            -- self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1), 0 ) * 300 )		
                                                   -- when we finished, go into the idle anim
        else
            self:StartActivity( ACT_IDLE )     
        end

		coroutine.yield()
	end
end
