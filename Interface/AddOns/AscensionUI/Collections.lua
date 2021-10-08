local Addon = select(2, ...)

local C = CreateFrame("FRAME", "Collections", UIParent, nil)
Addon.Collections = C
tinsert(UISpecialFrames, C:GetName())

C.Tab_Info = {
    { -- 1
        id = 1,
        text = "Avancement\ndu personnage",
        width = 148,
        icon = "Interface\\AddOns\\AwAddons\\Textures\\Misc\\spell_Paladin_divinecircle",
        tooltip = {
            "|cffFFFFFFAvancement du personnage|r",
            "Choisissez des capacités et des talents pour créer votre propre classe ou consultez celles créées par d'autres joueurs!"
        },
        isSeparate = true,
        GetFrame = function() return CA2 end
    },
    { -- 2
        id = 2,
        text = "Les Archétypes",
        width = 148,
        icon = "Interface\\Icons\\ability_priest_angelicfeather",
        tooltip = {
            "|cffFFFFFFLes Archétypes|r",
            "Consultez la liste des Builds les plus populaires, créez le vôtre et partagez-le avec vos amis!"
        },
        isSeparate = true,
        GetFrame = function() return BuildCreator end
    },
    { -- 3
        id = 3,
        text = "Cosmétique",
        width = 128,
        icon = "Interface\\icons\\INV_Chest_Awakening",
        tooltip = {
            "|cffFFFFFFCollection des cosmétiques|r",
            "Récupérez des objets de la boutique de Ascension directement dans votre inventaire n'importe où, n'importe quand."
        },
        isSeparate = false,
        GetFrame = function() return Addon.Store end
    },
    { -- 4
        id = 4,
        text = "Enchants",
        width = 128,
        icon = "Interface\\icons\\inv_custom_ReforgeToken",
        tooltip = {
            "|cffFFFFFFCollection d'enchantements aléatoires|r",
            "Remplissez votre collection d'enchantements puissants qui apporteront encore plus de puissance à votre personnage."
        },
        isSeparate = false,
        GetFrame = function() return Addon.MysticEnchant end
    },
    { -- 5
        id = 5,
        text = "Saison",
        width = 128,
        icon = "Interface\\icons\\season1_complete",
        tooltip = {
            "|cffFFFFFFCollection saisonnière|r",
            "Découvrez les dernières fonctionnalités saisonnières et recevez des récompenses exclusives!"
        },
        isSeparate = false,
        GetFrame = function() return Addon.SeasonalCollection end
    },
    { -- 6
        id = 6,
        text = "Clés mythiques",
        width = 158,
        icon = "Interface\\Icons\\inv_relics_hourglass",
        tooltip = {
            "|cFFFFFFFFClés mythiques|r",
            "Voir votre progression de votre clé MM+"
        },
        isSeparate = true,
        GetFrame = function() return Addon.MythicKeystone.KeystoneInfo end
    }
}

local Tabs = {}

C:SetFrameStrata("DIALOG")
C:SetSize(784, 512)
C:SetPoint("CENTER", 0, 30)
C:SetBackdrop({
    bgFile = "Interface\\AddOns\\AwAddons\\Textures\\Collections\\StoreCollection",
    insets = {left = -120, right = -120, top = -256, bottom = -256}
})
C:SetClampedToScreen(true)
C:SetMovable(true)
C:EnableMouse(true)
C:RegisterForDrag("LeftButton")
C:SetScript("OnDragStart", C.StartMoving)
C:SetScript("OnDragStop", C.StopMovingOrSizing)

function C:DisableTab(id)
    for _, t in ipairs(Tabs) do 
        if (t.id == id) then
            t:EnableMouse(false)
            t:SetNormalFontObject(GameFontDisableSmall)
            print("..")
        end
    end
end

