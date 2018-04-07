AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.Base = "nz_projectile_base"

ENT.Damage = 2
ENT.DamageType = DMG_BURN
ENT.Time = 1

ENT.PainSound1 = Sound("player/pl_burnpain1.wav")
ENT.PainSound2 = Sound("player/pl_burnpain2.wav")
ENT.PainSound3 = Sound("player/pl_burnpain3.wav")

ENT.ImpactSound1 = Sound("physics/flesh/flesh_squishy_impact_hard1.wav")
ENT.ImpactSound2 = Sound("physics/flesh/flesh_squishy_impact_hard2.wav")
ENT.ImpactSound3 = Sound("physics/flesh/flesh_squishy_impact_hard3.wav")
ENT.ImpactSound4 = Sound("physics/flesh/flesh_squishy_impact_hard4.wav")

ENT.Type = "anim"
