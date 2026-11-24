function TacRP.GetMoveVector(mv)
    local ang = mv:GetAngles()

    local max_speed = mv:GetMaxSpeed()

    local forward = math.Clamp(mv:GetForwardSpeed(), -max_speed, max_speed)
    local side = math.Clamp(mv:GetSideSpeed(), -max_speed, max_speed)

    local abs_xy_move = math.abs(forward) + math.abs(side)

    if abs_xy_move == 0 then
        return Vector(0, 0, 0)
    end

    local mul = max_speed / abs_xy_move

    local vec = Vector()

    vec:Add(ang:Forward() * forward)
    vec:Add(ang:Right() * side)

    vec:Mul(mul)

    return vec
end

function TacRP.GetCmdVector(cmd, defaultforward)
    local ang = Angle(0, cmd:GetViewAngles().y, 0)

    local forward = cmd:GetForwardMove() / 10000
    local side = cmd:GetSideMove() / 10000

    local abs_xy_move = math.abs(forward) + math.abs(side)
    if abs_xy_move == 0 then
        if defaultforward then
            forward = 1
        else
            return Vector()
        end
    end
    local div = (forward ^ 2 + side ^ 2) ^ 0.5

    local vec = Vector()
    vec:Add(ang:Forward() * forward / div)
    vec:Add(ang:Right() * side / div)

    return vec
end

function TacRP.CancelBodyDamage(ent, dmginfo, hitgroup)
    local tbl = TacRP.CancelMultipliers[string.lower(engine.ActiveGamemode())] or TacRP.CancelMultipliers[1]

    if IsValid(ent) and (ent:IsNPC() or ent:IsPlayer()) and TacRP.ConVars["bodydamagecancel"]:GetBool() then
        dmginfo:ScaleDamage(1 / (tbl[hitgroup] or 1))
    end

    -- Lambda Players call ScalePlayerDamage and cancel out hitgroup damage... except on the head
    if IsValid(ent) and ent.IsLambdaPlayer and hitgroup == HITGROUP_HEAD then
        dmginfo:ScaleDamage(1 / (tbl[hitgroup] or 1))
    end

    return dmginfo
end

function TacRP.EntityIsNecrotic(ent)
    if ent:IsNPC() and ent:Classify() == CLASS_ZOMBIE then return true end
    if ent.VJ_NPC_Class == "CLASS_ZOMBIE" or (istable(ent.VJ_NPC_Class) and table.HasValue(ent.VJ_NPC_Class,  "CLASS_ZOMBIE")) then return true end
    local ret = hook.Run("TacRP_EntityIsNecrotic", ent)
    if ret != nil then return ret end
    return false
end

function TacRP.FormatTierType(wtype, wtier, use_tiers)
    if wtype then
        local type_txt = TacRP:TryTranslate(wtype)
        if use_tiers and wtier and wtier != "9Special" then
            type_txt = TacRP:GetPhrase("cust.type_tier", {
                tier = TacRP:TryTranslate(wtier), type = type_txt
            })
        end
        return type_txt
    end
    return "Weapon"
end


TacRP.WeaponListCache = {}
function TacRP.GetWeaponList(subcat, tier)
    if !subcat then subcat = "" end
    if !tier then tier = "" end
    if !TacRP.WeaponListCache[subcat] or !TacRP.WeaponListCache[subcat][tier] then
        TacRP.WeaponListCache[subcat] = TacRP.WeaponListCache[subcat] or {}
        TacRP.WeaponListCache[subcat][tier] = {}

        for i, wep in pairs(weapons.GetList()) do
            local weap = weapons.Get(wep.ClassName)
            if !weap or !weap.ArcticTacRP
                    or wep.ClassName == "tacrp_base" or wep.ClassName == "tacrp_base_nade" or wep.ClassName == "tacrp_base_melee"
                    or !weap.Spawnable or weap.AdminOnly
                    or (subcat == "npc" and !weap.NPCUsable)
                    or (subcat != "" and subcat != "npc" and subcat != weap.SubCatType)
                    or (tier != "" and tier != weap.SubCatTier) then
                continue
            end

            table.insert(TacRP.WeaponListCache[subcat][tier], wep.ClassName)
        end
    end
    return TacRP.WeaponListCache[subcat][tier]
end

