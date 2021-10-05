local Addon = {}

local FeltouchedAura = 9930852
local IronmanAura = 9930931
local SurvivalistAura = 9930940

-- unsure if this is necessary. Don't know if these gamemodes see the prompt or not. I assume not.
local function CanGameModeRevive()
    return  not UnitDebuff("player", GetSpellInfo(9930852)) and -- feltouched
            not UnitDebuff("player", GetSpellInfo(9930931)) and -- ironman
            not UnitDebuff("player", GetSpellInfo(9930940)) -- survivalist
end

local function ShouldShowRes()
    if not UnitIsGhost("player") then
        return false
    end

    if not CanGameModeRevive() then
        return false
    end
    
    local _, instanceType = IsInInstance()
    if not instanceType or instanceType ~= "none" then 
        return false
    end

    return true
end

local ResInTownSpellID = 84423
local ResInCapitalSpellID = 84433

local SafeZoneButtonText = "Resurrect\nin a Safe Zone"

local DialogText =  "Resurrect in Nearest Town to restock, regroup and get back into the fight.\n\n"..
        "Closest Town Resurrection will incur\n"..
        "|cFFFF3F4020% durability loss.|r\n"..
        "|cFFFF3F401 minute of resurrection sickness.|r\n"..
        "Capital City Resurrection will incur\n"..
        "|cFFFF3F40100% durability loss.|r\n"..
        "|cFFFF3F40full resurrection sickness.|r"

-- Ressurect Popup Button
local f = CreateFrame("Button", "ResInSafeZoneButton", UIParent, nil)
f:SetWidth(200)
f:SetHeight(100)
f:SetPoint("TOP", 0, -20)
f:SetNormalTexture("Interface\\AddOns\\AwAddons\\Textures\\misc\\pvprev")

-- this prevents forcing it open anywhere, unsure if needed so commented out.
--[[
if:SetScript("OnShow", function(self)
    if not ShouldShowRes() then 
        self:Hide()
    end
end)
]]

f.text = f:CreateFontString()
f.text:SetFontObject(GameFontNormal)
f.text:SetText(SafeZoneButtonText)
f.text:SetPoint("CENTER", 32, 0)

f:RegisterForClicks("AnyUp")
f:SetHighlightTexture("Interface\\AddOns\\AwAddons\\Textures\\misc\\pvprev_h")
f:SetScript("OnClick", function(self)
    self.Dialog:Show()
end)

f:Hide()
Addon.ResInSafeZoneButton = f

-- Dialog Box
f = CreateFrame("Frame", nil, Addon.ResInSafeZoneButton)
Addon.ResInSafeZoneButton.Dialog = f
f:SetBackdrop(StaticPopup1:GetBackdrop())
f:SetHeight(155)
f:SetWidth(400)
f:SetPoint("TOP", UIParent, 0, -200)
f:Hide()

f.text = f:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
f.text:SetFont("Fonts\\FRIZQT__.ttf", 11)
f.text:SetText(DialogText)
f.text:SetJustifyH("CENTER")
f.text:SetJustifyV("TOP")
f.text:SetPoint("TOP", 0, -15)
f.text:SetPoint("BOTTOM", 0, 25)
f.text:SetPoint("RIGHT", -40, 0)
f.text:SetPoint("LEFT", 40, 0)

f.alert = f:CreateTexture()
f.alert:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
f.alert:SetSize(48, 48)
f.alert:SetPoint("LEFT", 12, 0)

f.resCity = CreateFrame("Button", nil, f, "StaticPopupButtonTemplate")
f.resCity:SetWidth(110)
f.resCity:SetHeight(19)
f.resCity:SetPoint("BOTTOM", -60, 15)
f.resCity:SetText("Closest Town")
f.resCity:SetScript("OnClick", function()
    Addon.ResInSafeZoneButton:Hide()
    Addon.ResInSafeZoneButton.Dialog:Hide()
    CastSpellByID(ResInTownSpellID)
end)

f.resCapital = CreateFrame("Button", nil, f, "StaticPopupButtonTemplate")
f.resCapital:SetWidth(110)
f.resCapital:SetHeight(19)
f.resCapital:SetPoint("BOTTOM", 60, 15)
f.resCapital:SetText("Capital City")
f.resCapital:SetScript("OnClick", function()
    Addon.ResInSafeZoneButton:Hide()
    Addon.ResInSafeZoneButton.Dialog:Hide()
    CastSpellByID(ResInCapitalSpellID)
end)

f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
f.close:SetPoint("TOPRIGHT", 0, 0)
f.close:SetScript("OnClick", function()
    Addon.ResInSafeZoneButton.Dialog:Hide()
end)

f:SetScript("OnShow", function(self)
    PlaySound("igMainMenuOpen")
end)
f:SetScript("OnHide", function(self)
    PlaySound("igMainMenuClose")
end)

local listener = CreateFrame("Frame")
listener:RegisterEvent("PLAYER_ALIVE")
listener:RegisterEvent("PLAYER_ENTERING_WORLD")
listener:RegisterEvent("PLAYER_UNGHOST")

listener:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ALIVE" or "PLAYER_ENTERING_WORLD" then
        if ShouldShowRes() then
            Addon.ResInSafeZoneButton:Show()
        else
            Addon.ResInSafeZoneButton:Hide()
        end
    elseif event == "PLAYER_UNGHOST" then 
        Addon.ResInSafeZoneButton:Hide()
    end
end)