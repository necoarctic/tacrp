local tier_to_color = {
	["Value"]			= Color( 109, 101, 101 ),
	["Consumer"]		= Color( 99, 143, 188 ),
	["Security"]		= Color( 144, 95, 223 ),
	["Operator"]		= Color( 220, 107, 157 ),
	["Elite"]			= Color( 255, 77, 77 ),
	["Special"]			= Color( 155, 126, 110 ),
	["Exotic"]			= Color( 202, 171, 5 ),
}

local COLOR_HOVER = TacRP.C2.COLOR_HOVER
local COLOR_UNTIERED = Color( 100, 100, 100 )

local grad_down = Material( "vgui/gradient-d" )
local grad_left = Material( "vgui/gradient-l" )

local PANEL = {}

function PANEL:OpenGenericSpawnmenuRightClickMenu()
	local spawnName = self.WeaponClassname--self:GetSpawnName()

	local menu = DermaMenu()

	if (spawnName and spawnName != "") then
		menu:AddOption("#spawnmenu.menu.copy", function()
			SetClipboardText(spawnName)
		end):SetIcon("icon16/page_copy.png")
	end

	if (isfunction(self.OpenMenuExtra)) then
		self:OpenMenuExtra(menu)
	end

	menu:Open()
end

function PANEL:Paint( w, h )
	local size = w

	surface.SetDrawColor( TacRP.UseTiers() and tier_to_color[self.WeaponData.SubCatTier] or COLOR_UNTIERED )
	surface.SetMaterial( grad_down )
	surface.DrawTexturedRect( 0, 0, w, h )
	
	if self:IsHovered() then
		surface.SetDrawColor( COLOR_HOVER )
		surface.SetMaterial( grad_left )
		surface.DrawTexturedRect( 0, 0, w, h )
	end

	surface.SetDrawColor( color_white )
	surface.SetMaterial( self.Material )
	surface.DrawTexturedRect( w/2 - size/2, h/2 - size/2, size, size )

	surface.SetFont( "TacRP_STD_16XI" )
	local name = TacRP.GetPhrase("wep."..self.WeaponClassname..".name.full") or self.WeaponData.FullName
	if not name or (2+surface.GetTextSize(name)) > w then
		name = TacRP.GetPhrase("wep."..self.WeaponClassname..".name") or self.WeaponData.PrintName
	end
	local text_width = surface.GetTextSize(name)

	local height = 16
	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.DrawRect( 0, h-height, text_width + 2+2+2, height )

	surface.SetTextColor( color_white )
	S2_DrawText(
		name,
		"TacRP_STD_16XI",
		2,
		h-height,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_TOP
	)

	return true
end

function PANEL:DoClick()
	RunConsoleCommand( "gm_giveswep", self.WeaponClassname )
end

function PANEL:DoMiddleClick()
	RunConsoleCommand( "gm_spawnswep", self.WeaponClassname )
end

function PANEL:DoRightClick()
	self:OpenGenericSpawnmenuRightClickMenu()
end

vgui.Register("S2_WeaponIcon", PANEL, "DButton")