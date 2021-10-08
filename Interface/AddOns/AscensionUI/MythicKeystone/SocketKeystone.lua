local Addon = select(2, ...)

local SocketKeystone = CreateFrame("FRAME", "SocketKeystone", UIParent, nil)
local MythicKeystone = Addon.MythicKeystone
MythicKeystone.SocketKeystone = SocketKeystone

-- Locals
local ITEM_BAG_TEMP = nil
local ITEM_SLOT_TEMP = nil
local ITEM_BAG_ACTIVE = nil
local ITEM_SLOT_ACTIVE = nil
local ITEM_ID_ACTIVE = nil

local HealthAffixTooltip = {
    "|cFFFFFFFFAugmentation de la santé|r",
    "Santé de toutes les créatures augmentée de "
}

local DamageAffixTooltip = {
    "|cFFFFFFFFDégâts Augmenté|r",
    "Dégâts de toutes les créatures augmentés de "
}

-- Sounds
local UI_70_CHALLENGE_MODE_SOCKET_PAGE_OPEN = 679
local UI_70_CHALLENGE_MODE_SOCKET_PAGE_CLOSE = 680
local UI_70_CHALLENGE_MODE_SOCKET_PAGE_SOCKET = 74431
local UI_70_CHALLENGE_MODE_SOCKET_PAGE_ACTIVATE_BUTTON = 61
local UI_70_CHALLENGE_MODE_SOCKET_PAGE_REMOVE_KEYSTONE = 1193

-- Helpers
local function GetLastLockedItem(bag, slot)
    if (bag and slot) then
        if (bag == 0) then
            ITEM_BAG_TEMP = 255
            ITEM_SLOT_TEMP = slot + 22
        else
            ITEM_BAG_TEMP = bag + 18
            ITEM_SLOT_TEMP = slot - 1
        end
    elseif (bag and (slot == nil)) then
        ITEM_BAG_TEMP = 255
        ITEM_SLOT_TEMP = bag - 1
    end
end

local function LoadKeystone(itemId)
    ITEM_ID_ACTIVE = itemId
    local keystone = Addon.KeystoneData[itemId]
    local level = keystone.mythicLevel
    local dmgPct = level * MythicKeystone.DamageMultiplier
    local healthPct = level * MythicKeystone.HealthMultiplier

    local affixes, affixCount = MythicKeystone:GetAffixes(MythicKeystone.CDB.Week, level)
    
    SocketKeystone:PlaceKeystone(itemId, keystone.instanceName, level, keystone.timeLimit, affixes, affixCount, dmgPct, healthPct)
end

-- SocketKeystone
SocketKeystone:SetSize(398, 548)
SocketKeystone:SetPoint("CENTER", 0, 40)
SocketKeystone:EnableMouse(true)
SocketKeystone:Hide()
SocketKeystone:RegisterEvent("ITEM_LOCKED")
SocketKeystone:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
SocketKeystone:SetScript("OnEvent", function(self, event, ...)
    if (event == "ITEM_LOCKED") then
        GetLastLockedItem(...)

    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local player, spellName = ...

        if player == "player" and spellName == "Activate Keystone" then
            local itemId = MythicKeystone:GetCurrentKeystone()
            LoadKeystone(itemId)

        end

    end
end)
SocketKeystone:SetScript("OnHide", function()
    SocketKeystone:ClearKeystone()
    PlaySound("igMainMenuClose")
end)
SocketKeystone:SetScript("OnShow", function() 
    PlaySound(UI_70_CHALLENGE_MODE_SOCKET_PAGE_OPEN)
end)

SocketKeystone.Affixes = {}

-- SocketKeystone.RuneBG
SocketKeystone.RuneBG = SocketKeystone:CreateTexture("SocketKeystone.RuneBG", "ARTWORK")
SocketKeystone.RuneBG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.RuneBG:SetPoint("CENTER", 0, 60)
SocketKeystone.RuneBG:SetSize(360, 360)
SocketKeystone.RuneBG:SetTexCoord(0.000976562, 0.694336, 0.000976562, 0.694336)
SocketKeystone.RuneBG:SetBlendMode("BLEND")
SocketKeystone.RuneBG:SetAlpha(1)

-- SocketKeystone.InstructionBackground
SocketKeystone.InstructionBackground = SocketKeystone:CreateTexture("SocketKeystone.InstructionBackground", "ARTWORK")
SocketKeystone.InstructionBackground:SetPoint("BOTTOM", 0, 80)
SocketKeystone.InstructionBackground:SetSize(374, 60)
SocketKeystone.InstructionBackground:SetTexture(0, 0, 0, 0.8)

-- SocketKeystone.BgBurst2
SocketKeystone.BgBurst2 = SocketKeystone:CreateTexture("SocketKeystone.BgBurst2", "ARTWORK")
SocketKeystone.BgBurst2:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.BgBurst2:SetPoint("CENTER", 0, 61)
SocketKeystone.BgBurst2:SetSize(301, 301)
SocketKeystone.BgBurst2:SetBlendMode("ADD")
SocketKeystone.BgBurst2:SetAlpha(0)
SocketKeystone.BgBurst2:SetTexCoord(0.696289, 0.989258, 0.000976562, 0.294922)

-- SocketKeystone.SlotFrame
SocketKeystone.SlotFrame = SocketKeystone:CreateTexture("SocketKeystone.SlotFrame", "ARTWORK")
SocketKeystone.SlotFrame:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
SocketKeystone.SlotFrame:SetPoint("CENTER", 0, 61)
SocketKeystone.SlotFrame:SetSize(120, 120)
SocketKeystone.SlotFrame:SetTexCoord(0.000976562, 0.118164, 0.641602, 0.758789)

-- SocketKeystone.KeystoneSlotGlow
SocketKeystone.KeystoneSlotGlow = SocketKeystone:CreateTexture("SocketKeystone.KeystoneSlotGlow", "OVERLAY")
SocketKeystone.KeystoneSlotGlow:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
SocketKeystone.KeystoneSlotGlow:SetPoint("CENTER", 0, 60)
SocketKeystone.KeystoneSlotGlow:SetAlpha(0)
SocketKeystone.KeystoneSlotGlow:SetSize(120, 120)
SocketKeystone.KeystoneSlotGlow:SetTexCoord(0.000976562, 0.118164, 0.522461, 0.639648)

-- SocketKeystone.CloseButton
SocketKeystone.CloseButton = CreateFrame("BUTTON", "CloseButton", SocketKeystone, "UIPanelCloseButton")
SocketKeystone.CloseButton:SetPoint("TOPRIGHT", -4, -5)
SocketKeystone.CloseButton:SetScript("OnMouseUp", function(self)
    PlaySound(UI_70_CHALLENGE_MODE_SOCKET_PAGE_CLOSE)
end)

-- SocketKeystone.StartButton
SocketKeystone.StartButton = CreateFrame("BUTTON", "StartButton", SocketKeystone, "UIPanelButtonTemplate")
SocketKeystone.StartButton:SetText("Activate")
SocketKeystone.StartButton:SetSize(120, 24)
SocketKeystone.StartButton:SetPoint("BOTTOM", 0, 20)
SocketKeystone.StartButton:SetScript("OnClick", function()
    if ITEM_ID_ACTIVE then
        ActivateMythicPlus()
        PlaySound(UI_70_CHALLENGE_MODE_SOCKET_PAGE_ACTIVATE_BUTTON)
    end

    SocketKeystone:Hide()

end)
SocketKeystone.StartButton:Disable()

