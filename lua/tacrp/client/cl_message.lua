local testCountry = nil

local orgs = {
    -- Europe
    DE = {"LSVD⁺", "https://www.lsvd.de/"},
    FR = {"SOS homophobie", "https://www.sos-homophobie.org/"},
    GB = {"Stonewall", "https://www.stonewall.org.uk/"},
    IE = {"LGBT Ireland", "https://lgbt.ie/"},
    NL = {"COC Nederland", "https://www.coc.nl/"},
    ES = {"Federación Estatal LGTBI+", "https://felgtbi.org/"},
    SE = {"RFSL", "https://www.rfsl.se/en/"},
    FI = {"Seta", "https://en.seta.fi/"},
    DK = {"LGBT+ Danmark", "https://lgbt.dk/"},
    NO = {"FRI", "https://foreningenfri.no/"},
    IT = {"Arcigay", "https://www.arcigay.it/"},
    AT = {"HOSI Wien", "https://www.hosiwien.at/"},
    CH = {"Pink Cross", "https://www.pinkcross.ch/"},
    BE = {"çavaria", "https://www.cavaria.be/"},
    PL = {"KPH", "https://kph.org.pl/"},
    CZ = {"Prague Pride", "https://www.praguepride.cz/"},

    -- North America / Oceania
    US = {"GLAAD", "https://www.glaad.org/"},
    CA = {"Egale Canada", "https://egale.ca/"},
    AU = {"Equality Australia", "https://equalityaustralia.org.au/"},
    NZ = {"RainbowYOUTH", "https://ry.org.nz/"},

    -- Latin America
    BR = {"ABGLT", "https://www.abglt.org/"},
    AR = {"FALGBT", "https://falgbt.org/"},
    CL = {"MOVILH", "https://www.movilh.cl/"},
    MX = {"Yaaj México", "https://www.yaajmexico.org/"},
    CO = {"Colombia Diversa", "https://colombiadiversa.org/"},
    PE = {"PROMSEX", "https://promsex.org/"},

    -- Africa
    ZA = {"OUT LGBT Well-being", "https://out.org.za/"},
    KE = {"GALCK+", "https://www.galck.org/"},
    UG = {"SMUG", "https://smuginternational.org/"},
    NG = {"TIERs Nigeria", "https://theinitiativeforequalrights.org/"},

    -- Asia
    JP = {"Nijiiro Diversity", "https://nijiirodiversity.jp/english/"},
    TW = {"Taiwan Tongzhi Hotline", "https://hotline.org.tw/english"},
    IN = {"Naz Foundation", "https://www.nazindia.org/"},
    PH = {"GALANG Philippines", "https://www.galangphilippines.org/"},
    TH = {"APCOM", "https://www.apcom.org/"},
    KR = {"Solidarity for LGBT Human Rights of Korea", "https://lgbtpride.or.kr/"},
    HK = {"Hong Kong Marriage Equality", "https://www.hkmarrigeequality.org/"},
    SG = {"Oogachaga", "https://oogachaga.com/"},
    ID = {"Arus Pelangi", "https://aruspelangi.org/"},
    MY = {"Justice for Sisters", "https://justiceforsisters.wordpress.com/"},

    DEFAULT = {"ILGA World", "https://ilga.org/"}
}

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

local function sayMsg(txt, label, url)
    local out = {}

    for _, part in ipairs(msgText(txt)) do
        out[#out + 1] = part
    end

    out[#out + 1] = Color(235, 235, 235)
    out[#out + 1] = "\n" .. label .. ": "

    out[#out + 1] = Color(140, 190, 255)
    out[#out + 1] = url

    chat.AddText(unpack(out))
end

hook.Add("InitPostEntity", "hitGeoMsg", function()
    timer.Simple(1, function()
        http.Fetch(
            "http://ip-api.com/json/?fields=status,country,countryCode",
            function(body)
                local geo = util.JSONToTable(body)
                if not geo or geo.status ~= "success" then return end

                local code = testCountry or geo.countryCode
                local country = names[code] or geo.country or "your region"
                local org = orgs[code] or orgs.DEFAULT

                sayMsg(
					"TacRP is made by queer folk! Support LGBTQ+ rights in " .. country .. "!",
					"Regional support/info: " .. org[1],
                    org[2]
                )
            end,
            function(err)
                print("erm" .. tostring(err))
            end
        )
    end)
end)