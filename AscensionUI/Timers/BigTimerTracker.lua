local Addon = select(2, ...)

local timer = nil

local SoundThreshold = 5

local DigitCoord = {
   [0] = { 0, 0.25, 0, 0.33203125 },
   [1] = { 0.25, 0.5, 0, 0.33203125 },
   [2] = { 0.5, 0.75, 0, 0.33203125 },
   [3] = { 0.75, 1, 0, 0.33203125 },
   [4] = { 0, 0.25, 0.33203125, 0.6640625 },
   [5] = { 0.25, 0.5, 0.33203125, 0.6640625 },
   [6] = { 0.5, 0.75, 0.33203125, 0.6640625 },
   [7] = { 0.75, 1, 0.33203125, 0.6640625 },
   [8] = { 0, 0.25, 0.6640625, 1 },
   [9] = { 0.25, 0.5, 0.6640625, 1 }
}

local DigitHalfWidth = {
    [0] = 35,
    [1] = 14,
    [2] = 33,
    [3] = 32,
    [4] = 36,
    [5] = 32,
    [6] = 33,
    [7] = 29,
    [8] = 31,
    [9] = 31
}

local function DisplayTime(tens, ones)
    timer.AnimGroup:Stop()

    if timer.seconds < 0 then
        Addon:StopTimer()
        return
    end
    timer.AnimGroup:Play()

    timer.digit1:SetSize(256, 170)
    timer.digit1.glow:SetSize(256, 170)

    timer.digit2:SetSize(256, 170)
    timer.digit2.glow:SetSize(256, 170)

    if tens > 0 then
        timer.digit1:SetTexCoord(unpack(DigitCoord[tens]))
        timer.digit1.glow:SetTexCoord(unpack(DigitCoord[tens]))
        -- set digit 1 position 
        local hw = DigitHalfWidth[tens] + DigitHalfWidth[ones]
        timer.digit1:SetPoint("CENTER", UIParent, "CENTER", -hw, 0)
        timer.digit1.glow:SetPoint("CENTER", timer.digit1)
        -- set digit 2 position
        timer.digit2:SetPoint("CENTER", UIParent, "CENTER", hw, 0)
        timer.digit2.glow:SetPoint("CENTER", timer.digit2)
    else
        timer.digit1:SetTexCoord(0, 0, 0, 0)
        timer.digit1.glow:SetTexCoord(0, 0, 0, 0)

        timer.digit1:SetPoint("CENTER", UIParent)
        timer.digit1.glow:SetPoint("CENTER", timer.digit1)

        timer.digit2:SetPoint("CENTER", UIParent)
        timer.digit2.glow:SetPoint("CENTER", timer.digit2)
    end

    if tens == 0 and ones == 0 and timer.isChallenge then
        timer.digit2:SetSize(256, 256)
        timer.digit2.glow:SetSize(256, 256)
        PlaySoundFile("Interface\\AddOns\\AscensionUI\\Sounds\\UI_COUNTDOWN_FINISHED.wav", "SFX")
        timer.digit2:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\Challenges-Logo")
        timer.digit2.glow:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\Challenges-LogoGlow")
        timer.digit2:SetTexCoord(0, 1, 0, 1)
        timer.digit2.glow:SetTexCoord(0, 1, 0, 1)
    else
        if timer.seconds <= SoundThreshold then
            PlaySoundFile("Interface\\AddOns\\AscensionUI\\Sounds\\UI_COUNTDOWN_TIMER.wav", "SFX")
        end
        timer.digit2:SetTexCoord(unpack(DigitCoord[ones]))
        timer.digit2.glow:SetTexCoord(unpack(DigitCoord[ones]))
    end
end

local function Tick()
    local seconds = timer.seconds
    local tens = floor(seconds / 10)
    local ones = seconds % 10

    DisplayTime(tens, ones)
    timer.seconds = timer.seconds - 1
end

