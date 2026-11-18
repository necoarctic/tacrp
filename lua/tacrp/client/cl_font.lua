local hudscale = TacRP.ConVars["hudscale"]
local hudscale_simres = TacRP.ConVars["hudscale_simres"]
function TacRP.SS(i)
    local res = hudscale_simres:GetInt()
    if res == 0 then
        res = ScrH()
    end
    return (res / 360) * i * hudscale:GetFloat()
end
local function real_holoss()
    return (ScrH() / 480) / 2
end
TacRP.HoloSS = real_holoss()

local fonts_to_make = {
    ["STD"] = {
        convar = "font1",
        default = "Myriad Pro",
        sizes = {
            32,
            24,
            14,
            12,
            10,
            8,
            6,
            -- Newsletter
            20,
        },
        sizes_italic = {
            12,
            10,
        },
        sizes_glow = {
            -- Newsletter
            8,
        },
        sizes_unscaled = {
            -- Spawnmenu
            24,
            16,
            12,
        },
        sizes_unscaled_italic = {
            -- Spawnmenu
            32,
            20,
        }
    },
    ["LCD"] = {
        convar = "font2",
        default = "HD44780A00 5x8",
        sizes = {
            12,
            -- Newsletter
            4,
        },
        sizes_italic = {},
        sizes_glow = {},
        sizes_unscaled = {},
        sizes_unscaled_italic = {},
    },
    -- Remove these following fonts eventually
    ["Myriad_Pro"] = {
        -- default = "Comic Sans MS",
        default = "Myriad Pro",
        convar = "font1",
        old_suffix = true,
        sizes = {
            4,
            5,
            6,
            8,
            10,
            11,
            12,
            14,
            16,
            20,
            32,
            36,
        },
        sizes_italic = {
            6,
            8,
            12,
        },
        sizes_glow = {},
        sizes_unscaled = {
            24,
            32,
            48
        },
        sizes_unscaled_italic = {},
    },
    ["HD44780A00_5x8"] = {
        -- default = "Comic Sans MS",
        default = "HD44780A00 5x8",
        convar = "font2",
        old_suffix = true,
        sizes = {
            4,
            5,
            6,
            8,
            10,
            11,
            12,
            14,
            16,
            20,
            32,
            36,
        },
        sizes_italic = {
            6,
            8,
            12,
        },
        sizes_glow = {},
        sizes_unscaled = {
            24,
            32,
            48
        },
        sizes_unscaled_italic = {},
    },
}

local function generatefonts()
    for fontname, def in pairs(fonts_to_make) do
        local old = def.old_suffix
        local selected_font = def.default
        if def.convar then
            local choice = TacRP.ConVars[def.convar]:GetString()
            if choice ~= "" then
                selected_font = cvar_choice
            end
        end
        for _, size in ipairs(def.sizes) do
            surface.CreateFont("TacRP_" .. fontname .. "_" .. tostring(size), {
                font = selected_font,
                size = TacRP.SS(size),
                weight = 0,
                antialias = true,
                extended = true,
            } )
        end
        for _, size in ipairs(def.sizes_italic) do
            surface.CreateFont("TacRP_" .. fontname .. "_" .. tostring(size) .. (old and "_Italic" or "I"), {
                font = selected_font,
                size = TacRP.SS(size),
                weight = 0,
                antialias = true,
                extended = true,
                italic = true,
            } )
        end
        for _, size in ipairs(def.sizes_glow) do
            surface.CreateFont("TacRP_" .. fontname .. "_" .. tostring(size) .. (old and "_Glow" or "G"), {
                font = selected_font,
                size = TacRP.SS(size),
                weight = 0,
                antialias = true,
                extended = true,
                blursize = 6,
            } )
        end
        for _, size in ipairs(def.sizes_unscaled) do
            surface.CreateFont("TacRP_" .. fontname .. "_" .. tostring(size) .. (old and "_Unscaled" or "X"), {
                font = selected_font,
                size = size,
                weight = 0,
                antialias = true,
                extended = true,
            } )
        end
        for _, size in ipairs(def.sizes_unscaled_italic) do
            surface.CreateFont("TacRP_" .. fontname .. "_" .. tostring(size) .. "XI", {
                font = selected_font,
                size = size,
                weight = 0,
                antialias = true,
                extended = true,
                italic = true,
            } )
        end
    end

end

generatefonts()

function TacRP.Regen()
    generatefonts()
end

hook.Add( "OnScreenSizeChanged", "TacRP.Regen", TacRP.Regen )
hook.Add( "OnScreenSizeChanged", "TacRP.RegenHolo", function()
    TacRP.HoloSS = real_holoss()
end )
cvars.AddChangeCallback( "tacrp_hudscale", TacRP.Regen, "tacrp_hudscale" )
cvars.AddChangeCallback( "tacrp_hudscale_simres", TacRP.Regen, "tacrp_hudscale" )
cvars.AddChangeCallback( "tacrp_font1", TacRP.Regen, "TacRP_Change_Font1" )
cvars.AddChangeCallback( "tacrp_font2", TacRP.Regen, "TacRP_Change_Font2" )

function TacRP.MultiLineText(text, maxw, font)
    local content = {}
    local tline = ""
    local x = 0
    surface.SetFont(font)

    local ts = surface.GetTextSize(" ")

    local newlined = string.Split(text, "\n")

    for _, line in ipairs(newlined) do
        local words = string.Split(line, " ")

        for _, word in ipairs(words) do
            local tx = surface.GetTextSize(word)

            if x + tx > maxw then
                local dashi = string.find(word, "-")
                if dashi and surface.GetTextSize(utf8.sub(word, 0, dashi)) <= maxw - x then
                    -- cut the word at the dash sign if possible
                    table.insert(content, tline .. utf8.sub(word, 0, dashi))
                    tline = ""
                    x = 0
                    word = utf8.sub(word, dashi + 1)
                    tx = surface.GetTextSize(word)
                else
                    -- move whole word to new line
                    table.insert(content, tline)
                    tline = ""
                    x = 0

                -- else
                --     -- cut the word down from the middle
                --     while x + tx > maxw do
                --         local cut = ""
                --         for i = 2, utf8.len(word) do
                --             cut = utf8.sub(word, 0, -i)
                --             tx = surface.GetTextSize(cut)
                --             if x + tx < maxw then
                --                 table.insert(content, tline .. cut)
                --                 tline = ""
                --                 word = utf8.sub(word, utf8.len(word) - i + 2)
                --                 x = 0
                --                 tx = surface.GetTextSize(word)
                --                 break
                --             end
                --         end
                --     end
                end
            end

            tline = tline .. word .. " "

            x = x + tx + ts
        end

        table.insert(content, tline)
        tline = ""
        x = 0
    end

    return content
end