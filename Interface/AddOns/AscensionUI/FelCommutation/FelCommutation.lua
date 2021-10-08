local Addon = select(2, ...)
local FelComm = CreateFrame("FRAME", "FelComm", UIParent, nil)
Addon.FelCommutation = FelComm

-- close when pressing esc
tinsert(UISpecialFrames, FelComm:GetName())


-- Settings
local SAFE_TO_REMOVE_TEXT = "This item doesn't \ndrop on death. You can remove\nFel Commutation from it"
local SAVE_COST_TEXT = "Insuring this item\ncould cost you|r\n|cffFFFFFF %d|TInterface\\MONEYFRAME\\UI-GoldIcon.blp:11:11:0:-1|t %d|TInterface\\MONEYFRAME\\UI-SilverIcon.blp:11:11:0:-1|t %d|TInterface\\MONEYFRAME\\UI-CopperIcon.blp:11:11:0:-1|t|r\neach death"
local UNINSURE_SLOT_COST_TEXT = "this item\ncould cost you|r\n|cffFFFFFF %d|TInterface\\MONEYFRAME\\UI-GoldIcon.blp:11:11:0:-1|t %d|TInterface\\MONEYFRAME\\UI-SilverIcon.blp:11:11:0:-1|t %d|TInterface\\MONEYFRAME\\UI-CopperIcon.blp:11:11:0:-1|t|r\neach death"
local SAVE_EMPTY_SLOT_TEXT = "Equip an Item.\nThis saves it\nwhen you die."
local SLOT_IS_DISABLED_TEXT = "This item doesn't \ndrop on death."
local SAVE_EMPTY_SLOT = "Insuring this slot\nwill protect any item\nequipped in it"

local INSURED_TOOLTIP_LEFT_TEXT = "|cffFFFFFFPotential drop cost:\n%d |TInterface\\MONEYFRAME\\UI-GoldIcon.blp:11:11:0:-1|t %d|TInterface\\MONEYFRAME\\UI-SilverIcon.blp:11:11:0:-1|t %d|TInterface\\MONEYFRAME\\UI-CopperIcon.blp:11:11:0:-1|t|r"
local INSURED_TOOLTIP_RIGHT_TEXT = "|cffFFFFFFEach death|r"

local SafeSlots_MaxLevel_MinCost = 100000
local OneHandedWeapons = {
    ["Weapon"] = {
        ["One-Handed Axes"] = true, -- 1h axe
        ["One-Handed Maces"] = true, -- 1h mace
        ["One-Handed Swords"] = true, -- 1h sword
        ["Fist Weapons"] = true, -- fist weapon
        ["Miscellaneous"] = true, -- (Blacksmith Hammer, Mining Pick, etc.)
        ["Daggers"] = true, -- dagger
    },

    ["Armor"] = {
        ["Shields"] = true,
        ["Librams"] = true,
        ["Idols"] = true,
        ["Totems"] = true,
        ["Sigils"] = true,
    },
}

local QualityModifiers = { -- [quality] = modifier, DropCost = DropCost*modifier
    [5] = 1.5,
    [4] = 1.5,
    [3] = 1,
    [2] = 0.8,
    ["default"] = 1,
}

local OneHandedWeapons_CostModifier = 0.5

