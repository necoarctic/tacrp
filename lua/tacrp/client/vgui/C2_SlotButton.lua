local s = TacRP.SS

local MARGIN_XS = TacRP.C2.MARGIN_XS
local MARGIN_S = TacRP.C2.MARGIN_S
local MARGIN_M = TacRP.C2.MARGIN_M
local MARGIN_L = TacRP.C2.MARGIN_L
local COLOR_HOVER = TacRP.C2.COLOR_HOVER

local BUTTON_HEIGHT_EMPTY = TacRP.C2.BUTTON_HEIGHT_EMPTY
local BUTTON_HEIGHT = TacRP.C2.BUTTON_HEIGHT

local PANEL = {}
PANEL.Weapon = nil
PANEL.SlotIndex = nil
PANEL.SlotData = nil
PANEL.AttList = nil

function PANEL:GetAttachment()
	if not self.SlotData.Installed then
		return
	end
	return TacRP.Attachments[self.SlotData.Installed]
end

function PANEL:Paint( w, h )
	C2_Box( 0, 0, w, h )
	if self:IsHovered() then
		surface.SetDrawColor( COLOR_HOVER )
		C2_Gradient_Left( 0, 0, w, h )
	end

	C2_DrawText(
		self.SlotData.PrintName,
		"TacRP_STD_8",
		s(MARGIN_S), s(MARGIN_S),
		color_white
	)

	local att_data = self:GetAttachment()
	if not att_data then C2_Outline( 0, 0, w, h ) return true end

	C2_DrawText(
		TacRP:TryTranslate(att_data.PrintName),
		"TacRP_STD_12",
		s(MARGIN_S), h/2,
		color_white,
		nil, TEXT_ALIGN_CENTER
	)
	
	local size = h
	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( att_data.Icon )
	surface.DrawTexturedRect( w - size - s(MARGIN_S), h/2 - size/2, size, size )

	C2_Outline( 0, 0, w, h )
	return true
end

function PANEL:EvaluateSize()
	self:SetTall( self:GetAttachment() and s(BUTTON_HEIGHT) or s(BUTTON_HEIGHT_EMPTY) )
end

function PANEL:DoClick()
	if self.AttList.ActiveSlot == self.SlotIndex then
		self.AttList:Clear()
	else
		self.AttList:Populate( self.SlotData.Category, self.Weapon, self.SlotIndex )
	end
end

function PANEL:DoRightClick()
	if self.SlotData.Installed then
		self.Weapon:Detach( self.SlotIndex )
	end
end

function PANEL:Think()
	self:EvaluateSize()
end

vgui.Register("C2_SlotButton", PANEL, "DButton")