local Addon = {}

local minLevel = 20
local ironmanNoChangeLevel = 22
local ironmanMaxLevel = 60

local Destiny_Theresa_NPC = 75110
local Destiny_NPC_Table = {
    Destiny_Theresa_NPC,
    100031,
    100030,
    499991,
    499970,
    100032,
    --75110,
}

local HighRiskSpellID = 84421
local NoRiskSpellID = 84422
local NoRiskPvPSpellID = 84420

local NoRiskPvEkBuffID = 9931032
local NoRiskBuffID = 1004119
local HighRiskBuffID = 1004019
local ConflictedBuff = 1001030
local OutlawBuff = 9930874
local IronmanBuff = 9930931
local FeltouchedBuff = 9930852

local tinsert = table.insert

Addon.FramesToFade = {}
function Addon:BaseFrameFade(frame, dir)
    if not frame then return end

    frame.FadeTimer = 0
    if frame.time then
        frame.TimeToFade = frame.time
    else
        frame.TimeToFade = 3
    end

    frame.FadeMode = dir
    tinsert(Addon.FramesToFade, frame)
end

function Addon:BaseFrameFadeIn(frame)
    self:BaseFrameFade(frame, "IN")
    frame:Show()
end

function Addon:BaseFrameFadeOut(frame)
    self:BaseFrameFade(frame, "OUT")
end

local fader = CreateFrame("Frame")
fader:SetScript("OnUpdate", function(self, dt)
    for i, frame in ipairs(Addon.FramesToFade) do
        frame.FadeTimer = frame.FadeTimer + dt
        if frame.FadeTimer < frame.TimeToFade then
            if frame.FadeMode == "IN" then
                frame:SetAlpha(frame.FadeTimer / frame.TimeToFade)
            elseif frame.FadeMode == "OUT" then
                frame:SetAlpha((frame.TimeToFade - frame.FadeTimer) / frame.TimeToFade)
            end
        else
            if frame.FadeMode == "IN" then
                frame:SetAlpha(1)
            elseif frame.FadeMode == "OUT" then
                frame:SetAlpha(0)
                frame:Hide()
            end
            tremove(Addon.FramesToFade, i)
        end
    end
end)

function Addon:BroadcastError(message, sysmessage)
    if message then
        UIErrorsFrame:AddMessage(message, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1.0)
    end
    if sysmessage then
        SendSystemMessage(sysmessage);
    end
end

local CurrentRulest = 0
local DestinyDialog_Close_Modes = {
    [0] = "If you close this window, you'll continue your\npath in No Risk (PvP) mode.\nYou can change Rulesets at any time in a city.\n\nAre you sure you want to continue your\npath in |cff00FF00No Risk|r |cffFF0000(PVP)|r mode?", -- norisk text
    [1] = "If you close this window, you'll continue your\npath in High Risk mode.\nYou can change Rulesets at any time in a city.\n\nAre you sure you want to continue your\npath in |cffFF0000High Risk|r mode?", -- highrisk text
    [2] = "If you close this window, you'll continue your\npath in No Risk (PvE) mode.\nYou can changeRulesets at any time in a city.\n\nAre you sure you want to continue your\npath in |cff00FF00No Risk|r |cffFF0000(PVE)|r mode?", -- norisk text
}

