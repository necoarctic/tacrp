local SINGLEPLAYER = game.SinglePlayer()
function SWEP:Think()
    local owner = self:GetOwner()

    local stop = self:RunHook("Hook_PreThink")
    if stop then return end

    self:ThinkBurst()

    if self:GetPatternCount() > 0 and (self:GetRecoilAmount() == 0 or self:GetReloading()) then
        self:SetPatternCount(0)
    end

    if (SERVER or !game.SinglePlayer()) then
        if owner:KeyPressed(TacRP.IN_CUSTOMIZE) then
            if (self:GetScopeLevel() == 0) then
                self:ToggleCustomize(!self:GetCustomize())
            else
                if !self:GetValue("AlwaysPeek") then
                    local shouldpeek = !self:GetPeeking()

                    if (owner:GetInfoNum("tacrp_togglepeek", 0) == 0) then
                        shouldpeek = true
                    end

                    self:SetPeeking(shouldpeek)

                    if (self:GetSightAmount() > 0) then
                        self:SetLastScopeTime(CurTime())
                    end
                end
            end
        elseif (owner:KeyReleased(TacRP.IN_CUSTOMIZE) and !self:GetValue("AlwaysPeek") and owner:GetInfoNum("tacrp_togglepeek", 0) == 0 and self:GetPeeking()) then
            self:SetPeeking(false)

            if (self:GetSightAmount() > 0) then
                self:SetLastScopeTime(CurTime())
            end
        end

        if owner:KeyPressed(TacRP.IN_TACTICAL) then
            self:ToggleTactical()
        end
    end

    self:ThinkRecoil()

    self:ThinkSprint()

    self:ThinkGrenade()

    self:ThinkReload()

    self:ThinkSights()

    self:ThinkFreeAim()

    self:ThinkBlindFire()

    self:ProcessTimers()

    self:ThinkLockOn()

    self:ThinkHoldBreath()

    if self:GetValue("Melee") and self:GetOwner():KeyPressed(TacRP.IN_MELEE) then
        self:Melee()
        return
    end

    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and self:GetValue("TacticalThink") and self:GetTactical() then
        self:GetValue("TacticalThink")(self)
    end

    -- if IsValid(self:GetOwner()) and self:GetTactical() and self:GetValue("Minimap") and (SERVER and !game.SinglePlayer()) and (self.NextRadarBeep or 0) < CurTime() then
    --     self.NextRadarBeep = CurTime() + 1.5
    --     local f = RecipientFilter()
    --     f:AddPVS(self:GetPos())
    --     f:RemovePlayer(self:GetOwner())
    --     local s = CreateSound(self, "plats/elevbell1.wav", f)
    --     s:SetSoundLevel(75)
    --     s:PlayEx(0.25, 105)
    -- end

    if self:GetJammed() and !self:StillWaiting() and TacRP.ConVars["jam_autoclear"]:GetBool() then
        local t = self:PlayAnimation("jam", 0.75, true, true)
        self:GetOwner():DoCustomAnimEvent(PLAYERANIMEVENT_CANCEL_RELOAD, t * 1000)
        self:SetJammed(false)
    end

    if self:GetNextIdle() < CurTime() and (SERVER or !game.SinglePlayer()) then
        self:Idle()
    end

    if self:GetValue("Bipod") and self:GetInBipod() and !self:CanBipod() then
        self:ExitBipod()
    end

    if CLIENT and (IsFirstTimePredicted() or game.SinglePlayer()) then

        self:ThinkNearWall()

        if IsValid(self.MuzzleLight) then
            if (self.MuzzleLightEnd or 0) < UnPredictedCurTime() then
                self.MuzzleLight:Remove()
                self.MuzzleLight = nil
            else
                self.MuzzleLight:SetBrightness( math.Remap( UnPredictedCurTime(), self.MuzzleLightStart, self.MuzzleLightEnd, self.MuzzleLightBrightness, 0 ) )
                self.MuzzleLight:SetFOV( math.Remap( UnPredictedCurTime(), self.MuzzleLightStart, self.MuzzleLightEnd, self.MuzzleLightFOV, 60 ) )
                self.MuzzleLight:Update()
            end
        end

        if !self.LoadedPreset then
            self.LoadedPreset = true

            if TacRP.ConVars["autosave"]:GetBool() and TacRP.ConVars["free_atts"]:GetBool() then
                self:LoadPreset()
                -- self:DoDeployAnimation()
            end
        end

        self:CanBipod()
    end

    self:RunHook("Hook_PostThink")

    -- Replace engine calls of PrimaryAttack cause they don't run due to NextPrimaryFire
    -- they don't run on the CLIENT in singleplayer
    if SINGLEPLAYER and SERVER or not SINGLEPLAYER then
        if owner:KeyDown(IN_ATTACK) then
            self:Player_Primary()
        end
        if owner:KeyDown(IN_ATTACK2) then
            self:Player_Secondary()
        end
    end

    if owner:GetInfoNum("tacrp_autoreload", 0) ~= 0 then
        if self:GetValue("DualAkimbo") then
            if self:A_GetClip( false ) == 0 and self:A_GetClip( true ) == 0 then
                self:Reload()
            end
        else
            if self:A_GetClip( false ) == 0 then
                self:Reload()
            end
        end
    end
end

function SWEP:ThinkBurst()
    local max_burst = self:GetMaxBurst()
    local owner = self:GetOwner()
    if not IsValid(owner) then
        owner = nil
    end
    
    for i=1, self:GetValue("DualAkimbo") and 2 or 1 do
        local gun2 = i == 2
        local key = gun2 and IN_ATTACK2 or IN_ATTACK
        local attack_down = owner and owner:KeyDown( key ) or false
        local burst_count = self:A_GetBurstCount( gun2 )
        local dryfire = self:A_GetClip( gun2 ) < self:GetValue("AmmoPerShot") or self:GetJammed()
        local max_burst = dryfire and 1 or max_burst
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