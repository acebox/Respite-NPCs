AddCSLuaFile();

list.Set( "NPC", "resp_wheelchair", {
	Name = "Wheelchair",
	Class = "resp_wheelchair",
	Category = "Respite"
} )

MONSTRUM_FIEND_AffectedLights = {}

sound.Add( {
	name = "spook2",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 70,
	pitch = 80,
	sound = "respite/horror2.mp3"
} )

ENT.classname = "resp_wheelchair"
ENT.Base = "nz_base";
ENT.Spawnable        = false
ENT.AdminSpawnable   = false
ENT.SlowZombies = true
ENT.CollisionSide = 15
ENT.CollisionHeight = 55
ENT.IdleNoiseInterval = 6
ENT.Model = "models/respite/wheelchair_model.mdl"
ENT.MoveType = 2
ENT.WalkSpeedAnimation = 1.0
ENT.WalkAnim = nil
ENT.Speed = 0
ENT.Damage = 0
ENT.AttackRange = 75
ENT.DamageRange = 80
ENT.AttackAnim = ACT_MELEE_ATTACK1
ENT.health = 0
ENT.UseFootSteps = 1
ENT.FootStepTime = 0
ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")
ENT.Miss = Sound("npc/zombie/claw_miss1.wav")

function ENT:Precache()

	util.PrecacheModel(self.Model)

end

function ENT:Initialize()
    -- self:ChooseRandPoses()
	self.WalkAnim = "walk"
	self.Speed = 65
	self.health = 200
	self.Damage = 4
	self.FootStepTime = 4
	self:SetRenderFX(kRenderFxHologram)
	self:EmitSound( "spook2" )

	if( SERVER ) then 
	
		self:Precache()
		self.loco:SetStepHeight( 40 )
		self.loco:SetAcceleration( 500 )
		self.loco:SetDeceleration( 300 )
		self.loco:SetJumpHeight( 35 )
		
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
	
	self:SetHealth( self.health )	
	

	self:SetModel( self.Model )
	
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_NPC )
	
	self:SetSequence( "idle1" )
	
	self.NextIdle = CurTime() + self.IdleNoiseInterval

	self.WanderAttentionSpan = math.Rand( 3, 9 );
	self.ChaseAttentionSpan = math.Rand( 15, 25 );
		
	self.PlayerPositions = { };
end

function ENT:BleedVisual( time, pos, dmginfo )

	local bleed = ents.Create("info_particle_system")
	bleed:SetKeyValue("effect_name", "blood_impact_red_01")
	bleed:SetPos( pos )
	bleed:Spawn()
	bleed:Activate()
	bleed:Fire("Start", "", 0)
	bleed:Fire("Kill", "", time)
	
end

function ENT:CollisionSetup( collisionside, collisionheight, collisiongroup )

	self:SetCollisionGroup( collisiongroup )
	-- self:SetCollisionBounds( Vector(-8,-8,0), Vector(10,10,90) )
	self:SetCollisionBounds( Vector(-collisionside,-collisionside,0), Vector(collisionside,collisionside,collisionheight) )
	
end

function ENT:MovementFunctions( type, act, speed, playbackrate )
	if type == 1 then
		self:StartActivity( act )
		self:SetPoseParameter("move_x", playbackrate )		
	elseif type == 2 then
		self:ResetSequence( act )
		-- self.IsMoving = true
		self:SetPlaybackRate( playbackrate )
		self:SetPoseParameter("move_x", playbackrate )
	elseif type == 3 then
     	self:ResetSequence( act )
        self:SetSequence(act)
		self:SetPoseParameter("move_x", playbackrate )
end

	self.loco:SetDesiredSpeed( speed )
	
end

