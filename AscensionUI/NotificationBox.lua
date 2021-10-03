local Addon = select(2, ...)
Addon.NotificationBox = {}
local NB = Addon.NotificationBox

local tinsert = table.insert
local tremove = table.remove
local strlower = string.lower
local strmatch = string.match
local strfind = string.find
local strsub = string.sub

NB.notifQueue = {}

NB.NotificationSlots = {}
NB.ActiveNotifications = {}

NB.QUALITY_COLOR_STR =
{
    "|cFF889D9D",
    "|cFFFFFFFF",
    "|cFF1EFF0C",
    "|cFF0070FF",
    "|cFFA335EE",
    "|cFFFF8000",
    "|cFFE6CC80"
}

NB.ITEM_BORDER_TEXTURE =
{
    nil,
    nil,
    "Interface\\AddOns\\AwAddons\\Textures\\LootTex\\Loot_Icon_green",
    "Interface\\AddOns\\AwAddons\\Textures\\LootTex\\Loot_Icon_Blue",
    "Interface\\AddOns\\AwAddons\\Textures\\LootTex\\Loot_Icon_Purple",
    "Interface\\AddOns\\AwAddons\\Textures\\LootTex\\Loot_Icon_Leg",
    "Interface\\AddOns\\AwAddons\\Textures\\LootTex\\Loot_Icon_Gold"
}

NB.IGNORED_ITEM_ID = {
    383080, -- Ability Essence
    383081 -- Talent Essence
}

