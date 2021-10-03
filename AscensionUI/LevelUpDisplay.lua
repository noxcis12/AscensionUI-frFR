local Addon = select(2, ...)

--[[if not _G["AscensionUI"] then
    _G["AscensionUI"] = Addon
end]]

-- Disable for CoA
local _, class = UnitClass("player")
if class ~= "DRUID" then
    return
end

Addon.LevelUpDisplay = {}
LU = Addon.LevelUpDisplay

local scrollOfFortuneID = 0
local scrollOfUnlearningID = 1101243 -- scroll of talent unlearning
local talentEssenceID = 383081
local abilityEssenceID = 383080

LU.Settings = {
    Spell = {
        TexCoords = {0.64257813, 0.72070313, 0.03710938, 0.11132813},
        Format = "Capacité disponible %s:"
    },
    Feature = {
        TexCoords = {0.64257813, 0.70117188, 0.11523438, 0.18359375},
        Format = "|cff00FF00Nouvelle fonctionnalité déverrouillée:|r",
        FormatSpecial = "|cffFF0000ATTENTION!|r"
    },
    Item = {
        TexCoords = {0.64257813, 0.68359375, 0.18750000, 0.23046875},
        Format = "|cff00FF00Objet reçu:|r"
    }
}

LU.Features = {
    [10] = {
        {
            itemType = "Feature",
            id = nil,
            icon = "Interface\\Icons\\Ability_Marksmanship",
            name = "Talents"
        },
        {
            itemType = "Feature",
            id = nil,
            icon = "Interface\\Icons\\Ability_DualWield",
            name = "Champs de Bataille"
        },
        {
            itemType = "Feature",
            id = nil,
            icon = "Interface\\Icons\\INV_Misc_Coin_01",
            name = "Plus de réinitialisations gratuites!"
        }
    },
    [15] = {
        {
            itemType = "Feature",
            id = nil,
            icon = "Interface\\Icons\\LevelUpIcon-LFD",
            name = "Recherche de Donjon!"
        },
        {
            itemType = "Feature",
            id = nil,
            icon = "Interface\\Icons\\spell_warlock_demonicportal_green",
            name = "Fel Commutation"
        },
        {
            itemType = "Feature",
            id = nil,
            icon = "Interface\\Icons\\inv_custom_demonstears",
            name = "Emplacement pour arme principale assuré!"
        },
        {
            itemType = "Feature",
            id = nil,
            icon = "Interface\\Icons\\inv_custom_demonstears",
            name = "Emplacement pour arme secondaire assuré!"
        },
        {
            itemType = "Feature",
            id = nil,
            icon = "Interface\\Icons\\inv_custom_demonstears",
            name = "Emplacement d'arme à distance assuré!"
        }
    },
    [60] = {
        {
            itemType = "Feature",
            id = nil,
            icon = "Interface\\Icons\\Ability_Mount_Awakening",
            name = "100% d'augmentation de la vitesse des montures"
        },
        {
            itemType = "Feature",
            id = nil,
            icon = "Interface\\Icons\\INV_custom_spectome",
            name = "Multi Specialisation"
        },
        {
            itemType = "Feature",
            id = nil,
            icon = "Interface\\Icons\\inv_custom_ReforgeToken",
            name = "Enchant Collection Reforge"
        }
    }
}

LU.Spells = nil

LU.Items = {}

LU.DataInQueue = {}

local uiDifference = 1
local uiScale = 1

local function IsTalentSpell(talent)
    if SPELL_QUALITY_TABLE[talent] then
        return true
    end
    return false
end

local function GetSpellData()
    -- this probably will need to be replaced if Character Advancement is rewritten
    -- I'd argue global tables like CAO_Spells / CAO_Talents are very useful for other addon devs though 
    -- so maybe getting that data from the server should stay
    -- would also save the hassle of having a big unwieldy number table to map spells to lvl
    if not CAO_Spells or not CAO_Talent_References or not CAO_Talents then return end -- table isnt ready i guess

    for spellID, spellInfo in pairs(CAO_Spells) do
        if not LU.Spells then 
            LU.Spells = {}
        end
        if not LU.Spells[spellInfo[4]] then
            LU.Spells[spellInfo[4]] = {}
        end

        tinsert(LU.Spells[spellInfo[4]], {
            itemType = "Spell",
            id = spellID
        })
    end

    for spellID, refID in pairs(CAO_Talent_References) do
        if IsTalentSpell(spellID) then
            if CAO_Talents[refID] ~= nil then
                local level = CAO_Talents[refID][5]
                if not LU.Spells[level] then
                    LU.Spells[level] = {}
                end

                tinsert(LU.Spells[level], {
                    itemType = "Spell",
                    id = spellID
                })
            end
        end
    end
