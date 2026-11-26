local s = TacRP.SS
local MARGIN_XS = TacRP.C2.MARGIN_XS
local MARGIN_S = TacRP.C2.MARGIN_S
local MARGIN_M = TacRP.C2.MARGIN_M
local MARGIN_L = TacRP.C2.MARGIN_L
local COLOR_OUTLINE = TacRP.C2.COLOR_OUTLINE

local PANEL = {}
function PANEL:Paint( w, h )
	local wep = self.Weapon
	local metric = TacRP.ConVars["metricunit"]:GetBool()
	C2_FullBox( 0, 0, w, h )
	
	local raw_dmg_max = wep:GetValue("Damage_Max")
	local raw_dmg_min = wep:GetValue("Damage_Min")
	local exp = wep:GetValue("ExplosiveDamage")
	local pellets = wep:GetValue("Num")
	local dmult = wep:GetConfigDamageMultiplier()

	local dmg_max = (raw_dmg_max + exp) * dmult
	local dmg_min = (raw_dmg_min + exp) * dmult
	local range_min, range_max = wep:GetMinMaxRange()

	local _, base_range_max = wep:GetMinMaxRange(true)
	local greatest_range_max = math.max( range_max, base_range_max )

	-- initial range
	local panel_range = 2000
	local phys_to_pixel = panel_range/w

	-- multiply it to fit this weapon's max range
	local density = math.ceil(greatest_range_max / panel_range)
	panel_range = panel_range * density
	phys_to_pixel = panel_range/w

	-- fit a bit more meters to the right to keep it comfy
	panel_range = panel_range + (s(32) * phys_to_pixel)
	local multiple = metric and (50 / TacRP.HUToM) or 1000
	panel_range = math.ceil(panel_range / multiple + 0.5) * multiple
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

	local txt_unit_damage = TacRP.GetPhrase("unit.damage")
	local txt_dmg_max = math.floor(dmg_max) .. txt_unit_damage
	local txt_dmg_min = math.floor(dmg_min) .. txt_unit_damage
	if pellets > 1 then
		txt_dmg_max = dmg_max * pellets .. "-" .. txt_dmg_max
		txt_dmg_min = dmg_min * pellets .. "-" .. txt_dmg_min
	end

	surface.SetDrawColor( COLOR_OUTLINE )
	C2_Gradient_Down( p1_x, y, 1, tall )
	C2_Gradient_Down( p2_x, y, 1, tall )

	surface.SetFont("TacRP_STD_8")
	local txt_range_max = wep:RangeUnitize(range_max)
	local txt_range_min = wep:RangeUnitize(range_min)
	local width_dmg_max = surface.GetTextSize(txt_dmg_max)
	local width_dmg_min = surface.GetTextSize(txt_dmg_min)
	local width_range_max = surface.GetTextSize(txt_range_max)
	local width_range_min = surface.GetTextSize(txt_range_min)

	C2_DrawText(
		txt_dmg_max,
		"TacRP_STD_8",
		math.max( s(MARGIN_S), p1_x - width_dmg_max/2 ),
		s(4),
		color_white
	)
	
	C2_DrawText(
		txt_range_min,
		"TacRP_STD_8",
		math.max( s(MARGIN_S), p1_x - width_range_min/2 ),
		s(4+8),
		color_white
	)

	C2_DrawText(
		txt_dmg_min,
		"TacRP_STD_8",
		math.min( w - width_dmg_min - s(MARGIN_S), p2_x - width_dmg_min/2 ),
		s(4),
		color_white
	)

	C2_DrawText(
		txt_range_max,
		"TacRP_STD_8",
		math.min( w - width_range_max - s(MARGIN_S), p2_x - width_range_max/2 ),
		s(4+8),
		color_white
	)

	local height = math.ceil(s(2))
	local skip = (metric and 25 / TacRP.HUToM or 1000)
	if density > 2 then
		skip = skip * 2
	end
	for i=0, panel_range, skip do
		if i == 0 then continue end
		local x = i/phys_to_pixel
		if x > w - s(2+16+2) then continue end
		surface.SetDrawColor( COLOR_OUTLINE )
		C2_Gradient_Down( x - s(.5), h - height, s(1), height )
		C2_DrawText(
			wep:RangeUnitize(i),
			"TacRP_STD_6",
			x, h - s(1),
			color_white,
			TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		)
	end

	-- show panel range
	C2_DrawText(
		wep:RangeUnitize(panel_range),
		"TacRP_STD_6",
		w - s(1),
		h - s(1),
		color_white,
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_BOTTOM
	)

	local range = self.LastRange or range_min
	local hovered = self:IsHovered()
	if hovered then
		range = (self:LocalCursorPos()/w) * panel_range
		self.LastRange = range
	end
	if self.DamageDoll then
		self.DamageDoll.Range = range
	end

	if not hovered and range <= range_min then return true end

	local range_x = range / phys_to_pixel
	C2_Gradient_Down( range_x - s(1), y+tall/2, s(2), tall/2 )

	local txt_dmg
	if pellets > 1 then
		txt_dmg = wep:GetDamageAtRange(range) * pellets .. "-" .. wep:GetDamageAtRange(range) .. TacRP.TryTranslate("unit.damage")
	else
		txt_dmg = wep:GetDamageAtRange(range) .. " " .. TacRP.TryTranslate("unit.damage")
	end
	local txt_range = wep:RangeUnitize(range)
	surface.SetFont("TacRP_STD_6")
	local width_txt_dmg = surface.GetTextSize(txt_dmg)
	local width_txt_range = surface.GetTextSize(txt_range)

	C2_DrawText(
		txt_dmg,
		"TacRP_STD_6",
		math.Clamp( range_x - width_txt_dmg/2, s(4), w - width_txt_dmg - s(4) ), y+tall/2 - s(6),
		color_white,
		TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
	)
	C2_DrawText(
		txt_range,
		"TacRP_STD_6",
		math.Clamp( range_x - width_txt_range/2, s(4), w - width_txt_range - s(4) ), y+tall/2,
		color_white,
		TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
	)
	return true
end

vgui.Register("C2_DamageRange", PANEL, "Panel")