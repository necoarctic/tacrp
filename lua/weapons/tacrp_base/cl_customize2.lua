local s = TacRP.C2.SS

local fn = "Myriad Pro"
local sizes = {36, 18, 16, 14, 12, 10, 8, 6}
local function generate_fonts()
	for i, v in ipairs(sizes) do
		surface.CreateFont( "TacRP_C2_"..v, {
			font = fn,
			size = s(v),
			weight = 0,
		})
		surface.CreateFont( "TacRP_C2_"..v.."I", {
			font = fn,
			size = s(v),
			italic = true,
			weight = 0,
		})
	end
end
generate_fonts()

cvars.AddChangeCallback( "tacrp_c2_scale", function()
	generate_fonts()
end, "TacRP_C2_RegenerateFonts")

local cb = Color( 0, 0, 0, 127 )

local COLOR_OLD = Color( 200, 200, 200 )
local COLOR_POSITIVE = Color( 120, 255, 120 )
local COLOR_NEGATIVE = Color( 255, 200, 200 )

local function sort_atts(a, b)
	a = a or ""
	b = b or ""

	if a == "" or b == "" then return true end

	local atttbl_a = TacRP.GetAttTable(a)
	local atttbl_b = TacRP.GetAttTable(b)

	local order_a = 0
	local order_b = 0

	order_a = atttbl_a.SortOrder or order_a
	order_b = atttbl_b.SortOrder or order_b

	if order_a == order_b then
		return (atttbl_a.PrintName or "") < (atttbl_b.PrintName or "")
	end

	return order_a < order_b
end

-- Drop-in empty panel Paint
local function rt( fu, w, h )
	surface.SetDrawColor( 0, 0, 0, 63 )
	surface.DrawRect( 0, 0, w, h )
	return true
end

local grad = Material("vgui/gradient-d")
local grad2 = Material("vgui/gradient-u")
local gradr = Material("vgui/gradient-l")

local MARGIN_XS = TacRP.C2.MARGIN_XS
local MARGIN_S = TacRP.C2.MARGIN_S
local MARGIN_M = TacRP.C2.MARGIN_M
local MARGIN_L = TacRP.C2.MARGIN_L
local MARGIN_XL = TacRP.C2.MARGIN_XL

-- Text shadow upper
local C2_COLOR_TextShadow = HSVToColor( 0, 0, 0.25 )
C2_COLOR_TextShadow.a = 0.50*255

-- Text shadow lower
local C2_Color_TextShadowLower = HSVToColor( 0, 0, 0.25 )
C2_Color_TextShadowLower.a = 0.25*255

-- Main color
local C2_COLOR_Main = HSVToColor( 100, 0.2, 1 )
C2_COLOR_Main.a = 4

-- Accent color
local C2_COLOR_Accent = HSVToColor( 100, 0.4, 1 )
C2_COLOR_Accent.a = 10

-- TODO move convars to main convars file
-- Main color convars
local c_1_h = CreateClientConVar( "tacrp_c2_1_h", 20, true, false )
local c_1_s = CreateClientConVar( "tacrp_c2_1_s", 0.4, true, false )
local c_1_v = CreateClientConVar( "tacrp_c2_1_v", 1, true, false )
local c_1_a = CreateClientConVar( "tacrp_c2_1_a", (1/32), true, false )

-- Accent color convars
local c_2_h = CreateClientConVar( "tacrp_c2_2_h", 20, true, false )
local c_2_s = CreateClientConVar( "tacrp_c2_2_s", 0.6, true, false )
local c_2_v = CreateClientConVar( "tacrp_c2_2_v", 1, true, false )
local c_2_a = CreateClientConVar( "tacrp_c2_2_a", (1/32), true, false )

local c_2_gd = CreateClientConVar( "tacrp_c2_graddown", 0, true, false )

function C2_UpdateColors()
	C2_COLOR_Main = HSVToColor( c_1_h:GetFloat(), c_1_s:GetFloat(), c_1_v:GetFloat() )
	C2_COLOR_Main.a = c_1_a:GetFloat()*255
	
	C2_COLOR_Accent = HSVToColor( c_2_h:GetFloat(), c_2_s:GetFloat(), c_2_v:GetFloat() )
	--C2_COLOR_Accent = HSVToColor( ((CurTime()*360)-180)%360, 1, 1 )
	C2_COLOR_Accent.a = c_2_a:GetFloat()*255
end

