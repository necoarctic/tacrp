local s = TacRP.SS

local COLOR_BACKGROUND = TacRP.C2.COLOR_BACKGROUND
local COLOR_HOVER = TacRP.C2.COLOR_HOVER
local COLOR_OLD = TacRP.C2.COLOR_OLD
local COLOR_POSITIVE = TacRP.C2.COLOR_POSITIVE
local COLOR_NEGATIVE = TacRP.C2.COLOR_NEGATIVE
local COLOR_OUTLINE = TacRP.C2.COLOR_OUTLINE

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


local MARGIN_XS = TacRP.C2.MARGIN_XS
local MARGIN_S = TacRP.C2.MARGIN_S
local MARGIN_M = TacRP.C2.MARGIN_M
local MARGIN_L = TacRP.C2.MARGIN_L
local BUTTON_HEIGHT = TacRP.C2.BUTTON_HEIGHT

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
local c_1_h = TacRP.ConVars["c2_1_h"]
local c_1_s = TacRP.ConVars["c2_1_s"]
local c_1_v = TacRP.ConVars["c2_1_v"]
local c_1_a = TacRP.ConVars["c2_1_a"]

-- Accent color convars
local c_2_h = TacRP.ConVars["c2_2_h"]
local c_2_s = TacRP.ConVars["c2_2_s"]
local c_2_v = TacRP.ConVars["c2_2_v"]
local c_2_a = TacRP.ConVars["c2_2_a"]

local c_2_gd = TacRP.ConVars["c2_graddown"]
local c_2_classic = TacRP.ConVars["c2_classic"]

function C2_UpdateColors()
	C2_COLOR_Main = HSVToColor( c_1_h:GetFloat(), c_1_s:GetFloat(), c_1_v:GetFloat() )
	C2_COLOR_Main.a = c_1_a:GetFloat()*255
	
	C2_COLOR_Accent = HSVToColor( c_2_h:GetFloat(), c_2_s:GetFloat(), c_2_v:GetFloat() )
	--C2_COLOR_Accent = HSVToColor( ((CurTime()*360)-180)%360, 1, 1 )
	C2_COLOR_Accent.a = c_2_a:GetFloat()*255
end
C2_UpdateColors()

cvars.AddChangeCallback( "tacrp_c2_1_h", C2_UpdateColors, "TacRP_C2_Color" )
cvars.AddChangeCallback( "tacrp_c2_1_s", C2_UpdateColors, "TacRP_C2_Color" )
cvars.AddChangeCallback( "tacrp_c2_1_v", C2_UpdateColors, "TacRP_C2_Color" )
cvars.AddChangeCallback( "tacrp_c2_1_a", C2_UpdateColors, "TacRP_C2_Color" )
cvars.AddChangeCallback( "tacrp_c2_2_h", C2_UpdateColors, "TacRP_C2_Color" )
cvars.AddChangeCallback( "tacrp_c2_2_s", C2_UpdateColors, "TacRP_C2_Color" )
cvars.AddChangeCallback( "tacrp_c2_2_v", C2_UpdateColors, "TacRP_C2_Color" )
cvars.AddChangeCallback( "tacrp_c2_2_a", C2_UpdateColors, "TacRP_C2_Color" )
cvars.AddChangeCallback( "tacrp_c2_graddown", C2_UpdateColors, "TacRP_C2_Color" )
cvars.AddChangeCallback( "tacrp_c2_classic", C2_UpdateColors, "TacRP_C2_Color" )

local grad_d = Material("vgui/gradient-d")
local grad_u = Material("vgui/gradient-u")
local grad_l = Material("vgui/gradient-l")
local grad_r = Material("vgui/gradient-r")

function C2_Gradient_Up( x, y, w, h )
	surface.SetMaterial( grad_u )
	surface.DrawTexturedRect( x, y, w, h )
end
function C2_Gradient_Down( x, y, w, h )
	surface.SetMaterial( grad_d )
	surface.DrawTexturedRect( x, y, w, h )
