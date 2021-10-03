local Addon = select(2, ...)
local KeystoneFrame = CreateFrame("FRAME", "AscensionUI.MythicKeystone.KeystoneFrame", UIParent)
Addon.MythicKeystone.KeystoneFrame = KeystoneFrame

local MythicKeystone = Addon.MythicKeystone

local TimerValue = 0
local TotalTime = 0
local DeathCountValue = 0
local Bosses = 0
local BossesDone = 0
local Minions = 0
local MinionsDone = 0
local KeystoneStarting = false
local EnteredWorld = false 
local KeystoneFailed = false


local RingOfLaw = {
    [9027] = true, -- NPC_GOROSH_THE_DERVISH
    [9028] = true, -- NPC_GRIZZLE
    [9029] = true, -- NPC_EVISCERATOR
    [9030] = true, -- NPC_OKTHOR_THE_BREAKER
    [9031] = true, -- NPC_ANUBSHIAH
    [9032] = true, -- NPC_HEDRUM_THE_CREEPER
}

local TrackedBosses = {}

local ENEMY_FORCES_FORMAT = "Enemy Forces"
local SLAIN_PERCENT_FORMAT = "%.2f%%"
local BOSSES_FORMAT = "%01d/%01d Bosses Slain"
local BOSS_FORMAT = "%01d/%01d - %s"


local TIME_FOR_4 = 0.25
local TIME_FOR_3 = 0.5

local ui_x, ui_y = GetScreenWidth(), GetScreenHeight()

-- Keystone Frame
KeystoneFrame:SetSize(297, 86)
KeystoneFrame:SetPoint("TOPRIGHT", -(0.12 * ui_x), -(0.34 * ui_y))
KeystoneFrame:EnableMouse(true)
KeystoneFrame:SetMovable(true)
KeystoneFrame:RegisterForDrag("LeftButton")

KeystoneFrame.Texture = KeystoneFrame:CreateTexture(nil, "ARTWORK")
KeystoneFrame.Texture:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ObjectiveTracker")
KeystoneFrame.Texture:SetAllPoints()
KeystoneFrame.Texture:SetTexCoord(0.00195312, 0.582031, 0.00195312, 0.169922)

KeystoneFrame.Text = KeystoneFrame:CreateFontString(nil, "OVERLAY")
KeystoneFrame.Text:SetPoint("TOPLEFT", KeystoneFrame, "TOPLEFT", 22, -19)
KeystoneFrame.Text:SetFontObject(GameFontNormal)
KeystoneFrame.Text:SetText("Dungeon Name")
KeystoneFrame.Text:SetAlpha(0.95)

KeystoneFrame.Toggle = CreateFrame("CheckButton", nil, KeystoneFrame, "UICheckButtonTemplate")
KeystoneFrame.Toggle:SetPoint("TOPRIGHT", KeystoneFrame, "TOPRIGHT", -28, -17)
KeystoneFrame.Toggle:SetSize(16, 16)

local checked = KeystoneFrame.Toggle:GetCheckedTexture()
checked:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ObjectiveTracker")
checked:SetTexCoord(0.714844, 0.746094, 0.130859, 0.162109)

local normal = KeystoneFrame.Toggle:GetNormalTexture()
normal:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ObjectiveTracker")
normal:SetTexCoord(0.621094, 0.652344, 0.130859, 0.162109)

local pushed = KeystoneFrame.Toggle:GetPushedTexture()
pushed:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ObjectiveTracker")
pushed:SetTexCoord(0.65625, 0.6875, 0.130859, 0.162109)

KeystoneFrame.Toggle:SetScript("OnClick", function(self)
    local main = self:GetParent().Main
    if self:GetChecked() then
        main:Hide()
    else
        main:Show()
    end
end)

KeystoneFrame.Lock = CreateFrame("CheckButton", nil, KeystoneFrame, "UICheckButtonTemplate")
KeystoneFrame.Lock:SetPoint("RIGHT", KeystoneFrame.Toggle, "LEFT", -4, 0)
KeystoneFrame.Lock:SetSize(20, 20)

KeystoneFrame.Lock.Border = KeystoneFrame.Lock:CreateTexture(nil, "BACKGROUND")
KeystoneFrame.Lock.Border:SetAllPoints()
KeystoneFrame.Lock.Border:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\LockButton-Border")

checked = KeystoneFrame.Lock:GetCheckedTexture()
checked:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\LockButton-Locked-Up")

normal = KeystoneFrame.Lock:GetNormalTexture()
normal:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\LockButton-Unlocked-Up")

pushed = KeystoneFrame.Lock:GetPushedTexture()
pushed:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\LockButton-Unlocked-Down")

KeystoneFrame.Lock:SetScript("OnClick", function(self) 
    if self:GetChecked() then
        KeystoneFrame:SetScript("OnDragStart", nil)
        KeystoneFrame:SetScript("OnDragStop", nil)
        MythicKeystone.CDB.Locked = true
    else
        KeystoneFrame:SetScript("OnDragStart", KeystoneFrame.StartMoving)
        KeystoneFrame:SetScript("OnDragStop", KeystoneFrame.StopMovingOrSizing)
        MythicKeystone.CDB.Locked = false
    end
end)


