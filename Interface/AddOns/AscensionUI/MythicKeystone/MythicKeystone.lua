local Addon = select(2, ...)
local MythicKeystone = CreateFrame("Frame")
Addon.MythicKeystone = MythicKeystone

MythicKeystone.CommPrefix = "ASC_MYTHIC_PLUS"

MythicKeystone.DamageMultiplier = 3
MythicKeystone.HealthMultiplier = 10

MythicKeystone.Show_Affix_Exclude = {
    ["Environmental Affix"] = true,
    ["Champion Affix"] = true
}

-- for displaying key names in compact frames
MythicKeystone.AbbreviatedKeys = {
    ["Profondeurs de Rochenoire - Prison"] = "BRD - Prison",
    ["Profondeurs de Rochenoire - Ville Haute"] = "BRD - Upper City",
    ["Hache-tripes - Est"] = "DM - East",
    ["Hache-tripes - Nord"] = "DM - North",
    ["Hache-tripes - Ouest"] = "DM - West",
    ["Pic Rochenoire - Bas"] = "LBRS",
    ["Stratholme - Porte Principale"] = "Strath - Main Gate",
    ["Stratholme - Entrée de Service"] = "Strath - Service",
    ["Évasion de Fort-de-Durn"] = "Old Hillsbrad",
    ["Pic Rochenoire - Haut"] = "UBRS",
}

local TIME_FORMAT_HOURS = "%01d:%02d:%02d"
local TIME_FORMAT = "%02d:%02d"

-- hook tooltips to show current affixes on the keystone itself
GameTooltip:HookScript("OnTooltipSetItem", function(self)
	local _, itemLink = self:GetItem()
	if not itemLink then return end

	local itemId = GetItemInfoFromHyperlink(itemLink)
	if not itemId then return end

	local keystone = Addon.KeystoneData[itemId]
	if not keystone then return end

    local affixData = Addon.AffixData[MythicKeystone.CDB.Week][keystone.mythicLevel] 
    if not affixData then return end
    
    local affixes = {}
    local text = {}
    tinsert(text, "|cFFFFFFFFModificateur de Donjon:|r")
    for _, id in ipairs(affixData.BossAffixes) do
        -- dont allow duplicates
        if not affixes[id] then
            local spellName, rank = GetSpellInfo(id)
            if spellName then
                if not MythicKeystone.Show_Affix_Exclude[rank] then
                    affixes[id] = true
                    tinsert(text, format("|cFF1EFF0C  %s|r", spellName))
                end
            end
        end
    end

    for _, id in ipairs(affixData.MinionAffixes) do
        -- dont allow duplicates 
        if not affixes[id] then
            local spellName, rank = GetSpellInfo(id)
            if spellName then
                if not MythicKeystone.Show_Affix_Exclude[rank] then
                    affixes[id] = true
                    tinsert(text, format("|cFF1EFF0C  %s|r", spellName))
                end
            end
        end
    end

    for _, id in ipairs(affixData.PlayerAffixes) do
        -- dont allow duplicates
        if not affixes[id] then
            local spellName, rank = GetSpellInfo(id)
            if spellName then
                if not MythicKeystone.Show_Affix_Exclude[rank] then
                    affixes[id] = true
                    tinsert(text, format("|cFF1EFF0C  %s|r", spellName))
                end
            end
        end
    end

    local num = #text
    local data = {}
    for i = 1, num do 
        data[i + 3] = text[i]
    end
    InsertTooltipMultipleLines(self, data, num)
end)

function MythicKeystone:GetAffixes(week, level)
    local affixes = {}
    local affixCount = 0
    local affixData = Addon.AffixData[week][level]
    
    if affixData then
        for _, id in ipairs(affixData.BossAffixes) do
            -- dont allow duplicates
            if not affixes[id] then
                local _, rank = GetSpellInfo(id)
                if not MythicKeystone.Show_Affix_Exclude[rank] then
                    affixes[id] = true
                    affixCount = affixCount + 1
                end
            end
        end

        for _, id in ipairs(affixData.MinionAffixes) do
            -- dont allow duplicates 
            if not affixes[id] then
                local _, rank = GetSpellInfo(id)
                if not MythicKeystone.Show_Affix_Exclude[rank] then
                    affixes[id] = true
                    affixCount = affixCount + 1
                end
            end
        end

        for _, id in ipairs(affixData.PlayerAffixes) do
            -- dont allow duplicates
            if not affixes[id] then
                local spellName, rank = GetSpellInfo(id)
                if spellName then
                    if not MythicKeystone.Show_Affix_Exclude[rank] then
                        affixes[id] = true
                        affixCount = affixCount + 1
                    end
                end
            end
        end
    end
    return affixes, affixCount
