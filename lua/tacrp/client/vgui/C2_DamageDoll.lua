local s = TacRP.SS
local MARGIN_XS = TacRP.C2.MARGIN_XS
local MARGIN_S = TacRP.C2.MARGIN_S
local MARGIN_M = TacRP.C2.MARGIN_M
local MARGIN_L = TacRP.C2.MARGIN_L

local armor = Material("tacrp/hud/armor.png", "mip smooth")
local body = Material("tacrp/hud/body.png", "mips smooth")
local body_head = Material("tacrp/hud/body_head.png", "mips smooth")
local body_chest = Material("tacrp/hud/body_chest.png", "mips smooth")
local body_stomach = Material("tacrp/hud/body_stomach.png", "mips smooth")
local body_arms = Material("tacrp/hud/body_arms.png", "mips smooth")
local body_legs = Material("tacrp/hud/body_legs.png", "mips smooth")

local stk_clr = {
	HSVToColor( 345, 1, 1 ),
	HSVToColor( 10, .7, .9 ),
	HSVToColor( 15, .55, .7 ),
	HSVToColor( 15, .3, .6 ),
	HSVToColor( 0, 0, .5 ),
	HSVToColor( 0, 0, .4 ),
	HSVToColor( 0, 0, .3 ),
	HSVToColor( 0, 0, .2 ),
	HSVToColor( 0, 0, .1 ),
	HSVToColor( 0, 0, 0 ),
}

local stk_clr_amr = {
	HSVToColor( 260, 1, 1 ),
	HSVToColor( 225, .75, .9 ),
	HSVToColor( 215, .55, .7 ),
	HSVToColor( 215, .3, .6 ),
	HSVToColor( 0, 0, .5 ),
	HSVToColor( 0, 0, .4 ),
	HSVToColor( 0, 0, .3 ),
	HSVToColor( 0, 0, .2 ),
	HSVToColor( 0, 0, .1 ),
	HSVToColor( 0, 0, 0 ),
}

local function get_dmgtext_and_setcolor(dmg, num, mult, hover, armor)
    local stk = math.ceil(100 / (dmg * mult))
    local clrlist = armor and stk_clr_amr or stk_clr
    local c = clrlist[math.min(num > 1 and math.ceil(stk / num) or stk, #clrlist)]
    surface.SetDrawColor(c.r, c.g, c.b, 255)
	
    if hover then
        return stk .. "x" --TacRP:GetPhrase(num > 1 and "unit.ptk" or "unit.stk")
    else
        return math.floor(dmg * mult) --  .. (num > 1 and ("×" .. num) or "")
    end
end

local PANEL = {}
function PANEL:Init()
	local button = self:Add("DButton")
	button:SetSize( s(8), s(8) )
	button:AlignTop( s(MARGIN_XS) )
	button:AlignLeft( s(MARGIN_XS) )

	function button:Paint( w, h )
		local v = 200
		if self:GetParent().EnableArmor then v = v + 30 end
		if self:IsHovered() then v = v + 25 end
		surface.SetDrawColor( v, v, v )
		surface.SetMaterial( armor )
		surface.DrawTexturedRect( 0, 0, w, h )
		return true
	end

	function button:DoClick()
		local parent = self:GetParent()
		parent.EnableArmor = not parent.EnableArmor
	end
end

function PANEL:Paint( w, h )
	local wep = self.Weapon
	C2_Box( 0, 0, w, h )

	local w2 = h*(136/370)
	local h2 = h - s(MARGIN_S*2)
	local x2 = s(5)
	local y2 = s(MARGIN_S)
	
	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial(body)
	surface.DrawTexturedRect(x2, y2, w2, h2)

	local dmg = wep:GetDamageAtRange(self.Range or 0, true) + wep:GetValue("ExplosiveDamage")
	local armor = self.EnableArmor
	if armor then
		dmg = dmg * math.Clamp(wep:GetValue("ArmorPenetration"), 0, 1)
	end
	local num = wep:GetValue("Num")
	local mult = wep:GetBodyDamageMultipliers()
	local hovered = self:IsHovered()

	C2_DrawText(
		TacRP:GetPhrase( hovered and (num > 1 and "unit.ptk" or "unit.stk") or "unit.damage" ),
		"TacRP_STD_6",
		w - s(MARGIN_XS),
		s(MARGIN_XS),
		color_white,
		TEXT_ALIGN_RIGHT
	)

	do -- body
		local txt
		
		-- head
		txt = get_dmgtext_and_setcolor( dmg, num, mult[HITGROUP_HEAD], hovered, armor )
		surface.SetMaterial(body_head)
		surface.DrawTexturedRect(x2, y2, w2, h2)
		C2_DrawText(
			txt,
			"TacRP_STD_8",
			x2 + w2 * 0.42,
			y2 + h2 * 0.07,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
		
		-- chest
		txt = get_dmgtext_and_setcolor( dmg, num, mult[HITGROUP_CHEST], hovered, armor )
		surface.SetMaterial(body_chest)
		surface.DrawTexturedRect(x2, y2, w2, h2)
		C2_DrawText(
			txt,
			"TacRP_STD_8",
			x2 + w2 * 0.40,
			y2 + h2 * 0.22,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)

		-- stomach
		txt = get_dmgtext_and_setcolor( dmg, num, mult[HITGROUP_STOMACH], hovered, armor )
		surface.SetMaterial(body_stomach)
		surface.DrawTexturedRect(x2, y2, w2, h2)
		C2_DrawText(
			txt,
			"TacRP_STD_8",
			x2 + w2 * 0.44,
			y2 + h2 * 0.41,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)

		-- legs
		txt = get_dmgtext_and_setcolor( dmg, num, mult[HITGROUP_LEFTLEG], hovered, armor )
		surface.SetMaterial(body_legs)
		surface.DrawTexturedRect(x2, y2, w2, h2)
		C2_DrawText(
			txt,
			"TacRP_STD_8",
			x2 + w2 * 0.41,
			y2 + h2 * 0.7,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)

		-- arms
		txt = get_dmgtext_and_setcolor( dmg, num, mult[HITGROUP_LEFTARM], hovered, armor )
		surface.SetMaterial(body_arms)
		surface.DrawTexturedRect(x2, y2, w2, h2)
		C2_DrawText(
			txt,
			"TacRP_STD_8",
			x2 + w2 * 0.06,
			y2 + h2 * 0.35,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
	end

	local size = math.ceil(s(6))
	local x = w - s(MARGIN_XS) - size
	local y = h - s(MARGIN_XS) - size
	for i=1, 9 do
		surface.SetDrawColor( (armor and stk_clr_amr or stk_clr)[i] )
		surface.DrawRect( x, y, size, size )
		C2_DrawText(
			i,
			"TacRP_STD_6",
			x + size/2,
			y,
			color_white,
			TEXT_ALIGN_CENTER
		)
		y = y - size
	end

	C2_Outline( 0, 0, w, h )
	return true
end

vgui.Register("C2_DamageDoll", PANEL, "Panel")