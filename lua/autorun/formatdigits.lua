--[This looks suspicious, but it's just digit formatting for Nextbot sounds.]
function string.FormatDigits( str )
	
	if( tonumber( str ) < 10 ) then
		
		return "0" .. str;
		
	end
	
	return str;
end

--[Soundlevel ENUMS]

SNDLVL_GUNFIRE = 120
SNDLVL_NORM = 80
SNDLVL_20dB = 20
SNDLVL_25dB = 25
SNDLVL_30dB = 30
SNDLVL_35dB = 35
SNDLVL_40dB = 40
SNDLVL_45dB = 45
SNDLVL_50dB = 50
SNDLVL_55dB = 55
SNDLVL_60dB = 60
SNDLVL_65dB = 65
SNDLVL_70dB = 70
SNDLVL_75dB = 75
SNDLVL_80dB = 80
SNDLVL_85dB = 85
SNDLVL_90dB = 90
SNDLVL_95dB = 95
SNDLVL_100dB = 100
SNDLVL_105dB = 105
SNDLVL_105 = 105
SNDLVL_110dB = 110
SNDLVL_115dB = 115
SNDLVL_120dB = 120
SNDLVL_125dB = 125
SNDLVL_130dB = 130
SNDLVL_135dB = 135
SNDLVL_140dB = 140
SNDLVL_145dB = 145
SNDLVL_150dB = 150
SNDLVL_155dB = 155
SNDLVL_160dB = 160
SNDLVL_165dB = 165
SNDLVL_170dB = 170
SNDLVL_175dB = 175
SNDLVL_180dB = 180

if CLIENT then
 
local iRed, iGreen, iBlue
local mulRed, mulGreen, mulBlue
local iBrightness, iContrast, brightnessRate, contrastRate
local wep
local blur, rate, MotionBlurAmount
local motionBlur = 0
 
local colorMod = {}
colorMod[ "$pp_colour_addr" ]           = 0
colorMod[ "$pp_colour_addg" ]           = 0
colorMod[ "$pp_colour_addb" ]           = 0
colorMod[ "$pp_colour_brightness" ]     = 0
colorMod[ "$pp_colour_contrast" ]       =  0
colorMod[ "$pp_colour_colour" ]                 = 0
colorMod[ "$pp_colour_mulr" ]           = 0
colorMod[ "$pp_colour_mulg" ]           = 0
colorMod[ "$pp_colour_mulb" ]           = 0
colorMod.bloom =
{
        [ 1 ] = 1,
        [ 2 ] = 0.2,
        [ 3 ] = 4,
        [ 4 ] = 4,
        [ 5 ] = 1,
        [ 6 ] = 1,
        [ 7 ] = 1,
        [ 8 ] = 1,
        [ 9 ] = 1,
}
 
function animatedColor( start, newValue, rate )
        if ( start == newValue ) then return newValue end
 
        return math.Approach( start, newValue, rate )
end
 
local function GetMotionBlurValues( x, y, fwd, spin )
        local pl = LocalPlayer()
        wep = pl:GetActiveWeapon()
       
       
       blur, rate, MotionBlurAmount = 0, 0.05, math.Clamp( 1 - ( pl:Health() / 35 ),0, 0.15 )
       
                if ( IsValid( wep ) && wep.Base == "tfa_base" && wep:GetIronSights() ) then
                        MotionBlurAmount =  0.07
                        rate = 0.05
                end
               
       
        motionBlur = math.Approach(motionBlur, MotionBlurAmount, FrameTime() * rate )
        return blur, blur, math.max(fwd, motionBlur), spin
end
hook.Add( "GetMotionBlurValues", "IWMotionBlur", GetMotionBlurValues )

--[[function color()
        local pl = LocalPlayer()  
        if pl.InPAC3Editor then return end
        if ( nut.gui.char and nut.gui.char:IsVisible() ) then return end
		
        if ( IsValid( pl ) ) then
		       
        iRed, iGreen, iBlue = 0, 0, 0; //Set up the value's
        mulRed, mulGreen, mulBlue = 0, 0, 0; // How much will it be multiplied by?
        iBrightness, iContrast = 0, 1 // set up the default numbers
                if ( pl:Health() <= 30 ) then
                        iRed, mulRed, iGreen, mulGreen = 0.02, 0.02, 0.02, 0.02
                end
               
                if ( pl:Health() <= 20 ) then
                        iRed, mulRed, iGreen, mulGreen = 0.04, 0.04, 0.04, 0.04
                end
                       
                if ( pl:Health() <= 10 ) then
                        iRed, iGreen, mulRed, mulGreen = 0.001 + math.Clamp( math.sin( math.abs( RealTime() * 0.6 ) * 14 ) * 10, 0., 0.1 ) , 0.03, 0.2, 0.5
          
        end
       
                colorMod[ "$pp_colour_addr" ]   = animatedColor( colorMod[ "$pp_colour_addr" ], iRed, FrameTime() * 1 )
                colorMod[ "$pp_colour_addg" ]   = animatedColor( colorMod[ "$pp_colour_addg" ] , iGreen, FrameTime() * 0.02 )
                colorMod[ "$pp_colour_mulr" ]   = animatedColor( colorMod[ "$pp_colour_mulr" ] ,  mulRed, FrameTime() * 0.02 )
                colorMod[ "$pp_colour_mulg" ]   = animatedColor( colorMod[ "$pp_colour_mulg" ] , mulGreen, FrameTime() * 0.02 )
                colorMod[ "$pp_colour_contrast" ] = animatedColor( colorMod[ "$pp_colour_contrast" ], iContrast, FrameTime() * 0.7 )
                colorMod[ "$pp_colour_brightness" ] = animatedColor( colorMod[ "$pp_colour_brightness" ], iBrightness, FrameTime() * 0.44 )
                colorMod[ "$pp_colour_colour" ] = 1
               
                DrawColorModify( colorMod )
                DrawBloom( colorMod.bloom[ 1 ], colorMod.bloom[ 2 ], colorMod.bloom[ 3 ], colorMod.bloom[ 4 ], colorMod.bloom[ 5 ], colorMod.bloom[ 6 ], colorMod.bloom[ 7 ], colorMod.bloom[ 8 ], colorMod.bloom[ 9 ] )
        end
 
end
hook.Add( "RenderScreenspaceEffects", "Color", color )--]]

function panic()

local blink = 0
local near = 200
 -- baseclass.Get( v:GetClass() ).Base == 'base_nextbot' or baseclass.Get( v:GetClass() ).Base == 'nz_base' )