function C2_GradientLine( x, y, h )
	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( grad2 )
	surface.DrawTexturedRect( x, y, 1, h )
end

function C2_GradientLineDown( x, y, h )
	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( grad )
	surface.DrawTexturedRect( x, y, 1, h )
end

function C2_GradientLineRight( x, y, w )
	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( gradr )
	surface.DrawTexturedRect( x, y, w, 1 )
end

function C2_Outline( x, y, w, h )
	surface.SetDrawColor( 255, 255, 255 )
	surface.DrawRect( x, y, w, 1 )
	surface.SetMaterial( grad2 )
	surface.DrawTexturedRect( x, y, 1, h )
	surface.DrawTexturedRect( x+w-1, y, 1, h )
end

function C2_Box( x, y, w, h )
	surface.SetDrawColor( C2_COLOR_Main )
	surface.DrawRect( x, y, w, h )
	surface.SetDrawColor( C2_COLOR_Accent )
	surface.SetMaterial( (c_2_gd:GetBool() and grad2) or grad )
	surface.DrawTexturedRect( x, y, w, h )
end

function C2_FullBox( x, y, w, h )
	C2_Box( x, y, w, h )
	C2_Outline( x, y, w, h )
end

local CLASSIC = false
if CLASSIC then
	function C2_Outline() return end
	function C2_Box( x, y, w, h )
		surface.SetDrawColor( cb )
		TacRP.DrawCorneredBox( x, y, w, h )
	end
	C2_FullBox = C2_Box
end

local function paint_box( _, w, h )
	C2_FullBox( 0, 0, w, h )
	return true
end

function C2_DrawText( t, f, x, y, c, ax, ay )
	draw.SimpleText( t, f, x, y+1, C2_COLOR_TextShadow, ax, ay )
	draw.SimpleText( t, f, x+1, y+1, C2_COLOR_TextShadow, ax, ay )
	draw.SimpleText( t, f, x+1, y+2, C2_COLOR_TextShadow, ax, ay )

	draw.SimpleText( t, f, x-1, y, C2_Color_TextShadowLower, ax, ay )
	draw.SimpleText( t, f, x-1, y-1, C2_Color_TextShadowLower, ax, ay )
	draw.SimpleText( t, f, x+1, y-1, C2_Color_TextShadowLower, ax, ay )

	draw.SimpleText( t, f, x+2, y+2, C2_Color_TextShadowLower, ax, ay )
	draw.SimpleText( t, f, x+2, y, C2_Color_TextShadowLower, ax, ay )

	draw.SimpleText( t, f, x, y, c, ax, ay )
end

local function C2_ShadowedRect( x, y, ax, ay, color )
	surface.SetDrawColor( C2_Color_TextShadowLower )
	surface.DrawRect( x, y+1, ax, ay )
	surface.DrawRect( x+1, y+1, ax, ay )
	surface.DrawRect( x+1, y+2, ax, ay )

	surface.DrawRect( x-1, y, ax, ay )
	surface.DrawRect( x-1, y-1, ax, ay )
	surface.DrawRect( x+1, y-1, ax, ay )

	surface.DrawRect( x+2, y+2, ax, ay )
	surface.DrawRect( x+2, y, ax, ay )

	surface.SetDrawColor( color )
	surface.DrawRect( x, y, ax, ay )
end

local BUTTON_HEIGHT_EMPTY = 18
local BUTTON_HEIGHT = 36

