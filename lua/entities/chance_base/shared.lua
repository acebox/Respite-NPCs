if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "base_nextbot"
ENT.Spawnable        = false
ENT.AdminOnly   = false

--Stats--
ENT.UseFootSteps = 1
ENT.Bone1 = "ValveBiped.Bip01_R_Foot"
ENT.Bone2 = "ValveBiped.Bip01_L_Foot"
ENT.FootAngles = 0 --used for ENT.UseFootSteps = 1 to perform a trace from the foot down
ENT.FootAngles2 = 0
ENT.FootStepTime = 0.5 --only used for ENT.UseFootSteps = 2

ENT.MoveType = 1 --used for various animation things. ACT_WALK is not the same as "walk", and sometimes this needs to be changed to make that work.

ENT.SearchRadius = 2000 --how far away the npc can see you
ENT.LoseTargetDist = 4000 --not used in most npcs

ENT.Speed = 0 --movement speed
ENT.WalkSpeedAnimation = 0 --1 = 100%
ENT.FlinchSpeed = 0 --movement speed when flinching

ENT.health = 0 
ENT.Damage = 0

ENT.PhysForce = 15000 --how much force the npc hit objects with
ENT.AttackRange = 70 --where the damage is applied
ENT.InitialAttackRange = 60 --when the npc starts the attack

ENT.HitPerDoor = 1 --how much damage the npc does to doors higher kills doors faster
ENT.DoorAttackRange = 25 --range to hit doors

ENT.AttackFinishTime = 0 --time it takes for the damage to hit the player after the animation starts
ENT.AttackAnimSpeed = 1 --1 is 100%

ENT.NextAttack = 1.3

ENT.FallDamage = 0

--gross timer things that don't really need to be up here
ENT.nextWander = 0
ENT.nextIdle = 0
ENT.retargetTime = 0

ENT.OldEnemy = nil --used for a check for retargetting
ENT.IsAttacking = false 

ENT.corpseTime = 600 --how long it takes for a corpse to disappear after death

ENT.pitch = 100 --the pitch of most of the creatures sounds
ENT.pitchVar = 5 --the variance of the pitch
ENT.volume = 75 --sound range of npc's emitted sounds.

ENT.wanderType = 3 --behavior choice for what it does when it has no target
ENT.idleTime = 10 --how long to stand still for when idling. Only useful for wanderType 3

ENT.Ignites = true --whether the npc can be ignited or not
ENT.Launches = false --whether or not it tosses your salad
ENT.Persistent = false --whether it can follow enemies through walls

--Model Settings--
ENT.Model = ""

ENT.AttackAnim = (NONE)

ENT.WalkAnim = (NONE)
ENT.IdleAnim = ACT_IDLE

ENT.FlinchAnim = (NONE)
ENT.FallAnim = (NONE)

ENT.AttackDoorAnim = (NONE)

--Sounds--
ENT.attackSounds = {}
ENT.alertSounds = {}
ENT.deathSounds = {}
ENT.idleSounds = {}
ENT.painSounds = {}
ENT.hitSounds = {}
ENT.missSounds = {}

ENT.chance = true --just stupid thing i put in to make it easier to check if it's on this base
ENT.team = 0 --if an npc's team is different than another's, they will fight each other.

--caches most of the npc's things.
function ENT:Precache()
	util.PrecacheModel(self.Model)

	if(self.models) then
		for k, v in pairs(self.models) do
			if(type(v) == "string") then --i dont know why i have to do this and it makes me mad
				util.PrecacheModel(v)
			end
		end
	end
	
	--Sounds--	
	util.PrecacheSound(self.DoorBreak)

	for k, v in pairs(self.attackSounds) do
		if(type(v) == "string") then
			util.PrecacheSound(v)
		end
	end

	for k, v in pairs(self.alertSounds) do
		if(type(v) == "string") then
			util.PrecacheSound(v)
		end
	end

	for k, v in pairs(self.deathSounds) do
		if(type(v) == "string") then
			util.PrecacheSound(v)
		end
	end

	for k, v in pairs(self.idleSounds) do
		if(type(v) == "string") then
			util.PrecacheSound(v)
		end
	end

	for k, v in pairs(self.painSounds) do
		if(type(v) == "string") then
			util.PrecacheSound(v)
		end
	end

	for k, v in pairs(self.hitSounds) do
		if(type(v) == "string") then
			util.PrecacheSound(v)
		end
	end

	for k, v in pairs(self.missSounds) do
		if(type(v) == "string") then
			util.PrecacheSound(v)
		end
	end
end

--called right before spawn, initilizes the npc. 
function ENT:Initialize()
end