local DestinyFrameText = {
    ["DestinyFrame.NoRiskFrame.Icon1.Label"] = "A Safer Haven",
    ["DestinyFrame.NoRiskFrame.Icon1.Text"] = "Being slain in World PvP Combat will not cause you to drop any items or turn PvP off entirely",
    ["DestinyFrame.NoRiskFrame.Icon1.Icon"] = "Interface\\icons\\Achievement_bg_killxenemies_generalsroom",

    ["DestinyFrame.NoRiskFrame.Icon2.Label"] = "Fight, or Don't!",
    ["DestinyFrame.NoRiskFrame.Icon2.Text"] = "You can toggle between PvP or PvE. PvP means you can be attacked. PvE means you cannot be attacked!",
    ["DestinyFrame.NoRiskFrame.Icon2.Icon"] = "Interface\\icons\\Achievement_explore_argus",

    ["DestinyFrame.NoRiskFrame.Icon3.Label"] = "Dungeon Diver",
    ["DestinyFrame.NoRiskFrame.Icon3.Text"] = "Gather your gear steadily in Dungeons and Raids, without risking it all in the Open World.",
    ["DestinyFrame.NoRiskFrame.Icon3.Icon"] = "Interface\\icons\\Achievement_Ashran_Tourofduty",

    ["DestinyFrame.HighRiskFrame.Icon1.Label"] = "The Risk of Reward",
    ["DestinyFrame.HighRiskFrame.Icon1.Text"] = "Players you slay in World PvP Combat drop a chest containing their loot. As do you. You cannot fly in Highrisk.",
    ["DestinyFrame.HighRiskFrame.Icon1.Icon"] = "Interface\\icons\\warrior_skullbanner",

    ["DestinyFrame.HighRiskFrame.Icon2.Label"] = "Treasures Untold",
    ["DestinyFrame.HighRiskFrame.Icon2.Text"] = "Have a chance at looting Bloodforged Rare and Epic items throughout the World!",
    ["DestinyFrame.HighRiskFrame.Icon2.Icon"] = "Interface\\icons\\achievement_guildperk_mobilebanking",

    ["DestinyFrame.HighRiskFrame.Icon3.Label"] = "Switch at Anytime!",
    ["DestinyFrame.HighRiskFrame.Icon3.Text"] = "You can swap Risk Rulesets at any time, in case things get too intense!",
    ["DestinyFrame.HighRiskFrame.Icon3.Icon"] = "Interface\\icons\\racechange",
}

-- popups
StaticPopupDialogs["ASC_DESTINYFRAME_PROMPT_NORISK"] = {
    text = "Please, choose which ruleset you prefer for your\npath in |cff00FF00No Risk|r Ruleset?\n\nIf you choose PvP, you can be attacked by other players.\n\nIf you choose PvE, you cannot be attacked by other players\n\nYou can change your Ruleset at any time in a Capital City!",
    button1 = "|cffFF0000PvP|r Ruleset",
    button2 = "Cancel",
    button3 = "|cff00FF00PvE|r Ruleset",
    whileDead = true,
    timeout = 0,
    hideOnEscape = false,
    OnAccept = function(self)
        Addon:BaseFrameFadeOut(DestinyFrame_BG)
        SpellStopCasting()
        CastSpellByID(NoRiskPvPSpellID)
        Addon:BroadcastError(nil, "You have switched your mode to |cff00FF00No Risk |cffFF0000(PVP)|r. You won't be able to switch between modes for 10 minutes.")
    end,
    OnAlt = function(self)
        Addon:BaseFrameFadeOut(DestinyFrame_BG)
        SpellStopCasting()
        CastSpellByID(NoRiskSpellID)
        Addon:BroadcastError(nil, "You have switched your mode to |cff00FF00No Risk |cffFF0000(PVE)|r. You won't be able to switch between modes for 10 minutes.")
    end
}

StaticPopupDialogs["ASC_DESTINYFRAME_PROMPT_CLOSE"] = {
    text = "If you close this window, you'll continue your\npath in No Risk Ruleset.\nYou can change this in a Capital City at any time!\n\nAre you sure you want to continue your\npath in |cff00FF00No Risk|r Ruleset?",
    button1 = "Accept",
    button2 = "Cancel",
    whileDead = true,
    timeout = 0,
    hideOnEscape = false,
    OnAccept = function(self)
        if (DestinyFrame_BG:IsVisible()) then
            Addon:BaseFrameFadeOut(DestinyFrame_BG)
        end
        local spellID = NoRiskSpellID
        if CurrentRuleset == 0 then
            spellID = HighRiskSpellID
        elseif CurrentRuleset == 1 then
            spellID = NoRiskPvPSpellID
        end

        SpellStopCasting()
        CastSpellByID(spellID)
    end
}