end

local function UIScaleSolveConflict()
    if (GetCVar("useUiScale") == "1") then
        uiDifference = 1
        uiScale = GetCVar("uiScale")
    else
        SetCVar("uiScale", "1")
        _, h = UIParent:GetSize()
        uiDifference = 768 / h
        uiScale = 1
    end
end

-- more stuff from Character Advancement
local function IsDraftMode()
    --return false
    return IN_DRAFT_MODE
end

local function IsRandomMode()
    return IN_RM_MODE
end

local function GenerateLevelUpData()
    local level = LU.level
    local data = {}

    -- add features first
    if LU.Features[level] then
        for _, entry in ipairs(LU.Features[level]) do
            tinsert(data, entry)
        end
    end

    -- add spells
    if not IsRandomMode() and not IsDraftMode() then
        -- couldnt cache spells earlier, maybe we can now?
        if CAO_Spells then
            if not LU.Spells then
                GetSpellData()
            end
        else -- still cant, show nothing sadly
            return
        end

        if LU.Spells and LU.Spells[level] then
            for _, entry in pairs(LU.Spells[level]) do
                tinsert(data, entry)
            end
        end
    end

    -- add new spells if in random mode
    if IsRandomMode() then
        if not LU.KnownSpells and CAO_Known then
            -- for some reason we didnt cache spells.
            -- cache spells now and tell the player next time they level i guess
            for id, known in pairs(CAO_Known) do
                LU.KnownSpells[id] = known
            end
        elseif CAO_Known then
            for spellID in pairs(CAO_Known) do
                if LU.KnownSpells[spellID] == nil then
                    LU.KnownSpells[spellID] = 1
                    tinsert(data, {
                        itemType = "Spell",
                        id = spellID
                    })
                end
            end
        end
    end

    -- add talent / ability essence last
    if LU.level >= 10 then
        tinsert(data, {
            itemType = "Item",
            id = talentEssenceID
        })
        -- dont need to tell draft or random mode about their new unusable essence
        if not IsRandomMode() and not IsDraftMode() then
            tinsert(data, {
                itemType = "Item",
                id = abilityEssenceID
            })
        end
    end

    -- scrolls every 10 levels
    if LU.level % 10 == 0 then
        if IsRandomMode() then
            tinsert(data, {
                itemType = "Item",
                id = scrollOfFortuneID
            })
        else
            tinsert(data, {
                itemType = "Item",
                id = scrollOfUnlearningID
            })
        end
    end

    return data
end

local function DisplayData(data)
    local new = {}
    for i, info in ipairs(data) do
        if i > 6 then
            -- animation events will run these later
            tinsert(new, info)
        else
            LU.Frame.SkillFrame:DisplayItem(i, info)
        end
    end
    LU.DataInQueue = new
end