for k, v in pairs( ents.FindInSphere( EyePos(), near )) do
if IsValid( v ) and ( v:GetClass() == "shadow" ) then

local dist = v:GetPos():Distance(LocalPlayer():GetPos())
local proc = ( 1 - math.Clamp( dist / near, 0, 1 ) ) * 3
local b = ( 0.01 - math.Clamp( dist / near, 0, 1 ) ) * 1

local lowhealth = {
[ "$pp_colour_addr" ] = -25/255,
[ "$pp_colour_addg" ] = -25/255,
[ "$pp_colour_addb" ] = -5/255,
[ "$pp_colour_brightness" ] = 0,
[ "$pp_colour_contrast" ] = 0.9,
[ "$pp_colour_colour" ] = 0.4,
[ "$pp_colour_mulr" ] = 0,
[ "$pp_colour_mulg" ] = 0,
[ "$pp_colour_mulb" ] = 0
}

   DrawSharpen(0.3, math.ceil( 25 * proc )  )
   -- DrawMotionBlur(0.5, math.ceil( 1 * proc ), 0.01  )
   DrawColorModify( lowhealth )	
   surface.PlaySound( 'chorror/bass4.wav' )	
   timer.Create( 'bass', 0.5, 1, function() surface.PlaySound( 'chorror/bass4.wav' ) end )
   end
   end

   end
   hook.Add( "HUDPaint", "Panic", panic )
   
   
	-- as suggested by Kamshak, I will now start using locals in a different way so that my code is "readable"
	CreateClientConVar("lowhp_status", 1, true, true)
	
	local intensity = 0
	local hpwait, hpalpha = 0, 0
	local vig = surface.GetTextureID("vgui/vignette_w")
	
	local clr = {
		[ "$pp_colour_addr" ] = 0,
		[ "$pp_colour_addg" ] = 0,
		[ "$pp_colour_addb" ] = 0,
		[ "$pp_colour_brightness" ] = 0,
		[ "$pp_colour_contrast" ] = 1,
		[ "$pp_colour_colour" ] = 1,
		[ "$pp_colour_mulr" ] = 0,
		[ "$pp_colour_mulg" ] = 0,
		[ "$pp_colour_mulb" ] = 0
	}
	
	-- these are the settings for various parts of the script
	-- you can turn off various parts of it by changing 'true' to 'false' here
	
	local LHPS = {
		lowhpthreshold = 25, -- when the player's health reaches this value, various low health effects will start kicking in and increasing in intensity as his health lowers
		drawVignette = false,
		drawRedFlash = false,
		playHeartbeatSound = true,
		muffleSounds = false,
		muffleSoundsOnHealth = 10 -- when the player's health reaches this value, sounds will become muffled
	}

	local function LowHP_HUDPaint()
		if GetConVarNumber("lowhp_status") <= 0 then
			return 
		end
		
		local ply = LocalPlayer()
		local hp = ply:Health()
		local x, y = ScrW(), ScrH()
		local FT = FrameTime()
		
		if LHPS.muffleSounds then
			if ply:Health() <= LHPS.muffleSoundsOnHealth then
				if not ply.lastDSP then
					ply:SetDSP(14)
					ply.lastDSP = 14
				end
			else
				if ply.lastDSP then
					ply:SetDSP(0)
					ply.lastDSP = nil
				end
			end
		end
		
		intensity = math.Approach(intensity, math.Clamp(1 - math.Clamp(hp / LHPS.lowhpthreshold, 0, 1), 0, 1), FT * 3)
		
		if intensity > 0 then
			if LHPS.drawVignette then
				surface.SetDrawColor(0, 0, 0, 200 * intensity)
				surface.SetTexture(vig)
				surface.DrawTexturedRect(0, 0, x, y)
			end
			
			clr[ "$pp_colour_colour" ] = 1 - intensity
			DrawColorModify(clr)
			
			if ply:Alive() then
				local CT = CurTime()
				
				if LHPS.playHeartbeatSound then
					if CT > hpwait then
						ply:EmitSound("lowhp/hbeat.wav", 45 * intensity, 100 + 20 * intensity)
						hpwait = CT + 0.5
					end
				end
				
				if LHPS.drawRedFlash then
					surface.SetDrawColor(255, 0, 0, (50 * intensity) * hpalpha)
					surface.DrawTexturedRect(0, 0, x, y)
					
					if CT < hpwait - 0.4 then
						hpalpha = math.Approach(hpalpha, 1, FrameTime() * 10)
					else
						hpalpha = math.Approach(hpalpha, 0.33, FrameTime() * 10)
					end
				end
			end
		end	
	end
	
	hook.Add("HUDPaint", "LowHP_HUDPaint", LowHP_HUDPaint)
end