-- SocketKeystone.KeystoneSlot
SocketKeystone.KeystoneSlot = CreateFrame("Button", "SocketKeystone.KeystoneSlot", SocketKeystone)
SocketKeystone.KeystoneSlot:SetSize(48, 48)
SocketKeystone.KeystoneSlot:SetPoint("CENTER", SocketKeystone, 0, 60)
SocketKeystone.KeystoneSlot:SetScript("OnMouseDown", function(self, button)
    if button == "RightButton" and (ITEM_BAG_ACTIVE ~= nil or ITEM_SLOT_ACTIVE ~= nil) then
        self:GetParent():ClearKeystone()
        return
    end

    local type, data, subType, subData = GetCursorInfo()
    ClearCursor()
    if type == "item" and ITEM_BAG_TEMP and ITEM_SLOT_TEMP then
        ITEM_BAG_ACTIVE = ITEM_BAG_TEMP
        ITEM_SLOT_ACTIVE = ITEM_SLOT_TEMP
        LoadKeystone(data)
        return true
    end
end)
SocketKeystone.KeystoneSlot:SetScript("OnEnter", function()
end)
SocketKeystone.KeystoneSlot:SetScript("OnLeave", function()
end)
SocketKeystone.KeystoneSlot.Icon = SocketKeystone.KeystoneSlot:CreateTexture(nil, "BACKGROUND")
SocketKeystone.KeystoneSlot.Icon:SetSize(48, 48)
SocketKeystone.KeystoneSlot.Icon:SetPoint("CENTER", 0, 0)

-- SocketKeystone.Divider
SocketKeystone.Divider = SocketKeystone:CreateTexture("SocketKeystone.Divider", "ARTWORK")
SocketKeystone.Divider:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
SocketKeystone.Divider:SetPoint("BOTTOM", SocketKeystone.InstructionBackground, "TOP", 0, 0)
SocketKeystone.Divider:SetSize(365, 5)
SocketKeystone.Divider:SetTexCoord(0.538086, 0.894531, 0.375, 0.37793)

-- SocketKeystone.DungeonName
SocketKeystone.DungeonName = SocketKeystone:CreateFontString(nil, "OVERLAY")
SocketKeystone.DungeonName:SetFont("Fonts\\MORPHEUS.TTF", 32)
SocketKeystone.DungeonName:SetShadowOffset(1, -1)
SocketKeystone.DungeonName:SetFontObject(GameFontHighlight)
SocketKeystone.DungeonName:SetSize(350, 0)
SocketKeystone.DungeonName:SetPoint("BOTTOM", SocketKeystone.Divider, "TOP", 0, 4)
SocketKeystone.DungeonName:SetText("|cffFFD100NOM DU DONJON|r")
SocketKeystone.DungeonName:Hide()

-- SocketKeystone.PowerLevel
SocketKeystone.PowerLevel = SocketKeystone:CreateFontString(nil, "OVERLAY")
SocketKeystone.PowerLevel:SetFont("Fonts\\MORPHEUS.TTF", 32)
SocketKeystone.PowerLevel:SetShadowOffset(1, -1)
SocketKeystone.PowerLevel:SetFontObject(GameFontHighlight)
SocketKeystone.PowerLevel:SetSize(350, 0)
SocketKeystone.PowerLevel:SetPoint("TOP", 0, -30)
SocketKeystone.PowerLevel:SetText("|cffFFD100Niveau 00|r")
SocketKeystone.PowerLevel:Hide()

-- SocketKeystone.TimeLimit
SocketKeystone.TimeLimit = SocketKeystone:CreateFontString(nil, "OVERLAY")
SocketKeystone.TimeLimit:SetFontObject(GameFontHighlightLarge)
SocketKeystone.TimeLimit:SetPoint("TOP", SocketKeystone.Divider, "TOP", 0, -6)
SocketKeystone.TimeLimit:SetText("00 Minutes")
SocketKeystone.TimeLimit:Hide()

-- SocketKeystone.Instructions
SocketKeystone.Instructions = SocketKeystone:CreateFontString(nil, "OVERLAY")
SocketKeystone.Instructions:SetFontObject(GameFontHighlightLarge)
SocketKeystone.Instructions:SetPoint("CENTER", SocketKeystone.InstructionBackground, "CENTER")
SocketKeystone.Instructions:SetText("Insérer une clé Mythique")

-- SocketKeystone.PentagonLines
SocketKeystone.PentagonLines = SocketKeystone:CreateTexture("SocketKeystone.PentagonLines", "OVERLAY")
SocketKeystone.PentagonLines:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
SocketKeystone.PentagonLines:SetPoint("CENTER", SocketKeystone.RuneBG, "CENTER", 0, 6)
SocketKeystone.PentagonLines:SetSize(242, 227)
SocketKeystone.PentagonLines:SetTexCoord(0.524414, 0.760742, 0.390625, 0.613281)
SocketKeystone.PentagonLines:SetBlendMode("BLEND")
SocketKeystone.PentagonLines:SetAlpha(0.55)
SocketKeystone.PentagonLines:Hide()

-- SocketKeystone.LargeCircleGlow
SocketKeystone.LargeCircleGlow = SocketKeystone:CreateTexture("SocketKeystone.LargeCircleGlow", "OVERLAY")
SocketKeystone.LargeCircleGlow:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.LargeCircleGlow:SetPoint("CENTER", SocketKeystone.RuneBG, "CENTER", 0, 5)
SocketKeystone.LargeCircleGlow:SetSize(211, 209)
SocketKeystone.LargeCircleGlow:SetTexCoord(0.732422, 0.938477, 0.696289, 0.900391)
SocketKeystone.LargeCircleGlow:SetBlendMode("BLEND")
SocketKeystone.LargeCircleGlow:SetAlpha(0.55)
SocketKeystone.LargeCircleGlow:Hide()

-- SocketKeystone.SmallCircleGlow
SocketKeystone.SmallCircleGlow = SocketKeystone:CreateTexture("SocketKeystone.SmallCircleGlow", "OVERLAY")
SocketKeystone.SmallCircleGlow:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
SocketKeystone.SmallCircleGlow:SetPoint("CENTER", SocketKeystone.RuneBG, "CENTER", 0, 1)
SocketKeystone.SmallCircleGlow:SetSize(130, 130)
SocketKeystone.SmallCircleGlow:SetTexCoord(0.000976562, 0.131836, 0.390625, 0.520508)
SocketKeystone.SmallCircleGlow:SetBlendMode("BLEND")
SocketKeystone.SmallCircleGlow:SetAlpha(0.55)
SocketKeystone.SmallCircleGlow:Hide()

-- SocketKeystone.Shockwave
SocketKeystone.Shockwave = SocketKeystone:CreateTexture("SocketKeystone.Shockwave", "OVERLAY")
SocketKeystone.Shockwave:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
SocketKeystone.Shockwave:SetPoint("CENTER", 0, 60)
SocketKeystone.Shockwave:SetSize(206, 209)
SocketKeystone.Shockwave:SetTexCoord(0.762695, 0.963867, 0.390625, 0.594727)
SocketKeystone.Shockwave:SetBlendMode("ADD")
SocketKeystone.Shockwave:SetAlpha(0)