local function CalculateItemFelCommutationCost(itemLink)
    local _, _, itemQuality, itemLevel, _, itemType, itemSubType, _, _, texture = GetItemInfo(itemLink)
    -- bug when loading in GetItemInfo returns nothing
    if not itemLevel then return 0 end

    local DropCostModifier = 1770
    local Is1H = false
    local DropCost = 0

    if (OneHandedWeapons[itemType] and OneHandedWeapons[itemType][itemSubType]) then
        Is1H = true
    end

    if (itemLevel <= 25) then
        DropCostModifier = 56
    elseif (itemLevel >= 26 and itemLevel <= 35) then
        DropCostModifier = 170
    elseif (itemLevel >= 36 and itemLevel <= 45) then
        DropCostModifier = 512
    elseif (itemLevel >= 46 and itemLevel <= 54) then
        if itemType == "Weapon" then
            if (Is1H) then
                DropCostModifier = 1446 * OneHandedWeapons_CostModifier
            else
                DropCostModifier = 1446
            end
        else
            DropCostModifier = 723
        end
    elseif (itemLevel >= 55 and itemLevel <= 62) then
        if itemType == "Weapon" then
            if (Is1H) then
                DropCostModifier = 5000 * OneHandedWeapons_CostModifier
            else
                DropCostModifier = 5000
            end
        else
            DropCostModifier = 2500
        end
        -- 60-67 leveling
    elseif (itemLevel >= 63 and itemLevel <= 105) then
        if itemType == "Weapon" then
            if (Is1H) then
                DropCostModifier = 6000 * OneHandedWeapons_CostModifier
            else
                DropCostModifier = 6000
            end
        else
            DropCostModifier = 3000
        end
        -- 68-70 leveling plus some 70 §dungeon gear
    elseif (itemLevel >= 106 and itemLevel <= 114) then
        if itemType == "Weapon" then
            if (Is1H) then
                DropCostModifier = 8000 * OneHandedWeapons_CostModifier
            else
                DropCostModifier = 8000
            end
        else
            DropCostModifier = 4000
        end
        -- Tier 4 gear (and the best 70 dungeon gear)
    elseif (itemLevel >= 115 and itemLevel <= 123) then
        if itemType == "Weapon" then
            if (Is1H) then
                DropCostModifier = 10000 * OneHandedWeapons_CostModifier
            else
                DropCostModifier = 10000
            end
        else
            DropCostModifier = 5000
        end
        -- Tier 5 gear and above
    elseif (itemLevel >= 124) then
        if itemType == "Weapon" then
            if (Is1H) then
                DropCostModifier = 11000 * OneHandedWeapons_CostModifier
            else
                DropCostModifier = 11000
            end
        else
            DropCostModifier = 5500
        end
    end

    DropCost = itemLevel * DropCostModifier -- Temporary was 2285

    if (UnitLevel("player") == 60) then
        DropCost = SafeSlots_MaxLevel_MinCost + math.floor(DropCost/2)
    else
        DropCost = math.floor(DropCost/2)
    end

    if (QualityModifiers[itemQuality]) then
        DropCost = DropCost*QualityModifiers[itemQuality]
    else
        DropCost = DropCost*QualityModifiers["default"]
    end

    return math.floor(DropCost)
end

--local C_BloodiedItemList = {}
local DISABLED_SLOTS = {
    [19] = true,
    [4] = true
}
local SlotsData = {
    [1] = {"Head"},
    [2] = {"Neck"},
    [3] = {"Shoulders"},
    [4] = {"Shirt"},
    [5] = {"Chest"},
    [6] = {"Waist"},
    [7] = {"Legs"},
    [8] = {"Feet"},
    [9] = {"Wrist"},
    [10] = {"Hands"},
    [11] = {"Finger"},
    [12] = {"Finger"},
    [13] = {"Trinket"},
    [14] = {"Trinket"},
    [15] = {"Back"},
    [16] = {"Main Hand"},
    [17] = {"Off Hand"},
    [18] = {"Ranged"},
    [19] = {"Tabard"},
}

local IsSlotInsuranced = {}

local function GetMaxPotentialGearDropCount()
    if UnitAura("player", "Outlaw") then
        return 3
    end

    return 2
end

local function CalculateMaxPotentialCost()
    local costs = {}
    for i = 1, 19 do
        local link = GetInventoryItemLink("player", i)
        if link ~= nil and IsSlotInsuranced[i] then
            costs[i] = CalculateItemFelCommutationCost(GetInventoryItemLink("player", i))
        else
            costs[i] = 0
        end
    end

    -- @robinsch: sort descending
    table.sort(costs, function(a, b) return a > b end)

    local totalCost = 0
    local dropCount = GetMaxPotentialGearDropCount()
    for i = 1, dropCount do
        totalCost = totalCost + costs[i]
    end

    --TODO: when the char frame new part stuff is remade change this part
    -- check we have loaded new char frame stuff 
    if not CharFrameNewPart then return end

    if (totalCost > 0) then
        local gold, silver, copper = GetGoldForMoney(totalCost)
        CharFrameNewPart.Frame2:Show()
        FelComm.CostText:Show()
        FelComm.CostText:SetText("Maximum Gold Lost on Death (High-Risk)\n|cffFFFFFF"..gold.." |TInterface\\MONEYFRAME\\UI-GoldIcon.blp:11:11:0:-1|t "..silver.."|TInterface\\MONEYFRAME\\UI-SilverIcon.blp:11:11:0:-1|t "..copper.."|TInterface\\MONEYFRAME\\UI-CopperIcon.blp:11:11:0:-1|t|r each death")
        --PaperDoll_CostText:SetText("Maximum gold\nlost on death |cffFFFFFF"..gold.." |TInterface\\MONEYFRAME\\UI-GoldIcon.blp:11:11:0:-1|t "..silver.."|TInterface\\MONEYFRAME\\UI-SilverIcon.blp:11:11:0:-1|t "..copper.."|TInterface\\MONEYFRAME\\UI-CopperIcon.blp:11:11:0:-1|t|r each death")
        CharFrameNewPart.Frame2.TextFrame2.Text_R:SetText(gold.." |TInterface\\MONEYFRAME\\UI-GoldIcon.blp:16:16:0:-1|t "..silver.." |TInterface\\MONEYFRAME\\UI-SilverIcon.blp:16:16:0:-1|t "..copper.." |TInterface\\MONEYFRAME\\UI-CopperIcon.blp:16:16:0:-1|t")
        CharFrameNewPart.Frame3:SetPoint("TOP", 0, -185)
    else
        FelComm.CostText:Hide()
        CharFrameNewPart.Frame2:Hide()
        CharFrameNewPart.Frame3:SetPoint("TOP", 0, -90)
    end
