-- states you DEFINITELY would not want to do anything else in
function SWEP:StillWaitingSuper()
    if self:GetHolsterTime() ~= 0 then return true end
    if self:GetCustomize() then return true end
    if self:GetPrimedGrenade() then return true end

    return false
end

function SWEP:StillWaiting()
    if self:StillWaitingSuper() then return true end
    local ct = CurTime()
    if self:A_GetNextFire( false ) > ct then return true end
    if self:A_GetNextFire( true ) > ct then return true end
    if self:GetNextMeleeTime() > ct then return true end
    if self:GetAnimLockTime() > ct then return true end

    return false
end

function SWEP:SprintLock(shoot)
    if self:GetSprintLockTime() > CurTime() or self:GetIsSprinting() or self:ShouldLowerWeapon() then
        return true
    end

    if shoot and self:DoForceSightsBehavior() and (self:GetSprintDelta() > 0 or self:GetSightDelta() < 0.75) and !self:GetBlindFire() then
        return true
    end

    if self:GetValue("CannotHipFire") and self:GetSightAmount() < 1 and !self:GetBlindFire() then
        return true
    end

    return false
end

local function anglerotate(main, off)
    local forward, up, right = main:Forward(), main:Up(), main:Right()

    main:RotateAroundAxis(right, off.p)
    main:RotateAroundAxis(up, off.y)
    main:RotateAroundAxis(forward, off.r)

    return main
end