StaticPopupDialogs["ASC_DESTINYFRAME_PROMPT_HIGHRISK"] = {
    text = "Are you sure you want to continue your\npath in |cffFF0000High Risk|r Ruleset?\n\nYou can change this at anytime in a Capital City!",
    button1 = "Accept",
    button2 = "Cancel",
    whileDead = true,
    timeout = 0,
    hideOnEscape = false,
    OnAccept = function(self)
        Addon:BaseFrameFadeOut(DestinyFrame_BG)
        SpellStopCasting()
        CastSpellByID(HighRiskSpellID)
        Addon:BroadcastError(nil, "You have switched your mode to |cffFF0000High Risk|r. You won't be able to switch between modes for 10 minutes.")
    end
}

StaticPopupDialogs["ASC_DESTINYFRAME_PROMPT_SPECIAL"] = {
    text = "|cffFF0000Seems like you lost some of your |cffFFFFFFitems|r|cffFF0000! Would you like to switch to |cff00FF00No-Risk|r|cffFF0000 Ruleset?|r",
    button1 = "Accept",
    button2 = "Cancel",
    whileDead = true,
    timeout = 0,
    hideOnEscape = false,
    OnAccept = function(self)
        StaticPopup_Show("ASC_DESTINYFRAME_PROMPT_NORISK")
        RepopMe()
    end
}

local f = CreateFrame("FRAME", "DestinyFrame_BG", nil, nil)
f.time = 0.5
f:SetBackdrop(StaticPopup1:GetBackdrop())
f:SetPoint("CENTER")
local sizex, sizey = UIParent:GetSize()
f:SetSize(sizex*2, sizey*2)
f:EnableMouse(true)
f:EnableKeyboard(true)
f:Hide()
f:SetFrameStrata("DIALOG")

-- Call this to show the frame
function f:Display(level)
    if UnitBuff("player", GetSpellInfo(NoRiskPvEkBuffID)) then -- PvE Mode Buff
        CurrentRuleset = 2
    elseif UnitBuff("player", GetSpellInfo(NoRiskBuffID)) then -- No Risk Buff
        CurrentRuleset = 1
    elseif UnitBuff("player", GetSpellInfo(HighRiskBuffID)) then -- High Risk Buff
        CurrentRuleset = 0
    end

    StaticPopupDialogs["ASC_DESTINYFRAME_PROMPT_CLOSE"].text = DestinyDialog_Close_Modes[CurrentRuleset]

    -- check if we can even display this 
    --[[local level = UnitLevel("player")
    if level < minLevel then 
        Addon:BroadcastError("I can choose a mode only after level "..minLevel, 
                            "You can choose a mode only after level "..minLevel)
        return false
    end]]
    if not IsSpellKnown(HighRiskSpellID) or not IsSpellKnown(NoRiskSpellID) or not IsSpellKnown(NoRiskPvPSpellID) then
        Addon:BroadcastError("I can choose a mode only after level "..minLevel,
                "You can choose a mode only after level "..minLevel)
        return false
    end

    if UnitIsPVP("player") then
        Addon:BroadcastError("I can only switch risk modes when I am not flagged for PvP.",
                "You can only switch risk modes when you are not flagged for PvP.")
        return false
    end

    if UnitDebuff("player", GetSpellInfo(ConflictedBuff)) then
        Addon:BroadcastError("I can't do that now", "You can't do that now")
        return false
    end

    if UnitDebuff("player", GetSpellInfo(IronmanBuff)) then
        if level >= ironmanMaxLevel and level < ironmanMaxLevel then
            Addon:BroadcastError("I can't switch mode until level |cffFFFFFF"..ironmanMaxLevel.."|r in Ironman Mode",
                    "You can't switch mode until level |cffFFFFFF"..ironmanMaxLevel.."|r in Ironman Mode.")
            return false
        end
    end

    if UnitBuff("player", GetSpellInfo(FeltouchedBuff)) then
        Addon:BroadcastError("I can't use that option in this game mode.", "You can't use this option in choosen game mode.")
        return false
    end

    Addon:BaseFrameFadeIn(f)
    return true