end

function MythicKeystone:GetCurrentKeystone()
    for bag = 0, NUM_BAG_SLOTS do 
        for slot = 1, GetContainerNumSlots(bag) do 
            local itemId = GetContainerItemID(bag, slot)
            if itemId ~= nil then
                local keystone = Addon.KeystoneData[itemId]
                if keystone then
                    return itemId, keystone
                end
            end
        end
    end
    return 0
end

function MythicKeystone:FormatTime(seconds)
    local hours = floor(seconds / 3600)
    local minutes = seconds / 60 % 60
    local seconds = seconds % 60
    local text = ""
    if hours > 0 then 
        text = format(TIME_FORMAT_HOURS, hours, minutes, seconds)
    else
        text = format(TIME_FORMAT, minutes, seconds)
    end

    return text
end

MythicKeystone:RegisterEvent("ADDON_LOADED")
MythicKeystone:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
        AscensionUI.CDB.MythicKeystone = AscensionUI.CDB.MythicKeystone or {}
        MythicKeystone.CDB = AscensionUI.CDB.MythicKeystone
        MythicKeystone.CDB.Week = GetCurrentMythicWeek()
    end
end)

--[[
local AtlasInfo = {
    ["Interface/Challenges/ChallengeModeRunes"] = {
        ["ChallengeMode-Runes-BackgroundCoverGlow"] = { 276, 275, 0.696289, 0.96582, 0.296875, 0.56543, false, false },
        ["ChallengeMode-Runes-GlowBurstLarge"] = { 234, 234, 0.501953, 0.730469, 0.696289, 0.924805, false, false },
        ["ChallengeMode-Runes-GlowSmall"] = { 261, 260, 0.000976562, 0.255859, 0.696289, 0.950195, false, false },
        ["ChallengeMode-RuneBG"] = { 710, 710, 0.000976562, 0.694336, 0.000976562, 0.694336, false, false },
        ["ChallengeMode-Runes-BackgroundBurst"] = { 300, 301, 0.696289, 0.989258, 0.000976562, 0.294922, false, false },
        ["ChallengeMode-Runes-BL-Glow"] = { 78, 78, 0.791992, 0.868164, 0.567383, 0.643555, false, false },
        ["ChallengeMode-Runes-BR-Glow"] = { 78, 78, 0.870117, 0.946289, 0.567383, 0.643555, false, false },
        ["ChallengeMode-Runes-InnerCircleGlow"] = { 211, 209, 0.732422, 0.938477, 0.696289, 0.900391, false, false },
        ["ChallengeMode-Runes-L-Glow"] = { 78, 78, 0.732422, 0.808594, 0.902344, 0.978516, false, false },
        ["ChallengeMode-Runes-R-Glow"] = { 78, 78, 0.810547, 0.886719, 0.902344, 0.978516, false, false },
        ["ChallengeMode-Runes-Small"] = { 248, 248, 0.257812, 0.5, 0.696289, 0.938477, false, false },
        ["ChallengeMode-Runes-T-Glow"] = { 78, 78, 0.888672, 0.964844, 0.902344, 0.978516, false, false },
        ["ChallengeMode-Runes-CircleGlow"] = { 96, 96, 0.696289, 0.790039, 0.567383, 0.661133, false, false },
    }, -- Interface/Challenges/ChallengeModeRunes
    ["Interface/Challenges/ChallengeMode"] =
    {
        ["ChallengeMode-AffixRing-Lg"] = { 52, 52, 0.912109, 0.962891, 0.0537109, 0.104492, false, false },
        ["ChallengeMode-AffixRing-Sm"] = { 34, 34, 0.964844, 0.998047, 0.000976562, 0.0341797, false, false },
        ["ChallengeMode-DungeonIconFrame"] = { 52, 52, 0.912109, 0.962891, 0.000976562, 0.0517578, false, false },
        ["ChallengeMode-KeystoneFrame"] = { 398, 548, 0.133789, 0.522461, 0.390625, 0.925781, false, false },
        ["ChallengeMode-KeystoneSlotBG"] = { 114, 114, 0.000976562, 0.112305, 0.760742, 0.87207, false, false },
        ["ChallengeMode-KeystoneSlotFrame"] = { 120, 120, 0.000976562, 0.118164, 0.641602, 0.758789, false, false },
        ["ChallengeMode-KeystoneSlotFrameGlow"] = { 120, 120, 0.000976562, 0.118164, 0.522461, 0.639648, false, false },
        ["ChallengeMode-MainTabBg"] = { 548, 397, 0.000976562, 0.536133, 0.000976562, 0.388672, false, false },
        ["ChallengeMode-ThinDivider"] = { 365, 3, 0.538086, 0.894531, 0.375, 0.37793, false, false },
        ["ChallengeMode-Runes-GlowLarge"] = { 392, 391, 0.524414, 0.907227, 0.615234, 0.99707, false, false },
        ["ChallengeMode-Runes-Large"] = { 381, 381, 0.538086, 0.910156, 0.000976562, 0.373047, false, false },
        ["ChallengeMode-Runes-LineGlow"] = { 242, 228, 0.524414, 0.760742, 0.390625, 0.613281, false, false },
        ["ChallengeMode-Runes-SmallCircleGlow"] = { 134, 133, 0.000976562, 0.131836, 0.390625, 0.520508, false, false },
        ["ChallengeMode-Runes-Shockwave"] = { 206, 209, 0.762695, 0.963867, 0.390625, 0.594727, false, false },
    }, -- Interface/Challenges/ChallengeMode
    ["Interface/Challenges/ChallengeModeHud"] = {
        ["challenges-timerborder"] = { 184, 23, 0.000976562, 0.180664, 0.802734, 0.847656, false, false },
        ["challenges-blackfade"] = { 333, 61, 0.387695, 0.712891, 0.431641, 0.550781, false, false },
        ["challenges-timerbg"] = { 243, 59, 0.714844, 0.952148, 0.431641, 0.546875, false, false },
        ["challenges-bannershine"] = { 222, 106, 0.387695, 0.604492, 0.220703, 0.427734, false, false },
        ["challenges-toast"] = { 311, 78, 0.633789, 0.9375, 0.00195312, 0.154297, false, false },
        ["challenges-nomedal"] = { 9, 10, 0.000976562, 0.00976562, 0.974609, 0.994141, false, false },
        ["BossBanner-PortraitBorder"] = { 61, 61, 0.000976562, 0.0605469, 0.851562, 0.970703, false, false },
        ["ChallengeMode-SoftYellowGlow"] = { 206, 206, 0.000976562, 0.202148, 0.00195312, 0.404297, false, false },
        ["ChallengeMode-SpikeyStar"] = { 200, 200, 0.000976562, 0.196289, 0.408203, 0.798828, false, false },
        ["ChallengeMode-Timer"] = { 261, 87, 0.606445, 0.861328, 0.220703, 0.390625, false, false },
        ["ChallengeMode-TimerBG"] = { 223, 11, 0.633789, 0.851562, 0.158203, 0.179688, false, false },
        ["ChallengeMode-TimerFill"] = { 223, 11, 0.606445, 0.824219, 0.394531, 0.416016, false, false },
        ["ChallengeMode-WhiteSpikeyGlow"] = { 186, 209, 0.204102, 0.385742, 0.00195312, 0.410156, false, false },
        ["ChallengeMode-Chest"] = { 175, 130, 0.204102, 0.375, 0.414062, 0.667969, false, false },
        ["ChallengeMode-icon-chest"] = { 19, 20, 0.182617, 0.201172, 0.802734, 0.841797, false, false },
        ["ChallengeMode-icon-redline"] = { 19, 19, 0.0625, 0.0810547, 0.851562, 0.888672, false, false },
        ["ChallengeMode-TimerBG-back"] = { 223, 11, 0.633789, 0.851562, 0.183594, 0.205078, false, false },
        ["ChallengeMode-guild-background"] = { 250, 110, 0.387695, 0.631836, 0.00195312, 0.216797, false, false },
        ["ChallengeMode-RankLineDivider"] = { 193, 9, 0.387695, 0.576172, 0.554688, 0.572266, false, false },
    }, -- Interface/Challenges/ChallengeModeHud
}
]]