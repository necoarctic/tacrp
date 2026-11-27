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

	local pellets = wep:GetValue("Num")

	local range_min, range_max = wep:GetMinMaxRange()
	local base_range_min, base_range_max = wep:GetMinMaxRange(true)
	local greatest_range_max = math.max( range_max, base_range_max )

	-- initial range
	local panel_range = 2000
	local phys_to_pixel = panel_range/w

	-- multiply it to fit this weapon's max range
	local density = math.ceil(greatest_range_max / panel_range)
	panel_range = panel_range * density
	phys_to_pixel = panel_range/w

	-- fit a bit more meters to the right to keep it comfy
	panel_range = panel_range + (s(16) * phys_to_pixel)
	local multiple = metric and (25 / TacRP.HUToM) or 1000
	panel_range = math.ceil(panel_range / multiple) * multiple
	phys_to_pixel = panel_range/w

	local tall = h * .75
	local y = h - tall
	local dmult = wep:GetConfigDamageMultiplier()

	local exp = wep:GetValue("ExplosiveDamage")
	local dmg_max = (wep:GetValue("Damage_Max") + exp) * dmult
	local dmg_min = (wep:GetValue("Damage_Min") + exp) * dmult

	local base_exp = wep:GetBaseValue("ExplosiveDamage")
	local base_dmg_max = (wep:GetBaseValue("Damage_Max") + base_exp) * dmult
	local base_dmg_min = (wep:GetBaseValue("Damage_Min") + base_exp) * dmult

	local diff_range_min = base_range_min ~= range_min
	local diff_range_max = base_range_max ~= range_max
	local diff_dmg_max = base_dmg_max ~= dmg_max
	local diff_dmg_min = base_dmg_min ~= dmg_min
	
	-- lines
	for i=1, 2 do
		local base = i==1
		local p1_x = w * ((base and base_range_min or range_min) / panel_range)
		local p2_x = w * ((base and base_range_max or range_max) / panel_range)
		local pellets = base and wep:GetBaseValue("Num") or pellets

		surface.SetDrawColor( 255, 255, 255, base and 63 or 255 )--base and 0 or 255, 0, base and 255 or 0, base and 255 or 127 )
		local dmg_max_y = h - math.min(((base and base_dmg_max or dmg_max) * pellets)/100, 1) * tall
		local dmg_min_y = h - math.min(((base and base_dmg_min or dmg_min) * pellets)/100, 1) * tall

		-- horizontal damage lines
		for i = 0, base and 0 or 1 do
			if not base or diff_range_min or diff_dmg_max then
				surface.DrawLine( 0, dmg_max_y + i, p1_x, dmg_max_y + i )
			end
			if not base or diff_range_min or diff_range_max or diff_dmg_max or diff_dmg_min then
				surface.DrawLine( p1_x, dmg_max_y + i, p2_x, dmg_min_y + i )
			end
			if not base or diff_range_max or diff_dmg_min then
				surface.DrawLine( p2_x, dmg_min_y + i, w, dmg_min_y + i )
			end
		end
	

		local tall = h * (base and .5 or .75)
		local y = h - tall
		-- vertical range bars for min and max range
		if not base or diff_range_min then
			C2_Gradient_Down( p1_x, y, 1, tall )
		end
		if not base or diff_range_max then
			C2_Gradient_Down( p2_x, y, 1, tall )
		end
	end

	local p1_x = w * (range_min / panel_range)
	local p2_x = w * (range_max / panel_range)
	local txt_unit_damage = TacRP.GetPhrase("unit.damage")
	local txt_dmg_max = math.ceil(dmg_max) .. txt_unit_damage
	local txt_dmg_min = math.ceil(dmg_min) .. txt_unit_damage
	if pellets > 1 then
		txt_dmg_max = math.ceil(dmg_max) * pellets .. "-" .. txt_dmg_max
		txt_dmg_min = math.ceil(dmg_min) * pellets .. "-" .. txt_dmg_min
	end

	surface.SetFont("TacRP_STD_8")
	local txt_range_max = wep:RangeUnitize(range_max)
	local txt_range_min = wep:RangeUnitize(range_min)
	local width_dmg_max = surface.GetTextSize(txt_dmg_max)
	local width_dmg_min = surface.GetTextSize(txt_dmg_min)
	local width_range_max = surface.GetTextSize(txt_range_max)
	local width_range_min = surface.GetTextSize(txt_range_min)

	-- bar damage close
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

	-- bar damage far
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

	surface.SetFont("TacRP_STD_6")
	local txt_panel_range = wep:RangeUnitize(panel_range)
	local width_panel_range = surface.GetTextSize(txt_panel_range)
	local height = math.ceil(s(2))
	local skip = (metric and 25 / TacRP.HUToM or 1000)
	if density > 2 then
		skip = skip * 2
	end
	for i=0, panel_range, skip do
		if i == 0 then continue end
		local x = i/phys_to_pixel
		local txt_range_marker = wep:RangeUnitize(i)
		do
			local width_range_marker = surface.GetTextSize(txt_range_marker)
			if x > w - s(1) - width_panel_range - width_range_marker/2 then continue end
		end
		surface.SetDrawColor( COLOR_OUTLINE )
		C2_Gradient_Down( x - s(.5), h - height, s(1), height )
		C2_DrawText(
			txt_range_marker,
			"TacRP_STD_6",
			x, h - s(1),
			color_white,
			TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
		)
	end

	-- show panel range
	C2_DrawText(
		txt_panel_range,
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
	local hover_bar_thickness = s(1)
	C2_Gradient_Down( range_x - hover_bar_thickness/2, y+tall/2, hover_bar_thickness, tall/2 )

	local txt_dmg
	local dmg_atrange = wep:GetDamageAtRange(range)
	if pellets > 1 then
		txt_dmg = dmg_atrange * pellets .. "-" .. dmg_atrange .. TacRP.TryTranslate("unit.damage")
	else
		txt_dmg = dmg_atrange .. TacRP.TryTranslate("unit.damage")
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