end

f.DestinyFrame = CreateFrame("FRAME", nil, f, nil)
f.DestinyFrame:SetSize(784,512)
f.DestinyFrame:SetPoint("CENTER", 0, 0)
f.DestinyFrame:SetBackdrop({
    bgFile = "Interface\\AddOns\\AwAddons\\Textures\\SeasonalFFA_NORISK_Petition",
    insets = {
        left = -120,
        right = -120,
        top = -256,
        bottom = -256}
})

f.DestinyFrame.CloseButton = CreateFrame("Button", nil, f.DestinyFrame, "UIPanelCloseButton")
f.DestinyFrame.CloseButton:SetPoint("TOPRIGHT", -4, -1)
f.DestinyFrame.CloseButton:EnableMouse(true)
f.DestinyFrame.CloseButton:SetScript("OnClick", function()
    PlaySound("QUESTLOGCLOSE")
    StaticPopup_Show("ASC_DESTINYFRAME_PROMPT_CLOSE")
end)

f.DestinyFrame.TitleText = f.DestinyFrame:CreateFontString(nil)
f.DestinyFrame.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
f.DestinyFrame.TitleText:SetFontObject(GameFontNormal)
f.DestinyFrame.TitleText:SetPoint("TOP", 0, -11)
f.DestinyFrame.TitleText:SetShadowOffset(1,-1)
f.DestinyFrame.TitleText:SetText("")

-------------------------------------------------------------------------------
--                                  No-Risk                                  --
-------------------------------------------------------------------------------
f.DestinyFrame.NoRiskFrame = CreateFrame("FRAME", nil, f.DestinyFrame)
f.DestinyFrame.NoRiskFrame:SetSize(320, 450)
f.DestinyFrame.NoRiskFrame:SetPoint("LEFT", 65, 0)
f.DestinyFrame.NoRiskFrame.Texts = 3

f.DestinyFrame.NoRiskFrame.Label = f.DestinyFrame.NoRiskFrame:CreateFontString(nil)
f.DestinyFrame.NoRiskFrame.Label:SetFont("Fonts\\MORPHEUS.TTF", 30)
f.DestinyFrame.NoRiskFrame.Label:SetFontObject(GameFontNormal)
f.DestinyFrame.NoRiskFrame.Label:SetPoint("TOP",0,-10)
f.DestinyFrame.NoRiskFrame.Label:SetShadowOffset(0,0)
f.DestinyFrame.NoRiskFrame.Label:SetSize(260, 42)
f.DestinyFrame.NoRiskFrame.Label:SetText("No Risk Ruleset")
f.DestinyFrame.NoRiskFrame.Label:SetJustifyH("CENTER")
f.DestinyFrame.NoRiskFrame.Label:SetVertexColor(0.0, 0.0, 0.0, 0.8)

f.DestinyFrame.NoRiskFrame.Button = CreateFrame("BUTTON", nil, f.DestinyFrame.NoRiskFrame, "StaticPopupButtonTemplate")
f.DestinyFrame.NoRiskFrame.Button:SetSize(128, 64)
f.DestinyFrame.NoRiskFrame.Button:SetPoint("BOTTOM", 0, 24)
f.DestinyFrame.NoRiskFrame.Button:SetNormalTexture("")
f.DestinyFrame.NoRiskFrame.Button:SetPushedTexture("")