local function CreateLevelUpFrame()
    local f = CreateFrame("Frame", "ASC_LevelUp", UIParent)
    f:SetFrameStrata("TOOLTIP")
    f:SetPoint("TOP", 0, -190)
    f:SetSize(418, 72)
    f:Hide()

    f.BookIcon = f:CreateTexture(nil, "BACKGROUND")
    f.BookIcon:SetTexture("Interface\\LevelUp\\LevelUpTex")
    f.BookIcon:SetSize(223, 115)
    f.BookIcon:SetPoint("TOP", 0, 43)
    f.BookIcon:SetTexCoord(0.56054688, 0.99609375, 0.24218750, 0.46679688)
    f.BookIcon:SetVertexColor(1, 1, 1, 0)

    f.GoldBG = f:CreateTexture(nil, "BACKGROUND")
    f.GoldBG:SetTexture("Interface\\LevelUp\\LevelUpTex")
    f.GoldBG:SetSize(223, 115)
    f.GoldBG:SetPoint("TOP", 0, 43)
    f.GoldBG:SetTexCoord(0.56054688, 0.99609375, 0.24218750, 0.46679688)
    f.GoldBG:SetVertexColor(1, 1, 1, 0)

    f.Texture = f:CreateTexture(nil, "BACKGROUND", nil, 2)
    f.Texture:SetTexture("Interface\\LevelUp\\LevelUpTex")
    f.Texture:SetSize(284, 115)
    f.Texture:SetPoint("TOP", 0, 44)
    f.Texture:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
    f.Texture:SetVertexColor(1, 1, 1, 0.6)

    f.LineUp = f:CreateTexture(nil, "BORDER", nil, 2)
    f.LineUp:SetTexture("Interface\\LevelUp\\LevelUpTex")
    f.LineUp:SetSize(418, 7)
    f.LineUp:SetPoint("TOP")
    f.LineUp:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
    f.LineUp:SetVertexColor(1, 1, 1)

    f.LineDown = f:CreateTexture(nil, "BORDER", nil, 2)
    f.LineDown:SetTexture("Interface\\LevelUp\\LevelUpTex")
    f.LineDown:SetSize(418, 7)
    f.LineDown:SetPoint("BOTTOM", f.Texture)
    f.LineDown:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
    f.LineDown:SetVertexColor(1, 1, 1)

    f.Text = f:CreateFontString(nil, "OVERLAY", GameFont_Gigantic)
    f.Text:SetFont("Fonts\\MORPHEUS.ttf", 80, "OUTLINE")
    f.Text:SetPoint("BOTTOM", f.GoldBG, "BOTTOM", 0, 5)
    f.Text:SetShadowOffset(0,0)
    f.Text:SetText("Niveau 1")
    f.Text:SetVertexColor(1, 0.82, 0)
    f.Text:SetAlpha(0)

    f.ReachedText = f:CreateFontString(nil, "OVERLAY", SystemFont_Shadow_Large)
    f.ReachedText:SetFont("Fonts\\MORPHEUS.ttf", 80, "OUTLINE")
    f.ReachedText:SetPoint("BOTTOM",f.Text, "TOP", 0, 5)
    f.ReachedText:SetShadowOffset(0,0)
    f.ReachedText:SetText("Vous avez atteint le")
    f.ReachedText:SetAlpha(0)

    f.SkillFrame = CreateFrame("Frame", nil, f)
    f.SkillFrame:SetPoint("BOTTOM",f.GoldBG, "BOTTOM", 0, 5)
    f.SkillFrame:SetSize(418,72)
    f.SkillFrame:SetFrameLevel(4)
    f.SkillFrame.List = {}

    -- create skill icon slots
    for i = 1, 6 do
        local icon = f.SkillFrame:CreateTexture(nil, "BACKGROUND")
        icon:SetSize(36, 36)
        icon:SetTexture("Interface\\Icons\\INV_Chest_Samurai")
        icon:SetPoint("CENTER", -90, ((i - 1) * -50) - 10)

        icon.Name = f.SkillFrame:CreateFontString(nil, "OVERLAY")
        icon.Name:SetFontObject(GameFontNormalLarge)
        icon.Name:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 10, 2)
        icon.Name:SetShadowOffset(0,0)
        icon.Name:SetText("Nouvelle fonctionnalité débloquée!")
        icon.Name:SetJustifyH("LEFT")
        icon.Name:SetVertexColor(1, 1, 1)

        icon.SubText = f.SkillFrame:CreateFontString(nil, "OVERLAY")
        icon.SubText:SetFontObject(GameFontNormal)
        icon.SubText:SetPoint("BOTTOMLEFT", icon.Name, "TOPLEFT", 0, 1)
        icon.SubText:SetShadowOffset(0,0)
        icon.SubText:SetText("Nouvelle fonctionnalité débloquée!")
        icon.SubText:SetJustifyH("LEFT")

        icon.Book = f.SkillFrame:CreateTexture(nil, "OVERLAY", nil, 3)
        icon.Book:SetTexture("Interface\\LevelUp\\LevelUpTex")
        icon.Book:SetSize(20,20)
        icon.Book:SetPoint("BOTTOMLEFT", icon, -10, -8)
        icon.Book:SetTexCoord(0.64257813, 0.72070313, 0.03710938, 0.11132813)

        icon.Book:Hide()
        icon.SubText:Hide()
        icon.Name:Hide()
        icon:Hide()

        function icon:DisplayItem(data)
            -- data = { itemType, id, icon, name, format }
            local success = false
            if data.itemType == "Spell" then
                -- handle spells
                local spellName, _, spellIcon = GetSpellInfo(data.id)
                if not spellName then
                    return
                end

                if not spellIcon then
                    spellIcon = "Interface\\Icons\\INV_Misc_Book_09"
                end

                self:SetTexture(spellIcon)
                self.Name:SetText(spellName)
                self.SubText:SetText(format(LU.Settings.Spell.Format, spellName))
                self.Book:SetTexCoord(unpack(LU.Settings.Spell.TexCoords))
                success = true

            elseif data.itemType == "Item" then
                -- handle items
                local itemName, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(data.id)

                if not itemName and not data.name then
                    return
                end

                if not itemIcon and not data.icon then
                    itemIcon = "Interface\\Icons\\INV_Misc_Bag_08"
                end

                self:SetTexture(itemIcon or data.icon)
                self.Name:SetText(itemName or data.name)
                self.SubText:SetText(LU.Settings.Item.Format)
                self.Book:SetTexCoord(unpack(LU.Settings.Item.TexCoords))
                success = true

            elseif data.itemType == "Feature" or data.itemType == "FeatureSpecial" then
                -- handle features
                self:SetTexture(data.icon)
                self.Name:SetText(data.name)
                self.SubText:SetText(LU.Settings.Feature.Format)
                self.Book:SetTexCoord(unpack(LU.Settings.Feature.TexCoords))
                success = true
            end

            if success then
                self:Show()
                self.Name:Show()
                self.SubText:Show()
                self.Book:Show()
            end
        end

        f.SkillFrame["Icon"..i] = icon
    end

    function f.SkillFrame:HideItem(index)
        local icon = self["Icon"..index]

        if not icon then return end

        icon:Hide()
        icon.Name:Hide()
        icon.SubText:Hide()
        icon.Book:Hide()
    end

    function f.SkillFrame:DisplayItem(index, data)
        local icon = self["Icon"..index]
        if not icon then return end

        icon:DisplayItem(data)
    end

    GetSpellData()

    --Create Animations
    f.Texture.AnimGroup = f.Texture:CreateAnimationGroup()
    f.Texture.AnimGroup.Grow = f.Texture.AnimGroup:CreateAnimation("Scale")
    f.Texture.AnimGroup.Grow:SetScale(1, 0.001)
    f.Texture.AnimGroup.Grow:SetDuration(0)
    f.Texture.AnimGroup.Grow:SetStartDelay(0)
    f.Texture.AnimGroup.Grow:SetOrder(1)
    f.Texture.AnimGroup.Grow:SetOrigin("BOTTOM", 0, 0)

    f.Texture.AnimGroup.Grow2 = f.Texture.AnimGroup:CreateAnimation("Scale")
    f.Texture.AnimGroup.Grow2:SetScale(1, 1000)
    f.Texture.AnimGroup.Grow2:SetDuration(0.15)
    f.Texture.AnimGroup.Grow2:SetStartDelay(0.15)
    f.Texture.AnimGroup.Grow2:SetOrder(2)
    f.Texture.AnimGroup.Grow2:SetOrigin("BOTTOM", 0, 0)

    f.LineUp.AnimGroup = f.LineUp:CreateAnimationGroup()
    f.LineUp.AnimGroup.Grow = f.LineUp.AnimGroup:CreateAnimation("Scale")
    f.LineUp.AnimGroup.Grow:SetScale(0.001, 1)
    f.LineUp.AnimGroup.Grow:SetDuration(0)
    f.LineUp.AnimGroup.Grow:SetStartDelay(0.5)
    f.LineUp.AnimGroup.Grow:SetOrder(1)
    f.LineUp.AnimGroup.Grow:SetOrigin("BOTTOM", 0, 0)

    f.LineUp.AnimGroup.Grow2 = f.LineUp.AnimGroup:CreateAnimation("Scale")
    f.LineUp.AnimGroup.Grow2:SetScale(1000, 1)
    f.LineUp.AnimGroup.Grow2:SetDuration(0.5)
    f.LineUp.AnimGroup.Grow2:SetOrder(2)
    f.LineUp.AnimGroup.Grow2:SetOrigin("BOTTOM", 0, 0)

    f.LineDown.AnimGroup = f.LineDown:CreateAnimationGroup()
    f.LineDown.AnimGroup.Grow = f.LineDown.AnimGroup:CreateAnimation("Scale")
    f.LineDown.AnimGroup.Grow:SetScale(0.001, 1)
    f.LineDown.AnimGroup.Grow:SetDuration(0)
    f.LineDown.AnimGroup.Grow:SetStartDelay(1.5)
    f.LineDown.AnimGroup.Grow:SetOrder(1)
    f.LineDown.AnimGroup.Grow:SetOrigin("BOTTOM", 0, 0)

    f.LineDown.AnimGroup.Grow2 = f.LineDown.AnimGroup:CreateAnimation("Scale")
    f.LineDown.AnimGroup.Grow2:SetScale(1000, 1)
    f.LineDown.AnimGroup.Grow2:SetDuration(0.5)
    f.LineDown.AnimGroup.Grow2:SetOrder(2)
    f.LineDown.AnimGroup.Grow2:SetOrigin("BOTTOM", 0, 0)
    f.LineDown.AnimGroup.Grow2:SetScript("OnPlay", function()
        LU.Frame.Texture.AnimGroup:Play();
        LU.Frame.LineUp.AnimGroup:Play();
    end)

    f.LineDown.MoveAnimGroup = f.LineDown:CreateAnimationGroup()
    f.LineDown.MoveAnimGroup.Move = f.LineDown.MoveAnimGroup:CreateAnimation("Translation")
    f.LineDown.MoveAnimGroup.Move:SetDuration(0.5)
    f.LineDown.MoveAnimGroup.Move:SetOrder(1)
    f.LineDown.MoveAnimGroup.Move:SetEndDelay(2)
    f.LineDown.MoveAnimGroup.Move:SetSmoothing("IN_OUT")

    f.LineDown.MoveAnimGroup:SetScript("OnFinished", function() 
        LU.Frame.LineDown:SetPoint("BOTTOM", LU.Frame.Texture)
    end)

    f.LineDown.MoveAnimGroup:SetScript("OnStop", function() 
        LU.Frame.LineDown:SetPoint("BOTTOM", LU.Frame.Texture)
    end)

    f.Texture.MoveAnimGroup = f.Texture:CreateAnimationGroup()
    f.Texture.MoveAnimGroup.Scale = f.Texture.MoveAnimGroup:CreateAnimation("Scale")
    f.Texture.MoveAnimGroup.Scale:SetScale(1, 2)
    f.Texture.MoveAnimGroup.Scale:SetDuration(0.5)
    f.Texture.MoveAnimGroup.Scale:SetOrder(1)
    f.Texture.MoveAnimGroup.Scale:SetEndDelay(2)
    f.Texture.MoveAnimGroup.Scale:SetSmoothing("IN_OUT")
    f.Texture.MoveAnimGroup.Scale:SetOrigin("TOP", 0, 0)

    f.Texture.MoveAnimGroup:SetScript("OnFinished", function() 
        local _, ySize = LU.Frame.Texture.MoveAnimGroup.Scale:GetScale()
        LU.Frame.Texture:SetSize(284, 115 * ySize)
    end)

    f.Texture.MoveAnimGroup:SetScript("OnStop", function() 
        local _, ySize = LU.Frame.Texture.MoveAnimGroup.Scale:GetScale()
        LU.Frame.Texture:SetSize(284, 115 * ySize)
    end)

    f.Text.FadeOut = f.Text:CreateAnimationGroup()
    f.Text.FadeOut.Alpha = f.Text.FadeOut:CreateAnimation("Alpha")
    f.Text.FadeOut.Alpha:SetStartDelay(0)
    f.Text.FadeOut.Alpha:SetChange(1)
    f.Text.FadeOut.Alpha:SetDuration(0)
    f.Text.FadeOut.Alpha:SetOrder(1)

    f.Text.FadeOut.Alpha = f.Text.FadeOut:CreateAnimation("Alpha")
    f.Text.FadeOut.Alpha:SetStartDelay(3)
    f.Text.FadeOut.Alpha:SetChange(-1)
    f.Text.FadeOut.Alpha:SetDuration(0.5)
    f.Text.FadeOut.Alpha:SetOrder(2)

    f.ReachedText.FadeOut = f.ReachedText:CreateAnimationGroup()
    f.ReachedText.FadeOut.Alpha =
    f.ReachedText.FadeOut:CreateAnimation("Alpha")
    f.ReachedText.FadeOut.Alpha:SetStartDelay(0)
    f.ReachedText.FadeOut.Alpha:SetChange(1)
    f.ReachedText.FadeOut.Alpha:SetDuration(0)
    f.ReachedText.FadeOut.Alpha:SetOrder(1)
    f.ReachedText.FadeOut.Alpha:SetScript("OnPlay", function()
        LU.Frame.Text.FadeOut:Play()
    end)

    f.ReachedText.FadeOut.Alpha = f.ReachedText.FadeOut:CreateAnimation("Alpha")
    f.ReachedText.FadeOut.Alpha:SetStartDelay(3)
    f.ReachedText.FadeOut.Alpha:SetChange(-1)
    f.ReachedText.FadeOut.Alpha:SetDuration(0.5)
    f.ReachedText.FadeOut.Alpha:SetOrder(2)

    f.ReachedText.FadeOut:SetScript("OnFinished", function()
        LU.Frame.ReachedText:SetAlpha(0)
        LU.Frame.Text:SetAlpha(0)

        -- exit we just want to show the level up
        if not LU.DataInQueue or #LU.DataInQueue == 0 then
            LU.Frame.FadeOut:Play()
            return
        end

        LU.Frame.SkillFrame:Show()
        LU.Frame.SkillFrame.FadeIn:Play()
        -- -1 so we dont offset on a single item being shown
        local numVisible = -1
        for i = 1, 6 do
            if LU.Frame.SkillFrame["Icon"..i]:IsVisible() then
                numVisible = numVisible + 1
            end
        end
        -- 2.2 is a random ass number that seems to look nice rofl
        LU.Frame.Texture.MoveAnimGroup.Scale:SetScale(1, ((numVisible / 2.2)) + 1)
        LU.Frame.Texture.MoveAnimGroup:Play()
        LU.Frame.LineDown.MoveAnimGroup.Move:SetOffset(0, (-numVisible * 36) + (numVisible * 2))
        LU.Frame.LineDown.MoveAnimGroup:Play()
    end)

    f.FadeIn = f:CreateAnimationGroup()
    f.FadeIn.Alpha = f.FadeIn:CreateAnimation("Alpha")
    f.FadeIn.Alpha:SetChange(-1)
    f.FadeIn.Alpha:SetStartDelay(1.5)
    f.FadeIn.Alpha:SetDuration(0)
    f.FadeIn.Alpha:SetOrder(1)
    f.FadeIn.Alpha:SetScript("OnPlay", function()
        UIScaleSolveConflict()
        local f = LU.Frame
        f.Texture:SetSize(284, 115)
        f.Texture.MoveAnimGroup.Scale:Stop()
        f.LineDown.AnimGroup:Play()
        f.ReachedText.FadeOut:Play()
        f.SkillFrame:Hide()
    end)

    f.FadeIn.Alpha = f.FadeIn:CreateAnimation("Alpha")
    f.FadeIn.Alpha:SetChange(1)
    f.FadeIn.Alpha:SetDuration(0.5)
    f.FadeIn.Alpha:SetOrder(2)

    f.FadeOut = f:CreateAnimationGroup()
    f.FadeOut.Alpha = f.FadeOut:CreateAnimation("Alpha")
    f.FadeOut.Alpha:SetChange(-1)
    f.FadeOut.Alpha:SetDuration(0.5)
    f.FadeOut.Alpha:SetOrder(1)
    f.FadeOut.Alpha:SetScript("OnFinished", function()
        LU.Frame:Hide()
    end)

    f.SkillFrame.FadeIn = f.SkillFrame:CreateAnimationGroup()
    f.SkillFrame.Alpha = f.SkillFrame.FadeIn:CreateAnimation("Alpha")
    f.SkillFrame.Alpha:SetChange(-1)
    f.SkillFrame.Alpha:SetStartDelay(0.5)
    f.SkillFrame.Alpha:SetDuration(0)
    f.SkillFrame.Alpha:SetOrder(1)

    f.SkillFrame.Alpha = f.SkillFrame.FadeIn:CreateAnimation("Alpha")
    f.SkillFrame.Alpha:SetChange(1)
    f.SkillFrame.Alpha:SetStartDelay(0)
    f.SkillFrame.Alpha:SetDuration(0.5)
    f.SkillFrame.Alpha:SetEndDelay(3)
    f.SkillFrame.Alpha:SetOrder(2)

    f.SkillFrame.FadeOut = f.SkillFrame:CreateAnimationGroup()
    f.SkillFrame.Alpha = f.SkillFrame.FadeOut:CreateAnimation("Alpha")
    f.SkillFrame.Alpha:SetChange(-1)
    f.SkillFrame.Alpha:SetStartDelay(2)
    f.SkillFrame.Alpha:SetDuration(0.5)
    f.SkillFrame.Alpha:SetOrder(1)

    f.SkillFrame.FadeOut:SetScript("OnFinished", function()
        for i = 1, 6 do
            LU.Frame.SkillFrame:HideItem(i)
        end
        if #LU.DataInQueue > 0 then
            LU.Frame.SkillFrame.FadeIn:Play()
        else
            LU.Frame.FadeOut:Play()
        end
    end)

    f.SkillFrame.FadeIn:SetScript("OnPlay", function()
        if #LU.DataInQueue > 0 then
            DisplayData(LU.DataInQueue)
        else
            LU.Frame.SkillFrame:StopAnimating()
            LU.Frame.FadeOut:Play()
        end
    end)
    f.SkillFrame.FadeIn:SetScript("OnFinished", function()
        LU.Frame.SkillFrame.FadeOut:Play()
    end)

    LU.Frame = f
    return f