function C:CreateTab(info, parent)
    local tab = CreateFrame("CheckButton", nil, parent) -- WIP. we better have frame names, otherwise its impossible to use read from external
    tab:SetSize(info.width, 32)
    tab.id = info.id
    tab.isSeparate = info.isSeparate

    tab:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
    tab:GetHighlightTexture():SetPoint("TOPLEFT", 3, 5, "BOTTOMRIGHT", -3, 0)
    tab:SetDisabledTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
    tab:SetPoint("LEFT", parent, "RIGHT", -16, 0)

    tab:SetNormalFontObject(GameFontNormalSmall)
    tab:SetHighlightFontObject(GameFontHighlightSmall)
    tab:SetDisabledFontObject(GameFontHighlightSmall)
    tab:SetText(info.text)
    tab:GetFontString():SetPoint("CENTER", 0, 4)

    tab.BG = tab:CreateTexture(nil, "BACKGROUND")
    tab.BG:SetTexture("Interface\\PaperDollInfoFrame\\UI-CHARACTER-INACTIVETAB")
    tab.BG:SetAllPoints()

    tab.Icon = tab:CreateTexture(nil, "OVERLAY")
    tab.Icon:SetSize(16, 16)
    tab.Icon:SetTexture(info.icon)
    tab.Icon:SetPoint("LEFT", 19, 3)
    SetPortraitToTexture(tab.Icon, info.icon)

    tab:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        for _, line in ipairs(info.tooltip) do
            GameTooltip:AddLine(line)
        end
        GameTooltip:Show()
    end)

    tab:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    tab:SetScript("OnClick", function(self)
        for _, t in ipairs(Tabs) do 
            t:SetChecked(false)
            local f = t:GetFrame()
            if f then
                HideUIPanel(f)
            end
            if t.id == self.id then
                t:Disable()
            else
                t:Enable()
            end
        end

        PlaySound("igMainMenuOpen")
        local f = self:GetFrame()
        if f then
            if self.isSeparate then
                HideUIPanel(C)
            else
                ShowUIPanel(C)
            end
            ShowUIPanel(f)
        end
    end)

    if info.disabled then
        tab:EnableMouse(false)
        tab:SetNormalFontObject(GameFontDisableSmall)
    end

    tab.GetFrame = info.GetFrame
    return tab
end

C:SetScript("OnShow", function()
    -- CA2 isn't loaded yet
    if not CA2 then C:Hide()
        SendSystemMessage("En attente de l'initialisation de l'interface utilisateur. Réessayez bientôt.")
        return 
    end

    HideCards()
end)

-- Generate Tabs
function CreateTabs(globalParent)
    for i, info in ipairs(C.Tab_Info) do
        local parent = nil
        if i == 1 then
            parent = globalParent
        else
            parent = globalParent["Tab"..i-1]
        end
        local tab = C:CreateTab(info, parent)

        if i == 1 then
            tab:ClearAllPoints()
            tab:SetPoint("BOTTOMLEFT", 20, -22)
        end
        tinsert(Tabs, tab)
        globalParent["Tab"..i] = tab
    end
end