end


--name, button, is slot currently activated
local InsureCurrency = 98461

local LC_Weapon, LC_Armor = GetAuctionItemClasses()

local ClassNumbers = {
    [LC_Weapon] = 2,
    [LC_Armor] = 4,
}

local LC_1HA, LC_2HA, LC_BOW, LC_GUN, LC_1HM, LC_2HM, LC_POLEARM, LC_1HS, LC_2HS, LC_STAVES, LC_FIST, LC_MISC, LC_DAGGER, LC_THROWN, LC_CROSSBOW, LC_WAND, LC_FISH = GetAuctionItemSubClasses(1)
local LC_MISCARMOR, LC_CLOTH, LC_LEATHER, LC_MAIL, LC_PLATE, LC_SHIELDS, LC_LIBRAMS, LC_IDOLS, LC_TOTEMS, LC_SIGILS = GetAuctionItemSubClasses(2)

--MAIN FRAME

FelComm:SetSize(512,512)
FelComm:SetPoint("CENTER")

FelComm:SetMovable(true)
FelComm:EnableMouse(true)
FelComm:RegisterForDrag("LeftButton")
FelComm:SetClampedToScreen(true)
FelComm:SetScript("OnDragStart", FelComm.StartMoving)
FelComm:SetScript("OnDragStop", FelComm.StopMovingOrSizing)
FelComm:SetFrameStrata("HIGH")

FelComm:SetBackdrop({
    bgFile = "Interface\\AddOns\\AwAddons\\Textures\\SafeSlots\\SafeSlots",
    --insets = { left = -256, right = -256, top = -5, bottom = -5}
})

FelComm.CloseButton = CreateFrame("Button", "FelComm.CloseButton", FelComm, "UIPanelCloseButton")
FelComm.CloseButton:SetPoint("TOPRIGHT", -82, -45)
FelComm.CloseButton:EnableMouse(true)
--FelComm.CloseButton:SetSize(29, 29)
FelComm.CloseButton:SetScript("OnMouseUp", function()
    PlaySound("QUESTLOGCLOSE")
    FelComm:Hide()
end)
FelComm.TitleText = FelComm:CreateFontString("FelComm.TitleText")
FelComm.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 11)
FelComm.TitleText:SetFontObject(GameFontNormal)
FelComm.TitleText:SetPoint("TOP", 0, -55)
FelComm.TitleText:SetShadowOffset(1,-1)
FelComm.TitleText:SetText("Fel Commutation")

FelComm.CostText = FelComm:CreateFontString("FelComm.CostText")
FelComm.CostText:SetFont("Fonts\\FRIZQT__.TTF", 11)
FelComm.CostText:SetFontObject(GameFontNormal)
FelComm.CostText:SetPoint("TOP", 0, -80)
FelComm.CostText:SetShadowOffset(1,-1)
FelComm.CostText:Hide()

FelComm:Hide()
--END OF MAIN FRAME

--MAIN FRAME SCRIPTS--

local TempSafeSlotsFrame = CreateFrame("FRAME")
TempSafeSlotsFrame:RegisterEvent("UNIT_MODEL_CHANGED")
TempSafeSlotsFrame:SetScript("OnEvent", function(self,event,...)
    CalculateMaxPotentialCost()
end)
TempSafeSlotsFrame:Show()
--END OF MAIN FRAME SCRIPTS--

