-- TODO move convars to main convars file
local h2_enabled = CreateClientConVar( "tacrp_h2_enable", 1, true, false )
local h2_enabled_health = CreateClientConVar( "tacrp_h2_enable_health", 1, true, false )
local h2_enabled_ammo = CreateClientConVar( "tacrp_h2_enable_ammo", 1, true, false )
local s = TacRP.SS

local hide_health = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
}

local hide_ammo = {
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
}

local hints = {
	{
		"[E] + [R]",
		"Change Firemode",
	},
	{
		"[T]",
		"Quickthrow",
	},
	{
		"[J]",
		"Quickthrow Menu",
	},
	{
		"[E] + [M1]",
		"Melee Attack",
	},
	{
		"[E] + [M2]",
		"Toggle Safety",
	},
	{
		"[X]",
		"Blindfire Menu",
	},
	{
		"[CTRL]",
		"Toggle Peek",
	},
}

hook.Add( "HUDShouldDraw", "TacRP_HUD2_HUDShouldDraw", function( name )
	if h2_enabled:GetBool() then
		if h2_enabled_health:GetBool() and hide_health[ name ] then return false end
		if h2_enabled_ammo:GetBool() and hide_ammo[ name ] then return false end
	end
end )

-- Get text size, setting the font beforehand
local function qtl( t, f )
	surface.SetFont( f )
	return surface.GetTextSize( t )
end

local function get_firemode_text( wep, fm )
	if fm == 2 then
		return "Full-auto"
	end
	if fm == 1 then
		return "Semi-auto"
	end
	if fm == 0 then
		return "Safety"
	end
	if fm <= 0 then
		return (-fm) .. "-burst"
	end
end

local function H2_DrawAmmo( ply, wep )
	local sw, sh = ScrW(), ScrH()
	local Hw, Hh = s(140), s(19)
	local Hx, Hy = sw - Hw - s(12), sh - Hh - s(12)
	C2_FullBox( Hx, Hy, Hw, Hh )

	C2_DrawText( wep:GetPrintName(), "TacRP_Myriad_Pro_12_Italic", Hx + s(4), Hy + s(3), color_white, TEXT_ALIGN_LEFT )

	if wep.ArcticTacRP then
		if wep:GetSafe() then
			C2_DrawText(
				"Safety",
				"TacRP_Myriad_Pro_10",
				Hx + Hw - s(4+1),
				Hy + Hh/2 + s(-3.5),
				color_white,
				TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER
			)
			C2_DrawText( "[E] + [RMB] " .. get_firemode_text( wep, wep:GetCurrentFiremode() ), "TacRP_Myriad_Pro_8", Hx + Hw - s(4+1), Hy + s(2+7), color_white, TEXT_ALIGN_RIGHT )
		else
			local fm_text = get_firemode_text( wep, wep:GetCurrentFiremode() )
			local different = wep:GetCurrentFiremode() ~= wep:GetNextFiremode()
			C2_DrawText(
				fm_text,
				"TacRP_Myriad_Pro_10",
				Hx + Hw - s(4+1),
				Hy + Hh/2 + (different and s(-3.5) or s(-0.5)),
				color_white,
				TEXT_ALIGN_RIGHT,
				TEXT_ALIGN_CENTER
			)
			if different then
				local fm_text = get_firemode_text( wep, wep:GetNextFiremode() )
				C2_DrawText(
					"[E] + [R] " .. fm_text,
					"TacRP_Myriad_Pro_8",
					Hx + Hw - s(4+1),
					Hy + s(2+7),
					color_white,
					TEXT_ALIGN_RIGHT
				)
			end
		end
	end

	local MC = wep:GetMaxClip1()
	local Buw, Buh = math.ceil(s(12)), math.ceil(s(12))
	local Sx, Sy = 0, 0
	local Bobber = 0
	local Pass = 0

	local aps = 1
	if wep.GetValue then
		aps = wep:GetValue("AmmoPerShot")
	end

	surface.SetMaterial( Material("tacrp/h2/bullet.png", "mips smooth"))
	local BANG = 14
	for i=1, MC do
		local Dx, Dy = Hx + Hw - s(4+4) + Sx, Hy - s(4+1) + Sy
		if i<= wep:Clip1() then
			surface.SetDrawColor( 32, 32, 32, 80 )
			surface.DrawTexturedRectRotated( Dx + 2, Dy + 1, Buw, Buh, BANG )
			surface.DrawTexturedRectRotated( Dx + 2, Dy + 2, Buw, Buh, BANG )
			local c1 = wep:Clip1()
			local bl
			local bc
			if wep.ArcticTacRP then
				bl = wep:GetCurrentFiremode()
				bc = wep:GetBurstCount()
				if bl < 0 then
					bl = -bl
				else
					bl = 1
					bc = 0
				end
			else
				bl = 1
				bc = 0
			end
			if ((i+aps) > wep:Clip1()) then
				surface.SetDrawColor( 255, 200, 60 )
			elseif i > (c1-(bl*aps)+((bc)*aps)) then
				surface.SetDrawColor( 255, 180, 120 )
			else
				surface.SetDrawColor( 255, 255, 255 )
			end
			surface.DrawTexturedRectRotated( Dx, Dy, Buw, Buh, BANG )
		else
			if wep:Clip1() == 0 and (CurTime()%0.4) > 0.3 then
				surface.SetDrawColor( 255, 0, 0, 127 )
			elseif (wep:Clip1() <= wep:GetMaxClip1()*0.5) and (CurTime()%0.4) < 0.1 then
				surface.SetDrawColor( 255, 0, 0, 127 )
			else
				surface.SetDrawColor( 32, 32, 32, 127 )
			end
			surface.DrawTexturedRectRotated( Dx, Dy, Buw, Buh, BANG )
		end
		Sx = Sx - math.ceil(s(4))

		Bobber = Bobber + 1
		if i ~= MC and Bobber >= 30 then
			Bobber = 0
			Pass = Pass + 1
			--Sx = (Pass%2 == 1) and math.ceil( s(-2) ) or 0
			Sx = ( s(-2*Pass) )
			Sy = Sy - math.ceil( s(4) )
		end
	end
	local ammo_text
	local has_ammotype = not (wep:GetPrimaryAmmoType() == -1)
	if wep:Clip1() == -1 then
		if wep:GetPrimaryAmmoType() == -1 then
			return
		else
			ammo_text = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
		end
	else
		if wep:GetPrimaryAmmoType() == -1 then
			ammo_text = wep:Clip1()
		else
			ammo_text = wep:Clip1() .. " / " .. ply:GetAmmoCount(wep:GetPrimaryAmmoType())
		end
	end
	C2_DrawText(
		ammo_text,
		"TacRP_Myriad_Pro_10",
		Hx + Hw + s(-2*Pass) - s(8),
		Hy + Sy - s(17),
		color_white,
		TEXT_ALIGN_RIGHT
	)