local function compute_stat( wep, stat_cache, index, data )
	if data.ConVarCheck then
		if !data.ConVar then data.ConVar = GetConVar(data.ConVarCheck) end
		if data.ConVar:GetBool() == tobool(data.ConVarInvert) then return end
	end
	if data.Spacer then
		stat_cache[index] = true
		return
	end

	local stat_base = wep:GetBaseValue( data.Value )
	local stat_curr = wep:GetValue( data.Value )

	if data.HideIfSame and stat_base == stat_curr then
		return
	end
	if data.DefaultValue ~= nil and
		stat_base == data.DefaultValue and
		stat_curr == data.DefaultValue then
		return
	end

	if data.AggregateFunction then
		stat_base = data.AggregateFunction( wep, true, wep:GetBaseValue(data.Value) )
		stat_curr = data.AggregateFunction( wep, false, wep:GetValue(data.Value) )
	else
		stat_base = math.Round( stat_base, 4 )
		stat_curr = math.Round( stat_curr, 4 )
	end
	if stat_base == nil and stat_curr == nil then return end

	local diff = nil
	if data.DifferenceFunction then
		diff = data.DifferenceFunction( wep, stat_base, stat_curr )
	elseif isnumber(stat_base) and isnumber(stat_curr) then
		if stat_curr == stat_base then
			diff = ""
		else
			diff = math.Round( (stat_curr / stat_base - 1) * 100 )
			if diff > 0 then
				diff = "+" .. tostring(diff) .. "%"
			else
				diff = tostring(diff) .. "%"
			end
		end
	end

	local text_curr
	local text_base
	if data.DisplayFunction then
		text_base = data.DisplayFunction( wep, true, stat_base )
		text_curr = data.DisplayFunction( wep, false, stat_curr )
	elseif isbool(stat_base) then
		text_base = stat_base and "YES" or "NO"
		text_curr = stat_curr and "YES" or "NO"
	else
		text_base = tostring(stat_base)
		text_curr = tostring(stat_curr)
	end

	if data.Unit then
		local unit = TacRP:TryTranslate(data.Unit)
		text_base = text_base .. unit
		text_curr = text_curr .. unit
	end

	local varying = false
	local positive = false
	if data.BetterFunction then
		-- varying, positive = data.BetterFunction( wep, stat_base, stat_curr )
	elseif stat_base ~= stat_curr then
		if isnumber(stat_curr) then
			varying = true
			positive = stat_curr > stat_base
		elseif isbool(stat_curr) then
			varying = true
			positive = !stat_base and stat_curr
		end
	end

	if data.LowerIsBetter then
		positive = !positive
	end

	stat_cache[index] = {
		stat_base = stat_curr,
		stat_curr = stat_curr,
		diff = diff,
		varying = varying,
		positive = positive,
		text_base = text_base,
		text_curr = text_curr,
	}
end