CreateTabs(C)
C:Hide()
--[[
C.CharacterAdvancementTab = CreateFrame("CheckButton", nil, C, nil)
C.CharacterAdvancementTab:SetSize(148, 32)
C.CharacterAdvancementTab:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
C.CharacterAdvancementTab:GetHighlightTexture():SetPoint("TOPLEFT", 3, 5, "BOTTOMRIGHT", -3, 0)
C.CharacterAdvancementTab:SetDisabledTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
C.CharacterAdvancementTab:SetPoint("BOTTOMLEFT", 20, -22)
C.CharacterAdvancementTab:SetNormalFontObject(GameFontNormalSmall)
C.CharacterAdvancementTab:SetHighlightFontObject(GameFontHighlightSmall)
C.CharacterAdvancementTab:SetDisabledFontObject(GameFontHighlightSmall)
C.CharacterAdvancementTab:SetText("Character\nAdvancement")
C.CharacterAdvancementTab:GetFontString():SetPoint("CENTER", 0, 4)
C.CharacterAdvancementTab.BG = C.CharacterAdvancementTab:CreateTexture(nil, "BACKGROUND")
C.CharacterAdvancementTab.BG:SetTexture("Interface\\PaperDollInfoFrame\\UI-CHARACTER-INACTIVETAB")
C.CharacterAdvancementTab.BG:SetAllPoints()
C.CharacterAdvancementTab.Icon = C.CharacterAdvancementTab:CreateTexture(nil, "OVERLAY")
C.CharacterAdvancementTab.Icon:SetSize(16, 16)
C.CharacterAdvancementTab.Icon:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Misc\\spell_Paladin_divinecircle")
C.CharacterAdvancementTab.Icon:SetPoint("LEFT", 19, 3)
SetPortraitToTexture(C.CharacterAdvancementTab.Icon, "Interface\\AddOns\\AwAddons\\Textures\\Misc\\spell_Paladin_divinecircle")

C.HeroArchitectTab = CreateFrame("CheckButton", nil, C, nil)
C.HeroArchitectTab:SetSize(148, 32)
C.HeroArchitectTab:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
C.HeroArchitectTab:GetHighlightTexture():SetPoint("TOPLEFT", 3, 5, "BOTTOMRIGHT", -3, 0)
C.HeroArchitectTab:SetDisabledTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
C.HeroArchitectTab:SetPoint("LEFT", C.CharacterAdvancementTab, "RIGHT", -16, 0)
C.HeroArchitectTab:SetNormalFontObject(GameFontNormalSmall)
C.HeroArchitectTab:SetHighlightFontObject(GameFontHighlightSmall)
C.HeroArchitectTab:SetDisabledFontObject(GameFontHighlightSmall)
C.HeroArchitectTab:SetText("Les Archétypes")
C.HeroArchitectTab:GetFontString():SetPoint("CENTER", 0, 4)
C.HeroArchitectTab:Enable()
C.HeroArchitectTab:EnableMouse(false)
C.HeroArchitectTab:SetNormalFontObject(GameFontDisableSmall)
C.HeroArchitectTab.BG = C.HeroArchitectTab:CreateTexture(nil, "BACKGROUND")
C.HeroArchitectTab.BG:SetTexture("Interface\\PaperDollInfoFrame\\UI-CHARACTER-INACTIVETAB")
C.HeroArchitectTab.BG:SetSize(148, 31)
C.HeroArchitectTab.BG:SetPoint("CENTER", 0, 0)
C.HeroArchitectTab.Icon = C.HeroArchitectTab:CreateTexture(nil, "OVERLAY")
C.HeroArchitectTab.Icon:SetSize(16, 16)
C.HeroArchitectTab.Icon:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Misc\\spell_Paladin_divinecircle")
C.HeroArchitectTab.Icon:SetPoint("LEFT", 19, 3)
SetPortraitToTexture(C.HeroArchitectTab.Icon, "Interface\\AddOns\\AwAddons\\Textures\\Misc\\spell_Paladin_divinecircle")

C.VanityStoreTab = CreateFrame("CheckButton", nil, C, nil)
C.VanityStoreTab:SetSize(128, 32)
C.VanityStoreTab:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
C.VanityStoreTab:GetHighlightTexture():SetPoint("TOPLEFT", 3, 5, "BOTTOMRIGHT", -3, 0)
C.VanityStoreTab:SetDisabledTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
C.VanityStoreTab:SetPoint("LEFT", C.HeroArchitectTab, "RIGHT", -16, 0)
C.VanityStoreTab:SetNormalFontObject(GameFontNormalSmall)
C.VanityStoreTab:SetHighlightFontObject(GameFontHighlightSmall)
C.VanityStoreTab:SetDisabledFontObject(GameFontHighlightSmall)
C.VanityStoreTab:SetText("Vanity")
C.VanityStoreTab:GetFontString():SetPoint("CENTER", 0, 2)
C.VanityStoreTab.BG = C.VanityStoreTab:CreateTexture(nil, "BACKGROUND")
C.VanityStoreTab.BG:SetTexture("Interface\\PaperDollInfoFrame\\UI-CHARACTER-INACTIVETAB")
C.VanityStoreTab.BG:SetSize(128, 31)
C.VanityStoreTab.BG:SetPoint("CENTER", 0, 0)
C.VanityStoreTab.Icon = C.VanityStoreTab:CreateTexture(nil, "OVERLAY")
C.VanityStoreTab.Icon:SetSize(16, 16)
C.VanityStoreTab.Icon:SetTexture("Interface\\icons\\INV_Chest_Awakening")
C.VanityStoreTab.Icon:SetPoint("LEFT", 19, 3)
SetPortraitToTexture(C.VanityStoreTab.Icon, "Interface\\icons\\INV_Chest_Awakening")

C.MysticEnchantTab = CreateFrame("CheckButton", nil, C, nil)
C.MysticEnchantTab:SetSize(128, 32)
C.MysticEnchantTab:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
C.MysticEnchantTab:GetHighlightTexture():SetPoint("TOPLEFT", 3, 5, "BOTTOMRIGHT", -3, 0)
C.MysticEnchantTab:SetDisabledTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
C.MysticEnchantTab:SetPoint("LEFT", C.VanityStoreTab, "RIGHT", -16, 0)
C.MysticEnchantTab:SetNormalFontObject(GameFontNormalSmall)
C.MysticEnchantTab:SetHighlightFontObject(GameFontHighlightSmall)
C.MysticEnchantTab:SetDisabledFontObject(GameFontHighlightSmall)
C.MysticEnchantTab:SetText("Enchants")
C.MysticEnchantTab:GetFontString():SetPoint("CENTER", 0, 2)
C.MysticEnchantTab.BG =C.MysticEnchantTab:CreateTexture(nil, "BACKGROUND")
C.MysticEnchantTab.BG:SetTexture("Interface\\PaperDollInfoFrame\\UI-CHARACTER-INACTIVETAB")
C.MysticEnchantTab.BG:SetSize(128, 31)
C.MysticEnchantTab.BG:SetPoint("CENTER", 0, 0)
C.MysticEnchantTab.Icon = C.MysticEnchantTab:CreateTexture(nil, "OVERLAY")
C.MysticEnchantTab.Icon:SetSize(16, 16)
C.MysticEnchantTab.Icon:SetTexture("Interface\\icons\\inv_custom_ReforgeToken")
C.MysticEnchantTab.Icon:SetPoint("LEFT", 19, 3)
SetPortraitToTexture(C.MysticEnchantTab.Icon, "Interface\\icons\\inv_custom_ReforgeToken")

C.SeasonalCollectionTab = CreateFrame("CheckButton", nil, C, nil)
C.SeasonalCollectionTab:SetSize(128, 32)
C.SeasonalCollectionTab:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
C.SeasonalCollectionTab:GetHighlightTexture():SetPoint("TOPLEFT", 3, 5, "BOTTOMRIGHT", -3, 0)
C.SeasonalCollectionTab:SetDisabledTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
C.SeasonalCollectionTab:SetPoint("LEFT", C.MysticEnchantTab, "RIGHT", -16, 0)
C.SeasonalCollectionTab:SetNormalFontObject(GameFontNormalSmall)
C.SeasonalCollectionTab:SetHighlightFontObject(GameFontHighlightSmall)
C.SeasonalCollectionTab:SetDisabledFontObject(GameFontHighlightSmall)
C.SeasonalCollectionTab:SetText("Seasonal")
C.SeasonalCollectionTab:GetFontString():SetPoint("CENTER", 0, 2)
C.SeasonalCollectionTab.BG = C.SeasonalCollectionTab:CreateTexture(nil, "BACKGROUND")
C.SeasonalCollectionTab.BG:SetTexture("Interface\\PaperDollInfoFrame\\UI-CHARACTER-INACTIVETAB")
C.SeasonalCollectionTab.BG:SetSize(128, 31)
C.SeasonalCollectionTab.BG:SetPoint("CENTER", 0, 0)
C.SeasonalCollectionTab.Icon = C.SeasonalCollectionTab:CreateTexture(nil, "OVERLAY")
C.SeasonalCollectionTab.Icon:SetSize(16, 16)
C.SeasonalCollectionTab.Icon:SetTexture("Interface\\icons\\INV_Chest_Awakening")
C.SeasonalCollectionTab.Icon:SetPoint("LEFT", 19, 3)
SetPortraitToTexture(C.SeasonalCollectionTab.Icon, "Interface\\icons\\season1_complete")


C.MythicKeystoneTab = CreateFrame("CheckButton", nil, C, nil)
C.MythicKeystoneTab:SetSize(148, 32)
C.MythicKeystoneTab:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
C.MythicKeystoneTab:GetHighlightTexture():SetPoint("TOPLEFT", 3, 5, "BOTTOMRIGHT", -3, 0)
C.MythicKeystoneTab:SetDisabledTexture("Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab")
C.MythicKeystoneTab:SetPoint("LEFT", C.MysticEnchantTab, "RIGHT", -16, 0)
C.MythicKeystoneTab:SetNormalFontObject(GameFontNormalSmall)
C.MythicKeystoneTab:SetHighlightFontObject(GameFontHighlightSmall)
C.MythicKeystoneTab:SetDisabledFontObject(GameFontHighlightSmall)
C.MythicKeystoneTab:SetText("Mythic Keystones")
C.MythicKeystoneTab:GetFontString():SetPoint("CENTER", 0, 2)
C.MythicKeystoneTab.BG = C.MythicKeystoneTab:CreateTexture(nil, "BACKGROUND")
C.MythicKeystoneTab.BG:SetTexture("Interface\\PaperDollInfoFrame\\UI-CHARACTER-INACTIVETAB")
C.MythicKeystoneTab.BG:SetSize(148, 31)
C.MythicKeystoneTab.BG:SetPoint("CENTER", 0, 0)
C.MythicKeystoneTab.Icon = C.MythicKeystoneTab:CreateTexture(nil, "OVERLAY")
C.MythicKeystoneTab.Icon:SetSize(16, 16)
C.MythicKeystoneTab.Icon:SetTexture("Interface\\icons\\INV_Chest_Awakening")
C.MythicKeystoneTab.Icon:SetPoint("LEFT", 20, 3)
SetPortraitToTexture(C.MythicKeystoneTab.Icon, "Interface\\Icons\\inv_relics_hourglass")
--]]