--[[
function ENT:TransformRagdoll( dmginfo )

	if !self:IsValid() then return end
	
	local ragdoll = ents.Create("prop_ragdoll")
		if ragdoll:IsValid() then 
			ragdoll:SetPos(self:GetPos())
			ragdoll:SetModel(self:GetModel())
			ragdoll:SetAngles(self:GetAngles())
			ragdoll:Spawn()
			ragdoll:SetSkin(self:GetSkin())
			ragdoll:SetColor(self:GetColor())
			ragdoll:SetMaterial(self:GetMaterial())
			
			local num = ragdoll:GetPhysicsObjectCount()-1
			local v = self.loco:GetVelocity()	
   
			for i=0, num do
				local bone = ragdoll:GetPhysicsObjectNum(i)

				if IsValid(bone) then
					local bp, ba = self:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
					if bp and ba then
						bone:SetPos(bp)
						bone:SetAngles(ba)
					end
					bone:SetVelocity(v)
				end
	  
			end
			
			ragdoll:SetBodygroup( 1, self:GetBodygroup(1) )
			ragdoll:SetBodygroup( 2, self:GetBodygroup(2) )
			ragdoll:SetBodygroup( 3, self:GetBodygroup(3) )
			ragdoll:SetBodygroup( 4, self:GetBodygroup(4) )
			ragdoll:SetBodygroup( 5, self:GetBodygroup(5) )
			ragdoll:SetBodygroup( 6, self:GetBodygroup(6) )
			
			ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			ragdoll:Fire("FadeAndRemove", self.CorpseFadeTime)
		end
	
	SafeRemoveEntity( self )

end
--]]

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
		
		self:Effects()
		self:CloseDoorsNearEnemy()
		-- self:FlickerFlashlight()
end
end