for i = 1, 6 do
    local f = CreateFrame("Frame", "NotificationBox"..i, UIParent)
    tinsert(NB.NotificationSlots, f)
    f:EnableMouse(true)
    f:SetPoint("BOTTOM", 0, 107+(90*(i-1)))
    f:SetSize(512, 128)
    f:Hide()
    f:SetScript("OnEnter", function(self)
        if self.AnimationGroup:IsPlaying() then
            self.AnimationGroup:Stop()
        end
    end)
    f:SetScript("OnLeave", function(self)
        if not self.AnimationGroup:IsPlaying() then
            self.AnimationGroup:Play()
        end
    end)
    f:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            self.AnimationGroup.Alpha:SetStartDelay(0)
            self.AnimationGroup.Alpha:SetDuration(0.25)
            self.AnimationGroup:Play()
        end
    end)

    f.AnimationGroup = f:CreateAnimationGroup()
    f.AnimationGroup.Parent = f
    f.AnimationGroup.Alpha = f.AnimationGroup:CreateAnimation("Alpha")
    f.AnimationGroup.Alpha:SetStartDelay(1)
    f.AnimationGroup.Alpha:SetDuration(2)
    f.AnimationGroup.Alpha:SetOrder(1)
    f.AnimationGroup.Alpha:SetEndDelay(0)
    f.AnimationGroup.Alpha:SetChange(-1)
    f.AnimationGroup:SetScript("OnFinished", function(self)
        self.Parent:Hide()
    end)

    f.LootFrame = CreateFrame("Frame", nil, f)
    f.LootFrame.Parent = f
    f.LootFrame:SetPoint("CENTER")
    f.LootFrame:SetSize(256, 70)

    f.LootFrame.BGTex = f.LootFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
    f.LootFrame.BGTex:SetWidth(512)
    f.LootFrame.BGTex:SetHeight(128)
    f.LootFrame.BGTex:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\LootTex\\Loot_BG_Normal")
    f.LootFrame.BGTex:SetPoint("CENTER")

    f.LootFrame.GoldBGTex = f.LootFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
    f.LootFrame.GoldBGTex:SetWidth(512)
    f.LootFrame.GoldBGTex:SetHeight(128)
    f.LootFrame.GoldBGTex:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\LootTex\\Loot_BG_Gold_Icon")
    f.LootFrame.GoldBGTex:SetPoint("CENTER")
    f.LootFrame.GoldBGTex:Hide()

    f.LootFrame.HighlightTex = f.LootFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
    f.LootFrame.HighlightTex:SetWidth(512)
    f.LootFrame.HighlightTex:SetHeight(128)
    f.LootFrame.HighlightTex:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\LootTex\\Loot_BG_HighLight")
    f.LootFrame.HighlightTex:SetPoint("CENTER")
    f.LootFrame.HighlightTex:SetBlendMode("ADD")

    f.LootFrame.Icon = f.LootFrame:CreateTexture(nil, "BORDER", nil, 0)
    f.LootFrame.Icon:SetWidth(50)
    f.LootFrame.Icon:SetHeight(50)
    f.LootFrame.Icon:SetTexture("Interface\\icons\\inv_custom_trainerBook")
    f.LootFrame.Icon:SetPoint("LEFT", 14, 0)

    f.LootFrame.IconBorder = f.LootFrame:CreateTexture(nil, "BORDER", nil, 1)
    f.LootFrame.IconBorder:SetWidth(62)
    f.LootFrame.IconBorder:SetHeight(62)
    f.LootFrame.IconBorder:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\LootTex\\Loot_Icon_green")
    f.LootFrame.IconBorder:SetPoint("LEFT", 7, 0)

    f.LootFrame.TitleText = f.LootFrame:CreateFontString(nil)
    f.LootFrame.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
    f.LootFrame.TitleText:SetFontObject(GameFontNormal)
    f.LootFrame.TitleText:SetPoint("TOP", 28, -9)
    f.LootFrame.TitleText:SetSize(164, 16)
    f.LootFrame.TitleText:SetShadowOffset(1, -1)
    f.LootFrame.TitleText:SetText("Nouvel objet obtenu!")
    f.LootFrame.TitleText:SetJustifyH("LEFT")
    f.LootFrame.TitleText:SetJustifyV("TOP")

    f.LootFrame.ItemText = f.LootFrame:CreateFontString(nil)
    f.LootFrame.ItemText:SetFont("Fonts\\FRIZQT__.TTF", 12)
    f.LootFrame.ItemText:SetFontObject(GameFontNormal)
    f.LootFrame.ItemText:CanWordWrap(true)
    f.LootFrame.ItemText:SetPoint("CENTER", 28, -7)
    f.LootFrame.ItemText:SetSize(164, 24)
    f.LootFrame.ItemText:SetShadowOffset(1, -1)
    f.LootFrame.ItemText:SetText("|cff1eff00Thunderfury Lame bénie du chercheur de vent")
    f.LootFrame.ItemText:SetJustifyH("LEFT")
    f.LootFrame.ItemText:SetJustifyV("CENTER")

    f.LootFrame.HighlightTex.AnimationGroup = f.LootFrame.HighlightTex:CreateAnimationGroup()
    f.LootFrame.HighlightTex.AnimationGroup.Parent = f.LootFrame
    f.LootFrame.HighlightTex.AnimationGroup.Alpha = f.LootFrame.HighlightTex.AnimationGroup:CreateAnimation("Alpha")
    f.LootFrame.HighlightTex.AnimationGroup.Alpha:SetStartDelay(0)
    f.LootFrame.HighlightTex.AnimationGroup.Alpha:SetDuration(1)
    f.LootFrame.HighlightTex.AnimationGroup.Alpha:SetEndDelay(0)
    f.LootFrame.HighlightTex.AnimationGroup.Alpha:SetOrder(1)
    f.LootFrame.HighlightTex.AnimationGroup.Alpha:SetChange(-1)

    f.LootFrame.HighlightTex.AnimationGroup:SetScript("OnFinished", function(self)
        self.Parent.HighlightTex:Hide()
        self.Parent.Parent.AnimationGroup:Play()
    end)

    f.Run = function(self, nameRef, title, itemText, icon, iconBorder, count, gold)
        if gold then
            self.LootFrame.GoldBGTex:Show()
            self.LootFrame.BGTex:Hide()
        else
            self.LootFrame.GoldBGTex:Hide()
            self.LootFrame.BGTex:Show()
        end

        self.name = nameRef
        self.itemText = itemText
        self.count = count

        self.LootFrame.TitleText:SetText(title)

        if self.count and self.count > 1 then
            itemText = itemText .. " |cffFFFFFFx" .. count .. "|r"
        end

        self.LootFrame.ItemText:SetText(itemText)
        self.LootFrame.Icon:SetTexture(icon)
        self.LootFrame.IconBorder:SetTexture(iconBorder)

        self:Show()
        self.LootFrame.HighlightTex:Show()
        self.AnimationGroup:Stop()
        self.LootFrame.HighlightTex.AnimationGroup:Stop()
        self.LootFrame.HighlightTex.AnimationGroup:Play()

        NB.ActiveNotifications[self.name] = self
    end

    f.UpdateCount = function(self)
        self.LootFrame.ItemText:SetText(self.itemText .. " |cffFFFFFFx" .. self.count .. "|r")
        self.LootFrame.HighlightTex:Show()
        self.AnimationGroup:Stop()
        self.LootFrame.HighlightTex.AnimationGroup:Stop()
        self.LootFrame.HighlightTex.AnimationGroup:Play()
    end

    f:SetScript("OnHide", function(self)
        NB.ActiveNotifications[self.name] = nil
        self.name = nil
        self.itemText = nil
        self.count = nil
    end)
