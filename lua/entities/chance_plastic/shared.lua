if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "nz_base_mod"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false

--SpawnMenu--
list.Set( "NPC", "chance_plastic", {
	Name = "Plastic",
	Class = "chance_plastic",
	Category = "Respite - Experimental"
} )

ENT.classname = "chance_plastic"
ENT.NiceName = "Plastic"
--Stats--
ENT.MoveType = 2

ENT.UseFootSteps = 1

ENT.FootAngles = 11
ENT.FootAngles2 = 11

--[[
ENT.Bone1 = "mixamorig:RightFoot"
ENT.Bone2 = "mixamorig:LeftFoot"
--]]

ENT.CollisionHeight = 85
ENT.CollisionSide = 13

ENT.Speed = nut.config.get("walkSpeed")
ENT.WalkSpeedAnimation = 1.0

ENT.health = 100
ENT.Damage = 25

ENT.PhysForce = 30000
ENT.AttackRange = 75
ENT.InitialAttackRange = 60
ENT.DoorAttackRange = 60

ENT.NextAttack = 0.6

--Model Settings--
ENT.Model = "models/tnb/citizens/male_04.mdl"

ENT.WalkAnim = "walk_all"

ENT.IdleAnim = "idle_all_01"


--Sounds--

ENT.DoorBreak = Sound("npc/zombie/zombie_pound_door.wav")

ENT.Sound1 = Sound("respite/housewife/01.wav")
ENT.Sound2 = Sound("respite/housewife/02.wav")
ENT.Sound3 = Sound("respite/housewife/03.wav")

ENT.HitSound = Sound("npc/zombie/claw_strike1.wav")
ENT.Miss = Sound("npc/zombie/claw_miss1.wav")

ENT.Inventory = {}
ENT.Stuck = false

function ENT:Draw()

	--if( self:Alive() ) then
		
		self:DrawModel();

	--end

	if( !self.Gun ) then

		self.Gun = ClientsideModel( "models/props_canal/mattpipe.mdl", RENDERGROUP_BOTH )
		self.Gun:SetParent( self ) --doesnt actually work
		self.Gun:AddEffects( EF_BONEMERGE )
		
		function self.Gun:RenderOverride()

			if( !self:GetParent() or !self:GetParent():IsValid()) then return end
			self:DrawModel()

		end

	elseif( self.Gun and self.Gun:IsValid() ) then

		self.Gun:SetPos( self:GetPos() )
		self.Gun:DrawModel()

	end

end

function ENT:Precache()

util.PrecacheModel(self.Model)

util.PrecacheSound(self.DoorBreak)
util.PrecacheSound(self.Sound1)
util.PrecacheSound(self.Sound2)
util.PrecacheSound(self.Sound3)
util.PrecacheSound(self.HitSound)
util.PrecacheSound(self.Miss)

end

function ENT:Initialize()
	
	self:SetModel(self.Model)
	self:SetMaterial("phoenix_storms/mrref2")

	if SERVER then
	
	self.Inventory = self:CreateInv()
	
	self:SetBloodColor(DONT_BLEED)
	self:SetHealth(self.health)	
	
	self.LoseTargetDist	= (self.LoseTargetDist)
	self.SearchRadius 	= (self.SearchRadius)
	
	self.loco:SetStepHeight(35)
	self.loco:SetAcceleration(500)
	self.loco:SetDeceleration(900)

	self:Precache()
	self:CreateBullseye()
	self:CollisionSetup( self.CollisionSide, self.CollisionHeight, COLLISION_GROUP_INTERACTIVE_DEBRIS )
	self:PhysicsInitShadow(true, true)
	
	end
end

function ENT:GetTask()
	if(self:FindTree()) then
		return true
	end
	
	if(self:HaveObj()) then
		return true
	end	
	
	if(table.Count(self:getInv():getItems()) > 0 and self:FindStorage()) then
		return true
	end
	
	if(self:FindEnemy()) then
		return true
	end
	
	return false