f.DestinyFrame.NoRiskFrame.Button.TextNormal = f.DestinyFrame.NoRiskFrame.Button:CreateFontString(nil)
f.DestinyFrame.NoRiskFrame.Button.TextNormal:SetFontObject(GameFontNormal)
f.DestinyFrame.NoRiskFrame.Button.TextNormal:SetFont("Fonts\\FRIZQT__.TTF", 16)
f.DestinyFrame.NoRiskFrame.Button.TextNormal:SetPoint("CENTER", 0, 0)
f.DestinyFrame.NoRiskFrame.Button.TextNormal:SetSize(240, 52)
f.DestinyFrame.NoRiskFrame.Button.TextNormal:SetText("Choose\nNo Risk Mode")
f.DestinyFrame.NoRiskFrame.Button.TextNormal:SetJustifyH("CENTER")
f.DestinyFrame.NoRiskFrame.Button.TextNormal:SetJustifyV("CENTER")
f.DestinyFrame.NoRiskFrame.Button:SetFontString(f.DestinyFrame.NoRiskFrame.Button.TextNormal)

f.DestinyFrame.NoRiskFrame.Button.BG = f.DestinyFrame.NoRiskFrame.Button:CreateTexture(nil, "BORDER")
f.DestinyFrame.NoRiskFrame.Button.BG:SetSize(256,64)
f.DestinyFrame.NoRiskFrame.Button.BG:SetPoint("CENTER", -4, -4)
f.DestinyFrame.NoRiskFrame.Button.BG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\DestinyFrameButtonNormal_L")
f.DestinyFrame.NoRiskFrame.Button.BG:SetBlendMode("ADD")
f.DestinyFrame.NoRiskFrame.Button.BG:SetAlpha(0.7)

f.DestinyFrame.NoRiskFrame.Button.Highlight = f.DestinyFrame.NoRiskFrame.Button:CreateTexture(nil, "HIGH")
f.DestinyFrame.NoRiskFrame.Button.Highlight:SetSize(256,64)
f.DestinyFrame.NoRiskFrame.Button.Highlight:SetPoint("CENTER", -4, -4)
f.DestinyFrame.NoRiskFrame.Button.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\DestinyFrameButtonNormal_L")
f.DestinyFrame.NoRiskFrame.Button.Highlight:SetBlendMode("ADD")
f.DestinyFrame.NoRiskFrame.Button.Highlight:SetAlpha(0.7)
f.DestinyFrame.NoRiskFrame.Button:SetHighlightTexture(f.DestinyFrame.NoRiskFrame.Button.Highlight)

f.DestinyFrame.NoRiskFrame.Button.Highlight_Add = f.DestinyFrame.NoRiskFrame.Button:CreateTexture(nil, "HIGH")
f.DestinyFrame.NoRiskFrame.Button.Highlight_Add:SetSize(512,256)
f.DestinyFrame.NoRiskFrame.Button.Highlight_Add:SetPoint("CENTER", -66, 46)
f.DestinyFrame.NoRiskFrame.Button.Highlight_Add:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\DestinyFrameButtonNormal_L_Add")
f.DestinyFrame.NoRiskFrame.Button.Highlight_Add:SetBlendMode("ADD")
f.DestinyFrame.NoRiskFrame.Button.Highlight_Add:Hide()
f.DestinyFrame.NoRiskFrame.Button.Highlight_Add.time = 0.25

f.DestinyFrame.NoRiskFrame.Button:SetScript("OnEnter", function(self)
    Addon:BaseFrameFadeIn(self.Highlight_Add)
end)
f.DestinyFrame.NoRiskFrame.Button:SetScript("OnLeave", function(self)
    Addon:BaseFrameFadeOut(self.Highlight_Add)
end)

f.DestinyFrame.NoRiskFrame.Button:SetScript("OnClick", function(self)
    StaticPopup_Show("ASC_DESTINYFRAME_PROMPT_NORISK")
end)