--[[

C.SeasonalCollectionTab:Hide()

C.MysticEnchantTab:SetScript("OnClick", function(self)
    PlaySound("igMainMenuOpen")
    HideUIPanel(BuildCreator)
    HideUIPanel(CA2)
    ShowUIPanel(C)
    Addon.Store:Hide()
    if SeasonalCollectionFrame then
        SeasonalCollectionFrame:Hide()
    end
    AscensionUI.MysticEnchant:Show()
    C.CharacterAdvancementTab:SetChecked(false)
    C.VanityStoreTab:SetChecked(false)
    C.SeasonalCollectionTab:SetChecked(false)
    C.HeroArchitectTab:SetChecked(false)
    C.CharacterAdvancementTab:Enable()
    C.HeroArchitectTab:Enable()
    C.VanityStoreTab:Enable()
    C.SeasonalCollectionTab:Enable()
    self:Disable()
end)

C.CharacterAdvancementTab:SetScript("OnClick", function(self)
    PlaySound("igMainMenuOpen")
    HideUIPanel(C)
    HideUIPanel(BuildCreator)
    ShowUIPanel(CA2)
    self:Disable()
end)

C.HeroArchitectTab:SetScript("OnClick", function(self)
    PlaySound("igMainMenuOpen")
    HideUIPanel(C)
    HideUIPanel(CA2)
    ShowUIPanel(BuildCreator)
    self:Disable()
end)

C.VanityStoreTab:SetScript("OnClick", function(self)
    PlaySound("igMainMenuOpen")
    HideUIPanel(CA2)
    HideUIPanel(BuildCreator)
    ShowUIPanel(C)
    Addon.MysticEnchant:Hide()
    if SeasonalCollectionFrame then
        SeasonalCollectionFrame:Hide()
    end
    Addon.Store:Show()
    C.MysticEnchantTab:SetChecked(false)
    C.CharacterAdvancementTab:SetChecked(false)
    C.SeasonalCollectionTab:SetChecked(false)
    C.HeroArchitectTab:SetChecked(false)
    C.MysticEnchantTab:Enable()
    C.CharacterAdvancementTab:Enable()
    C.SeasonalCollectionTab:Enable()
    C.HeroArchitectTab:Enable()
    self:Disable()
end)

C.SeasonalCollectionTab:SetScript("OnClick", function(self)
    PlaySound("igMainMenuOpen")
    HideUIPanel(CA2)
    HideUIPanel(BuildCreator)
    ShowUIPanel(C)
    Addon.MysticEnchant:Hide()
    Addon.Store:Hide()
    SeasonalCollectionFrame:Show()
    C.MysticEnchantTab:SetChecked(false)
    C.CharacterAdvancementTab:SetChecked(false)
    C.SeasonalCollectionTab:SetChecked(false)
    C.HeroArchitectTab:SetChecked(false)
    C.MysticEnchantTab:Enable()
    C.CharacterAdvancementTab:Enable()
    C.VanityStoreTab:Enable()
    C.HeroArchitectTab:Enable()
    self:Disable()
end)
--]]
--[[
C.MysticEnchantTab:SetScript("OnEnter", function(self) 
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("|cffFFFFFFCollection of Random Enchants|r")
    GameTooltip:AddLine("Fill your collection by powerfull enchants which will bring even more power to your character.")
    GameTooltip:Show()
end)

C.CharacterAdvancementTab:SetScript("OnEnter", function(self) 
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("|cffFFFFFFCharacter Advancement|r")
    GameTooltip:AddLine("Choose abilities and talents for your own class fantasy or check out a list of existing builds created by other players!")
    GameTooltip:Show()
end)

C.VanityStoreTab:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("|cffFFFFFFCollection of Vanity Items|r")
    GameTooltip:AddLine("Deliver items from the Ascension store directly to your inventory anywhere, anytime.")
    GameTooltip:Show()
end)

C.SeasonalCollectionTab:SetScript("OnEnter", function(self) 
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("|cffFFFFFFSeasonal Collection|r")
    GameTooltip:AddLine("Check out latest seasonal features and recieve exclusive rewards!")
    GameTooltip:Show()
end)

C.HeroArchitectTab:SetScript("OnEnter", function(self) 
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("|cffFFFFFFBuild Creator|r")
    GameTooltip:AddLine("WIP Very very WIP!")
    GameTooltip:Show()
end)

C.MysticEnchantTab:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
C.CharacterAdvancementTab:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
C.VanityStoreTab:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
C.SeasonalCollectionTab:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
C.HeroArchitectTab:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
--]]

-- TODO: COMPATABILITY. FIX LATER PROBABLY
CollectionController = C
CollectionController.CollectionControllerTab1 = C.Tab4
CollectionController.CollectionControllerTab2 = C.Tab1
CollectionController.CollectionControllerTab3 = C.Tab3
CollectionController.CollectionControllerTab4 = C.Tab5
CollectionController.CollectionControllerTab5 = C.Tab2
