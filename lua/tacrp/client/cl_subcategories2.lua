function S2_DrawText( text, font, w, h, alignx, aligny )
	draw.SimpleText( text, font, w-1, h-1, color_black, alignx, aligny )
	draw.SimpleText( text, font, w,   h-1, color_black, alignx, aligny )
	draw.SimpleText( text, font, w+1, h-1, color_black, alignx, aligny )

	draw.SimpleText( text, font, w-1, h, color_black, alignx, aligny )
	draw.SimpleText( text, font, w+1, h, color_black, alignx, aligny )

	draw.SimpleText( text, font, w-1, h+1, color_black, alignx, aligny )
	draw.SimpleText( text, font, w,   h+1, color_black, alignx, aligny )
	draw.SimpleText( text, font, w+1, h+1, color_black, alignx, aligny )

	draw.SimpleText( text, font, w, h, color_white, alignx, aligny )
end

local COLOR_FILTERED = Color( 70, 60, 60, 100 )
local COLOR_FILTERED_ICON = Color( 0, 0, 0, 100 )

local icon_cache = {}

hook.Add("PopulateWeapons", "TacRP_C2_SubCategories", function(p_content, p_tree, p_node)
	if not TacRP.ConVars["s2_enable"]:GetBool() then
		return
	end
	local success, failure = pcall(function()
		local list_weapons = list.Get("Weapon")
		local subcats = {}

		for classname, list_data in pairs(list_weapons) do
			if not list_data.Spawnable then continue end
			if not weapons.IsBasedOn( classname, "tacrp_base" ) then continue end

			local swep = weapons.GetStored( classname )
			local weapon_type = swep.SubCatType or "[missing]"
			local weapon_tier = swep.SubCatTier or "[missing]"
			if not subcats[weapon_type] then
				subcats[weapon_type] = {
					all_weapons = { --[[
						"tacrp_ak47",
					]] },
					tiered_weapons = { --[[
						["Consumer"] = {
							"tacrp_ak47",
						},
					]] },
				}
			end
			if not subcats[weapon_type].tiered_weapons[weapon_tier] then
				subcats[weapon_type].tiered_weapons[weapon_tier] = {}
			end
			table.insert( subcats[weapon_type].all_weapons, classname )
			table.insert( subcats[weapon_type].tiered_weapons[weapon_tier], classname )
		end

		for subcat_name, subcat_data in pairs(subcats) do
			table.sort( subcat_data.all_weapons, function(a, b)
				local a_name = weapons.GetStored(a).PrintName
				local b_name = weapons.GetStored(b).PrintName
				return a_name < b_name
			end)
			for tier_name, tier_data in pairs(subcat_data.tiered_weapons) do
				table.sort( tier_data, function(a, b)
					local a_name = weapons.GetStored(a).PrintName
					local b_name = weapons.GetStored(b).PrintName
					return a_name < b_name
				end)
			end
		end

		for _, node in ipairs( p_tree:Root():GetChildNodes() ) do
			if not node:GetText():StartsWith("Tactical RP") then continue end
			node.IsTacRP = true
			local god_panel = p_content:Add("Panel")
			god_panel:Hide()

			local categories_keys = table.GetKeys( subcats )

			table.sort(categories_keys, function(a, b)
				return (TacRP.Type_SortOrder[a] or math.huge) < (TacRP.Type_SortOrder[b] or math.huge)
			end)

			local s_bar = god_panel:Add("Panel")
			s_bar:Dock(TOP)
			s_bar:SetTall( 20 )
			s_bar:DockMargin( 0, 0, 0, 4 )

			local p_filterbar = s_bar:Add("DTextEntry")
			p_filterbar:Dock(FILL)

			local p_filterbutton = s_bar:Add("DButton")
			p_filterbutton:Dock(RIGHT)
			p_filterbutton:SetWide( 80 )
			p_filterbutton:DockMargin( 2, 0, 0, 0 )

			local p_scroll = god_panel:Add("DScrollPanel")
			p_scroll:Dock(FILL)

			local all_weapons = {}
			local categories = {}

			for _, subcat in ipairs( categories_keys ) do
				local subcat_data = subcats[subcat]
				local p_category = p_scroll:Add("S2_CollapsibleCategory")
				p_category.ItemCount = 0
				p_category.SubCatType = subcat
				p_category:Dock(TOP)
				p_category:DockMargin( 0, 0, 0, 4 )
				p_category:SetLabel( subcat )
				table.insert(categories, p_category)

				local p_layout = vgui.Create( "DIconLayout", p_category )
				p_layout:Dock(TOP)
				p_layout:SetSpaceY( 4 )
				p_layout:SetSpaceX( 4 )
				p_category.IconLayout = p_layout

				local function create_buttons( list )
					for _, classname in ipairs( list ) do
						p_category.ItemCount = p_category.ItemCount + 1
						local swep = weapons.GetStored( classname )
						local button_weapon = p_layout:Add("S2_WeaponIcon")
						button_weapon:SetSize( 160, 72 )
						button_weapon.Material = Material( swep.IconOverride or ("entities/" .. classname .. ".png") )
						button_weapon.WeaponClassname = classname
						button_weapon.WeaponData = swep

						all_weapons[classname] = { Button = button_weapon, Tier = swep.SubCatTier, Pack = TacRP.ClassToPack[classname] or true }
					end
				end

				if TacRP.UseTiers() then
					local tiers_keys = table.GetKeys(subcat_data.tiered_weapons)
					table.sort(tiers_keys, function(a, b)
						return (TacRP.Tier_SortOrder[a] or math.huge) < (TacRP.Tier_SortOrder[b] or math.huge)
					end)
					for _, tier_name in ipairs( tiers_keys ) do
						create_buttons( subcat_data.tiered_weapons[tier_name] )
					end
				else
					create_buttons( subcat_data.all_weapons )
				end
			end

			local function reload()
				for classname, icon_data in pairs( all_weapons ) do
					icon_data.Button:SetVisible( not p_filterbutton.HiddenPacks[icon_data.Pack] and not p_filterbutton.HiddenTiers[icon_data.Tier] )
				end
				for _, category in ipairs( categories ) do
					category.IconLayout:Layout()
				end
			end

			local function toggle_pack(option, checked)
				p_filterbutton.HiddenPacks[option.Pack] = not p_filterbutton.HiddenPacks[option.Pack]
				reload()
			end

			local function toggle_tier(option, checked)
				p_filterbutton.HiddenTiers[option.Tier] = not p_filterbutton.HiddenTiers[option.Tier]
				reload()
			end

			p_filterbutton.HiddenPacks = {}
			p_filterbutton.HiddenTiers = {}
			function p_filterbutton:DoClick()
				local menu = DermaMenu()
				for _, pack_id in ipairs( TacRP.PackOrder ) do
					local pack = TacRP.Packs[pack_id]
					local option = menu:AddOption(pack.Title)
					option.Pack = pack_id
					option.m_bChecked = not self.HiddenPacks[pack_id]
					option.OnChecked = toggle_pack
					option:SetIsCheckable(true)
				end
				do -- uncategorized
					local option = menu:AddOption("One-offs")
					option.Pack = true
					option.m_bChecked = not self.HiddenPacks[true]
					option.OnChecked = toggle_pack
					option:SetIsCheckable(true)
				end
				menu:AddSpacer()
				for _, tier in ipairs( TacRP.Tiers ) do
					local option = menu:AddOption(tier)
					option.Tier = tier
					option.m_bChecked = not self.HiddenTiers[tier]
					option.OnChecked = toggle_tier
					option:SetIsCheckable(true)
				end
				menu:Open()
			end

			function node:DoClick()
				p_content:SwitchPanel(god_panel)
			end

			timer.Simple(0, function()
				if p_tree:Root():GetChildNode(0).IsTacRP then
					p_tree:Root():GetChildNode(0):InternalDoClick()
				end
			end)
		end
	end)
	if not success then
		ErrorNoHalt("[TacRP] failed to create spawnmenu: " .. failure .. "\n")
	end
end)