KeystoneFrame:Hide()

KeystoneFrame:SetScript("OnShow", function(self)
    _G["WatchFrame"]:Hide()
end)
KeystoneFrame:SetScript("OnHide", function(self)
    _G["WatchFrame"]:Show()
end)

-- Main
local Main = CreateFrame("FRAME", "AscensionUI.MythicKeystone.Main", KeystoneFrame, nil)
KeystoneFrame.Main = Main
Main:SetSize(251, 87)
Main:SetPoint("TOPLEFT", KeystoneFrame, "TOPLEFT", 14, -39)
--Main:SetMovable(true)
--Main:EnableMouse(true)
--Main:RegisterForDrag("LeftButton")
--Main:SetScript("OnDragStart", Main.StartMoving)
--Main:SetScript("OnDragStop", Main.StopMovingOrSizing)
Main:Hide()

-- Main.TimerBGBack
Main.TimerBGBack = Main:CreateTexture("AscensionUI.MythicKeystone.Main.TimerBGBack", "BORDER")
Main.TimerBGBack:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
Main.TimerBGBack:SetPoint("BOTTOM", 0, 13)
Main.TimerBGBack:SetSize(223, 11)
Main.TimerBGBack:SetTexCoord(0.633789, 0.851562, 0.183594, 0.205078)

-- Main.TimerBGBack
Main.TimerBG = Main:CreateTexture("AscensionUI.MythicKeystone.Main.TimerBG", "BORDER")
Main.TimerBG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
Main.TimerBG:SetPoint("BOTTOM", 0, 13)
Main.TimerBG:SetSize(223, 11)
Main.TimerBG:SetTexCoord(0.633789, 0.851562, 0.158203, 0.179688)

-- Main.TimerOverlay
Main.TimerOverlay = Main:CreateTexture("AscensionUI.MythicKeystone.Main.TimerOverlay", "OVERLAY")
Main.TimerOverlay:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
Main.TimerOverlay:SetPoint("CENTER", 0, 0)
Main.TimerOverlay:SetSize(261, 87)
Main.TimerOverlay:SetTexCoord(0.606445, 0.861328, 0.220703, 0.390625)

-- Main.Level
Main.Level = Main:CreateFontString(nil, "OVERLAY")
Main.Level:SetFont("Fonts\\FRIZQT__.TTF", 11)
Main.Level:SetFontObject(GameFontNormal)
Main.Level:SetPoint("TOPLEFT", 28, -18)
Main.Level:SetJustifyH("LEFT")

-- Main.StartedDepleted
Main.StartedDepleted = CreateFrame("FRAME", "AscensionUI.MythicKeystone.Main.StartedDepleted", Main, nil)
Main.StartedDepleted:SetSize(19, 20)
Main.StartedDepleted:SetPoint("TOPLEFT", Main, "BOTTOMRIGHT", -43, 72)
Main.StartedDepleted:EnableMouse(true)
Main.StartedDepleted:Hide()

-- Main.StartedDepleted.IconChest
Main.StartedDepleted.IconChest = Main.StartedDepleted:CreateTexture("AscensionUI.MythicKeystone.Main.StartedDepleted.IconChest", "ARTWORK")
Main.StartedDepleted.IconChest:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
Main.StartedDepleted.IconChest:SetPoint("CENTER", 0, 0)
Main.StartedDepleted.IconChest:SetSize(19, 20)
Main.StartedDepleted.IconChest:SetTexCoord(0.182617, 0.201172, 0.802734, 0.841797)

-- Main.StartedDepleted.RedLine
Main.StartedDepleted.RedLine = Main.StartedDepleted:CreateTexture("AscensionUI.MythicKeystone.Main.StartedDepleted.RedLine", "OVERLAY")
Main.StartedDepleted.RedLine:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
Main.StartedDepleted.RedLine:SetPoint("CENTER", 0, 0)
Main.StartedDepleted.RedLine:SetSize(19, 19)
Main.StartedDepleted.RedLine:SetTexCoord(0.0625, 0.0810547, 0.851562, 0.888672)

-- Main.DeathCount
Main.DeathCount = CreateFrame("FRAME", "AscensionUI.MythicKeystone.Main.DeathCount", Main, nil)
Main.DeathCount:SetSize(19, 20)
Main.DeathCount:SetPoint("TOPLEFT", Main, "BOTTOMRIGHT", -37, 43)
Main.DeathCount:EnableMouse(true)
Main.DeathCount:Hide()
Main.DeathCount:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("Player Deaths")
    GameTooltip:Show()