--Can be used to randomize model if ENT.models exist.
function ENT:SelectModel()
	self:SetModel(self.models[ math.random( #self.models ) ])
end

--sets up the collision box for the npc
function ENT:CollisionSetup( collisionside, collisionheight, collisiongroup )
	self:SetCollisionGroup( collisiongroup )
	self:SetCollisionBounds( Vector(-collisionside,-collisionside,0), Vector(collisionside,collisionside,collisionheight) )
	self.NEXTBOT = true
end

--called every think, serverside
function ENT:CustomThink()
end

--determines location of npc. Places it where you're aiming.
function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 16

	if util.PointContents( tr.HitPos ) == CONTENTS_EMPTY then

	local ent = ents.Create( Class )
		ent:SetPos( SpawnPos )
		ent:Spawn()
	end

	return ent
end

--main think function
function ENT:Think()
	self:CustomThinkClient() --used for clientside things
	
	if not SERVER then return end
	
	if(!self.timers) then
		self.timers = {}
	end	
	
	if !IsValid(self) then return end

	--this is confusing but it basically goes through the table of active timers, and runs them when it is time.
	if(self.timers) then
		for k, v in pairs(self.timers) do
			if(k < CurTime()) then
				v()
				self.timers[k] = nil
			end
		end
	end	
	
	self:CustomThink()

	-- Step System --
	if self.UseFootSteps == 1 then 
		if !self.nxtThink then self.nxtThink = 0 end
		if CurTime() < self.nxtThink then return end

		self.nxtThink = CurTime() + 0.025

	-- First Step
        local bones = self:LookupBone(self.Bone1)
		if(bones) then
			local pos, ang = self:GetBonePosition(bones)

			local tr = {}
			tr.start = pos
			tr.endpos = tr.start - ang:Right()* self.FootAngles + ang:Forward()* self.FootAngles2
			tr.filter = self
			tr = util.TraceLine(tr)

			if tr.Hit && !self.FeetOnGround then
				self:FootSteps()
			end

			self.FeetOnGround = tr.Hit

		-- Second Step
			local bones2 = self:LookupBone(self.Bone2)

			local pos2, ang2 = self:GetBonePosition(bones2)

			local tr = {}
			tr.start = pos2
			tr.endpos = tr.start - ang2:Right()* self.FootAngles + ang2:Forward()* self.FootAngles2
			tr.filter = self
			tr = util.TraceLine(tr)

			if tr.Hit && !self.FeetOnGround2 then
						self:FootSteps()
			end

			self.FeetOnGround2 = tr.Hit
		end
		
		self:NPCHate()
	end
end

function ENT:NPCHate()
	local enemy = ents.FindByClass( "npc_*" ) --Find any spawned entity in map with class beginning at npc
	for _, x in pairs( enemy ) do --for every found entity do
		if !x:IsNPC() then return end -- if found entity is not NPC then do nothing
		x:AddEntityRelationship(self, D_HT, 99) -- found entity will hate self entity
	end
end

--main attack function. Plays animation, damage handled in AttackEffect
function ENT:Attack()
	if ( self.NextAttackTimer or 0 ) < CurTime() then	
		
		if ( (self.Enemy:IsValid() and self.Enemy:Health() > 0 ) ) then
			if !self:CheckStatus() then return end
			self:CustomAttack()
		
			self:AttackSound()
			self.IsAttacking = true
		
			self.loco:SetDeceleration(0)
			self.loco:FaceTowards(self.Enemy:GetPos())
			
			if(isnumber(self.AttackAnim)) then
				self:StartActivity(self.AttackAnim)
				self:AttackEffect( self.AttackFinishTime, self.Enemy, self.Damage, 0, 1)
				coroutine.wait(1)
			else
				self:AttackEffect( self.AttackFinishTime, self.Enemy, self.Damage, 0, 1)
				self:PlaySequenceAndWait( self.AttackAnim, self.AttackAnimSpeed )
			end
			
			self.loco:SetDeceleration(900)
		end
		
		self.NextAttackTimer = CurTime() + self.NextAttack
	end
end

--called when the npc attacks
function ENT:CustomAttack()
end

--handles damaging, missing, and other on hit effects
function ENT:AttackEffect(waitTime, ent, dmg, type, reset )
	local function temp()
		if !self:IsValid() then return end
		if self:Health() < 0 then return end
		if !self:CheckValid( ent ) then return end
		if !self:CheckStatus() then return end
		
		if self:GetRangeTo( ent ) < self.AttackRange then
			
			ent:TakeDamage(dmg, self)	
			
			if ent:IsPlayer() or ent:IsNPC() then			
				if(self.Launches) then
					local moveAdd=Vector(0,0,350)
						if not ent:IsOnGround() then
							moveAdd=Vector(0,0,0)
						end
					ent:SetVelocity( moveAdd + ( ( self.Enemy:GetPos() - self:GetPos() ):GetNormal() * 150 ) )
				end

				self:HitSound()
			end
			
			if ent:IsPlayer() then
				ent:ViewPunch(Angle(math.random(-1, 1)*self.Damage, math.random(-1, 1)*self.Damage, math.random(-1, 1)*self.Damage))
			end
			
			if type == 1 then
				local phys = ent:GetPhysicsObject()
				if (phys != nil && phys != NULL && phys:IsValid() ) then
					phys:ApplyForceCenter(self:GetForward():GetNormalized()*(self.PhysForce) + Vector(0, 0, 2))
					ent:EmitSound(self.DoorBreak)
				end
			elseif type == 2 then
				if ent != NULL and ent.hitsLeft != nil then
					if ent.hitsLeft > 0 then
						ent.hitsLeft = ent.hitsLeft - self.HitPerDoor	
						ent:EmitSound(self.DoorBreak)
					end
				end
			end
							
		else	
			self:MissSound()
		end	
	end
	
	self:delay(waitTime, temp)
	
	--resumes movement for the npc after the attack.
	if reset == 1 then
		local function temp()
			if !self:IsValid() then return end
			if self:Health() < 0 then return end
			if !self:CheckValid( ent ) then return end
			if !self:CheckStatus() then return end
			
			self.IsAttacking = false
			self:ResumeMovementFunctions()
		end
	
		self:delay(waitTime + 0.6, temp)
	end
end

function ENT:delay(delayTime, delayedFunc)
	--example of how to use this weird thing
	--[[
		local function temp()
			print("frogs")
		end
		
		self:delay(1, temp)	
	--]]

	self.timers[CurTime() + delayTime] = delayedFunc
end

--turns the npc into a ragdoll (used when its killed.)
--ragdoll fades away after ENT.corpseTime seconds have elapsed.
function ENT:TransformRagdoll( dmginfo )
	local ragdoll = ents.Create("prop_ragdoll")
		if ragdoll:IsValid() then 
			ragdoll:SetPos(self:GetPos())
			ragdoll:SetModel(self:GetModel())
			ragdoll:SetAngles(self:GetAngles())
			ragdoll:Spawn()
			ragdoll:SetSkin(self:GetSkin())
			ragdoll:SetColor(self:GetColor())
			ragdoll:SetMaterial(self:GetMaterial())
			ragdoll:SetBloodColor(self:GetBloodColor())

			--doesn't work
			if self:GetModelScale() then
				ragdoll:SetModelScale( self:GetModelScale(), 0 )
			end
			
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
			
			--I hate this
			ragdoll:SetBodygroup( 1, self:GetBodygroup(1) )
			ragdoll:SetBodygroup( 2, self:GetBodygroup(2) )
			ragdoll:SetBodygroup( 3, self:GetBodygroup(3) )
			ragdoll:SetBodygroup( 4, self:GetBodygroup(4) )
			ragdoll:SetBodygroup( 5, self:GetBodygroup(5) )
			ragdoll:SetBodygroup( 6, self:GetBodygroup(6) )

			ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		end
		
	if (self:IsOnFire()) then --if the npc is on fire, set the ragdoll on fire too.
		ragdoll:Ignite(10,20)
	end
	
	SafeRemoveEntity( self )
	
	--used a regular timer for this since the npc itself is gone? Not sure if it'll screw with anything.
	timer.Simple(self.corpseTime, 
		function()
			SafeRemoveEntity( ragdoll )
		end
	)
end

--called when the npc dies
function ENT:CustomDeath( dmginfo )
	self:TransformRagdoll( dmginfo )
end

--called when the npc is injured
function ENT:CustomInjure( dmginfo )
end

--plays footsteps sounds.
function ENT:FootSteps()
	--self:EmitSound("footstepsoundhere", 75, self.pitch)
end

--used for playing footsteps when ENT.UseFootSteps = 2
function ENT:FootStepThink()
	if(self.UseFootSteps == 2) then
		if(!self.nextStep) then self.nextStep = 0 end
		if (self.nextStep < CurTime()) then
			self:FootSteps()
			self.nextStep = CurTime() + self.FootStepTime
		end
	end
end

--if you arent going to use a certain category of sounds, just overwrite the functio and make it do nothing.

--sound played when the npc spots an enemy
function ENT:AlertSound()
	local sound = self.alertSounds[ math.random( #self.alertSounds ) ]
	if(!sound) then return end
	
	self:EmitSound(sound, self.volume, math.random(self.pitch-self.pitchVar, self.pitch+self.pitchVar))
end

--sound played when taking damage
function ENT:PainSound()
	local sound = self.painSounds[ math.random( #self.painSounds ) ]
	if(!sound) then return end
	
	self:EmitSound(sound, self.volume, math.random(self.pitch-self.pitchVar, self.pitch+self.pitchVar))
end

--sound played on death
function ENT:DeathSound()
	local sound = self.deathSounds[ math.random( #self.deathSounds ) ]
	if(!sound) then return end
	
	self:EmitSound(sound, self.volume, math.random(self.pitch-self.pitchVar, self.pitch+self.pitchVar))
end

--sound the npc makes when it attempts an attack
function ENT:AttackSound()
	local sound = self.attackSounds[ math.random( #self.attackSounds ) ]
	if(!sound) then return end
	
	self:EmitSound(sound, self.volume, math.random(self.pitch-self.pitchVar, self.pitch+self.pitchVar))
end

--plays an idle sound.
function ENT:IdleSound()
	local sound = self.idleSounds[ math.random( #self.idleSounds ) ]
	if(!sound) then return end
	
	self:EmitSound(sound, self.volume, math.random(self.pitch-self.pitchVar, self.pitch+self.pitchVar))
end

--played when the npc hits the thing it's trying to hit
function ENT:HitSound()
	local sound = self.hitSounds[ math.random( #self.hitSounds ) ]
	if(!sound) then return end
	
	self:EmitSound(sound, self.volume, math.random(85,105))
end

--sounds that plays when an npc misses an attack.
function ENT:MissSound()
	local sound = self.missSounds[ math.random( #self.missSounds ) ]
	if(!sound) then return end
	
	self:EmitSound(sound, self.volume, math.random(85,105))
end

--plays idle sounds. Doesn't do it as often when just walking around.
function ENT:IdleSounds()
	if self:HaveEnemy() then
		self:IdleSound()
	else
		if math.random(1,10) == 1 then
			self:IdleSound()
		end
	end
end

--isn't really used, helper function for determining that and entity other than itself is valid.
function ENT:CheckValid( ent )
	if !ent then
		return false
	end

	if !self:IsValid() then
		return false
	end

	if self:Health() < 0 then
		return false
	end

	if !ent:IsValid() then
		return false
	end

	if ent:Health() < 0 then
		return false
	end

	return true
end

--used for flinching and other animation playing actions. This usually makes the npc stop in place and do a thing.
function ENT:CheckStatus()
	return true
end

--resets the npcs movement animations
function ENT:ResumeMovementFunctions()
	self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
end

--general function for deciding npc behaviours when idle.
function ENT:IdleFunction()
	if (self.wanderType == 1) then --just stand there
		self:Idle()
		
	elseif (self.wanderType == 2) then --find a hiding spot and then just stand there
		if(!self.Hiding) then --find a spot.
			self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
			local spot = self:FindSpot( "random", { type = 'hiding', radius = 5000 } )
			self:GoToLocation(spot)
			self.Hiding = true
		else --just stand there if you're in a spot.
			self:Idle()
		end
		
	elseif (self.wanderType == 3) then --walk around aimlessly, pausing every so often.
		if(CurTime() > self.nextWander) then
			self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )			
			self:Wander(self:GetPos() + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400) -- Walk to a random place within about 400 units (yielding)
		else --hang out for awhile
			self:Idle()
		end
		
	else --just run around like an idiot i guess
		self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )	
		self:Wander(self:GetPos() + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400) -- Walk to a random place within about 400 units (yielding)
	end
end

function ENT:Idle()
	if(self.nextIdle < CurTime()) then
		self.oldVol = self.volume
		self.volume = self.volume/2 --makes it so they arent as loud when they're just hiding in a corner
		self:IdleSound()
		self.volume = self.oldVol
		self.oldVol = nil
		
		self.nextIdle = CurTime() + math.random(10,15)
	end
	self:MovementFunctions( 2, self.IdleAnim, self.Speed, self.WalkSpeedAnimation )	
end

function ENT:MovementFunctions( type, act, speed, playbackrate )
	if type == 1 then
		self:StartActivity( act )
		self:SetPoseParameter("move_x", playbackrate )		
	elseif type == 2 then
		self:ResetSequence( act )
		self:SetPlaybackRate( playbackrate )
		self:SetPoseParameter("move_x", playbackrate )
	elseif type == 3 then
     	self:ResetSequence( act )
        self:SetSequence(act)
		self:SetPoseParameter("move_x", playbackrate )
	end
	self.loco:SetDesiredSpeed( speed )
end

--spawns the npc in
function ENT:SpawnIn()
	local nav = navmesh.GetNearestNavArea(self:GetPos())
	
	if !self:IsInWorld() or !IsValid(nav) or nav:GetClosestPointOnArea(self:GetPos()):DistToSqr(self:GetPos()) >= 20000 then 
		ErrorNoHalt("Nextbot ["..self:GetClass().."] spawned too far away from a navmesh!")
		SafeRemoveEntity(self)
	end 
	
	self:OnSpawn()
end

--called right after the npc is spawned in
function ENT:OnSpawn()
	
end

--main behaviour loop.
function ENT:RunBehaviour()
	self:SpawnIn()

	while ( true ) do
		local enemy = self:HaveEnemy()
		
		if (enemy and enemy:IsValid() and enemy:Health() > 0) then --if we have an enemy, chase him
		
			self.Hiding = false
			
			pos = enemy:GetPos()

			if self:CheckStatus() then
				self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed, self.WalkSpeedAnimation )
			end

			local opts = {	lookahead = 0,
				tolerance = 5,
				draw = false,
				maxage = 20,
				repath = 0.3	}
					
			self:ChaseEnemy( pos, opts )
		else --if we don't, idle.
			self.Enemy = nil
			
			self:IdleFunction()
		end
	
		coroutine.yield()
	end
end

--finds the range to current enemy, and if he's close enough, hit him
function ENT:CheckRangeToEnemy()
	if ( self.CheckTimer or 0 ) < CurTime() then
	
		local enemy = self:GetEnemy()
		
		if (enemy and enemy:IsValid()) then
			if(enemy:Health() > 0) then
				if self:GetRangeTo( enemy ) < self.InitialAttackRange then
					self:Attack()
				end
			else
				self.Enemy = nil
			end
		else
			self.Enemy = nil
		end

		self.CheckTimer = CurTime() + 1
	end
end

--follow enemy, if he runs out of sight, go to where we last saw him.
function ENT:ChaseEnemy( pos, options )
	local enemy = self:HaveEnemy()
	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	
	if !enemy:IsValid() then return end
	if enemy:Health() < 0 then return end

	local nav = navmesh.GetNearestNavArea(enemy:GetPos())
	if(IsValid(nav) and nav:GetClosestPointOnArea(enemy:GetPos()):DistToSqr(enemy:GetPos()) <= 10000) then
		path:Compute( self, pos )
	end
	
	if ( !path:IsValid() ) then return "failed" end
	
	while ( path:IsValid() ) do
		path:Update( self )
		
		if ( options.draw ) then
			path:Draw()
		end

		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end
		
		if (enemy and enemy:IsValid()) then
			if(!self.Persistent) then
				if(self:CanSeePlayer(enemy)) then
					self.OldPos = enemy:GetPos()
				end
			else
				self.OldPos = enemy:GetPos()
			end
		
			if !self.IsAttacking then
				if(self.nextIdle < CurTime()) then
					self:IdleSound()
					self.nextIdle = CurTime() + math.random(6,18)
				end
			end
			
			--if the player goes into noclip stop chasing him
			if(enemy:GetMoveType() == MOVETYPE_NOCLIP) then
				self.Enemy = nil
			end
		end
		
		self:CustomChaseEnemy()
		self:CheckRangeToEnemy()
		self:FootStepThink() --footstep noises

		if enemy and enemy:IsValid() and enemy:Health() > 0 then
			self:AttackDoor(false)
		
			if self:GetRangeTo( enemy ) < 25 or self:AttackObject() then

			end
		end

		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then 
				return "timeout" 
			end
		end

		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then 
			
				if(!self.OldPos) then
					break
				end
			
				--if it reaches the target location
				if(self:GetPos():DistToSqr(self.OldPos) < 10000) then
					break
				end
			
				local nav = navmesh.GetNearestNavArea(self.OldPos)
				if(!IsValid(nav) or nav:GetClosestPointOnArea(self.OldPos):DistToSqr(self.OldPos) > 10000) then
					break
				end
			
				enemy = self.Enemy
				path:Compute( self, self.OldPos )
			end
		end

		coroutine.yield()
	end
	return "ok"
end

--pathing function, tells it to go somewhere specific
function ENT:GoToLocation(location, options)
	if(!util.IsInWorld(location)) then return end

	local options = options or {}

	local path = Path("Follow")
	path:SetMinLookAheadDistance(300)
	path:SetGoalTolerance(10)

	path:Compute(self, location)
		
	if (!path:IsValid()) then return "failed" end
	
	while (path:IsValid() and location) do
		local nav = navmesh.GetNearestNavArea(location)
		if(!IsValid(nav) or nav:GetClosestPointOnArea(location):DistToSqr(location) > 100 * 100) then
			break
		end
	
		if(self:HaveEnemy()) then --if found a target
			break
		end
	
		if(!self:IsValid()) then --if removed or dead
			break
		end
	
		self:FootStepThink() --footstep noises
		self:DoorStuck(true)
	
		if (path:GetAge() > 20) then
			path:Compute(self, location)
		end
		
		if(self.nextIdle < CurTime()) then
			self:IdleSound()
			self.nextIdle = CurTime() + math.random(12,18)
		end
		
		if (!self.Stuck and self.loco:IsStuck()) then
			self.Stuck = true
			local oldLoc = location
			location = self:GetPos() + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 1000
			
			local nav = navmesh.GetNearestNavArea(location)
			if(!IsValid(nav) or nav:GetClosestPointOnArea(location):DistToSqr(location) > 10000) then
				break
			end
			
			path:Compute(self, location)
			
			local function temp()
				location = oldLoc
				path:Compute(self, location)
				self.Stuck = false
			end
			
			self:delay(1, temp)
		end
		
		path:Update(self)

		if (self:GetPos():DistToSqr(location) < 2500) then break end
		
		coroutine.yield()
	end
	return "ok"

end

--idle wandering, moves around randomly.
function ENT:Wander(pos, options)
	local nav = navmesh.GetNearestNavArea(pos)
	if(!IsValid(nav) or nav:GetClosestPointOnArea(pos):DistToSqr(pos) > 100 * 100) then
		self.nextWander = CurTime() + self.idleTime
		return
	end

    local options = options or {}

	local path = Path("Follow")
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 20)
	path:Compute(self, pos)

	if (!path:IsValid()) then return "failed" end

	while (path:IsValid() and !self:HaveEnemy()) do
        local zombiePosition = self:GetPos()
		
		if (!self.Stuck and self.loco:IsStuck()) then
			self.Stuck = true
			local oldLoc = location
			location = self:GetPos() + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 1000
			
			local nav = navmesh.GetNearestNavArea(location)
			if(!IsValid(nav) or nav:GetClosestPointOnArea(location):DistToSqr(location) > 100 * 100) then
				self.nextWander = CurTime() + self.idleTime
				break
			end
			
			path:Compute(self, location)
			
			local function temp()
				self.Stuck = false
			end
			
			self:delay(1, temp)
		end

		self:DoorStuck(true)
		self:FootStepThink()
		
		if(path:GetAge() > 330 / self.Speed) then --if its been moving for 10 seconds, stop it and tell it to just stand there like a good boy.
			self.nextWander = CurTime() + self.idleTime
			break
		end
		
		if(self.nextIdle < CurTime()) then
			self:IdleSound()
			self.nextIdle = CurTime() + math.random(10,15)
		end
		
        if(zombiePosition:DistToSqr(pos) < 50 * 50 or path:GetAge() > 30) then
            pos = zombiePosition + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 800
			
			local nav = navmesh.GetNearestNavArea(pos)
			if(!IsValid(nav) or nav:GetClosestPointOnArea(pos):DistToSqr(pos) > 100 * 100) then
				break
			end
			path:Compute(self, pos)
		end
		path:Update(self)

		coroutine.yield()

	end

	return "ok"

end

--called when stuck on a door.
function ENT:DoorStuck(openNormal) --DOORS STUCK
	if(!self.nextSample or !self.stuckPosition) then
		self.nextSample = 0
		self.stuckPosition = 0
	end
		
	if(self.nextSample < CurTime()) then
		if(self:GetPos() == self.stuckPosition) then
			self:AttackDoor(openNormal)
		end
			
		self.stuckPosition = self:GetPos()
			
		self.nextSample = CurTime() + 1
	end
end

--checks if something is a door or not
function ENT:GetDoor(ent)
	local doors = {
		"models/props_c17/door01_left.mdl",
		"models/props_c17/door02_double.mdl",
		"models/props_c17/door03_left.mdl",
		"models/props_doors/door01_dynamic.mdl",
		"models/props_doors/door03_slotted_left.mdl",
		"models/props_interiors/elevatorshaft_door01a.mdl",
		"models/props_interiors/elevatorshaft_door01b.mdl",
		"models/props_silo/silo_door01_static.mdl",
		"models/props_wasteland/prison_celldoor001b.mdl",
		"models/props_wasteland/prison_celldoor001a.mdl",
		"models/props_radiostation/radio_metaldoor01.mdl",
		"models/props_radiostation/radio_metaldoor01a.mdl",
		"models/props_radiostation/radio_metaldoor01b.mdl",
		"models/props_radiostation/radio_metaldoor01c.mdl",
	}

	for k,v in pairs( doors ) do
		if !IsValid( ent ) then break end
		if ent:GetModel() == v and string.find(ent:GetClass(), "door") then
			return true
		end
	end
	
	return false
end

--attack or open a door.
function ENT:AttackDoor(openNormal)
	local door = ents.FindInSphere(self:GetPos(), self.DoorAttackRange)
		if door then
			for i = 1, #door do
				local v = door[i]
					if self:GetDoor( v ) then

					if(v:GetCollisionGroup() == COLLISION_GROUP_IN_VEHICLE) then --this is a check for doors that we've already knocked down
						continue
					end
					
					if v.hitsLeft == nil then
						v.hitsLeft = 8
					end

					if(openNormal) then
						v:Fire( "Open" )
						return
					end
					
					if v != NULL and v.hitsLeft > 0 then

						if (self:GetRangeTo(v) < (self.DoorAttackRange)) then

							if self.loco:GetVelocity( Vector( 0,0,0 ) ) then
								self:SetPoseParameter( "move_x", 0 )
							else
								self:SetPoseParameter( "move_x", self.WalkSpeedAnimation )
							end

							self:CustomDoorAttack( v )

						end

					end

					if v != NULL and v.hitsLeft < 1 then
						self:ProcessDoor(v)
					end
						
						self:BehaveStart()
					end
			end
		end
end

function ENT:ProcessDoor(door)
	local prop = ents.Create("prop_physics")
	if prop then
		prop:SetModel(door:GetModel())
		prop:SetPos(door:GetPos())
		prop:SetAngles(door:GetAngles())
		prop:Spawn()
		prop.FalseProp = true
		prop:EmitSound("Wood_Plank.Break")

		local phys = prop:GetPhysicsObject()
		if (phys != nil && phys != NULL && phys:IsValid()) then
			phys:ApplyForceCenter(self:GetForward():GetNormalized()*20000 + Vector(0, 0, 2))
		end
		
		prop:SetSkin(door:GetSkin())	
		prop:SetColor(door:GetColor())
		prop:SetMaterial(door:GetMaterial())
	end

	door.RenderGroup = RENDERGROUP_TRANSLUCENT --used for invisible door stuff
	door:SetRenderMode(RENDERMODE_TRANSALPHA)
	door:SetColor(Color(255,255,255,0)) --make the door invisible
	
	door.oldGroup = door:GetCollisionGroup() --store old collision group of door
	door:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE) --set door to not collide with anything at all
	
	--didnt use entity delay function for this, because we still want it to happen even if the npc is dead, hopefully it doesn't break anything. Might be done better soemwhere else.
	timer.Simple(600, function() -- "respawn" the door by making it visible again, and deleting the dummy prop.
		local sEffect = ents.Create("info_particle_system")
		sEffect:SetKeyValue("effect_name", "vortigaunt_charge_token")
		sEffect:SetParent(door)
		sEffect:SetPos( door:GetPos() )
		sEffect:Spawn()
		sEffect:Activate()
		sEffect:Fire("Start", "", 0)
		sEffect:Fire("Kill", "", 5)
	
		door:SetColor(Color(255,255,255,255))
		door:SetCollisionGroup(door.oldGroup)
		door.hitsLeft = 8

		SafeRemoveEntity(prop)
	end)
	
	--self:delay(600, temp)
end

--called when the npc is chasing a target
function ENT:CustomChaseEnemy()

end

--called when a door is being attacked
function ENT:CustomDoorAttack( ent )
	if ( self.NextDoorAttackTimer or 0 ) < CurTime() then		
		if !self:CheckStatus() then return end
		
		self:AttackSound()
		self.loco:SetDeceleration(0)
		self.IsAttacking = true
		
		if(isnumber(self.AttackAnim)) then
			self:StartActivity(self.AttackAnim)
			coroutine.wait(1)
		else
			self:PlaySequenceAndWait( self.AttackAnim, 1 )
		end
		
		self:AttackEffect( self.AttackFinishTime, ent, self.Damage, 2, 1 )
		self.loco:SetDeceleration(900)
		self.NextDoorAttackTimer = CurTime() + self.NextAttack
	end
end

--called when a prop is being attacked
function ENT:CustomPropAttack( ent )
	if ( self.NextPropAttackTimer or 0 ) < CurTime() then
		self:AttackSound()
		self.loco:SetDeceleration(0)
		self.IsAttacking = true
		
		if(isnumber(self.AttackAnim)) then
			self:StartActivity(self.AttackAnim)
			coroutine.wait(1)
		else
			self:PlaySequenceAndWait( self.AttackAnim, 1 )
		end
		
		self:AttackEffect( self.AttackFinishTime, ent, self.Damage, 1, 1 )
		self.loco:SetDeceleration(900)
		
		self.NextPropAttackTimer = CurTime() + self.NextAttack
	end
end

function ENT:CheckProp( ent )
	if !ent:IsValid() then return end

	if !ent:GetPhysicsObject() then return end
	if !ent:GetPhysicsObject():IsValid() then return end
	if ent:GetPhysicsObject():GetMass() > 2600 then return end

	return true
end

--attacking an object
function ENT:AttackObject()
	local entstoattack = ents.FindInSphere(self:GetPos(), 25)
	for _,v in pairs(entstoattack) do

	
		if ( v:GetClass() == "func_breakable" or v:GetClass() == "func_physbox" or v:GetClass() == "prop_physics_multiplayer" or v:GetClass() == "prop_physics" or v:GetClass() == "nut_storage") then
			--[[
			local physObj = v:GetPhysicsObject()
			if(physObj and physObj:IsValid() and !physObj:IsMotionEnabled() and physObj:GetMass() > 10000) then
				return
			end
			--]]
			
			if v.FalseProp then return end
			if !self:CheckProp( v ) then return end

			self:CustomPropAttack( v )

			return true
		end
	end
	return false
end

--called when the npc catches on fire
function ENT:OnIgnite()
	if(!self.nextBurn) then self.nextBurn = 0 end

	if(self.nextBurn < CurTime()) then
		self:PainSound() --ow
		self.nextBurn = CurTime() + 5
	end
end

--called when the npc dies
function ENT:OnKilled( damageInfo )
	self:CustomDeath( damageInfo )
	self:DeathSound()
end

--not used in many npcs, creates an entity and makes it play an animation.
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

		zombie:StartActivity( activity )

		SafeRemoveEntity( self )
	end
end

--spurts of blood when the npc gets hit and things like that.
function ENT:BleedVisual( time, pos, color )
	if(pos != Vector(0,0,0)) then --prevents invalid positioning
		local bleed = ents.Create("info_particle_system")
		if(!color) then --red blood
			local ran = math.random(1)
			if(ran == 1) then
				bleed:SetKeyValue("effect_name", "blood_impact_red_01")
			else
				bleed:SetKeyValue("effect_name", "blood_zombie_split_spray")	
			end
			
		elseif(color == "yellow") then --yellow blood
			bleed:SetKeyValue("effect_name", "blood_impact_yellow_01")
			
		elseif(color == "green") then --green blood
			bleed:SetKeyValue("effect_name", "blood_impact_green_01")


		elseif(color == "none") then --weird effect
			bleed:SetKeyValue("effect_name", "hunter_shield_impact")
			bleed:SetParent(self)
		end
		
		bleed:SetPos( pos )
		bleed:Spawn()
		bleed:Activate()
		bleed:Fire("Start", "", 0)
		bleed:Fire("Kill", "", time)
	end
end

--called when the npc takes damage.
function ENT:OnInjured( dmginfo )

	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	local player = attacker:IsPlayer()
	local npc = attacker:IsNPC() or (attacker:GetClass() == "chance_plastic")
	
	--a little extra blood effect, not very noticeable.
	if(self:GetBloodColor() == BLOOD_COLOR_RED) then
		self:BleedVisual( 0.3, dmginfo:GetDamagePosition())		
		
	elseif(self:GetBloodColor() == BLOOD_COLOR_YELLOW) then
		self:BleedVisual( 0.3, dmginfo:GetDamagePosition(), "yellow")		
		
	elseif(self:GetBloodColor() == BLOOD_COLOR_GREEN) then
		self:BleedVisual( 0.3, dmginfo:GetDamagePosition(), "green")	
	
	elseif(self:GetBloodColor() == DONT_BLEED and (string.find(self:GetClass(), "shade") or string.find(self:GetClass(), "wraith") or self.wraith)) then
		self:BleedVisual( 0.3, dmginfo:GetDamagePosition(), "none")	
	end
	
	--if attacked with no enemy
	if (!self:HaveEnemy() and (player or npc)) then
		if (self:IsValid() and self:Health() > 0) then
			local temp = function()
				self:SetEnemy(attacker)
				self.loco:FaceTowards(attacker:GetPos())
			end
			self:delay(0.05, temp) --makes the reaction more reliable for some reason.
		end
	end

	--other npcs hear pain sounds.
	if(!self.nextPainSound) then self.nextPainSound = 0 end
	if (self.nextPainSound < CurTime()) then
		self:PainSound()
	
		local nearby = ents.FindInSphere(self:GetPos(), 400)
		for k, v in pairs(nearby) do
			if(v.chance and v != self) then
				if(!v:GetEnemy()) then
					v:SetEnemy(attacker)
					local temp = function()
						if(IsValid(attacker)) then
							v:SetEnemy(attacker)
							v.loco:FaceTowards(attacker:GetPos())
						end
					end
					v:delay(0.05, temp) --makes the reaction more reliable for some reason.
				end
			end
		end
		
		self.nextPainSound = CurTime() + 5
	end

	--sets npc on fire
	if ( self.Ignites and dmginfo:IsDamageType(DMG_BURN) ) then
		self:Ignite(10,30)
		self:SetColor(Color(100,100,100))
	end
	
	--slashing damage reduced
	if ( dmginfo:IsDamageType(DMG_SLASH) ) then
		dmginfo:ScaleDamage(0.7)
	end	
	
	--bullet damage increased
	if ( dmginfo:IsDamageType(DMG_BULLET) ) then
		dmginfo:ScaleDamage(2)
	end

	--explosion damage increased
	if dmginfo:IsDamageType(DMG_BLAST) then
		dmginfo:ScaleDamage(5)
		
		--has chance to set npc on fire
		if(self.Ignites) then
			if math.random(1,2) == 1 then
				self:Ignite( 10, 60 )
				self:SetColor(Color(100,100,100))
			end
		end
	end

	self:CustomInjure( dmginfo )
end

--look at the victim, approach location they were killed from
function ENT:BuddyKilled( victim, attacker )
	self:Enrage()
	self:SetEnemy(attacker)
	--my assumption for this is that if the attacker and npc positions are way different, they were killed with a firearm
	--firearms produce noise, so this should simulate them going towards the noise of a gunshot
	--in the case of their positions being similar, it would be that they heard the monster cry out in death or something like that.
	self.OldPos = attacker:GetPos()
	
	--after awhile of searching with no results, they calm down and run the calm function.

	local function temp()
		if(IsValid(self) and !self:GetEnemy()) then
			self:Calm()
		end
	end
	
	self:delay(30, temp)
end

--called when another npc dies
function ENT:OnOtherKilled( victim, dmginfo )
	if (!self:HaveEnemy()) then --if no enemy, go attack that dude
		if (victim.chance and victim != self) then
			if(self:GetPos():DistToSqr(victim:GetPos()) < (self.SearchRadius) * (self.SearchRadius) * 3) then
				local attacker = dmginfo:GetAttacker()
				
				if(attacker:IsPlayer() or attacker:IsNPC()) then
					self:BuddyKilled(victim, attacker)
				end
			end
		end
	end
end

--return the current enemy.
function ENT:GetEnemy()
	return self.Enemy
end

--attempts to set the current enemy.
function ENT:SetEnemy( ent )
	if(!ent) then
		return nil 
	end
	
	if(!ent:IsValid()) then 
		return nil 
	end
	
	self.Enemy = ent
	
	--this is used to prevent it from playing alert sounds/functions when it's just resetting to the same target. Kind of shitty
	if(ent != self.OldEnemy) then
		self:AlertSound()
		self:OnAlert()
	end
	
	return ent
end

--whether or not the npc can see the supplied position (I didnt make this)
function ENT:CanSeePos( pos1, pos2, filter )
	local trace = {}
	trace.start = pos1
	trace.endpos = pos2
	trace.filter = filter
	trace.mask = MASK_SOLID + CONTENTS_WINDOW + CONTENTS_GRATE
	local tr = util.TraceLine( trace )
	
	if( tr.Fraction == 1.0 ) then
		return true
	end
	
	return false
end

--whether or not the npc can see the supplied player.
function ENT:CanSeePlayer( ply )
	return self:CanSeePos( self:EyePos(), ply:EyePos(), { self, ply } );
end

--finds the closest player
function ENT:FindClosestPlayer()
	local closest = nil;
	local dist = math.huge;
	
	for _, v in pairs( player.GetAll() ) do
		local d = v:GetPos():DistToSqr( self:GetPos() );
			
		if( d < dist ) then
			dist = d;
			closest = v;
		end
	end
	
	return closest, dist;
end

--searches for an enemy
function ENT:SearchForEnemy( ents )
	for k,v in pairs( ents ) do
		if (v:IsPlayer() and v:Alive() and v:GetMoveType() != MOVETYPE_NOCLIP) then
			local char = v:getChar()
			if(char) then
				if (char:getFaction() == FACTION_ABOM) then
					continue --ignore abominations
				end
			end
		
			if(self:CanSeePlayer(v)) then
				return self:SetEnemy(v)
			end
		elseif(v:IsNPC()) then
			if(self:CanSeePlayer(v)) then
				return self:SetEnemy(v)
			end
		elseif(v.chance and v.team != self.team) then --team variable allows nextbots to fight each other.
			if(self:CanSeePlayer(v)) then
				return self:SetEnemy(v)
			end
		--elseif(v:IsRagdoll()) then --for them to go after and eat up corpses 

		end
	end

	return self:SetEnemy(nil)
end

--tries to find an enemy
function ENT:FindEnemy()
	return self:SearchForEnemy( ents.FindInCone( self:GetPos(), self:GetForward() * self.SearchRadius, self.SearchRadius, 155 ) )
end

--checks if we have an enemy, if we don't, try to find one. If we can't find one, we got nothing.
function ENT:HaveEnemy()
	local enemy = self:GetEnemy()
	
	if(!enemy or !enemy:IsValid()) then
		return self:FindEnemy()
	end
	
	if(self.retargetTime < CurTime()) then
		self.OldEnemy = enemy
		self.retargetTime = CurTime() + 10

		return self:FindEnemy()
	end
	
	if(enemy:IsPlayer() and !enemy:Alive()) then
		return self:FindEnemy()
	end
	
	if(enemy:IsNPC() and enemy:Health() < 0) then
		return self:FindEnemy()
	end

	return enemy
end

--put something in this for when you want the npc to be mad
function ENT:Enrage()
end

--this is what happens when enrage wears off
function ENT:Calm()
end

--called when the npc spots an enemy or changes targets
function ENT:OnAlert()
end

--called during think, use for clientside functions.
function ENT:CustomThinkClient()
end

--makes npcs look like different, called in OnSpawn()
function ENT:Shadow()
	--you need to put ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	--for this to work properly
	self.pitch = self.pitch - 40
	self:SetBloodColor(DONT_BLEED)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(0,0,0))
	self:SetRenderFX(kRenderFxDistort)
	self.Ignites = false
end