end

function ENT:RunBehaviour()
	while (true) do	
		if (self:GetEnemy()) then
			local enemy = self:GetEnemy() 
			self:MovementFunctions( self.MoveType, "run_all_01", self.Speed*2, self.WalkSpeedAnimation ) --run
			self:GoToEnemy(enemy)
			self:Attack()
		elseif (table.Count(self:getInv():getItems()) > 0 and self:FindStorage()) then
			local storage = self:FindStorage()
			self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed/1.5, self.WalkSpeedAnimation ) --walk
			self:GoToLocation(storage:NearestPoint(self:GetPos()))
			self:Deposit(storage)
		elseif (self:HaveObj()) then
			local object = self:HaveObj()
			self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed/1.5, self.WalkSpeedAnimation )
			self:GoToLocation(object:NearestPoint(self:GetPos()))
			self:PickUp()
		elseif (self:FindTree()) then
			local tree = self:FindTree()
			self:MovementFunctions( self.MoveType, "run_all_01", self.Speed*2, self.WalkSpeedAnimation )
			self:GoToLocation(tree:NearestPoint(self:GetPos()))
			self:Harvest(tree)
		else
			self:MovementFunctions( self.MoveType, self.WalkAnim, self.Speed/1.5, self.WalkSpeedAnimation )
            self:CustomMoveToPos(self:GetPos() + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400) -- Walk to a random place within about 400 units (yielding)
		end
		
		coroutine.yield()
	end
end

function ENT:CreateInv()
	nut.item.registerInv("plastic", 20, 20)
	nut.item.newInv(0, "plastic", function(inventory)
		self:setInventory(inventory)
	end)
end

function ENT:setInventory(inventory)
	if (inventory) then
		self:setNetVar("id", inventory:getID())
			
		inventory.onAuthorizeTransfer = function(inventory, client, oldInventory, item)
			if (IsValid(client) and IsValid(self) and self.receivers[client]) then
				return true
			end
		end
		inventory.onCanTransfer = function(inventory, client, oldX, oldY, x, y, newInvID)
			return hook.Run("StorageCanTransfer", inventory, client, oldX, oldY, x, y, newInvID)
		end
	end
end

function ENT:getInv()
	return nut.item.inventories[self:getNetVar("id", 0)]
end

function ENT:PickUp()
	timer.Simple(0.2, 
		function()
			self:ResetSequence("pose_ducking_01")
		end
	)
	self.loco:SetDesiredSpeed(0)
	coroutine.wait(0.5)
	if(self:GetObj() and IsValid(self:GetObj())) then
		local id = self:GetObj().nutItemID
		if(id) then
			self:getInv():add(id)
		end
		self:GetObj():Remove()
	end
	self.Obj = nil
end

--finds a nutscript item on the ground in field of view.
function ENT:FindObj()
	local item = false
	local everything = ents.FindInCone( self:GetPos(), self:GetForward() * self.SearchRadius, self.SearchRadius, 155 )
	if(everything) then
		for k,v in pairs( everything ) do
			if(v:GetClass() == "nut_item" and IsValid(v)) then
				item = v
				break
			end
		end
		
		self.Obj = item
		return item
	else
		return false
	end
end

function ENT:SetEnemy(target)
	self.Enemy = target
end

function ENT:GetEnemy()
	local enemy = self.Enemy
	if(enemy and IsValid(enemy) and enemy:Health() > 0) then
		return self.Enemy
	else
		return self:FindEnemy()
	end
end

function ENT:FindEnemy()
	local everything = ents.FindInCone( self:GetPos(), self:GetForward() * self.SearchRadius, self.SearchRadius, 155 )
	if(everything) then
		for k,v in pairs( everything ) do
			if v:IsPlayer() and v:Alive() and v:GetMoveType() != MOVETYPE_NOCLIP then
				self:SetEnemy(v)
				return v
			end
			
			if ((v:IsNPC() or string.find(v:GetClass(), "nz_*")) and v:GetClass() != "chance_plastic" and v:Health() > 0 and !string.find(v:GetClass(), "npc_bullseye") and !string.find(v:GetClass(), "npc_grenade_frag") and !string.find(v:GetClass(), "animprop_generic")) then
				self:SetEnemy(v)
				return v
			end
		end
	end

	self:SetEnemy(nil)
	return false
