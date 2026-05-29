SWEP.Base = "tacrp_base"
SWEP.Spawnable = true

AddCSLuaFile()

// names and stuff
SWEP.PrintName = "LAR Grizzly"
SWEP.AbbrevName = "Grizzly"
SWEP.Category = "Tactical RP"

SWEP.SubCatTier = "3Security"
SWEP.SubCatType = "2Magnum Pistol"

SWEP.Description = "Oversized M1911 derivative designed for big game hunting. Fast firing, strong vertical kick."
SWEP.Description_Quote = "\"Dancing in the shadow... I kiss you.\"" // Angel Beats

SWEP.Trivia_Caliber = ".45 Winchester Magnum"
SWEP.Trivia_Manufacturer = "LAR Manufacturing"
SWEP.Trivia_Year = "1983"

SWEP.Faction = TacRP.FACTION_NEUTRAL
SWEP.Credits = [[
Model & Textures: Sine
Sounds: Vunsunta
Animations: Tactical Intervention
]]

SWEP.ViewModel = "models/weapons/tacint_shark/v_grizzly.mdl"
SWEP.WorldModel = "models/weapons/tacint_shark/w_grizzly.mdl"

SWEP.Slot = 1

SWEP.BalanceStats = {
    [TacRP.BALANCE_SBOX] = {
        Damage_Max = 22,
        Damage_Min = 14,

        BodyDamageMultipliers = {
            [HITGROUP_HEAD] = 4,
            [HITGROUP_CHEST] = 1,
            [HITGROUP_STOMACH] = 1,
            [HITGROUP_LEFTARM] = 1,
            [HITGROUP_RIGHTARM] = 1,
            [HITGROUP_LEFTLEG] = 0.75,
            [HITGROUP_RIGHTLEG] = 0.75,
            [HITGROUP_GEAR] = 0.9
        },
    },
    [TacRP.BALANCE_TTT] = {
        Damage_Max = 15,
        Damage_Min = 6,
        RPM = 500,
        RPMMultBurst = 2.5,
        PostBurstDelay = 0.35,

        RecoilMaximum = 6,
        RecoilResetTime = 0.11,
        RecoilDissipationRate = 12,
        RecoilFirstShotMult = 0.6,
        RecoilSpreadPenalty = 0.008,

        BodyDamageMultipliers = {
            [HITGROUP_HEAD] = 2.5,
            [HITGROUP_CHEST] = 1,
            [HITGROUP_STOMACH] = 1,
            [HITGROUP_LEFTARM] = 0.9,
            [HITGROUP_RIGHTARM] = 0.9,
            [HITGROUP_LEFTLEG] = 0.75,
            [HITGROUP_RIGHTLEG] = 0.75,
            [HITGROUP_GEAR] = 0.9
        },
    }
}

SWEP.TTTReplace = TacRP.TTTReplacePreset.Pistol

// "ballistics"

SWEP.Damage_Max = 34
SWEP.Damage_Min = 22
SWEP.Range_Min = 700
SWEP.Range_Max = 2500
SWEP.Penetration = 11
SWEP.ArmorPenetration = 0.8
SWEP.ArmorBonus = 1.5

SWEP.MuzzleVelocity = 17500

SWEP.BodyDamageMultipliers = {
    [HITGROUP_HEAD] = 3,
    [HITGROUP_CHEST] = 1,
    [HITGROUP_STOMACH] = 1,
    [HITGROUP_LEFTARM] = 0.75,
    [HITGROUP_RIGHTARM] = 0.75,
    [HITGROUP_LEFTLEG] = 0.5,
    [HITGROUP_RIGHTLEG] = 0.5,
    [HITGROUP_GEAR] = 0.9
}

// misc. shooting

SWEP.Firemode = 1

SWEP.RPM = 280
SWEP.RPMMultSemi = 0.85

SWEP.Spread = 0.0045

SWEP.RecoilPerShot = 1
SWEP.RecoilMaximum = 4
SWEP.RecoilResetTime = 0.3
SWEP.RecoilDissipationRate = 4
SWEP.RecoilFirstShotMult = 0.8

