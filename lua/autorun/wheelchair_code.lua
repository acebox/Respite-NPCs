if SERVER then
	AddCSLuaFile()
end

hook.Add( "PlayerHurt", "hurt_effect_fade", function( ply )
	ply:ScreenFade( SCREENFADE.IN, Color( 255, 0, 0, 128 ), 0.3, 0 )
	ply:ViewPunch(Angle(math.random(-1,1)*3,math.random(-1,1)*3,math.random(-1,1)*3))
end )

local HorrorMonsterPlayerEffectTime = 0

hook.Add("Think","MayhemHorrorNPCEffects",function()
		
	for P=1, #player.GetAll() do
		local ply = player.GetAll()[P]
		
		if(SERVER) then
			if(HorrorMonsterPlayerEffectTime<CurTime()) then
						
				local TEMP_MONSTERS = ents.FindByClass("resp_wheelchair")
				
				if(GetConVar("ai_disabled"):GetInt()==0&&GetConVar("ai_ignoreplayers"):GetInt()==0&&#TEMP_MONSTERS>0) then
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
							ply:ViewPunch(Angle(math.random(-1,1)*2,math.random(-1,1)*2,math.random(-1,1)*2))
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
end)

hook.Add( "PreDrawHUD", "MayhemHorrorNPCEffects_Hud", function()
	if(IsValid(LocalPlayer())&&LocalPlayer():Alive()) then
		local TEMP_PSYDMG = LocalPlayer():GetNWFloat("MayhemHorrorNPCEffects",0)
			
		if(TEMP_PSYDMG>0) then
			local tab = {
				[ "$pp_colour_addr" ] = 0.01*(TEMP_PSYDMG*2),
				[ "$pp_colour_addg" ] = 0.02*(TEMP_PSYDMG*2),
				[ "$pp_colour_addb" ] = 0.3*(TEMP_PSYDMG*2),
				[ "$pp_colour_brightness" ] = -0.43*(TEMP_PSYDMG*2),
				[ "$pp_colour_contrast" ] = 0.5-(0.22*(TEMP_PSYDMG*2)),
				[ "$pp_colour_colour" ] = 0.5-(0.7*(TEMP_PSYDMG*2)),
			}

			DrawColorModify( tab )
			
			DrawMotionBlur( 0.3, 0.9*(TEMP_PSYDMG*2), 0.001 )
			
			local TEMP_BLUR = Material("effects/flicker_256")
		
			cam.Start2D()
				local x, y = 0, 0
				local scrW, scrH = ScrW(), ScrH()
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial( TEMP_BLUR )
				
				for i = 1, 3 do
					TEMP_BLUR:SetFloat("$blur", (LocalPlayer():GetNWFloat("MayhemHorrorNPCEffects",0)*3)*i)
					TEMP_BLUR:Recompute()
					render.UpdateScreenEffectTexture()
					surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
				end
			cam.End2D()
		end
	end
end )