end


--test func
function ENT:FindTree()
	local everything = ents.FindInSphere( self:GetPos(), 90000 )
	local gather = {}
	local gatherEnt
	if(everything) then
		for k,v in pairs( everything ) do
			if((v:GetClass() == "nut_tree" or v:GetClass() == "nut_portal") and IsValid(v)) then
				table.insert(gather, v)
			end
		end
		
		if(table.Count(gather) > 0) then
			gatherEnt = table.Random(gather)
			return gatherEnt
		else
			return false
		end
	else
		return false
	end
end

function ENT:Harvest(gather)
	if(!gather) then --if the ent got removed or something in the middle of harvesting
		return false
	end

	timer.Simple(0.2, 
		function()		
			self:ResetSequence("seq_baton_swing")
			
			local dmginfo = DamageInfo()
			dmginfo:SetDamagePosition(self:GetPos() + Vector(0,0,100) + self:GetForward()*40)
			dmginfo:SetAttacker(self)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamage(11)
			
			if(IsValid(gather)) then
				gather:TakeDamageInfo(dmginfo)
			end
		end
	)
	self.loco:SetDesiredSpeed(0)
	coroutine.wait(1)
end

--finds a storage entity around itself
function ENT:FindStorage()
	local everything = ents.FindInSphere( self:GetPos(), 90000 )
	local storage = {}
	if(everything) then
		for k,v in pairs( everything ) do
			if(v:GetClass() == "nut_storage" and IsValid(v)) then
				table.insert(storage, v)
			end
		end
		
		if(table.Count(storage) > 0) then
			self.Storage = table.Random(storage)
			return self.Storage
		else
			return false
		end
	else
		return false
	end
	
end

--checks if it has an object.
function ENT:HaveObj()
	local obj = self:GetObj()

	if ( obj and IsValid( obj ) ) then
		return self:GetObj()
	else
		return self:FindObj()
	end
end

function ENT:GetObj()
	return self.Obj
end

--pathing function, tells it to go somewhere
function ENT:GoToLocation(location, options)

	if(!util.IsInWorld(location)) then return end

	local options = options or {}

	local path = Path("Follow")
	path:SetMinLookAheadDistance(10000)
	path:SetGoalTolerance(10)

	path:Compute(self, location)
		
	if (!path:IsValid()) then return "failed" end
	
	while (path:IsValid() and location and !self:GetEnemy()) do
		if (path:GetAge() > 20) then
			path:Compute(self, location)
		end
		
		if (!self.Stuck and self.loco:IsStuck()) then
			self.Stuck = true
			local oldLoc = location
			location = self:GetPos() + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 1000
			path:Compute(self, location)
			timer.Simple(1, 
				function()
					location = oldLoc
					path:Compute(self, location)
					self.Stuck = false
				end
			)
		end
		
		path:Update(self)

		if (self:GetPos():DistToSqr(location) < 50 * 50) then break end
		
		coroutine.yield()
	end
	return "ok"

end

--pathin function, tells it to go somewhere
function ENT:GoToEnemy(options)
	--
	local options = options or {}

	local path = Path("Chase")
	path:SetMinLookAheadDistance(10000)
	path:SetGoalTolerance(20)
	
	if(!self.Enemy) then return end
	
	local enemy = self.Enemy
	local location = enemy:NearestPoint(self:GetPos())
	
	path:Compute(self, location)
		
	if (!path:IsValid()) then return "failed" end

	while (path:IsValid() and IsValid(enemy) and enemy:Health() > 0) do
		if (path:GetAge() > 0.1) then	
			location = enemy:NearestPoint(self:GetPos())
			path:Compute(self, location)
		end

		path:Update(self)
		
		if (self:GetPos():DistToSqr(location) < 50 * 50) then break end
		
		coroutine.yield()

	end
	return "ok"

