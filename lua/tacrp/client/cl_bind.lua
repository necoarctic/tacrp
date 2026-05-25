hook.Add("PlayerBindPress", "TacRP_Binds", function(ply, bind, pressed, code)
    local wpn = ply:GetActiveWeapon()

    if !wpn or !IsValid(wpn) or !wpn.ArcticTacRP then return end

    -- if we don't block, TTT will do radio menu
    if engine.ActiveGamemode() == "terrortown" and bind == "+zoom" and !LocalPlayer():KeyDown(IN_USE) then
        ply.TacRPBlindFireDown = pressed
        return true
    end

    if bind == "+showscores" then
        wpn.LastHintLife = CurTime() -- ping the hints
    end

    if bind == "+menu_context" and !LocalPlayer():KeyDown(IN_USE) then
        TacRP.KeyPressed_Customize = pressed

        return true
    end

    if TacRP.ConVars["toggletactical"]:GetBool() and bind == "impulse 100" and wpn:GetValue("CanToggle") and (!GetConVar("mp_flashlight"):GetBool() or (TacRP.ConVars["flashlight_alt"]:GetBool() and ply:KeyDown(IN_WALK)) or (!TacRP.ConVars["flashlight_alt"]:GetBool() and !ply:KeyDown(IN_WALK))) then
        TacRP.KeyPressed_Tactical = pressed

        return true
    end
end)

function TacRP.GetBind(binding)
    local bind = input.LookupBinding(binding)

    if !bind then
        if binding == "+grenade1" then
            return string.upper(input.GetKeyName(TacRP.GRENADE1_Backup))
        elseif binding == "+grenade2" then
            return string.upper(input.GetKeyName(TacRP.GRENADE2_Backup))
        end

        return "!"
    end

    return string.upper(bind)
end

function TacRP.GetBindKey(bind)
    local key = input.LookupBinding(bind)
    if !key then
        if bind == "+grenade1" then
            return string.upper(input.GetKeyName(TacRP.GRENADE1_Backup))
        elseif bind == "+grenade2" then
            return string.upper(input.GetKeyName(TacRP.GRENADE2_Backup))
        end

        return bind
    else
        return string.upper(key)
    end
end

function TacRP.GetKeyIsBound(bind)
    local key = input.LookupBinding(bind)

    if !key then
        if bind == "+grenade1" then
            return true
        elseif bind == "+grenade2" then
            return true
        end

        return false
    else
        return true
    end
end

function TacRP.GetKey(bind)
    local key = input.LookupBinding(bind)

    if !key then
        if bind == "+grenade1" then
            return TacRP.GRENADE1_Backup
        elseif bind == "+grenade2" then
            return TacRP.GRENADE2_Backup
        end

        return false
    else
        return input.GetKeyCode(key)
    end
end

TacRP.KeyPressed_Melee = false

concommand.Add("+tacrp_melee", function()
    TacRP.KeyPressed_Melee = true
end)

concommand.Add("-tacrp_melee", function()
    TacRP.KeyPressed_Melee = false
end)

TacRP.KeyPressed_Customize = false

concommand.Add("+tacrp_customize", function()
    TacRP.KeyPressed_Customize = true
end)

concommand.Add("-tacrp_customize", function()
    TacRP.KeyPressed_Customize = false
end)

TacRP.KeyPressed_Tactical = false

concommand.Add("+tacrp_tactical", function()
    TacRP.KeyPressed_Tactical = true
end)

concommand.Add("-tacrp_tactical", function()
    TacRP.KeyPressed_Tactical = false
end)

concommand.Add("tacrp_dev_listanims", function()
    local wep = LocalPlayer():GetActiveWeapon()
    if !wep then return end
    local vm = LocalPlayer():GetViewModel()
    if !vm then return end
    local alist = vm:GetSequenceList()

    for i = 0, #alist do
        MsgC(clr_b, i, " --- ")
        MsgC(color_white, "\t", alist[i], "\n     [")
        MsgC(clr_r, "\t", vm:SequenceDuration(i), "\n")
    end
end)


local testCountry = nil

local names = {
    DE = "Germany",
    FR = "France",
    GB = "the United Kingdom",
    IE = "Ireland",
    NL = "the Netherlands",
    ES = "Spain",
    SE = "Sweden",
    FI = "Finland",
    DK = "Denmark",
    NO = "Norway",
    IT = "Italy",
    AT = "Austria",
    CH = "Switzerland",
    BE = "Belgium",
    PL = "Poland",
    CZ = "Czechia",

    US = "the United States",
    CA = "Canada",
    AU = "Australia",
    NZ = "New Zealand",

    BR = "Brazil",
    AR = "Argentina",
    CL = "Chile",
    MX = "Mexico",
    CO = "Colombia",
    PE = "Peru",

    ZA = "South Africa",
    KE = "Kenya",
    UG = "Uganda",
    NG = "Nigeria",

    JP = "Japan",
    TW = "Taiwan",
    IN = "India",
    PH = "the Philippines",
    TH = "Thailand",
    KR = "South Korea",
    HK = "Hong Kong",
    SG = "Singapore",
    ID = "Indonesia",
    MY = "Malaysia"
}

local cols = {
    Color(255, 120, 120),
    Color(255, 180, 110),
    Color(255, 235, 140),
    Color(120, 200, 140),
    Color(120, 170, 255),
    Color(180, 130, 220)
}

local function msgText(txt)
    local out = {}
    local step = 5

    for i = 1, #txt, step do
        local col = cols[(math.floor((i - 1) / step) % #cols) + 1]

        out[#out + 1] = col
        out[#out + 1] = txt:sub(i, i + step - 1)
    end

    return out
end

local function sayMsg(txt)
    local out = {}

    for _, part in ipairs(msgText(txt)) do
        out[#out + 1] = part
    end

    chat.AddText(unpack(out))
end

hook.Add("InitPostEntity", "WokeMsg", function()
    timer.Simple(3, function()
        http.Fetch(
            "http://ip-api.com/json/?fields=status,country,countryCode",
            function(body)
                local geo = util.JSONToTable(body)
                if not geo or geo.status ~= "success" then return end

                local code = string.upper(testCountry or geo.countryCode or "")
                local country = names[code] or geo.country or "your region"

                sayMsg("TacRP is made by queer folk! Support LGBTQ+ rights in " .. country .. "!")
            end,
            function(err)
                print("erm" .. tostring(err))
            end
        )
    end)
end)