--SLOT BUTTONS--
--loading same settings for all of the slot buttons
for i = 1, 19 do
    FelComm["Slot"..i] = CreateFrame("Button", nil, FelComm)
    FelComm["Slot"..i]:SetNormalTexture("Interface\\AddOns\\AwAddons\\Textures\\SafeSlots\\SlotBorder")
    FelComm["Slot"..i]:SetHighlightTexture("Interface\\AddOns\\AwAddons\\Textures\\SafeSlots\\SlotBorder_H")
    if i <= 16 then
        FelComm["Slot"..i]:SetSize(54,54)
    else
        FelComm["Slot"..i]:SetSize(60,60)
    end
end
--additional button textures
for i = 1, 19 do
    FelComm["Slot"..i].Glow = FelComm["Slot"..i]:CreateTexture(nil, "OVERLAY")
    FelComm["Slot"..i].Glow:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\SafeSlots\\SlotBorder_active")
    FelComm["Slot"..i].Glow:SetSize(FelComm["Slot"..i]:GetSize())
    FelComm["Slot"..i].Glow:SetPoint("CENTER")
    FelComm["Slot"..i].Glow:SetBlendMode("ADD")
    FelComm["Slot"..i].Glow:Hide()
end

tinsert(SlotsData[1], FelComm.Slot1)
tinsert(SlotsData[2], FelComm.Slot2)
tinsert(SlotsData[3], FelComm.Slot3)
tinsert(SlotsData[4], FelComm.Slot6)
tinsert(SlotsData[5], FelComm.Slot5)
tinsert(SlotsData[6], FelComm.Slot10)
tinsert(SlotsData[7], FelComm.Slot11)
tinsert(SlotsData[8], FelComm.Slot12)
tinsert(SlotsData[9], FelComm.Slot8)
tinsert(SlotsData[10], FelComm.Slot9)
tinsert(SlotsData[11], FelComm.Slot13)
tinsert(SlotsData[12], FelComm.Slot14)
tinsert(SlotsData[13], FelComm.Slot15)
tinsert(SlotsData[14], FelComm.Slot16)
tinsert(SlotsData[15], FelComm.Slot4)
tinsert(SlotsData[16], FelComm.Slot17)
tinsert(SlotsData[17], FelComm.Slot18)
tinsert(SlotsData[18], FelComm.Slot19)
tinsert(SlotsData[19], FelComm.Slot7)

--setting up each button properly
FelComm.Slot1:SetPoint("CENTER", -100, 144)
FelComm.Slot2:SetPoint("CENTER", -121, 106)
FelComm.Slot3:SetPoint("CENTER", -134, 64)
FelComm.Slot4:SetPoint("CENTER", -140, 22)
FelComm.Slot5:SetPoint("CENTER", -140, -22)
FelComm.Slot6:SetPoint("CENTER", -134, -64)
FelComm.Slot7:SetPoint("CENTER", -121, -106)
FelComm.Slot8:SetPoint("CENTER", -100, -144)

FelComm.Slot9:SetPoint("CENTER", 103, 144)
FelComm.Slot10:SetPoint("CENTER", 124, 106)
FelComm.Slot11:SetPoint("CENTER", 137, 64)
FelComm.Slot12:SetPoint("CENTER", 143, 22)
FelComm.Slot13:SetPoint("CENTER", 143, -22)
FelComm.Slot14:SetPoint("CENTER", 137, -64)
FelComm.Slot15:SetPoint("CENTER", 124, -106)
FelComm.Slot16:SetPoint("CENTER", 103, -144)

FelComm.Slot17:SetPoint("CENTER", -43, -161)
FelComm.Slot18:SetPoint("CENTER", 3, -161)
FelComm.Slot19:SetPoint("CENTER", 46, -161)

--slot buttons item slot textures--
for i = 1, 19 do
    FelComm["Slot"..i].BG = FelComm["Slot"..i]:CreateTexture(nil, "BACKGROUND")
    FelComm["Slot"..i].BG:SetSize(33,33)
    FelComm["Slot"..i].BG:SetPoint("CENTER")
    FelComm["Slot"..i].BG:Hide()
end
--END OF SLOT BUTTONS