-- SocketKeystone.Shockwave2
SocketKeystone.Shockwave2 = SocketKeystone:CreateTexture("SocketKeystone.Shockwave2", "OVERLAY")
SocketKeystone.Shockwave2:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
SocketKeystone.Shockwave2:SetPoint("CENTER", 0, 60)
SocketKeystone.Shockwave2:SetSize(206, 209)
SocketKeystone.Shockwave2:SetTexCoord(0.762695, 0.963867, 0.390625, 0.594727)
SocketKeystone.Shockwave2:SetBlendMode("ADD")
SocketKeystone.Shockwave2:SetAlpha(0)

-- SocketKeystone.RunesLarge
SocketKeystone.RunesLarge = SocketKeystone:CreateTexture("SocketKeystone.RunesLarge", "OVERLAY")
SocketKeystone.RunesLarge:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
SocketKeystone.RunesLarge:SetPoint("CENTER", 0, 60)
SocketKeystone.RunesLarge:SetSize(196, 196)
SocketKeystone.RunesLarge:SetTexCoord(0.538086, 0.910156, 0.000976562, 0.373047)
SocketKeystone.RunesLarge:SetBlendMode("BLEND")
SocketKeystone.RunesLarge:SetAlpha(0.15)

-- SocketKeystone.GlowBurstLarge
SocketKeystone.GlowBurstLarge = SocketKeystone:CreateTexture("SocketKeystone.GlowBurstLarge", "OVERLAY")
SocketKeystone.GlowBurstLarge:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.GlowBurstLarge:SetPoint("CENTER", SocketKeystone.RunesLarge, "CENTER", -1, -3)
SocketKeystone.GlowBurstLarge:SetSize(234, 234)
SocketKeystone.GlowBurstLarge:SetTexCoord(0.501953, 0.730469, 0.696289, 0.924805)
SocketKeystone.GlowBurstLarge:SetBlendMode("ADD")
SocketKeystone.GlowBurstLarge:SetAlpha(0)

-- SocketKeystone.RunesSmall
SocketKeystone.RunesSmall = SocketKeystone:CreateTexture("SocketKeystone.RunesSmall", "OVERLAY")
SocketKeystone.RunesSmall:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.RunesSmall:SetPoint("CENTER", 0, 60)
SocketKeystone.RunesSmall:SetSize(125, 125)
SocketKeystone.RunesSmall:SetTexCoord(0.257812, 0.5, 0.696289, 0.938477)
SocketKeystone.RunesSmall:SetBlendMode("BLEND")
SocketKeystone.RunesSmall:SetAlpha(0.15)

-- SocketKeystone.GlowBurstSmall
SocketKeystone.GlowBurstSmall = SocketKeystone:CreateTexture("SocketKeystone.GlowBurstSmall", "OVERLAY")
SocketKeystone.GlowBurstSmall:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.GlowBurstSmall:SetPoint("CENTER", 0, 60)
SocketKeystone.GlowBurstSmall:SetSize(234, 234)
SocketKeystone.GlowBurstSmall:SetTexCoord(0.501953, 0.730469, 0.696289, 0.924805)
SocketKeystone.GlowBurstSmall:SetBlendMode("BLEND")
SocketKeystone.GlowBurstSmall:SetAlpha(0)

-- SocketKeystone.SlotBG
SocketKeystone.SlotBG = SocketKeystone:CreateTexture("SocketKeystone.SlotBG", "BORDER")
SocketKeystone.SlotBG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
SocketKeystone.SlotBG:SetPoint("CENTER", 0, 61)
SocketKeystone.SlotBG:SetSize(114, 114)
SocketKeystone.SlotBG:SetTexCoord(0.000976562, 0.112305, 0.760742, 0.87207)

-- SocketKeystone.RuneCircleT
SocketKeystone.RuneCircleT = SocketKeystone:CreateTexture("SocketKeystone.RuneCircleT", "OVERLAY")
SocketKeystone.RuneCircleT:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.RuneCircleT:SetPoint("CENTER", SocketKeystone.RuneBG, "CENTER", 0, 126)
SocketKeystone.RuneCircleT:SetSize(48, 48)
SocketKeystone.RuneCircleT:SetTexCoord(0.696289, 0.790039, 0.567383, 0.661133)
SocketKeystone.RuneCircleT:SetBlendMode("BLEND")
SocketKeystone.RuneCircleT:SetAlpha(0)

-- SocketKeystone.RuneCircleR
SocketKeystone.RuneCircleR = SocketKeystone:CreateTexture("SocketKeystone.RuneCircleR", "OVERLAY")
SocketKeystone.RuneCircleR:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.RuneCircleR:SetPoint("CENTER", SocketKeystone.RuneBG, "CENTER", 118, 40)
SocketKeystone.RuneCircleR:SetSize(48, 48)
SocketKeystone.RuneCircleR:SetTexCoord(0.696289, 0.790039, 0.567383, 0.661133)
SocketKeystone.RuneCircleR:SetBlendMode("BLEND")
SocketKeystone.RuneCircleR:SetAlpha(0)

-- SocketKeystone.RuneCircleBR
SocketKeystone.RuneCircleBR = SocketKeystone:CreateTexture("SocketKeystone.RuneCircleBR", "OVERLAY")
SocketKeystone.RuneCircleBR:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.RuneCircleBR:SetPoint("CENTER", SocketKeystone.RuneBG, "CENTER", 73, -98)
SocketKeystone.RuneCircleBR:SetSize(48, 48)
SocketKeystone.RuneCircleBR:SetTexCoord(0.696289, 0.790039, 0.567383, 0.661133)
SocketKeystone.RuneCircleBR:SetBlendMode("BLEND")
SocketKeystone.RuneCircleBR:SetAlpha(0)

-- SocketKeystone.RuneCircleBL
SocketKeystone.RuneCircleBL = SocketKeystone:CreateTexture("SocketKeystone.RuneCircleBL", "OVERLAY")
SocketKeystone.RuneCircleBL:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.RuneCircleBL:SetPoint("CENTER", SocketKeystone.RuneBG, "CENTER", -73, -98)
SocketKeystone.RuneCircleBL:SetSize(48, 48)
SocketKeystone.RuneCircleBL:SetTexCoord(0.696289, 0.790039, 0.567383, 0.661133)
SocketKeystone.RuneCircleBL:SetBlendMode("BLEND")
SocketKeystone.RuneCircleBL:SetAlpha(0)

-- SocketKeystone.RuneCircleL
SocketKeystone.RuneCircleL = SocketKeystone:CreateTexture("SocketKeystone.RuneCircleL", "OVERLAY")
SocketKeystone.RuneCircleL:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.RuneCircleL:SetPoint("CENTER", SocketKeystone.RuneBG, "CENTER", -118, 40)
SocketKeystone.RuneCircleL:SetSize(48, 48)
SocketKeystone.RuneCircleL:SetTexCoord(0.696289, 0.790039, 0.567383, 0.661133)
SocketKeystone.RuneCircleL:SetBlendMode("BLEND")
SocketKeystone.RuneCircleL:SetAlpha(0)

-- SocketKeystone.KeystoneFrame
SocketKeystone.KeystoneFrame = SocketKeystone:CreateTexture("SocketKeystone.KeystoneFrame", "BACKGROUND")
SocketKeystone.KeystoneFrame:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
SocketKeystone.KeystoneFrame:SetPoint("CENTER", 0, 0)
SocketKeystone.KeystoneFrame:SetSize(398, 548)
SocketKeystone.KeystoneFrame:SetTexCoord(0.133789, 0.522461, 0.390625, 0.925781)