end

-- init
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self)
    self.waitTime = GetTime() + 0.5 -- wait 0.5s before doing spell checks

    self:SetScript("OnUpdate", function(self)
        if self.waitTime < GetTime() then
            NB.DoSpellNotifications()
            self:SetScript("OnUpdate", nil)
        end
    end)

end)

f = CreateFrame("Frame")
f:RegisterEvent("ITEM_PUSH")
f:RegisterEvent("CHAT_MSG_LOOT")

f:SetScript("OnEvent", function(self, event, msg)
    if event == "ITEM_PUSH" then
        self.looted = true
    end

    if event == "CHAT_MSG_LOOT" then

        if not self.looted then
            if not strfind(msg, "^"..strsub(LOOT_ROLL_YOU_WON, 1, 7)) then
                return
            end
        end

        msg = strlower(msg)
        self.looted = false

        local itemID = strmatch(msg, "hitem:(%d+):")

        if not itemID or not tonumber(itemID) then
            return
        end

        local count = strmatch(msg, "(%d+).$")

        if not count then
            count = 1
        else
            count = tonumber(count)
        end

        for _, ignored in ipairs(NB.IGNORED_ITEM_ID) do
            if tonumber(itemID) == tonumber(ignored) then
                return
            end
        end

        local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)

        if itemName == nil then return end -- cache issue, skip item

        if itemQuality < 3 then return end -- only show blue+ drops

        local notif = {
            name = itemName,
            title = "Vous avez obtenu!",
            itemText = NB.QUALITY_COLOR_STR[min(itemQuality + 1, 7)] .. itemName .. "|r",
            itemTextRaw = NB.QUALITY_COLOR_STR[min(itemQuality + 1, 7)] .. itemName .. "|r",
            icon = itemTexture,
            iconBorder = NB.ITEM_BORDER_TEXTURE[min(itemQuality + 1, 7)],
            count = count
        }

        tinsert(NB.notifQueue, notif)
    end
end)

f:SetScript("OnUpdate", function(self, dt)
    if #NB.notifQueue == 0 then return end

    local notif = NB.notifQueue[1]

    if NB.ActiveNotifications[notif.name] ~= nil then
        local frame = NB.ActiveNotifications[notif.name]
        if not notif.isSpell then
            frame.count = frame.count + notif.count
            frame:UpdateCount()
        end
        tremove(NB.notifQueue, 1)
    end

    for _, slot in ipairs(NB.NotificationSlots) do

        if NB.ActiveNotifications[notif.name] ~= nil then
            return
        end

        if not slot:IsVisible() then
            local notif = tremove(NB.notifQueue, 1)
            if not notif then return end
            slot:Run(notif.name, notif.title, notif.itemText, notif.icon, notif.iconBorder, notif.count, notif.gold)
            return
        end
    end
end)

function NB.DoSpellNotifications()
    local curLevel = UnitLevel("Player")

    -- add criminal intent notification
    if curLevel == 20 then
        if IsSpellKnown(9930872) then
            local spellName, _, spellIcon = GetSpellInfo(9930872)
            local notif = {
                name = spellName,
                title = "Fonctionnalité déverrouillée",
                itemText = spellName,
                icon = spellIcon,
                iconBorder = "Interface\\AddOns\\AwAddons\\Textures\\LootTex\\Loot_Icon_Gold",
                gold = true,
                isSpell = true
            }
            tinsert(NB.notifQueue, notif)
        end
    end

    for _, spellData in ipairs(NB.Spell_Rank_Data) do
        local data = {}
        data.currentSpellID = spellData[1]
        data.targetSpellID = spellData[2]
        data.targetSpellRank = spellData[3]
        data.targetReqLevel = spellData[4]

        if data.targetReqLevel <= curLevel then
            if IsSpellKnown(data.currentSpellID) and not IsSpellKnown(data.targetSpellID) then
                local spellName, _, spellIcon = GetSpellInfo(data.currentSpellID)

                local notif = {
                    name = spellName,
                    title = "Amélioration disponible",
                    itemText = spellName .. " est prêt à être amélioré.",
                    icon = spellIcon,
                    iconBorder = "Interface\\AddOns\\AwAddons\\Textures\\LootTex\\Loot_Icon_Gold",
                    gold = true,
                    isSpell = true
                }

                tinsert(NB.notifQueue, notif)
            end
        end
    end