function SWEP:C2_Open()
	if IsValid( c2 ) then c2:Remove() end
	local sw, sh = ScrW(), ScrH()
	local wep = self
	c2 = vgui.Create( "Panel" )
	c2:SetSize( sw, sh )
	c2:Center()
	c2:MakePopup()
	c2:SetPopupStayAtBack( true )
	c2:SetKeyboardInputEnabled( false )
	-- c2.m_bDeleteOnClose = true
	local margin = s(MARGIN_XL)
	c2:DockPadding( margin, margin, margin, margin )

	local cl = c2:Add("DButton")
	cl:SetSize( s(58), s(12) )
	cl:SetPos( 0, 0 )
	function cl:DoClick()
		RunConsoleCommand("tacrp_drop")
		c2:Remove()
	end
	function cl:Paint( w, h )
		C2_FullBox( 0, 0, w, h )
		C2_DrawText( "Drop Weapon", "TacRP_C2_10", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		return true
	end

	c2.Interp = 0
	local align_top = c2:Add("Panel")
	align_top:SetSize( sw, sh )
	function align_top:Think()
		c2.Interp = math.Approach(c2.Interp, 1, RealFrameTime() / .4 )
		align_top:SetY( math.ease.InCirc( 1-c2.Interp ) * -sh/2 )
	end

	local align_bottom = c2:Add("Panel")
	align_bottom:SetSize( sw, sh )
	function align_bottom:Think()
		c2.Interp = math.Approach(c2.Interp, 1, RealFrameTime() / .4 )
		align_bottom:SetY( math.ease.InCirc( 1-c2.Interp ) * -sh/2 )
	end

	local align_left = c2:Add("Panel")
	align_left:SetSize( sw, sh )
	function align_left:Think()
		c2.Interp = math.Approach(c2.Interp, 1, RealFrameTime() / .4 )
		align_left:SetX( math.ease.InCirc( 1-c2.Interp ) * -sw/2 )
	end

	local p_helphover = c2:Add("Panel")
	p_helphover.TargetDraw = nil
	p_helphover.TargetDrawData = nil
	p_helphover.CurrentDraw = nil
	p_helphover:SetWide( s(140) )
	p_helphover:DockPadding( s(MARGIN_S), s(MARGIN_S), s(MARGIN_S), s(MARGIN_S) )
	p_helphover:Center()
	function p_helphover:Paint( w, h )
		surface.SetDrawColor( cb )
		surface.DrawRect( 0, 0, w, h )
		C2_Outline( 0, 0, w, h )
	end
	function p_helphover:PerformLayout( w, h )
		self:SizeToChildren( false, true )
	end
	function p_helphover:Think()
		if not self.TargetDraw then
			p_helphover:Hide()
			return
		end
		if self.TargetDraw ~= self.CurrentDraw then
			-- 

			self.CurrentDraw = self.TargetDraw
		end


	end

	local detail = p_helphover:Add("Panel")
	detail:Dock( TOP )
	detail:SetTall( s(14) )
	function detail:Paint( w, h )
		C2_DrawText(
			"Attachment Name",
			"TacRP_C2_14",
			0, 0,
			color_white
		)
	end
	
	local detail = p_helphover:Add("Panel")
	detail:Dock( TOP )
	detail:SetTall( s(2) )
	detail:DockMargin( s(-4), s(2), s(-4), s(2) )
	function detail:Paint( w, h )
		C2_GradientLineRight( 0, 0, w )
		-- surface.SetDrawColor( cb )
		-- surface.DrawRect( 0, 0, w, h )
		-- surface.SetDrawColor( color_white )
		-- surface.DrawRect( 1, 1, w-2, h-2 )
	end

	for i, v in ipairs({ "hi", "hello", "This is a long ass string! Lol!" }) do
		local detail = p_helphover:Add("Panel")
		detail:Dock( TOP )
		detail:SetTall( s(10) )
		function detail:Paint( w, h )
			C2_DrawText(
				v,
				"TacRP_C2_10",
				0, 0,
				color_white
			)
		end
	end
	
	local p_header = c2:Add("Panel")
	p_header:Dock(TOP)
	p_header:SetTall( s(48) )
	function p_header:Paint( w, h )
		C2_FullBox( 0, 0, w, h )
		local type_txt = TacRP.FormatTierType(wep.SubCatType, wep.SubCatTier, TacRP.UseTiers())
		C2_FullBox( 0, 0, w, h )
		C2_DrawText(
			wep.PrintName,
			"TacRP_C2_36",
			s(MARGIN_L), h/2,
			color_white,
			nil,
			TEXT_ALIGN_CENTER
		)
		C2_DrawText(
			type_txt,
			"TacRP_C2_12",
			w - s(MARGIN_L), h/2 - s(6),
			color_white,
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_CENTER
		)
		C2_DrawText(
			wep:GetValue("Trivia_Caliber"),
			"TacRP_C2_12",
			w - s(MARGIN_L), h/2 + s(6),
			color_white,
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_CENTER
		)
		return true
	end

	local p_footer = c2:Add("Panel")
	-- p_footer:Dock(BOTTOM)
	-- p_footer:SetTall( s(48) )
	-- local size = sw - s(360)
	p_footer:SetWide( s(360) )
	p_footer:AlignBottom( s(MARGIN_XL) )
	p_footer:CenterHorizontal()
	-- p_footer:DockMargin( size/2, 0, size/2, 0 )
	function p_footer:Paint( w, h )
		C2_FullBox( 0, 0, w, h )
		local desc = TacRP.MultiLineText( wep.Description, w - s(12*2), "TacRP_C2_12" )
		local lines = #desc
		for i, v in ipairs( desc ) do
			C2_DrawText(
				v,
				"TacRP_C2_12",
				s(12), s( 6+(12*(i-1)) ),
				color_white
			)
		end
		C2_DrawText(
			wep.Description_Quote,
			"TacRP_C2_12I",
			s(12), s( 6+(12*(lines+1)) ),
			color_white
		)
	end

	function p_footer:PerformLayout( w, h )
		local desc = TacRP.MultiLineText( wep.Description, w - s(12*2), "TacRP_C2_12" )
		local lines = #desc
		if wep.Description_Quote then lines = lines + 2 end
		self:SetTall( s(6+(12*lines)+6) )
		self:AlignBottom( s(MARGIN_XL) )
		self:CenterHorizontal()
	end
	
	local p_slotlist = c2:Add("C2_ScrollPanel")
	p_slotlist.TopBottomPadding = false
	p_slotlist:GetCanvas():DockPadding( 0, 0, s(4), 0 )
	p_slotlist:SetWide( s(96) )
	p_slotlist:Dock(LEFT)
	p_slotlist:DockMargin( 0, s(MARGIN_S), 0, s(MARGIN_S) )
	p_slotlist:GetCanvas():DockMargin( 0, 0, s(4), 0 )
	-- p_slotlist.Paint = paint_box

	local list_slots = {}
	local list_atts = {}
	
	local p_attlist = c2:Add("C2_ScrollPanel")
	p_attlist.TopBottomPadding = false
	p_attlist:GetCanvas():DockPadding( 0, 0, s(4), 0 )
	p_attlist:SetWide( s(128) )
	p_attlist:Dock(LEFT)
	p_attlist:DockMargin( s(MARGIN_S), s(MARGIN_S), 0, s(MARGIN_S) )
	p_attlist.ActiveSlot = nil
	function p_attlist:Clear()
		for i, v in ipairs(list_atts) do
			v:Remove()
			list_atts[i] = nil
		end
		self.ActiveSlot = nil
	end

	function p_attlist:Populate( category, weapon, slotindex )
		self:Clear()
		
		local atts = TacRP.GetAttsForCats( category, weapon )
		table.sort(atts, sort_atts)

		for _, att in ipairs(atts) do
			local button = p_attlist:Add("C2_AttachmentButton")
			button:SetTall( s(BUTTON_HEIGHT) )
			button:Dock(TOP)
			button:DockMargin( 0, 0, 0, s(MARGIN_S) )
			button.AttachmentName = att
			button.AttachmentData = TacRP.Attachments[att]
			button.Weapon = wep
			button.SlotIndex = slotindex

			table.insert(list_atts, button)
		end

		self.ActiveSlot = slotindex
	end

	for i, slot_data in ipairs( self.Attachments ) do
		local button = p_slotlist:Add("C2_SlotButton")
		button:Dock(TOP)
		button:SetTall( s(BUTTON_HEIGHT) )
		button:DockMargin( 0, 0, 0, s(MARGIN_S) )
		button.Weapon = wep
		button.SlotIndex = i
		button.SlotData = slot_data
		button.AttList = p_attlist
		button:EvaluateSize()

		list_slots[i] = button
	end

	--[[ function align_left:PerformLayout( w, h )
		p_slotlist:SizeToChildren( false, true )
		p_slotlist:SetY( h/2 - p_slotlist:GetTall() / 2)
	end ]]
	p_slotlist:InvalidateLayout( true )
	p_slotlist:SizeToChildren( false, true )

	local p_align_right = c2:Add( "Panel" )
	p_align_right:Dock(RIGHT)
	p_align_right:SetWide( s(180) )
	p_align_right:DockMargin( 0, s(MARGIN_S), 0, s(MARGIN_S) )

	local p_align_dmgstats = p_align_right:Add( "Panel" )
	p_align_dmgstats:Dock( TOP )
	p_align_dmgstats:SetTall( s(80) )
	p_align_dmgstats:DockMargin( 0, 0, 0, s(MARGIN_S) )

	local p_dmgdoll = p_align_dmgstats:Add( "Panel" )
	p_dmgdoll:SetWide( s(48) )
	p_dmgdoll:Dock( LEFT )
	p_dmgdoll:DockMargin( 0 ,0, s(MARGIN_S), 0 )
	function p_dmgdoll:Paint( w, h )
		C2_FullBox( 0, 0, w, h )
		C2_DrawText( "DOLL", "TacRP_C2_8", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		return true
	end

	local p_dmgrange = p_align_dmgstats:Add( "Panel" )
	p_dmgrange:Dock( FILL )

	function p_dmgrange:Paint( w, h )
		C2_FullBox( 0, 0, w, h )

		local exp = wep:GetValue("ExplosiveDamage")
		local dmult = wep:GetConfigDamageMultiplier()
		local dmg_max = (wep:GetValue("Damage_Max") + exp) * dmult
		local dmg_min = (wep:GetValue("Damage_Min") + exp) * dmult
		local range_min, range_max = wep:GetMinMaxRange()

		-- panel range expands to fit the entire damage range (+ some extra margin)
		-- panel_range = panel_range * math.ceil((range_max + 13)/panel_range)
		local right_space = s(32)
		local phys_to_pixel = range_max/w
		local panel_range = range_max + right_space*phys_to_pixel
		phys_to_pixel = panel_range/w -- needs to be updated after a new panel range

		local tall = h*.75
		local y = h - tall

		local p1_x = w * (range_min / panel_range)
		local p2_x = w * (range_max / panel_range)

		-- lines
		local max_y = h - (math.min(wep:GetValue("Damage_Max")/100, 1) * tall)
		local min_y = h - (math.min(wep:GetValue("Damage_Min")/100, 1) * tall)
		surface.SetDrawColor(255, 255, 255)
		for i = 0, 1 do
			surface.DrawLine( 0, max_y + i, p1_x, max_y + i )
			surface.DrawLine( p1_x, max_y + i, p2_x, min_y + i )
			surface.DrawLine( p2_x, min_y + i, w, min_y + i )
		end

		local txt_dmg_max = dmg_max .. TacRP:GetPhrase("unit.damage")
		local txt_dmg_min = dmg_min .. TacRP:GetPhrase("unit.damage")
		local pellets = wep:GetValue("Num")
		if pellets > 1 then
			txt_dmg_max = dmg_max * pellets .. "-" .. txt_dmg_max
			txt_dmg_min = dmg_min * pellets .. "-" .. txt_dmg_min
		end

		C2_GradientLineDown( p1_x, y, tall )
		C2_DrawText(
			txt_dmg_max,
			"TacRP_C2_10",
			p1_x, s(4),
			color_white,
			TEXT_ALIGN_CENTER
		)
		C2_DrawText(
			wep:RangeUnitize(range_min),
			"TacRP_C2_10",
			p1_x, s(4+10),
			color_white,
			TEXT_ALIGN_CENTER
		)

		C2_GradientLineDown( p2_x, y, tall )
		C2_DrawText(
			txt_dmg_min,
			"TacRP_C2_10",
			p2_x, s(4),
			color_white,
			TEXT_ALIGN_CENTER
		)
		C2_DrawText(
			wep:RangeUnitize(range_max),
			"TacRP_C2_10",
			p2_x, s(4+10),
			color_white,
			TEXT_ALIGN_CENTER
		)

		for i=0, panel_range, (TacRP.ConVars["metricunit"]:GetBool() and 25 / TacRP.HUToM or 1000) do
			if i == 0 then continue end
			-- surface.DrawRect( i / phys_to_pixel, h-2, 1, 1 )
			local x = i/phys_to_pixel
			C2_GradientLineDown( x, h - s(4), s(4) )
			C2_DrawText(
				wep:RangeUnitize(i),
				"TacRP_C2_6",
				x, h - s(1),
				color_white,
				TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
			)
		end

		return true
	end

	local p_align_breakdown = p_align_right:Add("Panel")
	p_align_breakdown:Dock( FILL )

	local p_breakdown = p_align_right:Add("C2_ScrollPanel")
	p_breakdown:Dock( RIGHT )
	p_breakdown:SetWide( s( (180 - 48) - MARGIN_S ) )
	p_breakdown:GetCanvas():DockPadding( 0, 0, 0, s(4) )
	p_breakdown.Paint = paint_box

	-- pregenerate stat display
	local stat_cache = {}

	for index, data in ipairs(wep.StatDisplay) do
		compute_stat( wep, stat_cache, index, data )
		if data.Spacer and stat_cache[index] then
			local top = index == 1
			local item = p_breakdown:Add( "Panel" )
			item:Dock( TOP )
			item:SetTall( s(18) )
			function item:Paint( w, h )
				if not top then
					C2_GradientLineRight( 0, s(2), w )
				end
				C2_DrawText(
					TacRP:TryTranslate(data.Name),
					"TacRP_C2_14",
					s(4), h,
					color_white,
					nil, TEXT_ALIGN_BOTTOM
				)
				return true
			end
		else
			local cache = stat_cache[index]
			if not cache then continue end

			local item = p_breakdown:Add( "Panel" )
			item:Dock( TOP )
			item:SetTall( s(14+5) )
			item:DockMargin( s(6), 0, 0, 0 )
			function item:Paint( w, h )
				C2_DrawText(
					TacRP:TryTranslate(data.Name),
					"TacRP_C2_8",
					0, 0,
					color_white
				)

				local stat_color = cache.varying and (cache.positive and COLOR_POSITIVE or COLOR_NEGATIVE) or color_white

				C2_DrawText(
					cache.text_curr,
					"TacRP_C2_14",
					s(4), s(5),
					stat_color
				)

				local bump_x = surface.GetTextSize(cache.text_curr) + s(4)

				if cache.diff and cache.diff ~= "" then
					local text_diff = "(" .. cache.diff .. ")"
					C2_DrawText(
						text_diff,
						"TacRP_C2_10",
						s(4) + bump_x, s(5+3.5),
						stat_color
					)
					bump_x = bump_x + surface.GetTextSize(text_diff) + s(4)
				end

				if cache.text_curr ~= cache.text_base then
					C2_DrawText(
						cache.text_base,
						"TacRP_C2_10",
						s(4) + bump_x, s(5+3.5),
						COLOR_OLD
					)
				end
				
				return true
			end
		end
	end
end

-- reloading for development
if IsValid( c2 ) then
	c2:Remove()
	c2 = nil
	net.Start("TacRP_togglecustomize")
		net.WriteBool(false)
	net.SendToServer()
	timer.Simple( 0.1, function()
	net.Start("TacRP_togglecustomize")
		net.WriteBool(true)
	net.SendToServer()
	end)
end

function SWEP:C2_Close()
	if IsValid( c2 ) then c2:Remove() return end
end

local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudGMod"] = true,
}

hook.Add("HUDShouldDraw", "TacRP_C2_HideHUD", function(name)
    if !IsValid(LocalPlayer()) then return end

	local player = LocalPlayer()
	local weapon = player:GetActiveWeapon()
	if not (IsValid( weapon ) and weapon.ArcticTacRP) then
		weapon = false
	end

	if weapon and weapon:GetCustomize() then
		if hide[name] then return false end
	end
end)

local pres = {
	["Orange Peel"] = {
		["tacrp_c2_1_h"]	= 0,
		["tacrp_c2_1_s"]	= 0.4,
		["tacrp_c2_1_v"]	= 1,
		["tacrp_c2_1_a"]	= 0.10,
		["tacrp_c2_2_h"]	= 20,
		["tacrp_c2_2_s"]	= 0.6,
		["tacrp_c2_2_v"]	= 1,
		["tacrp_c2_2_a"]	= 0.10,
		["tacrp_c2_graddown"]	= true,
	},
	["Hot Red"] = {
		["tacrp_c2_1_h"]	= 0,
		["tacrp_c2_1_s"]	= 0.8,
		["tacrp_c2_1_v"]	= 1,
		["tacrp_c2_1_a"]	= 0.25,
		["tacrp_c2_2_h"]	= 40,
		["tacrp_c2_2_s"]	= 0.8,
		["tacrp_c2_2_v"]	= 1,
		["tacrp_c2_2_a"]	= 0.25,
		["tacrp_c2_graddown"]	= true,
	},
	["Pretty Fish"] = {
		["tacrp_c2_1_h"]	= 40,
		["tacrp_c2_1_s"]	= 0.8,
		["tacrp_c2_1_v"]	= 1,
		["tacrp_c2_1_a"]	= 0.25,
		["tacrp_c2_2_h"]	= 180,
		["tacrp_c2_2_s"]	= 0.8,
		["tacrp_c2_2_v"]	= 1,
		["tacrp_c2_2_a"]	= 0.25,
		["tacrp_c2_graddown"]	= false,
	},
	["Fresh Vapor"] = {
		["tacrp_c2_1_h"]	= 285,
		["tacrp_c2_1_s"]	= 0.61,
		["tacrp_c2_1_v"]	= 1,
		["tacrp_c2_1_a"]	= 0.1,
		["tacrp_c2_2_h"]	= 200,
		["tacrp_c2_2_s"]	= 0.61,
		["tacrp_c2_2_v"]	= 0.85,
		["tacrp_c2_2_a"]	= 0.2,
		["tacrp_c2_graddown"]	= true,
	},
	["Baby Blue"] = {
		["tacrp_c2_1_h"]	= 180,
		["tacrp_c2_1_s"]	= 0.8,
		["tacrp_c2_1_v"]	= 1,
		["tacrp_c2_1_a"]	= 0.1,
		["tacrp_c2_2_h"]	= 230,
		["tacrp_c2_2_s"]	= 0.8,
		["tacrp_c2_2_v"]	= 1,
		["tacrp_c2_2_a"]	= 0.1,
		["tacrp_c2_graddown"]	= false,
	},
	["Dark Dashboard"] = {
		["tacrp_c2_1_h"]	= 180,
		["tacrp_c2_1_s"]	= 0.8,
		["tacrp_c2_1_v"]	= 1,
		["tacrp_c2_1_a"]	= 0.01,
		["tacrp_c2_2_h"]	= 230,
		["tacrp_c2_2_s"]	= 0.8,
		["tacrp_c2_2_v"]	= 1,
		["tacrp_c2_2_a"]	= 0.1,
		["tacrp_c2_graddown"]	= false,
	},
	["Dew Green"] = {
		["tacrp_c2_1_h"]	= 200,
		["tacrp_c2_1_s"]	= 0.4,
		["tacrp_c2_1_v"]	= 0.5,
		["tacrp_c2_1_a"]	= 0.2,
		["tacrp_c2_2_h"]	= 80,
		["tacrp_c2_2_s"]	= 0.6,
		["tacrp_c2_2_v"]	= 0.5,
		["tacrp_c2_2_a"]	= 0.2,
		["tacrp_c2_graddown"]	= false,
	},
	["Grass Blade"] = {
		["tacrp_c2_1_h"]	= 98,
		["tacrp_c2_1_s"]	= 0.47,
		["tacrp_c2_1_v"]	= 1,
		["tacrp_c2_1_a"]	= 0.1,
		["tacrp_c2_2_h"]	= 80,
		["tacrp_c2_2_s"]	= 0.6,
		["tacrp_c2_2_v"]	= 1,
		["tacrp_c2_2_a"]	= 0.05,
		["tacrp_c2_graddown"]	= false,
	},
	["Soft Pink"] = {
		["tacrp_c2_1_h"]	= 360,
		["tacrp_c2_1_s"]	= 0.3,
		["tacrp_c2_1_v"]	= 1,
		["tacrp_c2_1_a"]	= 0.07,
		["tacrp_c2_2_h"]	= 304,
		["tacrp_c2_2_s"]	= 0.4,
		["tacrp_c2_2_v"]	= 1,
		["tacrp_c2_2_a"]	= 0.07,
		["tacrp_c2_graddown"]	= false,
	},
	["Cookie Cream"] = {
		["tacrp_c2_1_h"]	= 0,
		["tacrp_c2_1_s"]	= 0.0,
		["tacrp_c2_1_v"]	= 0.0,
		["tacrp_c2_1_a"]	= 0.5,
		["tacrp_c2_2_h"]	= 43,
		["tacrp_c2_2_s"]	= 0.2,
		["tacrp_c2_2_v"]	= 1,
		["tacrp_c2_2_a"]	= 0.0,
		["tacrp_c2_graddown"]	= true,
	},
}

hook.Add( "PopulateToolMenu", "CustomMenuSettings", function()
	spawnmenu.AddToolMenuOption( "Options", "Tactical RP Weapons", "TacRP_C2", "Beta: Customize 2", "", "", function( panel )
		panel:Help("Presets")
		local pcom = vgui.Create( "DComboBox", panel )
		pcom:Dock(TOP)
		pcom:DockMargin( 10, 5, 10, 5 )
		for i, data in SortedPairs( pres ) do
			pcom:AddChoice( i )
		end

		function pcom:OnSelect( bleh, index )
			if pres[index] then
				for i, v in pairs( pres[index] ) do
					if v == true or v == false then
						GetConVar(i):SetBool(v)
					else
						GetConVar(i):SetFloat(v)
					end
				end
			end
		end

		panel:Help("Main Color")
		panel:NumSlider( "Main Hue", "tacrp_c2_1_h", 0, 360, 0 )
		panel:NumSlider( "Main Sat.", "tacrp_c2_1_s", 0, 1, 2 )
		panel:NumSlider( "Main Value", "tacrp_c2_1_v", 0, 1, 2 )
		panel:NumSlider( "Main Alpha", "tacrp_c2_1_a", 0, 1, 2 )
		
		panel:Help("Accent Color")
		panel:CheckBox( "Top-down Gradient", "tacrp_c2_graddown" )
		panel:NumSlider( "Accent Hue", "tacrp_c2_2_h", 0, 360, 0 )
		panel:NumSlider( "Accent Sat.", "tacrp_c2_2_s", 0, 1, 2 )
		panel:NumSlider( "Accent Value", "tacrp_c2_2_v", 0, 1, 2 )
		panel:NumSlider( "Accent Alpha", "tacrp_c2_2_a", 0, 1, 2 )
	end )
	spawnmenu.AddToolMenuOption( "Options", "Tactical RP Weapons", "TacRP_H2", "Beta: HUD 2", "", "", function( panel )
		panel:CheckBox( "Enable HUD", "tacrp_h2_enable" )
		panel:CheckBox( "Enable Health", "tacrp_h2_enable_health" )
		panel:CheckBox( "Enable Ammo", "tacrp_h2_enabled_ammo" )
	end )
end )