local s = TacRP.SS
local MARGIN_XS = TacRP.C2.MARGIN_XS
local MARGIN_S = TacRP.C2.MARGIN_S
local MARGIN_M = TacRP.C2.MARGIN_M
local MARGIN_L = TacRP.C2.MARGIN_L
local MARGIN_XL = TacRP.C2.MARGIN_XL
local COLOR_HOVER = TacRP.C2.COLOR_HOVER

local PANEL = {}
PANEL.AttachmentName = nil
PANEL.AttachmentData = nil
PANEL.Weapon = nil
PANEL.SlotIndex = nil

function PANEL:SetupTarget()
	self.TargetID = "attachment_" .. self.AttachmentName
	local adata = self.AttachmentData
	local tdata = {
		{
			Text = TacRP:TryTranslate(adata.FullName or adata.PrintName),
			Big = true,
		},
		{
			Text = TacRP:TryTranslate(adata.Description),
		}
	}
	if adata.Pros then
		for _, text in ipairs(adata.Pros) do
			table.insert( tdata, {
				Text = "+ " .. TacRP:TryTranslate( text ),
			})
		end
	end
	if adata.Cons then
		for _, text in ipairs(adata.Cons) do
			table.insert( tdata, {
				Text = "- " .. TacRP:TryTranslate( text ),
			})
		end
	end
	self.TargetData = tdata
end

function PANEL:Paint( w, h )
	C2_Box( 0, 0, w, h )
	if self:IsHovered() then
		surface.SetDrawColor( COLOR_HOVER )
		C2_Gradient_Left( 0, 0, w, h )
	end

	local margin = s(MARGIN_S)
	local data = self.AttachmentData
	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( data.Icon )
	surface.DrawTexturedRect( margin, 0, h, h )

	C2_DrawText(
		TacRP:TryTranslate(data.PrintName),
		"TacRP_STD_12",
		margin + h + margin, h/2,
		color_white,
		nil, TEXT_ALIGN_CENTER
	)

	C2_Outline( 0, 0, w, h )
	return true
end

function PANEL:DoClick()
	if self.Weapon.Attachments[ self.SlotIndex ].Installed == self.AttachmentName then
		self.Weapon:Detach( self.SlotIndex )
		return
	end
	self.Weapon:Detach( self.SlotIndex, true )
	self.Weapon:Attach( self.SlotIndex, self.AttachmentName )
end

function PANEL:DoRightClick()
	if self.Weapon.Attachments[ self.SlotIndex ].Installed == self.AttachmentName then
		self.Weapon:Detach( self.SlotIndex )
	end
end

vgui.Register("C2_AttachmentButton", PANEL, "DButton")