end)
Main.DeathCount:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- Main.DeathCount.Icon
Main.DeathCount.Icon = Main.DeathCount:CreateTexture("AscensionUI.MythicKeystone.Main.DeathCount.RedLine", "ARTWORK")
Main.DeathCount.Icon:SetTexture("Interface\\Minimap\\POIIcons")
Main.DeathCount.Icon:SetPoint("LEFT", 0, 0)
Main.DeathCount.Icon:SetSize(16, 16)
Main.DeathCount.Icon:SetTexCoord(0.5625, 0.6328125, 0, 0.0703125)

-- Main.DeathCount.Count
Main.DeathCount.CountValue = 0
Main.DeathCount.Count = Main.DeathCount:CreateFontString(nil, "OVERLAY")
Main.DeathCount.Count:SetFontObject(GameFontHighlight)
Main.DeathCount.Count:SetPoint("LEFT", Main.DeathCount.Icon, "RIGHT",  1, 0)
Main.DeathCount.Count:SetText("0")

-- Main.StatusBar
Main.StatusBar = CreateFrame("StatusBar", "AscensionUI.MythicKeystone.Main.StatusBar", Main)
Main.StatusBar:SetSize(223, 11)
Main.StatusBar:SetPoint("BOTTOM", 0, 10)

Main.StatusBar:EnableMouse(true)
Main.StatusBar:SetStatusBarColor(0, 0.33, 0.61, 1)
Main.StatusBar:SetMinMaxValues(0, 100)
Main.StatusBar:SetValue(100)

-- Main.StatusBar.Texture
Main.StatusBar.Texture = Main.StatusBar:CreateTexture("AscensionUI.MythicKeystone.Main.StatusBar.Texture", "ARTWORK")
Main.StatusBar.Texture:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
Main.StatusBar.Texture:SetSize(223, 11)
Main.StatusBar.Texture:SetTexCoord(0.606445, 0.824219, 0.394531, 0.416016)

-- Main.StatusBar.BarFor4
Main.StatusBar.BarFor4 = Main.StatusBar:CreateTexture(nil, "OVERLAY")
Main.StatusBar.BarFor4:SetPoint("TOPLEFT", Main.StatusBar, "TOPLEFT", Main.StatusBar:GetWidth() * (1 - TIME_FOR_4) - 4, 0)
Main.StatusBar.BarFor4:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ScenarioTimer-Bar")
Main.StatusBar.BarFor4:SetSize(8, 10)
Main.StatusBar.BarFor4:SetTexCoord(0, 0.5, 0, 1)

-- Main.StatusBar.BarFor3
Main.StatusBar.BarFor3 = Main.StatusBar:CreateTexture(nil, "OVERLAY")
Main.StatusBar.BarFor3:SetPoint("TOPLEFT", Main.StatusBar, "TOPLEFT", Main.StatusBar:GetWidth() * (1 - TIME_FOR_3) - 4, 0)
Main.StatusBar.BarFor3:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ScenarioTimer-Bar")
Main.StatusBar.BarFor3:SetSize(8, 10)
Main.StatusBar.BarFor3:SetTexCoord(0.5, 1, 0, 1)


Main.StatusBar:SetStatusBarTexture(Main.StatusBar.Texture, "BACKGROUND")

local function Reset()
    TimerValue = 0
    TotalTime = 0
    DeathCountValue = 0
    Bosses = 0
    BossesDone = 0
    Minions = 0
    MinionsDone = 0

    MythicKeystone.CDB.LastKeystone = nil

    KeystoneFrame.Text:SetText("")

    for i = 1, 6 do 
        Main["Affix"..i]:Hide()
    end
    
    for i = 1, 20 do 
        Main["BossTracker"..i]:Reset()
        Main["BossTracker"..i]:Hide()
    end
    Main.FinalBossDeathCount:Reset()
    
    Main.TimeLeft:SetText("")
    Main.TimeLeft2:SetText("")
    Main.DeathCount.Count:SetText(0)
    Main.MinionDeathCount.StatusBar.Label:SetText(format(SLAIN_PERCENT_FORMAT, 0))
    Main.MinionDeathCount.Text:SetText(ENEMY_FORCES_FORMAT)
    Main.BossDeathCount.Text:SetText(format(BOSSES_FORMAT, 0, 0))
    Main.BossDeathCount.Icon:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ScenarioIcon-Combat")
    Main.BossDeathCount.Text:SetTextColor(1, 1, 1, 1)
    Main.MinionDeathCount.Icon:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ScenarioIcon-Combat")
    Main.MinionDeathCount.Text:SetTextColor(1, 1, 1, 1)
end

local function LoadKeystone(itemId)
    Reset()
    MythicKeystone.CDB.LastKeystone = itemId
    local keystone = Addon.KeystoneData[itemId]
    local seconds = keystone.timeLimit / 1000

    --print("Loading Keystone", itemId, keystone.instanceName, "+"..keystone.mythicLevel)

    local affixes, affixCount = MythicKeystone:GetAffixes(MythicKeystone.CDB.Week, keystone.mythicLevel)

    Main:ShowUI(keystone.instanceName, keystone.mythicLevel, seconds, keystone.killRequirement, keystone.bossKillRequirement, affixes, affixCount)