function TacRP.GetRandomWeapon(subcat, tier)
    if !subcat then subcat = "" end
    if !tier then tier = "" end

    local tbl = TacRP.GetWeaponList(subcat, tier)
    return tbl[math.random(1, #tbl)]
end

function TacRP.Developer(i)
    return (SERVER or (CLIENT and IsValid(LocalPlayer()) and LocalPlayer():IsSuperAdmin())) and GetConVar("developer"):GetInt() >= (i or 1)
end

TacRP.Type_Fix = {
    ["1Pistol"]         = "Pistol",
    ["2Magnum Pistol"]  = "Magnum Pistol",
    ["3Akimbo"]         = "Akimbo",
    ["3Machine Pistol"] = "Machine Pistol",
    ["3Submachine Gun"] = "Submachine Gun",
    ["4Assault Rifle"]  = "Assault Rifle",
    ["5Battle Rifle"]   = "Battle Rifle",
    ["5Machine Gun"]    = "Machine Gun",
    ["5Shotgun"]        = "Shotgun",
    ["5Sporter"]        = "Sporter",
    ["6Marksman Rifle"] = "Marksman Rifle",
    ["7Sniper Rifle"]   = "Sniper Rifle",
    
    ["6Launcher"]       = "Launcher",
    ["7Special Weapon"] = "Special Weapon",
    ["8Bladed Melee"]   = "Bladed Melee",
    ["8Blunt Melee"]    = "Blunt Melee",
    ["8Melee Weapon"]   = "Melee Weapon",
    ["9Equipment"]      = "Equipment",
    ["9Throwable"]      = "Throwable",
}

TacRP.Tier_Fix = {
    ["0Exotic"]         = "Exotic",
    ["1Elite"]          = "Elite",
    ["2Operator"]       = "Operator",
    ["3Security"]       = "Security",
    ["4Consumer"]       = "Consumer",
    ["5Value"]          = "Value",
    ["9Special"]        = "Special",
}

TacRP.Tier_SortOrder = {
    ["Exotic"] = 1,
    ["Elite"] = 2,
    ["Operator"] = 3,
    ["Security"] = 4,
    ["Consumer"] = 5,
    ["Value"] = 6,
    ["Special"] = 7,
}

TacRP.Type_SortOrder = {
	["Pistol"]			= 101,
	["Magnum Pistol"]	= 102,
	["Akimbo"]			= 103,
	["Machine Pistol"]	= 104,
	["Submachine Gun"]	= 105,
	["Assault Rifle"]	= 106,
	["Battle Rifle"]	= 107,
	["Machine Gun"]		= 108,
	["Shotgun"]			= 109,
	["Sporter"]			= 110,
	["Marksman Rifle"]	= 111,
	["Sniper Rifle"]	= 112,
	["Launcher"]		= 201,
	["Special Weapon"]	= 202,
	["Bladed Melee"]	= 203,
	["Blunt Melee"]		= 204,
	["Melee Weapon"]	= 205,
	["Equipment"]		= 206,
	["Throwable"]		= 207,
}

hook.Add( "PreRegisterSWEP", "TacRP_PreRegisterSWEP", function( swep, class )
    -- needs special logic
    if class:StartsWith("tacrp_nade") then
        swep.SubCatType = "Throwable"
        swep.SubCatTier = "Special"
    end
    if swep.Base:StartsWith("tacrp_") then
        swep.Category = "Tactical RP"

        local fixed_type = TacRP.Type_Fix[swep.SubCatType]
        if fixed_type then
            swep.SubCatType = fixed_type
        end

        local fixed_tier = TacRP.Tier_Fix[swep.SubCatTier]
        if fixed_tier then
            swep.SubCatTier = fixed_tier
        end

        swep.SubCategory = swep.SubCatType
    end
end )

TacRP.PackCategorization = {}

TacRP.PackCategorization["tacrp"] = {
	Name = "Tactical RP",
	Weapons = {
		tacrp_amd65 = true,
		tacrp_as50 = true,
		tacrp_aug = true,
		tacrp_bekas = true,
		tacrp_c4_detonator = true,
		tacrp_ak47 = true,
		tacrp_dsa58 = true,
		tacrp_fp6 = true,
		tacrp_g36k = true,
		tacrp_gsr1911 = true,
		tacrp_hk417 = true,
		tacrp_k1a = true,
		tacrp_knife = true,
		tacrp_knife2 = true,
		tacrp_ks23 = true,
		tacrp_m1 = true,
		tacrp_m14 = true,
		tacrp_m320 = true,
		tacrp_m4 = true,
		tacrp_m4star10 = true,
		tacrp_medkit = true,
		tacrp_mg4 = true,
		tacrp_mp5 = true,
		tacrp_mp7 = true,
		tacrp_mr96 = true,
		tacrp_mtx_dual = true,
		tacrp_nade_charge = true,
		tacrp_nade_flashbang = true,
		tacrp_nade_frag = true,
		tacrp_nade_gas = true,
		tacrp_nade_heal = true,
		tacrp_nade_smoke = true,
		tacrp_nade_thermite = true,
		tacrp_p2000 = true,
		tacrp_p250 = true,
		tacrp_p90 = true,
		tacrp_pdw = true,
		tacrp_rpg7 = true,
		tacrp_sg551 = true,
		tacrp_skorpion = true,
		tacrp_sphinx = true,
		tacrp_spr = true,
		tacrp_superv = true,
		tacrp_tgs12 = true,
		tacrp_uratio = true,
		tacrp_uzi = true,
		tacrp_vertec = true,
		tacrp_xd45 = true,
	}
}

TacRP.PackCategorization["ak"] = {
	Name = "Iron Curtain",
	Weapons = {
		tacrp_ak_aek971 = true,
		tacrp_ak_ak12 = true,
		tacrp_ak_ak74 = true,
		tacrp_ak_ak74u = true,
		tacrp_ak_an94 = true,
		tacrp_ak_galil_lmg = true,
		tacrp_ak_galil_sniper = true,
		tacrp_ak_rk95 = true,
		tacrp_ak_svd = true,
	}
}