--SLOT BUTTONS SCRIPTS--
for i = 1, 19 do
    FelComm["Slot"..i]:SetScript("OnClick", function(self) -- main action
        PlaySound("igMainMenuOptionCheckBoxOn")
        if not(FelComm.Confirm:IsVisible()) then
            FelComm.Confirm:Show()
            FelComm.Confirm.Icon.slot = self.slot
            FelComm.Confirm:Update()
        elseif (FelComm.Confirm.Icon.slot) and FelComm.Confirm.Icon.slot == self.slot then
            FelComm.Confirm:Hide()
        else
            FelComm.Confirm.Icon.slot = self.slot
            FelComm.Confirm:Update()
        end
    end)


    FelComm["Slot"..i]:SetScript("OnEnter", function(self) -- default tooltip text
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

        if (self.slot) then
            GameTooltip:SetText("|cffFFFFFF"..SlotsData[self.slot][1])
        end

        if not(self.slot) or not(IsSlotInsuranced[self.slot]) then
            GameTooltip:AddLine("Click on this slot to insure it")
        end
        GameTooltip:Show()
    end)

    FelComm["Slot"..i]:SetScript("OnLeave", function(self) -- onleave script
        GameTooltip:Hide()
    end)
end

--END OF SLOT BUTTONS SCRIPTS--

--MODEL OF CHARACTER--
FelComm.PlayerModel = CreateFrame("PlayerModel", "FelComm.PlayerModel", FelComm)
FelComm.PlayerModel:SetWidth(192);
FelComm.PlayerModel:SetHeight(256);
FelComm.PlayerModel:SetPoint("CENTER", 0, -22)
FelComm.PlayerModel:SetUnit("player")
FelComm.PlayerModel:SetModelScale(1)
FelComm.PlayerModel:SetPosition(0.0,0.0,0)
FelComm.PlayerModel:SetCamera(1)
--END OF THE MODEL OF CHARACTER--

--MODEL OF CHARACTER SCRIPTS--
FelComm.PlayerModel:RegisterEvent("UNIT_MODEL_CHANGED")
FelComm.PlayerModel:SetScript("OnEvent", function(self,event,arg)
    if arg == "player" then
        self:RefreshUnit()
    end
end)
--END OF MODEL OF CHARACTER SCRIPTS--

--Confirm Frame--
FelComm.Confirm = CreateFrame("FRAME", "FelComm.Confirm", FelComm,nil)
FelComm.Confirm:SetSize(512,512)
FelComm.Confirm:SetPoint("CENTER")
FelComm.Confirm:SetBackdrop({
    bgFile = "Interface\\AddOns\\AwAddons\\Textures\\SafeSlots\\SafeSlots_Window",
    --insets = { left = -256, right = -256, top = -5, bottom = -5}
})
FelComm.Confirm:SetFrameStrata("DIALOG")
FelComm.Confirm:Hide()

--[[local SafeSlots_Main_Confirm_CloseButton = CreateFrame("Button", "SafeSlots_Main_Confirm_CloseButton", FelComm.Confirm, "UIPanelCloseButton")
SafeSlots_Main_Confirm_CloseButton:SetPoint("CENTER", 90, -2)
SafeSlots_Main_Confirm_CloseButton:EnableMouse(true)
SafeSlots_Main_Confirm_CloseButton:SetSize(25, 25)
SafeSlots_Main_Confirm_CloseButton:SetScript("OnMouseUp", function()
    PlaySound("TalentScreenOpen")
    FelComm.Confirm:Hide()
    end)]]--

-- version of frame if your slot is activated
FelComm.UninsureButton = CreateFrame("Button", "FelComm.UninsureButton", FelComm.Confirm, "UIPanelButtonTemplate")
FelComm.UninsureButton:SetWidth(141)
FelComm.UninsureButton:SetHeight(21)
FelComm.UninsureButton:SetPoint("CENTER", 0,-54)
FelComm.UninsureButton:RegisterForClicks("AnyUp")
FelComm.UninsureButton:SetText("Remove Commutation")


FelComm.InsureButton = CreateFrame("Button", "FelComm.InsureButton", FelComm.Confirm, "UIPanelButtonTemplate")
FelComm.InsureButton:SetWidth(141)
FelComm.InsureButton:SetHeight(21)
FelComm.InsureButton:SetPoint("CENTER", 0,-54)
FelComm.InsureButton:RegisterForClicks("AnyUp")
FelComm.InsureButton:SetText("Commute slot")