end

local function EnsureTimerVisible()
    if not KeystoneFrame:IsVisible() then
        -- we probably just reloaded or something
        local keyid = MythicKeystone.CDB.LastKeystone
        if keyid ~= nil then
            LoadKeystone(keyid)
        end
    end
end

local function UpdateTimer(timeLeft)
    EnsureTimerVisible()
    TimerValue = timeLeft

    Main.StatusBar:SetValue(TimerValue)
    
    Main.TimeLeft:SetText(MythicKeystone:FormatTime(TimerValue))

    local time4 = TotalTime * (1 - TIME_FOR_4)
    local time3 = TotalTime * (1 - TIME_FOR_3)

    if TimerValue > time4 then
        time4 = TimerValue - time4
        Main.TimeLeft2:SetText(MythicKeystone:FormatTime(time4))
        Main.TimeLeft2:SetTextColor(1, 0.843, 0)
        Main.TimeLeft2:Show()

    elseif TimerValue > time3 then
        time3 = TimerValue - time3
        Main.TimeLeft2:SetText(MythicKeystone:FormatTime(time3))
        Main.TimeLeft2:SetTextColor(0.78, 0.78, 0.812)
        Main.TimeLeft2:Show()

    else
        Main.TimeLeft2:Hide()
    end
    
    if TimerValue <= 0 or KeystoneFailed then
        Main.TimeLeft:SetTextColor(0.8, 0.2, 0.2)
        Main.StatusBar.Texture:SetVertexColor(1, 0, 0)
    else
        Main.TimeLeft:SetTextColor(1, 1, 1)
    end

    local deadBosses = 0
    for bossId, frame in pairs(TrackedBosses) do
        if IsMythicPlusBossKilled(bossId) then
            frame:Kill()
            deadBosses = deadBosses + 1
        else
            frame:Revive()
        end
    end

    BossesDone = deadBosses
    Main:UpdateBossesComplete()
end

-- Main.TimeLeft
Main.TimeLeft = Main.StatusBar:CreateFontString(nil, "OVERLAY")
Main.TimeLeft:SetFont("Fonts\\FRIZQT__.TTF", 20, "THICKOUTLINE")
Main.TimeLeft:SetPoint("BOTTOMLEFT", Main.StatusBar, "TOPLEFT",  8, 5)
Main.TimeLeft:SetText("00:00")
Main.TimeLeft:SetJustifyH("LEFT")

-- Main.TimeLeft2
Main.TimeLeft2 = Main.StatusBar:CreateFontString(nil, "OVERLAY")
Main.TimeLeft2:SetFont("Fonts\\FRIZQT__.TTF", 12)
Main.TimeLeft2:SetPoint("LEFT", Main.TimeLeft, "RIGHT",  4, 0)
Main.TimeLeft2:SetText("00:00")
Main.TimeLeft2:SetJustifyH("LEFT")

-- set count frame checked
local function SetObjectiveChecked(self, checked)
    if checked then
        self.Text:SetTextColor(0.5, 0.5, 0.5)
        self.Icon:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ScenarioIcon-Check")
    else
        self.Text:SetTextColor(1, 1, 1)
        self.Icon:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ScenarioIcon-Combat")
    end
end

local function SetObjectiveTarget(self, name)
    self.bossName = name
    self.Text:SetText(format(BOSS_FORMAT, 0, 1, name or ""))
    self:SetChecked(false)
end

local function ResetTarget(self)
    self:SetChecked(false)
    self:SetTarget(nil)
end

local function KillObjective(self)
    local text = self.bossName
    local deathTime = MythicKeystone.CDB.BossDeathTime and MythicKeystone.CDB.BossDeathTime[self.bossName]
    if deathTime then
        text = text .. " ("..MythicKeystone:FormatTime(deathTime)..")"
    end
    self.Text:SetText(format(BOSS_FORMAT, 1, 1, text))
    self:SetChecked(true)

    BossesDone = BossesDone + 1
    BossesDone = min(BossesDone, Bosses)
    Main:UpdateBossesComplete()
end

local function ReviveObjective(self)
    self.Text:SetText(format(BOSS_FORMAT, 0, 1, self.bossName))
    self:SetChecked(false)
end

-- Main.BossDeathCount
Main.BossDeathCount = CreateFrame("FRAME", nil, Main)
Main.BossDeathCount:SetSize(260, 20)
Main.BossDeathCount:SetPoint("TOP", Main, "BOTTOM",  0, -6)

-- Main.DeathCount.Icon
Main.BossDeathCount.Icon = Main.BossDeathCount:CreateTexture(nil, "ARTWORK")
Main.BossDeathCount.Icon:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ScenarioIcon-Combat")
Main.BossDeathCount.Icon:SetPoint("TOPLEFT", Main.BossDeathCount, "TOPLEFT", 0, 0)
Main.BossDeathCount.Icon:SetSize(16, 16)