local function CreateDigitTexture(parent)
    local digit = parent:CreateTexture(nil, "ARTWORK")
    digit:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\BigTimerNumbers")
    digit:SetPoint("CENTER")
    digit.glow = parent:CreateTexture(nil, "BACKGROUND")
    digit.glow:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\BigTimerNumbersGlow")
    digit.glow:SetPoint("CENTER", digit)
    digit.glow:SetVertexColor(0, 0, 0, 1)

    digit:SetSize(256, 170)
    digit.glow:SetSize(256, 170)
    return digit
end

local function CreateAnimationGroup()
    local ag = timer:CreateAnimationGroup()
    ag.Scale1 = ag:CreateAnimation("Scale")
    ag.Scale2 = ag:CreateAnimation("Scale")
    ag.Alpha1 = ag:CreateAnimation("Alpha")
    ag.Alpha2 = ag:CreateAnimation("Alpha")

    ag.Scale1:SetStartDelay(0)
    ag.Scale1:SetOrder(1)
    ag.Scale1:SetDuration(0.001)

    ag.Scale2:SetStartDelay(0.05)
    ag.Scale2:SetOrder(2)
    ag.Scale2:SetDuration(0.5)

    ag.Scale1:SetScale(0, 0)
    ag.Scale2:SetScale(1000, 1000)

    ag.Alpha1:SetChange(1)
    ag.Alpha1:SetOrder(1)
    ag.Alpha1:SetDuration(0.01)
    ag.Alpha1:SetStartDelay(0)

    ag.Alpha1:SetScript("OnStop", function(self)
        self:GetParent():GetParent():SetAlpha(1)
    end)
    ag.Alpha1:SetScript("OnFinished", function(self)
        self:GetParent():GetParent():SetAlpha(1)
    end)
    ag.Alpha1:SetScript("OnPlay", function(self)
        self:GetParent():GetParent():SetAlpha(0)
    end)

    ag.Alpha2:SetChange(-1)
    ag.Alpha2:SetOrder(3)
    ag.Alpha2:SetDuration(0.5)
    ag.Alpha2:SetStartDelay(0.1)

    timer.AnimGroup = ag
end
-- same as Addon:StartTimer but displays the challenge mode logo at the end of the timer
function Addon:StartChallengeTimer(seconds)
    if seconds > 60 then
        error("Cannot start a countdown timer longer than 60 seconds")
        return
    end
    Addon:StartTimer(seconds)
    timer.isChallenge = true
end

function Addon:StartTimer(seconds)
    if seconds > 60 then
        error("Cannot start a countdown timer longer than 60 seconds")
        return
    end

    if Addon:IsTimerPlaying() then
        Addon:StopTimer()
    end

    if not timer then
        timer = CreateFrame("Frame", "BigTimer", UIParent)
        timer:SetPoint("CENTER")
        timer:SetSize(512, 512)
        timer.digit1 = CreateDigitTexture(timer)
        timer.digit2 = CreateDigitTexture(timer)
        CreateAnimationGroup()
    end

    timer.digit1:SetSize(256, 170)
    timer.digit1.glow:SetSize(256, 170)

    timer.digit2:SetSize(256, 170)
    timer.digit2.glow:SetSize(256, 170)

    timer.digit1:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\BigTimerNumbers")
    timer.digit2:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\BigTimerNumbers")

    timer.digit1.glow:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\BigTimerNumbersGlow")
    timer.digit2.glow:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\BigTimerNumbersGlow")

    local tens = floor(seconds / 10)
    local ones = seconds % 10
    timer.seconds = seconds - 1

    DisplayTime(tens, ones)
    
    if seconds <= SoundThreshold then
        PlaySoundFile("Interface\\AddOns\\AscensionUI\\Sounds\\UI_COUNTDOWN_TIMER.wav", "SFX")
    end
    timer.AnimGroup:Stop()
    timer.AnimGroup:Play()
    timer.ticker = C_Timer.NewTicker(1, Tick, timer.seconds + 2)

    timer:Show()
end

function Addon:StopTimer()
    timer.ticker:Cancel()
    timer.ticker = nil
    timer.isChallenge = false
    timer:Hide()
end

function Addon:IsTimerPlaying()
    return timer and timer.ticker ~= nil
end