function ENT:Effects()
	for P=1, #player.GetAll() do
		local ply = player.GetAll()[P]
		
		--[[
		if(SERVER) then
			if(HorrorMonsterPlayerEffectTime<CurTime()) then
						
				local TEMP_MONSTERS = ents.FindByClass("resp_wheelchair")
				
				if(#TEMP_MONSTERS>0) then
					local TEMP_NEARESTMONSTER = ply
					local TEMP_NEARESTMONSTERDISTANCE = 5000
					
					for C=1, #TEMP_MONSTERS do
						local ent = TEMP_MONSTERS[C]
						local TEMP_MONSTERDISTANCE = ply:GetPos():Distance(ent:GetPos())
						
						if(ent:Visible(ply)&&TEMP_MONSTERDISTANCE<TEMP_NEARESTMONSTERDISTANCE) then
							TEMP_NEARESTMONSTERDISTANCE = TEMP_MONSTERDISTANCE
							TEMP_NEARESTMONSTER = ent
							
							ply:SetNWFloat("MayhemHorrorNPCEffects",((550-TEMP_MONSTERDISTANCE)/5000),0,0.5)
						end
					end
					
					if(TEMP_NEARESTMONSTER!=ply) then
						if(ply:GetEyeTrace().Entity==TEMP_NEARESTMONSTER) then
							-- ply:ViewPunch(Angle(math.random(-1,1)*2,math.random(-1,1)*2,math.random(-1,1)*2))
						end
						
					else
						ply:SetNWFloat("MayhemHorrorNPCEffects",math.max(ply:GetNWFloat("MayhemHorrorNPCEffects",0)-0.1,0))	
					end
				else
					ply:SetNWFloat("MayhemHorrorNPCEffects",math.max(ply:GetNWFloat("MayhemHorrorNPCEffects",0)-0.1,0))
				end

				HorrorMonsterPlayerEffectTime = CurTime()+0.2
			end
		end
		--]]
				
		if(ply:GetNWFloat("MayhemHorrorNPCEffects",0)>0) then 

			if(SERVER) then
				if(!timer.Exists("ControllerCameraShake"..tostring(ply))) then
					local TEMP_CAMSHAKENUM = 0
					local TEMP_CAMSHAKESIDE = -1
					
					if(timer.Exists("ControllerCameraShake"..tostring(ply))) then
						timer.Remove("ControllerCameraShake"..tostring(ply))
					end
					
						
					timer.Create("ControllerCameraShake"..tostring(ply),0.04,0,function()
						if(ply:GetNWFloat("MayhemHorrorNPCEffects",0)>0) then
							if(IsValid(ply)&&ply!=NULL) then
								ply:ViewPunch(Angle(0,0,(TEMP_CAMSHAKENUM*ply:GetNWFloat("MayhemHorrorNPCEffects",0))/6))
								
								
								TEMP_CAMSHAKENUM = TEMP_CAMSHAKENUM+TEMP_CAMSHAKESIDE
								
								if(TEMP_CAMSHAKENUM==30||TEMP_CAMSHAKENUM==-30) then
									TEMP_CAMSHAKESIDE = TEMP_CAMSHAKESIDE*-1
								end
							end
						end
					end)
				end
			else
				util.ScreenShake( LocalPlayer():GetPos(), ply:GetNWFloat("MayhemHorrorNPCEffects",0)*2, 
				ply:GetNWFloat("MayhemHorrorNPCEffects",0)*2, 0.2, 5 )
			end
		end
	end
end


function ENT:CloseDoorsNearEnemy()
	local enemy = self.Target
	
	if( !IsValid( enemy ) ) then
		return;
	end
	
	
	self.m_flLastDoorLock = self.m_flLastDoorLock || 0
	
	if( self.m_flLastDoorLock <= CurTime() ) then
		for i, v in pairs( ents.FindInSphere( enemy:GetPos(), 250 ) ) do
			if( !IsValid( v ) || ( v:GetClass() != "func_door" && v:GetClass() != "prop_door_rotating" ) ) then
				continue
			end
			
			v:Fire( "Close" )
			self.m_flLastDoorLock = CurTime() + 30
			break
		end
	end
end

-- function ENT:Flicker()
-- local times = 3
-- local enemy = self.Target

	-- if(times > 0) then
		-- timer.Simple(math.random(0.3,3),
			-- function()
				-- if (enemy:FlashlightIsOn()) then
					-- enemy:Flashlight(false)
				-- else
					-- enemy:Flashlight(true)
				-- end
				-- self:Flicker()
			-- end
		-- )
	-- end
-- end

-- function ENT:FlickerFlashlight()
	-- local enemy = self.Target
	
	-- if( !IsValid( enemy ) ) then
		-- return;
	-- end
	
	-- if( !IsValid( self ) ) then
	    -- return;
	-- end
	
    -- if( enemy:getChar() and enemy:getChar():getInv():hasItem("flashlight_shard") ) then
	    -- return;
	-- end
	
	-- self.flick = 0
	
	-- if( self.flick <= CurTime() ) then
	-- if( enemy:GetPos():Distance( self:GetPos() ) < 250 ) then
     	-- self:Flicker()
		
	-- else return
	-- end

	-- self.flick = CurTime() + 5
	

	-- end
-- end


function ENT:BodyUpdate()
	
	self:BodyMoveXY();
	
end

function ENT:DeathAnimation( anim, pos, activity, scale )
	local zombie = ents.Create( anim )
	if !self:IsValid() then return end
	
	if zombie:IsValid() then 
		zombie:SetPos( pos )
		zombie:SetModel(self:GetModel())
		zombie:SetAngles(self:GetAngles())
		zombie:Spawn()	
		zombie:SetSkin(self:GetSkin())
		zombie:SetColor(self:GetColor())
		zombie:SetMaterial(self:GetMaterial())
		zombie:SetModelScale( scale, 0 )
			
		-- zombie:StartActivity( activity )
		
		if self.Burning then
			zombie:Ignite( 4 )
			zombie.Burning = true
		end
		
		SafeRemoveEntity( self )
	end
end


function ENT:CustomDeath( dmginfo )
	self:DeathAnimation( "resp_deathanim_wc", self:GetPos(), ACT_DIESIMPLE, 1 )
	self:EmitSound("npc/wheelchair/death.wav", 80, 80)
    self:StopSound( "spook2" )
	util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
end

function ENT:OnStuck()

end

function ENT:MovementThink()

	-- if self:WaterLevel() == 3 then
        -- self:Remove()
    -- end
	
	if ( self.loco:IsStuck() ) then
		
		if( !self.StuckTime ) then
			
			self.StuckTime = CurTime();
			
		end
		
		self:Attack();
		
	else
		
		self.StuckTime = nil;
		
	end
	
	if( self.StuckTime and CurTime() >= self.StuckTime + 5 ) then
		
		if( !self:CanPlayerSeeZombieAt( self:GetPos() ) ) then
			
			self:Remove();
			return;
			
		end
		
    end
	
	if self.UseFootSteps == 1 then
	
	if !self.nxtThink then self.nxtThink = 0 end
	
	if ( self.loco:IsStuck() ) then return end
	
	if !self:IsOnGround() then return end
	
	if CurTime() < self.nxtThink then return end
	self:FootSteps()
	self.nxtThink = CurTime() + self.FootStepTime
	end
	
	local trace = { };
	trace.start = self:WorldSpaceCenter();
	trace.endpos = trace.start + self:GetForward() * 74;
	trace.filter = self;
	
	local tr = util.TraceLine( trace );
	
	
end

function ENT:FootSteps()

	self:EmitSound("npc/wheelchair/wc_wheel"..math.random(1, 3)..".wav", 65, math.random(80,120))
	
end

function ENT:AttackThink()
	
	if( self.NextAttackDamage and CurTime() > self.NextAttackDamage ) then
		
		self.NextAttackDamage = nil;
		
		local venttab = { };
		
		for _, v in pairs( ents.FindInSphere( self:GetPos(), self.DamageRange ) ) do
			
			local trace = { };
			trace.start = self:WorldSpaceCenter();
			trace.endpos = v:WorldSpaceCenter();
			trace.filter = ents.FindByClass( self.classname );
			
			-- for _, v in pairs( player.GetAll() ) do
				
				-- if( v:IsZombie() ) then
					
					-- table.insert( trace.filter, v );
					
				-- end
				
			-- end
			
			local tr = util.TraceLine( trace );
			
			if( tr.Entity and tr.Entity:IsValid() and tr.Entity == v ) then
				
				table.insert( venttab, v );
				
			end
			
		end
		
		for _, v in pairs( venttab ) do
			
				
				if( v:IsPlayer() and self:IsOnFire() and !v:IsOnFire() ) then
					
					v:Ignite( 20, 0 );
					
				end
				
				local dmg = DamageInfo();
				dmg:SetAttacker( self );
				dmg:SetDamage( self.Damage );
				dmg:SetDamageType( DMG_DIRECT );
				dmg:SetInflictor( self );
				
				v:TakeDamageInfo( dmg );
				
				if( v:GetClass() == "func_breakable_surf" ) then
					
					v:Fire( "Shatter", "0 0 0" );
					
				end
				
				local ply = false;
				
				for _, n in pairs( player.GetAll() ) do
					
					if( n:GetPos():Distance( v:GetPos() ) < 1200 ) then
						
						ply = true;
						
					end
					
				end
				
			end
	

						
					
		
		if( #venttab > 0 ) then
			
			self:EmitSound( "npc/wheelchair/wc_hit.wav", 70, 100, 1, CHAN_AUTO );	
			
		end
		
	end
	
end

function ENT:IdleThink()
	
	if self.NextIdle < CurTime() then
	
		self:EmitSound( "npc/wheelchair/wc_alert.wav", 70, math.random(80,100), 1, CHAN_VOICE );
		self.NextIdle = CurTime() + self.IdleNoiseInterval
		
		end
		
end

function ENT:RageThink()
	
	if( self.SlowZombies ) then
		
		self:IdleThink();
		return;
		
	end
	
	
end

function ENT:StuckThink()
	
end

function ENT:Attack()

    local enemy = self.Target

	if( !self.NextAttack ) then self.NextAttack = CurTime(); end
	
	if( CurTime() >= self.NextAttack ) then

	    self:RestartGesture(self.AttackAnim);
		self.NextAttack = CurTime() + 2;
		self.NextAttackDamage = CurTime() + 0.5;
		self:EmitSound( "npc/wheelchair/wc_attack.wav", 70, math.random(70,80), 1, CHAN_VOICE );
		self:SetPos( enemy:GetPos() + Vector( math.random(-5, 5), math.random(-55, 25), 0 ) )
		
	end
end

function ENT:Wander( rad )
	
	local r = math.random( 0, 360 );
	
	local x = math.cos( r ) * rad;
	local y = math.sin( r ) * rad;
	
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( 6 );
	path:SetGoalTolerance( 60 );
	path:Compute( self, self:GetPos() + Vector( x, y, 0 ) );
	
	if( !path:IsValid() ) then return "failed" end
	
	while( path:IsValid() ) do

		path:Update( self );
		
		--path:Draw();
		self:AttackThink();
		self:IdleThink();
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

function ENT:Idle( delay )
	
	local t = CurTime() + delay;
	
	local len = self:SetSequence( self:LookupSequence( "idle1" ) );
	
	-- self.IsMoving = false
	self:ResetSequenceInfo();
	self:SetCycle( 0 );
	self:SetPlaybackRate( 1 );
	
	while( CurTime() < t ) do
		
		self:AttackThink();
		self:IdleThink();
		
		self:UpdatePlayerPositions();
		local ret, ply = self:GetBestEnemy();
		
		if( ret != false ) then
			
			return "found", ply;
			
		end
		
		coroutine.yield();
	
	end
	
end

function ENT:FindClosestPlayer()
	
	local closest = nil;
	local dist = math.huge;
	
	for _, v in pairs( player.GetAll() ) do
		
		-- if( !v:IsZombie() ) then
			
			local d = v:GetPos():Distance( self:GetPos() );
			
			if( d < dist ) then
				
				dist = d;
				closest = v;
				
			end
			
		-- end
		
	end
	
	return closest, dist;
	
end

function ENT:FindClosestPlayerDistance()
	
	local dist = math.huge;
	
	for _, v in pairs( player.GetAll() ) do
		
		-- if( !v:IsZombie() ) then
			
			local d = v:GetPos():Distance( self:GetPos() );
			
			if( d < dist ) then
				
				dist = d;
				
			end
			
		-- end
		
	end
	
	return dist;
	
end

function ENT:FindClosestPlayerMemory()
	
	local closest = nil;
	local dist = math.huge;
	
	for k, v in pairs( self.PlayerPositions ) do
		
		-- if( !v:IsZombie() ) then
			
			local d = v:Distance( self:GetPos() );
			
			if( d < dist ) then
				
				dist = d;
				closest = k;
				
			end
			
		-- end
		
	end
	
	return closest, dist;
	
end


function ENT:ChasePlayer()
	
	if( !self.Target or !self.Target:IsValid() ) then return "no target" end
	if( !self.PlayerPositions[self.Target] ) then return "no player position" end
	
	local path = Path( "Follow" );
	path:SetMinLookAheadDistance( 0 );
	path:SetGoalTolerance( 6 );
	path:Compute( self, self.PlayerPositions[self.Target][1] );
	
	if( !path:IsValid() ) then return "failed" end
	
	while( path:IsValid() ) do
		
		if( !self.Target or !self.Target:IsValid() ) then return "lost target" end
		
		path:Update( self );
		
		--path:Draw();
	
		self:AttackThink();
		self:MovementThink();
		self:RageThink();
		
		local dist = ( self.PlayerPositions[self.Target][1] - self:GetPos() ):Length();
		
		if( dist > 1000 and path:GetAge() > 1 ) then
			
			if( self.PlayerPositions[self.Target] ) then
				
				path:Compute( self, self.PlayerPositions[self.Target][1] );
				
			end	
			
		elseif( dist <= 1000 and path:GetAge() > 0.3 ) then
			
			if( self.PlayerPositions[self.Target] ) then
				
				path:Compute( self, self.PlayerPositions[self.Target][1] );
				
			end	
			
		end
		
		self:IdleThink();
		
		local dist = self:FindClosestPlayerDistance();
		
		if( dist < self.AttackRange ) then
		
			self:Attack();
			
		end
		
		self:UpdatePlayerPositions();
		
		local ret, ply = self:GetBestEnemy();
		
		if( ret == false ) then -- we have no enemy to chase..
			
			return "lost targets"
			
		elseif( ret ) then
			
			self.Target = ply;
			
		end
		
		coroutine.yield();

	end
	
	return "ok"

end

function ENT:OnRemove()
self:StopSound( "spook2" )
end


function ENT:CanSeePos( pos1, pos2, filter )
	
	local trace = { };
	trace.start = pos1;
	trace.endpos = pos2;
	trace.filter = filter;
	trace.mask = MASK_SOLID + CONTENTS_WINDOW + CONTENTS_GRATE;
	local tr = util.TraceLine( trace );
	
	if( tr.Fraction == 1.0 ) then
		
		return true;
		
	end
	
	return false;
	
end

function ENT:CanSeePlayer( ply )
	
	return self:CanSeePos( self:EyePos(), ply:EyePos(), { self, ply } );
	
end

function ENT:UpdatePlayerPositions()
	
	for k, v in pairs( self.PlayerPositions ) do
		
		if( !k or !k:IsValid() ) then

			self.PlayerPositions[k] = nil;
			
			if( k == self.Target ) then

				self.Target = nil;
				
			end
			
		elseif( !k:Alive() ) then
			
			self.PlayerPositions[k] = nil;
			
			if( k == self.Target ) then
				
				self.Target = nil;
				
			end
			
		elseif( CurTime() > v[2] + self.ChaseAttentionSpan ) then
			
			self.PlayerPositions[k] = nil;
			
			if( k == self.Target ) then
				
				self.Target = nil;
				
			end
			
		end
		
	end
	
	for _, v in pairs( player.GetAll() ) do
		
		if( !v:Alive() or v:GetMoveType() == MOVETYPE_NOCLIP ) then continue; end
		-- if( v:IsZombie() ) then continue; end
		
		local pos = v:GetPos();
		local d = self:GetPos():Distance( pos );
		
		if( self.LastShot and self.LastShot == v ) then
			
			self.PlayerPositions[v] = { pos, CurTime() };
			continue;
			
		end
		
		if( d < 1000 and v:FlashlightIsOn() ) then
			self.PlayerPositions[v] = { pos, CurTime() };
			continue;
		end
		
		if( d < 1400 and ( !v:Crouching() or v:FlashlightIsOn() ) ) then
			self.PlayerPositions[v] = { pos, CurTime() };
			continue;
		end
		
		local dot = ( pos - self:GetPos() ):GetNormal():Dot( self:GetForward() );
		
		if( v:Crouching() and !v:FlashlightIsOn() ) then
			
			if( self:CanSeePlayer( v ) and dot > 0.7 and d < 800 ) then
				
				self.PlayerPositions[v] = { pos, CurTime() };
				
			end
			
		else
			
			if( self.PlayerPositions[v] and d < 700 ) then
				
				self.PlayerPositions[v] = { pos, CurTime() };
				
			elseif( self:CanSeePlayer( v ) and dot > 0.6 and d < 1300 ) then
				
				self.PlayerPositions[v] = { pos, CurTime() };
				
			end
			
		end
		
	end
	
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

function ENT:GetBestEnemy()
	
	if( self.Target and self.Target:IsValid() and self.PlayerPositions[self.Target] ) then
		
		local d = self:PathDistanceToPos( self.PlayerPositions[self.Target][1] );
		
		if( self.LastShot and self.LastShot:IsValid() ) then
			
			self.LastShot = nil;
			
			if( d > 400 ) then
				
				return true, self.LastShot;
				
			end
			
		end
		
		for k, v in pairs( self.PlayerPositions ) do
			
			local l = self:PathDistanceToPos( v[1] );
			
			if( l < d ) then
				
				return true, k;
				
			end
			
		end
		
		return nil, self.Target;
		
	else
		
		if( self.LastShot and self.LastShot:IsValid() ) then
			
			self.LastShot = nil;
			return true, self.LastShot;
			
		end
		
		local d = math.huge;
		local ply = nil;
		
		for k, v in pairs( self.PlayerPositions ) do
			
			local l = self:PathDistanceToPos( v[1] );
			
			if( l < d ) then
				
				d = l;
				ply = k;
				
			end
			
		end
		
		if( ply ) then
			
			return true, ply;
			
		else
			
			return false, nil;
			
		end
		
	end
	
end

function ENT:CanPlayerSeeZombieAt( pos )
	
	for _, v in pairs( player.GetAll() ) do
		
		if( v:Alive() ) then
			
			local d = v:GetPos():Distance( pos );
			
			if( d < 1000 ) then return true end 
			if( v:VisibleVec( pos ) ) then return true end 
			
			local dir = ( pos * v:EyePos() ):GetNormal();
			
			if( dir:Dot( v:GetAimVector() ) > 0.7071 and d < 1000 ) then
				
				return true;
				
			end
			
		end
		
	end
	
	return false;
	
end

function ENT:OnInjured( dmg )
	
	local ent = dmg:GetAttacker();
	
	local z = ( dmg:GetDamagePosition() - self:GetPos() ).z;
	
	local pos = self:FindSpot( "random", { type = 'hiding', radius = 5000 } )
	
			
	dmg:ScaleDamage( 0.85 );
	
    self:SetPos( pos )
	
	self:EmitSound("respite/scare17.wav", 70, math.random(90,110))
			
	
end

function ENT:RunBehaviour()
	
	while( true ) do
		self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
		local ret, ply = self:Wander( 300 );
		
		if( ret == "found" ) then
			
			self.Target = ply;
			
			if( self.SlowZombies ) then
				
				self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
				
			else
				
			    self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
				
			end
			
			self:ChasePlayer( ply );
			
		end
		
		local ret, ply = self:Idle( math.Rand( 60, 100 ) );
		
		if( ret == "found" ) then
			
			self.Target = ply;
			
			if( self.SlowZombies ) then
				
               self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
				
			else
				
				self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
				
			end
			
			self:ChasePlayer();
			
		end
		
		local plys = ents.FindInSphere( self:GetPos(), 800 );
		local idlemore = true;
		local n = false;
		
		for _, v in pairs( plys ) do
			
			if( v:IsPlayer() ) then
				
				if( !v:Crouching() ) then
					
					idlemore = false;
					
				end
				
				n = true;
				
			end
			
		end
		
		if( !n ) then
			
			idlemore = false;
			
		end
		
		if( idlemore ) then
			
			local ret, ply = self:Idle( math.Rand( 150, 200 ) );
			
			if( ret == "found" ) then
				
				self.Target = ply;
				
				if( self.SlowZombies ) then
					
					self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
					
				else
					
					self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
					
				end
				
				self:ChasePlayer();
				
			end
			
		end
		
		coroutine.yield();
		
	end
	
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