-- Main.BossDeathCount.Text
Main.BossDeathCount.Text = Main.BossDeathCount:CreateFontString(nil, "OVERLAY")
Main.BossDeathCount.Text:SetFontObject(GameFontHighlight)
Main.BossDeathCount.Text:SetPoint("LEFT", Main.BossDeathCount.Icon, "RIGHT",  4, 0)
Main.BossDeathCount.Text:SetText(format(BOSSES_FORMAT, 0, 0))

Main.BossDeathCount.SetChecked = SetObjectiveChecked

Main.BossDeathCount.Toggle = CreateFrame("CheckButton", nil, Main.BossDeathCount, "UICheckButtonTemplate")
Main.BossDeathCount.Toggle:SetPoint("RIGHT", Main.BossDeathCount, "RIGHT", 0, 0)
Main.BossDeathCount.Toggle:SetSize(16, 16)

local checked = Main.BossDeathCount.Toggle:GetCheckedTexture()
checked:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ObjectiveTracker")
checked:SetTexCoord(0.714844, 0.746094, 0.130859, 0.162109)

local normal = Main.BossDeathCount.Toggle:GetNormalTexture()
normal:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ObjectiveTracker")
normal:SetTexCoord(0.621094, 0.652344, 0.130859, 0.162109)

local pushed = Main.BossDeathCount.Toggle:GetPushedTexture()
pushed:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ObjectiveTracker")
pushed:SetTexCoord(0.65625, 0.6875, 0.130859, 0.162109)

Main.BossDeathCount.Toggle:SetScript("OnClick", function(self)
    local main = self:GetParent().Main
    if self:GetChecked() then
        for i = 1, 20 do
            local frame = Main["BossTracker"..i]
            if frame:IsVisible() then
                frame:Hide()
            end
        end
        Main.MinionDeathCount:SetPoint("TOP", Main.FinalBossDeathCount, "BOTTOM", -20, 0)

    else
        local last = nil
        for i = 1, 20 do
            local frame = Main["BossTracker"..i]
            if frame.bossName then
                frame:Show()
                last = frame
            end
        end
        Main.MinionDeathCount:SetPoint("TOP", last, "BOTTOM", -20, 0)
    end
end)
-- Main.FinalBossDeathCount
Main.FinalBossDeathCount = CreateFrame("FRAME", nil, Main.BossDeathCount)
Main.FinalBossDeathCount:SetSize(260, 20)
Main.FinalBossDeathCount:SetPoint("TOP", Main.BossDeathCount, "BOTTOM", 20, 0)

-- Main.FinalBossDeathCount.Icon
Main.FinalBossDeathCount.Icon = Main.FinalBossDeathCount:CreateTexture(nil, "ARTWORK")
Main.FinalBossDeathCount.Icon:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ScenarioIcon-Combat")
Main.FinalBossDeathCount.Icon:SetPoint("TOPLEFT", Main.FinalBossDeathCount, "TOPLEFT", 0, 0)
Main.FinalBossDeathCount.Icon:SetSize(16, 16)

-- Main.FinalBossDeathCount.Text
Main.FinalBossDeathCount.Text = Main.FinalBossDeathCount:CreateFontString(nil, "OVERLAY")
Main.FinalBossDeathCount.Text:SetFontObject(GameFontHighlight)
Main.FinalBossDeathCount.Text:SetPoint("LEFT", Main.FinalBossDeathCount.Icon, "RIGHT",  4, 0)
Main.FinalBossDeathCount.Text:SetText(format(BOSS_FORMAT, 0, 0, "Final Boss"))

Main.FinalBossDeathCount.SetChecked = SetObjectiveChecked
Main.FinalBossDeathCount.SetTarget = SetObjectiveTarget
Main.FinalBossDeathCount.Reset = ResetTarget
Main.FinalBossDeathCount.Kill = KillObjective
Main.FinalBossDeathCount.Revive = ReviveObjective

for i = 1, 20 do
    local parent = Main.FinalBossDeathCount
    if i > 1 then
        parent = Main["BossTracker"..i-1]
    end
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(260, 20)

    frame:SetPoint("TOP", parent, "BOTTOM", 0, 0)

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ScenarioIcon-Combat")
    frame.Icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.Icon:SetSize(16, 16)

    frame.Text = frame:CreateFontString(nil, "OVERLAY")
    frame.Text:SetFontObject(GameFontHighlight)
    frame.Text:SetPoint("LEFT", frame.Icon, "RIGHT", 4, 0)
    frame.Text:SetText(format(BOSS_FORMAT, 0, 1, "BossName"))
    
    frame.bossName = nil

    frame:Hide()

    frame.SetChecked = SetObjectiveChecked
    frame.SetTarget = SetObjectiveTarget
    frame.Reset = ResetTarget
    frame.Kill = KillObjective
    frame.Revive = ReviveObjective

    Main["BossTracker"..i] = frame
end