-- SocketKeystone.RuneT
SocketKeystone.RuneT = SocketKeystone:CreateTexture("SocketKeystone.RuneT", "OVERLAY")
SocketKeystone.RuneT:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.RuneT:SetPoint("CENTER", SocketKeystone.RuneCircleT, "CENTER", 0, 0)
SocketKeystone.RuneT:SetSize(40, 40)
SocketKeystone.RuneT:SetTexCoord(0.888672, 0.964844, 0.902344, 0.978516)
SocketKeystone.RuneT:SetBlendMode("BLEND")
SocketKeystone.RuneT:SetAlpha(0)

-- SocketKeystone.RuneR
SocketKeystone.RuneR = SocketKeystone:CreateTexture("SocketKeystone.RuneR", "OVERLAY")
SocketKeystone.RuneR:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.RuneR:SetPoint("CENTER", SocketKeystone.RuneCircleR, "CENTER", 0, 0)
SocketKeystone.RuneR:SetSize(40, 40)
SocketKeystone.RuneR:SetTexCoord(0.810547, 0.886719, 0.902344, 0.978516)
SocketKeystone.RuneR:SetBlendMode("BLEND")
SocketKeystone.RuneR:SetAlpha(0)

-- SocketKeystone.RuneBR
SocketKeystone.RuneBR = SocketKeystone:CreateTexture("SocketKeystone.RuneBR", "OVERLAY")
SocketKeystone.RuneBR:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.RuneBR:SetPoint("CENTER", SocketKeystone.RuneCircleBR, "CENTER", 0, 0)
SocketKeystone.RuneBR:SetSize(40, 40)
SocketKeystone.RuneBR:SetTexCoord(0.870117, 0.946289, 0.567383, 0.643555)
SocketKeystone.RuneBR:SetBlendMode("BLEND")
SocketKeystone.RuneBR:SetAlpha(0)

-- SocketKeystone.RuneBL
SocketKeystone.RuneBL = SocketKeystone:CreateTexture("SocketKeystone.RuneBL", "OVERLAY")
SocketKeystone.RuneBL:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.RuneBL:SetPoint("CENTER", SocketKeystone.RuneCircleBL, "CENTER", 0, 0)
SocketKeystone.RuneBL:SetSize(40, 40)
SocketKeystone.RuneBL:SetTexCoord(0.791992, 0.868164, 0.567383, 0.643555)
SocketKeystone.RuneBL:SetBlendMode("BLEND")
SocketKeystone.RuneBL:SetAlpha(0)

-- SocketKeystone.RuneL
SocketKeystone.RuneL = SocketKeystone:CreateTexture("SocketKeystone.RuneL", "OVERLAY")
SocketKeystone.RuneL:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.RuneL:SetPoint("CENTER", SocketKeystone.RuneCircleL, "CENTER", 0, 0)
SocketKeystone.RuneL:SetSize(40, 40)
SocketKeystone.RuneL:SetTexCoord(0.732422, 0.808594, 0.902344, 0.978516)
SocketKeystone.RuneL:SetBlendMode("BLEND")
SocketKeystone.RuneL:SetAlpha(0)

-- SocketKeystone.LargeRuneGlow
SocketKeystone.LargeRuneGlow = SocketKeystone:CreateTexture("SocketKeystone.LargeRuneGlow", "OVERLAY")
SocketKeystone.LargeRuneGlow:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
SocketKeystone.LargeRuneGlow:SetPoint("CENTER", 0, 61)
SocketKeystone.LargeRuneGlow:SetSize(198, 199)
SocketKeystone.LargeRuneGlow:SetTexCoord(0.524414, 0.907227, 0.615234, 0.99707)
SocketKeystone.LargeRuneGlow:SetBlendMode("ADD")
SocketKeystone.LargeRuneGlow:SetAlpha(0)

-- SocketKeystone.SmallRuneGlow
SocketKeystone.SmallRuneGlow = SocketKeystone:CreateTexture("SocketKeystone.SmallRuneGlow", "OVERLAY")
SocketKeystone.SmallRuneGlow:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SocketKeystone.SmallRuneGlow:SetPoint("CENTER", 0, 61)
SocketKeystone.SmallRuneGlow:SetSize(129, 129)
SocketKeystone.SmallRuneGlow:SetTexCoord(0.000976562, 0.255859, 0.696289, 0.950195)
SocketKeystone.SmallRuneGlow:SetBlendMode("ADD")
SocketKeystone.SmallRuneGlow:SetAlpha(0)

-------------------------------------------------------------------------------
--                                 Animations                                --
-------------------------------------------------------------------------------

-- SocketKeystone.KeystoneSlotGlow.AnimationGroup
SocketKeystone.KeystoneSlotGlow.AnimationGroup = SocketKeystone.KeystoneSlotGlow:CreateAnimationGroup()
SocketKeystone.KeystoneSlotGlow.AnimationGroup.Alpha0 = SocketKeystone.KeystoneSlotGlow.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.KeystoneSlotGlow.AnimationGroup.Alpha0:SetDuration(1)
SocketKeystone.KeystoneSlotGlow.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.KeystoneSlotGlow.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.KeystoneSlotGlow.AnimationGroup.Alpha0:SetScript("OnFinished", function()
    SocketKeystone.KeystoneSlotGlow.AnimationGroup.Alpha0:Stop()
    SocketKeystone.KeystoneSlotGlow:SetAlpha(1)
end)

SocketKeystone.PentagonLines.AnimationGroup = SocketKeystone.PentagonLines:CreateAnimationGroup()
SocketKeystone.PentagonLines.AnimationGroup.Alpha0 = SocketKeystone.PentagonLines.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.PentagonLines.AnimationGroup.Alpha0:SetStartDelay(0.15)
SocketKeystone.PentagonLines.AnimationGroup.Alpha0:SetSmoothing("IN")
SocketKeystone.PentagonLines.AnimationGroup.Alpha0:SetDuration(0.25)
SocketKeystone.PentagonLines.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.PentagonLines.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.PentagonLines.AnimationGroup.Alpha1 = SocketKeystone.PentagonLines.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.PentagonLines.AnimationGroup.Alpha1:SetStartDelay(0.55)
SocketKeystone.PentagonLines.AnimationGroup.Alpha1:SetSmoothing("IN_OUT")
SocketKeystone.PentagonLines.AnimationGroup.Alpha1:SetDuration(1)
SocketKeystone.PentagonLines.AnimationGroup.Alpha1:SetOrder(1)
SocketKeystone.PentagonLines.AnimationGroup.Alpha1:SetChange(-0.45)

SocketKeystone.LargeCircleGlow.AnimationGroup = SocketKeystone.LargeCircleGlow:CreateAnimationGroup()
SocketKeystone.LargeCircleGlow.AnimationGroup.Alpha0 = SocketKeystone.LargeCircleGlow.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.LargeCircleGlow.AnimationGroup.Alpha0:SetStartDelay(0.05)
SocketKeystone.LargeCircleGlow.AnimationGroup.Alpha0:SetSmoothing("IN")
SocketKeystone.LargeCircleGlow.AnimationGroup.Alpha0:SetDuration(0.25)
SocketKeystone.LargeCircleGlow.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.LargeCircleGlow.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.LargeCircleGlow.AnimationGroup.Alpha1 = SocketKeystone.LargeCircleGlow.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.LargeCircleGlow.AnimationGroup.Alpha1:SetStartDelay(0.35)
SocketKeystone.LargeCircleGlow.AnimationGroup.Alpha1:SetSmoothing("IN_OUT")
SocketKeystone.LargeCircleGlow.AnimationGroup.Alpha1:SetDuration(1)
SocketKeystone.LargeCircleGlow.AnimationGroup.Alpha1:SetOrder(1)
SocketKeystone.LargeCircleGlow.AnimationGroup.Alpha1:SetChange(-0.45)