for i = 1, f.DestinyFrame.NoRiskFrame.Texts do
    local icon = CreateFrame("FRAME", nil, f.DestinyFrame.NoRiskFrame)
    icon:SetSize(37,37)
    icon:SetPoint("LEFT", 20, 140 + (i-1)*(-70))

    icon.Icon = icon:CreateTexture(nil, "BORDER")
    icon.Icon:SetSize(39,39)
    icon.Icon:SetPoint("CENTER", 0, 0)
    icon.Icon:SetTexture(DestinyFrameText["DestinyFrame.NoRiskFrame.Icon"..i..".Icon"])

    icon.BG = icon:CreateTexture(nil, "BACKGROUND")
    icon.BG:SetSize(64,64)
    icon.BG:SetTexture("Interface\\Spellbook\\UI-Spellbook-SpellBackground")
    icon.BG:SetPoint("TOPLEFT", -3, 3)

    icon.Label = icon:CreateFontString(nil)
    icon.Label:SetFont("Fonts\\FRIZQT__.TTF", 16)
    icon.Label:SetPoint("LEFT", 45, 10, "RIGHT")
    icon.Label:SetSize(240, 52)
    icon.Label:SetText(DestinyFrameText["DestinyFrame.NoRiskFrame.Icon"..i..".Label"])
    icon.Label:SetJustifyH("LEFT")
    icon.Label:SetJustifyV("CENTER")
    icon.Label:SetShadowOffset(0,0)
    icon.Label:SetVertexColor(0, 0, 0, 0.8)

    icon.Text = icon:CreateFontString(nil)
    icon.Text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    icon.Text:SetPoint("LEFT", 45, -30, "RIGHT")
    icon.Text:SetSize(240, 52)
    icon.Text:SetText(DestinyFrameText["DestinyFrame.NoRiskFrame.Icon"..i..".Text"])
    icon.Text:SetJustifyH("LEFT")
    icon.Text:SetJustifyV("TOP")
    icon.Text:SetShadowOffset(0,0)
    icon.Text:SetVertexColor(0, 0, 0, 0.8)
end


-------------------------------------------------------------------------------
--                                High-Risk                                  --
-------------------------------------------------------------------------------
f.DestinyFrame.HighRiskFrame = CreateFrame("FRAME", nil, f.DestinyFrame)
f.DestinyFrame.HighRiskFrame:SetSize(320, 450)
f.DestinyFrame.HighRiskFrame:SetPoint("RIGHT", -65, 0)
f.DestinyFrame.HighRiskFrame.Texts = 3
--f.DestinyFrame.HighRiskFrame:SetBackdrop(GameTooltip:GetBackdrop())

f.DestinyFrame.HighRiskFrame.Label = f.DestinyFrame.HighRiskFrame:CreateFontString(nil)
f.DestinyFrame.HighRiskFrame.Label:SetFont("Fonts\\MORPHEUS.TTF", 30)
f.DestinyFrame.HighRiskFrame.Label:SetFontObject(GameFontNormal)
f.DestinyFrame.HighRiskFrame.Label:SetPoint("TOP",0,-10)
f.DestinyFrame.HighRiskFrame.Label:SetShadowOffset(0,0)
f.DestinyFrame.HighRiskFrame.Label:SetSize(260, 42)
f.DestinyFrame.HighRiskFrame.Label:SetText("High Risk Ruleset")
f.DestinyFrame.HighRiskFrame.Label:SetJustifyH("CENTER")
f.DestinyFrame.HighRiskFrame.Label:SetVertexColor(0.0, 0.0, 0.0, 0.8)

f.DestinyFrame.HighRiskFrame.Button = CreateFrame("BUTTON", nil, f.DestinyFrame.HighRiskFrame, "StaticPopupButtonTemplate")
f.DestinyFrame.HighRiskFrame.Button:SetSize(128, 64)
f.DestinyFrame.HighRiskFrame.Button:SetPoint("BOTTOM", 0, 24)
f.DestinyFrame.HighRiskFrame.Button:SetHighlightTexture("")
f.DestinyFrame.HighRiskFrame.Button:SetNormalTexture("")
f.DestinyFrame.HighRiskFrame.Button:SetPushedTexture("")