end

hook.Add("HUDPaint", "TacRP_HUD2", function()
	local sw, sh = ScrW(), ScrH()
	local ply = LocalPlayer()
	if !ply:IsValid() then return end
	local wep = ply:GetActiveWeapon()
	if !wep:IsValid() then return end

	if h2_enabled:GetBool() then
		C2_UpdateColors() -- TODO: EW WHY EVERY HUD DRAW!!

		if h2_enabled_health:GetBool() then
			local Hw, Hh = s(60), s(36)
			local Hx, Hy = s(12), sh - Hh - s(12)
			C2_FullBox( Hx, Hy, Hw, Hh )

			C2_DrawText( "HEALTH", "TacRP_Myriad_Pro_10", Hx + s(4), Hy + s(2), color_white, TEXT_ALIGN_LEFT )
			C2_DrawText( ply:Health(), "TacRP_Myriad_Pro_36", Hx + Hw - s(4), Hy + s(3), color_white, TEXT_ALIGN_RIGHT )
			
			do -- Health
				local Hw, Hh = s(60), s(36)
				local Hx, Hy = Hx + s(60) + s(12), sh - Hh - s(12)
				C2_FullBox( Hx, Hy, Hw, Hh )

				C2_DrawText( "ARMOR", "TacRP_Myriad_Pro_10", Hx + s(4), Hy + s(2), color_white, TEXT_ALIGN_LEFT )
				C2_DrawText( ply:Armor(), "TacRP_Myriad_Pro_36", Hx + Hw - s(4), Hy + s(3), color_white, TEXT_ALIGN_RIGHT )
			end
		end

		if h2_enabled_ammo:GetBool() then
			H2_DrawAmmo( ply, wep )
		end
	end

	if not wep.ArcticTacRP then
		return
	end

	if h2_enabled:GetBool() then
		local push_y = 0
		for i, hint_data in ipairs(hints) do
			i = i - 1
			local strin, strin2 = hint_data[1], hint_data[2]

			local Nx = s(12)
			local Ny = sh/2 + s(8 * i)

			C2_DrawText(
				strin,
				"TacRP_Myriad_Pro_8",
				Nx, Ny + s(2),
				color_white,
				TEXT_ALIGN_LEFT
			)
			C2_DrawText(
				strin2,
				"TacRP_Myriad_Pro_8",
				Nx + s(110), Ny + s(2),
				color_white,
				TEXT_ALIGN_RIGHT
			)
		end
	end

	do return end

	if wep:GetValue("BlindFireCamera") then
		wep:DoCornershot()
	end

	if wep:GetValue("Scope") or wep:GetValue("PrimaryMelee") then
		wep:DrawBreathBar(ScrW() * 0.5, ScrH() * 0.65, s(64), s(4))
	end

	wep:DrawGrenadeHUD()
	wep:DrawBlindFireHUD()

	wep:DoScope()
	wep:DrawCustomizeHUD()
	if wep:GetValue("TacticalDraw") and wep:GetTactical() then
		wep:GetValue("TacticalDraw")(wep)
	end
end)