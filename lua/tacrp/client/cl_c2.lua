TacRP.C2 = TacRP.C2 or {}

TacRP.C2.MARGIN_XS = 2
TacRP.C2.MARGIN_S = 4
TacRP.C2.MARGIN_M = 8
TacRP.C2.MARGIN_L = 12
TacRP.C2.BUTTON_HEIGHT_EMPTY = 16
TacRP.C2.BUTTON_HEIGHT = 32

TacRP.C2.COLOR_BACKGROUND = Color( 0, 0, 0, 220 )
TacRP.C2.COLOR_HOVER = Color( 255, 255, 255, 100 )
TacRP.C2.COLOR_OLD = Color( 200, 200, 200 )
TacRP.C2.COLOR_POSITIVE = Color( 120, 255, 120 )
TacRP.C2.COLOR_NEGATIVE = Color( 255, 200, 200 )
TacRP.C2.COLOR_OUTLINE = color_white

function TacRP.C2.GetTargetDataForAttachment( adata )
	local tdata = {
		{
			Text = TacRP:TryTranslate( adata.FullName or adata.PrintName ),
			Big = true,
		},
		{
			Text = TacRP:TryTranslate( adata.Description ),
		}
	}
	if adata.Pros then
		for _, text in ipairs(adata.Pros) do
			table.insert( tdata, {
				Text = TacRP:TryTranslate( text ),
				Stat_Pro = true,
			})
		end
	end
	if adata.Cons then
		for _, text in ipairs(adata.Cons) do
			table.insert( tdata, {
				Text = TacRP:TryTranslate( text ),
				Stat_Con = true,
			})
		end
	end
	return tdata
end