FelComm.Confirm.Icon = CreateFrame("Button", "FelComm.Confirm.Icon", FelComm.Confirm, "SecureActionButtonTemplate")
FelComm.Confirm.Icon:SetSize(34, 34)
FelComm.Confirm.Icon:SetPoint("CENTER",-80,-23)
FelComm.Confirm.Icon:EnableMouse(true)
FelComm.Confirm.Icon:SetNormalTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
FelComm.Confirm.Icon:SetHighlightTexture("Interface\\BUTTONS\\ButtonHilight-Square")

FelComm.Confirm.CostText = FelComm.Confirm:CreateFontString("FelComm.Confirm.CostText")
FelComm.Confirm.CostText:SetFont("Fonts\\FRIZQT__.TTF", 10)
FelComm.Confirm.CostText:SetFontObject(GameFontNormal)
FelComm.Confirm.CostText:SetPoint("CENTER", 0, -15)
FelComm.Confirm.CostText:SetShadowOffset(1,-1)
--


function InsureSlot(slot)
    IsSlotInsuranced[slot] = true
    local link = GetInventoryItemLink("player", slot)
    local frame = SlotsData[slot][2]

    if link then
        local texture = select(10, GetItemInfo(link))
        SetPortraitToTexture(frame.BG, texture)
        frame.BG:Show()
    else
        frame.BG:Hide()
    end

    if not frame.Glow:IsVisible() then
        Addon:BaseFrameFadeIn(frame.Glow)
    else
        frame.Glow:Show()
    end

    CalculateMaxPotentialCost()
end

function UninsureSlot(slot)
    IsSlotInsuranced[slot] = false
    local link = GetInventoryItemLink("player", slot)
    local frame = SlotsData[slot][2]

    if link then 
        local texture = select(10, GetItemInfo(link))
        SetPortraitToTexture(frame.BG, texture)
        frame.BG:Show()
    else
        frame.BG:Hide()
    end
    if frame.Glow:IsVisible() then
        Addon:BaseFrameFadeOut(frame.Glow)
    else
        frame.Glow:Hide()
    end
    CalculateMaxPotentialCost()
end

-- main frame scripts--
function FelComm.Confirm:Update()
    local link = GetInventoryItemLink("player", FelComm.Confirm.Icon.slot)
    if GetFelCommutationInfo(FelComm.Confirm.Icon.slot) then-- player has insured slot
        if (link) then
            local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(link)
            local ItemID = GetInventoryItemID("player", FelComm.Confirm.Icon.slot)

            local itemCost = CalculateItemFelCommutationCost(link)

            if (true) then
                FelComm.Confirm.Icon:SetNormalTexture(texture)
                if (DISABLED_SLOTS[FelComm.Confirm.Icon.slot]) then
                    FelComm.Confirm.CostText:SetText(SAFE_TO_REMOVE_TEXT)
                else
                    local gold, silver, copper = GetGoldForMoney(itemCost)
                    FelComm.Confirm.CostText:SetText(format(UNINSURE_SLOT_COST_TEXT, gold, silver, copper))
                end
            else
                FelComm.Confirm.Icon:SetNormalTexture(texture)
                FelComm.Confirm.CostText:SetText(SAFE_TO_REMOVE_TEXT)
            end
        else
            FelComm.Confirm.Icon:SetNormalTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
            if (DISABLED_SLOTS[FelComm.Confirm.Icon.slot]) then
                FelComm.Confirm.CostText:SetText(SAFE_TO_REMOVE_TEXT)
            else
                FelComm.Confirm.CostText:SetText(SAVE_EMPTY_SLOT_TEXT)
            end
        end

        FelComm.UninsureButton:Show()
        FelComm.InsureButton:Hide()
    else-- player has not insured slot
        FelComm.UninsureButton:Hide()
        FelComm.InsureButton:Show()
        if (DISABLED_SLOTS[FelComm.Confirm.Icon.slot]) then
            FelComm.InsureButton:Disable()
            FelComm.Confirm.Icon:SetNormalTexture("Interface\\icons\\World_Marker_Cross")
            --FelComm.Confirm.CostText:SetText("Commutation cost:\n\n|cffa335ee[Demon's Tears]|r |cffFFFFFFx1|r")
            FelComm.Confirm.CostText:SetText(SLOT_IS_DISABLED_TEXT)
        elseif link then
            local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(link)
            local ItemID = GetInventoryItemID("player", FelComm.Confirm.Icon.slot)

            local itemCost = CalculateItemFelCommutationCost(link)

            FelComm.Confirm.Icon:SetNormalTexture(texture)
            local gold, silver, copper = GetGoldForMoney(itemCost)
            FelComm.Confirm.CostText:SetText(format(SAVE_COST_TEXT, gold, silver, copper))

        else
            FelComm.Confirm.Icon:SetNormalTexture("Interface\\icons\\inv_custom_demonstears")
            --FelComm.Confirm.CostText:SetText("Commutation cost:\n\n|cffa335ee[Demon's Tears]|r |cffFFFFFFx1|r")
            FelComm.Confirm.CostText:SetText(SAVE_EMPTY_SLOT)
            FelComm.InsureButton:Enable()
        end
    end