end
function C2_Gradient_Left( x, y, w, h )
	surface.SetMaterial( grad_l )
	surface.DrawTexturedRect( x, y, w, h )
end
function C2_Gradient_Right( x, y, w, h )
	surface.SetMaterial( grad_r )
	surface.DrawTexturedRect( x, y, w, h )
end

function C2_Outline( x, y, w, h )
	if c_2_classic:GetBool() then
		surface.SetDrawColor( color_white )
		TacRP.DrawCorners( x, y, w, h )
		return
	end

	surface.SetDrawColor( COLOR_OUTLINE )
	surface.DrawRect( x, y, w, 1 )
	surface.SetMaterial( grad_u )
	surface.DrawTexturedRect( x, y+1, 1, h-1 )
	surface.DrawTexturedRect( x+w-1, y+1, 1, h-1 )
end

function C2_Box( x, y, w, h )
	surface.SetDrawColor( C2_COLOR_Main )
	surface.DrawRect( x, y, w, h )
	surface.SetDrawColor( C2_COLOR_Accent )
	surface.SetMaterial( (c_2_gd:GetBool() and grad_u) or grad_d )
	surface.DrawTexturedRect( x, y, w, h )
end

function C2_FullBox( x, y, w, h )
	C2_Box( x, y, w, h )
	C2_Outline( x, y, w, h )
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

local function c2_tostr( str )
	return (str == math.huge) and "∞" or tostring(str)
end

