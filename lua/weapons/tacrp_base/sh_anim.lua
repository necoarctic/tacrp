function SWEP:PlayAnimation(seq, mult, lock, doidle)
    local vm = self:GetVM()
    if not vm then return end
    if not vm:IsValid() then return end

    mult = mult or 1
    lock = lock or false
    if doidle == nil then
        doidle = true
    end
    local anim = self:TranslateSequence(seq)
    local reverse = false

    if mult < 0 then
        reverse = true
        mult = -mult
    end

    if isstring(anim) then
        seq = vm:LookupSequence(anim)
    end

    if seq == -1 then return end

    self.CurrentAnimation = anim
    self.CurrentSeqeunce = seq

    local time = vm:SequenceDuration(seq)
    time = time * mult
    vm:SendViewModelMatchingSequence(seq)

    if mult == 0 then
        vm:SetCycle(0)
        vm:SetPlaybackRate(mult)
    elseif reverse then
        vm:SetCycle(1)
        vm:SetPlaybackRate(-1 / mult)
    else
        vm:SetCycle(0)
        vm:SetPlaybackRate(1 / mult)
    end

    if lock then
        self:SetAnimLockTime(CurTime() + time)
    end

    if doidle and !self.NoIdle then
        self:SetNextIdle(CurTime() + time)
    else
        self:SetNextIdle(math.huge)
    end

    self:SetLastProceduralFireTime(0)

    return time
end

function SWEP:IdleAtEndOfAnimation()
    local vm = self:GetVM()
    local cyc = vm:GetCycle()
    local duration = vm:SequenceDuration()
    local rate = vm:GetPlaybackRate()

    local time = (1 - cyc) * (duration / rate)

    self:SetNextIdle(CurTime() + time)
end

function SWEP:Idle()
    if self:GetPrimedGrenade() then return end

    local jammed = self:GetJammed()
    local akimbo = self:GetValue("DualAkimbo")
    local left_empty = jammed or self:A_GetClip( false ) == 0
    local right_empty = akimbo and (jammed or self:A_GetClip( true ) == 0)

    if self:GetBlindFire() then
        if left_empty then
            self:PlayAnimation("blind_dryfire", 0)
        else
            self:PlayAnimation("blind_idle")
        end
    elseif akimbo then
        if left_empty and right_empty then
            self:PlayAnimation("dryfire", 0)
        -- TODO PLEASE get rid of these HasSequence checks
        elseif left_empty and self:HasSequence("idle_left_empty") then
            self:PlayAnimation("idle_left_empty")
        elseif right_empty and self:HasSequence("idle_right_empty") then
            self:PlayAnimation("idle_right_empty")
        else
            self:PlayAnimation("idle")
        end
    else
        if left_empty then
            self:PlayAnimation("dryfire", 0)
        else
            self:PlayAnimation("idle")
        end
    end

    self:SetNextIdle( math.huge )
end