-- Main.MinionDeathCount
Main.MinionDeathCount = CreateFrame("FRAME", "AscensionUI.MythicKeystone.Main.MinionDeathCount", Main.BossDeathCount)
Main.MinionDeathCount:SetSize(260, 40)
Main.MinionDeathCount:SetPoint("TOP", Main.BossDeathCount, "BOTTOM", 0, 0)

-- Main.MinionDeathCount.Icon
Main.MinionDeathCount.Icon = Main.MinionDeathCount:CreateTexture(nil, "OVERLAY")
Main.MinionDeathCount.Icon:SetPoint("TOPLEFT", Main.MinionDeathCount, "TOPLEFT", 0, 0)
Main.MinionDeathCount.Icon:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\ScenarioIcon-Combat")
Main.MinionDeathCount.Icon:SetSize(16, 16)


-- Main.MinionDeathCount.Text
Main.MinionDeathCount.Text = Main.MinionDeathCount:CreateFontString(nil, "OVERLAY")
Main.MinionDeathCount.Text:SetPoint("LEFT", Main.MinionDeathCount.Icon, "RIGHT", 4, 0)
Main.MinionDeathCount.Text:SetFontObject(GameFontHighlight)
Main.MinionDeathCount.Text:SetText(ENEMY_FORCES_FORMAT)

Main.MinionDeathCount.SetChecked = SetObjectiveChecked


-- Main.MinionDeathCount.StatusBar
Main.MinionDeathCount.StatusBar = CreateFrame("STATUSBAR", nil, Main.MinionDeathCount)
Main.MinionDeathCount.StatusBar:SetSize(191, 17)
Main.MinionDeathCount.StatusBar:SetPoint("BOTTOM")
Main.MinionDeathCount.StatusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
Main.MinionDeathCount.StatusBar:SetStatusBarColor(0.26, 0.42, 1)
Main.MinionDeathCount.StatusBar:SetMinMaxValues(0, 100)

-- Main.MinionDeathCount.StatusBar.BG
Main.MinionDeathCount.StatusBar.BG = Main.MinionDeathCount.StatusBar:CreateTexture(nil, "BACKGROUND")
Main.MinionDeathCount.StatusBar.BG:SetAllPoints()
Main.MinionDeathCount.StatusBar.BG:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
Main.MinionDeathCount.StatusBar.BG:SetVertexColor(0.1, 0.1, 0.4, 1)

-- Main.MinionDeathCount.StatusBar.BarTexture
Main.MinionDeathCount.StatusBar.BarTexture = Main.MinionDeathCount.StatusBar:CreateTexture(nil, "OVERLAY")
Main.MinionDeathCount.StatusBar.BarTexture:SetPoint("LEFT", -7, -2)
Main.MinionDeathCount.StatusBar.BarTexture:SetSize(240, 51)
Main.MinionDeathCount.StatusBar.BarTexture:SetTexture("Interface\\AddOns\\AscensionUI\\Textures\\BonusObjectives")
Main.MinionDeathCount.StatusBar.BarTexture:SetTexCoord(0.00195312, 0.470703, 0.615234, 0.714844)

-- Main.MinionDeathCount.StatusBar.Label
Main.MinionDeathCount.StatusBar.Label = Main.MinionDeathCount.StatusBar:CreateFontString(nil, "OVERLAY")
Main.MinionDeathCount.StatusBar.Label:SetFontObject(GameFontHighlightMedium)
Main.MinionDeathCount.StatusBar.Label:SetPoint("CENTER", -1, -1)
Main.MinionDeathCount.StatusBar.Label:SetJustifyH("CENTER")
Main.MinionDeathCount.StatusBar.Label:SetText(format(SLAIN_PERCENT_FORMAT, 0))

-- Main.MinionDeathCount.StatusBar.BarBG
Main.MinionDeathCount.StatusBar.BarBG = Main.MinionDeathCount.StatusBar:CreateTexture(nil, "BACKGROUND")
Main.MinionDeathCount.StatusBar.BarBG:SetTexture(0.04, 0.07, 0.18)

-- Main["Affix"..1-6]
for i = 1, 6 do 
    local affix = CreateFrame("FRAME", nil, Main)
    Main["Affix"..i] = affix
    affix:SetFrameLevel(Main:GetFrameLevel() + 1)
    affix:Hide()

    affix:SetSize(24, 24)
    affix:SetPoint("TOPRIGHT", Main, "TOPRIGHT", -((i - 1) * 26) - 16, -14)
    affix:EnableMouse(true)

    affix.Border = affix:CreateTexture(nil, "OVERLAY")
    affix.Border:SetSize(24, 24)
    affix.Border:SetPoint("CENTER")
    affix.Border:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
    affix.Border:SetTexCoord(0.912109, 0.962891, 0.0537109, 0.104492)

    affix.Portrait = affix:CreateTexture(nil, "ARTWORK")
    affix.Portrait:SetSize(24, 24)
    affix.Portrait:SetPoint("CENTER", affix.Border)
end