end

function LU.OnLevelUp(level)
    if not LU.Frame then
        CreateLevelUpFrame()
    end
    LU.Stop()
    LU.level = level
    LU.Frame:Show()
    LU.DataInQueue = GenerateLevelUpData()
    LU.Frame.FadeIn:Play()
    LU.Frame.Text:SetText("Level "..level)
end

function LU.Stop()
    LU.DataInQueue = {}
    local f = LU.Frame
    for i = 1, 6 do 
        f.SkillFrame:HideItem(i)
    end
    f.Texture.AnimGroup:Stop()
    f.LineUp.AnimGroup:Stop()
    f.LineDown.AnimGroup:Stop()
    f.Texture.MoveAnimGroup:Stop()
    f.Text.FadeOut:Stop()
    f.ReachedText.FadeOut:Stop()
    f.FadeIn:Stop()
    f.FadeOut:Stop()
    f.SkillFrame.FadeIn:Stop()
    f.SkillFrame.FadeOut:Stop()
    if f:IsVisible() then 
        f:Hide()
    end
end

local listener = CreateFrame("Frame")
listener:RegisterEvent("PLAYER_LEVEL_UP")
listener:RegisterEvent("PLAYER_ENTERING_WORLD")

local function waitToCache(self)
    -- wait for CAO_Known to be populated then check if we're even in random mode before caching stuff
    if not CAO_Known then
        return
    end

    if IsRandomMode() then
        LU.KnownSpells = {}
        for id, known in pairs(CAO_Known) do
            LU.KnownSpells[id] = known
        end
    end

    self:SetScript("OnUpdate", nil)
end

listener:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LEVEL_UP" then
        LU.OnLevelUp(select(1, ...))
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- lets try and cache our known spells for random mode
        if not CAO_Known then
            self:SetScript("OnUpdate", waitToCache)
        end
    end
end)