local s = TacRP.SS
local MARGIN_XS = TacRP.C2.MARGIN_XS
local MARGIN_S = TacRP.C2.MARGIN_S
local MARGIN_M = TacRP.C2.MARGIN_M
local MARGIN_L = TacRP.C2.MARGIN_L
local MARGIN_XL = TacRP.C2.MARGIN_XL
local COLOR_OUTLINE = color_white

local PANEL = {}
function PANEL:Paint( w, h )
	local wep = self.Weapon
	C2_FullBox( 0, 0, w, h )
	
	local raw_dmg_max = wep:GetValue("Damage_Max")
	local raw_dmg_min = wep:GetValue("Damage_Min")
	local exp = wep:GetValue("ExplosiveDamage")
	local dmult = wep:GetConfigDamageMultiplier()

	local dmg_max = (raw_dmg_max + exp) * dmult
	local dmg_min = (raw_dmg_min + exp) * dmult
	local range_min, range_max = wep:GetMinMaxRange()

	local phys_to_pixel = range_max/w
	local panel_range = 10000-- * phys_to_pixel
	phys_to_pixel = panel_range/w

	local tall = h * .75
	local y = h - tall

	local p1_x = w * (range_min / panel_range)
	local p2_x = w * (range_max / panel_range)

	-- lines
	local max_y = h - math.min(raw_dmg_max/100, 1) * tall
	local min_y = h - math.min(raw_dmg_min/100, 1) * tall
	surface.SetDrawColor(255, 255, 255)
	for i = 0, 1 do
		surface.DrawLine( 0, max_y + i, p1_x, max_y + i )
		surface.DrawLine( p1_x, max_y + i, p2_x, min_y + i )
		surface.DrawLine( p2_x, min_y + i, w, min_y + i )
	end

	local txt_dmg_max = math.floor(dmg_max) .. TacRP:GetPhrase("unit.damage")
	local txt_dmg_min = math.floor(dmg_min) .. TacRP:GetPhrase("unit.damage")
	local pellets = wep:GetValue("Num")
	if pellets > 1 then
		txt_dmg_max = dmg_max * pellets .. "-" .. txt_dmg_max
		txt_dmg_min = dmg_min * pellets .. "-" .. txt_dmg_min
	end

	surface.SetDrawColor( COLOR_OUTLINE )
	C2_Gradient_Down( p1_x, y, 1, tall )
	C2_Gradient_Down( p2_x, y, 1, tall )

	surface.SetFont("TacRP_STD_10")
	local txt_range_max = wep:RangeUnitize(range_max)
	local txt_range_min = wep:RangeUnitize(range_min)
	local width_dmg_max = surface.GetTextSize(txt_dmg_max)
	local width_dmg_min = surface.GetTextSize(txt_dmg_min)
	local width_range_max = surface.GetTextSize(txt_range_max)
	local width_range_min = surface.GetTextSize(txt_range_min)

	C2_DrawText(
		txt_dmg_max,
		"TacRP_STD_10",
		math.max( s(MARGIN_S), p1_x - width_dmg_max/2 ),
		s(4),
		color_white
	)
	
	C2_DrawText(
		txt_range_min,
		"TacRP_STD_10",
		math.max( s(MARGIN_S), p1_x - width_range_min/2 ),
		s(4+10),
		color_white
	)

	C2_DrawText(
		txt_dmg_min,
		"TacRP_STD_10",
		math.min( w - width_dmg_min - s(MARGIN_S), p2_x - width_dmg_min/2 ),
		s(4),
		color_white
	)

	C2_DrawText(
		txt_range_max,
		"TacRP_STD_10",
		math.min( w - width_range_max - s(MARGIN_S), p2_x - width_range_max/2 ),
		s(4+10),
		color_white
	)

	for i=0, panel_range, (TacRP.ConVars["metricunit"]:GetBool() and 25 / TacRP.HUToM or 1000) do
		if i == 0 then continue end
		-- surface.DrawRect( i / phys_to_pixel, h-2, 1, 1 )
		local x = i/phys_to_pixel
		surface.SetDrawColor( COLOR_OUTLINE )
		C2_Gradient_Down( x, h - s(4), s(4), 1 )
		C2_DrawText(
			wep:RangeUnitize(i),
			"TacRP_STD_6",
			x, h - s(1),
			color_white,
			TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		)
	end

	return true
end

vgui.Register("C2_DamageRange", PANEL, "Panel")