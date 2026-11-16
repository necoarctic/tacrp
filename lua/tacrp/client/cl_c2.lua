TacRP.C2 = {}

local hudscale = TacRP.ConVars["hudscale"]
function TacRP.C2.SS( height )
	return height * ( ScrH() / 480.0 ) * hudscale:GetFloat()
end

TacRP.C2.MARGIN_XS = 2
TacRP.C2.MARGIN_S = 4
TacRP.C2.MARGIN_M = 8
TacRP.C2.MARGIN_L = 12
TacRP.C2.MARGIN_XL = 16