SWEP.RecoilVisualKick = 2
SWEP.RecoilKick = 12
SWEP.RecoilStability = 0.65

SWEP.RecoilSpreadPenalty = 0.01
SWEP.HipFireSpreadPenalty = 0.03
SWEP.PeekPenaltyFraction = 0.2

SWEP.CanBlindFire = true

// handling

SWEP.MoveSpeedMult = 0.925
SWEP.ShootingSpeedMult = 0.75
SWEP.SightedSpeedMult = 0.8

SWEP.ReloadSpeedMult = 0.75

SWEP.AimDownSightsTime = 0.27
SWEP.SprintToFireTime = 0.25

SWEP.Sway = 1
SWEP.ScopedSway = 0.5

SWEP.FreeAimMaxAngle = 3.5

// hold types

SWEP.HoldType = "revolver"
SWEP.HoldTypeSprint = "normal"
SWEP.HoldTypeBlindFire = false

SWEP.GestureShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
SWEP.GestureReload = ACT_HL2MP_GESTURE_RELOAD_PISTOL

SWEP.PassiveAng = Angle(0, 0, 0)
SWEP.PassivePos = Vector(0, -2, -5)

SWEP.BlindFireAng = Angle(0, 5, 0)
SWEP.BlindFirePos = Vector(0, -2, -5)

SWEP.BlindFireSuicideAng = Angle(-130, -4, 45)
SWEP.BlindFireSuicidePos = Vector(25, 15, -6)

SWEP.SprintAng = Angle(0, 30, 0)
SWEP.SprintPos = Vector(2, 0, -12)

SWEP.SightAng = Angle(4.99, 0.7, 0)
SWEP.SightPos = Vector(-2.38, 0, -3.8)

SWEP.CorrectivePos = Vector(-1.435, 0, 0)
SWEP.CorrectiveAng = Angle(-5, 5, 0)

SWEP.HolsterVisible = true
SWEP.HolsterSlot = TacRP.HOLSTER_SLOT_PISTOL
SWEP.HolsterPos = Vector(0, 3, -4)
SWEP.HolsterAng = Angle(90, 0, 0)

// reload

SWEP.ClipSize = 7
SWEP.Ammo = "357"

SWEP.ReloadTimeMult = 1.15

SWEP.DropMagazineModel = "models/weapons/tacint_shark/magazines/grizzly.mdl"
SWEP.DropMagazineImpact = "pistol"

SWEP.ReloadUpInTime = 1.2
SWEP.DropMagazineTime = 0.2

// sounds

local path = "tacrp/weapons/sphinx/"
local path2 = "tacint_shark/grizzly/"

SWEP.Sound_Shoot = "^" .. path2 .. "deagle-2.wav"
SWEP.Sound_Shoot_Silenced = path .. "fire_silenced-1.wav"

SWEP.Vol_Shoot = 110
SWEP.ShootPitchVariance = 2.5 // amount to vary pitch by each shot

// effects

// the .qc attachment for the muzzle
SWEP.QCA_Muzzle = 4

SWEP.MuzzleEffect = "muzzleflash_pistol_deagle"
SWEP.EjectEffect = 1

// anims

SWEP.AnimationTranslationTable = {
    ["deploy"] = "draw",
    ["fire"] = {"shoot1", "shoot2", "shoot3"},
    ["blind_fire"] = {"blind_shoot1", "blind_shoot2", "blind_shoot3"},
    ["melee"] = {"melee1", "melee2"}
}

SWEP.ProceduralIronFire = {
    vm_pos = Vector(0, -0.5, -0.6),
    vm_ang = Angle(0, 2, 0),
    t = 0.2,
    tmax = 0.2,
    bones = {
        {
            bone = "slide",
            pos = Vector(0, 0, -1),
            t0 = 0.02,
            t1 = 0.2,
        },
        {
            bone = "bullet",
            pos = Vector(0, 0, 0),
            t0 = 0,
            t1 = 0.2,
        },
        {
            bone = "hammer",
            ang = Angle(0, 0, 0),
            t0 = 0,
            t1 = 0.15,
        },
        {
            bone = "ValveBiped.Bip01_R_Finger1",
            ang = Angle(0, -15, 0),
            t0 = 0,
            t1 = 0.2,
        },
        {
            bone = "ValveBiped.Bip01_R_Finger11",
            ang = Angle(-35, 0, 0),
            t0 = 0,
            t1 = 0.15,
        },
    },
}