local rings = {1, 9, 24, 45}
local function ringnum(i)
    return rings[i] or (rings[#rings] + i ^ 2)
end

local function getring(x)
    local i = 1
    while x > ringnum(i) do i = i + 1 end
    return i
end

function SWEP:GetShotgunPattern(i, d)
    local ring_spread = self:GetSpread()
    local num = self:GetValue("Num")
    if num == 1 then return 0, 0 end

    local pelspread = self:GetValue("ShotgunPelletSpread") > 0 and TacRP.ConVars["pelletspread"]:GetBool()
    if pelspread then
        ring_spread = ring_spread - self:GetValue("ShotgunPelletSpread")
    else
        d = 0
    end

    local x = 0
    local y = 0
    local red = num <= 3 and 0 or 1
    local f = (i - red) / (num - red)

    if num == 2 then
        local angle = f * 180 + (pelspread and (d - 0.5) * 60 or 0)

        x = math.sin(math.rad(angle)) * ring_spread
        y = math.cos(math.rad(angle)) * ring_spread
    elseif num == 3 then
        local angle = f * 360 + d * 180 + 30
        x = math.sin(math.rad(angle)) * ring_spread
        y = math.cos(math.rad(angle)) * ring_spread
    elseif i == 1 then
        return x, y
    -- elseif num <= 9 then
    --     local angle = 360 * (f + d - (1 / (num - 2)))
    --     x = math.sin(math.rad(angle)) * ring_spread
    --     y = math.cos(math.rad(angle)) * ring_spread
    else
        local tr = getring(num)
        local ri = getring(i)
        local rin = ringnum(ri)
        local rln = ringnum(ri - 1)

        local l = (ri - 1) / (tr - 1)
        if ri == tr then
            f = (i - rln) / ((math.min(rin, num)) - rln)
        else
            f = (i - rln) / (rin - rln)
        end

        local angle = 360 * (f + l + d)
        x = math.sin(math.rad(angle)) * ring_spread * l
        y = math.cos(math.rad(angle)) * ring_spread * l
    end

    return x, y
end

local doorclasses = {
    ["func_door_rotating"] = true,
    ["prop_door_rotating"] = true,
    ["prop_door_rotating_checkpoint"] = true
}

function SWEP:AfterShotFunction(tr, dmg, range, penleft, alreadypenned, forced)
    if !forced and !IsFirstTimePredicted() and !game.SinglePlayer() then return end

    if self:GetValue("DamageType") then
        dmg:SetDamageType(self:GetValue("DamageType"))
    elseif self:IsShotgun() then
        dmg:SetDamageType(DMG_BUCKSHOT + (engine.ActiveGamemode() == "terrortown" and DMG_BULLET or 0))
    end

    local matpen = self:GetValue("Penetration")

    if tr.Entity and alreadypenned[tr.Entity] then
        dmg:SetDamage(0)
    elseif IsValid(tr.Entity) then
        dmg:SetDamage(self:GetDamageAtRange(range))
        local bodydamage = self:GetBodyDamageMultipliers()

        if bodydamage[tr.HitGroup] then
            dmg:ScaleDamage(bodydamage[tr.HitGroup])
        end

        if tr.Entity:IsNextBot() or tr.Entity:IsNPC() then
            dmg:ScaleDamage(self:GetValue("DamageMultNPC"))
        end

        TacRP.CancelBodyDamage(tr.Entity, dmg, tr.HitGroup)

        if self:GetOwner():IsNPC() and !TacRP.ConVars["npc_equality"]:GetBool() then
            dmg:ScaleDamage(0.25)
        elseif matpen > 0 and TacRP.ConVars["penetration"]:GetBool() and !self:GetOwner():IsNPC() then
            local pendelta = penleft / matpen
            pendelta = Lerp(pendelta, math.Clamp(matpen * 0.02, 0.25, 0.5), 1)
            dmg:ScaleDamage(pendelta)
        end
        alreadypenned[tr.Entity] = true

        if tr.Entity.LVS and !self:IsShotgun() then
            dmg:ScaleDamage(0.5)
            dmg:SetDamageForce(dmg:GetDamageForce():GetNormalized() * matpen * 75)
            dmg:SetDamageType(DMG_AIRBOAT + DMG_SNIPER)
            penleft = 0
        end

        if SERVER and self:GetValue("DamageType") == DMG_BURN and IsValid(tr.Entity) then
            tr.Entity:Ignite(1, 64)
        end
    end

    if self:GetValue("ExplosiveDamage") > 0 and penleft == matpen then
        -- Add DMG_AIRBOAT to hit helicopters
        -- Need a timer here because only one DamageInfo can exist at a time
        timer.Simple(0.0001, function()
            if !IsValid(self) or !IsValid(self:GetOwner()) then return end
            local dmginfo = DamageInfo()
            dmginfo:SetAttacker(self:GetOwner())
            dmginfo:SetInflictor(self)
            dmginfo:SetDamageType(self:GetValue("ExplosiveDamageType") or (DMG_BLAST + DMG_AIRBOAT))
            dmginfo:SetDamage(self:GetValue("ExplosiveDamage"))
            util.BlastDamageInfo(dmginfo, tr.HitPos, self:GetValue("ExplosiveRadius"))
        end)
        -- penleft = 0
        --util.BlastDamage(self, self:GetOwner(), tr.HitPos, self:GetValue("ExplosiveRadius"), self:GetValue("ExplosiveDamage"))
    end

    if self:GetValue("ExplosiveEffect") then
        local fx = EffectData()
        fx:SetOrigin(tr.HitPos)
        fx:SetNormal(tr.HitNormal)

        if bit.band(util.PointContents(tr.HitPos), CONTENTS_WATER) == CONTENTS_WATER then
            util.Effect("WaterSurfaceExplosion", fx, true)
        else
            util.Effect(self:GetValue("ExplosiveEffect"), fx, true)
        end
    end

    if SERVER and IsValid(tr.Entity) and !tr.Entity.TacRP_DoorBusted
            and doorclasses[tr.Entity:GetClass()] and self:GetValue("DoorBreach") then
        if !tr.Entity.TacRP_BreachThreshold or CurTime() - tr.Entity.TacRP_BreachThreshold[1] > 0.1 then
            tr.Entity.TacRP_BreachThreshold = {CurTime(), 0}
        end

        tr.Entity.TacRP_BreachThreshold[2] = tr.Entity.TacRP_BreachThreshold[2] + dmg:GetDamage()
        if tr.Entity.TacRP_BreachThreshold[2] > (self:GetValue("DoorBreachThreshold") or 100) then
            tr.Entity:EmitSound("ambient/materials/door_hit1.wav", 80, math.Rand(95, 105))
            for _, otherDoor in pairs(ents.FindInSphere(tr.Entity:GetPos(), 72)) do
                if tr.Entity != otherDoor and otherDoor:GetClass() == tr.Entity:GetClass() then
                    local v = (otherDoor.TacRP_BreachThreshold and CurTime() - otherDoor.TacRP_BreachThreshold[1] <= 0.1) and 800 or 200
                    TacRP.DoorBust(otherDoor, tr.Normal * v, dmg:GetAttacker())
                    break
                end
            end
            TacRP.DoorBust(tr.Entity, tr.Normal * 800, dmg:GetAttacker())
            tr.Entity.TacRP_BreachThreshold = nil
        end
    end

    self:Penetrate(tr, range, penleft, alreadypenned)
end

function SWEP:GetMinMaxRange(base, static)
    local valfunc = base and self.GetBaseValue or self.GetValue

    local max, min = valfunc(self, "Damage_Max"), valfunc(self, "Damage_Min")
    return valfunc(self, "Range_Min", static, max < min), valfunc(self, "Range_Max", static, max < min)
end

function SWEP:GetDamageAtRange(range, noround)
    local d = 1

    local r_min, r_max = self:GetMinMaxRange()

    if range <= r_min then
        d = 0
    elseif range >= r_max then
        d = 1
    else
        d = (range - r_min) / (r_max - r_min)
    end

    local dmgv = Lerp(d, self:GetValue("Damage_Max"), self:GetValue("Damage_Min")) * self:GetConfigDamageMultiplier()

    if !noround then
        dmgv = math.ceil(dmgv)
    end

    return dmgv
end

function SWEP:GetShootDir(nosway)
    if !IsValid(self:GetOwner()) then return self:GetAngles() end
    local dir = self:GetOwner():EyeAngles()

    local bf = self:GetBlindFireMode()
    if bf == TacRP.BLINDFIRE_KYS then
        dir.y = dir.y + 180
    elseif bf == TacRP.BLINDFIRE_LEFT then
        dir.y = dir.y + 75
    elseif bf == TacRP.BLINDFIRE_RIGHT then
        dir.y = dir.y - 75
    end

    local u, r = dir:Up(), dir:Right()

    local oa = self:GetFreeAimOffset()
    if !nosway then
        oa = oa + self:GetSwayAngles()
    end

    dir:RotateAroundAxis(u, oa.y)
    -- dir:RotateAroundAxis(r, oa.r)
    dir:RotateAroundAxis(r, -oa.p)

    dir = dir + self:GetValue("ShootOffsetAngle")

    return dir
end

function SWEP:ShootRocket(dir)
    if CLIENT then return end

    local src = self:GetMuzzleOrigin()
    dir = dir or self:GetShootDir()

    local ent = self:GetValue("ShootEnt")

    local rocket = ents.Create(ent)
    if !IsValid(rocket) then return end

    rocket:SetPos(src)
    if self:GetBlindFireMode() != TacRP.BLINDFIRE_KYS then
        rocket:SetOwner(self:GetOwner())
    else
        rocket.Attacker = self:GetOwner()
    end
    rocket.Inflictor = self
    rocket:SetAngles(dir)
    if isfunction(rocket.SetWeapon) then
        rocket:SetWeapon(self)
    end
    if self:GetOwner():IsNPC() then
        rocket.LockOnEntity = self:GetOwner():GetTarget()
    else
        if IsValid(self:GetLockOnEntity()) and CurTime() >= self:GetValue("LockOnTime") + self:GetLockOnStartTime() then
            rocket.LockOnEntity = self:GetLockOnEntity()
        end
    end
    self:RunHook("Hook_PreShootEnt", rocket)
    rocket:Spawn()
    self:RunHook("Hook_PostShootEnt", rocket)

    rocket.IsTacRPProjectile = true

    local phys = rocket:GetPhysicsObject()

    if phys:IsValid() and self:GetValue("ShootEntForce") > 0 then
        phys:SetVelocityInstantaneous(dir:Forward() * self:GetValue("ShootEntForce"))
    end
end

function SWEP:GetSpread(baseline)
    local ply = self:GetOwner()
    local spread = self:GetValue("Spread")

    if baseline then return spread end

    local hippenalty = self:GetValue("HipFireSpreadPenalty")
    local movepenalty = self:GetValue("MoveSpreadPenalty")
    if TacRP.ConVars["oldschool"]:GetBool() or TacRP.GetBalanceMode() == TacRP.BALANCE_OLDSCHOOL then
        movepenalty = movepenalty + hippenalty * 0.25
        hippenalty = hippenalty * Lerp(12 / (self:GetValue("ScopeFOV") - 1.1), 0.05, 0.5)
    end

    if self:GetInBipod() and self:GetScopeLevel() == 0 then
        spread = spread + Lerp(1 - self:GetValue("PeekPenaltyFraction"), hippenalty, 0)
    else
        spread = spread + Lerp(self:GetSightAmount() - (self:GetPeeking() and self:GetValue("PeekPenaltyFraction") or 0), hippenalty, 0)
    end

    if !self:UseAltRecoil() then
        spread = spread + (self:GetRecoilAmount() * self:GetValue("RecoilSpreadPenalty"))
    end

    local v = ply:GetAbsVelocity()
    local spd = math.min(math.sqrt(v.x * v.x + v.y * v.y) / 250, 1)

    spread = spread + (spd * movepenalty)

    local groundtime = CurTime() - (ply.TacRP_LastOnGroundTime or 0)
    local gd = math.Clamp(!ply:IsOnGround() and 0 or groundtime / math.Clamp((ply.TacRP_LastAirDuration or 0) - 0.25, 0.1, 1.5), 0, 1) ^ 0.75

    if gd < 1 and ply:GetMoveType() != MOVETYPE_NOCLIP then
        local v = (ply:WaterLevel() > 0 or ply:GetMoveType() == MOVETYPE_LADDER) and 0.5 or 0
        spread = spread + Lerp(gd + v, self:GetValue("MidAirSpreadPenalty"), 0)
    end

    if ply:OnGround() and ply:Crouching() then
        spread = spread + self:GetValue("CrouchSpreadPenalty")
    end

    if self:GetBlindFire() then
        spread = spread + self:GetValue("BlindFireSpreadPenalty")
    end

    local quickscopetime = CurTime() - self:GetLastScopeTime()

    local qsd = (quickscopetime / self:GetValue("QuickScopeTime")) ^ 4

    if qsd < 1 then
        spread = spread + Lerp(qsd, self:GetValue("QuickScopeSpreadPenalty"), 0)
    end

    spread = math.max(spread, 0)

    return spread
end

local type_to_cvar = {
    ["Magnum Pistol"] = "mult_damage_magnum",
    ["Sniper Rifle"] = "mult_damage_sniper",
    -- ["Shotgun"] = "mult_damage_shotgun",

    ["Launcher"] = "",
    ["Special Weapon"] = "",
    ["Melee Weapon"] = "",
    ["Equipment"] = "",
    ["Throwable"] = "",
}

function SWEP:GetConfigDamageMultiplier()
    if self:IsShotgun() then
        return TacRP.ConVars["mult_damage_shotgun"]:GetFloat()
    elseif self:GetValue("PrimaryMelee") then
        return TacRP.ConVars["mult_damage_melee"]:GetFloat()
    else
        local cvar = type_to_cvar[self.SubCatType] or "mult_damage"
        return TacRP.ConVars[cvar] and TacRP.ConVars[cvar]:GetFloat() or 1
    end
end

local shotgundmgmult = {
    [HITGROUP_HEAD] = 1,
    [HITGROUP_CHEST] = 1,
    [HITGROUP_STOMACH] = 1,
    [HITGROUP_LEFTARM] = 1,
    [HITGROUP_RIGHTARM] = 1,
    [HITGROUP_LEFTLEG] = 1,
    [HITGROUP_RIGHTLEG] = 1,
    [HITGROUP_GEAR] = 1,
}

function SWEP:GetBodyDamageMultipliers(base)
    if self:IsShotgun(base) then -- Shotguns using hull traces will never hit bodygroups
        return table.Copy(shotgundmgmult)
    end

    local valfunc = base and self.GetBaseValue or self.GetValue

    local btbl = table.Copy(valfunc(self, "BodyDamageMultipliers"))

    for k, v in pairs(valfunc(self, "BodyDamageMultipliersExtra") or {}) do
        if v < 0 then
            btbl[k] = math.abs(v)
        else
            btbl[k] = btbl[k] * v
        end
    end

    local mult = TacRP.ConVars["mult_headshot"]:GetFloat()
    if mult <= 0 then
        btbl[HITGROUP_HEAD] = 1
    elseif mult <= 1 then
        btbl[HITGROUP_HEAD] = Lerp(mult, 1, btbl[HITGROUP_HEAD])
    else
        btbl[HITGROUP_HEAD] = btbl[HITGROUP_HEAD] * mult
    end

    return btbl
end

function SWEP:FireAnimationEvent( pos, ang, event, options )
    if event != 5004 then return true end
end

-- DO NOT USE AngleRand() to do bullet spread as it generates a random angle in 3 directions when we only use two (roll is not relevant!)
-- Also, multiplying by 36 is not correct! you need to also multiply by square root of 2. Trig stuff, i forgot why exactly.
-- Arctic I fixed this THREE FUCKING TIMES on your THREE FUCKING WEAPON BASES do not make me come to Australia and beat the shit out of you
function SWEP:RandomSpread(spread, seed)
    seed = (seed or 0) + self:EntIndex() + engine.TickCount()
    local a = util.SharedRandom("tacrp_randomspread", 0, 360, seed)
    local angleRand = Angle(math.sin(a), math.cos(a), 0)
    angleRand:Mul(spread * util.SharedRandom("tacrp_randomspread2", 0, 45, seed) * 1.4142135623730)

    return angleRand
end

function SWEP:IsShotgun(base)
    if base then
        return self:GetBaseValue("Num") > 1 and !self:GetBaseValue("NotShotgun")
    else
        return self:GetValue("Num") > 1 and !self:GetValue("NotShotgun")
    end
end

function SWEP:GetJamChance(base)
    local valfunc = base and self.GetBaseValue or self.GetValue
    local factor = valfunc(self, "JamFactor")
    if factor <= 0 or !TacRP.ConVars["can_jam"]:GetBool() then return 0 end

    local default = TacRP.AmmoJamMSB[self:GetAmmoType(base)] or 15
    local msb = (valfunc(self, "JamBaseMSB") or default) / math.sqrt(factor)

    return 1 / msb
end

function SWEP:GetRPM(base, fm)
    fm = fm or self:GetCurrentFiremode()
    local valfunc = base and self.GetBaseValue or self.GetValue
    local rpm = valfunc(self, "RPM")
    if fm == 1 then
        rpm = rpm * valfunc(self, "RPMMultSemi")
    elseif fm < 0 then
        rpm = rpm * valfunc(self, "RPMMultBurst")
    end
    return rpm
end

function SWEP:GetEffectiveRPM(base, fm)
    local rpm = self:GetRPM(base, fm)
    local valfunc = base and self.GetBaseValue or self.GetValue
    if valfunc(self, "DualAkimbo") then
        rpm = rpm * 2
    end
    return rpm
end

-- fesiug's rewrites
local TICK_INTERVAL = engine.TickInterval()
local SINGLEPLAYER = game.SinglePlayer()

function SWEP:PlayShootSound(force_pos)
    local pvar = self:GetValue("ShootPitchVariance")
    local sshoot = self:GetValue("Silencer") and self:GetValue("Sound_Shoot_Silenced") or self:GetValue("Sound_Shoot")
    if istable(sshoot) then
        sshoot = table.Random(sshoot)
    end
    local volume = self:GetValue("Vol_Shoot")
    local pitch = self:GetValue("Pitch_Shoot") + util.SharedRandom("TacRP_sshoot", -pvar, pvar)
    local loudness = self:GetValue("Loudness_Shoot")

    local sshoot_add = self:GetValue("Sound_ShootAdd")
    if sshoot_add then
        if force_pos then
            EmitSound(sshoot_add, force_pos, 0, CHAN_BODY, loudness, volume, 0, pitch)
        else
            self:EmitSound(
                sshoot_add,
                volume,
                pitch,
                loudness,
                CHAN_BODY
            )
        end
    end
    if force_pos then
        EmitSound(sshoot, force_pos, 0, CHAN_WEAPON, loudness, volume, 0, pitch)
    else
        self:EmitSound(
            sshoot,
            volume,
            pitch,
            loudness,
            CHAN_WEAPON
        )
    end
end

local CLOSE_SIMULT = 0.1
local CLOSE_RECENT = 0.5
local LEFT, RIGHT = false, true

local anim_akimbo = {
    ["normal"] = {
        [RIGHT] = "shoot_right",
        [LEFT] = "shoot_left",
    },
    ["this_last"] = {
        [RIGHT] = "shoot_right_second_2_lastshot",
        [LEFT] = "shoot_left_second_2_lastshot",
    },
    ["this_last_other_empty"] = {
        [RIGHT] = "shoot_right_lastshot",
        [LEFT] = "shoot_left_lastshot",
    },
    ["this_normal_other_empty"] = {
        [RIGHT] = "shoot_right_second_empty",
        [LEFT] = "shoot_left_second_empty",
    },
    ["this_normal_other_recent"] = {
        [RIGHT] = "shoot_right_cooling",
        [LEFT] = "shoot_left_cooling",
    },
    -- simulataneous
    ["both"] = {
        [RIGHT] = "shoot_both",
        [LEFT] = "shoot_both",
    },
    ["both_empty"] = {
        [RIGHT] = "shoot_both_lastshot",
        [LEFT] = "shoot_both_lastshot",
    },
    ["both_this_empty"] = {
        [RIGHT] = "shoot_both_right_lastshot",
        [LEFT] = "shoot_both_left_lastshot",
    },
    -- dryfire
    ["dryfire"] = {
        [RIGHT] = "dryfire_right",
        [LEFT] = "dryfire_left",
    },
    ["dryfire_both"] = {
        [RIGHT] = "dryfire",
        [LEFT] = "dryfire",
    },
}

function SWEP:PlayShootAnim( gun2 )
    local seq = "fire"
    local idle = true
    local mult = self:GetValue("ShootTimeMult")
    local ct = CurTime()

    if self:GetValue("DualAkimbo") then
        local ammo_per_shot = self:GetValue("AmmoPerShot")
        local empty_other = self:A_GetClip( not gun2 ) < ammo_per_shot
        local empty_current = self:A_GetClip( gun2 ) <= ammo_per_shot

        if ct - self:A_GetLastShot( not gun2 ) < CLOSE_SIMULT then -- opposite gun fired simulataneously
            if empty_current and empty_other then -- were dry
                seq = anim_akimbo["both_empty"][gun2]
            elseif empty_current then -- im dry
                seq = anim_akimbo["both_this_empty"][gun2]
            else
                seq = anim_akimbo["both"][gun2]
            end

        elseif empty_current and empty_other then -- this gun fired its last shot and now both guns are empty
            seq = anim_akimbo["this_last_other_empty"][gun2]
        elseif empty_current then -- this gun just fired it's last shot
            seq = anim_akimbo["this_last"][gun2]
        elseif empty_other then -- opposite gun is empty while we are firing
            seq = anim_akimbo["this_normal_other_empty"][gun2]
        elseif ct - self:A_GetLastShot( not gun2 ) < CLOSE_RECENT then -- opposite gun was fired recently
            seq = anim_akimbo["this_normal_other_recent"][gun2]
        else
            seq = anim_akimbo["normal"][gun2]
        end
        self:PlayAnimation(seq, mult, false, idle)
        return
    end

    if self:GetValue("Akimbo") then
        if self:GetNthShot() % 2 == 0 then
            seq = "shoot_left"
        else
            seq = "shoot_right"
        end
        self:PlayAnimation(seq, mult, false, idle)
        return
    end

    if self:GetValue("LastShot") and self:Clip1() == self:GetValue("AmmoPerShot") then
        seq = self:TranslateSequence("lastshot")
        idle = false
    end

    if self:GetBlindFire() then
        seq = "blind_" .. seq
    end

    local procedural_iron = self:DoProceduralIrons()
    if self:GetScopeLevel() ~= 0 and not self:GetPeeking() then
        if procedural_iron then
            if self:GetValue("LastShot") and self:Clip1() == self:GetValue("AmmoPerShot") then
                self:PlayAnimation( self:TranslateSequence("dryfire"), mult, false )
            end
            if SINGLEPLAYER then
                self:CallOnClient("SetLastProceduralFireTime", UnPredictedCurTime())
            elseif IsFirstTimePredicted() then
                self:SetLastProceduralFireTime(UnPredictedCurTime())
            end
            return
        elseif self:HasSequence(seq .. "_iron") then
            self:PlayAnimation(seq .. "_iron", mult, false, idle)
            return
        end
    end

    local best_seq = seq .. 1
    if not self:InBipod() and (self:GetScopeLevel() == 0 or self:GetPeeking()) then
        best_seq = seq .. self:A_GetBurstCount(gun2)+1
    end
    best_seq = self:TranslateSequence(best_seq)
    if not self:HasSequence(best_seq) then
        best_seq = nil
        for i=1, self:A_GetBurstCount(gun2) do
            local test_seq = seq .. i
            test_seq = self:TranslateSequence(test_seq)
            if self:HasSequence(test_seq) then
                best_seq = test_seq
            else
                break
            end
        end
    end
    if best_seq then
        self:PlayAnimation( best_seq, mult, false, idle )
        return
    end

    self:PlayAnimation(seq, mult, false, idle)
end

function SWEP:GetMaxBurst()
    local cfm = self:GetCurrentFiremode()
    if cfm == 1 then
        return 1
    elseif cfm == 2 then
        return math.huge
    else
        return -cfm
    end
end

function SWEP:IsOneButtonAkimbo()
    return TacRP.ConVars["onebutton_akimbo"]:GetBool() or self:GetOwner():GetInfoNum("tacrp_onebutton_akimbo_client", 0) != 0
end

-- these functions are called at the whim at the engine and so i won't deal with them
function SWEP:PrimaryAttack()
    if self:GetOwner():IsNPC() then self:NPC_PrimaryAttack() end
end
function SWEP:SecondaryAttack() end

function SWEP:Player_Primary()
    if self:GetOwner():KeyDown(IN_USE) then
        self:Melee()
        return
    end

    if self:GetSafe() then
        self:ToggleSafety(false)
        self:SetAnimLockTime( CurTime() + 0.25 )
    end

    if self:GetValue("DualAkimbo") and self:IsOneButtonAkimbo() then
        if self:GetMaxBurst() > 1 then
            self:Weapon_Attack( false )
            self:Weapon_Attack( true )
        else
            local active
            if self:A_GetBurstCount( false ) ~= self:A_GetBurstCount( true ) then
                active = self:A_GetBurstCount( false ) < self:A_GetBurstCount( true )
            else
                active = self:A_GetClip( false ) < self:A_GetClip( true )
            end
            self:Weapon_Attack( active )
        end
    else
        self:Weapon_Attack(false)
    end
end

function SWEP:Player_Secondary()
    if not self:StillWaiting() and self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyPressed(IN_ATTACK2) then
        self:ToggleSafety()
        self:SetAnimLockTime( CurTime() + 0.25 )
        return
    end

    if self:GetValue("DualAkimbo") and not self:IsOneButtonAkimbo() then
        self:Weapon_Attack(true)
        return
    end

    self:RunHook("Hook_SecondaryAttack")
    return
end

function SWEP:ThinkBurst()
    local owner = self:GetOwner()
    if not IsValid(owner) then
        owner = nil
    end

    for i=1, self:GetValue("DualAkimbo") and 2 or 1 do
        local gun2 = i == 2
        local key = gun2 and IN_ATTACK2 or IN_ATTACK
        if self:IsOneButtonAkimbo() then
            key = IN_ATTACK
        end
        local attack_down = owner and owner:KeyDown( key ) or false
        local burst_count = self:A_GetBurstCount( gun2 )
        local dryfire = self:A_GetClip( gun2 ) < self:GetValue("AmmoPerShot") or self:GetJammed()
        local max_burst = dryfire and 1 or self:GetMaxBurst()
        local burst_mode = max_burst ~= math.huge and max_burst ~= 1

        if burst_count == 0 then
            continue
        end

        -- automatic weapons can have the "runaway burst" stat :v
        if not burst_mode then
            if not attack_down then
                self:A_SetBurstCount( gun2, 0 )
            end
            continue
        end

        if self:GetValue("RunawayBurst") then
            if burst_count < max_burst then
                self:Weapon_Attack( gun2 )
            elseif not attack_down then
                self:A_SetBurstCount( gun2, 0 )
            end
        else
            if not attack_down then
                if burst_count ~= max_burst then
                    self:A_SetNextFire( gun2, math.max(
                        self:A_GetNextFire( gun2 ),
                        CurTime() + self:GetValue("PostBurstDelay")
                    ) )
                end
                self:A_SetBurstCount( gun2, 0 )
            end
        end
    end
end

function SWEP:Weapon_Dryfire( gun2 )
    local ret = self:RunHook("Hook_PreDryfire")
    if ret == true then
        return
    end

    if self:GetValue("DualAkimbo") then
        if not (CurTime() - self:A_GetLastShot( not gun2 ) < CLOSE_RECENT) then -- opposite gun was fired recently
            local seq
            if self:A_GetClip( not gun2 ) == 0 then
                seq = anim_akimbo["dryfire_both"][gun2]
            else
                seq = anim_akimbo["dryfire"][gun2]
            end
            self:PlayAnimation( seq )
        end
    else
        if self:GetBlindFire() then
            self:PlayAnimation("blind_dryfire")
        else
            self:PlayAnimation("dryfire")
        end
    end
    self:EmitSound(self:GetValue("Sound_DryFire"), 75, 100, 1, CHAN_ITEM)
    self:RunHook("Hook_PostDryfire")
end

function SWEP:Weapon_Attack( gun2 )
    if self:StillWaitingSuper() then return end
    local ct = CurTime()

    if self:A_GetNextFire( gun2 ) > ct then return end
    if self:GetNextMeleeTime() > ct then return end
    if self:GetSafe() then return end
    if self:SprintLock() then return end
    if self:GetBiocodeLocked() then return end

    local dryfire = self:A_GetClip( gun2 ) < self:GetValue("AmmoPerShot") or self:GetJammed()
    local max_burst = dryfire and 1 or self:GetMaxBurst()
    if self:A_GetBurstCount( gun2 ) >= max_burst then
        return
    end

    if !dryfire and self:GetReloading() and self:GetValue("ShotgunReload") then
        if TacRP.ConVars["reload_sg_cancel"]:GetBool() and not self:GetValue("ShotgunFullCancel") then
            self:CancelReload(false)
            self:Idle()
        else
            self:CancelReload(true)
        end
    end
    if self:GetAnimLockTime() > ct then return end

    if dryfire then
        self:Weapon_Dryfire( gun2 )
        self:A_SetBurstCount( gun2, 1 )
        return
    end

    if self:Weapon_JamLogic( gun2 ) then
        return
    end

    local stop = self:RunHook("Hook_PreShoot")
    if stop then return end

    -- gets around sound not playing when shooter dies
    local shootsoundpos = self:GetBlindFireMode() == TacRP.BLINDFIRE_KYS and self:GetPos()

    if SINGLEPLAYER and ct - self:A_GetLastShot( not gun2 ) < 0.01 then
        timer.Simple( 0.03, function() if self:IsValid() then self:PlayShootSound(shootsoundpos) end end)
    else
        self:PlayShootSound(shootsoundpos)
    end
    self:PlayShootAnim( gun2 )
    self:Weapon_Effects( gun2 )
    self:ApplyRecoil()
    self:Weapon_FireBullet()

    -- Jane's fix
    local curatt = self:A_GetNextFire( gun2 )
    local diff = ct - curatt
    if diff > TICK_INTERVAL or diff < 0 then
        curatt = ct
    end

    self:A_TakeAmmo( gun2, self:GetValue("AmmoPerShot") )
    self:A_SetNextFire( gun2, curatt + 60 / self:GetRPM() )
    self:A_SetBurstCount( gun2, self:A_GetBurstCount( gun2 ) + 1 )
    self:SetPatternCount( self:GetPatternCount() + 1 )
    self:DoBulletBodygroups()

    local burst_mode = max_burst ~= math.huge and max_burst >= 2
    if burst_mode then
        if self:A_GetBurstCount( gun2 ) >= max_burst then
            self:A_SetNextFire( gun2, math.max(
                self:A_GetNextFire( gun2 ),
                curatt + self:GetValue("PostBurstDelay")
            ) )
            if self:GetValue("AutoBurst") then
                self:A_SetBurstCount( gun2, 0 )
            end
        end
        if self:A_GetClip( gun2 ) == 0 then
            self:A_SetBurstCount( gun2, 0 )
        end
    end

    self:A_SetNthShot( gun2, self:A_GetNthShot( gun2 ) + 1 )

    self:RunHook("Hook_PostShoot")
end

function SWEP:Weapon_FireBullet()
    local num = self:GetValue("Num")
    local fixed_spread = TacRP.ConVars["fixedspread"]:GetBool() and self:IsShotgun()
    local pellet_spread = TacRP.ConVars["pelletspread"]:GetBool() and self:IsShotgun() and self:GetValue("ShotgunPelletSpread") > 0

    local spread = self:GetSpread()
    local dir = self:GetShootDir()
    local tr = self:GetValue("TracerNum")
    local shootent = self:GetValue("ShootEnt")

    if not IsFirstTimePredicted() then
        return
    end

    local hitscan = self:GetValue("AlwaysHitscan") or !TacRP.ConVars["physbullet"]:GetBool()
    local dist = 100000
    -- If the bullet is going to hit something very close in front, use hitscan bullets instead
    -- This uses the aim direction without random spread, which may result in hitscan bullets in distances where it shouldn't be.
    if not hitscan and (SINGLEPLAYER or not TacRP.ConVars["client_damage"]:GetBool()) then
        dist = math.max(self:GetValue("MuzzleVelocity"), 15000) * engine.TickInterval()
            * game.GetTimeScale()
            * (num == 1 and 2 or 1) * (game.IsDedicated() and 1 or 2)
        local threshold = dir:Forward() * dist
        local inst_tr = util.TraceLine({
            start = self:GetMuzzleOrigin(),
            endpos = self:GetMuzzleOrigin() + threshold,
            mask = MASK_SHOT,
            filter = { self:GetOwner(), self:GetOwner():GetVehicle(), self },
        })
        if inst_tr.Hit and !inst_tr.HitSky then
            hitscan = true
        end
        -- debugoverlay.Line(self:GetMuzzleOrigin(), self:GetMuzzleOrigin() + threshold, 2, hitscan and Color(255, 0, 255) or Color(255, 255, 255))
    end

    if shootent or not hitscan or fixed_spread then
        local d = math.random() -- self:GetNthShot() / self:GetCapacity()
        for i = 1, num do
            local new_dir = Angle(dir)
            if fixed_spread then
                local sgp_x, sgp_y = self:GetShotgunPattern(i, d)
                new_dir = anglerotate(new_dir, Angle(sgp_x, sgp_y, 0) * 36 * 1.4142135623730)
                if pellet_spread then
                    new_dir = anglerotate(new_dir, self:RandomSpread(self:GetValue("ShotgunPelletSpread"), i))
                end
            else
                new_dir = anglerotate(new_dir, self:RandomSpread(spread, i))
            end

            if shootent then
                self:ShootRocket(new_dir)
            elseif hitscan then
                self:GetOwner():FireBullets({
                    Damage = self:GetValue("Damage_Max"),
                    Force = 8,
                    Tracer = tr,
                    TracerName = "tacrp_tracer",
                    Num = 1,
                    Dir = new_dir:Forward(),
                    Src = self:GetMuzzleOrigin(),
                    Spread = Vector(),
                    IgnoreEntity = self:GetOwner():GetVehicle(),
                    Distance = dist,
                    HullSize = (self:IsShotgun() and i % 2 == 0) and TacRP.ShotgunHullSize or 0,
                    Callback = function(att, btr, dmg)
                        local range = (btr.HitPos - btr.StartPos):Length()

                        self:AfterShotFunction(btr, dmg, range, self:GetValue("Penetration"), {})
                        -- if SERVER then
                        --     debugoverlay.Cross(btr.HitPos, 4, 5, Color(255, 0, 0), false)
                        -- else
                        --     debugoverlay.Cross(btr.HitPos, 4, 5, Color(255, 255, 255), false)
                        -- end
                    end
                })
            else
                TacRP:ShootPhysBullet(self, self:GetMuzzleOrigin(),
                    new_dir:Forward() * self:GetValue("MuzzleVelocity"),
                    { HullSize = (self:IsShotgun() and i % 2 == 0) and TacRP.ShotgunHullSize or 0, })
            end
        end
    else
        local new_dir = Angle(dir)
        local new_spread = spread
        -- if pellet_spread then
        --     new_spread = self:GetValue("ShotgunPelletSpread")
        --     new_dir:Add(self:RandomSpread(spread, 0))
        -- end

        -- Try to use Num in FireBullets if at all possible, as this is more performant and better for damage calc compatibility
        -- Also it generates nice big numbers in various hit number addons instead of a buncha small ones.
        self:GetOwner():FireBullets({
            Damage = self:GetValue("Damage_Max"),
            Force = 8,
            Tracer = tr,
            TracerName = "tacrp_tracer",
            Num = num,
            Dir = new_dir:Forward(),
            Src = self:GetMuzzleOrigin(),
            Spread = Vector(new_spread, new_spread, 0),
            IgnoreEntity = self:GetOwner():GetVehicle(),
            Distance = dist,
            Callback = function(att, btr, dmg)
                local range = (btr.HitPos - btr.StartPos):Length()

                if IsValid(btr.Entity) and (not SINGLEPLAYER and TacRP.ConVars["client_damage"]:GetBool()) then
                    if CLIENT then
                        net.Start("tacrp_clientdamage")
                        net.WriteEntity(self)
                        net.WriteEntity(btr.Entity)
                        net.WriteVector(btr.Normal)
                        net.WriteVector(btr.Entity:WorldToLocal(btr.HitPos))
                        net.WriteUInt(btr.HitGroup, 8)
                        net.WriteFloat(range)
                        net.WriteFloat(self:GetValue("Penetration"))
                        net.WriteUInt(0, 4)
                        net.SendToServer()
                    else
                        self:AfterShotFunction(btr, dmg, range, self:GetValue("Penetration"), { [btr.Entity] = true })
                    end
                else
                    self:AfterShotFunction(btr, dmg, range, self:GetValue("Penetration"), {})
                end

                if SERVER then
                    debugoverlay.Cross(btr.HitPos, 4, 5, Color(255, 0, 0), false)
                else
                    debugoverlay.Cross(btr.HitPos, 4, 5, Color(255, 255, 255), false)
                end
            end
        })
    end

    if self:GetBlindFireMode() == TacRP.BLINDFIRE_KYS then
        local self_dir = self:GetShootDir(true):Forward()
        local dmg = DamageInfo()
        dmg:SetDamage(self:GetValue("Damage_Max") * 2 * (self:GetBodyDamageMultipliers()[HITGROUP_HEAD] or 1))
        dmg:SetDamageType(self:GetValue("DamageType") or DMG_BULLET)
        dmg:SetInflictor(self)
        dmg:SetAttacker(self:GetOwner())
        dmg:SetDamagePosition(self:GetOwner():GetPos() + Vector(0, 0, 72))
        dmg:SetDamageForce((self_dir + VectorRand() * 0.5) * math.Rand(1000, 6000))
        local self_tr = util.TraceLine({
            start = self:GetMuzzleOrigin(),
            endpos = self:GetMuzzleOrigin() + self_dir * 16,
            mask = MASK_SHOT,
            filter = { self },
        })
        self_tr.HitGroup = HITGROUP_HEAD
        TacRP.CancelBodyDamage(self:GetOwner(), dmg, HITGROUP_HEAD)
        self:GetOwner():DispatchTraceAttack(dmg, self_tr, self_dir)
    end
end

function SWEP:Weapon_JamLogic( gun2 )
    if util.SharedRandom("tacRP_shootChance", 0, 1) > self:GetJamChance(false) then
        return
    end

    local ret = self:RunHook("Hook_PreJam")
    if ret == true then
        return
    end

    local ammo_per_shot = self:GetValue("AmmoPerShot")
    if self:GetValue("DualAkimbo") then
        if self:A_GetClip( not gun2 ) < ammo_per_shot then
            self:PlayAnimation( anim_akimbo["this_last_other_empty"][gun2] )
        else
            self:PlayAnimation( anim_akimbo["this_last"][gun2] )
        end
    elseif self:GetBlindFire() then
        self:PlayAnimation("blind_dryfire")
    else
        self:PlayAnimation("dryfire")
    end

    self:EmitSound(self:GetValue("Sound_Jam"), 75, 100, 1, CHAN_ITEM)
    self:A_SetBurstCount( gun2, 0 )
    self:SetPatternCount( 0 )
    self:A_SetNextFire( gun2, CurTime() + self:GetValue("JamWaitTime") )
    if self:GetValue("JamTakesRound") then
        self:A_TakeAmmo( gun2, self:GetValue("AmmoPerShot") )
    end
    if self:A_GetClip( gun2 ) > 0 and not self:GetValue("JamSkipFix") then
        self:SetJammed(true)
    end
    self:RunHook("Hook_PostJam")

    return true
end

function SWEP:Weapon_Effects( gun2 )
    local dualakimbo = self:GetValue("DualAkimbo")
    local owner = self:GetOwner()
    owner:DoCustomAnimEvent(PLAYERANIMEVENT_ATTACK_PRIMARY, 0)

    if CLIENT and owner == LocalPlayer() then
        self:DoMuzzleLight()
    elseif game.SinglePlayer() then
        self:CallOnClient("DoMuzzleLight")
    end

    local force_right = nil
    if dualakimbo then
        force_right = gun2
    end

    -- ejection
    local ejectdelay = self:GetValue("EjectDelay")
    if ejectdelay == 0 then
        self:DoEject(nil, force_right)
    else
        self:SetTimer(ejectdelay, function()
            self:DoEject(nil, force_right)
        end)
    end

    local effect_right = nil
    if dualakimbo then
        effect_right = gun2
    end
    self:DoEffects(nil, effect_right)
    if self:GetValue("EffectsDoubled") then
        self:DoEffects(true, force_right)
        if ejectdelay == 0 then
            self:DoEject(true, force_right)
        else
            self:SetTimer(ejectdelay, function()
                self:DoEject(true, force_right)
            end)
        end
    end
end

-- akimbo buddies
function SWEP:A_GetNextFire( gun2 )
    return gun2 and self:GetNextSecondaryFire() or self:GetNextPrimaryFire()
end
function SWEP:A_GetBurstCount( gun2 )
    return gun2 and self:GetBurstCount2() or self:GetBurstCount()
end
function SWEP:A_GetClip( gun2 )
    return gun2 and self:Clip2() or self:Clip1()
end
function SWEP:A_GetMaxClip( gun2 )
    return gun2 and self:GetMaxClip2() or self:GetMaxClip1()
end
function SWEP:A_GetNthShot( gun2 )
    return gun2 and self:GetNthShot2() or self:GetNthShot()
end

function SWEP:A_SetNextFire( gun2, value )
    if gun2 then
        self:SetNextSecondaryFire( value )
    else
        self:SetNextPrimaryFire( value )
    end
end
function SWEP:A_SetBurstCount( gun2, value )
    if gun2 then
        self:SetBurstCount2( value )
    else
        self:SetBurstCount( value )
    end
end
function SWEP:A_SetClip( gun2, value )
    if gun2 then
        self:SetClip2( value )
    else
        self:SetClip1( value )
    end
end
function SWEP:A_SetNthShot( gun2, value )
    if gun2 then
        self:SetNthShot2( value )
    else
        self:SetNthShot( value )
    end
end

function SWEP:A_TakeAmmo( gun2, value )
    self:A_SetClip( gun2, math.max( 0, self:A_GetClip( gun2 ) - value ) )
end

-- this one is just used by the akimbo firing animation
function SWEP:A_GetLastShot( gun2 )
    return self:A_GetNextFire( gun2 ) - (60/self:GetRPM())
end