SocketKeystone.SmallCircleGlow.AnimationGroup = SocketKeystone.SmallCircleGlow:CreateAnimationGroup()
SocketKeystone.SmallCircleGlow.AnimationGroup.Alpha0 = SocketKeystone.SmallCircleGlow.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.SmallCircleGlow.AnimationGroup.Alpha0:SetSmoothing("IN")
SocketKeystone.SmallCircleGlow.AnimationGroup.Alpha0:SetDuration(0.25)
SocketKeystone.SmallCircleGlow.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.SmallCircleGlow.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.SmallCircleGlow.AnimationGroup.Alpha1 = SocketKeystone.SmallCircleGlow.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.SmallCircleGlow.AnimationGroup.Alpha1:SetStartDelay(0.25)
SocketKeystone.SmallCircleGlow.AnimationGroup.Alpha1:SetSmoothing("IN_OUT")
SocketKeystone.SmallCircleGlow.AnimationGroup.Alpha1:SetDuration(1)
SocketKeystone.SmallCircleGlow.AnimationGroup.Alpha1:SetOrder(1)
SocketKeystone.SmallCircleGlow.AnimationGroup.Alpha1:SetChange(-0.45)

-- SocketKeystone.RuneCircleT.AnimationGroup
SocketKeystone.RuneCircleT.AnimationGroup = SocketKeystone.RuneCircleT:CreateAnimationGroup()
SocketKeystone.RuneCircleT.AnimationGroup.Alpha0 = SocketKeystone.RuneCircleT.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.RuneCircleT.AnimationGroup.Alpha0:SetStartDelay(0.35)
SocketKeystone.RuneCircleT.AnimationGroup.Alpha0:SetDuration(0.35)
SocketKeystone.RuneCircleT.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.RuneCircleT.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.RuneCircleT.AnimationGroup.Alpha0:SetScript("OnFinished", function()
    SocketKeystone.RuneCircleT.AnimationGroup.Alpha0:Stop()
    SocketKeystone.RuneCircleT:SetAlpha(1)
end)

-- SocketKeystone.RuneT.AnimationGroup
SocketKeystone.RuneT.AnimationGroup = SocketKeystone.RuneT:CreateAnimationGroup()
SocketKeystone.RuneT.AnimationGroup.Alpha0 = SocketKeystone.RuneT.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.RuneT.AnimationGroup.Alpha0:SetStartDelay(0.45)
SocketKeystone.RuneT.AnimationGroup.Alpha0:SetSmoothing("OUT")
SocketKeystone.RuneT.AnimationGroup.Alpha0:SetDuration(0.45)
SocketKeystone.RuneT.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.RuneT.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.RuneT.AnimationGroup.Alpha0:SetScript("OnFinished", function()
    SocketKeystone.RuneT.AnimationGroup.Alpha0:Stop()
    SocketKeystone.RuneT:SetAlpha(1)
end)

-- SocketKeystone.RuneCircleR.AnimationGroup
SocketKeystone.RuneCircleR.AnimationGroup = SocketKeystone.RuneCircleR:CreateAnimationGroup()
SocketKeystone.RuneCircleR.AnimationGroup.Alpha0 = SocketKeystone.RuneCircleR.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.RuneCircleR.AnimationGroup.Alpha0:SetStartDelay(0.35)
SocketKeystone.RuneCircleR.AnimationGroup.Alpha0:SetDuration(0.35)
SocketKeystone.RuneCircleR.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.RuneCircleR.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.RuneCircleR.AnimationGroup.Alpha0:SetScript("OnFinished", function()
    SocketKeystone.RuneCircleR.AnimationGroup.Alpha0:Stop()
    SocketKeystone.RuneCircleR:SetAlpha(1)
end)

-- SocketKeystone.RuneR.AnimationGroup
SocketKeystone.RuneR.AnimationGroup = SocketKeystone.RuneR:CreateAnimationGroup()
SocketKeystone.RuneR.AnimationGroup.Alpha0 = SocketKeystone.RuneR.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.RuneR.AnimationGroup.Alpha0:SetStartDelay(0.45)
SocketKeystone.RuneR.AnimationGroup.Alpha0:SetSmoothing("OUT")
SocketKeystone.RuneR.AnimationGroup.Alpha0:SetDuration(0.45)
SocketKeystone.RuneR.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.RuneR.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.RuneR.AnimationGroup.Alpha0:SetScript("OnFinished", function()
    SocketKeystone.RuneR.AnimationGroup.Alpha0:Stop()
    SocketKeystone.RuneR:SetAlpha(1)
end)

-- SocketKeystone.RuneCircleBR.AnimationGroup
SocketKeystone.RuneCircleBR.AnimationGroup = SocketKeystone.RuneCircleBR:CreateAnimationGroup()
SocketKeystone.RuneCircleBR.AnimationGroup.Alpha0 = SocketKeystone.RuneCircleBR.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.RuneCircleBR.AnimationGroup.Alpha0:SetStartDelay(0.35)
SocketKeystone.RuneCircleBR.AnimationGroup.Alpha0:SetDuration(0.35)
SocketKeystone.RuneCircleBR.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.RuneCircleBR.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.RuneCircleBR.AnimationGroup.Alpha0:SetScript("OnFinished", function()
    SocketKeystone.RuneCircleBR.AnimationGroup.Alpha0:Stop()
    SocketKeystone.RuneCircleBR:SetAlpha(1)
end)

-- SocketKeystone.RuneBR.AnimationGroup
SocketKeystone.RuneBR.AnimationGroup = SocketKeystone.RuneBR:CreateAnimationGroup()
SocketKeystone.RuneBR.AnimationGroup.Alpha0 = SocketKeystone.RuneBR.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.RuneBR.AnimationGroup.Alpha0:SetStartDelay(0.45)
SocketKeystone.RuneBR.AnimationGroup.Alpha0:SetSmoothing("OUT")
SocketKeystone.RuneBR.AnimationGroup.Alpha0:SetDuration(0.45)
SocketKeystone.RuneBR.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.RuneBR.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.RuneBR.AnimationGroup.Alpha0:SetScript("OnFinished", function()
    SocketKeystone.RuneBR.AnimationGroup.Alpha0:Stop()
    SocketKeystone.RuneBR:SetAlpha(1)
end)

-- SocketKeystone.RuneCircleBL.AnimationGroup
SocketKeystone.RuneCircleBL.AnimationGroup = SocketKeystone.RuneCircleBL:CreateAnimationGroup()
SocketKeystone.RuneCircleBL.AnimationGroup.Alpha0 = SocketKeystone.RuneCircleBL.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.RuneCircleBL.AnimationGroup.Alpha0:SetStartDelay(0.35)
SocketKeystone.RuneCircleBL.AnimationGroup.Alpha0:SetDuration(0.35)
SocketKeystone.RuneCircleBL.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.RuneCircleBL.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.RuneCircleBL.AnimationGroup.Alpha0:SetScript("OnFinished", function()
    SocketKeystone.RuneCircleBL.AnimationGroup.Alpha0:Stop()
    SocketKeystone.RuneCircleBL:SetAlpha(1)
end)