f.DestinyFrame.HighRiskFrame.Button.TextNormal = f.DestinyFrame.HighRiskFrame.Button:CreateFontString(nil)
f.DestinyFrame.HighRiskFrame.Button.TextNormal:SetFontObject(GameFontNormal)
f.DestinyFrame.HighRiskFrame.Button.TextNormal:SetFont("Fonts\\FRIZQT__.TTF", 16)
f.DestinyFrame.HighRiskFrame.Button.TextNormal:SetPoint("CENTER", 0, 0)
f.DestinyFrame.HighRiskFrame.Button.TextNormal:SetSize(240, 52)
f.DestinyFrame.HighRiskFrame.Button.TextNormal:SetText("Choose\nHigh Risk Ruleset")
f.DestinyFrame.HighRiskFrame.Button.TextNormal:SetJustifyH("CENTER")
f.DestinyFrame.HighRiskFrame.Button.TextNormal:SetJustifyV("CENTER")

f.DestinyFrame.HighRiskFrame.Button:SetFontString(f.DestinyFrame.HighRiskFrame.Button.TextNormal)

f.DestinyFrame.HighRiskFrame.Button.BG = f.DestinyFrame.HighRiskFrame.Button:CreateTexture(nil, "BORDER")
f.DestinyFrame.HighRiskFrame.Button.BG:SetSize(256,64)
f.DestinyFrame.HighRiskFrame.Button.BG:SetPoint("CENTER", 4, -4)
f.DestinyFrame.HighRiskFrame.Button.BG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\DestinyFrameButtonNormal_R")
f.DestinyFrame.HighRiskFrame.Button.BG:SetBlendMode("ADD")
f.DestinyFrame.HighRiskFrame.Button.BG:SetAlpha(0.7)

f.DestinyFrame.HighRiskFrame.Button.Highlight = f.DestinyFrame.HighRiskFrame.Button:CreateTexture(nil, "HIGH")
f.DestinyFrame.HighRiskFrame.Button.Highlight:SetSize(256,64)
f.DestinyFrame.HighRiskFrame.Button.Highlight:SetPoint("CENTER", 4, -4)
f.DestinyFrame.HighRiskFrame.Button.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\DestinyFrameButtonNormal_R")
f.DestinyFrame.HighRiskFrame.Button.Highlight:SetBlendMode("ADD")
f.DestinyFrame.HighRiskFrame.Button.Highlight:SetAlpha(0.7)
f.DestinyFrame.HighRiskFrame.Button:SetHighlightTexture(f.DestinyFrame.HighRiskFrame.Button.Highlight)

f.DestinyFrame.HighRiskFrame.Button.Highlight_Add = f.DestinyFrame.HighRiskFrame.Button:CreateTexture(nil, "HIGH")
f.DestinyFrame.HighRiskFrame.Button.Highlight_Add:SetSize(512,256)
f.DestinyFrame.HighRiskFrame.Button.Highlight_Add:SetPoint("CENTER", 67, 40)
f.DestinyFrame.HighRiskFrame.Button.Highlight_Add:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\DestinyFrameButtonNormal_R_Add")
f.DestinyFrame.HighRiskFrame.Button.Highlight_Add:SetBlendMode("ADD")
f.DestinyFrame.HighRiskFrame.Button.Highlight_Add:Hide()
f.DestinyFrame.HighRiskFrame.Button.Highlight_Add.time = 0.25

f.DestinyFrame.HighRiskFrame.Button:SetScript("OnEnter", function(self)
    Addon:BaseFrameFadeIn(self.Highlight_Add)
end)

f.DestinyFrame.HighRiskFrame.Button:SetScript("OnLeave", function(self)
    Addon:BaseFrameFadeOut(self.Highlight_Add)
end)

f.DestinyFrame.HighRiskFrame.Button:SetScript("OnClick", function(self)
    StaticPopup_Show("ASC_DESTINYFRAME_PROMPT_HIGHRISK")
end)

