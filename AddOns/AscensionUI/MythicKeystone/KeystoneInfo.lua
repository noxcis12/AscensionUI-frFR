local Addon = select(2, ...)
local MythicKeystone = Addon.MythicKeystone

local KeystoneInfo = CreateFrame("Frame", "AscensionUI.MythicKeystone.KeystoneInfo", UIParent, "UIPanelDialogTemplate")
tinsert(UISpecialFrames, KeystoneInfo:GetName())

MythicKeystone.KeystoneInfo = KeystoneInfo

local level = UnitLevel("player")

local COMM_SEND_MY_KEY = "SendMyKeystone"
local COMM_REQUEST_KEYS = "RequestKeystones"

local BestFrames = {}
local PartyKeystones = {}
local CurrentKeystone = nil

local BC_Dungeon_Info = {
    ["The Black Morass"] = { -- The Black Morass
        texture = "Interface\\LFGFRAME\\LFGICON-CAVERNSOFTIME",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-CAVERNSOFTIME",
        name = "The Black Morass",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Shattered Halls"] = { -- Shattered Halls
        texture = "Interface\\LFGFRAME\\LFGICON-HELLFIRECITADEL",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-HELLFIRECITADEL",
        name = "Shattered Halls",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Shadow Labyrinth"] = { -- Shadow Labyrinth
        texture = "Interface\\LFGFRAME\\LFGICON-AUCHINDOUN",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-AUCHINDOUN",
        name = "Shadow Labyrinth",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["The Mechanar"] = { -- The Mechanar
        texture = "Interface\\LFGFRAME\\LFGICON-TEMPESTKEEP",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-TEMPESTKEEP",
        name = "The Mechanar",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["The Steamvault"] = { -- The Steamvault
        texture = "Interface\\LFGFRAME\\LFGICON-COILFANG",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-COILFANG",
        name = "The Steamvault",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Hellfire Ramparts"] = { -- Hellfire Ramparts 
        texture = "Interface\\LFGFRAME\\LFGICON-HELLFIRECITADEL",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-HELLFIRECITADEL",
        name = "Hellfire Ramparts",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Auchenai Crypts"] = { -- Auchenai Crypts
        texture = "Interface\\LFGFRAME\\LFGICON-AUCHINDOUN",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-AUCHINDOUN",
        name = "Auchenai Crypts",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Underbog"] = { -- Underbog
        texture = "Interface\\LFGFRAME\\LFGICON-COILFANG",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-COILFANG",
        name = "Underbog",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["The Botanica"] = { -- The Botanica
        texture = "Interface\\LFGFRAME\\LFGICON-TEMPESTKEEP",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-TEMPESTKEEP",
        name = "The Botanica",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Sethekk Halls"] = { -- Sethekk Halls
        texture = "Interface\\LFGFRAME\\LFGICON-AUCHINDOUN",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-AUCHINDOUN",
        name = "Sethekk Halls",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Blood Furnace"] = { -- Blood Furnace
        texture = "Interface\\LFGFRAME\\LFGICON-HELLFIRECITADEL",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-HELLFIRECITADEL",
        name = "Blood Furnace",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Slave Pens"] = { -- Slave Pens
        texture = "Interface\\LFGFRAME\\LFGICON-COILFANG",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-COILFANG",
        name = "Slave Pens",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["The Arcatraz"] = { -- The Arcatraz
        texture = "Interface\\LFGFRAME\\LFGICON-TEMPESTKEEP",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-TEMPESTKEEP",
        name = "The Arcatraz",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Mana Tombs"] = { -- Mana Tombs
        texture = "Interface\\LFGFRAME\\LFGICON-AUCHINDOUN",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-AUCHINDOUN",
        name = "Mana Tombs",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["The Escape from Durnholde"] = { -- The Escape from Durnholde
        texture = "Interface\\LFGFRAME\\LFGICON-CAVERNSOFTIME",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-CAVERNSOFTIME",
        name = "The Escape from Durnholde",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
}

local Classic_Dungeon_Info = {
    ["Profondeurs de Rochenoire - Prison"] = { -- Blackrock Depths - Prison
        texture = "Interface\\LFGFRAME\\LFGICON-BLACKROCKDEPTHS",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-BLACKROCKDEPTHS",
        name = "Profondeurs de Rochenoire - Prison",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Pic Rochenoire - Bas"] = { -- Lower Blackrock Spire
        texture = "Interface\\LFGFRAME\\LFGICON-BLACKROCKSPIRE",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-BLACKROCKSPIRE",
        name = "Pic Rochenoire - Bas",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Scholomance"] = { -- Scholomance
        texture = "Interface\\LFGFRAME\\LFGICON-SCHOLOMANCE",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-SCHOLOMANCE",
        name = "Scholomance",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Stratholme - Porte Principale"] = { -- Stratholme - Main Gate
        texture = "Interface\\LFGFRAME\\LFGICON-STRATHOLME",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-STRATHOLME",
        name = "Stratholme - Porte Principale",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Hache-tripes - Est"] = { -- Dire Maul - East
        texture = "Interface\\LFGFRAME\\LFGICON-DIREMAUL",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-DIREMAUL",
        name = "Hache-tripes - Est",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Pic Rochenoire - Haut"] = { -- Upper Blackrock Spire
        texture = "Interface\\LFGFRAME\\LFGICON-BLACKROCKSPIRE",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-BLACKROCKSPIRE",
        name = "Pic Rochenoire - Haut",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Hache-tripes - Ouest"] = { -- Dire Maul - West
        texture = "Interface\\LFGFRAME\\LFGICON-DIREMAUL",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-DIREMAUL",
        name = "Hache-tripes - Ouest",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Profondeurs de Rochenoire - Ville Haute"] = { -- Blackrock Depths - Upper City
        texture = "Interface\\LFGFRAME\\LFGICON-BLACKROCKDEPTHS",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-BLACKROCKDEPTHS",
        name = "Profondeurs de Rochenoire - Ville Haute",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Stratholme - Entrée de Service"] = { -- Stratholme - Service Entrance
        texture = "Interface\\LFGFRAME\\LFGICON-STRATHOLME",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-STRATHOLME",
        name = "Stratholme - Entrée de Service",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
    ["Hache-tripes - Nord"] = { -- Dire Maul - North
        texture = "Interface\\LFGFRAME\\LFGICON-DIREMAUL",
        bg = "Interface\\LFGFRAME\\UI-LFG-BACKGROUND-DIREMAUL",
        name = "Hache-tripes - Nord",
        best = 0,
        timed = false,
        totalTime = 0,
        timestamp = 0
    },
}

KeystoneInfo:SetSize(784, 512)
KeystoneInfo:SetPoint("CENTER", UIParent)
KeystoneInfo:SetMovable(true)
KeystoneInfo:EnableMouse(true)
KeystoneInfo:RegisterForDrag("LeftButton")
KeystoneInfo:SetScript("OnDragStart", KeystoneInfo.StartMoving)
KeystoneInfo:SetScript("OnDragStop", KeystoneInfo.StopMovingOrSizing)
KeystoneInfo:Hide()

CreateTabs(KeystoneInfo)

KeystoneInfo.Title = KeystoneInfo:CreateFontString(nil, "ARTWORK")
KeystoneInfo.Title:SetPoint("TOP", -1, -8)
KeystoneInfo.Title:SetFontObject(GameFontNormal)
KeystoneInfo.Title:SetText("Donjons Mythique")


KeystoneInfo.WeeklyInfo = CreateFrame("ScrollFrame", "AscensionUI.MythicKeystone.KeystoneInfo.WeeklyInfo", KeystoneInfo)
KeystoneInfo.WeeklyInfo:SetSize(766, 475)
KeystoneInfo.WeeklyInfo:SetPoint("TOP", 0, -26)

KeystoneInfo.WeeklyInfo.BG = KeystoneInfo.WeeklyInfo:CreateTexture(nil, "BACKGROUND")
KeystoneInfo.WeeklyInfo.BG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
KeystoneInfo.WeeklyInfo.BG:SetAllPoints()
KeystoneInfo.WeeklyInfo.BG:SetSize(766, 475)
KeystoneInfo.WeeklyInfo.BG:SetTexCoord(0.000976562, 0.536133, 0.000976562, 0.388672)

KeystoneInfo.WeeklyInfo.BG2 = KeystoneInfo.WeeklyInfo:CreateTexture(nil, "BACKGROUND")
KeystoneInfo.WeeklyInfo.BG2:SetAllPoints()
KeystoneInfo.WeeklyInfo.BG2:SetSize(766, 475)
KeystoneInfo.WeeklyInfo.BG2:SetAlpha(0.5)
KeystoneInfo.WeeklyInfo.BG2:SetBlendMode("ADD")
KeystoneInfo.WeeklyInfo.BG2:Hide()

KeystoneInfo.WeeklyInfo.Child = CreateFrame("Frame")
KeystoneInfo.WeeklyInfo.Child:SetSize(766, 475)

KeystoneInfo.WeeklyInfo:SetScrollChild(KeystoneInfo.WeeklyInfo.Child)

KeystoneInfo.WeeklyInfo.Child.TextThisWeek = KeystoneInfo.WeeklyInfo.Child:CreateFontString(nil, "ARTWORK")
KeystoneInfo.WeeklyInfo.Child.TextThisWeek:SetFont("Fonts\\FRIZQT__.TTF", 22, "OUTLINE")
KeystoneInfo.WeeklyInfo.Child.TextThisWeek:SetPoint("TOP", 0, -25)
KeystoneInfo.WeeklyInfo.Child.TextThisWeek:SetText("Cette semaine")

for i = 1, 6 do 
    local affix = CreateFrame("Frame", nil, KeystoneInfo.WeeklyInfo.Child)
        affix:SetSize(64, 64)
        if i == 1 then 
            affix:SetPoint("TOP", KeystoneInfo.WeeklyInfo.Child.TextThisWeek, "BOTTOM", 0, -8)
        else
            affix:SetPoint("LEFT", KeystoneInfo.WeeklyInfo.Child["Affix"..i-1], "RIGHT", 4, 0)
        end
        affix:EnableMouse(true)

        affix.Border = affix:CreateTexture(nil, "OVERLAY")
        affix.Border:SetAllPoints()
        affix.Border:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
        affix.Border:SetTexCoord(0.964844, 0.998047, 0.000976562, 0.0341797)

        affix.Portrait = affix:CreateTexture(nil, "ARTWORK")
        affix.Portrait:SetSize(62, 62)
        affix.Portrait:SetPoint("CENTER", affix.Border)

        affix:SetScript("OnEnter", function(self)
            if not self.spell then return end

            local spellName = GetSpellInfo(self.spell)
            if not spellName then return end

            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            GameTooltip:SetHyperlink("|Hspell:"..self.spell.."|h["..spellName.."]|h")
            GameTooltip:Show()
        end)

        affix:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        affix:Hide()

        KeystoneInfo.WeeklyInfo.Child["Affix"..i] = affix
end

KeystoneInfo.WeeklyInfo.Child.TextBest = KeystoneInfo.WeeklyInfo.Child:CreateFontString(nil, "ARTWORK")
KeystoneInfo.WeeklyInfo.Child.TextBest:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
KeystoneInfo.WeeklyInfo.Child.TextBest:SetPoint("BOTTOMLEFT", 12, 80)
KeystoneInfo.WeeklyInfo.Child.TextBest:SetText("Meilleures sessions")

-- spiky star
KeystoneInfo.WeeklyInfo.Child.BestBG = KeystoneInfo.WeeklyInfo.Child:CreateTexture(nil, "ARTWORK")
KeystoneInfo.WeeklyInfo.Child.BestBG:SetPoint("CENTER", 0, 0)
KeystoneInfo.WeeklyInfo.Child.BestBG:SetSize(200, 200)
KeystoneInfo.WeeklyInfo.Child.BestBG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
KeystoneInfo.WeeklyInfo.Child.BestBG:SetTexCoord(0.000976562, 0.196289, 0.408203, 0.798828)

-- soft yellow glow 
KeystoneInfo.WeeklyInfo.Child.BestBG2 = KeystoneInfo.WeeklyInfo.Child:CreateTexture(nil, "OVERLAY")
KeystoneInfo.WeeklyInfo.Child.BestBG2:SetPoint("CENTER", KeystoneInfo.WeeklyInfo.Child.BestBG)
KeystoneInfo.WeeklyInfo.Child.BestBG2:SetSize(200, 200)
KeystoneInfo.WeeklyInfo.Child.BestBG2:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
KeystoneInfo.WeeklyInfo.Child.BestBG2:SetTexCoord(0.000976562, 0.202148, 0.00195312, 0.404297)
KeystoneInfo.WeeklyInfo.Child.BestBG2:SetAlpha(0.8)
KeystoneInfo.WeeklyInfo.Child.BestBG2:SetBlendMode("ADD")
KeystoneInfo.WeeklyInfo.Child.BestBG2:Hide()

KeystoneInfo.WeeklyInfo.Child.BestLevel = KeystoneInfo.WeeklyInfo.Child:CreateFontString(nil, "OVERLAY")
KeystoneInfo.WeeklyInfo.Child.BestLevel:SetFontObject(GameFontNormal)
KeystoneInfo.WeeklyInfo.Child.BestLevel:SetFont("Fonts\\FRIZQT__.TTF", 32, "OUTLINE")
KeystoneInfo.WeeklyInfo.Child.BestLevel:SetPoint("CENTER", KeystoneInfo.WeeklyInfo.Child.BestBG, -1)
KeystoneInfo.WeeklyInfo.Child.BestLevel:SetText("")

KeystoneInfo.WeeklyInfo.Child.BestDungeon = KeystoneInfo.WeeklyInfo.Child:CreateFontString(nil, "OVERLAY")
KeystoneInfo.WeeklyInfo.Child.BestDungeon:SetFontObject(GameFontNormal)
KeystoneInfo.WeeklyInfo.Child.BestDungeon:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
KeystoneInfo.WeeklyInfo.Child.BestDungeon:SetPoint("BOTTOM", KeystoneInfo.WeeklyInfo.Child.BestBG, "TOP", 0, 12)
KeystoneInfo.WeeklyInfo.Child.BestDungeon:SetText("Meilleur: |cFFFFFFFFAucun Donjons|r")

KeystoneInfo.WeeklyInfo.Child.RewardsLeft = KeystoneInfo.WeeklyInfo.Child:CreateFontString(nil, "OVERLAY")
KeystoneInfo.WeeklyInfo.Child.RewardsLeft:SetFontObject(GameFontNormal)
KeystoneInfo.WeeklyInfo.Child.RewardsLeft:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
KeystoneInfo.WeeklyInfo.Child.RewardsLeft:SetPoint("TOP", KeystoneInfo.WeeklyInfo.Child.BestBG, "BOTTOM", 0, -12)
KeystoneInfo.WeeklyInfo.Child.RewardsLeft:SetText("Récompenses d'objets restantes: |cFFFFFFFF0|r")


KeystoneInfo.WeeklyInfo.Child.ScheduleFrame = CreateFrame("Frame", nil, KeystoneInfo.WeeklyInfo.Child)
KeystoneInfo.WeeklyInfo.Child.ScheduleFrame:SetSize(246, 92)
KeystoneInfo.WeeklyInfo.Child.ScheduleFrame:SetPoint("RIGHT", -20, 60)
--TODO: Remove me later
KeystoneInfo.WeeklyInfo.Child.ScheduleFrame:Hide()

KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.BG = KeystoneInfo.WeeklyInfo.Child.ScheduleFrame:CreateTexture(nil, "ARTWORK")
KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.BG:SetAllPoints()
KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.BG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.BG:SetTexCoord(0.387695, 0.631836, 0.00195312, 0.216797)
KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.BG:SetAlpha(0.4)

KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.Line = KeystoneInfo.WeeklyInfo.Child.ScheduleFrame:CreateTexture(nil, "OVERLAY")
KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.Line:SetSize(232, 9)
KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.Line:SetPoint("TOP", 0, -20)
KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.Line:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.Line:SetTexCoord(0.387695, 0.576172, 0.554688, 0.572266)

KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.Title = KeystoneInfo.WeeklyInfo.Child.ScheduleFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.Title:SetPoint("TOPLEFT", 15, -7)
KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.Title:SetText("Calendrier")

KeystoneInfo.WeeklyInfo.Child.PartyKeys = CreateFrame("Frame", nil, KeystoneInfo.WeeklyInfo.Child)
KeystoneInfo.WeeklyInfo.Child.PartyKeys:SetSize(246, 128)
KeystoneInfo.WeeklyInfo.Child.PartyKeys:SetPoint("RIGHT", -20, 0)

KeystoneInfo.WeeklyInfo.Child.PartyKeys.BG = KeystoneInfo.WeeklyInfo.Child.PartyKeys:CreateTexture(nil, "ARTWORK")
KeystoneInfo.WeeklyInfo.Child.PartyKeys.BG:SetAllPoints()
KeystoneInfo.WeeklyInfo.Child.PartyKeys.BG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
KeystoneInfo.WeeklyInfo.Child.PartyKeys.BG:SetTexCoord(0.387695, 0.631836, 0.00195312, 0.216797)
KeystoneInfo.WeeklyInfo.Child.PartyKeys.BG:SetAlpha(0.4)

KeystoneInfo.WeeklyInfo.Child.PartyKeys.Line = KeystoneInfo.WeeklyInfo.Child.PartyKeys:CreateTexture(nil, "OVERLAY")
KeystoneInfo.WeeklyInfo.Child.PartyKeys.Line:SetSize(232, 9)
KeystoneInfo.WeeklyInfo.Child.PartyKeys.Line:SetPoint("TOP", 0, -20)
KeystoneInfo.WeeklyInfo.Child.PartyKeys.Line:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
KeystoneInfo.WeeklyInfo.Child.PartyKeys.Line:SetTexCoord(0.387695, 0.576172, 0.554688, 0.572266)

KeystoneInfo.WeeklyInfo.Child.PartyKeys.Title = KeystoneInfo.WeeklyInfo.Child.PartyKeys:CreateFontString(nil, "ARTWORK", "GameFontNormal")
KeystoneInfo.WeeklyInfo.Child.PartyKeys.Title:SetPoint("TOPLEFT", 15, -7)
KeystoneInfo.WeeklyInfo.Child.PartyKeys.Title:SetText("Groupe de clé")
KeystoneInfo.WeeklyInfo.Child.PartyKeys:Hide()

for i = 1, 5 do
    local partyMember = CreateFrame("Frame", nil, KeystoneInfo.WeeklyInfo.Child.PartyKeys)
    KeystoneInfo.WeeklyInfo.Child.PartyKeys["Party"..i] = partyMember

    partyMember:SetSize(216, 18)
    partyMember:SetPoint("TOP", KeystoneInfo.WeeklyInfo.Child.PartyKeys.Line, "BOTTOM", 0, (i - 1) * -18)
    
    partyMember.Text = partyMember:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    partyMember.Text:SetWidth(120)
    partyMember.Text:SetJustifyH("LEFT")
    partyMember.Text:SetWordWrap(false)
    partyMember.Text:SetPoint("LEFT")

    partyMember.Text:SetText(UnitName("player"))

    partyMember.Key = partyMember:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    partyMember.Key:SetJustifyH("RIGHT")
    partyMember.Key:SetWordWrap(false)
    partyMember.Key:SetPoint("RIGHT")

    partyMember.SetKey = function(self, player, itemId)
        self.Text:SetText(player)
        self:Show()
        self:GetParent():Show()

        local keystone = Addon.KeystoneData[itemId]
        if not keystone then
            self.Key:SetText("Pas de clé")
            return
        end
        local name = MythicKeystone.AbbreviatedKeys[keystone.instanceName] or keystone.instanceName
        self.Key:SetText(format("%s (+%d)", name, keystone.mythicLevel))
    end

    partyMember:Hide()
end

for i = 1, 3 do 
    local week = CreateFrame("Frame", nil, KeystoneInfo.WeeklyInfo.Child.ScheduleFrame)
    KeystoneInfo.WeeklyInfo.Child.ScheduleFrame["Week"..i] = week 

    week:SetSize(216, 18)
    week:SetPoint("TOP", KeystoneInfo.WeeklyInfo.Child.ScheduleFrame.Line, "BOTTOM", 0, (i - 1) * -18)
    week.Text = week:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    week.Text:SetWidth(120)
    week.Text:SetJustifyH("LEFT")
    week.Text:SetWordWrap(false)
    week.Text:SetPoint("LEFT")

    if i == 1 then 
        week.Text:SetText("Cette semaine")
    elseif i == 2 then 
        week.Text:SetText("La semaine prochaine")
    else
        week.Text:SetText("Dans deux semaines")
    end

    -- create affix frames
    for j = 1, 6 do 
        local affix = CreateFrame("Frame", nil, week)
        affix:SetSize(16, 16)
        affix:SetPoint("RIGHT", week, "RIGHT", (j - 1) * - 18, 0)
        affix:EnableMouse(true)

        affix.Border = affix:CreateTexture(nil, "OVERLAY")
        affix.Border:SetAllPoints()
        affix.Border:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
        affix.Border:SetTexCoord(0.964844, 0.998047, 0.000976562, 0.0341797)

        affix.Portrait = affix:CreateTexture(nil, "ARTWORK")
        affix.Portrait:SetSize(14, 14)
        affix.Portrait:SetPoint("CENTER", affix.Border)

        affix:SetScript("OnEnter", function(self)
            if not self.spell then return end

            local spellName = GetSpellInfo(self.spell)
            if not spellName then return end

            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            GameTooltip:SetHyperlink("|Hspell:"..self.spell.."|h["..spellName.."]|h")
            GameTooltip:Show()
        end)

        affix:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        affix:Hide()

        KeystoneInfo.WeeklyInfo.Child.ScheduleFrame["Week"..i]["Affix"..j] = affix
    end
end


-- child frame background rune textures
local RuneBG = KeystoneInfo.WeeklyInfo.Child:CreateTexture(nil, "BACKGROUND")
KeystoneInfo.WeeklyInfo.Child.RuneBG = RuneBG

RuneBG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
RuneBG:SetSize(710, 710)
RuneBG:SetTexCoord(0.000976562, 0.694336, 0.000976562, 0.694336)
RuneBG:SetPoint("CENTER", -100, 50)
RuneBG:SetAlpha(0.5)

local RunesLarge = KeystoneInfo.WeeklyInfo.Child:CreateTexture(nil, "BACKGROUND")
KeystoneInfo.WeeklyInfo.Child.RunesLarge = RunesLarge 

RunesLarge:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
RunesLarge:SetSize(381, 381)
RunesLarge:SetTexCoord(0.538086, 0.910156, 0.000976562, 0.373047)
RunesLarge:SetPoint("CENTER", RuneBG)
RunesLarge:SetAlpha(0.5)

local RunesSmall = KeystoneInfo.WeeklyInfo.Child:CreateTexture(nil, "BACKGROUND")
KeystoneInfo.WeeklyInfo.Child.RunesSmall = RunesSmall

RunesSmall:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
RunesSmall:SetSize(248, 248)
RunesSmall:SetTexCoord(0.257812, 0.5, 0.696289, 0.938477)
RunesSmall:SetPoint("CENTER", RuneBG, -1)
RunesSmall:SetAlpha(0.5)

local LargeRuneGlow = KeystoneInfo.WeeklyInfo.Child:CreateTexture(nil, "BACKGROUND", 1)
KeystoneInfo.WeeklyInfo.Child.LargeRuneGlow = LargeRuneGlow

LargeRuneGlow:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
LargeRuneGlow:SetSize(392, 391)
LargeRuneGlow:SetTexCoord(0.524414, 0.907227, 0.615234, 0.99707)
LargeRuneGlow:SetPoint("TOPLEFT", 0, -2)
LargeRuneGlow:SetAlpha(0)
LargeRuneGlow:SetBlendMode("ADD")

LargeRuneGlow.AnimGroup = LargeRuneGlow:CreateAnimationGroup()
LargeRuneGlow.AnimGroup:SetLooping("BOUNCE")
LargeRuneGlow.AnimGroup.Alpha = LargeRuneGlow.AnimGroup:CreateAnimation("Alpha")
LargeRuneGlow.AnimGroup.Alpha:SetStartDelay(1.5)
LargeRuneGlow.AnimGroup.Alpha:SetDuration(3)
LargeRuneGlow.AnimGroup.Alpha:SetChange(0.1)
LargeRuneGlow.AnimGroup:Play()

local SmallRuneGlow = KeystoneInfo.WeeklyInfo.Child:CreateTexture(nil, "BACKGROUND", 1)
KeystoneInfo.WeeklyInfo.Child.SmallRuneGlow = SmallRuneGlow

SmallRuneGlow:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeRunes")
SmallRuneGlow:SetSize(252, 252)
SmallRuneGlow:SetTexCoord(0.000976562, 0.255859, 0.696289, 0.950195)
SmallRuneGlow:SetPoint("CENTER", RunesSmall)
SmallRuneGlow:SetAlpha(0)
SmallRuneGlow:SetBlendMode("ADD")

SmallRuneGlow.AnimGroup = SmallRuneGlow:CreateAnimationGroup()
SmallRuneGlow.AnimGroup:SetLooping("BOUNCE")
SmallRuneGlow.AnimGroup.Alpha = SmallRuneGlow.AnimGroup:CreateAnimation("Alpha")
SmallRuneGlow.AnimGroup.Alpha:SetDuration(3)
SmallRuneGlow.AnimGroup.Alpha:SetChange(0.3)
SmallRuneGlow.AnimGroup:Play()

local function SetBestRun(frame)
    if frame.dungeon.best ~= 0 then
        frame.Text:SetText(frame.dungeon.best)
    else
        frame.Text:SetText("")
    end

    if frame.dungeon.timed then
        frame.BG:SetVertexColor(1, 1, 1)
        frame.Text:SetTextColor(1, 0.843, 0)
        frame.BG:SetDesaturated(0)
    else
        frame.BG:SetVertexColor(0.5, 0.5, 0.5)
        frame.Text:SetTextColor(1, 1, 1)
        frame.BG:SetDesaturated(1)
    end
end

--SETUP DUNGEON FRAMES FOR CLASSIC
local i = 1
if level < 70 then
    for name, dungeon in pairs(Classic_Dungeon_Info) do
        local best = CreateFrame("Frame", nil, KeystoneInfo)
        best.id = i
        best:SetSize(77, 77)
        best:SetPoint("BOTTOMLEFT", KeystoneInfo, "BOTTOMLEFT", 10 + ((i - 1) * 77), 10)
        best.Text = best:CreateFontString(nil, "OVERLAY")
        best.Text:SetPoint("TOP", -1, -8)
        best.Text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        best.Text:SetText("")

        best.dungeon = dungeon

        best.BG = best:CreateTexture(nil, "OVERLAY")
        best.BG:SetAllPoints()
        best.BG:SetTexture(dungeon.texture)

        best.Border = CreateFrame("Frame", nil, best)
        best.Border:SetPoint("TOPLEFT", 2, -2)
        best.Border:SetPoint("BOTTOMRIGHT", -2, 2)
        best.Border:SetBackdrop({
            edgeFile = [[Interface\Buttons\WHITE8x8]],
            edgeSize = 2
        })
        best.Border:SetBackdropBorderColor(0, 0, 0, 0.7)

        SetBestRun(best)

        best:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            GameTooltip:AddLine(format("%s (+%d)", dungeon.name, dungeon.best))

            if dungeon.totalTime > 0 then
                local minutes = dungeon.totalTime / 60 % 60
                local seconds = dungeon.totalTime % 60
                
                if dungeon.timed then -- make text red if we didn't time this dungeon
                    GameTooltip:AddDoubleLine("|cFFFFFFFFTemps|r", format("|cFFFFFFFF%02d:%02d|r", minutes, seconds))
                else
                    GameTooltip:AddDoubleLine("|cFFFFFFFFTemps|r", "|cFFFF3F40temps supplémentaire|r")
                end
                

                -- add date completed 
                GameTooltip:AddDoubleLine("|cFFFFFFFFDate|r", format("|cFFFFFFFF%s|r", date("%m/%d/%y", dungeon.timestamp)))
            else
                GameTooltip:AddLine("|cFFFFFFFFAucune clé terminée pour ce donjon!|r")
            end

            GameTooltip:Show()
        end)

        best:SetScript("OnLeave", function() 
            GameTooltip:Hide()
        end)
        best:EnableMouse(true)

        BestFrames[dungeon.name] = best
        KeystoneInfo["Best"..i] = best
        i = i + 1
    end
else -- SETUP DUNGEON FRAMES FOR TBC
    for name, dungeon in pairs(BC_Dungeon_Info) do
        local best = CreateFrame("Frame", nil, KeystoneInfo)
        best.id = i
        best:SetSize(51, 51)
        best:SetPoint("BOTTOMLEFT", KeystoneInfo, "BOTTOMLEFT", 8 + ((i - 1) * 51), 10)
        best.Text = best:CreateFontString(nil, "OVERLAY")
        best.Text:SetPoint("TOP", -1, -8)
        best.Text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        best.Text:SetText("")

        best.dungeon = dungeon

        best.BG = best:CreateTexture(nil, "OVERLAY")
        best.BG:SetAllPoints()
        best.BG:SetTexture(dungeon.texture)

        best.Border = CreateFrame("Frame", nil, best)
        best.Border:SetPoint("TOPLEFT", 2, -2)
        best.Border:SetPoint("BOTTOMRIGHT", -2, 2)
        best.Border:SetBackdrop({
            edgeFile = [[Interface\Buttons\WHITE8x8]],
            edgeSize = 2
        })
        best.Border:SetBackdropBorderColor(0, 0, 0, 0.7)

        SetBestRun(best)

        best:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            GameTooltip:AddLine(dungeon.name)
            GameTooltip:Show()
        end)

        best:SetScript("OnLeave", function() 
            GameTooltip:Hide()
        end)
        best:EnableMouse(true)

        BestFrames[dungeon.name] = best
        KeystoneInfo["Best"..i] = best
        i = i + 1
    end
end

function KeystoneInfo:StoreKeystoneData(name, level, timed, totalTime)
    local db = MythicKeystone.CDB
    db.BestRuns = db.BestRuns or {}
    local run = db.BestRuns[name]
    -- check if our run is better than our saved run
    if run then
        -- level is lower than our best, exit
        if level < run.best then
            return
        end
        -- our run wasn't timed and our best was, exit
        if not timed and run.timed then
            return
        end
        -- our run was timed but slower, exit
        if level == run.best and timed and run.timed and totalTime > run.totalTime then
            return
        end
    end

    db.BestRuns[name] = {
        timed = timed, 
        totalTime = totalTime,
        best = level,
        timestamp = time()
    }
    --print("Stored Best Run -", name, "+"..level, "Timed =", timed, "Seconds =", totalTime)

    if level > db.CurrentWeek.best or timed and not db.CurrentWeek.timed then
        db.CurrentWeek.best = level
        db.CurrentWeek.name = name
        db.CurrentWeek.timed = timed
        if BC_Dungeon_Info[name] then
            db.CurrentWeek.bg = BC_Dungeon_Info[name].bg
        else
            db.CurrentWeek.bg = Classic_Dungeon_Info[name].bg
        end
        KeystoneInfo:UpdateWeeklyBest()
    end

    KeystoneInfo:UpdateKeystoneData()
end

function KeystoneInfo:UpdateKeystoneData()
    local db = MythicKeystone.CDB
    if not db then return end
    
    --TODO: When amount of rewwards is available change this
    local keystone = Addon.KeystoneData[MythicKeystone:GetCurrentKeystone()]
    if keystone then
        KeystoneInfo.WeeklyInfo.Child.RewardsLeft:SetText(format("Ma clé: |cFFFFFFFF%s (+%d)|r", keystone.instanceName, keystone.mythicLevel))
    else
        KeystoneInfo.WeeklyInfo.Child.RewardsLeft:SetText("Ma clé: |cFFFFFFFFAucune clé|r")
    end
    -- reset our weekly data if the week changed or we don't have any!
    if MythicKeystone.CDB.Week and (not db.CurrentWeek or db.CurrentWeek.week ~= MythicKeystone.CDB.Week) then
        db.CurrentWeek = {
            best = 0, 
            name = "",
            timed = false,
            week = MythicKeystone.CDB.Week,
            bg = ""
        }
    end

    if db and db.BestRuns then
        local dungeonInfo = Classic_Dungeon_Info
        if level == 70 then 
            dungeonInfo = BC_Dungeon_Info 
        end
        for name, dungeon in pairs(dungeonInfo) do
            local data = db.BestRuns[name]

            if data then
                dungeon.timed = data.timed
                dungeon.best = data.best
                dungeon.totalTime = data.totalTime
                dungeon.timestamp = data.timestamp
            end

            local frame = BestFrames[name]
            SetBestRun(frame)
        end
    end

    KeystoneInfo:UpdateWeeklyBest()

    KeystoneInfo:UpdateAffixSchedule()
end

function KeystoneInfo:UpdateWeeklyBest()
    local db = MythicKeystone.CDB
    if not db or not db.CurrentWeek or db.CurrentWeek.best <= 0 then 
        KeystoneInfo.WeeklyInfo.Child.BestDungeon:SetText("Meilleur: |cFFFFFFFFAucun Donjon|r")
        KeystoneInfo.WeeklyInfo.Child.BestLevel:SetText("")
        KeystoneInfo.WeeklyInfo.Child.BestBG2:Hide()
        KeystoneInfo.WeeklyInfo.BG2:Hide()
        return
    end

    KeystoneInfo.WeeklyInfo.BG2:SetTexture(db.CurrentWeek.bg)
    KeystoneInfo.WeeklyInfo.BG2:Show()
    KeystoneInfo.WeeklyInfo.Child.BestDungeon:SetText("Meilleur: |cFFFFFFFF"..db.CurrentWeek.name.." +"..db.CurrentWeek.best.."|r")
    KeystoneInfo.WeeklyInfo.Child.BestLevel:SetText(db.CurrentWeek.best)
    KeystoneInfo.WeeklyInfo.Child.BestBG2:Show()
end

function KeystoneInfo:UpdateAffixSchedule()
    local week = MythicKeystone.CDB.Week

    if not week then return end

    -- do each week
    for i = 1, 3 do 
        local offset = week + (i - 1)

        -- 254 is max key level, maybe just do 10?
        local affixes, affixCount = MythicKeystone:GetAffixes(offset, 100)
        
        if affixCount > 6 then 
            affixCount = 6
        end

        for j = 1, 6 do 
            local frame = KeystoneInfo.WeeklyInfo.Child.ScheduleFrame["Week"..i]["Affix"..j]
            frame.spell = nil
            frame:Hide()
        end

        -- first week needs to display at the top of the frame too
        if i == 1 then
            for j = 1, 6 do
                local frame = KeystoneInfo.WeeklyInfo.Child["Affix"..i]
                frame:Hide()
                frame.spell = nil
            end

            local j = 1
            for id in pairs(affixes) do
                if j <= affixCount then
                    local frame = KeystoneInfo.WeeklyInfo.Child["Affix"..j]

                    frame.spell = id
                    local _, _, spellIcon = GetSpellInfo(id)
                    SetPortraitToTexture(frame.Portrait, spellIcon)
                    frame:Show()

                    KeystoneInfo.WeeklyInfo.Child["Affix"..1]:SetPoint("TOP", KeystoneInfo.WeeklyInfo.Child.TextThisWeek, "BOTTOM", (j - 1) * - 34, 0)
                    j = j + 1
                end
            end
        end

        -- display the affixes for the week
        local j = 1
        for id in pairs(affixes) do
            if j <= affixCount then 
                local frame = KeystoneInfo.WeeklyInfo.Child.ScheduleFrame["Week"..i]["Affix"..j]
                frame.spell = id
                local _, _, spellIcon = GetSpellInfo(id)
                SetPortraitToTexture(frame.Portrait, spellIcon)
                frame:Show()
                j = j + 1
            end
        end
    end
end

function KeystoneInfo:MakeFakeData()
    local db = MythicKeystone.CDB
    db.BestRuns = db.BestRuns or {}
    local tf = {true, false}
    for name in pairs(Classic_Dungeon_Info) do 
        KeystoneInfo:StoreKeystoneData(name, random(2, 15), tf[random(0, 1)], random(600, 1200))
    end
    KeystoneInfo:UpdateKeystoneData()
end

function KeystoneInfo:ClearFakeData()
    local db = MythicKeystone.CDB
    db.BestRuns = nil
    db.CurrentWeek = nil
    KeystoneInfo:UpdateKeystoneData()
end

function KeystoneInfo:AddPartyMemberKey(player, itemId)
    if UnitInRaid("player") then return end
    PartyKeystones[player] = itemId
    KeystoneInfo:UpdatePartyKeys()
end

function KeystoneInfo:UpdatePartyKeys()
    for i = 1, 5 do 
        KeystoneInfo.WeeklyInfo.Child.PartyKeys["Party"..i]:Hide()
    end

    if UnitInRaid("player") then return end

    local i = 1
    local hide = true
    for person, id in pairs(PartyKeystones) do
        if not UnitInParty(person) then 
            PartyKeystones[person] = nil 
        else
            if i <= 5 then
                KeystoneInfo.WeeklyInfo.Child.PartyKeys["Party"..i]:SetKey(person, id)
                i = i + 1
                hide = false
            end
        end
    end

    if hide then 
        KeystoneInfo.WeeklyInfo.Child.PartyKeys:Hide()
    end
end

function KeystoneInfo:SendKey()
    CurrentKeystone = MythicKeystone:GetCurrentKeystone()
    if UnitInRaid("player") then return end
    SendAddonMessage(MythicKeystone.CommPrefix, COMM_SEND_MY_KEY.." "..CurrentKeystone, "PARTY")
end

function KeystoneInfo:RequestPartyKeystones()
    SendAddonMessage(MythicKeystone.CommPrefix, COMM_REQUEST_KEYS, "PARTY")
end

function KeystoneInfo:ReceiveComm(player, msg)
    if UnitInRaid("player") then return end
    if msg:find(COMM_SEND_MY_KEY) then
        local itemId = msg:match(COMM_SEND_MY_KEY.." (%d+)")
        itemId = tonumber(itemId)
        if itemId then
            KeystoneInfo:AddPartyMemberKey(player, itemId)
        end
    elseif msg:find(COMM_REQUEST_KEYS) then 
        KeystoneInfo:SendKey()
    end
end

KeystoneInfo:RegisterEvent("PLAYER_ENTERING_WORLD")
KeystoneInfo:RegisterEvent("CHAT_MSG_ADDON")
KeystoneInfo:RegisterEvent("PARTY_MEMBERS_CHANGED")
KeystoneInfo:RegisterEvent("PARTY_CONVERTED_TO_RAID")
KeystoneInfo:RegisterEvent("ITEM_PUSH")
KeystoneInfo:SetScript("OnEvent", function(self, event, ...) 
    if event == "PLAYER_ENTERING_WORLD" then 
        self:UpdateKeystoneData()
        -- we just logged into a party, get keystones
        if GetNumPartyMembers() > 0 then
            self:RequestPartyKeystones()
        end

    elseif event == "CHAT_MSG_ADDON" then
        local prefix, msg, _, player = ...
        if prefix == MythicKeystone.CommPrefix then
            self:ReceiveComm(player, msg)
        end

    elseif event == "PARTY_MEMBERS_CHANGED" then 
        self:SendKey()
    
    elseif event == "PARTY_CONVERTED_TO_RAID" then
        self:UpdatePartyKeys()
    
    elseif event == "ITEM_PUSH" then 
        if GetNumPartyMembers() > 0 and not UnitInRaid("player") then 
            if CurrentKeystone ~= MythicKeystone:GetCurrentKeystone() then 
                self:SendKey()
                --TODO: Do we want this?
                --local keystone = Addon.KeystoneData[CurrentKeystone]
                --SendChatMessage(format("New Keystone: %s (+%d)", keystone.instanceName, keystone.mythicLevel), "PARTY")
            end
        end
    end
end)

KeystoneInfo:SetScript("OnShow", function(self)
    self:UpdateKeystoneData()
end)