-- SocketKeystone.RuneBL.AnimationGroup
SocketKeystone.RuneBL.AnimationGroup = SocketKeystone.RuneBL:CreateAnimationGroup()
SocketKeystone.RuneBL.AnimationGroup.Alpha0 = SocketKeystone.RuneBL.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.RuneBL.AnimationGroup.Alpha0:SetStartDelay(0.45)
SocketKeystone.RuneBL.AnimationGroup.Alpha0:SetSmoothing("OUT")
SocketKeystone.RuneBL.AnimationGroup.Alpha0:SetDuration(0.45)
SocketKeystone.RuneBL.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.RuneBL.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.RuneBL.AnimationGroup.Alpha0:SetScript("OnFinished", function()
    SocketKeystone.RuneBL.AnimationGroup.Alpha0:Stop()
    SocketKeystone.RuneBL:SetAlpha(1)
end)

-- SocketKeystone.RuneCircleL.AnimationGroup
SocketKeystone.RuneCircleL.AnimationGroup = SocketKeystone.RuneCircleL:CreateAnimationGroup()
SocketKeystone.RuneCircleL.AnimationGroup.Alpha0 = SocketKeystone.RuneCircleL.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.RuneCircleL.AnimationGroup.Alpha0:SetStartDelay(0.35)
SocketKeystone.RuneCircleL.AnimationGroup.Alpha0:SetDuration(0.35)
SocketKeystone.RuneCircleL.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.RuneCircleL.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.RuneCircleL.AnimationGroup.Alpha0:SetScript("OnFinished", function()
    SocketKeystone.RuneCircleL.AnimationGroup.Alpha0:Stop()
    SocketKeystone.RuneCircleL:SetAlpha(1)
end)

-- SocketKeystone.RuneL.AnimationGroup
SocketKeystone.RuneL.AnimationGroup = SocketKeystone.RuneL:CreateAnimationGroup()
SocketKeystone.RuneL.AnimationGroup.Alpha0 = SocketKeystone.RuneL.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.RuneL.AnimationGroup.Alpha0:SetStartDelay(0.45)
SocketKeystone.RuneL.AnimationGroup.Alpha0:SetSmoothing("OUT")
SocketKeystone.RuneL.AnimationGroup.Alpha0:SetDuration(0.45)
SocketKeystone.RuneL.AnimationGroup.Alpha0:SetChange(1)
SocketKeystone.RuneL.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.RuneL.AnimationGroup.Alpha0:SetScript("OnFinished", function()
    SocketKeystone.RuneL.AnimationGroup.Alpha0:Stop()
    SocketKeystone.RuneL:SetAlpha(1)
end)

-- SocketKeystone.BgBurst2.AnimationGroup
SocketKeystone.BgBurst2.AnimationGroup = SocketKeystone.BgBurst2:CreateAnimationGroup()
SocketKeystone.BgBurst2.AnimationGroup:SetScript("OnFinished", function()
    -- @robinsch: Repeat should reset initial start delay
    SocketKeystone.BgBurst2.AnimationGroup.Alpha0:SetStartDelay(0)
    SocketKeystone.BgBurst2.AnimationGroup.Alpha1:SetStartDelay(1.5)
    SocketKeystone.BgBurst2.AnimationGroup:Play()
end)
SocketKeystone.BgBurst2.AnimationGroup.Alpha0 = SocketKeystone.BgBurst2.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.BgBurst2.AnimationGroup.Alpha0:SetStartDelay(0.9 + 0.0)
SocketKeystone.BgBurst2.AnimationGroup.Alpha0:SetDuration(1.5)
SocketKeystone.BgBurst2.AnimationGroup.Alpha0:SetChange(0.75)
SocketKeystone.BgBurst2.AnimationGroup.Alpha0:SetOrder(1)
SocketKeystone.BgBurst2.AnimationGroup.Alpha1 = SocketKeystone.BgBurst2.AnimationGroup:CreateAnimation("Alpha")
SocketKeystone.BgBurst2.AnimationGroup.Alpha1:SetStartDelay(0.9 + 1.5)
SocketKeystone.BgBurst2.AnimationGroup.Alpha1:SetDuration(1.5)
SocketKeystone.BgBurst2.AnimationGroup.Alpha1:SetChange(-0.75)
SocketKeystone.BgBurst2.AnimationGroup.Alpha1:SetOrder(1)

-- SocketKeystone.RunesLarge.AnimationGroup
SocketKeystone.RunesLarge.AnimationGroup = SocketKeystone.RunesLarge:CreateAnimationGroup()
SocketKeystone.RunesLarge.AnimationGroup:SetScript("OnFinished", function()
    SocketKeystone.RunesLarge.AnimationGroup:Play()
end)
SocketKeystone.RunesLarge.AnimationGroup.Rotation = SocketKeystone.RunesLarge.AnimationGroup:CreateAnimation("Rotation")
SocketKeystone.RunesLarge.AnimationGroup.Rotation:SetDuration(160)
SocketKeystone.RunesLarge.AnimationGroup.Rotation:SetOrder(1)
SocketKeystone.RunesLarge.AnimationGroup.Rotation:SetDegrees(-360)

-- SocketKeystone.LargeRuneGlow.AnimationGroup
SocketKeystone.LargeRuneGlow.AnimationGroup = SocketKeystone.LargeRuneGlow:CreateAnimationGroup()
SocketKeystone.LargeRuneGlow.AnimationGroup:SetScript("OnFinished", function()
    SocketKeystone.LargeRuneGlow.AnimationGroup:Play()
end)
SocketKeystone.LargeRuneGlow.AnimationGroup.Rotation = SocketKeystone.LargeRuneGlow.AnimationGroup:CreateAnimation("Rotation")
SocketKeystone.LargeRuneGlow.AnimationGroup.Rotation:SetDuration(160)
SocketKeystone.LargeRuneGlow.AnimationGroup.Rotation:SetOrder(1)
SocketKeystone.LargeRuneGlow.AnimationGroup.Rotation:SetDegrees(-360)

-- SocketKeystone.GlowBurstLarge.AnimationGroup
SocketKeystone.GlowBurstLarge.AnimationGroup = SocketKeystone.GlowBurstLarge:CreateAnimationGroup()
SocketKeystone.GlowBurstLarge.AnimationGroup:SetScript("OnFinished", function()
    SocketKeystone.GlowBurstLarge.AnimationGroup:Play()
end)
SocketKeystone.GlowBurstLarge.AnimationGroup.Rotation = SocketKeystone.GlowBurstLarge.AnimationGroup:CreateAnimation("Rotation")
SocketKeystone.GlowBurstLarge.AnimationGroup.Rotation:SetDuration(160)
SocketKeystone.GlowBurstLarge.AnimationGroup.Rotation:SetOrder(1)
SocketKeystone.GlowBurstLarge.AnimationGroup.Rotation:SetDegrees(-360)

