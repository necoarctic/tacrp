-- TODO move convars to main convars file
local h2_enable = TacRP.ConVars["h2_enable"]
local h2_enable_health = TacRP.ConVars["h2_enable_health"]
local h2_enable_ammo = TacRP.ConVars["h2_enable_ammo"]
local s = TacRP.SS
local MARGIN_XS = TacRP.C2.MARGIN_XS
local MARGIN_S = TacRP.C2.MARGIN_S
local MARGIN_M = TacRP.C2.MARGIN_M
local MARGIN_L = TacRP.C2.MARGIN_L

local hide_health = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
}

local hide_ammo = {
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
}

hook.Add( "HUDShouldDraw", "TacRP_HUD2_HUDShouldDraw", function( name )
	if h2_enable:GetBool() then
		if h2_enable_health:GetBool() and hide_health[ name ] then return false end
		if h2_enable_ammo:GetBool() and hide_ammo[ name ] then return false end
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

local MATERIAL_BULLET = Material("tacrp/h2/bullet.png", "mips smooth")
local COLOR_NEXT = Color( 255, 200, 60 )
local COLOR_NEXTBURST = Color( 255, 180, 120 )
local COLOR_REST = Color( 255, 255, 255 )
local COLOR_LOWAMMO = Color( 255, 0, 0, 127 )
local COLOR_EMPTY = Color( 32, 32, 32, 127 )
local COLOR_SHADOW = Color( 32, 32, 32, 127 )

local NEWLINE_AT = 30
local LOW_AMMO_PERCENTAGE = 0.34

local function H2_DrawAmmo( ply, wep )
	local sw, sh = ScrW(), ScrH()
	local panel_w = s(140)
	local panel_h = s(20)
	local panel_x = sw - panel_w - s(MARGIN_L)
	local panel_y = sh - panel_h - s(MARGIN_L)
	local tacrp = wep.ArcticTacRP
	C2_FullBox( panel_x, panel_y, panel_w, panel_h )

	C2_DrawText(
		wep.AbbrevName or wep:GetPrintName(),
		"TacRP_STD_12I",
		panel_x + s(MARGIN_S),
		panel_y + panel_h/2,
		color_white,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER
	)

	-- firemode
	if tacrp and not wep:GetValue("PrimaryMelee") and not wep:GetValue("PrimaryGrenade") then
		local safety = wep:GetSafe()
		local fm_text = safety and "Safety" or get_firemode_text( wep, wep:GetCurrentFiremode() )
		local different = safety or (wep:GetCurrentFiremode() ~= wep:GetNextFiremode())
		C2_DrawText(
			fm_text,
			"TacRP_STD_10",
			panel_x + panel_w - s(MARGIN_S),
			panel_y + panel_h/2 - s(different and 4 or 0),
			color_white,
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_CENTER
		)
		if different then
			local fm_text = safety and ("[E] + [RMB] " .. get_firemode_text( wep, wep:GetCurrentFiremode() )) or ("[E] + [R] " .. get_firemode_text( wep, wep:GetNextFiremode() ))
			C2_DrawText(
				fm_text,
				"TacRP_STD_8",
				panel_x + panel_w - s(MARGIN_S),
				panel_y + panel_h/2 + s(4),
				color_white,
				TEXT_ALIGN_RIGHT,
				TEXT_ALIGN_CENTER
			)
		end
	end

	local ammo_per_shot = 1
	if wep.GetValue then
		ammo_per_shot = wep:GetValue("AmmoPerShot")
	end

	local t = CurTime()
	local flash_empty = t % 0.3 < 0.25
	local flash_lowammo = t % 0.5 < 0.1
	local o_x = panel_x + panel_w
	local o_y = panel_y
	local final_x = 0
	local final_y = 0

	surface.SetMaterial( MATERIAL_BULLET )
	-- ammo counter bullets
	for gun=1, (tacrp and wep.DualAkimbo) and 2 or 1 do
		local mag_max = wep:GetMaxClip1()
		local mag_loaded = wep:Clip1()
		if gun == 2 then
			mag_max = wep:GetMaxClip2()
			mag_loaded = wep:Clip2()
		end
		local burst_length = 1
		local burst_count = 0
		if tacrp then
			burst_count = gun == 2 and wep:GetBurstCount2() or wep:GetBurstCount()
			local fm = wep:GetCurrentFiremode()
			if fm < 0 then
				burst_length = -fm
			end
			if burst_count == burst_length then
				burst_count = 0
			end
		end

		-- theoretically customizable
		local rotation = 14
		local im_w, im_h = s(12), s(12)
		local line_max = 30
		local bgap_x = s(4)
		local bgap_newlinex = s(2)
		local bgap_line = s(4)

		if mag_max >= 50 then
			im_w, im_h = s(6), s(12)
			line_max = 25
			bgap_x = s(4)
			bgap_newlinex = s(1)
			bgap_line = s(2)
			rotation = 90
		end

		for bullet = 1, mag_max do
			local i = bullet - 1
			local b_x = o_x - s(12) - final_x
			local b_y = o_y - s(4) - final_y

			local linecount = math.floor(i / line_max) -- starts from 0
			b_x = b_x - (bgap_x * (i % line_max)) - (bgap_newlinex * linecount)
			b_y = b_y - (bgap_line * linecount)
			
			if bullet <= mag_loaded then -- this round is loaded
				surface.SetDrawColor( COLOR_SHADOW )
				surface.DrawTexturedRectRotated( b_x + 2, b_y + 1, im_w, im_h, rotation )
				surface.DrawTexturedRectRotated( b_x + 2, b_y + 2, im_w, im_h, rotation )
				
				if ( bullet + ammo_per_shot > mag_loaded ) then
					surface.SetDrawColor( COLOR_NEXT )
				elseif bullet > ( mag_loaded - ( burst_length * ammo_per_shot ) + ( burst_count * ammo_per_shot ) ) then
					surface.SetDrawColor( COLOR_NEXTBURST )
				else
					surface.SetDrawColor( COLOR_REST )
				end
				surface.DrawTexturedRectRotated( b_x, b_y, im_w, im_h, rotation )
			else
				if mag_loaded == 0 then
					surface.SetDrawColor( flash_empty and COLOR_LOWAMMO or COLOR_EMPTY )
				else
					surface.SetDrawColor( (mag_max * LOW_AMMO_PERCENTAGE >= mag_loaded and flash_lowammo) and COLOR_LOWAMMO or COLOR_EMPTY )
				end
				surface.DrawTexturedRectRotated( b_x, b_y, im_w, im_h, rotation )
			end
			-- surface.SetDrawColor( 255, 0, 0 )
			-- surface.DrawRect( b_x-1, b_y-1, 2, 2 )
		end
		local lc = math.floor((mag_max-1) / line_max) + 1
		final_x = final_x + (bgap_newlinex * lc)
		final_y = final_y + (bgap_line * lc)
	end

	-- ammo text
	local ammo_type = wep:GetPrimaryAmmoType()
	local has_ammotype = ammo_type ~= -1
	local ammo_count = ply:GetAmmoCount(ammo_type)
	local ammo_text
	local clip = tostring( wep:Clip1() )
	if wep:Clip2() ~= -1 then
		clip = clip .. " + " .. tostring( wep:Clip2() )
	end

	if tacrp and wep:GetInfiniteAmmo() then
		ammo_count = "∞"
	end
	
	if wep:Clip1() == -1 then
		if not has_ammotype then
			return panel_x, panel_y, panel_w, panel_h
		else
			ammo_text = ammo_count
		end
	else
		if not has_ammotype then
			ammo_text = clip
		else
			ammo_text = clip .. " / " .. ammo_count
		end
	end
	C2_DrawText(
		ammo_text,
		"TacRP_STD_10",
		panel_x + panel_w - s(10) - final_x,
		panel_y - s(2) - final_y,
		color_white,
		TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
	)

	return panel_x, panel_y, panel_w, panel_h
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

local function get_txt_from_hintbind( str )
	local keys = string.Explode("/", str, false)
	local total = ""
	for i, v in ipairs(keys) do
		if i ~= 1 then
			total = total .. " + "
		end
		total = total .. "[" .. TacRP.GetBindKey(v) .. "]"
	end
	return total
end

hook.Add("HUDPaint", "TacRP_HUD2", function()
	local sw, sh = ScrW(), ScrH()
	local ply = LocalPlayer()
	if !ply:IsValid() then return end
	local wep = ply:GetActiveWeapon()
	if !wep:IsValid() then wep = false end
	local tacrp = wep and wep.ArcticTacRP

	if h2_enable:GetBool() then
		if h2_enable_health:GetBool() then
			local Hw = s(56)
			local Hh = s(32)
			local Hx = s(MARGIN_L)
			local Hy = sh - Hh - s(MARGIN_L)
			C2_FullBox( Hx, Hy, Hw, Hh )

			C2_DrawText(
				"HEALTH",
				"TacRP_STD_8",
				Hx + s(4),
				Hy + s(2),
				color_white,
				TEXT_ALIGN_LEFT
			)
			C2_DrawText(
				ply:Health(),
				"TacRP_STD_32",
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
				Hx = Hx + Hw + s(MARGIN_M)
				Hy = sh - Hh - s(MARGIN_L)
				local Hw = s(56)
				local Hh = s(32)
				C2_FullBox( Hx, Hy, Hw, Hh )

				C2_DrawText(
					"ARMOR",
					"TacRP_STD_8",
					Hx + s(4),
					Hy + s(2),
					color_white,
					TEXT_ALIGN_LEFT
				)
				C2_DrawText(
					ply:Armor(),
					"TacRP_STD_32",
					Hx + Hw - s(4),
					Hy + s(3),
					color_white,
					TEXT_ALIGN_RIGHT
				)
			end
		end

		local Hx, Hy, Hw, Hh = sw, sh, 0, 0
		if wep and h2_enable_ammo:GetBool() then
			Hx, Hy, Hw, Hh = H2_DrawAmmo( ply, wep )
		end

		-- grenades
		if wep and tacrp then
			local def = wep:GetGrenade()
			local qty
			if def.Singleton then
				qty = ply:HasWeapon(def.GrenadeWep) and 1 or 0
			elseif !TacRP.IsGrenadeInfiniteAmmo(def.Index) then
				qty = ply:GetAmmoCount(def.Ammo)
			end
			local panel_w, panel_h = s(56), s(20)
			local panel_x = Hx - panel_w - s(MARGIN_S)--sw/2 - panel_w/2
			local panel_y = sh - panel_h - s(MARGIN_L)

			local icon_size = panel_h
			local icon_x = panel_x + panel_w - icon_size
			local icon_y = panel_y

			C2_FullBox( panel_x, panel_y, panel_w, panel_h )

			C2_DrawText(
				def.PrintName,
				"TacRP_STD_10I",
				panel_x + s(MARGIN_S),
				panel_y + panel_h/2 - s(qty and 4 or 0),
				color_white,
				TEXT_ALIGN_LEFT,
				TEXT_ALIGN_CENTER
			)
			if qty then
				C2_DrawText(
					"×" .. qty,
					"TacRP_STD_8",
					panel_x + s(MARGIN_S),
					panel_y + panel_h/2 + s(4),
					color_white,
					TEXT_ALIGN_LEFT,
					TEXT_ALIGN_CENTER
				)
			end

			surface.SetMaterial( def.Icon )
			surface.SetDrawColor( COLOR_SHADOW )

			surface.DrawTexturedRect( icon_x + 2, icon_y + 1, icon_size, icon_size )
			surface.DrawTexturedRect( icon_x + 2, icon_y + 2, icon_size, icon_size )
			surface.SetDrawColor( color_white )
			surface.DrawTexturedRect( icon_x, icon_y, icon_size, icon_size )
		end

		-- halo style grenades
		if wep and tacrp then
			local origin_x = sw - s(MARGIN_L)
			local origin_y = s(MARGIN_L)
			local panel_y = origin_y
			local shift_x = 0
			local panel_w, panel_h = s(23), s(16)

			for index=TacRP.QuickNades_Count, 1, -1 do
				local grenade_class = TacRP.QuickNades_Index[index]
				local selected = wep:GetGrenadeIndex() == index

				if not selected and not wep:CheckGrenade(index, checkammo) then
					continue
				end
				local def = TacRP.QuickNades[grenade_class]

				local qty
				if def.Singleton then
					qty = ply:HasWeapon(def.GrenadeWep) and 1 or 0
				elseif !TacRP.IsGrenadeInfiniteAmmo(def.Index) then
					qty = ply:GetAmmoCount(def.Ammo)
				end
				if not selected and qty and qty == 0 then
					continue
				end
				shift_x = shift_x - panel_w
				
				local panel_x = origin_x + shift_x
				
				surface.SetAlphaMultiplier( (qty and qty==0) and 0.5 or 1 )
				if selected then
					C2_FullBox( panel_x, panel_y, panel_w, panel_h )
				end
				
				surface.SetMaterial( def.Icon )
				surface.SetDrawColor( COLOR_SHADOW )
				surface.DrawTexturedRect( panel_x+2, panel_y+1, panel_h, panel_h )
				surface.DrawTexturedRect( panel_x+2, panel_y+2, panel_h, panel_h )
				surface.SetDrawColor( color_white )
				surface.DrawTexturedRect( panel_x, panel_y, panel_h, panel_h )

				if qty and qty > 99 then
					qty = "99+"
				end
				C2_DrawText(
					qty or "∞",
					"TacRP_STD_10",
					panel_x + panel_w - s(3),
					-- panel_x + (panel_h) + (panel_w-panel_h)/2 - s(2),
					panel_y + panel_h/2,
					color_white,
					-- TEXT_ALIGN_CENTER,
					TEXT_ALIGN_RIGHT,
					TEXT_ALIGN_CENTER
				)
				shift_x = shift_x - s(1)
			end
			surface.SetAlphaMultiplier( 1 )
		end
	end

	if not tacrp then
		return
	end

	-- hints
	if wep and h2_enable:GetBool() and TacRP.ConVars["hints"]:GetBool() then
		local push_y = 0
		local caps = wep:GetHintCapabilities()

		push_y = push_y - s(4 * table.Count(caps))

		for control, data in SortedPairsByMemberValue(caps, "so") do
			local x = s(MARGIN_L)
			local y = sh/2

			C2_DrawText(
				get_txt_from_hintbind(control),
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

	if not wep then return end

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