-------------------------------------------------------------------------------
--                                Functionality                              --
-------------------------------------------------------------------------------
function Main:ShowUI(instance, powerLevel, timeLimit, minions, bossCount, affixes, affixCount)
    KeystoneFrame:Show()
    Main:Show()
    
    KeystoneFrame.Text:SetText(instance)
    
    Main.Level:SetText("Level "..powerLevel)

    TimerValue = timeLimit
    TotalTime = timeLimit
    Minions = minions
    Bosses = bossCount
    
    Main.StatusBar:SetMinMaxValues(0, TimerValue)
    Main.StatusBar:SetValue(TimerValue)
    Main.StatusBar.Texture:SetVertexColor(1, 1, 1)

    -- setup timer
    Main.TimeLeft:SetText(MythicKeystone:FormatTime(TimerValue))
    Main.TimeLeft:SetTextColor(1, 1, 1)

    local time4 = TotalTime * TIME_FOR_4
    Main.TimeLeft2:SetText(MythicKeystone:FormatTime(time4))
    Main.TimeLeft2:SetTextColor(1, 0.843, 0)

    -- setup bosses to kill 
    Main.BossDeathCount.Text:SetText(format(BOSSES_FORMAT, BossesDone, Bosses))
    TrackedBosses = {}
    local bosses = Addon.DungeonInfo[instance].bosses
    local finalBoss = Addon.DungeonInfo[instance].finalBoss

    for bossId, name in pairs(finalBoss) do
        TrackedBosses[bossId] = Main.FinalBossDeathCount
        Main.FinalBossDeathCount:SetTarget(name)
        Main.FinalBossDeathCount:Show()

        --check if this boss is already dead
        -- ignore if from keystonestarting because old data isnt flushed at this point
        --print("IsMythicPlusBossKilled("..bossId..") =", IsMythicPlusBossKilled(bossId), "["..Addon.DungeonInfo[instance].bosses[bossId].."]")
        if not KeystoneStarting and IsMythicPlusBossKilled(bossId) then
            Main.FinalBossDeathCount:Kill()
        end
    end

    local i = 1
    for bossId, name in pairs(bosses) do
        local frame = Main["BossTracker"..i]
        Main.MinionDeathCount:SetPoint("TOP", frame, "BOTTOM", -20, 0)

        if not TrackedBosses[bossId] then
            TrackedBosses[bossId] = frame

            if name then
                frame:SetTarget(name)
            else
                frame:SetTarget(bossId)
            end
            frame:Show()

            -- check if this boss is already dead
            -- ignore if keystonestarting because old data isnt flushed at this point
            --print("IsMythicPlusBossKilled("..bossId..") =", IsMythicPlusBossKilled(bossId), "["..Addon.DungeonInfo[instance].bosses[bossId].."]")
            if not KeystoneStarting and IsMythicPlusBossKilled(bossId) then 
                frame:Kill()
            end
            i = i + 1
        end
    end

    

    -- show minions stuff
    if Minions > 0 then
        local pctDone = MinionsDone / Minions * 100
        Main.MinionDeathCount.StatusBar.Label:SetText(format(SLAIN_PERCENT_FORMAT, pctDone))
        Main.MinionDeathCount.StatusBar:SetValue(pctDone)
    else
        Main.MinionDeathCount:Hide()
    end


    -- show affix data 
    if affixCount > 6 then 
        affixCount = 6
    end

    local i = 1
    for id in pairs(affixes) do 
        if i > affixCount then return end -- TODO: maybe handle more affixes?
        local affix = Main["Affix"..i]
        local spellName, _, spellIcon = GetSpellInfo(id) 
        if spellIcon then
            SetPortraitToTexture(affix.Portrait, spellIcon)
            affix:Show()
            affix:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink("|Hspell:"..id.."|h["..spellName.."]|h")
                GameTooltip:Show()
            end)
            affix:SetScript("OnLeave", function() 
                GameTooltip:Hide()
            end)
            i = i + 1
        end
    end

    -- recover from reload or relog
    Main:OnMinionKilled(GetMythicPlusCreatureKilledProgress())

    Main.BossDeathCount.Toggle:SetChecked(true)
    Main.BossDeathCount.Toggle:GetScript("OnClick")(Main.BossDeathCount.Toggle)
end

-- /run AscensionUI.MythicKeystone.Main:OnDeathCountUpdated(780)
function Main:OnDeathCountUpdated()
    Main.DeathCount:Show()

    DeathCountValue = DeathCountValue + 1

    Main.DeathCount.Count:SetText(DeathCountValue)
end