end

function ENT:OnStuck()
	--[[
	local trace = { }
	trace.start = self:GetPos() + Vector( 0, 0, 64 )
	trace.endpos = trace.start + self:GetForward() * 60
	trace.filter = self
	trace.mins = Vector( -16, -16, 16 )
	trace.maxs = Vector( 16, 16, 16 )
	local tr = util.TraceHull( trace )

	local door = tr.Entity
	if( door and door:IsValid() and door:isDoor() ) then --isDoor() is probably a nutscript specific function, couldnt find it though.
		local oldGroup = tr.Entity:GetCollisionGroup()
		door:Fire( "Open" )
		timer.Simple(0.5, 
			function()
				door:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			end
		)
		timer.Simple(2, 
			function()
				tr.Entity:SetCollisionGroup(oldGroup)
			end
		)
	end
	--]]
end


--drops the plastic's entire inventory at once.
function ENT:DropInv()
	if(SERVER) then
		local inv = self:getInv()
		if(inv) then
			local dropTable = inv:getItems()
			if(dropTable) then
				for k, v in pairs(dropTable) do
					v:spawn(self:GetPos())
					inv:remove(v.id, false, true)
				end
			end
		end
	end
end

--Puts the plastic's inventory into a storage object
function ENT:Deposit(storage)
	if(SERVER) then
		local invID = storage:getNetVar("id")
	
		local inv = self:getInv()
		if(inv) then
			timer.Simple(0.2, 
				function()
					self:ResetSequence("pose_ducking_01")
				end
			)
			self.loco:SetDesiredSpeed(0)
			coroutine.wait(0.5)
			local dropTable = inv:getItems()
			if(dropTable) then
				for k, v in pairs(dropTable) do
					v:transfer(invID)
				end
			end
		end
	end
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
end

function ENT:CustomDeath( dmginfo )
	self:DropInv()
	self:TransformRagdoll( dmginfo)
end

function ENT:OnRemove( dmginfo )
	self:DropInv()
end

--[[
function ENT:FootSteps()
	local random = math.random( 1, 3 )
	self:EmitSound( 'monsters/suitor/metal_run0'  .. random .. '.mp3', 75, math.random(80, 95) )
end
--]]

--[[
function ENT:AlertSound()
	local sounds = {}
		sounds[1] = (self.Sound1)
		sounds[2] = (self.Sound2)
		sounds[3] = (self.Sound3)
	self:EmitSound( sounds[math.random(1,3)], 65, math.random(70, 100) )
end

function ENT:PainSound()
	local sounds = {}
		sounds[1] = (self.Sound1)
		sounds[2] = (self.Sound2)
		sounds[3] = (self.Sound3)
	self:EmitSound( sounds[math.random(1,3)], 65, math.random(70, 100) )
end

function ENT:DeathSound()
	local sounds = {}
		sounds[1] = (self.Sound1)
		sounds[2] = (self.Sound2)
		sounds[3] = (self.Sound3)
	self:EmitSound( sounds[math.random(1,3)], 65, math.random(50, 80) )
end

function ENT:AttackSound()
	local sounds = {}
		sounds[1] = (self.Sound1)
		sounds[2] = (self.Sound2)
		sounds[3] = (self.Sound3)
	self:EmitSound( sounds[math.random(1,3)], 65, math.random(70, 100) )
end

function ENT:IdleSound()
	local sounds = {}
		sounds[1] = (self.Sound1)
		sounds[2] = (self.Sound2)
		sounds[3] = (self.Sound3)
	self:EmitSound( sounds[math.random(1,3)], 65, math.random(70, 100) )
end
--]]