end
-- main frame scripts--

--item icon scripts--
FelComm.Confirm.Icon:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local itemlink = GetInventoryItemLink("player", self.slot)
    if itemlink and GetFelCommutationInfo(self.slot) then
        GameTooltip:SetHyperlink(GetInventoryItemLink("player", self.slot))
    elseif GetFelCommutationInfo(self.slot) then
        GameTooltip:AddLine("Slot is empty")
    else
    end
    GameTooltip:Show()
end)
FelComm.Confirm.Icon:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

--insure item button script
--[[FelComm.InsureButton:SetScript("OnUpdate", function(self)
    if ( GetItemCount(InsureCurrency) > 0) then
        self:Enable()
    else
        self:Disable()
    end
    end)]]-- Demon's Tears disabled
--end
--End Confirm Frame Scripts--

--ANIMATIONS--
FelComm.Complete = FelComm:CreateTexture(nil, "ARTWORK")
FelComm.Complete:SetSize(FelComm:GetSize())
FelComm.Complete:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\SafeSlots\\SafeSlotsHighlight")
FelComm.Complete:SetPoint("CENTER")
FelComm.Complete:SetBlendMode("ADD")
FelComm.Complete:Hide()

FelComm.Complete.Dialog = FelComm.Confirm:CreateTexture(nil, "OVERLAY")
FelComm.Complete.Dialog:SetSize(FelComm:GetSize())
FelComm.Complete.Dialog:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\SafeSlots\\SafeSlots_confirmH")
FelComm.Complete.Dialog:SetPoint("CENTER")
FelComm.Complete.Dialog:SetBlendMode("ADD")
FelComm.Complete.Dialog:Hide()

function FelComm:AnimGroup_OnEnd()
    Addon:BaseFrameFadeOut(FelComm.Complete)
    Addon:BaseFrameFadeOut(FelComm.Complete.Dialog)
    --AIO.Handle("SlotIsurance", "GetSlotList")
end
FelComm.AnimGroup = FelComm:CreateAnimationGroup()
FelComm.AnimGroup.Scale = FelComm.AnimGroup:CreateAnimation("Scale")
FelComm.AnimGroup.Scale:SetDuration(0.5)
FelComm.AnimGroup.Scale:SetOrder(1)
FelComm.AnimGroup.Scale:SetEndDelay(0)
--FelComm.AnimGroup.Scale:SetScale(1,1)
FelComm.AnimGroup.Scale:SetScript("OnFinished", FelComm.AnimGroup_OnEnd)
FelComm.AnimGroup.Scale:SetScript("OnStop", FelComm.AnimGroup_OnEnd)
FelComm.AnimGroup.Scale:SetScript("OnPlay", function()
    Addon:BaseFrameFadeIn(FelComm.Complete)
    Addon:BaseFrameFadeIn(FelComm.Complete.Dialog)
end)

function FelComm:Init()
    FelComm.PlayerModel:SetUnit("player")
    FelComm.PlayerModel:SetCamera(1) -- model settings
    FelComm.Confirm:Hide()

    for i = 1, 19 do
        IsSlotInsuranced[i] = GetFelCommutationInfo(i)

        if IsSlotInsuranced[i] then
            InsureSlot(i)
        else
           UninsureSlot(i)
        end
        SlotsData[i][2].slot = i -- button settings
    end
end
--END OF ANIMATIONS--


FelComm:SetScript("OnShow", function()
    FelComm:Init()
    CalculateMaxPotentialCost()
end)