SWEP.ShootTimeMult = 0.5

SWEP.LastShot = true

// attachments

SWEP.AttachmentElements = {
    ["pistol_comp"] = {
        BGs_VM = {
            {2, 1}
        },
        BGs_WM = {
            {1, 1}
        }
    },
    ["tactical"] = {
        BGs_VM = {
            {1, 1}
        },
    },
}

SWEP.Attachments = {
    [1] = {
        PrintName = "Optic",
        Category = "optic_pistol",
        Bone = "slide",
        WMBone = "Box01",
        AttachSound = "tacrp/weapons/optic_on.wav",
        DetachSound = "tacrp/weapons/optic_off.wav",
        VMScale = 1,
        WMScale = 1,
        Pos_VM = Vector(-0.01, 0, 0.6),
        Ang_VM = Angle(0, -90, 0),
        Pos_WM = Vector(0, -1, -0.8),
        Ang_WM = Angle(0, -90, 0),
    },
    [2] = {
        PrintName = "Muzzle",
        Category = {"barrel", "comp_grizzly"},
        Bone = "slide",
        WMBone = "Box01",
        AttachSound = "tacrp/weapons/flashlight_on.wav",
        DetachSound = "tacrp/weapons/flashlight_off.wav",
        VMScale = 1,
        WMScale = 1,
        Pos_VM = Vector(0, 0, 0),
        Ang_VM = Angle(0, 0, 0),
        Pos_WM = Vector(0, 0, 0),
        Ang_WM = Angle(0, 0, 0),
    },
    [3] = {
        PrintName = "Tactical",
        Category = {"tactical", "tactical_zoom", "tactical_ebullet"},
        Bone = "sphinx_ROOT",
        WMBone = "Box01",
        InstalledElements = {"tactical"},
        AttachSound = "tacrp/weapons/flashlight_on.wav",
        DetachSound = "tacrp/weapons/flashlight_off.wav",
        VMScale = 0.9,
        WMScale = 1.3,
        Pos_VM = Vector(-1.4, -0.1, 6.1),
        Ang_VM = Angle(90, 0, 180),
        Pos_WM = Vector(0, 5, -2.75),
        Ang_WM = Angle(0, -90, 180),
    },
    [4] = {
        PrintName = "Accessory",
        Category = {"acc", "acc_extmag_pistol2", "acc_holster", "acc_brace"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [5] = {
        PrintName = "Bolt",
        Category = {"bolt_automatic"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [6] = {
        PrintName = "Trigger",
        Category = "trigger_semi",
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [7] = {
        PrintName = "Ammo",
        Category = {"ammo_pistol"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [8] = {
        PrintName = "Perk",
        Category = {"perk", "perk_melee", "perk_shooting", "perk_reload"},
        AttachSound = "tacrp/weapons/flashlight_on.wav",
        DetachSound = "tacrp/weapons/flashlight_off.wav",
    },
}

local function addsound(name, spath)
    sound.Add({
        name = name,
        channel = 16,
        volume = 1.0,
        sound = spath
    })
end

addsound("tacint_grizzly.clip_in", path .. "clip_in-1.wav")
addsound("tacint_grizzly.clip_out", path2 .. "magout.wav")
addsound("tacint_grizzly.slide_back", path2 .. "slideback.wav")
addsound("tacint_grizzly.slide_forward", path2 .. "sliderelease.wav")
addsound("tacint_grizzly.slide_shut", path2 .. "sliderelease.wav")
addsound("tacint_grizzly.cock_hammer", path .. "cockhammer.wav")
addsound("tacint_grizzly.safety_switch", path .. "safety_switch.wav")
