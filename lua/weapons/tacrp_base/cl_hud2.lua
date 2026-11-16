-- TODO move convars to main convars file
local h2_enabled = CreateClientConVar( "tacrp_h2_enable", 1, true, false )
local h2_enabled_health = CreateClientConVar( "tacrp_h2_enable_health", 1, true, false )
local h2_enabled_ammo = CreateClientConVar( "tacrp_h2_enable_ammo", 1, true, false )
local s = TacRP.SS
local MARGIN_XS = TacRP.C2.MARGIN_XS
local MARGIN_S = TacRP.C2.MARGIN_S
local MARGIN_M = TacRP.C2.MARGIN_M
local MARGIN_L = TacRP.C2.MARGIN_L
local MARGIN_XL = TacRP.C2.MARGIN_XL

local hide_health = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
}

local hide_ammo = {
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
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

local ROTATION = 14
local MATERIAL_BULLET = Material("tacrp/h2/bullet.png", "mips smooth")
local COLOR_NEXT = Color( 255, 200, 60 )
local COLOR_NEXTBURST = Color( 255, 180, 120 )
local COLOR_REST = Color( 255, 255, 255 )
local COLOR_LOWAMMO = Color( 255, 0, 0, 127 )
local COLOR_EMPTY = Color( 32, 32, 32, 127 )
local COLOR_SHADOW = Color( 32, 32, 32, 80 )

local NEWLINE_AT = 30
local LOW_AMMO_PERCENTAGE = 0.34

local function H2_DrawAmmo( ply, wep )
	local sw, sh = ScrW(), ScrH()
	local Hw = s(140)
	local Hh = s(19)
	local Hx = sw - Hw - s(MARGIN_XL)
	local Hy = sh - Hh - s(MARGIN_XL)
	local tacrp = wep.ArcticTacRP
	C2_FullBox( Hx, Hy, Hw, Hh )

	C2_DrawText( wep:GetPrintName(), "TacRP_STD_12I", Hx + s(4), Hy + s(3), color_white, TEXT_ALIGN_LEFT )

	-- firemode
	if tacrp then
		if wep:GetSafe() then
			C2_DrawText(
				"Safety",
				"TacRP_STD_10",
				Hx + Hw - s(4+1),
				Hy + Hh/2 + s(-3.5),
				color_white,
				TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER
			)
			C2_DrawText( "[E] + [RMB] " .. get_firemode_text( wep, wep:GetCurrentFiremode() ), "TacRP_STD_8", Hx + Hw - s(4+1), Hy + s(2+7), color_white, TEXT_ALIGN_RIGHT )
		else
			local fm_text = get_firemode_text( wep, wep:GetCurrentFiremode() )
			local different = wep:GetCurrentFiremode() ~= wep:GetNextFiremode()
			C2_DrawText(
				fm_text,
				"TacRP_STD_10",
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
					"TacRP_STD_8",
					Hx + Hw - s(4+1),
					Hy + s(2+7),
					color_white,
					TEXT_ALIGN_RIGHT
				)
			end
		end
	end

	local IW, IH = math.ceil(s(12)), math.ceil(s(12))
	local shift_x, shift_y = 0, 0
	local newline_counter = 0
	local linecount = 0

	local aps = 1
	if wep.GetValue then
		aps = wep:GetValue("AmmoPerShot")
	end

	surface.SetMaterial( MATERIAL_BULLET )
	for gun=1, (tacrp and wep.DualAkimbo) and 2 or 1 do
		local max_clip = wep:GetMaxClip1()
		local clip = wep:Clip1()
		if gun == 2 then
			max_clip = wep:GetMaxClip2()
			clip = wep:Clip2()
			-- shift and make new line
			newline_counter = 0
			linecount = linecount + 1
			shift_x = math.ceil( s( -2 * linecount ) )
			shift_y = shift_y - math.ceil( s(4) )
		end
		local burst_length = 1
		local burst_count = 0

		if tacrp then
			burst_count = gun == 2 and wep:GetBurstCount2() or wep:GetBurstCount()
			local fm = wep:GetCurrentFiremode()
			if fm < 0 then
				burst_length = -fm
			end
		end

		for i=1, max_clip do
			local Dx = Hx + Hw - s(4+4) + shift_x
			local Dy = Hy - s(4+1) + shift_y

			shift_x = shift_x - math.ceil(s(4))
			newline_counter = newline_counter + 1
			if i ~= max_clip and newline_counter >= NEWLINE_AT then
				newline_counter = 0
				linecount = linecount + 1
				shift_x = math.ceil( s( -2 * linecount ) )
				shift_y = shift_y - math.ceil( s(4) )
			end

			if i<= clip then
				surface.SetDrawColor( COLOR_SHADOW )
				surface.DrawTexturedRectRotated( Dx + 2, Dy + 1, IW, IH, ROTATION )
				surface.DrawTexturedRectRotated( Dx + 2, Dy + 2, IW, IH, ROTATION )
				
				if ( i + aps > clip ) then
					surface.SetDrawColor( COLOR_NEXT )
				elseif i > ( clip - ( burst_length * aps ) + ( burst_count * aps ) ) then
					surface.SetDrawColor( COLOR_NEXTBURST )
				else
					surface.SetDrawColor( COLOR_REST )
				end
				surface.DrawTexturedRectRotated( Dx, Dy, IW, IH, ROTATION )
			else
				if clip == 0 then
					if CurTime() % 0.25 < 0.2 then
						surface.SetDrawColor( COLOR_LOWAMMO )
					else
						surface.SetDrawColor( COLOR_EMPTY )
					end
				elseif max_clip * LOW_AMMO_PERCENTAGE >= clip and CurTime() % 0.5 < 0.1 then
					surface.SetDrawColor( COLOR_LOWAMMO )
				else
					surface.SetDrawColor( COLOR_EMPTY )
				end
				surface.DrawTexturedRectRotated( Dx, Dy, IW, IH, ROTATION )
			end
		end
	end
	local ammo_type = wep:GetPrimaryAmmoType()
	local ammo_count = ply:GetAmmoCount(ammo_type)
	local ammo_text
	local has_ammotype = ammo_type ~= -1
	local clip = tostring( wep:Clip1() )
	if wep:Clip2() ~= -1 then
		clip = clip .. " + " .. tostring( wep:Clip2() )
	end
	if wep:Clip1() == -1 then
		if not has_ammotype then
			return
		else
			ammo_text = ammo_count
		end
		C2_DrawText(
			ammo_text,
			"TacRP_STD_10",
			Hx + Hw + s(-2*-1) - s(8),
			Hy - s(12),
			color_white,
			TEXT_ALIGN_RIGHT
		)
	else
		if not has_ammotype then
			ammo_text = clip
		else
			ammo_text = clip .. " / " .. ammo_count
		end
		C2_DrawText(
			ammo_text,
			"TacRP_STD_10",
			Hx + Hw + s(-2*linecount) - s(8),
			Hy + shift_y - s(17),
			color_white,
			TEXT_ALIGN_RIGHT
		)
	end
end

local lasthealtime = -math.huge
local lastdmgtime = -math.huge
local faceindex = 0
local lasthp = 0
local lastarmor = 0

local FACES_JUSTHURT = {
	"#> <",
	"(>Д<)",
	"(@_@)",
	"(ー;ー)",
	"(・ロ・)",
	"゛> <",
	"(>_メ)",
	"(*_*)",
	"゜・+_+"
}

local FACES_JUSTHEALED1 = {
	"(^ω~)",
	"(>ω^)",
	"(>3^)",
	"(^.~)",
	"(･ω<)",
	"(^.~)",
	"♥(ツ)♥"
}

local FACES_JUSTHEALED2 = {
	"(^w^)",
	"('3')",
	"(♡3♡)",
	"(ПωП)",
	"(>3<)",
	"('w')",
	"TYSM!"
}

local function get_face( ply )
	local face = "-_-"
	local ct = CurTime()
	local hp = ply:Health()
	local armor = ply:Armor()
	local hp_frac = hp / ply:GetMaxHealth()

	if lastdmgtime + 1 > ct then
		face = FACES_JUSTHURT[faceindex]
	elseif lasthealtime + 1 > ct then
		if hp_frac >= 1 then
			face = FACES_JUSTHEALED1[faceindex]

			if lasthp < ply:Health() then
				lasthealtime = ct

				faceindex = math.random(1, #FACES_JUSTHEALED1)
			end
		else
			face = FACES_JUSTHEALED2[faceindex]
		end
	else
		if math.sin(ct * 3) > 0.98 then
			if hp_frac < 0.1 then
				face = "(>_<)"
			elseif hp_frac < 0.25 then
				face = "(>_<)"
			elseif hp_frac < 0.5 then
				face = "(>_<)"
			elseif hp_frac < 0.95 then
				face = "(-_-)"
			else
				face = "(-_-)"
			end
		else
			if hp_frac < 0.1 then
				face = "(×_×)"
			elseif hp_frac < 0.25 then
				face = "(;_;)"
			elseif hp_frac < 0.5 then
				face = "(゜_゜)"
			elseif hp_frac < 0.95 then
				face = "('_')"
			else
				face = "(^_^)"
			end
		end

		if lasthp > hp then
			lastdmgtime = ct
			faceindex = math.random(1, #FACES_JUSTHURT)
		elseif lasthp < hp or lastarmor < armor then
			lasthealtime = ct
			faceindex = math.random(1, #FACES_JUSTHEALED1)
		end
	end

	if hp_frac > 2.5 then
		if math.sin(ct * 3) > 0.96 then
			face = "(UwU)"
		else
			face = "(OwO)"
		end
	end

	lasthp = hp
	lastarmor = armor
	return face
end

hook.Add("HUDPaint", "TacRP_HUD2", function()
	local sw, sh = ScrW(), ScrH()
	local ply = LocalPlayer()
	if !ply:IsValid() then return end
	local wep = ply:GetActiveWeapon()
	if !wep:IsValid() then return end
	local tacrp = wep.ArcticTacRP

	if h2_enabled:GetBool() then
		if h2_enabled_health:GetBool() then
			local Hw = s(60)
			local Hh = s(36)
			local Hx = s(MARGIN_XL)
			local Hy = sh - Hh - s(MARGIN_XL)
			C2_FullBox( Hx, Hy, Hw, Hh )

			C2_DrawText(
				"HEALTH",
				"TacRP_STD_10",
				Hx + s(4),
				Hy + s(2),
				color_white,
				TEXT_ALIGN_LEFT
			)
			C2_DrawText(
				ply:Health(),
				"TacRP_STD_36",
				Hx + Hw - s(4),
				Hy + s(3),
				color_white,
				TEXT_ALIGN_RIGHT
			)

			do -- Kaomoji
				local Hw = s(4+(8*5)+4)
				local Hh = s(2+12+2)
				local Hx = Hx
				local Hy = Hy - Hh - s(MARGIN_S)
				C2_FullBox( Hx, Hy, Hw, Hh )

				local face = get_face(ply)
				for i=1, utf8.len(face) do
					local char = utf8.GetChar(face, i)
					C2_DrawText(
						char,
						"TacRP_LCD_12",
						Hx + s(4 + ((i-1) * 8)),
						Hy + s(1),
						color_white
					)
				end
			end
			
			if ply:Armor() > 0 then -- Armor
				Hx = Hx + Hw + s(MARGIN_XL)
				Hy = sh - Hh - s(MARGIN_XL)
				local Hw = s(60)
				local Hh = s(36)
				C2_FullBox( Hx, Hy, Hw, Hh )

				C2_DrawText(
					"ARMOR",
					"TacRP_STD_10",
					Hx + s(4),
					Hy + s(2),
					color_white,
					TEXT_ALIGN_LEFT
				)
				C2_DrawText(
					ply:Armor(),
					"TacRP_STD_36",
					Hx + Hw - s(4),
					Hy + s(3),
					color_white,
					TEXT_ALIGN_RIGHT
				)
			end
		end

		if h2_enabled_ammo:GetBool() then
			H2_DrawAmmo( ply, wep )
		end
	end

	if not tacrp then
		return
	end

	if h2_enabled:GetBool() then
		local push_y = 0
		local caps = wep:GetHintCapabilities()

		for i, v in pairs(caps) do
			push_y = push_y - s(4)
		end

		for control, data in SortedPairsByMemberValue(caps, "so") do
			local x = s(MARGIN_XL)
			local y = sh/2

			local keys = string.Explode("/", control, false)
			local total = ""
			for i, v in ipairs(keys) do
				if i ~= 1 then
					total = total .. " + "
				end
				total = total .. "[" .. TacRP.GetBindKey(v) .. "]"
			end
			C2_DrawText(
				total,
				"TacRP_STD_8",
				x,
				y + s(2) + push_y,
				color_white,
				TEXT_ALIGN_LEFT,
				TEXT_ALIGN_CENTER
			)
			
			C2_DrawText(
				TacRP:TryTranslate(data.str),
				"TacRP_STD_8",
				x + s(110),
				y + s(2) + push_y,
				color_white,
				TEXT_ALIGN_RIGHT,
				TEXT_ALIGN_CENTER
			)
			push_y = push_y + s(8)
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