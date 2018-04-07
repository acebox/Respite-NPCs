if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

ENT.Base             = "amputated"
ENT.Spawnable        = false
ENT.AdminSpawnable   = false


list.Set( "NPC", "amputated_flame", {
	Name = "Amputated (Flame)",
	Class = "amputated_flame",
	Category = "Respite - Wraith"
} )

ENT.classname = "amputated"
ENT.NiceName = "Amputated"

ENT.Ignites = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:OnSpawn()
	self.pitch = self.pitch + 20
	self:SetMaterial("models/effects/splode1_sheet")
end

function ENT:CustomDeath( dmginfo )
	if (math.random(0,5) == 5) then
		nut.item.spawn("ichor", self:GetPos()+ Vector(0,0,20))
	end		

    util.Decal("bloodpool" .. math.random(1,3) .. "", self:GetPos() - Vector(4,4,4), self:GetPos() - Vector(4,4,4))
	self:TransformRagdoll( dmginfo )
end

function ENT:OnAlert(dmginfo)
	if(math.random(0,1) == 1) then
		self:EmitSound("ambient/fire/ignite.wav")
		self:Ignite(180)
	end
end

function ENT:CustomInjure( dmginfo )
	local attacker = dmginfo:GetAttacker()
	if (attacker.IsPlayer() and attacker != self.Enemy) then
		self:SetEnemy(attacker)
	end
	
	if(dmginfo:GetDamageType() == 268435464 or dmginfo:GetDamageType() == DMG_BURN) then
		dmginfo:ScaleDamage(0)
	end
	
	if ( dmginfo:IsBulletDamage() ) then
		// hack: get hitgroup
		local trace = {}
		trace.start = attacker:GetShootPos()
			
		trace.endpos = trace.start + ( ( dmginfo:GetDamagePosition() - trace.start ) * 2 )  
		trace.mask = MASK_SHOT
		trace.filter = attacker
			
		local tr = util.TraceLine( trace )
		hitgroup = tr.HitGroup
					
		if hitgroup == HITGROUP_HEAD then
			self:EmitSound("hits/headshot_"..math.random(9)..".wav", 70)
			dmginfo:ScaleDamage(20) --just kill the thing
		end
	end
end