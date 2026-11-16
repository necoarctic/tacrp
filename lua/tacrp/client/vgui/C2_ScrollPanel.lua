local s = TacRP.SS

local PANEL = {}
PANEL.TopBottomPadding = true

local function scroll_paint()
	return true
end

local function scroll_grip_paint( self, w, h )
	local todo = DisableClipping( true )
		surface.SetDrawColor( 255, 255, 255 )
		if self:GetParent():GetParent().TopBottomPadding then
			surface.DrawRect( s(1), s(2), s(2), h - s(4) )
		else
			surface.DrawRect( s(1), 0, s(2), h )
		end
	DisableClipping( todo )
	return true
end

function PANEL:Init()
	self.VBar:SetWide( s(4) )
	self.VBar:SetHideButtons(true)
	self.VBar.Paint = scroll_paint
	self.VBar.btnGrip.Paint = scroll_grip_paint
end

function PANEL:PerformLayoutInternal()
	local Tall = self.pnlCanvas:GetTall()
	local Wide = self:GetWide()
	local YPos = 0

	self:Rebuild()

	self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
	YPos = self.VBar:GetOffset()

	-- don't like the added vbar width thing
	-- if ( self.VBar.Enabled ) then Wide = Wide - self.VBar:GetWide() end

	self.pnlCanvas:SetPos( 0, YPos )
	self.pnlCanvas:SetWide( Wide )

	self:Rebuild()

	if ( Tall ~= self.pnlCanvas:GetTall() ) then
		self.VBar:SetScroll( self.VBar:GetScroll() ) -- Make sure we are not too far down!
	end
end

vgui.Register("C2_ScrollPanel", PANEL, "DScrollPanel")