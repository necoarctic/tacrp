local PANEL = {}

local function header_paint(self, w, h)
	return true
end

function PANEL:Init()
	self.Header:SetTall( 32 )
	self.Header.Paint = header_paint
end

function PANEL:Paint(w, h)
	local expanded = self.m_bSizeExpanded
	surface.SetDrawColor( 0, 0, 0, 200 )
	surface.SetFont("TacRP_STD_32XI")
	local text_width = surface.GetTextSize( self.SubCatType )
	surface.DrawRect( 0, 0, 4+text_width+4+4, 32 )

	S2_DrawText(
		self.SubCatType,
		"TacRP_STD_32XI",
		4,
		0
	)

	local additional = ""
	if self.ItemsFiltered and self.ItemsFiltered > 0 and self.ItemCount ~= self.ItemsFiltered then
		additional = " -- " .. self.ItemsFiltered .. " shown"
	end
	S2_DrawText(
		self.ItemCount .. " total" .. additional,
		"TacRP_STD_20XI",
		4 + text_width + 4 + 4 + 4,
		32/2,
		nil,
		TEXT_ALIGN_CENTER
	)

	if not expanded then
		local size = 12
		draw.NoTexture()
		surface.SetDrawColor( color_white )
		surface.DrawTexturedRectRotated( w - size, 32/2, size, size, 45 )
	end
	return true
end

vgui.Register("S2_CollapsibleCategory", PANEL, "DCollapsibleCategory")