FelComm.UninsureButton:SetScript("OnClick", function(self)
    PlaySound("Glyph_MajorCreate")
    if (FelComm.Confirm.Icon.slot) then
        FelComm.AnimGroup:Stop()
        FelComm.AnimGroup:Play()
        SetFelCommutation(FelComm.Confirm.Icon.slot, false)
    end
end)
FelComm.InsureButton:SetScript("OnClick", function(self)
    if (self:IsEnabled() == 1) then
        PlaySound("Glyph_MajorCreate")
        --if ( GetItemCount(InsureCurrency) > 0) then
        FelComm.AnimGroup:Stop()
        FelComm.AnimGroup:Play()
        if (FelComm.Confirm.Icon.slot) then
            SetFelCommutation(FelComm.Confirm.Icon.slot, true)
        end
    end
end)

--[[function SlotIsuranceClient.SafeSlots_InitBloodied(player, BloodiedList)
    C_BloodiedItemList = BloodiedList
end]]--

--TOTAL COST TEXT--
--[[PaperDoll_CostText = PlayerStatFrameRightDropDown:CreateFontString("PaperDoll_CostText")
PaperDoll_CostText:SetFont("Fonts\\FRIZQT__.TTF", 10)
PaperDoll_CostText:SetFontObject(GameFontNormal)
PaperDoll_CostText:SetPoint("TOPLEFT", -83, 22)
PaperDoll_CostText:SetShadowOffset(1,-1)
PaperDoll_CostText:Hide()]]--
--
--TOOLTIP SCRIPTS--

local cTip = CreateFrame("GameTooltip","cTooltip",nil,"GameTooltipTemplate")

local function IsSoulbound(slot)
    cTip:SetOwner(UIParent, "ANCHOR_NONE")
    cTip:SetInventoryItem("player", slot)
    cTip:Show()
    for i = 1,cTip:NumLines() do
        if(_G["cTooltipTextLeft"..i]:GetText()==ITEM_SOULBOUND) then
            return true
        end
    end
    cTip:Hide()
    return false
end

GameTooltip:HookScript("OnTooltipSetItem", function (self)
    if not GameTooltip:GetOwner() then return false end -- ?? Can happen from atlas loot stuff apparently
    local TooltipOwner = GameTooltip:GetOwner():GetName()
    local slot = nil
    local ItemID = nil

    if not(TooltipOwner) then
        return false
    end

    local SlotName = _G[strupper(strsub(TooltipOwner, 10))]
    local IsInsured = false

    local _, link = GameTooltip:GetItem()

    if not(link) or not(IsEquippedItem(link)) then
        return false
    end

    if not(SlotsData[1]) then
        return false
    end

    for i = 1, 19 do
        if (SlotsData[i][1] == SlotName) and IsSlotInsuranced[i] then
            if (GetInventoryItemLink("player", i) == link) then
                ItemID = GetInventoryItemID("player", i)
                IsInsured = true
                slot = i
            end
        end
    end

    local felCommutationCost = CalculateItemFelCommutationCost(link)
    if (IsInsured) and felCommutationCost > 0 then
        local gold, silver, copper = GetGoldForMoney(felCommutationCost)
        self:AddDoubleLine(format(INSURED_TOOLTIP_LEFT_TEXT, gold, silver, copper), INSURED_TOOLTIP_RIGHT_TEXT)
        self:Show()

        --[[local id = GetInventoryItemID("player", slot)
        if (IsSoulbound(slot)) then
            self:AddLine("|cff9ACD32• Fel commutation won't apply on this item\nsince it is a soulbound item")
            self:Show()
        end]]--
    end
end)

FelComm.Slot6.BG:SetDesaturated(true)
FelComm.Slot7.BG:SetDesaturated(true)

FelComm:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
FelComm:RegisterEvent("COMMENTATOR_SKIRMISH_QUEUE_REQUEST")

FelComm:SetScript("OnEvent", function(self, event, asc_event, ...) 
    if event == "COMMENTATOR_SKIRMISH_QUEUE_REQUEST" then 

        if asc_event == "ASCENSION_FEL_COMMUTATION_CHANGED" then
            FelComm.Confirm:Hide()
            local slot, applied = ... 
            if applied then 
                InsureSlot(slot + 1)
            else
                UninsureSlot(slot + 1)
            end

        elseif asc_event == "ASCENSION_FEL_COMMUTATION_WINDOW_VISIBILITY_CHANGED" then
            local show = ...
            if show then
                FelComm:Show()
            else
                FelComm:Hide()
            end
        end
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        FelComm:Init()
        CalculateMaxPotentialCost()
    end
end)

CharacterFrame:HookScript("OnShow", function() CalculateMaxPotentialCost() end)

-- setup
FelComm:Init()
CalculateMaxPotentialCost()