function Main:OnMinionKilled(amount)
    if MinionsDone >= Minions then
        if not MythicKeystone.CDB.MinionDeathTime then
            MythicKeystone.CDB.MinionDeathTime = TotalTime - TimerValue
        end
        Main.MinionDeathCount.Text:SetText(ENEMY_FORCES_FORMAT.." ("..MythicKeystone:FormatTime(MythicKeystone.CDB.MinionDeathTime)..")")
        Main.MinionDeathCount:SetChecked(true)
        return
    end

    MinionsDone = MinionsDone + amount

    if MinionsDone > Minions then
        MinionsDone = Minions
    end

    local pctDone = MinionsDone / Minions * 100
    Main.MinionDeathCount.StatusBar.Label:SetText(format(SLAIN_PERCENT_FORMAT, pctDone))
    Main.MinionDeathCount.StatusBar:SetValue(pctDone)

    if MinionsDone >= Minions then
        if not MythicKeystone.CDB.MinionDeathTime then
            MythicKeystone.CDB.MinionDeathTime = TotalTime - TimerValue
        end
        Main.MinionDeathCount.Text:SetText(ENEMY_FORCES_FORMAT.." ("..MythicKeystone:FormatTime(MythicKeystone.CDB.MinionDeathTime)..")")
    end

    Main.MinionDeathCount:SetChecked(MinionsDone >= Minions)
end

function Main:OnBossKilled(bossId)

    if RingOfLaw[bossId] then
        bossId = 0
    end

    local frame = TrackedBosses[bossId]
    if not frame then
        return
    end

    local bossName = Addon.DungeonInfo[Addon.KeystoneData[MythicKeystone.CDB.LastKeystone].instanceName].bosses[bossId]
    if bossName and not MythicKeystone.CDB.BossDeathTime[bossName] then
        MythicKeystone.CDB.BossDeathTime[bossName] = TotalTime - TimerValue
    end
    frame:Kill()
end

function Main:UpdateBossesComplete()
    if BossesDone >= Bosses then
        BossesDone = Bosses
        Main.BossDeathCount:SetChecked(true)
    end

    Main.BossDeathCount.Text:SetText(format(BOSSES_FORMAT, BossesDone, Bosses))

    if BossesDone >= Bosses then
        return
    end

    Main.BossDeathCount:SetChecked(false)
end

local function CheckMinionSlain(count)
    if count > MinionsDone then
        Main:OnMinionKilled(count - MinionsDone)
    end
end

function Main:ASCENSION_MYTHIC_PLUS_EVENT_DUNGEON_STATE_STARTING(player, keystoneId)
    MythicKeystone.CDB.MinionDeathTime = nil
    MythicKeystone.CDB.BossDeathTime = {}
    KeystoneFailed = false
    KeystoneStarting = true
    LoadKeystone(tonumber(keystoneId))
    Addon:StartChallengeTimer(10)
end

function Main:ASCENSION_MYTHIC_PLUS_EVENT_DUNGEON_STATE_STARTING_CANCELLED(player, keystoneId)
    KeystoneStarting = false
end

function Main:ASCENSION_MYTHIC_PLUS_EVENT_DUNGEON_STATE_STARTED(player, keystoneId)
    KeystoneFailed = false
    KeystoneStarting = false
    LoadKeystone(tonumber(keystoneId))
end

function Main:ASCENSION_MYTHIC_PLUS_EVENT_DUNGEON_STATE_FINISHED(player, keystoneId)
    KeystoneFailed = false
    Main.StatusBar.Texture:SetVertexColor(0, 0.8, 0)
    MythicKeystone.KeystoneCompleted:CompleteKey(tonumber(keystoneId), true, TimerValue)
end

function Main:ASCENSION_MYTHIC_PLUS_EVENT_DUNGEON_STATE_FAILED(player, keystoneId)
    KeystoneFailed = true
    Main.StatusBar.Texture:SetVertexColor(1, 0, 0)
    Main.TimeLeft:SetTextColor(0.8, 0.2, 0.2)
    MythicKeystone.KeystoneCompleted:CompleteKey(tonumber(keystoneId), false, TimerValue)
end

function Main:ASCENSION_MYTHIC_PLUS_BOSS_SLAIN(bossId)
    Main:OnBossKilled(tonumber(bossId))
end

function Main:ASCENSION_MYTHIC_PLUS_CREATURE_AMOUNT_CHANGED(amount)
    CheckMinionSlain(tonumber(amount))
end

function Main:ASCENSION_MYTHIC_PLUS_TIMER_UPDATE(seconds)
    if not EnteredWorld then return end
    UpdateTimer(tonumber(seconds)/1000)
end

Main:RegisterEvent("ADDON_LOADED")
Main:RegisterEvent("PLAYER_ENTERING_WORLD")
Main:RegisterEvent("COMMENTATOR_SKIRMISH_QUEUE_REQUEST")
Main:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if MythicKeystone.CDB.Locked == nil then 
            MythicKeystone.CDB.Locked = true
        end
        KeystoneFrame.Lock:SetChecked(MythicKeystone.CDB.Locked)
        KeystoneFrame.Lock:GetScript("OnClick")(KeystoneFrame.Lock)
        EnteredWorld = true
        KeystoneFailed = false
        if self:GetParent():IsVisible() then
            self:Hide()
            self:GetParent():Hide()
        end

    elseif event == "COMMENTATOR_SKIRMISH_QUEUE_REQUEST" then
        local func = Main[select(1, ...)]
        if func then func(...) end

    end
end)