--[[
function ENT:CustomDoorAttack( ent )

	if ( self.NextDoorAttackTimer or 0 ) < CurTime() then
	
		if !self:CheckStatus() then return end
	
		self:AttackSound()
	
		self:Melee( ent, 2 )
		
		self.NextDoorAttackTimer = CurTime() + self.NextAttack
	end
	
end
--]]
	
--[[
function ENT:CustomPropAttack( ent )

	if ( self.NextPropAttackTimer or 0 ) < CurTime() then

		if !self:CheckStatus() then return end
	
		self:AttackSound()
	
		self:Melee( ent, 1 )
	
		self.NextPropAttackTimer = CurTime() + self.NextAttack
	end
	
end
--]]

function ENT:AttackEffect( time, ent, dmg, type )

	timer.Simple(time, function() 
		if !self:IsValid() then return end
		if self:Health() < 0 then return end
		if !self:CheckValid( ent ) then return end
		if !self:CheckStatus() then return end
		
		if self:GetRangeTo( ent ) < self.AttackRange then
			
			ent:TakeDamage( self.Damage, self )
			
			if ent:IsPlayer() or ent:IsNPC() or string.find(ent:GetClass(), "nz_*") then
				self:BleedVisual( 0.2, ent:GetPos() + Vector(0,0,50) )	
				self:EmitSound("npc/infected_zombies/hit_punch_0"..math.random(8)..".wav", math.random(100,125), math.random(85,105))
				self:EmitSound("physics/body/body_medium_impact_hard"..math.random(5,6)..".wav")
			end
			
			if ent:IsPlayer() then
				ent:ViewPunch(Angle(math.random(-1, 1)*self.Damage, math.random(-1, 1)*self.Damage, math.random(-1, 1)*self.Damage))
			end
							
		else	
			self:EmitSound("npc/infected_zombies/claw_miss_"..math.random(2)..".wav", math.random(75,95), math.random(65,95))
		end
		
	end)

end

function ENT:Melee( ent, type )

	self.loco:FaceTowards(ent:GetPos())
    self:AttackEffect( 0.8, ent, self.Damage, type )
    self:PlaySequenceAndWait( "seq_baton_swing", 1 )

	
	self.IsAttacking = false
	self:ResumeMovementFunctions()
	
end

function ENT:Attack()
		
	if ( self.NextAttackTimer or 0 ) < CurTime() then	
		
		if ( (self.Enemy:IsValid() and self.Enemy:Health() > 0 ) ) then
		
			if !self:CheckStatus() then return end
			
			self:AttackSound()
			self.IsAttacking = true
	
			self:Melee( self.Enemy, 0 )
			
		end
		
		self.NextAttackTimer = CurTime() + self.NextAttack
	end	
	
end

function ENT:AttackSound()
--in the future want this determined by wielded weapon
	self:EmitSound("npc/vort/claw_swing"..math.random(1,2)..".wav")
end

function ENT:CustomMoveToPos(pos, options)
    local options = options or {}

	local path = Path("Follow")
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 20)
	path:Compute(self, pos)

	if (!path:IsValid()) then return "failed" end

	while (path:IsValid() and !self:GetTask()) do
        local zombiePosition = self:GetPos()

		while(!util.IsInWorld(pos)) do
			pos = zombiePosition + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400
			path:Compute(self, pos)
		end
		
		if(path:GetAge() > 10) then
			if(zombiePosition == self:GetPos()) then --havent gone anywhere in 10 seconds.
				pos = zombiePosition + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400
				path:Compute(self, pos)
			end
		end
		
        if(zombiePosition:DistToSqr(pos) < 50 * 50 or path:GetAge() > 30) then
			
            pos = zombiePosition + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 800
			path:Compute(self, pos)
		end
		path:Update(self)

		-- if (options.draw) then path:Draw() end

		--[[if (self.loco:IsStuck()) then
			self:HandleStuck()
			return "stuck"
		end--]]

		coroutine.yield()

	end

	return "ok"

end