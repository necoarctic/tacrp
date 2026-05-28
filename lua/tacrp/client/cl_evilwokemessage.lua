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

hook.Add("InitPostEntity", "woketacrpmessage", function()
    timer.Simple(3, function(body)
				sayMsg("TacRP is made by queer folk! Support LGBTQ+ rights worldwide!")
            end
        )
end)