for i = 1, f.DestinyFrame.HighRiskFrame.Texts do
    local icon = CreateFrame("FRAME", nil, f.DestinyFrame.HighRiskFrame)
    icon:SetSize(37,37)
    icon:SetPoint("LEFT", 20, 140 + (i-1)*(-70))

    icon.Icon = icon:CreateTexture(nil, "BORDER")
    icon.Icon:SetSize(39,39)
    icon.Icon:SetPoint("CENTER", 0, 0)
    icon.Icon:SetTexture(DestinyFrameText["DestinyFrame.HighRiskFrame.Icon"..i..".Icon"])

    icon.BG = icon:CreateTexture(nil, "BACKGROUND")
    icon.BG:SetSize(64,64)
    icon.BG:SetTexture("Interface\\Spellbook\\UI-Spellbook-SpellBackground")
    icon.BG:SetPoint("TOPLEFT", -3, 3)

    icon.Label = icon:CreateFontString(nil)
    icon.Label:SetFont("Fonts\\FRIZQT__.TTF", 16)
    icon.Label:SetPoint("LEFT", 45, 10, "RIGHT")
    icon.Label:SetSize(240, 52)
    icon.Label:SetText(DestinyFrameText["DestinyFrame.HighRiskFrame.Icon"..i..".Label"])
    icon.Label:SetJustifyH("LEFT")
    icon.Label:SetJustifyV("CENTER")
    icon.Label:SetShadowOffset(0,0)
    icon.Label:SetVertexColor(0, 0, 0, 0.8)

    icon.Text = icon:CreateFontString(nil)
    icon.Text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    icon.Text:SetPoint("LEFT", 45, -30, "RIGHT")
    icon.Text:SetSize(240, 52)
    icon.Text:SetText(DestinyFrameText["DestinyFrame.HighRiskFrame.Icon"..i..".Text"])
    icon.Text:SetJustifyH("LEFT")
    icon.Text:SetJustifyV("TOP")
    icon.Text:SetShadowOffset(0,0)
    icon.Text:SetVertexColor(0, 0, 0, 0.8)
end

-- Register Events
local listener = CreateFrame("Frame")
listener:RegisterEvent("PLAYER_LEVEL_UP")
listener:RegisterEvent("GOSSIP_SHOW")
listener:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LEVEL_UP" then

        if UnitDebuff("player", GetSpellInfo(FeltouchedBuff)) then
            return -- dont even try to display risk picking to feltouched players
        end

        local level = ...

        if level > minLevel then
            -- dont unregister, we might prestige!
            return
        end

        if tonumber(level) == minLevel then

            listener:SetScript("OnUpdate", function(self)

                if UnitAffectingCombat("player") then
                    return
                end

                if IsFalling() then
                    return
                end
                DestinyFrame_BG:Display(level)
                self:SetScript("OnUpdate", nil)
            end)
        end
    elseif event == "GOSSIP_SHOW" then
        if (UnitAffectingCombat("player")) then
            return
        end
        for _, id in ipairs(Destiny_NPC_Table) do
            -- check if we're targeting a destiny npc
            local tar = UnitGUID("target")
            if not tar then return end
            if tonumber(strsub(tar, 8, 12), 16) == id then
                CloseGossip()
                ClearTarget() -- clear target so we can talk to the call board after talking to this npc
                -- check if the spell is on CD before we open the frame
                local _, cd = GetSpellCooldown(HighRiskSpellID)
                if cd ~= 0 then
                    Addon:BroadcastError("I must wait before I can do that",
                            "You must wait before changing your risk again")
                    return
                end
                if UnitLevel("player") >= 20 then
                    -- we are appropriate level to talk to this npc
                    f:Display(UnitLevel("player"))
                    return
                else
                    -- we arent appropriate level to talk to this npc
                    Addon:BroadcastError("I can choose a mode only after level "..minLevel,
                            "You can choose a mode only after level "..minLevel)
                end
            end
        end
    end
end)