end

NB.Spell_Rank_Data = {
    { 10, 10, 1, 20 },
    { 17, 17, 1, 6 },
    { 53, 53, 1, 4 },
    { 67, 67, 1, 1 },
    { 78, 78, 1, 1 },
    { 99, 99, 1, 10 },
    { 100, 100, 1, 4 },
    { 116, 116, 1, 4 },
    { 118, 118, 1, 8 },
    { 120, 120, 1, 26 },
    { 122, 122, 1, 10 },
    { 133, 133, 1, 1 },
    { 136, 136, 1, 12 },
    { 139, 139, 1, 8 },
    { 133, 143, 2, 6 },
    { 133, 145, 3, 12 },
    { 168, 168, 1, 1 },
    { 172, 172, 1, 4 },
    { 116, 205, 2, 8 },
    { 78, 284, 2, 8 },
    { 78, 285, 3, 16 },
    { 324, 324, 1, 8 },
    { 324, 325, 2, 16 },
    { 331, 331, 1, 1 },
    { 331, 332, 2, 6 },
    { 339, 339, 1, 8 },
    { 348, 348, 1, 1 },
    { 370, 370, 1, 12 },
    { 403, 403, 1, 1 },
    { 421, 421, 1, 32 },
    { 465, 465, 1, 1 },
    { 467, 467, 1, 6 },
    { 469, 469, 1, 68 },
    { 491, 491, 1, 18 },
    { 527, 527, 1, 18 },
    { 403, 529, 2, 8 },
    { 543, 543, 1, 20 },
    { 331, 547, 3, 12 },
    { 403, 548, 3, 14 },
    { 585, 585, 1, 1 },
    { 587, 587, 1, 6 },
    { 588, 588, 1, 12 },
    { 589, 589, 1, 4 },
    { 585, 591, 2, 6 },
    { 17, 592, 2, 12 },
    { 589, 594, 2, 10 },
    { 596, 596, 1, 30 },
    { 587, 597, 2, 12 },
    { 585, 598, 3, 14 },
    { 17, 600, 3, 18 },
    { 588, 602, 3, 30 },
    { 603, 603, 1, 60 },
    { 633, 633, 1, 10 },
    { 635, 635, 1, 1 },
    { 635, 639, 2, 6 },
    { 465, 643, 3, 20 },
    { 635, 647, 3, 14 },
    { 686, 686, 1, 1 },
    { 687, 687, 1, 1 },
    { 689, 689, 1, 14 },
    { 693, 693, 1, 18 },
    { 686, 695, 2, 6 },
    { 687, 696, 2, 10 },
    { 689, 699, 2, 22 },
    { 700, 700, 1, 8 },
    { 702, 702, 1, 4 },
    { 703, 703, 1, 14 },
    { 686, 705, 3, 12 },
    { 687, 706, 3, 20 },
    { 348, 707, 2, 10 },
    { 689, 709, 3, 30 },
    { 710, 710, 1, 28 },
    { 724, 724, 1, 40 },
    { 740, 740, 1, 30 },
    { 746, 746, 1, 0 },
    { 755, 755, 1, 12 },
    { 759, 759, 1, 28 },
    { 779, 769, 3, 34 },
    { 772, 772, 1, 4 },
    { 774, 774, 1, 4 },
    { 779, 779, 1, 16 },
    { 779, 780, 2, 24 },
    { 467, 782, 2, 14 },
    { 116, 837, 3, 14 },
    { 845, 845, 1, 20 },
    { 491, 857, 2, 30 },
    { 122, 865, 2, 26 },
    { 879, 879, 1, 20 },
    { 324, 905, 3, 24 },
    { 331, 913, 4, 18 },
    { 403, 915, 4, 20 },
    { 421, 930, 2, 40 },
    { 331, 939, 5, 24 },
    { 403, 943, 5, 26 },
    { 324, 945, 4, 32 },
    { 331, 959, 6, 32 },
    { 589, 970, 3, 18 },
    { 974, 974, 1, 50 },
    { 976, 976, 1, 30 },
    { 980, 980, 1, 8 },
    { 585, 984, 4, 22 },
    { 527, 988, 2, 36 },
    { 587, 990, 3, 22 },
    { 589, 992, 4, 26 },
    { 596, 996, 2, 40 },
    { 585, 1004, 5, 30 },
    { 588, 1006, 4, 40 },
    { 980, 1014, 2, 18 },
    { 1022, 1022, 1, 10 },
    { 635, 1026, 4, 22 },
    { 465, 1032, 5, 40 },
    { 635, 1042, 5, 30 },
    { 774, 1058, 2, 10 },
    { 339, 1062, 2, 18 },
    { 1064, 1064, 1, 40 },
    { 467, 1075, 3, 24 },
    { 1079, 1079, 1, 20 },
    { 1082, 1082, 1, 20 },
    { 687, 1086, 4, 30 },
    { 686, 1088, 4, 20 },
    { 700, 1090, 2, 20 },
    { 348, 1094, 3, 20 },
    { 1098, 1098, 1, 30 },
    { 686, 1106, 5, 28 },
    { 702, 1108, 2, 12 },
    { 1120, 1120, 1, 10 },
    { 1126, 1126, 1, 1 },
    { 1130, 1130, 1, 6 },
    { 746, 1159, 2, 0 },
    { 1160, 1160, 1, 14 },
    { 1243, 1243, 1, 1 },
    { 1243, 1244, 2, 12 },
    { 1243, 1245, 3, 24 },
    { 1329, 1329, 1, 40 },
    { 774, 1430, 3, 16 },
    { 1449, 1449, 1, 14 },
    { 1459, 1459, 1, 1 },
    { 1459, 1460, 2, 14 },
    { 1459, 1461, 3, 28 },
    { 1463, 1463, 1, 20 },
    { 1464, 1464, 1, 30 },
    { 1490, 1490, 1, 32 },
    { 1495, 1495, 1, 16 },
    { 1499, 1499, 1, 20 },
    { 1510, 1510, 1, 40 },
    { 1513, 1513, 1, 14 },
    { 1535, 1535, 1, 12 },
    { 78, 1608, 4, 24 },
    { 99, 1735, 2, 20 },
    { 1752, 1752, 1, 1 },
    { 1752, 1757, 2, 6 },
    { 1752, 1758, 3, 14 },
    { 1752, 1759, 4, 22 },
    { 1752, 1760, 5, 30 },
    { 1822, 1822, 1, 24 },
    { 1822, 1823, 2, 34 },
    { 1822, 1824, 3, 44 },
    { 1850, 1850, 1, 26 },
    { 1856, 1856, 1, 22 },
    { 1856, 1857, 2, 42 },
    { 1943, 1943, 1, 20 },
    { 1949, 1949, 1, 30 },
    { 1966, 1966, 1, 16 },
    { 1978, 1978, 1, 4 },
    { 2006, 2006, 1, 10 },
    { 2008, 2008, 1, 12 },
    { 2006, 2010, 2, 22 },
    { 6673, 2048, 8, 69 },
    { 2050, 2050, 1, 1 },
    { 2050, 2052, 2, 4 },
    { 2050, 2053, 3, 10 },
    { 2050, 2054, 4, 16 },
    { 2050, 2055, 5, 22 },
    { 2050, 2060, 8, 40 },
    { 2061, 2061, 1, 20 },
    { 6770, 2070, 2, 28 },
    { 774, 2090, 4, 22 },
    { 774, 2091, 5, 28 },
    { 2096, 2096, 1, 22 },
    { 2098, 2098, 1, 1 },
    { 2120, 2120, 1, 16 },
    { 2120, 2121, 2, 24 },
    { 2136, 2136, 1, 6 },
    { 2136, 2137, 2, 14 },
    { 2136, 2138, 3, 22 },
    { 2362, 2362, 1, 36 },
    { 53, 2589, 2, 12 },
    { 53, 2590, 3, 20 },
    { 53, 2591, 4, 28 },
    { 2637, 2637, 1, 18 },
    { 2643, 2643, 1, 18 },
    { 2649, 2649, 1, 1 },
    { 589, 2767, 5, 34 },
    { 1243, 2791, 4, 36 },
    { 633, 2800, 2, 30 },
    { 2812, 2812, 1, 50 },
    { 2818, 2818, 1, 30 },
    { 2818, 2819, 2, 38 },
    { 2823, 2823, 1, 30 },
    { 2823, 2824, 2, 38 },
    { 421, 2860, 3, 48 },
    { 2908, 2908, 1, 22 },
    { 2912, 2912, 1, 20 },
    { 348, 2941, 4, 30 },
    { 2944, 2944, 1, 20 },
    { 2947, 2947, 1, 14 },
    { 2948, 2948, 1, 22 },
    { 2973, 2973, 1, 1 },
    { 2983, 2983, 1, 10 },
    { 16827, 3009, 8, 56 },
    { 16827, 3010, 7, 48 },
    { 1082, 3029, 2, 28 },
    { 3044, 3044, 1, 6 },
    { 3110, 3110, 1, 1 },
    { 136, 3111, 2, 20 },
    { 133, 3140, 4, 18 },
    { 746, 3267, 3, 0 },
    { 746, 3268, 4, 0 },
    { 3355, 3355, 1, 20 },
    { 635, 3472, 6, 38 },
    { 759, 3552, 2, 38 },
    { 3599, 3599, 1, 10 },
    { 3606, 3606, 1, 10 },
    { 774, 3627, 6, 34 },
    { 136, 3661, 3, 28 },
    { 136, 3662, 4, 36 },
    { 3674, 3674, 1, 50 },
    { 755, 3698, 2, 20 },
    { 755, 3699, 3, 28 },
    { 755, 3700, 4, 36 },
    { 3716, 3716, 1, 10 },
    { 17, 3747, 4, 24 },
    { 5143, 5143, 1, 8 },
    { 5143, 5144, 2, 16 },
    { 5143, 5145, 3, 24 },
    { 5171, 5171, 1, 10 },
    { 5176, 5176, 1, 1 },
    { 5176, 5177, 2, 6 },
    { 5176, 5178, 3, 14 },
    { 5176, 5179, 4, 22 },
    { 5176, 5180, 5, 30 },
    { 5185, 5185, 1, 1 },
    { 5185, 5186, 2, 8 },
    { 5185, 5187, 3, 14 },
    { 5185, 5188, 4, 20 },
    { 5185, 5189, 5, 26 },
    { 339, 5195, 3, 28 },
    { 339, 5196, 4, 38 },
    { 1082, 5201, 3, 38 },
    { 5211, 5211, 1, 14 },
    { 5217, 5217, 1, 24 },
    { 5221, 5221, 1, 22 },
    { 1126, 5232, 2, 10 },
    { 1126, 5234, 4, 30 },
    { 6673, 5242, 2, 12 },
    { 5277, 5277, 1, 8 },
    { 5308, 5308, 1, 24 },
    { 5374, 5374, 1, 1 },
    { 5394, 5394, 1, 20 },
    { 5405, 5405, 1, 28 },
    { 5484, 5484, 1, 40 },
    { 5487, 5487, 1, 10 },
    { 5504, 5504, 1, 0 },
    { 5504, 5505, 2, 10 },
    { 5504, 5506, 3, 20 },
    { 5570, 5570, 1, 20 },
    { 1022, 5599, 2, 24 },
    { 879, 5614, 2, 28 },
    { 879, 5615, 3, 36 },
    { 5675, 5675, 1, 26 },
    { 5676, 5676, 1, 18 },
    { 6201, 5699, 3, 34 },
    { 5730, 5730, 1, 8 },
    { 5740, 5740, 1, 20 },
    { 5782, 5782, 1, 8 },
    { 5857, 5857, 1, 30 },
    { 403, 6041, 6, 32 },
    { 585, 6060, 6, 38 },
    { 2050, 6063, 6, 28 },
    { 2050, 6064, 7, 34 },
    { 17, 6065, 5, 30 },
    { 17, 6066, 6, 36 },
    { 139, 6074, 2, 14 },
    { 139, 6075, 3, 20 },
    { 139, 6076, 4, 26 },
    { 139, 6077, 5, 32 },
    { 139, 6078, 6, 38 },
    { 5504, 6127, 4, 30 },
    { 587, 6129, 4, 32 },
    { 122, 6131, 3, 40 },
    { 10, 6141, 2, 28 },
    { 6143, 6143, 1, 22 },
    { 100, 6178, 2, 26 },
    { 1160, 6190, 2, 24 },
    { 6673, 6192, 3, 22 },
    { 6201, 6201, 1, 10 },
    { 6201, 6202, 2, 22 },
    { 702, 6205, 3, 22 },
    { 5782, 6213, 2, 32 },
    { 5782, 6215, 3, 56 },
    { 980, 6217, 3, 28 },
    { 5740, 6219, 2, 34 },
    { 172, 6222, 2, 14 },
    { 172, 6223, 3, 24 },
    { 6229, 6229, 1, 32 },
    { 6307, 6307, 1, 4 },
    { 6343, 6343, 1, 6 },
    { 3606, 6350, 2, 20 },
    { 3606, 6351, 3, 30 },
    { 3606, 6352, 4, 40 },
    { 6353, 6353, 1, 48 },
    { 6360, 6360, 1, 22 },
    { 3599, 6363, 2, 20 },
    { 3599, 6364, 3, 30 },
    { 3599, 6365, 4, 40 },
    { 6366, 6366, 1, 28 },
    { 5394, 6375, 2, 30 },
    { 5394, 6377, 3, 40 },
    { 5730, 6390, 2, 18 },
    { 5730, 6391, 3, 28 },
    { 5730, 6392, 4, 38 },
    { 772, 6546, 2, 10 },
    { 772, 6547, 3, 20 },
    { 772, 6548, 4, 30 },
    { 13491, 6554, 2, 58 },
    { 13491, 6555, 3, 99 },
    { 6572, 6572, 1, 14 },
    { 6572, 6574, 2, 24 },
    { 6673, 6673, 1, 1 },
    { 1126, 6756, 3, 20 },
    { 2098, 6760, 2, 8 },
    { 2098, 6761, 3, 16 },
    { 2098, 6762, 4, 24 },
    { 1966, 6768, 2, 28 },
    { 6770, 6770, 1, 10 },
    { 5171, 6774, 2, 42 },
    { 5185, 6778, 6, 32 },
    { 5176, 6780, 6, 38 },
    { 6785, 6785, 1, 32 },
    { 6785, 6787, 2, 42 },
    { 6789, 6789, 1, 42 },
    { 5217, 6793, 2, 36 },
    { 5211, 6798, 2, 30 },
    { 5221, 6800, 2, 30 },
    { 6807, 6807, 1, 10 },
    { 6807, 6808, 2, 18 },
    { 6807, 6809, 3, 26 },
    { 7001, 7001, 1, 40 },
    { 588, 7128, 2, 20 },
    { 7268, 7268, 1, 8 },
    { 7268, 7269, 2, 16 },
    { 7268, 7270, 3, 24 },
    { 7294, 7294, 1, 16 },
    { 168, 7300, 2, 10 },
    { 168, 7301, 3, 20 },
    { 168, 7302, 4, 30 },
    { 168, 7320, 5, 40 },
    { 116, 7322, 4, 20 },
    { 845, 7369, 2, 30 },
    { 6572, 7379, 3, 34 },
    { 686, 7641, 6, 36 },
    { 702, 7646, 4, 32 },
    { 172, 7648, 4, 34 },
    { 689, 7651, 4, 38 },
    { 3110, 7799, 2, 8 },
    { 3110, 7800, 3, 18 },
    { 3110, 7801, 4, 28 },
    { 3110, 7802, 5, 38 },
    { 6307, 7804, 2, 14 },
    { 6307, 7805, 3, 26 },
    { 3716, 7809, 2, 20 },
    { 3716, 7810, 3, 30 },
    { 3716, 7811, 4, 40 },
    { 7812, 7812, 1, 16 },
    { 6360, 7813, 2, 34 },
    { 7814, 7814, 1, 20 },
    { 7814, 7815, 2, 28 },
    { 7814, 7816, 3, 36 },
    { 746, 7926, 5, 0 },
    { 746, 7927, 6, 0 },
    { 8004, 8004, 1, 20 },
    { 331, 8005, 7, 40 },
    { 8004, 8008, 2, 28 },
    { 8004, 8010, 3, 36 },
    { 370, 8012, 2, 32 },
    { 8017, 8017, 1, 10 },
    { 8017, 8018, 2, 22 },
    { 8017, 8019, 3, 34 },
    { 8024, 8024, 1, 10 },
    { 8026, 8026, 1, 10 },
    { 8024, 8027, 2, 18 },
    { 8026, 8028, 2, 18 },
    { 8026, 8029, 3, 26 },
    { 8024, 8030, 3, 26 },
    { 8033, 8033, 1, 20 },
    { 8034, 8034, 1, 20 },
    { 8034, 8037, 2, 28 },
    { 8033, 8038, 2, 28 },
    { 8042, 8042, 1, 4 },
    { 8042, 8044, 2, 8 },
    { 8042, 8045, 3, 14 },
    { 8042, 8046, 4, 24 },
    { 8050, 8050, 1, 10 },
    { 8050, 8052, 2, 18 },
    { 8050, 8053, 3, 28 },
    { 8056, 8056, 1, 20 },
    { 8056, 8058, 2, 34 },
    { 8071, 8071, 1, 4 },
    { 8075, 8075, 1, 10 },
    { 8092, 8092, 1, 10 },
    { 8092, 8102, 2, 16 },
    { 8092, 8103, 3, 22 },
    { 8092, 8104, 4, 28 },
    { 8092, 8105, 5, 34 },
    { 8092, 8106, 6, 40 },
    { 8122, 8122, 1, 14 },
    { 8122, 8124, 2, 28 },
    { 324, 8134, 5, 40 },
    { 8071, 8154, 2, 14 },
    { 8071, 8155, 3, 24 },
    { 8075, 8160, 2, 24 },
    { 8075, 8161, 3, 38 },
    { 8181, 8181, 1, 24 },
    { 8184, 8184, 1, 28 },
    { 8187, 8187, 1, 26 },
    { 8190, 8190, 1, 26 },
    { 6343, 8198, 2, 18 },
    { 6343, 8204, 3, 28 },
    { 6343, 8205, 4, 38 },
    { 8227, 8227, 1, 28 },
    { 8232, 8232, 1, 30 },
    { 8232, 8235, 2, 40 },
    { 8227, 8249, 2, 38 },
    { 1120, 8288, 2, 24 },
    { 1120, 8289, 3, 38 },
    { 2947, 8316, 2, 24 },
    { 2947, 8317, 3, 34 },
    { 8349, 8349, 1, 12 },
    { 133, 8400, 5, 24 },
    { 133, 8401, 6, 30 },
    { 133, 8402, 7, 36 },
    { 116, 8406, 5, 26 },
    { 116, 8407, 6, 32 },
    { 116, 8408, 7, 38 },
    { 2136, 8412, 4, 30 },
    { 2136, 8413, 5, 38 },
    { 5143, 8416, 4, 32 },
    { 5143, 8417, 5, 40 },
    { 7268, 8418, 5, 40 },
    { 7268, 8419, 4, 32 },
    { 2120, 8422, 3, 32 },
    { 2120, 8423, 4, 40 },
    { 10, 8427, 3, 36 },
    { 1449, 8437, 2, 22 },
    { 1449, 8438, 3, 30 },
    { 1449, 8439, 4, 38 },
    { 2948, 8444, 2, 28 },
    { 2948, 8445, 3, 34 },
    { 2948, 8446, 4, 40 },
    { 543, 8457, 2, 30 },
    { 543, 8458, 3, 40 },
    { 6143, 8461, 2, 32 },
    { 6143, 8462, 3, 42 },
    { 120, 8492, 2, 34 },
    { 1463, 8494, 2, 28 },
    { 1463, 8495, 3, 36 },
    { 1535, 8498, 2, 22 },
    { 1535, 8499, 3, 32 },
    { 8349, 8502, 2, 22 },
    { 8349, 8503, 3, 32 },
    { 1752, 8621, 6, 38 },
    { 2098, 8623, 5, 32 },
    { 2098, 8624, 6, 40 },
    { 703, 8631, 2, 22 },
    { 703, 8632, 3, 30 },
    { 703, 8633, 4, 38 },
    { 1966, 8637, 3, 40 },
    { 1943, 8639, 2, 28 },
    { 1943, 8640, 3, 36 },
    { 8676, 8676, 1, 18 },
    { 8679, 8679, 1, 20 },
    { 8680, 8680, 1, 20 },
    { 8680, 8685, 2, 28 },
    { 8679, 8686, 2, 28 },
    { 8679, 8688, 3, 36 },
    { 8680, 8689, 3, 36 },
    { 2983, 8696, 2, 34 },
    { 53, 8721, 5, 36 },
    { 8676, 8724, 2, 26 },
    { 8676, 8725, 3, 34 },
    { 1464, 8820, 2, 38 },
    { 5185, 8903, 7, 38 },
    { 5176, 8905, 7, 46 },
    { 1126, 8907, 5, 40 },
    { 774, 8910, 7, 40 },
    { 467, 8914, 4, 34 },
    { 740, 8918, 2, 40 },
    { 8921, 8921, 1, 4 },
    { 8921, 8924, 2, 10 },
    { 8921, 8925, 3, 16 }
}