local function compute_stat( wep, stat_cache, index, data )
	if data.ConVarCheck then
		if !data.ConVar then data.ConVar = GetConVar(data.ConVarCheck) end
		if data.ConVar:GetBool() == tobool(data.ConVarInvert) then return end
	end

	if data.Spacer then
		stat_cache[index] = true
		return
	end

	local raw_base = wep:GetBaseValue( data.Value )
	local raw_curr = wep:GetValue( data.Value )

	if data.HideIfSame and raw_base == raw_curr then
		return
	end
	
	if data.DefaultValue ~= nil and
		raw_base == data.DefaultValue and
		raw_curr == data.DefaultValue then
		return
	end

	if data.ValueCheck and wep:GetValue(data.ValueCheck) ~= (not data.ValueInvert) then
		return
	end

	local stat_base, stat_curr
	if data.AggregateFunction then
		stat_base = data.AggregateFunction( wep, true, raw_base )
		stat_curr = data.AggregateFunction( wep, false, raw_curr )
	else
		stat_base = math.Round( raw_base, 4 )
		stat_curr = math.Round( raw_curr, 4 )
	end
	if stat_base == nil and stat_curr == nil then return end

	local diff = nil
	if data.DifferenceFunction then
		diff = data.DifferenceFunction( wep, raw_base, raw_curr )
	elseif isnumber(stat_base) and isnumber(stat_curr) then
		if stat_curr == stat_base then
			diff = ""
		else
			diff = math.Round( (stat_curr / stat_base - 1) * 100 )
			if diff > 0 then
				diff = "+" .. c2_tostr(diff) .. "%"
			else
				diff = c2_tostr(diff) .. "%"
			end
		end
	end

	local text_base, text_curr
	if data.DisplayFunction then
		text_base = data.DisplayFunction( wep, true, raw_base )
		text_curr = data.DisplayFunction( wep, false, raw_curr )
	elseif isbool(stat_base) then
		text_base = stat_base and "YES" or "NO"
		text_curr = stat_curr and "YES" or "NO"
	else
		text_base = c2_tostr(stat_base)
		text_curr = c2_tostr(stat_curr)
	end

	if data.Unit then
		local unit = TacRP:TryTranslate(data.Unit)
		text_base = text_base .. unit
		text_curr = text_curr .. unit
	end

	local varying = false
	local positive = false
	if data.BetterFunction then
		varying, positive = data.BetterFunction( wep, raw_base, raw_curr )
	elseif stat_base ~= stat_curr then
		if isnumber(stat_curr) then
			varying = true
			-- -- TODO: M79 with Baseballs break the menu for some reason! Baseball: stat_base nil, stat_curr number
			if not stat_base then
				positive = true
			else
				positive = stat_curr > stat_base
			end
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
	local is_grenade = wep:GetValue("PrimaryGrenade")
	c2 = vgui.Create( "EditablePanel" )
	c2:SetSize( sw, sh )
	c2:Center()
	c2:MakePopup()
	c2:SetPopupStayAtBack( true )
	c2:SetKeyboardInputEnabled( false )
	-- c2.m_bDeleteOnClose = true
	local margin = s(MARGIN_L)
	c2:DockPadding( margin, margin, margin, margin )

	do -- Close & Drop Weapon button
		local BUTTON_SIZE = 8
		local p_closebutton = c2:Add("DButton")
		p_closebutton:SetSize( s(BUTTON_SIZE), s(BUTTON_SIZE) )
		p_closebutton:AlignRight( s(MARGIN_L) )
		p_closebutton:AlignTop( s(MARGIN_L/2 - BUTTON_SIZE/2) )

		function p_closebutton:DoClick()
			c2:Remove()
		end

		function p_closebutton:Paint( w, h )
			C2_Box( 0, 0, w, h )
			if self:IsHovered() then
				surface.SetDrawColor( COLOR_HOVER )
				surface.DrawRect( 0, 0, w, h )
			end
			C2_DrawText(
				"×",
				"TacRP_STD_8",
				w/2,
				h/2 - s(.5),
				color_white,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER
			)
			C2_Outline( 0, 0, w, h )
			return true
		end

		function c2:OnRemove()
			if TacRP.ConVars["autosave"]:GetBool() and TacRP.ConVars["free_atts"]:GetBool() then
				wep:SavePreset()
			end
		end

		if ( engine.ActiveGamemode() == "terrortown"
			or TacRP.ConVars["allowdrop"]:GetBool()
		) and TacRP.ConVars["cust_drop"]:GetBool() and ( !is_grenade or !TacRP.IsGrenadeInfiniteAmmo(is_grenade) ) then
			local txt = TacRP:TryTranslate("cust.drop_wep")
			surface.SetFont("TacRP_STD_6")
			local width = surface.GetTextSize(txt)
			width = width + s(BUTTON_SIZE)
			local p_dropweapon = c2:Add("DButton")
			p_dropweapon:SetSize( width, s(BUTTON_SIZE) )
			p_dropweapon:AlignRight( s(MARGIN_L + BUTTON_SIZE + MARGIN_S) )
			p_dropweapon:AlignTop( s(MARGIN_L/2 - BUTTON_SIZE/2) )

			function p_dropweapon:DoClick()
				RunConsoleCommand("tacrp_drop")
			end

			function p_dropweapon:Paint( w, h )
				C2_Box( 0, 0, w, h )
				if self:IsHovered() then
					surface.SetDrawColor( COLOR_HOVER )
					surface.DrawRect( 0, 0, w, h )
				end
				C2_DrawText(
					txt,
					"TacRP_STD_6",
					w/2,
					h/2,
					color_white,
					TEXT_ALIGN_CENTER,
					TEXT_ALIGN_CENTER
				)
				C2_Outline( 0, 0, w, h )
				return true
			end
		end
	end

	--[[ c2.Interp = 0

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
	end ]]

	local p_hint = c2:Add("Panel")
	p_hint.CurrentID = nil
	local wide = 160
	p_hint:SetWide( s(wide) )
	p_hint:DockPadding( s(MARGIN_S), s(MARGIN_S), s(MARGIN_S), s(MARGIN_S) )
	p_hint:Center()
	p_hint:SetDrawOnTop(true)

	function p_hint:Paint( w, h )
		surface.SetDrawColor( COLOR_BACKGROUND )
		surface.DrawRect( 0, 0, w, h )
		C2_Outline( 0, 0, w, h )
	end

	function p_hint:PerformLayout( w, h )
		self:SizeToChildren( false, true )
	end

	function c2:Think()
		if !IsValid(wep) or !IsValid(wep:GetOwner()) or wep:GetOwner():GetActiveWeapon() != wep then
			self:Remove()
		end

		local target = vgui.GetHoveredPanel()
		if target and target.TargetID and target.TargetData then

			if target.TargetID ~= p_hint.CurrentID then
				for _, panel in ipairs( p_hint:GetChildren() ) do
					panel:Remove()
				end

				if target.TargetID then
					for _, data in ipairs( target.TargetData ) do
						local size = data.Big and 12 or 8
						if data.Right then
							local detail = p_hint:Add("Panel")
							detail:SetSize( w, s(8+2+2) )
							function detail:Paint( w, h )
								C2_DrawText(
									data.Text,
									"TacRP_STD_8",
									w - s(2), s(2),
									color_white,
									TEXT_ALIGN_RIGHT
								)
							end
						elseif data.Separator then
							local detail = p_hint:Add("Panel")
							detail:Dock( TOP )
							detail:SetTall( s(2) )
							detail:DockMargin( s(-4), s(4), s(-4), s(4) )
							function detail:Paint( w, h )
								surface.SetDrawColor( COLOR_OUTLINE )
								C2_Gradient_Left( 0, 0, w, 1 )
							end
						else
							local detail = p_hint:Add("Panel")
							detail:Dock( TOP )
							local lines = TacRP.MultiLineText(data.Text, s(wide - 4 - 4), "TacRP_STD_"..size )
							detail:SetTall( s(#lines * size) )
							function detail:Paint( w, h )
								for i, line in ipairs(lines) do
									i = i - 1
									C2_DrawText(
										line,
										"TacRP_STD_"..size,
										0, s(i * size),
										color_white
									)
								end
							end

						end
					end
					p_hint:InvalidateLayout(true)
				end
				p_hint.CurrentID = target.TargetID
			end

			local hint_w, hint_h = p_hint:GetSize()
			local target_x, target_y = self:GetChildPosition(target)
			local target_w, target_h = target:GetSize()
			local final_x
			if target_x > self:GetWide()/2 then
				final_x = target_x - hint_w - s(4)
			else
				final_x = target_x + target_w + s(4)
			end

			local final_y = target_y + target_h/2 - hint_h/2
			final_y = math.Clamp( final_y, s(MARGIN_L), self:GetTall() - hint_h - s(MARGIN_L) )

			p_hint:SetPos( final_x, final_y )

			p_hint:Show()
		else
			p_hint:Hide()
		end
	end
	
	local p_header = c2:Add("Panel")
	p_header:Dock(TOP)
	p_header:SetTall( s(MARGIN_S+24+MARGIN_S) )
	function p_header:Paint( w, h )
		C2_FullBox( 0, 0, w, h )

		C2_DrawText(
			wep.PrintName,
			"TacRP_STD_24",
			s(MARGIN_M), h/2,
			color_white,
			nil,
			TEXT_ALIGN_CENTER
		)
		local txt_weptype = TacRP.FormatTierType(wep.SubCatType, wep.SubCatTier, TacRP.UseTiers())

		local txt_ammo
		local ammotype = wep:GetAmmoType()
		local ammoid = game.GetAmmoID(ammotype)
		ammotype = game.GetAmmoName(ammoid)
		
		local items = 1
		if ammotype ~= "" and ammoid != -1 then
			txt_ammo = language.GetPhrase(ammotype .. "_ammo")
			items = items + 1
		end

		local shift = s(10)
		local bump_y = -shift/2 * items

		C2_DrawText(
			txt_weptype,
			"TacRP_STD_10",
			w - s(MARGIN_M), (h/2) + bump_y,
			color_white,
			TEXT_ALIGN_RIGHT
		)
		bump_y = bump_y + shift

		if txt_ammo then
			C2_DrawText(
				txt_ammo,
				"TacRP_STD_10",
				w - s(MARGIN_M), (h/2) + bump_y,
				color_white,
				TEXT_ALIGN_RIGHT
			)
			bump_y = bump_y + shift
		end

		return true
	end

	do
		local SPACING_W = MARGIN_L
		local SPACING_H = MARGIN_M
		local LINE_HEIGHT = 10
		local p_footer = c2:Add("Panel")
		p_footer:SetWide( s(308) )

		local txt_desc, txt_quote
		if is_grenade then
			local def = TacRP.QuickNades[is_grenade]
			txt_desc = (TacRP:GetPhrase("quicknade." .. def.PrintName .. ".dettype") or def.DetType or "")
			txt_desc = txt_desc .. "\n" .. (TacRP:GetPhrase("quicknade." .. def.PrintName .. ".desc") or def.Description)
			-- txt_quote = "Grenade Quote"
		else
			txt_desc = wep.Description
			txt_quote = wep.Description_Quote
		end
		
		function p_footer:Paint( w, h )
			C2_FullBox( 0, 0, w, h )
			local lines_desc = TacRP.MultiLineText( txt_desc, w - s(SPACING_W*2), "TacRP_STD_10" )
			local line_index = 0
			for _, line in ipairs( lines_desc ) do
				C2_DrawText(
					line,
					"TacRP_STD_10",
					s( SPACING_W ),
					s( SPACING_H + (LINE_HEIGHT * line_index) ),
					color_white
				)
				line_index = line_index + 1
			end

			if not txt_quote then return end
			line_index = line_index + 1
			local lines_quote = TacRP.MultiLineText( txt_quote, w - s(SPACING_W*2), "TacRP_STD_10I" )
			for _, line in ipairs( lines_quote ) do
				C2_DrawText(
					line,
					"TacRP_STD_10I",
					s( SPACING_W ),
					s( SPACING_H + (LINE_HEIGHT * line_index) ),
					color_white
				)
				line_index = line_index + 1
			end
		end

		function p_footer:PerformLayout( w, h )
			local lines = #TacRP.MultiLineText( txt_desc, w - s(SPACING_W*2), "TacRP_STD_10" )
			if txt_quote then
				lines = lines + 1 + #TacRP.MultiLineText( txt_quote, w - s(SPACING_W*2), "TacRP_STD_10I" )
			end
			self:SetTall( s( SPACING_H*2 + LINE_HEIGHT*lines ) )
			self:AlignBottom( s( MARGIN_L ) )
			self:CenterHorizontal()
		end
	end
	
	local p_slotlist = c2:Add("C2_ScrollPanel")
	p_slotlist:GetCanvas():DockPadding( 0, 0, s(4), 0 ) -- scrollbar
	p_slotlist.TopBottomPadding = false
	p_slotlist:SetWide( s( MARGIN_S * 2 + 96 + 4 ) )
	p_slotlist:Dock(LEFT)
	p_slotlist:DockMargin( 0, s(MARGIN_S), 0, 0 )
	-- p_slotlist.Paint = paint_box

	local p_attlist = c2:Add("C2_ScrollPanel")
	p_attlist:GetCanvas():DockPadding( 0, 0, s(4), 0 ) -- scrollbar
	p_attlist.TopBottomPadding = false
	p_attlist:SetWide( s( MARGIN_S * 2 + 96 + 4 ) )
	p_attlist:Dock(LEFT)
	p_attlist:DockMargin( 0, s(MARGIN_S), 0, 0 )
	p_attlist.ActiveSlot = nil
	p_attlist.ChildPanels = {}
	function p_attlist:Clear()
		for i, v in ipairs(self.ChildPanels) do
			v:Remove()
			self.ChildPanels[i] = nil
		end
		self.ActiveSlot = nil
	end

	function p_attlist:Populate( category, weapon, slotindex, slotopener )
		self:Clear()
		self.SlotOpener = slotopener
		
		local atts = TacRP.GetAttsForCats( category, weapon )
		table.sort(atts, sort_atts)

		for _, att in ipairs(atts) do
			local button = p_attlist:Add("C2_AttachmentButton")
			button:SetTall( s(BUTTON_HEIGHT) )
			button:Dock(TOP)
			button:DockMargin( 0, 0, 0, s(MARGIN_S) )
			button.AttachmentName = att
			button.AttachmentData = TacRP.Attachments[att]
			button.AttList = p_attlist
			button.Weapon = wep
			button.SlotIndex = slotindex
			button:SetupTarget()

			table.insert(self.ChildPanels, button)
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
		button:SetupTarget()
		button:EvaluateSize()
	end

	-- take and hold support
	if TAH and TAH.ConVars["game_limitedcust"] and TAH.ConVars["game_limitedcust"]:GetBool() then
		local p = LocalPlayer()
		local button = p_slotlist:Add("DButton")
		button:Dock( TOP )
		button:SetTall( s(BUTTON_HEIGHT) )
		button:DockMargin( 0, 0, 0, s(MARGIN_S) )
		function button:Paint(w, h)
			C2_Box(0, 0, w, h)
			
			C2_DrawText(
				"Use Attachment Kit",
				"TacRP_STD_12",
				w/2,
				h/2,
				color_white,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER
			)

			C2_Outline(0, 0, w, h)
			return true
		end

		function button:DoClick()
			if p.TAH_PendingAttWeapon == wep then
				RunConsoleCommand("tah_attbox")
			else
				RunConsoleCommand("tah_use_attbox")
			end
		end
	end

	p_slotlist:InvalidateLayout( true )
	p_slotlist:SizeToChildren( false, true )

	local doll_wide = 36
	local want_wide = 112

	local p_align_right = c2:Add( "Panel" )
	p_align_right:Dock(RIGHT)
	p_align_right:SetWide( s(want_wide + doll_wide) )
	p_align_right:DockMargin( 0, s(MARGIN_S), 0, 0 )
	
	if not self:GetValue("NoRanger") then
		local p_align_dmgstats = p_align_right:Add( "Panel" )
		p_align_dmgstats:Dock( TOP )
		p_align_dmgstats:SetTall( s(80) )
		p_align_dmgstats:DockMargin( 0, 0, 0, s(MARGIN_S) )

		local p_dmgdoll = p_align_dmgstats:Add( "C2_DamageDoll" )
		p_dmgdoll:SetWide( s(doll_wide) )
		p_dmgdoll:Dock( LEFT )
		p_dmgdoll:DockMargin( 0, 0, s(MARGIN_S), 0 )
		p_dmgdoll.Weapon = wep

		local p_dmgrange = p_align_dmgstats:Add( "C2_DamageRange" )
		p_dmgrange:Dock( FILL )
		p_dmgrange.Weapon = wep
		p_dmgrange.DamageDoll = p_dmgdoll
	end

	local p_align_breakdown = p_align_right:Add("Panel")
	p_align_breakdown:Dock( FILL )

	--[[ for i=1, 3 do
		local p_tab = p_align_breakdown:Add("DButton")
		p_tab:Dock(TOP)
		function p_tab:Paint( w, h )
			C2_FullBox( 0, 0, w, h )
			return true
		end
	end ]]

	if not wep:GetValue("NoStatBox") then
		local p_breakdown = p_align_right:Add("C2_ScrollPanel")
		p_breakdown:Dock( RIGHT )
		p_breakdown:SetWide( s( want_wide - MARGIN_S ) )
		p_breakdown:GetCanvas():DockPadding( 0, s(MARGIN_S), 0, s(MARGIN_S) )
		p_breakdown.Paint = paint_box
		p_breakdown.ChildPanels = {}

		function p_breakdown:Populate()
			for _, v in pairs(self.ChildPanels) do
				v:Remove()
			end

			local melee = wep:GetValue("PrimaryMelee")
			local statgroup = melee and wep.StatGroupsMelee or wep.StatGroups
			local statdisplay = melee and wep.StatDisplayMelee or wep.StatDisplay

			local stat_cache = {}
			wep.MiscCache["c2_breakdown"] = stat_cache
			for index, data in ipairs(statdisplay) do
				compute_stat( wep, stat_cache, index, data )
				local TargetData = {
					{
						Text = TacRP:TryTranslate(data.Name),
						Big = true,
					},
					{
						Text = TacRP:TryTranslate(data.Description),
					}
				}
				local TargetID = "breakdown_" .. data.Name

				if data.Spacer and stat_cache[index] then
					local top = index == 1
					if not top then
						local bar = p_breakdown:Add("Panel")
						table.insert( self.ChildPanels, bar )
						bar:SetTall( 1 )
						bar:Dock(TOP)
						bar:DockMargin( 0, s(2), 0, s(2) )
						function bar:Paint( w, h )
							surface.SetDrawColor( COLOR_OUTLINE )
							C2_Gradient_Left( 0, 0, w, 1 )
						end
					end

					local item = p_breakdown:Add( "Panel" )
					table.insert( self.ChildPanels, item )
					item:Dock( TOP )
					item:SetTall( s(14) )
					item.TargetID = TargetID
					item.TargetData = TargetData
					function item:Paint( w, h )
						if self:IsHovered() then
							surface.SetDrawColor( COLOR_HOVER )
							C2_Gradient_Left( 0, 0, w, h )
						end
						C2_DrawText(
							TacRP:TryTranslate(data.Name),
							"TacRP_STD_14",
							s(4), 0,
							color_white
						)
						return true
					end
				else
					local cache = stat_cache[index]
					if not cache then continue end

					local item = p_breakdown:Add( "Panel" )
					table.insert( self.ChildPanels, item )
					item:Dock( TOP )
					item:SetTall( s(14+5) )
					item.TargetID = TargetID
					item.TargetData = TargetData
					function item:Paint( w, h )
						if self:IsHovered() then
							surface.SetDrawColor( COLOR_HOVER )
							C2_Gradient_Left( 0, 0, w, h )
						end

						C2_DrawText(
							TacRP:TryTranslate(data.Name),
							"TacRP_STD_8",
							s(6), 0,
							color_white
						)

						local stat_color = cache.varying and (cache.positive and COLOR_POSITIVE or COLOR_NEGATIVE) or color_white

						C2_DrawText(
							cache.text_curr,
							"TacRP_STD_14",
							s(6+4), s(5),
							stat_color
						)

						local bump_x = surface.GetTextSize(cache.text_curr) + s(4)

						if cache.diff and cache.diff ~= "" then
							local text_diff = "(" .. cache.diff .. ")"
							C2_DrawText(
								text_diff,
								"TacRP_STD_10",
								s(6+4) + bump_x, s(5+3.5),
								stat_color
							)
							bump_x = bump_x + surface.GetTextSize(text_diff) + s(4)
						end

						if cache.text_curr ~= cache.text_base then
							C2_DrawText(
								cache.text_base,
								"TacRP_STD_10",
								s(6+4) + bump_x, s(5+3.5),
								COLOR_OLD
							)
						end
						
						return true
					end
				end
			end
		end

		function p_breakdown:Think()
			if not wep.MiscCache["c2_breakdown"] then
				self:Populate()
			end
		end

		p_breakdown:Populate()
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

hook.Add("HUDShouldDraw", "TacRP_STD_HideHUD", function(name)
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
		["tacrp_c2_classic"]	= false,
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
		["tacrp_c2_classic"]	= false,
	},
	["Pretty Fish"] = {
		["tacrp_c2_1_h"]	= 40,
		["tacrp_c2_1_s"]	= 0.8,
		["tacrp_c2_1_v"]	= 1,
		["tacrp_c2_1_a"]	= 0.15,
		["tacrp_c2_2_h"]	= 180,
		["tacrp_c2_2_s"]	= 0.8,
		["tacrp_c2_2_v"]	= 1,
		["tacrp_c2_2_a"]	= 0.15,
		["tacrp_c2_graddown"]	= false,
		["tacrp_c2_classic"]	= false,
	},
	["Fresh Vapor"] = {
		["tacrp_c2_1_h"]	= 285,
		["tacrp_c2_1_s"]	= 0.61,
		["tacrp_c2_1_v"]	= 1.00,
		["tacrp_c2_1_a"]	= 0.10,
		["tacrp_c2_2_h"]	= 200,
		["tacrp_c2_2_s"]	= 0.61,
		["tacrp_c2_2_v"]	= 0.85,
		["tacrp_c2_2_a"]	= 0.20,
		["tacrp_c2_graddown"]	= true,
		["tacrp_c2_classic"]	= false,
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
		["tacrp_c2_classic"]	= false,
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
		["tacrp_c2_classic"]	= false,
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
		["tacrp_c2_classic"]	= false,
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
		["tacrp_c2_classic"]	= false,
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
		["tacrp_c2_classic"]	= false,
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
		["tacrp_c2_classic"]	= false,
	},
	["Cult Classic"] = {
		["tacrp_c2_1_h"]	= 0,
		["tacrp_c2_1_s"]	= 0,
		["tacrp_c2_1_v"]	= 0,
		["tacrp_c2_1_a"]	= 0.75,
		["tacrp_c2_2_h"]	= 0,
		["tacrp_c2_2_s"]	= 0,
		["tacrp_c2_2_v"]	= 0,
		["tacrp_c2_2_a"]	= 0,
		["tacrp_c2_graddown"]	= false,
		["tacrp_c2_classic"]	= true,
	},
	["Sweet Potato"] = {
		["tacrp_c2_1_h"]	= 304,
		["tacrp_c2_1_s"]	= 0.50,
		["tacrp_c2_1_v"]	= 0.47,
		["tacrp_c2_1_a"]	= 0.46,
		["tacrp_c2_2_h"]	= 43,
		["tacrp_c2_2_s"]	= 0.23,
		["tacrp_c2_2_v"]	= 1.00,
		["tacrp_c2_2_a"]	= 0.33,
		["tacrp_c2_graddown"]	= true,
		["tacrp_c2_classic"]	= false,
	},
	["Fragrant Laundry"] = {
		["tacrp_c2_1_h"]	= 340,
		["tacrp_c2_1_s"]	= 0.20,
		["tacrp_c2_1_v"]	= 0.40,
		["tacrp_c2_1_a"]	= 0.20,
		["tacrp_c2_2_h"]	= 290,
		["tacrp_c2_2_s"]	= 0.20,
		["tacrp_c2_2_v"]	= 1.00,
		["tacrp_c2_2_a"]	= 0.1,
		["tacrp_c2_graddown"]	= true,
		["tacrp_c2_classic"]	= false,
	},
	["Turquoise Tactics"] = {
		["tacrp_c2_1_h"]	= 0,
		["tacrp_c2_1_s"]	= 0.00,
		["tacrp_c2_1_v"]	= 0.10,
		["tacrp_c2_1_a"]	= 0.40,
		["tacrp_c2_2_h"]	= 200,
		["tacrp_c2_2_s"]	= 1.00,
		["tacrp_c2_2_v"]	= .75,
		["tacrp_c2_2_a"]	= 0.2,
		["tacrp_c2_graddown"]	= true,
		["tacrp_c2_classic"]	= false,
	},
}

hook.Add( "PopulateToolMenu", "CustomMenuSettings", function()
	spawnmenu.AddToolMenuOption( "Options", "Tactical RP Weapons", "TacRP_C2", "Anniversary Beta", "", "", function( panel )
		panel:CheckBox( "Spawnmenu v2", "tacrp_s2_enable" )
		panel:CheckBox( "HUD v2", "tacrp_h2_enable" )
		panel:CheckBox( "Enable Health", "tacrp_h2_enable_health" )
		panel:CheckBox( "Enable Ammo", "tacrp_h2_enable_ammo" )
		panel:Help( "press WALK + CUSTOMIZE to use old customize menu" )
		
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
		
		panel:CheckBox( "Classic Corners", "tacrp_c2_classic" )

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
end )