-- SocketKeystone.RunesSmall.AnimationGroup
SocketKeystone.RunesSmall.AnimationGroup = SocketKeystone.RunesSmall:CreateAnimationGroup()
SocketKeystone.RunesSmall.AnimationGroup:SetScript("OnFinished", function()
    SocketKeystone.RunesSmall.AnimationGroup:Play()
end)
SocketKeystone.RunesSmall.AnimationGroup.Rotation = SocketKeystone.RunesSmall.AnimationGroup:CreateAnimation("Rotation")
SocketKeystone.RunesSmall.AnimationGroup.Rotation:SetDuration(160)
SocketKeystone.RunesSmall.AnimationGroup.Rotation:SetOrder(1)
SocketKeystone.RunesSmall.AnimationGroup.Rotation:SetDegrees(360)

-- SocketKeystone.SmallRuneGlow.AnimationGroup
SocketKeystone.SmallRuneGlow.AnimationGroup = SocketKeystone.SmallRuneGlow:CreateAnimationGroup()
SocketKeystone.SmallRuneGlow.AnimationGroup:SetScript("OnFinished", function()
    SocketKeystone.SmallRuneGlow.AnimationGroup:Play()
end)
SocketKeystone.SmallRuneGlow.AnimationGroup.Rotation = SocketKeystone.SmallRuneGlow.AnimationGroup:CreateAnimation("Rotation")
SocketKeystone.SmallRuneGlow.AnimationGroup.Rotation:SetDuration(160)
SocketKeystone.SmallRuneGlow.AnimationGroup.Rotation:SetOrder(1)
SocketKeystone.SmallRuneGlow.AnimationGroup.Rotation:SetDegrees(360)

-- SocketKeystone.GlowBurstSmall.AnimationGroup
SocketKeystone.GlowBurstSmall.AnimationGroup = SocketKeystone.GlowBurstSmall:CreateAnimationGroup()
SocketKeystone.GlowBurstSmall.AnimationGroup:SetScript("OnFinished", function()
    SocketKeystone.GlowBurstSmall.AnimationGroup:Play()
end)
SocketKeystone.GlowBurstSmall.AnimationGroup.Rotation = SocketKeystone.GlowBurstSmall.AnimationGroup:CreateAnimation("Rotation")
SocketKeystone.GlowBurstSmall.AnimationGroup.Rotation:SetDuration(160)
SocketKeystone.GlowBurstSmall.AnimationGroup.Rotation:SetOrder(1)
SocketKeystone.GlowBurstSmall.AnimationGroup.Rotation:SetDegrees(360)

local function PlayPulseAnim()
    SocketKeystone.BgBurst2.AnimationGroup:Play()
end

local function PlayRunesLargeRotateAnim()
    SocketKeystone.RunesLarge.AnimationGroup:Play()
    SocketKeystone.LargeRuneGlow.AnimationGroup:Play()
    SocketKeystone.GlowBurstLarge.AnimationGroup:Play()
end

local function PlayRunesSmallRotateAnim()
    SocketKeystone.RunesSmall.AnimationGroup:Play()
    SocketKeystone.SmallRuneGlow.AnimationGroup:Play()
    SocketKeystone.GlowBurstSmall.AnimationGroup:Play()
end

local function PlayInsertedAnim()
    SocketKeystone.KeystoneSlotGlow:Show()
    SocketKeystone.KeystoneSlotGlow.AnimationGroup:Play()
    SocketKeystone.PentagonLines:Show()
    SocketKeystone.PentagonLines.AnimationGroup:Play()
    SocketKeystone.LargeCircleGlow:Show()
    SocketKeystone.LargeCircleGlow.AnimationGroup:Play()
    SocketKeystone.SmallCircleGlow:Show()
    SocketKeystone.SmallCircleGlow.AnimationGroup:Play()
    SocketKeystone.RuneCircleT.AnimationGroup:Play()
    SocketKeystone.RuneT.AnimationGroup:Play()
    SocketKeystone.RuneCircleR.AnimationGroup:Play()
    SocketKeystone.RuneR.AnimationGroup:Play()
    SocketKeystone.RuneCircleBR.AnimationGroup:Play()
    SocketKeystone.RuneBR.AnimationGroup:Play()
    SocketKeystone.RuneCircleBL.AnimationGroup:Play()
    SocketKeystone.RuneBL.AnimationGroup:Play()
    SocketKeystone.RuneCircleL.AnimationGroup:Play()
    SocketKeystone.RuneL.AnimationGroup:Play()

    PlayPulseAnim()
    PlayRunesLargeRotateAnim()
    PlayRunesSmallRotateAnim()
end

local function ResetAnim()
    SocketKeystone.KeystoneSlotGlow:Hide()
    SocketKeystone.PentagonLines:Hide()
    SocketKeystone.LargeCircleGlow:Hide()
    SocketKeystone.SmallCircleGlow:Hide()
    SocketKeystone.RuneCircleT:SetAlpha(0)
    SocketKeystone.RuneCircleT.AnimationGroup:Stop()
    SocketKeystone.RuneT:SetAlpha(0)
    SocketKeystone.RuneT.AnimationGroup:Stop()
    SocketKeystone.RuneCircleR:SetAlpha(0)
    SocketKeystone.RuneCircleR.AnimationGroup:Stop()
    SocketKeystone.RuneR:SetAlpha(0)
    SocketKeystone.RuneR.AnimationGroup:Stop()
    SocketKeystone.RuneCircleBR:SetAlpha(0)
    SocketKeystone.RuneCircleBR.AnimationGroup:Stop()
    SocketKeystone.RuneBR:SetAlpha(0)
    SocketKeystone.RuneBR.AnimationGroup:Stop()
    SocketKeystone.RuneCircleBL:SetAlpha(0)
    SocketKeystone.RuneCircleBL.AnimationGroup:Stop()
    SocketKeystone.RuneBL:SetAlpha(0)
    SocketKeystone.RuneBL.AnimationGroup:Stop()
    SocketKeystone.RuneCircleL:SetAlpha(0)
    SocketKeystone.RuneCircleL.AnimationGroup:Stop()
    SocketKeystone.RuneL:SetAlpha(0)
    SocketKeystone.RuneL.AnimationGroup:Stop()
    SocketKeystone.BgBurst2.AnimationGroup:Stop()
    SocketKeystone.RunesLarge.AnimationGroup:Stop()
    SocketKeystone.LargeRuneGlow.AnimationGroup:Stop()
    SocketKeystone.GlowBurstLarge.AnimationGroup:Stop()
    SocketKeystone.RunesSmall.AnimationGroup:Stop()
    SocketKeystone.RunesSmall.AnimationGroup:Stop()
    SocketKeystone.SmallRuneGlow.AnimationGroup:Stop()
    SocketKeystone.GlowBurstSmall.AnimationGroup:Stop()
end

-------------------------------------------------------------------------------
--                                Affix Frames                               --
-------------------------------------------------------------------------------

for i=1,6 do
    _G["SocketKeystone.Affix"..i] = CreateFrame("FRAME", "SocketKeystone.Affix"..i, SocketKeystone, nil);
    if i == 1 then
        _G["SocketKeystone.Affix"..i]:SetPoint("BOTTOM", SocketKeystone.Divider, "BOTTOM", 0, -80)
    else
        _G["SocketKeystone.Affix"..i]:SetPoint("LEFT", _G["SocketKeystone.Affix"..i-1], "RIGHT", 4, 0);
    end
    _G["SocketKeystone.Affix"..i]:SetSize(52, 52)
    _G["SocketKeystone.Affix"..i]:EnableMouse(true)
    _G["SocketKeystone.Affix"..i]:Hide()

    _G["SocketKeystone.Affix"..i].Border = _G["SocketKeystone.Affix"..i]:CreateTexture("SocketKeystone.Affix"..i..".Border", "OVERLAY")
    _G["SocketKeystone.Affix"..i].Border:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
    _G["SocketKeystone.Affix"..i].Border:SetSize(52, 52)
    _G["SocketKeystone.Affix"..i].Border:SetPoint("CENTER", 0, 0)
    _G["SocketKeystone.Affix"..i].Border:SetTexCoord(0.912109, 0.962891, 0.0537109, 0.104492)

    _G["SocketKeystone.Affix"..i].Percent = _G["SocketKeystone.Affix"..i]:CreateFontString(nil, "OVERLAY")
    _G["SocketKeystone.Affix"..i].Percent:SetFont("Fonts\\FRIZQT__.TTF", 14, "THICKOUTLINE")
    _G["SocketKeystone.Affix"..i].Percent:SetPoint("BOTTOM", _G["SocketKeystone.Affix"..i].Border, "BOTTOM", 0, -4)
    _G["SocketKeystone.Affix"..i].Percent:SetText("")

    _G["SocketKeystone.Affix"..i].Portrait = _G["SocketKeystone.Affix"..i]:CreateTexture("SocketKeystone.Affix"..i..".Portrait", "ARTWORK")
    _G["SocketKeystone.Affix"..i].Portrait:SetSize(50, 50)
    _G["SocketKeystone.Affix"..i].Portrait:SetPoint("CENTER", _G["SocketKeystone.Affix"..i].Border, "CENTER", 0, 0)
end

SetPortraitToTexture(_G["SocketKeystone.Affix1.Portrait"], "Interface\\Icons\\Ability_DualWield")
_G["SocketKeystone.Affix1"].Percent:SetText("0%")
SetPortraitToTexture(_G["SocketKeystone.Affix2.Portrait"], "Interface\\Icons\\Spell_Holy_SealOfSacrifice")
_G["SocketKeystone.Affix2"].Percent:SetText("0%")

function SocketKeystone:PositionAffixes(num)
    if num > 6 then
        num = 6
    end

    local frameWidth, spacing, distance = 52, 4, -34;
    -- Figure out where to place the leftmost spell
    if (num % 2 == 1) then
        local x = (num - 1) / 2;
        _G["SocketKeystone.Affix1"]:SetPoint("TOPLEFT", _G["SocketKeystone.Divider"], "TOP", -((frameWidth / 2) + (frameWidth * x) + (spacing * x)), distance);
    else
        local x = num / 2;
        _G["SocketKeystone.Affix1"]:SetPoint("TOPLEFT", _G["SocketKeystone.Divider"], "TOP", -((frameWidth * x) + (spacing * (x - 1)) + (spacing / 2)), distance);
    end
end

function SocketKeystone:ShowAffixes(affixes, count, dmgPct, healthPct)
    local num = count
    if num > 4 then
        num = 4
    end
    -- tooltips for health and damage 
    _G["SocketKeystone.Affix1"]:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        for i, line in ipairs(DamageAffixTooltip) do
            if i == 2 then
                line = line .. "|cFFFF8000"..dmgPct.."%|r"
            end
            GameTooltip:AddLine(line)
            GameTooltip:Show()
        end
    end)
    _G["SocketKeystone.Affix1"]:SetScript("OnLeave", function() GameTooltip:Hide() end)

    _G["SocketKeystone.Affix2"]:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        for i, line in ipairs(HealthAffixTooltip) do
            if i == 2 then
                line = line .. "|cFFFF8000"..healthPct.."%|r"
            end
            GameTooltip:AddLine(line)
            GameTooltip:Show()
        end
    end)
    _G["SocketKeystone.Affix2"]:SetScript("OnLeave", function() GameTooltip:Hide() end)

    _G["SocketKeystone.Affix1"].Percent:SetText(dmgPct.."%")
    _G["SocketKeystone.Affix2"].Percent:SetText(healthPct.."%")
    _G["SocketKeystone.Affix1"]:Show()
    _G["SocketKeystone.Affix2"]:Show()

    local frameIndex = 2
    local i = 1
    for spellId in pairs(affixes) do
        if i <= num then
            local spellName, _, spellIcon = GetSpellInfo(spellId)
            --if not spellName then print(spellId) end
            SetPortraitToTexture(_G["SocketKeystone.Affix"..(frameIndex+i)..".Portrait"], spellIcon)

            _G["SocketKeystone.Affix"..i+2]:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink("|Hspell:"..spellId.."|h["..spellName.."]|h")
                GameTooltip:Show()
            end)

            _G["SocketKeystone.Affix"..frameIndex+i]:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            _G["SocketKeystone.Affix"..frameIndex+i]:Show()

            i = i + 1
        end
    end

    for i = (frameIndex + num + 1), 6 do
        _G["SocketKeystone.Affix"..i]:Hide()
    end
end

-------------------------------------------------------------------------------
--                                Functionality                              --
-------------------------------------------------------------------------------
function SocketKeystone:PlaceKeystone(itemLink, dungeonName, keyLevel, timeLimit, affixes, affixCount, dmgPct, healthPct)
    if not SocketKeystone:IsVisible() then 
        SocketKeystone:Show()
    end
    local name, itemlink, _, _, _, _, _, _, _, texture, _ = GetItemInfo(itemLink)

    SocketKeystone:PositionAffixes(2 + affixCount)
    SocketKeystone:ShowAffixes(affixes, affixCount, dmgPct, healthPct)

    SetPortraitToTexture(SocketKeystone.KeystoneSlot.Icon, texture)

    PlayInsertedAnim()

    PlaySound(UI_70_CHALLENGE_MODE_SOCKET_PAGE_SOCKET)

    SocketKeystone.StartButton:Enable()

    SocketKeystone.DungeonName:SetText(format("|cffFFD100%s|r", dungeonName))
    SocketKeystone.PowerLevel:SetText(format("|cffFFD100Niveau %s|r", keyLevel))
    SocketKeystone.TimeLimit:SetText(format("%d Minutes", timeLimit / 1000 / 60))
    SocketKeystone.DungeonName:Show()
    SocketKeystone.PowerLevel:Show()
    SocketKeystone.TimeLimit:Show()

    SocketKeystone.InstructionBackground:Hide()
    SocketKeystone.Instructions:Hide()
end

function SocketKeystone:ClearKeystone()
    SocketKeystone.KeystoneSlot.Icon:SetTexture(nil)
    SocketKeystone.StartButton:Disable()

    SocketKeystone.DungeonName:SetText("")
    SocketKeystone.PowerLevel:SetText("")
    SocketKeystone.TimeLimit:SetText("")
    SocketKeystone.DungeonName:Hide()
    SocketKeystone.PowerLevel:Hide()
    SocketKeystone.TimeLimit:Hide()
    for i = 1, 6 do
        _G["SocketKeystone.Affix"..i]:Hide()
    end

    ResetAnim()
    PlaySound(UI_70_CHALLENGE_MODE_SOCKET_PAGE_REMOVE_KEYSTONE)

    SocketKeystone.InstructionBackground:Show()
    SocketKeystone.Instructions:Show()

    ITEM_BAG_TEMP = nil
    ITEM_BAG_TEMP = nil
    ITEM_BAG_ACTIVE = nil
    ITEM_SLOT_ACTIVE = nil
    ITEM_ID_ACTIVE = nil
end
