local AddonName, Addon = ...
local M = CreateFrame("FRAME", "MysticEnchantingFrame", Addon.Collections)
Addon.MysticEnchant = M
-- Ref for compatability with older UI
CollectionsFrame = M
M:SetFrameStrata("DIALOG")
M:Hide()

-------------------------------------------------------------------------------
--                                  Settings                                 --
-------------------------------------------------------------------------------

local GLOBAL_BREATHING_ENABLED = false
local ACTIVE_ITEM = nil
local ACTIVE_ENCHANT = nil
local ITEM_BAG = nil
local ITEM_SLOT = nil
local ITEM_BAG_TEMP = nil
local ITEM_SLOT_TEMP = nil
local CAN_REFUND = false
local DID_GOSSIP_ALTAR = false

local UNKNOWN_ENCHANT_ICON = "Interface\\Icons\\Inv_misc_questionmark"

local REFORGE_QUALITY_MIN = 2
local REFORGE_QUALITY_MAX = 5

local ReforgeToken = 98462
local ReforgeExtract = 98463
local ReforgeOrb = 98570
local balanceToken = 0
local balanceExtract = 0
local balanceOrbs = 0


local REFORGE_GOLD_COST = 25000
local REFORGE_RUNE_COST = 1

local ENCHANT_GREEN_ORB_COST = 3
local ENCHANT_BLUE_ORB_COST = 6
local ENCHANT_PURPLE_ORB_COST = 10
local ENCHANT_LEGENDARY_ORB_COST = 25

local ENCHANT_GOLD_MULTIPLIER = 150000

local ENCHANT_GREEN_GOLD_COST = ENCHANT_GREEN_ORB_COST * ENCHANT_GOLD_MULTIPLIER
local ENCHANT_BLUE_GOLD_COST = ENCHANT_BLUE_ORB_COST * ENCHANT_GOLD_MULTIPLIER
local ENCHANT_PURPLE_GOLD_COST = ENCHANT_PURPLE_ORB_COST * ENCHANT_GOLD_MULTIPLIER
local ENCHANT_LEGENDARY_GOLD_COST = ENCHANT_LEGENDARY_ORB_COST * ENCHANT_GOLD_MULTIPLIER

local ReforgeTokenTexture = "Interface\\Icons\\Inv_Custom_ReforgeToken"
local ReforgeExtractTexture = "Interface\\Icons\\Inv_Custom_MysticExtract"
local ReforgeOrbTexture = "Interface\\Icons\\inv_custom_CollectionRCurrency"

local prohibited_equipslots = {
    ["INVTYPE_BAG"] = true,
    ["INVTYPE_BODY"] = true,
    ["INVTYPE_AMMO"] = true,
    ["INVTYPE_TABARD"] = true
}

local VALID_INVTYPE = {
    ["INVTYPE_HEAD"] = true,
    ["INVTYPE_NECK"] = true,
    ["INVTYPE_SHOULDER"] = true,
    ["INVTYPE_BODY"] = true,
    ["INVTYPE_CHEST"] = true,
    ["INVTYPE_ROBE"] = true,
    ["INVTYPE_WAIST"] = true,
    ["INVTYPE_LEGS"] = true,
    ["INVTYPE_FEET"] = true,
    ["INVTYPE_WRIST"] = true,
    ["INVTYPE_HAND"] = true,
    ["INVTYPE_FINGER"] = true,
    ["INVTYPE_TRINKET"] = true,
    ["INVTYPE_CLOAK"] = true,
    ["INVTYPE_WEAPON"] = true,
    ["INVTYPE_SHIELD"] = true,
    ["INVTYPE_2HWEAPON"] = true,
    ["INVTYPE_WEAPONMAINHAND"] = true,
    ["INVTYPE_WEAPONOFFHAND"] = true,
    ["INVTYPE_HOLDABLE"] = true,
    ["INVTYPE_RANGED"] = true,
    ["INVTYPE_THROWN"] = true,
    ["INVTYPE_RANGEDRIGHT"] = true,
    ["INVTYPE_RELIC"] = true,
}

local ENCH_SPELLTEXTDATA = {}

local ParentButtons = {
    [1] = CharacterHeadSlot,
    [2] = CharacterNeckSlot,
    [3] = CharacterShoulderSlot,
    [15] = CharacterBackSlot,
    [5] = CharacterChestSlot,
    [4] = CharacterShirtSlot,
    [19] = CharacterTabardSlot,
    [9] = CharacterWristSlot,
    [10] = CharacterHandsSlot,
    [6] = CharacterWaistSlot,
    [7] = CharacterLegsSlot,
    [8] = CharacterFeetSlot,
    [11] = CharacterFinger0Slot,
    [12] = CharacterFinger1Slot,
    [13] = CharacterTrinket0Slot,
    [14] = CharacterTrinket1Slot,
    [16] = CharacterMainHandSlot,
    [17] = CharacterSecondaryHandSlot,
    [18] = CharacterRangedSlot
}

local PaperDoll_RE_Total_Quality = {
}

local PaperDollEnchantQualitySettings = {
    "Interface\\AddOns\\AwAddons\\Textures\\enchant\\EnchantBorder_white",
    "Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\BorderNewGreen",
    "Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\BorderNewBlue",
    "Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\BorderNewEpic",
    "Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\BorderNewLeg",
}

local CollectionSlotMap = {
}

Addon.REListSpellID = {}

for enchantID, RE in pairs(Addon.REList) do
    RE.enchantID = enchantID
    Addon.REListSpellID[RE.spellID] = RE.enchantID
end
-------------------------------------------------------------------------------
--                                 Variables                                 --
-------------------------------------------------------------------------------
M.MaxEcnhantsPerPage = 15
M.EnchantList = {} 
M.CurrentList = {}
M.CurrentPage = 1
M.PageCount = 1
M.SuccessChance = 100
M.KnownEnchants = 0
M.TotalEnchants = #M.EnchantList
M.QualityData = {}

M.EnchantQualitySettings = {
    [0] = {"|cff00FF00","Spells\\Creature_spellportallarge_green.m2","Interface\\AddOns\\AwAddons\\Textures\\Collections\\EnchantEffect_UnCommon", {0.12, 1.00, 0.00}},
    [1] = {"|cffffffff","Spells\\Creature_spellportallarge_lightred.m2","Interface\\AddOns\\AwAddons\\Textures\\Collections\\EnchantEffect_Common", {1.00, 1.00, 1.00}},
    [2] = {"|cff1eff00","Spells\\Creature_spellportallarge_green.m2","Interface\\AddOns\\AwAddons\\Textures\\Collections\\EnchantEffect_UnCommon", {0.12, 1.00, 0.00}},
    [3] = {"|cff0070dd","Spells\\Creature_spellportallarge_blue.m2","Interface\\AddOns\\AwAddons\\Textures\\Collections\\EnchantEffect_Rare", {0.00, 0.44, 0.87}},
    [4] = {"|cffa335ee","Spells\\Creature_spellportallarge_purple.m2","Interface\\AddOns\\AwAddons\\Textures\\Collections\\EnchantEffect_Epic", {0.64, 0.21, 0.93}},
    [5] = {"|cffff8000","Spells\\Creature_spellportallarge_yellow.m2","Interface\\AddOns\\AwAddons\\Textures\\Collections\\EnchantEffect_Legendary", {1.00, 0.50, 0.00}},
    [6] = {"|cffff8000","Spells\\Creature_spellportallarge_yellow.m2","Interface\\AddOns\\AwAddons\\Textures\\Collections\\EnchantEffect_Legendary", {1.00, 0.50, 0.00}},
    [7] = {"|cffff8000","Spells\\Creature_spellportallarge_yellow.m2","Interface\\AddOns\\AwAddons\\Textures\\Collections\\EnchantEffect_Legendary", {1.00, 0.50, 0.00}},
    [8] = {"|cffff8000","Spells\\Creature_spellportallarge_yellow.m2","Interface\\AddOns\\AwAddons\\Textures\\Collections\\EnchantEffect_Legendary", {1.00, 0.50, 0.00}},
    [9] = {"|cffff8000","Spells\\Creature_spellportallarge_yellow.m2","Interface\\AddOns\\AwAddons\\Textures\\Collections\\EnchantEffect_Legendary", {1.00, 0.50, 0.00}},
    [10] = {"|cffff8000","Spells\\Creature_spellportallarge_yellow.m2","Interface\\AddOns\\AwAddons\\Textures\\Collections\\EnchantEffect_Legendary", {1.00, 0.50, 0.00}},
    [11] = {"|cffff8000","Spells\\Creature_spellportallarge_yellow.m2","Interface\\AddOns\\AwAddons\\Textures\\Collections\\EnchantEffect_Legendary", {1.00, 0.50, 0.00}},
    [12] = {"|cffff8000","Spells\\Creature_spellportallarge_yellow.m2","Interface\\AddOns\\AwAddons\\Textures\\Collections\\EnchantEffect_Legendary", {1.00, 0.50, 0.00}},
}

M.MaxQualityLibrary = {
    [0] = 19,
    [1] = 19,
    [2] = 19,
    [3] = 19,
    [4] = 3,
    [5] = 1,
    [6] = 19,
    [7] = 19,
    [8] = 19,
}
M.SlotStackData = {}

StaticPopupDialogs["ASC_ERROR_TIMEOUT"] = {
    text = "Choose Mystic Enchant to add it to your build",
    button1 = OKAY,
    --button2 = "Cancel",
    whileDead = true,
    timeout = 5,
    hideOnEscape = true,
    exclusive = 1,
    --[[OnAccept = function(self)
        print("Accept, Debug")
    end]]--
}

local EXTRACT_TOOLTIP_DEFAULT = { "|cffFFFFFFClick to Extract|r", "|cffFFFFFFRequires|r x1 |cffFFFFFF|T"..ReforgeExtractTexture..".blp:13:13|t Mystic Extract|r" }
local EXTRACT_TOOLTIP_NO_GOSSIP = { "|cffFFFFFFInteragissez avec un autel d'enchantement pour extraire un enchantement|r" }
local EXTRACT_TOOLTIP_NO_EXTRACT = { "|cffCC0000Impossible d'extraire l'enchantement|r", "Il vous faut |cffFFFFFFx1 |T"..ReforgeExtractTexture..".blp:13:13|t Mystic Extract|r", }
local EXTRACT_TOOLTIP_NO_ITEM = { "|cffCC0000Impossible d'extraire l'enchantement|r", "|cffFFFFFFVous devez placer un objet dans l'emplacement d'enchantement|r" }
local EXTRACT_TOOLTIP_NO_ENCHANT = { "|cffCC0000Impossible d'extraire l'enchantement|r", "|cffFFFFFFL'objet actuel n'a pas d'enchantement!" }
local EXTRACT_TOOLTIP_LOW_QUALITY = { "|cffCC0000Impossible d'extraire l'enchantement|r", "|cffFFFFFFLa qualité de l'objet doit être|r |cff0070FFRare|r |cffFFFFFFou supérieur pour extraire un enchantement|r" }
local EXTRACT_TOOLTIP_HIGH_QUALITY = { "|cffCC0000Impossible d'extraire l'enchantement|r", "|cffFFFFFFLa qualité de l'objet doit être |r |cffFF8000Legendaire|r |cffFFFFFFou moins pour extraire un enchantement|r" }

local EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_DEFAULT
-------------------------------------------------------------------------------
--                               Slot Template                               --
-------------------------------------------------------------------------------
local function CreateUnlockAnimation(frame, size)
    frame.animStepAdd1Tex = frame:CreateTexture(nil, "ARTWORK")
    frame.animStepAdd1Tex:SetSize(size[1]*0.8, size[2]*0.8)
    frame.animStepAdd1Tex:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\AnimS1")
    frame.animStepAdd1Tex:SetPoint("CENTER", 0, 0)
    frame.animStepAdd1Tex:SetAlpha(0)

    frame.animStepAdd2Tex = frame:CreateTexture(nil, "OVERLAY")
    frame.animStepAdd2Tex:SetSize(unpack(size))
    frame.animStepAdd2Tex:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\AnimS2")
    frame.animStepAdd2Tex:SetPoint("CENTER", 0, 0)
    frame.animStepAdd2Tex:SetAlpha(0)

    frame.animStepAdd3Tex = frame:CreateTexture(nil, "ARTWORK")
    frame.animStepAdd3Tex:SetSize(unpack(size))
    frame.animStepAdd3Tex:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\AnimS3")
    frame.animStepAdd3Tex:SetPoint("CENTER", 0, 0)
    frame.animStepAdd3Tex:SetAlpha(0)

    -- 1st step of animation
    frame.animStepAdd1Tex.AG = frame.animStepAdd1Tex:CreateAnimationGroup()

    frame.animStepAdd1Tex.AG.Alpha0 = frame.animStepAdd1Tex.AG:CreateAnimation("Alpha")
    frame.animStepAdd1Tex.AG.Alpha0:SetStartDelay(0)
    frame.animStepAdd1Tex.AG.Alpha0:SetDuration(0.1)
    frame.animStepAdd1Tex.AG.Alpha0:SetOrder(0)
    frame.animStepAdd1Tex.AG.Alpha0:SetEndDelay(0)
    frame.animStepAdd1Tex.AG.Alpha0:SetSmoothing("IN")
    frame.animStepAdd1Tex.AG.Alpha0:SetChange(1)

    frame.animStepAdd1Tex.AG.Rotation = frame.animStepAdd1Tex.AG:CreateAnimation("Rotation")
    frame.animStepAdd1Tex.AG.Rotation:SetDuration(3)
    frame.animStepAdd1Tex.AG.Rotation:SetOrder(0)
    frame.animStepAdd1Tex.AG.Rotation:SetEndDelay(0)
    frame.animStepAdd1Tex.AG.Rotation:SetSmoothing("NONE")
    frame.animStepAdd1Tex.AG.Rotation:SetDegrees(-180)

    frame.animStepAdd1Tex.AG.Alpha1 = frame.animStepAdd1Tex.AG:CreateAnimation("Alpha")
    frame.animStepAdd1Tex.AG.Alpha1:SetStartDelay(0)
    frame.animStepAdd1Tex.AG.Alpha1:SetDuration(3)
    frame.animStepAdd1Tex.AG.Alpha1:SetOrder(1)
    frame.animStepAdd1Tex.AG.Alpha1:SetEndDelay(0)
    frame.animStepAdd1Tex.AG.Alpha1:SetSmoothing("OUT")
    frame.animStepAdd1Tex.AG.Alpha1:SetChange(-1)

    -- 2nd step of animation
    frame.animStepAdd2Tex.AG = frame.animStepAdd2Tex:CreateAnimationGroup()

    frame.animStepAdd2Tex.AG.Alpha0 = frame.animStepAdd2Tex.AG:CreateAnimation("Alpha")
    frame.animStepAdd2Tex.AG.Alpha0:SetStartDelay(0.5)
    frame.animStepAdd2Tex.AG.Alpha0:SetDuration(1)
    frame.animStepAdd2Tex.AG.Alpha0:SetOrder(0)
    frame.animStepAdd2Tex.AG.Alpha0:SetEndDelay(0)
    frame.animStepAdd2Tex.AG.Alpha0:SetSmoothing("IN")
    frame.animStepAdd2Tex.AG.Alpha0:SetChange(1)

    frame.animStepAdd2Tex.AG.Scale1 = frame.animStepAdd2Tex.AG:CreateAnimation("Scale")
    frame.animStepAdd2Tex.AG.Scale1:SetScale(0.1, 0.1)
    frame.animStepAdd2Tex.AG.Scale1:SetDuration(0.0)
    frame.animStepAdd2Tex.AG.Scale1:SetStartDelay(0)
    frame.animStepAdd2Tex.AG.Scale1:SetOrder(0)
    frame.animStepAdd2Tex.AG.Scale1:SetSmoothing("NONE")

    frame.animStepAdd2Tex.AG.Scale2 = frame.animStepAdd2Tex.AG:CreateAnimation("Scale")
    frame.animStepAdd2Tex.AG.Scale2:SetScale(10, 10)
    frame.animStepAdd2Tex.AG.Scale2:SetDuration(1)
    frame.animStepAdd2Tex.AG.Scale2:SetStartDelay(0)
    frame.animStepAdd2Tex.AG.Scale2:SetOrder(1)
    frame.animStepAdd2Tex.AG.Scale2:SetSmoothing("IN_OUT")

    frame.animStepAdd2Tex.AG.Alpha1 = frame.animStepAdd2Tex.AG:CreateAnimation("Alpha")
    frame.animStepAdd2Tex.AG.Alpha1:SetStartDelay(0)
    frame.animStepAdd2Tex.AG.Alpha1:SetDuration(4)
    frame.animStepAdd2Tex.AG.Alpha1:SetOrder(2)
    frame.animStepAdd2Tex.AG.Alpha1:SetEndDelay(0)
    frame.animStepAdd2Tex.AG.Alpha1:SetSmoothing("OUT")
    frame.animStepAdd2Tex.AG.Alpha1:SetChange(-1)

    -- 3rd step of animation
    frame.animStepAdd3Tex.AG = frame.animStepAdd3Tex:CreateAnimationGroup()

    frame.animStepAdd3Tex.AG.Alpha0 = frame.animStepAdd3Tex.AG:CreateAnimation("Alpha")
    frame.animStepAdd3Tex.AG.Alpha0:SetDuration(0.1)
    frame.animStepAdd3Tex.AG.Alpha0:SetOrder(1)
    frame.animStepAdd3Tex.AG.Alpha0:SetEndDelay(0)
    frame.animStepAdd3Tex.AG.Alpha0:SetSmoothing("IN")
    frame.animStepAdd3Tex.AG.Alpha0:SetChange(1)

    frame.animStepAdd3Tex.AG.Scale1 = frame.animStepAdd3Tex.AG:CreateAnimation("Scale")
    frame.animStepAdd3Tex.AG.Scale1:SetScale(0.1, 0.1)
    frame.animStepAdd3Tex.AG.Scale1:SetDuration(0.1)
    frame.animStepAdd3Tex.AG.Scale1:SetEndDelay(0)
    frame.animStepAdd3Tex.AG.Scale1:SetOrder(1)
    frame.animStepAdd3Tex.AG.Scale1:SetSmoothing("NONE")

    frame.animStepAdd3Tex.AG.Scale2 = frame.animStepAdd3Tex.AG:CreateAnimation("Scale")
    frame.animStepAdd3Tex.AG.Scale2:SetScale(15, 15)
    frame.animStepAdd3Tex.AG.Scale2:SetDuration(3)
    frame.animStepAdd3Tex.AG.Scale2:SetStartDelay(0)
    frame.animStepAdd3Tex.AG.Scale2:SetOrder(2)
    frame.animStepAdd3Tex.AG.Scale2:SetSmoothing("IN_OUT")

    frame.animStepAdd3Tex.AG.Alpha1 = frame.animStepAdd3Tex.AG:CreateAnimation("Alpha")
    frame.animStepAdd3Tex.AG.Alpha1:SetStartDelay(0)
    frame.animStepAdd3Tex.AG.Alpha1:SetDuration(3)
    frame.animStepAdd3Tex.AG.Alpha1:SetOrder(2)
    frame.animStepAdd3Tex.AG.Alpha1:SetEndDelay(0)
    frame.animStepAdd3Tex.AG.Alpha1:SetSmoothing("OUT")
    frame.animStepAdd3Tex.AG.Alpha1:SetChange(-1)

    local addFrame = CreateFrame("FRAME", nil, frame)
    addFrame:SetSize(frame:GetSize())
    addFrame:SetPoint("CENTER", 0, 0)

    addFrame.animStep1Tex = addFrame:CreateTexture(nil, "ARTWORK")
    addFrame.animStep1Tex:SetSize(size[1]*0.8, size[2]*0.8)
    addFrame.animStep1Tex:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\AnimS1")
    addFrame.animStep1Tex:SetPoint("CENTER", 0, 0)
    addFrame.animStep1Tex:SetBlendMode("ADD")
    addFrame.animStep1Tex:SetAlpha(0)

    addFrame.animStep2Tex = addFrame:CreateTexture(nil, "OVERLAY")
    addFrame.animStep2Tex:SetSize(unpack(size))
    addFrame.animStep2Tex:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\AnimS2")
    addFrame.animStep2Tex:SetPoint("CENTER", 0, 0)
    addFrame.animStep2Tex:SetBlendMode("ADD")
    addFrame.animStep2Tex:SetAlpha(0)

    addFrame.animStep3Tex = addFrame:CreateTexture(nil, "ARTWORK")
    addFrame.animStep3Tex:SetSize(unpack(size))
    addFrame.animStep3Tex:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\AnimS3")
    addFrame.animStep3Tex:SetPoint("CENTER", 0, 0)
    addFrame.animStep3Tex:SetBlendMode("ADD")
    addFrame.animStep3Tex:SetAlpha(0)

    -- 1st step of animation
    addFrame.animStep1Tex.AG = addFrame.animStep1Tex:CreateAnimationGroup()

    addFrame.animStep1Tex.AG.Alpha0 = addFrame.animStep1Tex.AG:CreateAnimation("Alpha")
    addFrame.animStep1Tex.AG.Alpha0:SetStartDelay(0)
    addFrame.animStep1Tex.AG.Alpha0:SetDuration(0.1)
    addFrame.animStep1Tex.AG.Alpha0:SetOrder(0)
    addFrame.animStep1Tex.AG.Alpha0:SetEndDelay(0)
    addFrame.animStep1Tex.AG.Alpha0:SetSmoothing("IN")
    addFrame.animStep1Tex.AG.Alpha0:SetChange(1)

    addFrame.animStep1Tex.AG.Rotation = addFrame.animStep1Tex.AG:CreateAnimation("Rotation")
    addFrame.animStep1Tex.AG.Rotation:SetDuration(3)
    addFrame.animStep1Tex.AG.Rotation:SetOrder(0)
    addFrame.animStep1Tex.AG.Rotation:SetEndDelay(0)
    addFrame.animStep1Tex.AG.Rotation:SetSmoothing("NONE")
    addFrame.animStep1Tex.AG.Rotation:SetDegrees(-180)

    addFrame.animStep1Tex.AG.Alpha1 = addFrame.animStep1Tex.AG:CreateAnimation("Alpha")
    addFrame.animStep1Tex.AG.Alpha1:SetStartDelay(0)
    addFrame.animStep1Tex.AG.Alpha1:SetDuration(3)
    addFrame.animStep1Tex.AG.Alpha1:SetOrder(1)
    addFrame.animStep1Tex.AG.Alpha1:SetEndDelay(0)
    addFrame.animStep1Tex.AG.Alpha1:SetSmoothing("OUT")
    addFrame.animStep1Tex.AG.Alpha1:SetChange(-1)

    -- 2nd step of animation
    addFrame.animStep2Tex.AG = addFrame.animStep2Tex:CreateAnimationGroup()

    addFrame.animStep2Tex.AG.Alpha0 = addFrame.animStep2Tex.AG:CreateAnimation("Alpha")
    addFrame.animStep2Tex.AG.Alpha0:SetStartDelay(0.5)
    addFrame.animStep2Tex.AG.Alpha0:SetDuration(1)
    addFrame.animStep2Tex.AG.Alpha0:SetOrder(0)
    addFrame.animStep2Tex.AG.Alpha0:SetEndDelay(0)
    addFrame.animStep2Tex.AG.Alpha0:SetSmoothing("IN")
    addFrame.animStep2Tex.AG.Alpha0:SetChange(1)

    addFrame.animStep2Tex.AG.Scale1 = addFrame.animStep2Tex.AG:CreateAnimation("Scale")
    addFrame.animStep2Tex.AG.Scale1:SetScale(0.1, 0.1)
    addFrame.animStep2Tex.AG.Scale1:SetDuration(0.0)
    addFrame.animStep2Tex.AG.Scale1:SetStartDelay(0)
    addFrame.animStep2Tex.AG.Scale1:SetOrder(0)
    addFrame.animStep2Tex.AG.Scale1:SetSmoothing("NONE")

    addFrame.animStep2Tex.AG.Scale2 = addFrame.animStep2Tex.AG:CreateAnimation("Scale")
    addFrame.animStep2Tex.AG.Scale2:SetScale(10, 10)
    addFrame.animStep2Tex.AG.Scale2:SetDuration(1)
    addFrame.animStep2Tex.AG.Scale2:SetStartDelay(0)
    addFrame.animStep2Tex.AG.Scale2:SetOrder(1)
    addFrame.animStep2Tex.AG.Scale2:SetSmoothing("IN_OUT")

    addFrame.animStep2Tex.AG.Alpha1 = addFrame.animStep2Tex.AG:CreateAnimation("Alpha")
    addFrame.animStep2Tex.AG.Alpha1:SetStartDelay(0)
    addFrame.animStep2Tex.AG.Alpha1:SetDuration(4)
    addFrame.animStep2Tex.AG.Alpha1:SetOrder(2)
    addFrame.animStep2Tex.AG.Alpha1:SetEndDelay(0)
    addFrame.animStep2Tex.AG.Alpha1:SetSmoothing("OUT")
    addFrame.animStep2Tex.AG.Alpha1:SetChange(-1)

    -- 3rd step of animation
    addFrame.animStep3Tex.AG = addFrame.animStep3Tex:CreateAnimationGroup()

    addFrame.animStep3Tex.AG.Alpha0 = addFrame.animStep3Tex.AG:CreateAnimation("Alpha")
    addFrame.animStep3Tex.AG.Alpha0:SetDuration(0.1)
    addFrame.animStep3Tex.AG.Alpha0:SetOrder(1)
    addFrame.animStep3Tex.AG.Alpha0:SetEndDelay(0)
    addFrame.animStep3Tex.AG.Alpha0:SetSmoothing("IN")
    addFrame.animStep3Tex.AG.Alpha0:SetChange(1)

    addFrame.animStep3Tex.AG.Scale1 = addFrame.animStep3Tex.AG:CreateAnimation("Scale")
    addFrame.animStep3Tex.AG.Scale1:SetScale(0.1, 0.1)
    addFrame.animStep3Tex.AG.Scale1:SetDuration(0.1)
    addFrame.animStep3Tex.AG.Scale1:SetEndDelay(0)
    addFrame.animStep3Tex.AG.Scale1:SetOrder(1)
    addFrame.animStep3Tex.AG.Scale1:SetSmoothing("NONE")

    addFrame.animStep3Tex.AG.Scale2 = addFrame.animStep3Tex.AG:CreateAnimation("Scale")
    addFrame.animStep3Tex.AG.Scale2:SetScale(15, 15)
    addFrame.animStep3Tex.AG.Scale2:SetDuration(3)
    addFrame.animStep3Tex.AG.Scale2:SetStartDelay(0)
    addFrame.animStep3Tex.AG.Scale2:SetOrder(2)
    addFrame.animStep3Tex.AG.Scale2:SetSmoothing("IN_OUT")

    addFrame.animStep3Tex.AG.Alpha1 = addFrame.animStep3Tex.AG:CreateAnimation("Alpha")
    addFrame.animStep3Tex.AG.Alpha1:SetStartDelay(0)
    addFrame.animStep3Tex.AG.Alpha1:SetDuration(3)
    addFrame.animStep3Tex.AG.Alpha1:SetOrder(2)
    addFrame.animStep3Tex.AG.Alpha1:SetEndDelay(0)
    addFrame.animStep3Tex.AG.Alpha1:SetSmoothing("OUT")
    addFrame.animStep3Tex.AG.Alpha1:SetChange(-1)

    function frame.PlayUnlock()
        frame.animStepAdd1Tex.AG:Stop()
        frame.animStepAdd2Tex.AG:Stop()
        frame.animStepAdd3Tex.AG:Stop()

        frame.animStepAdd1Tex.AG:Play()
        frame.animStepAdd2Tex.AG:Play()
        frame.animStepAdd3Tex.AG:Play()

        addFrame.animStep1Tex.AG:Stop()
        addFrame.animStep2Tex.AG:Stop()
        addFrame.animStep3Tex.AG:Stop()

        addFrame.animStep1Tex.AG:Play()
        addFrame.animStep2Tex.AG:Play()
        addFrame.animStep3Tex.AG:Play()
    end

    frame.UnlockDone = function() end

    function frame.SetUnlockColor(r, g, b)
        frame.animStepAdd1Tex:SetVertexColor(r, g, b)
        frame.animStepAdd2Tex:SetVertexColor(r, g, b)
        frame.animStepAdd3Tex:SetVertexColor(r, g, b)
        addFrame.animStep1Tex:SetVertexColor(r, g, b)
        addFrame.animStep2Tex:SetVertexColor(r, g, b)
        addFrame.animStep3Tex:SetVertexColor(r, g, b)
    end

    addFrame.animStep2Tex.AG.Scale2:SetScript("OnFinished", function()
        frame.UnlockDone()
    end)

end

local function ActiveEffectButtonTemplate(parent)
    local frame = CreateFrame("FRAME", nil, parent)
    frame:SetSize(32, 32)

    frame.text = frame:CreateFontString(nil, "ARTWORK")
    frame.text:SetJustifyH("LEFT")
    frame.text:SetPoint("LEFT", 0, 0)
    frame.text:SetFontObject(GameFontNormalSmall)

    frame.btn = CreateFrame("BUTTON", nil, frame)
    frame.btn:SetSize(32,32)
    frame.btn:SetNormalTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\qualityLight")
    frame.btn:SetHighlightTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\qualityLight")
    frame.btn:SetPoint("LEFT", frame.text, "RIGHT", -6, 0)
    frame.active = 0
    frame.total = 3
    frame.str = "|cffFFFFFF%i|r/%i"
    frame.quality = 1
    frame.tooltip = "Epic"
    frame.btn:SetScript("OnEnter", function(self)
        local _, _, _, qualityColor = GetItemQualityColor(self:GetParent().quality)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("|cffFFFFFFVous avez "..self:GetParent().active.." "..qualityColor..self:GetParent().tooltip.."|r |cffFFFFFFenchantements.|r")
        GameTooltip:AddLine("Vous ne pouvez pas avoir plus de "..self:GetParent().total.." "..qualityColor..self:GetParent().tooltip.."|r enchantements")
        GameTooltip:AddLine("actif en même temps.")
        GameTooltip:Show()
    end)
    frame.btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    frame.btn.BG = frame.btn:CreateTexture(nil, "BACKGROUND")
    frame.btn.BG:SetSize(16,16)
    frame.btn.BG:SetPoint("CENTER")
    frame.btn.BG:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\QualityBorder")

    function frame.UpdateText()
        frame.text:SetText(string.format(frame.str, frame.active, frame.total))
    end

    frame.UpdateText()

    return frame
end

local function StackDisplayOnEnter(self)
    if self.Spell and self.Spell ~= 0 then
        local spellName = GetSpellInfo(self.Spell)
        local Link = "|cff71d5ff|Hspell:"..self.Spell.."|h["..spellName.."]|h|r"
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(Link)
        
        if self.Quality ~= nil then

            if (self.Quality == 5) then
                GameTooltip:AddLine("\nYou can only have one |cffff8000Legendary|r\nenchant active on your character.\n")
            end

            if (self.Quality == 4) then
                GameTooltip:AddLine("\nYou can only have three |cffa335eeEpic|r\nenchants active on your character.\n")
            end

            if self.Quality == 4 and M.EquippedEpicEnchants and M.EquippedEpicEnchants > 3 then
                GameTooltip:AddLine("Active Effects: |cffD000000|r")
                GameTooltip:AddLine("|cffD00000This Mystic Enchant won't\naffect on your character if you have\nmore than 3 applied|r")
            elseif self.Quality >= 5 and M.EquippedLegendaryEnchants and M.EquippedLegendaryEnchants  > 1 then
                
                GameTooltip:AddLine("|cffD00000This Mystic Enchant won't\naffect on your character if you have\nmore than 1 applied|r")
            elseif self.Stack and (self.Stack <= self.MaxStack) then
                GameTooltip:AddLine("Active Effects: |cff00FF00"..self.Stack.."/"..self.MaxStack.."|r")
            elseif self.MaxStack then
                GameTooltip:AddLine("Active Effects: |cffD000000|r")
                GameTooltip:AddLine("|cffD00000This Mystic Enchant won't\naffect on your character if you have\nmore than "..self.MaxStack.." applied|r")
                GameTooltip:AddLine("\nIf you don't have more than |cffFFFFFF"..self.MaxStack.."|r\nenchants of that kind applied,\ntry re-equipping an item")
            end
        end

        GameTooltip:Show()
    end
end

local function EnchantStackDisplayButton_OnModifiedClick(self, button) 
    if ( IsModifiedClick("CHATLINK") ) then
        if self.Spell and self.Spell ~= 0 then
            local spellName = GetSpellInfo(self.Spell)
            local Link = "|cff71d5ff|Hspell:"..self.Spell.."|h["..spellName.."]|h|r"
            if ( Link ) then
                ChatEdit_InsertLink(Link);
            end
        end
        return;
    end
end

local function EnchantTemplate_Max(btn)
    btn.Icon:SetVertexColor(1, 0, 0, 1)
    btn:GetNormalTexture():SetVertexColor(1, 0, 0, 1)
    btn.Maxed:Show()
end

local function EnchantTemplate_Normalize(btn)
    btn.Icon:SetVertexColor(1, 1, 1, 1)
    if (btn:GetNormalTexture()) then
        btn:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
    end
    btn.Maxed:Hide()
end

local function CollectionEnchantTemplate(parent)
    local btn = CreateFrame("Button", nil, parent, nil)
    btn:SetSize(36, 36)
    btn:SetNormalTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\EnchantBorder")
    btn:SetHighlightTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\EnchantBorder_highlight")
    btn:GetHighlightTexture():ClearAllPoints()
    btn:GetHighlightTexture():SetSize(52,52)
    btn:GetHighlightTexture():SetPoint("CENTER", 0, 0)
    btn:Hide()

    btn.Icon = btn:CreateTexture(nil, "BORDER", nil)
    btn.Icon:SetSize(28,28)
    SetPortraitToTexture(btn.Icon, "Interface\\Icons\\inv_chest_samurai")
    btn.Icon:SetPoint("CENTER", 0, 0)

    btn.Maxed = btn:CreateTexture(nil, "OVERLAY", nil)
    btn.Maxed:SetSize(28,28)
    btn.Maxed:SetPoint("CENTER", 0, 0)
    btn.Maxed:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\RedSign")
    btn.Maxed:Hide()

    btn:SetScript("OnEnter", StackDisplayOnEnter)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    btn:SetScript("OnClick", function(self, button)
        if ( IsModifiedClick() ) then
            EnchantStackDisplayButton_OnModifiedClick(self, button);
        end
    end)

    CreateUnlockAnimation(btn, {128, 128})

    return btn
end

local function SlotButton_OnDisable(self)
    self.BG:SetDesaturated(true)
    self.Icon:SetDesaturated(true)
    self.breathing = false
end

local function SlotButton_OnEnable(self)
    self.BG:SetDesaturated(false)
    self.Icon:SetDesaturated(false)
    self.breathing = true
end

local function SlotButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    self:RegisterEvent("MODIFIER_STATE_CHANGED")

    local slotId, _, checkRelic = GetInventorySlotInfo(self.Slot)
    local hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", slotId);
    if ( not hasItem ) then
        GameTooltip:SetText("L'emplacement est vide");
    end

    CursorUpdate(self);
end

local function SlotButton_OnLeave(self)
    self:UnregisterEvent("MODIFIER_STATE_CHANGED")
    GameTooltip:Hide()
    ResetCursor()
end

local function SlotButton_OnEvent(self, event)
    if not(self.Slot) then
        return
    end

    local slotId = GetInventorySlotInfo(self.Slot)
    local itemId = GetInventoryItemID("player", slotId)

    if event == "PLAYER_EQUIPMENT_CHANGED" then
        if (itemId) then
            local texture = GetInventoryItemTexture("player", slotId)
            local quality = GetInventoryItemQuality("player", slotId) or 0
            self.Icon:Show()
            self.Icon:SetTexture(texture)

            if (quality >= REFORGE_QUALITY_MIN) and (quality <= REFORGE_QUALITY_MAX) then
                self.Icon:SetDesaturated(false)
                self.breathing = true
            else
                self.Icon:SetDesaturated(true)
                self.breathing = false
            end
        else
            self.breathing = false
            self.Icon:Hide()
        end

        if (GLOBAL_BREATHING_ENABLED) and (self.breathing) then
            self.AnimatedTex.AG:Stop()
            self.AnimatedTex.AG:Play()
            self.AnimatedTex:Show()
        else
            self.AnimatedTex:Hide()
        end
        return
    end

    if ( event == "MODIFIER_STATE_CHANGED" ) then
        if ( self:IsMouseOver() ) then
            self:GetScript("OnEnter")(self)
        end

        return
    end
end

local function SlotButtonSetQuality(self, quality)
    self:SetNormalTexture(PaperDollEnchantQualitySettings[quality])
end

local function SlotButtonHandleMax(self)

    if not(self.Spell) or not(self.Stack) then
        return false
    end

    if (self.Stack > self.MaxStack) then
        EnchantTemplate_Max(self)
    end
end

local function HandleCollectionSlot(self, enchantID)
    local RE = GetREData(enchantID)
    local spellID = RE.spellID
    local quality = RE.quality
    EnchantTemplate_Normalize(self)

    local _, _, icon = GetSpellInfo(spellID)

    if not icon then 
        icon = UNKNOWN_ENCHANT_ICON
    end

    self.Spell = spellID
    self:Show()
    SlotButtonSetQuality(self, quality)
    SetPortraitToTexture(self.Icon, icon)
    SlotButtonHandleMax(self)
end

local function ClearData()
    ACTIVE_ITEM = nil
    ACTIVE_ENCHANT = nil
    ITEM_BAG = nil
    ITEM_SLOT = nil
    CAN_REFUND = false
end

local function SetExtractButtonEnabled(btn, enabled)
    if enabled then
        btn:Enable()
        M.ControlFrame.ExtractButton.TooltipFrame:Hide()
    else
        SetButtonPulse(btn, 0, 1)
        btn:Disable()
        M.ControlFrame.ExtractButton.TooltipFrame:Show()
    end
end

local function DisenchantButtonTokenCheck(self)
    if not DID_GOSSIP_ALTAR then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_NO_GOSSIP
        SetExtractButtonEnabled(self, false)
        return
    end
    if not GetItemCount(ReforgeExtract) then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_NO_EXTRACT
        SetExtractButtonEnabled(self, false)
        return
    end

    if GetItemCount(ReforgeExtract) <= 0 then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_NO_EXTRACT
        SetExtractButtonEnabled(self, false)
        return
    end

    if not ACTIVE_ITEM then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_NO_ITEM
        SetExtractButtonEnabled(self, false)
        return
    end

    if not ACTIVE_ENCHANT then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_NO_ENCHANT
        SetExtractButtonEnabled(self, false)
        return
    end

    local _, _, quality = GetItemInfo(ACTIVE_ITEM)
    -- We have an item but can't determine its quality for some reason? Just enable the button and let the server resolve
    if not quality then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_DEFAULT
        SetExtractButtonEnabled(self, true)
        return
    end

    if quality <= REFORGE_QUALITY_MIN then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_LOW_QUALITY
        SetExtractButtonEnabled(self, false)
        return
    end

    if quality > REFORGE_QUALITY_MAX then
        EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_HIGH_QUALITY
        SetExtractButtonEnabled(self, false)
        return
    end

    EXTRACT_TOOLTIP = EXTRACT_TOOLTIP_DEFAULT
    SetExtractButtonEnabled(self, true)
end

local function RollButtonCheck(self,elapsed)
    if ACTIVE_ITEM and M.Initializated then
        local _, _, quality = GetItemInfo(ACTIVE_ITEM)
        if quality > REFORGE_QUALITY_MIN then
            self:Enable()
        else
            self:Disable()
        end
    else
        self:Disable()
    end
end

local function EnableBreathing()
    GLOBAL_BREATHING_ENABLED = true

    for slot, btn in pairs(CollectionSlotMap) do
        if (btn:IsEnabled() == 1) then
            if (btn.breathing) then
                btn.AnimatedTex.AG:Stop()
                btn.AnimatedTex.AG:Play()
                btn.AnimatedTex:Show()
            end
        end
    end
    M.EnchantFrame.BreathTex.AG:Stop()
    M.EnchantFrame.BreathTex.AG:Play()
    M.EnchantFrame.BreathTex:Show()
end

local function DisableBreathing()
    GLOBAL_BREATHING_ENABLED = false

    for slot, btn in pairs(CollectionSlotMap) do
        btn.AnimatedTex:Hide()
    end

    M.EnchantFrame.BreathTex:Hide()
end

local function ReforgeItemCost(item)
	local _, _, _, ilvl = GetItemInfo(item)

    if not balanceToken or balanceToken <= 0 then
        return REFORGE_GOLD_COST, true
    else
        return REFORGE_RUNE_COST, false
    end
end

local function EnchantItemCost(item)
    local cost = nil

    if not M.CollectionsEnchant then
        return cost
    end


    local RE = GetREData(M.CollectionsEnchant)

    if not RE then 
        return cost
    end

    if RE.quality <= 2 then
        if balanceOrbs < ENCHANT_GREEN_ORB_COST then 
            return ENCHANT_GREEN_GOLD_COST, true
        else
            return ENCHANT_GREEN_ORB_COST, false
        end

    elseif RE.quality == 3 then
        if balanceOrbs < ENCHANT_BLUE_ORB_COST then 
            return ENCHANT_BLUE_GOLD_COST, true
        else
            return ENCHANT_BLUE_ORB_COST, false
        end

    elseif RE.quality == 4 then
        if balanceOrbs < ENCHANT_PURPLE_ORB_COST then 
            return ENCHANT_PURPLE_GOLD_COST, true
        else
            return ENCHANT_PURPLE_ORB_COST, false
        end

    elseif RE.quality >= 5 then 
        if balanceOrbs < ENCHANT_LEGENDARY_ORB_COST then 
            return ENCHANT_LEGENDARY_GOLD_COST, true
        else
            return ENCHANT_LEGENDARY_ORB_COST, false
        end
    end
end

local function ClearControlFrame(self)
    for slot, btn in pairs(CollectionSlotMap) do
        btn:SetChecked(false)
    end

    M.ControlFrame.TokenFrame:Hide()
    M.ControlFrame.MoneyFrame:Hide()
    M.EnchantFrame.Icon:SetTexture("Interface\\Icons\\spell_frost_stun")
    M.EnchantFrame.Icon:SetVertexColor(0.5, 0, 0.5, 0.5)
    M.EnchantFrame.EnchName:SetText("Faites glisser un objet ici")
    M.EnchantFrame.ItemName:SetText("Utiliser l'autel antique d'enchantement.")
    M.EnchantFrame.Enchant:Hide()
    ClearData()
    CursorUpdate(self)
    RollButtonCheck(M.ControlFrame.RollButton)
    DisenchantButtonTokenCheck(M.ControlFrame.ExtractButton)
    M.EnchantFrame.BG:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\LabelTop")

    if (M.Initializated) then
        EnableBreathing()
    end
end

local function SlotButton_OnClick(self)
    local link = GetInventoryItemLink("player", self.SlotID)
    local isModifiedClick = false

    if ( IsModifiedClick("CHATLINK") ) then
        if (link) then
            ChatEdit_InsertLink(link)
        end
        isModifiedClick = true
    end
    
    local itemBagSaved = ITEM_BAG
    local itemSlotSaved = ITEM_SLOT
    ClearControlFrame(self)
    
    if not(link) then
        return
    end
    if DID_GOSSIP_ALTAR and (M.Initializated and self.SlotID) then
        if itemBagSaved and itemSlotSaved and (itemBagSaved == 255) and (itemSlotSaved == self.SlotID) and not(isModifiedClick) then
            return
        end
        ITEM_BAG_TEMP = 255
        ITEM_SLOT_TEMP = self.SlotID
        
        local enchantID = GetREInSlot(ITEM_BAG_TEMP, ITEM_SLOT_TEMP)
        local cost, useGold = ReforgeItemCost(link)
        M.PlaceItem(link, enchantID, {cost, useGold}, ITEM_BAG_TEMP, ITEM_SLOT_TEMP)

    else
        if not(isModifiedClick) then
            StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "Vous avez besnoin d'un |cffFFFFFFAutel antique d'enchantement|r pour utiliser cette option."
            StaticPopup_Show("ASC_ERROR_TIMEOUT")
        end
    end
end

local function CollectionSlotButtonTemplate(parent)
    if not(parent.buttonInfo) then
        parent.buttonInfo = 1
    else
        parent.buttonInfo = parent.buttonInfo + 1
    end

    local btn = CreateFrame("CheckButton", nil, parent, nil)
    btn:SetSize(42, 42)
    btn:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

    btn:SetNormalTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\Slot2")
    btn:SetCheckedTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
    btn:SetHighlightTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\slottemplateHighlight")
    btn:SetPushedTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\Slot2Pushed")
    btn:SetDisabledTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\Slot2")
    btn:GetDisabledTexture():SetDesaturated(true)

    btn.BG = btn:CreateTexture(nil, "BACKGROUND")
    btn.BG:SetSize(56,56)
    btn.BG:SetPoint("CENTER", 0, -1)
    btn.BG:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\slottemplateBG")

    btn.Icon = btn:CreateTexture(nil, "BORDER")
    btn.Icon:SetSize(36,36)
    btn.Icon:SetPoint("CENTER", 0, 0)
    btn.Icon:SetTexture("Interface\\Icons\\inv_misc_book_09")

    btn.Enchant = CollectionEnchantTemplate(btn)

    btn:SetScript("OnClick", SlotButton_OnClick)
    btn:SetScript("OnDisable", SlotButton_OnDisable)
    btn:SetScript("OnEnable", SlotButton_OnEnable)
    btn:SetScript("OnEnter", SlotButton_OnEnter)
    btn:SetScript("OnLeave", SlotButton_OnLeave)
    btn:SetScript("OnEvent", SlotButton_OnEvent)

    btn.AnimatedTex = btn:CreateTexture(nil, "OVERLAY")
    btn.AnimatedTex:SetAllPoints()
    btn.AnimatedTex:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
    btn.AnimatedTex:SetAlpha(0)
    btn.AnimatedTex:SetBlendMode("ADD")
    btn.AnimatedTex:Hide()

    btn.AnimatedTex.AG = btn.AnimatedTex:CreateAnimationGroup()

    btn.AnimatedTex.AG.Alpha0 = btn.AnimatedTex.AG:CreateAnimation("Alpha")
    btn.AnimatedTex.AG.Alpha0:SetStartDelay(0)
    btn.AnimatedTex.AG.Alpha0:SetDuration(1)
    btn.AnimatedTex.AG.Alpha0:SetOrder(0)
    btn.AnimatedTex.AG.Alpha0:SetEndDelay(0)
    btn.AnimatedTex.AG.Alpha0:SetSmoothing("IN")
    btn.AnimatedTex.AG.Alpha0:SetChange(1)

    btn.AnimatedTex.AG.Alpha1 = btn.AnimatedTex.AG:CreateAnimation("Alpha")
    btn.AnimatedTex.AG.Alpha1:SetStartDelay(0)
    btn.AnimatedTex.AG.Alpha1:SetDuration(1)
    btn.AnimatedTex.AG.Alpha1:SetOrder(0)
    btn.AnimatedTex.AG.Alpha1:SetEndDelay(0)
    btn.AnimatedTex.AG.Alpha1:SetSmoothing("IN_OUT")
    btn.AnimatedTex.AG.Alpha1:SetChange(-1)

    btn.AnimatedTex.AG:SetScript("OnFinished", function()
        btn.AnimatedTex.AG:Play()
    end)

    btn.AnimatedTex.AG:Play()
    btn.breathing = false

    return btn
end
-------------------------------------------------------------------------------
--                            Collection Template                            --
-------------------------------------------------------------------------------

local function ReforgeCheck()
    local _, _, quality = GetItemInfo(ACTIVE_ITEM)
    if quality < REFORGE_QUALITY_MIN or quality > REFORGE_QUALITY_MAX then 
        StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "L'objet doit être de qualité rare ou supérieure "
        StaticPopup_Show("ASC_ERROR_TIMEOUT")
        return false
    elseif M.CollectionsEnchant and M.CollectionsEnchant == ACTIVE_ENCHANT then
        StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "Vous avez déjà cet enchantement sur votre objet."
        StaticPopup_Show("ASC_ERROR_TIMEOUT")
        return false
    elseif M.CollectionsEnchant and M.CollectionsEnchant ~= 0 and ACTIVE_ITEM and M.Initializated then
        return true
    else
        return false
    end
end

local function RefundEnchant()
    if (ACTIVE_ITEM and ITEM_BAG and ITEM_SLOT and M.CollectionsEnchant) then
        PlaySound("igMainMenuOptionCheckBoxOn")
        --AIO.Handle("EnchantReRoll", "RefundEnchant", ITEM_BAG, ITEM_SLOT, M.CollectionsEnchant)
    end
end

local function RefundFullCheck()
    if CAN_REFUND then
        local RE = GetREData(ACTIVE_ENCHANT)
        local activeQuality = RE.quality
        local currQuality = GetREData(M.CollectionsEnchant).quality

        if (activeQuality and currQuality) and (currQuality <= activeQuality) then
            M.ConfirmDisenchant.text:SetText("Collection Reforge Cost: |cff00FF00FREE|r\nReforge Success Chance: |cffFFFFFF100%|r\n\nAre you sure you want to continue?\n")
        end

        M.ConfirmDisenchant.Mode = "REFUND"
    end
end

local function UpdateCollectionReforgeDialogue()
    if not ACTIVE_ITEM then
        return false
    end

    local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(ACTIVE_ITEM)
    local cost, useGold = EnchantItemCost(ACTIVE_ITEM)

    if useGold then
        local gold, silver, copper = GetGoldForMoney(cost)
        M.ConfirmDisenchant.text:SetText("Collection Reforge Cost: |cffFFFFFF"..gold.." |TInterface\\MONEYFRAME\\UI-GoldIcon.blp:11:11:0:-5|t "..silver.." |TInterface\\MONEYFRAME\\UI-SilverIcon.blp:11:11:0:-5|t "..copper.." |TInterface\\MONEYFRAME\\UI-CopperIcon.blp:11:11:0:-5|t|r\nReforge Success Chance: |cffFFFFFF"..M.SuccessChance.."%|r\n\nAre you sure you want to continue?\n")
        M.ConfirmDisenchant.Alert:SetTexture(texture) 
    else
        M.ConfirmDisenchant.text:SetText("Collection Reforge Cost: |cffFFFFFF"..cost.." |TInterface\\Icons\\inv_custom_CollectionRCurrency.blp:11:11:0:-5|t|r\nReforge Success Chance: |cffFFFFFF100%|r\n\nAre you sure you want to continue?\n")
        M.ConfirmDisenchant.Alert:SetTexture(texture) 
    end

    M.ConfirmDisenchant.Alert:SetVertexColor(1, 1, 1, 1)

    RefundFullCheck()
end

local function PrepareCollectionReforge()
    if not(ReforgeCheck()) then
        return false
    end

    M.ConfirmDisenchant.Mode = "COLLECTIONREFORGE"

    HandleCollectionSlot(M.ConfirmDisenchant.Enchant, M.CollectionsEnchant)
    UpdateCollectionReforgeDialogue()

    M.ConfirmDisenchant:Show()
end

local function ItemTemplate_OnDisable(self)
    self.TextNormal:SetFontObject(GameFontDisable)
end

local function ItemTemplate_OnEnable(self)
    self.TextNormal:SetFontObject(GameFontNormal)
end

local function ItemTemplate_OnEnter(self)
    if self.Spell == nil then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -13, -50)
    GameTooltip:SetHyperlink(self.Spell)
    GameTooltip:Show()
end

local function ItemTemplate_OnLeave()
    GameTooltip:Hide()
end

local function ItemTemplate_fake_OnClick(self)
    if ( IsModifiedClick("CHATLINK") ) then
        ChatEdit_InsertLink(self.Spell)
    end
end

local function ItemTemplate_OnClick(self)
    if ( IsModifiedClick("CHATLINK") ) then
        ChatEdit_InsertLink(self.Spell)
        return
    end
    
    PlaySound("GAMEABILITYACTIVATE")

    if (GLOBAL_BC_CHOOSE_ENCHANT) then
        HandleEnchantAddToBuildCreator(self.Spell)
        return
    end

    if (self.Enchant) then
        M.CollectionsEnchant = self.Enchant

        if (ITEM_BAG and ITEM_SLOT) then
            PrepareCollectionReforge()
        else
            StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "Vous devez avoir un objet actif pour appliquer cet enchantement."
            StaticPopup_Show("ASC_ERROR_TIMEOUT")
        end
    else
        M.CollectionsEnchant = 0
    end
end

local function CollectionItemTemplate(parent)
    if not(parent.itemCount) then
        parent.itemCount = 1
    else
        parent.itemCount = parent.itemCount + 1
    end

    local index = parent.itemCount
    local btn = CreateFrame("FRAME", "CollectionItemFrame"..index, parent, nil)
    btn:SetSize(128,64)

    btn.BackgroundTexture = btn:CreateTexture("CollectionItemFrame"..index..".BackgroundTexture", "BORDER")
    btn.BackgroundTexture:SetSize(35,35)
    btn.BackgroundTexture:SetTexture("Interface\\Icons\\INV_Chest_Samurai")
    btn.BackgroundTexture:SetPoint("LEFT", btn, 0,0)

    btn.BG = btn:CreateTexture("CollectionItemFrame"..index..".BG", "BACKGROUND")
    btn.BG:SetSize(246,78)
    btn.BG:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\EBG")
    btn.BG:SetPoint("CENTER", 32, -10.5)

    btn.Button = CreateFrame("Button", "CollectionItemFrame"..index..".Button", btn, nil)
    btn.Button:SetSize(170, 85)
    btn.Button:SetPoint("CENTER",0,0)
    btn.Button:EnableMouse(true)
    --btn.Button:SetNormalTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\CollectionsItemNormal")
    --btn.Button:SetDisabledTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\CollectionsItemDisabled")
    --btn.Button:SetPushedTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\CollectionsItemPushed")
    --btn.Button:SetHighlightTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\CollectionsItemNormal")
    btn.Button:Disable()
    --btn.Button:GetDisabledTexture():SetVertexColor(0.6,0.6,0.6,1)
    btn.IconBorder = btn:CreateTexture("CollectionItemFrame"..index..".IconBorder", "ARTWORK")
    btn.IconBorder:SetSize(48,48)
    btn.IconBorder:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\BorderNewGreen")
    btn.IconBorder:SetPoint("LEFT", btn, -7,0)

    btn.IconHighlight = btn:CreateTexture("CollectionItemFrame"..index..".IconHighlight", "OVERLAY")
    btn.IconHighlight:SetSize(64,64)
    btn.IconHighlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\EnchantBorder_highlight")
    btn.IconHighlight:SetPoint("CENTER", btn.IconBorder, 0,0)
    btn.IconHighlight:SetBlendMode("ADD")
    btn.IconHighlight:Hide()
    --btn:SetNormalTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\EnchantBorder")
    --btn:SetHighlightTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\EnchantBorder_highlight")

    btn.Button_fake = CreateFrame("Button", "CollectionItemFrame"..index..".Button_fake", btn.Button , nil)
    btn.Button_fake:SetSize(170, 85)
    btn.Button_fake:SetPoint("CENTER",0,0)
    btn.Button_fake:EnableMouse(true)

    btn.Button.TextNormal = btn.Button:CreateFontString("CollectionItemFrame"..index..".Button.TextNormal")
    btn.Button.TextNormal:SetSize(100, 45)
    btn.Button.TextNormal:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    btn.Button.TextNormal:SetFontObject(GameFontNormal)
    btn.Button.TextNormal:SetPoint("CENTER", 26, 1)
    btn.Button.TextNormal:SetShadowOffset(0,-1)
    btn.Button.TextNormal:SetText("Enchant Effect Name")
    btn.Button.TextNormal:SetJustifyH("LEFT")

    btn.Button_fake:SetScript("OnEnter", ItemTemplate_OnEnter)
    btn.Button_fake:SetScript("OnClick", ItemTemplate_fake_OnClick)
    btn.Button_fake:SetScript("OnLeave", ItemTemplate_OnLeave)
    btn.Button:SetScript("OnDisable", ItemTemplate_OnDisable)
    btn.Button:SetScript("OnEnable", ItemTemplate_OnEnable)
    btn.Button:SetScript("OnEnter", function(self)
        self:GetParent().IconHighlight:Show()
        self.TextNormal:SetTextColor(1,1,1,1)
        ItemTemplate_OnEnter(self)
    end)
    btn.Button:SetScript("OnLeave", function(self)
        self:GetParent().IconHighlight:Hide()
        self.TextNormal:SetTextColor(unpack(self.textColor))
        ItemTemplate_OnLeave(self)
    end)
    btn.Button:SetScript("OnClick", ItemTemplate_OnClick)

    btn.Button:SetScript("OnMouseUp", function(self)
        btn.Button.TextNormal:SetPoint("CENTER", 26, 1)
    end)

    btn.Button:SetScript("OnMouseDown", function(self)
        btn.Button.TextNormal:SetPoint("CENTER", 28, -1)
    end)

    btn:Hide()
    return btn
end
-------------------------------------------------------------------------------
--                              Base Scripts                                 --
-------------------------------------------------------------------------------
local function qsortSpecial(t, lo, hi)
    if lo > hi then
        return
    end
    local p = lo
    for i=lo+1, hi do
        if (t[i].quality < t[lo].quality) then -- here we compare quality of enchants
            p = p + 1
            t[p], t[i] = t[i], t[p]
        end
    end
    t[p], t[lo] = t[lo], t[p]
    qsortSpecial(t, lo, p-1)
    qsortSpecial(t, p+1, hi)
end

local function UnlockRefund(canRefund)
    if canRefund then
        CAN_REFUND = true
        --M.EnchantFrame.Enchant.Refund:Show()
    else
        CAN_REFUND = false
        M.EnchantFrame.Enchant.Refund:Hide()
    end
end

local function GetDisabledColoredText(color)
    local r, g, b = unpack(color)
    r = max(r/2, 0)
    g = max(g/2, 0)
    b = max(b/2, 0)

    return {r, g, b}
end

local function UpdateRerollCost(cost)
    if not(ACTIVE_ITEM) or not(M.Initializated) then
        return false
    end

    if cost[2] then
        MoneyFrame_Update(M.ControlFrame.MoneyFrame, cost[1])
        M.ControlFrame.TokenFrame:Hide()
        M.ControlFrame.MoneyFrame:Show()
    else
        M.ControlFrame.MoneyFrame:Hide()
        M.ControlFrame.TokenFrame:Show()
        M.ControlFrame.TokenFrame.TokenText:SetText("Coût: |cffFFFFFF"..cost[1].."|r")
    end
end

local function GetRequiredRollsForLevel(level)
    if level == 0 then
        return 1
    end
    
    return floor(354 * level + 7.5 * level * level)
end

local function UpdateProgress(level, progress)
    local lastRequired = 0
    local maxRequired = 1

    if not tonumber(level) or not tonumber(progress) then
        return
    end

    if level > 0 then
        lastRequired = GetRequiredRollsForLevel(level - 1)
        maxRequired = GetRequiredRollsForLevel(level)
    end

    --print("Progress Update: Last Required:", lastRequired, "Max Required:",  maxRequired, "Current:", progress)
    M.ProgressBar:SetMinMaxValues(lastRequired, maxRequired)
    M.ProgressBar:SetValue(progress)
    M.LevelFrame.TitleText:SetText(level)
    M.ProgressBar.Text:SetText(string.format("Niveau %i", level))

    if M.CDB then
        M.CDB.EnchantProgress = progress or 0
        M.CDB.EnchantLevel = level or 0
        M.CDB.LastRequired = lastRequired or 0
        M.CDB.NextRequired = maxRequired or 1
    end
end

local function UpdateMysticRuneBalance()
    local OldBalanceExtract = balanceExtract
    balanceToken = GetItemCount(ReforgeToken)
    balanceExtract = GetItemCount(ReforgeExtract)
    balanceOrbs = GetItemCount(ReforgeOrb)

    if not(balanceToken) then
        balanceToken = 0
    end

    if not(balanceExtract) then
        balanceExtract = 0
    end

    if not(balanceOrbs) then
        balanceOrbs = 0
    end

    M.ControlFrame.Currency.ExtractText:SetText(string.format("Mystic Extract: |cffFFFFFF%i|r", balanceExtract))
    M.ControlFrame.Currency.TokenText:SetText(string.format("Mystic Rune: |cffFFFFFF%i|r", balanceToken))
    M.ControlFrame.Currency.OrbText:SetText(string.format("Mystic Orb: |cffFFFFFF%i|r", balanceOrbs))
end

local function PlaceItem(self, flag)
    local infoType, _, itemLink = GetCursorInfo()
    if DID_GOSSIP_ALTAR and ((infoType == "item") or flag) and ITEM_BAG_TEMP and ITEM_SLOT_TEMP and M.Initializated then
        ClearControlFrame()

        local enchantID = GetREInSlot(ITEM_BAG_TEMP, ITEM_SLOT_TEMP)
        local cost, useGold = ReforgeItemCost(itemLink)
        M.PlaceItem(itemLink, enchantID, { cost, useGold }, ITEM_BAG_TEMP, ITEM_SLOT_TEMP)
        return true

    elseif not(ACTIVE_ITEM) then
        StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "|cffFFFFFFFaites glisser|r un objet et utilisez |cffFFFFFFl'Autel d'enchantement pour utiliser cette option."
        StaticPopup_Show("ASC_ERROR_TIMEOUT")
        ClearControlFrame()
        return false
    end

    ClearControlFrame()
end

local function CollectionsOnHide()
    DID_GOSSIP_ALTAR = false
    GLOBAL_BC_CHOOSE_ENCHANT = false -- to avoid issues
    M.Initializated = false
    DisableBreathing()
    M.ConfirmDisenchant:Hide()
    ClearControlFrame()
end

local function GetLastLockedItem(bag, slot)
    ITEM_BAG_TEMP = bag
    ITEM_SLOT_TEMP = slot
    if (bag and (slot == nil)) then
        ITEM_BAG_TEMP = 255
    end
end

local function PrepareReforge(self)
    if (ACTIVE_ITEM and ITEM_BAG and ITEM_SLOT) and (self:IsEnabled() == 1) then
        if balanceToken == 0 then 
            if GetMoney() < ReforgeItemCost(ACTIVE_ITEM) then 
                SendSystemMessage("Vous n'avez pas assez d'or pour reforger cet objet")
                return
            end
        end
        PlaySound("igMainMenuOptionCheckBoxOn")

        -- double check we haven't swapped the items around real quick
        if ITEM_BAG == 255 then 
            local itemLink = GetInventoryItemLink("player", ITEM_SLOT)
            if ACTIVE_ITEM ~= itemLink then
                return 
            end
        else
            local _, _, _, _, _, _, itemLink = GetContainerItemInfo(ITEM_BAG, ITEM_SLOT)
            if ACTIVE_ITEM ~= itemLink then
                return
            end
        end
        --[[if ITEM_BAG == 255 then
            print("[Request] Inventory Reforge Slot:", ITEM_SLOT, GetInventoryItemLink("player", ITEM_SLOT))
        else
            print("[Request] Bag Reforge Bag:", ITEM_BAG, "Slot:", ITEM_SLOT, GetContainerItemLink(ITEM_BAG, ITEM_SLOT))
        end]]
        RequestSlotReforgeEnchantment(ITEM_BAG, ITEM_SLOT)
    end
end

local function CollectionReforge()
    if (ACTIVE_ITEM and ITEM_BAG and ITEM_SLOT and M.CollectionsEnchant) then
        -- check for cost here
        PlaySound("igMainMenuOptionCheckBoxOn")
        RequestSlotReforgeEnchantment(ITEM_BAG, ITEM_SLOT, M.CollectionsEnchant)
    end
end

local function DisenchantItem()
    if GetItemCount(ReforgeExtract) and (GetItemCount(ReforgeExtract) > 0) then
        if (ACTIVE_ITEM and ITEM_BAG and ITEM_SLOT and ACTIVE_ENCHANT) then
            if IsReforgeEnchantmentKnown(ACTIVE_ENCHANT) then
                SendSystemMessage("Vous connaissez déjà cet enchantement")
                return
            end
            PlaySound("igMainMenuOptionCheckBoxOn")
            RequestSlotReforgeExtraction(ITEM_BAG, ITEM_SLOT)
            ClearControlFrame()
        end
    else
        SendSystemMessage("Vous n'avez pas assez de Mystic Extract pour désenchanter cet objet ")
    end
end

local function PrepareDisenchant()
    if not(ACTIVE_ITEM or ITEM_BAG or ITEM_SLOT or not ACTIVE_ENCHANT) then
        return false
    end

    local Type = GetCursorInfo()

    if Type and (Type == "item") then
        return false
    end

    local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(ACTIVE_ITEM)

    M.ConfirmDisenchant.Mode = "DISENCHANT"
    M.ConfirmDisenchant:Show()
    M.ConfirmDisenchant.text:SetText("Êtes-vous sûr de vouloir détruire\nl'Enchantement mystique de l'objet suivant:\n(Cela supprimera l'enchantement de l'objet) \n|CffFF0000(Cela DÉTRUIRA l'objet)|r\n"..link)
    M.ConfirmDisenchant.Alert:SetTexture(texture) 
    M.ConfirmDisenchant.Alert:SetVertexColor(1, 0, 0, 1)
    HandleCollectionSlot(M.ConfirmDisenchant.Enchant, ACTIVE_ENCHANT)
end

local function EnchantShowDisenchantHint(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    for _, line in ipairs(EXTRACT_TOOLTIP) do
        GameTooltip:AddLine(line)
    end
    GameTooltip:Show()
end

local function EnchantShowLink(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if (ACTIVE_ITEM) then
        GameTooltip:SetHyperlink(ACTIVE_ITEM)
    else
        GameTooltip:SetText("Faites glisser un objet ici pour le reforger\nou pour extraire un Enchantement Mystique.");
    end
    GameTooltip:Show()
end

local function UpdateListButtons(pagenumber)
    for i = 1, 15 do 
        _G["CollectionItemFrame"..i]:Hide()
    end

    local listtodisplay = {}

    local StartListValues = pagenumber*M.MaxEcnhantsPerPage-(M.MaxEcnhantsPerPage-1)
    local EndListValues = pagenumber*M.MaxEcnhantsPerPage

    if (#M.CurrentList < EndListValues) then
        EndListValues = #M.CurrentList
    end

    for i = StartListValues, EndListValues do
        table.insert(listtodisplay, M.CurrentList[i])
    end

    local button_progress = 1

    while (button_progress <= #listtodisplay) do
        local RE = GetREData(listtodisplay[button_progress].enchantID)
        local EnchantEntry = RE.enchantID
        local spellID = RE.spellID
        local EnchantKnown = RE.known
        local spellName, _, spellIcon = GetSpellInfo(spellID)
        local quality = RE.quality
        local enchantColor = M.EnchantQualitySettings[RE.quality][1]

        if not(spellName) then
            SendSystemMessage("|cffFFFF00S'il vous plaît, mettez à jour votre patch. Le client ne peut pas charger le sort "..spellID.." à utiliser dans la collection des enchantements|r")
            return false
        end

        -- lets cache the text and desc on our way by
        if not ENCH_SPELLTEXTDATA[spellID] then
            ENCH_SPELLTEXTDATA[spellID] = { spellName, GetSpellDescription(spellID) }
        end

        SetPortraitToTexture(_G["CollectionItemFrame"..button_progress..".BackgroundTexture"], spellIcon)

        if (quality) then
            if EnchantKnown then
                _G["CollectionItemFrame"..button_progress..".Button"].textColor = M.EnchantQualitySettings[quality][4]
            else
                _G["CollectionItemFrame"..button_progress..".Button"].textColor = GetDisabledColoredText(M.EnchantQualitySettings[quality][4])
            end
        else
            _G["CollectionItemFrame"..button_progress..".Button"].textColor = {1, 1, 1}
        end

        if (EnchantKnown) then
            _G["CollectionItemFrame"..button_progress..".Button"]:Enable()
            _G["CollectionItemFrame"..button_progress..".Button_fake"]:Hide()
            _G["CollectionItemFrame"..button_progress..".Button.TextNormal"]:SetFontObject(GameFontNormal)
            _G["CollectionItemFrame"..button_progress..".Button.TextNormal"]:SetTextColor(unpack(_G["CollectionItemFrame"..button_progress..".Button"].textColor))
            _G["CollectionItemFrame"..button_progress..".BackgroundTexture"]:SetVertexColor(1, 1, 1, 1)
            _G["CollectionItemFrame"..button_progress..".Button"].Enchant = EnchantEntry
            _G["CollectionItemFrame"..button_progress..".IconBorder"]:SetVertexColor(1, 1, 1, 1)
            --_G["CollectionItemFrame"..button_progress..".Button"]:SetNormalTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\CollectionsItemNormal")
        else
            _G["CollectionItemFrame"..button_progress..".Button_fake"]:Show()
            _G["CollectionItemFrame"..button_progress..".Button"]:Disable()
            _G["CollectionItemFrame"..button_progress..".Button.TextNormal"]:SetFontObject(GameFontDisable)
             _G["CollectionItemFrame"..button_progress..".Button.TextNormal"]:SetTextColor(unpack(_G["CollectionItemFrame"..button_progress..".Button"].textColor))
            _G["CollectionItemFrame"..button_progress..".IconBorder"]:SetVertexColor(0.4, 0.4, 0.4, 1)
            _G["CollectionItemFrame"..button_progress..".BackgroundTexture"]:SetVertexColor(0.4, 0.4, 0.4, 0.8)
        end
        _G["CollectionItemFrame"..button_progress..".Button"].Spell = "|cff71d5ff|Hspell:"..spellID.."|h["..spellName.."]|h|r"
        _G["CollectionItemFrame"..button_progress..".Button_fake"].Spell = "|cff71d5ff|Hspell:"..spellID.."|h["..spellName.."]|h|r"
        _G["CollectionItemFrame"..button_progress..".Button.TextNormal"]:SetText(spellName)
        _G["CollectionItemFrame"..button_progress..".IconBorder"]:SetTexture(PaperDollEnchantQualitySettings[tonumber(quality)])
        _G["CollectionItemFrame"..button_progress]:Show()

        button_progress = button_progress + 1
    end

end

local function UpdatePageInfo(pagenum)
    M.CollectionsList.PageText:SetText("Page "..pagenum.."/"..M.PageCount)
end

local function UpdateListInfo(list, pagenumber)
    M.CurrentList = {}
    if not(pagenumber) then
        pagenumber = 1
    end

    for _,  RE in pairs(list) do
        if RE.enchantID ~= 0 then 
            if not RE.known then 
                RE.known = IsReforgeEnchantmentKnown(RE.enchantID)
            end
            table.insert(M.CurrentList, RE)
        end
    end
    
    qsortSpecial(M.CurrentList, 1, #M.CurrentList)

    M.PageCount = math.ceil(#M.CurrentList/M.MaxEcnhantsPerPage)

    if (M.PageCount < 1) then
        M.PageCount = 1
    end

    M.CurrentPage = pagenumber
    UpdatePageInfo(M.CurrentPage)

    if (M.PageCount <= 1) then
        M.CollectionsList.NextButton:Disable()
    else
        M.CollectionsList.NextButton:Enable()
    end

    if (pagenumber == 1) then
        M.CollectionsList.PrevButton:Disable()
    end

    UpdateListButtons(pagenumber)
end

local function CollectionListNextPage(self)
    PlaySound("igMainMenuContinue")
    M.CurrentPage = M.CurrentPage+1

    if (M.CurrentPage == M.PageCount) then
        self:Disable()
    end

    if (M.CollectionsList.PrevButton:IsEnabled() == 0) then
        M.CollectionsList.PrevButton:Enable()
    end

    UpdatePageInfo(M.CurrentPage)
    UpdateListButtons(M.CurrentPage)
end

local function CollectionListPrevPage(self)
    PlaySound("igMainMenuContinue")
    M.CurrentPage = M.CurrentPage-1

    if (M.CurrentPage == 1) then
        self:Disable()
    end

    if (M.CollectionsList.NextButton:IsEnabled() == 0) then
        M.CollectionsList.NextButton:Enable()
    end

    UpdatePageInfo(M.CurrentPage)
    UpdateListButtons(M.CurrentPage)
end

local function BuildClassList(class)
    local list = {}

    for _, v in pairs(Addon.REList) do
        if (v.class == class) then
            table.insert(list, v)
        end
    end

    UpdateListInfo(list)
end

local function BuildKnownList(known)
    local list = {}

    for i , v in pairs(Addon.REList) do
        if not v.known then
            v.known = IsReforgeEnchantmentKnown(i)
        end
        if v.known and known then
            table.insert(list, v)
        elseif not known and not v.known then
            table.insert(list, v)
        end
    end
    UpdateListInfo(list)
end

local function BuildListByQuality(quality)
    local list = {}

    for i , v in pairs(Addon.REList) do
        if (v.quality == quality) then
            table.insert(list, v)
        end
    end

    UpdateListInfo(list)
end

function ClearSearchEscape(self)
    local text = self:GetText()

    if not(text) or (text == "") then
        self:SetText(SEARCH)
    end

    self:ClearFocus(self)
end

local function SearchForEnchant(self)
    local list = {}
    local text = self:GetText()

    if not(text) or (text == "") or (text:lower() == "search") then
        self:ClearFocus(self)
        self:SetText("Search")
        return false
    end

    text = text:lower()

    for i,v in pairs(Addon.REList) do
        local sid = v.spellID
        local name = v.spellName
        local description = Addon.GetSpellDescription(sid)

        name = name:lower()
        description = description:lower()

        if name:find(text) or description:find(text) then
            table.insert(list, Addon.REList[i])
        end
    end

    UpdateListInfo(list)
    self:ClearFocus(self)
end

local function ReceiveNewEnchant(enchantID)
    if not enchantID or enchantID == 0 then
        return
    end
    local RE = GetREData(enchantID)
    RE.known = true
    local spellID = RE.spellID

    local spellName, _, spellIcon = GetSpellInfo(spellID)

    if not spellName then
        return
    end

    local enchantColor = M.EnchantQualitySettings[RE.quality][1]

    M.CollectionsList.NewEnchantInCollection.Enchant = "|Hspell:"..spellID.."|h["..spellName.."]|h"
    M.CollectionsList.NewEnchantInCollection.BackgroundTexture:SetTexture(spellIcon)
    M.CollectionsList.NewEnchantInCollection.TextNormal:SetText(enchantColor..M.CollectionsList.NewEnchantInCollection.Enchant.."|r")
    M.CollectionsList.NewEnchantInCollection.TextAdd:SetText("|cffFFFFFFYou have successfuly unlocked "..enchantColor..M.CollectionsList.NewEnchantInCollection.Enchant.."|r enchant")

    M.CollectionsList.NewEnchantInCollection.AnimationGroup:Stop()
    M.CollectionsList.NewEnchantInCollection.AnimationGroup:Play()
    BuildKnownList(true)
end

-------------------------------------------------------------------------------
--                           Paper doll scripts                              --
-------------------------------------------------------------------------------
local function SetPaperDollEnchantVisual(index, RE)
    local spellID = RE.spellID
    
    local _, _, icon = GetSpellInfo(spellID)

    if not icon then
        icon = UNKNOWN_ENCHANT_ICON
    end

    local quality = RE.quality

    local count = M.EquippedEnchantStacks[RE.enchantID] or 0

    local btn = _G["EnchantStackDisplayButton"..index]
    EnchantTemplate_Normalize(btn)
    btn:SetNormalTexture(PaperDollEnchantQualitySettings[quality])
    btn.Quality = quality

    SetPortraitToTexture(btn.Icon, icon)

    btn.Spell = spellID
    btn.Stack = count

    if (count == 0) then
        btn.MaxStack = 1
    else
        btn.MaxStack = RE.stackable
    end

    if btn.Stack > btn.MaxStack then
        EnchantTemplate_Max(btn)
    end
    if RE.quality >= 5 and M.EquippedLegendaryEnchants > 1 then 
        EnchantTemplate_Max(btn)
    elseif RE.quality == 4 and M.EquippedEpicEnchants > 3 then 
        EnchantTemplate_Max(btn)
    end

    btn:Show()
end

-- FIXME: CHECK HERE IF NEW CHAR FRAME STUFF IS EVER MODIFIED
function UpdatePaperDollEnchantList()
    local CharFrameEdit_EnchantsVisible = 0
    local index = 0
    local EnchantQualityColor = ""

    for i = 1, 20 do 
        if not _G["CharFrameNewPart_EnchantsFrame1TextFrame"..i] then
            return
        end
        _G["CharFrameNewPart_EnchantsFrame1TextFrame"..i]:Hide()
    end

    for enchantID, count in pairs(M.EquippedEnchantStacks) do
        index = index + 1

        local RE = GetREData(enchantID)
        local sname, _, sicon = GetSpellInfo(RE.spellID)
        if not sname or not sicon then 
            sname = "Unknown Enchant"
            sicon = UNKNOWN_ENCHANT_ICON
        end
        local maxStacks = RE.stackable
        EnchantQualityColor = M.EnchantQualitySettings[RE.quality][1]

        -- set up additional frame --
        _G["CharFrameNewPart_EnchantsFrame1TextFrame"..index].Icon.Spell = RE.spellID
        _G["CharFrameNewPart_EnchantsFrame1TextFrame"..index].Icon.Icon:SetTexture(sicon)
        _G["CharFrameNewPart_EnchantsFrame1TextFrame"..index].Text_L:SetText(EnchantQualityColor..sname.."|r")
        if (count == 99) then
            _G["CharFrameNewPart_EnchantsFrame1TextFrame"..index].Text_R:SetText("|cffFF00000/"..maxStacks)
        else
            _G["CharFrameNewPart_EnchantsFrame1TextFrame"..index].Text_R:SetText(count.."/"..maxStacks)
        end
        _G["CharFrameNewPart_EnchantsFrame1TextFrame"..index]:Show()
    end

    --[[if (index == 0) then
        CharFrameNewPart.Frame3:Hide()
    elseif (index == 1) then
        --CharFrameNewPart.Frame3:Show()
        _G["CharFrameNewPartFrame3TextFrame"..CharFrameEdit_EnchantsVisible]:Hide()
        --CharFrameNewPart.Frame3.TextFrame1.Button:SetPoint("BOTTOM", 0, -28)
    else
        --CharFrameNewPart.Frame3:Show()
        _G["CharFrameNewPartFrame3TextFrame"..CharFrameEdit_EnchantsVisible]:Show()
        --CharFrameNewPart.Frame3.TextFrame1.Button:SetPoint("BOTTOM", 0, -70)
    end]]--

    -- set up additional Frame
    if (index <= CharFrameEdit_EnchantsVisible) then
        CharFrameNewPart.Frame3.TextFrame1.Button:Disable()
        return 
    end

    CharFrameNewPart.Frame3.TextFrame1.Button:Enable()

    if (index*50 > CharFrameNewPart_Enchants:GetHeight()) then
        CharFrameNewPart_Enchants:EnableMouseWheel(true)
    else
        CharFrameNewPart_Enchants:EnableMouseWheel(false)
    end

    CharFrameNewPart_Enchants.ScrollBar:SetMinMaxValues(1,index*27.5) 

end

local function UpdateActiveEnchants()

    M.ControlFrame.Currency.TotalLeg.active = M.EquippedLegendaryEnchants
    M.ControlFrame.Currency.TotalEpic.active = M.EquippedEpicEnchants
    --M.ControlFrame.Currency.TotalRare.active = totalRare + totalUncommon
    M.ControlFrame.Currency.TotalLeg.UpdateText()
    M.ControlFrame.Currency.TotalEpic.UpdateText()
    --M.ControlFrame.Currency.TotalRare.UpdateText()
    --local totalStr = string.format("Active Effects: "..legQualityColor.."Legendary|r: |cffFFFFFF%i|r/1 "..epicQualityColor.."Epic|r: |cffFFFFFF%i|r/3 "..rareQualityColor.."Rare|r/"..uncommonQualityColor.."Uncommon|r: |cffFFFFFF%i|r/13", totalLegendary, totalEpic, (totalUncommon+totalRare))
    --M.ControlFrame.Currency.ActiveText:SetText(totalStr)
end
-------------------------------------------------------------------------------
--                               AIO Scripts                                 --
-------------------------------------------------------------------------------

local function UpdatePaperDoll()
    M.QualityData = {}

    for i, _ in pairs(ParentButtons) do
        if not _G["EnchantStackDisplayButton"..i] then -- called before AIO laoded stuff
            return 
        end
        _G["EnchantStackDisplayButton"..i]:Hide()
        _G["EnchantStackDisplayButton"..i].Maxed:Hide()
    end

    M.EquippedEnchantStacks = {}
    M.EquippedLegendaryEnchants = 0
    M.EquippedEpicEnchants = 0

    for i = 1, 19 do
        local slot = M.PaperDoll["Slot"..i]
        if slot then
            slot:GetScript("OnEvent")(slot, "PLAYER_EQUIPMENT_CHANGED")
            slot.Enchant:Hide()
            slot.Enchant.Maxed:Hide()
            
            local enchantID = GetREInSlot(255, slot.SlotID)
            slot.enchantID = enchantID

            if enchantID ~= 0 then
                HandleCollectionSlot(slot.Enchant, enchantID)

                if GetREData(enchantID).quality >= 5 then
                    M.EquippedLegendaryEnchants = M.EquippedLegendaryEnchants + 1

                elseif GetREData(enchantID).quality == 4 then 
                    M.EquippedEpicEnchants = M.EquippedEpicEnchants + 1
                end

                if M.EquippedEnchantStacks[enchantID] == nil then
                    M.EquippedEnchantStacks[enchantID] = 1

                else
                    M.EquippedEnchantStacks[enchantID] = M.EquippedEnchantStacks[enchantID] + 1
                end
            end
        end
    end

    -- i dont like looping this twice but its the only real way to check if we have too many of an enchant 
    for i = 1, 19 do 
        local slot = M.PaperDoll["Slot"..i]
        if slot and slot.SlotID ~= nil then
            if slot.enchantID ~= nil and slot.enchantID ~= 0 then 
                local RE = GetREData(slot.enchantID)

                if M.EquippedEnchantStacks[slot.enchantID] ~= nil then
                    SetPaperDollEnchantVisual(slot.SlotID, RE, M.EquippedEnchantStacks[slot.enchantID])

                    if M.EquippedEnchantStacks[slot.enchantID] > RE.stackable then
                        EnchantTemplate_Max(slot.Enchant)
                    end

                    if RE.quality >= 5 and M.EquippedLegendaryEnchants > 1 then
                        EnchantTemplate_Max(slot.Enchant)

                    elseif RE.quality == 4 and M.EquippedEpicEnchants > 3 then
                        EnchantTemplate_Max(slot.Enchant)
                    end
                end
            end
        end
        
    end

    UpdatePaperDollEnchantList()
    UpdateActiveEnchants()
end

-- move this to AscensionUI since other stuff could possibly use a spell / item caching helper
local tooltipHelper = CreateFrame("GameTooltip", "AIORETOOLTIP", WorldFrame, "GameTooltipTemplate")

function M.PlaceItem(item, enchantID, cost, bag, slot)
    local name, itemlink, quality, _, _, _, _, _, itemType, texture, _ = GetItemInfo(item)
    -- check if we can even place this item
    if not VALID_INVTYPE[itemType] then
        return
    end

    if quality < REFORGE_QUALITY_MIN or quality > REFORGE_QUALITY_MAX then 
        StaticPopupDialogs["ASC_ERROR_TIMEOUT"].text = "Item must be\n|cFF1EFF0CUncommon|r, |cFF0070FFRare|r, |cFFA335EEEpic|r, or |cFFFF8000Legendary|r\nto enchant it"
        StaticPopup_Show("ASC_ERROR_TIMEOUT")
        return 
    end

    --Setting up item to the button
    PlaySound("Glyph_MajorCreate")
    ACTIVE_ITEM = item
    ITEM_SLOT = slot
    ITEM_BAG = bag
    
    M.ConfirmDisenchant:Hide()
    local RE = GetREData(enchantID)
    local enchantName, _, enchantTexture = GetSpellInfo(RE.spellID)

    if not enchantName or not enchantTexture then 
        enchantName = "Unknown Enchant"
        enchantTexture = UNKNOWN_ENCHANT_ICON
    end

    -- can be nil because we might have gotten an enchantid 0
    local qualityColor = 0
    if RE.quality ~= nil then
        qualityColor = M.EnchantQualitySettings[RE.quality][1]
    end

    M.EnchantFrame.Icon:SetVertexColor(1, 1, 1, 1)
    M.EnchantFrame.EnchName:Show()
    M.EnchantFrame.ItemName:Show()

    M.EnchantFrame.Icon:SetTexture(texture)
    M.EnchantFrame.ItemName:SetText(itemlink)

    UpdateRerollCost(cost)

    if M.EnchantFrame.BGHighlight.AG:IsPlaying() then
        M.EnchantFrame.BGHighlight.AG:Stop()
    end

    M.EnchantFrame.BGHighlight.AG:Play()
    M.EnchantFrame.BG:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\LabelTopActive")
    DisableBreathing()

    if enchantID == 0 or not enchantName then
        M.EnchantFrame.EnchName:SetText("|cffFFFFFFNo Mystic Enchant|r")
        M.EnchantFrame.Enchant:Hide()
        ACTIVE_ENCHANT = nil
    else
        M.EnchantFrame.EnchName:SetText(qualityColor..enchantName.."|r")
        M.EnchantFrame.Enchant.Qualtiy = RE.quality
        M.EnchantFrame.Enchant.Spell = RE.spellID
        M.EnchantFrame.Enchant:Show()
        HandleCollectionSlot(M.EnchantFrame.Enchant, enchantID)
        ACTIVE_ENCHANT = enchantID

        --handle refund here
        --local canRefund = false
        --UnlockRefund(canRefund)
    end

    if (bag == 255) and CollectionSlotMap[slot] then
        CollectionSlotMap[slot]:SetChecked(true)
    end

    DisenchantButtonTokenCheck(M.ControlFrame.ExtractButton)
    RollButtonCheck(M.ControlFrame.RollButton)
    ClearCursor()
end

local function OnReforgeSuccess(playerGUID, enchantID)
    
    if playerGUID ~= tonumber(UnitGUID("player"), 16) then
        return
    end

    local RE = GetREData(enchantID)

    local enchantName, _, enchantTexture = GetSpellInfo(RE.spellID)

    if not enchantName or not enchantTexture then
        enchantName = RE.spellName
        enchantTexture = UNKNOWN_ENCHANT_ICON
    end

    local qualityNumber = RE.quality
    local qualityColor = M.EnchantQualitySettings[qualityNumber][1]

    if enchantName then
        if not(M.EnchantFrame.Enchant:IsVisible()) then
            M.EnchantFrame.Enchant:SetNormalTexture("")
            M.EnchantFrame.Enchant.Icon:Hide()
        end

        M.EnchantFrame.Enchant:Show()
        ACTIVE_ENCHANT = enchantID

        local r, g, b = GetItemQualityColor(qualityNumber)
        M.EnchantFrame.Enchant.SetUnlockColor(r, g, b)

        M.EnchantFrame.EnchName:SetText(qualityColor..enchantName.."|r")

        M.EnchantFrame.Enchant.UnlockDone = function()
            -- id like to move this out of here and have it update immediately
            -- but for some reason, the items arent updated immediately so it would be kind of a pain in the ass for little gain.
            UpdatePaperDoll()
            M.EnchantFrame.Enchant.Icon:Show()
            HandleCollectionSlot(M.EnchantFrame.Enchant, enchantID)
            HandleCollectionSlot(M.ConfirmDisenchant.Enchant, enchantID)
            DisenchantButtonTokenCheck(M.ControlFrame.ExtractButton)
            RollButtonCheck(M.ControlFrame.RollButton)
        end

        M.EnchantFrame.Enchant.PlayUnlock()
    end

    if (M.CollectionsEnchant ~= 0) then
        --AIO.Handle("EnchantReRoll", "RequestSuccessChance", M.CollectionsEnchant)
    end

    DisenchantButtonTokenCheck(M.ControlFrame.ExtractButton)
    RollButtonCheck(M.ControlFrame.RollButton)
end

function  M:Display()
    PlaySound("Glyph_MajorCreate")
    Addon.Collections.Tab4:GetScript("OnClick")(Addon.Collections.Tab4)
end

function  M:Close()
    PlaySound("igMainMenuOptionCheckBoxOn")
    M:Hide()
    HideUIPanel(AscensionUI.Collections)
end

function M.GetSuccessChance(chance)
    M.SuccessChance = chance
end
-------------------------------------------------------------------------------
--                                    UI                                     --
-------------------------------------------------------------------------------
M:SetSize(784,512)
--M:SetPoint("LEFT", 70, 30)
M:SetPoint("CENTER", 0, 0)
--M:SetFrameLevel(10)

M.Icon = M:CreateTexture(nil, "BACKGROUND")
M.Icon:SetSize(60,60)
M.Icon:SetPoint("TOPLEFT", 4, 2)
M.Icon:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\inv_blacksmithing_khazgoriananvil1")
SetPortraitToTexture(M.Icon, "Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\inv_blacksmithing_khazgoriananvil1")

M.BG = M:CreateTexture(nil, "BORDER")
M.BG:SetSize(1024,1024)
M.BG:SetPoint("CENTER", 0, 0)
M.BG:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\EnchRework2")

M.CloseButton = CreateFrame("Button", nil, M, "UIPanelCloseButton")
M.CloseButton:SetPoint("TOPRIGHT", -4, -1) 
M.CloseButton:EnableMouse(true)
M.CloseButton:SetScript("OnMouseUp", function()
    PlaySound("QUESTLOGCLOSE")
    HideUIPanel(AscensionUI.Collections)
end)

M.TitleText = M:CreateFontString()
M.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
M.TitleText:SetFontObject(GameFontNormal)
M.TitleText:SetPoint("TOP", 0, -11)
M.TitleText:SetShadowOffset(1,-1)
M.TitleText:SetText("Autel d'enchantement Antique")

-------------------------------------------------------------------------------
--                                   Level                                   --
-------------------------------------------------------------------------------
M.LevelFrame = CreateFrame("Button", nil, M)
M.LevelFrame:SetPoint("BOTTOMRIGHT", M.Icon, 8, -8)
M.LevelFrame:SetWidth(36)
M.LevelFrame:SetHeight(36)
--M.LevelFrame:SetHighlightTexture("Interface\\AddOns\\AwAddons\\Textures\\Misc\\roundbuttonhighlight")

M.LevelFrame.Border = M.LevelFrame:CreateTexture(nil, "ARTWORK")
M.LevelFrame.Border:SetSize(36,36)
M.LevelFrame.Border:SetPoint("CENTER", -1, -1)
M.LevelFrame.Border:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\StoreCollectionRound")

M.LevelFrame.Icon = M.LevelFrame:CreateTexture(nil, "BORDER")
M.LevelFrame.Icon:SetSize(24,24)
M.LevelFrame.Icon:SetPoint("CENTER", 0, 0)
M.LevelFrame.Icon:SetVertexColor(0.1, 0.1, 0.1, 1)
SetPortraitToTexture(M.LevelFrame.Icon, "Interface\\icons\\INV_Misc_Book_11")

M.LevelFrame.Highlight = M.LevelFrame:CreateTexture(nil, "BACKGROUND")
M.LevelFrame.Highlight:SetSize(70,70)
M.LevelFrame.Highlight:SetPoint("CENTER", 0, 2)
M.LevelFrame.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\DragonHighlight")
M.LevelFrame.Highlight:SetBlendMode("ADD")

M.LevelFrame.TitleText = M.LevelFrame:CreateFontString(nil, "OVERLAY")
M.LevelFrame.TitleText:SetFontObject(GameFontHighlight)
M.LevelFrame.TitleText:SetPoint("CENTER", -1.5, 0)
M.LevelFrame.TitleText:SetText("")

M.LevelFrame.Highlight.AnimG = M.LevelFrame.Highlight:CreateAnimationGroup()
M.LevelFrame.Highlight.AnimG.Rotation = M.LevelFrame.Highlight.AnimG:CreateAnimation("Rotation")
M.LevelFrame.Highlight.AnimG.Rotation:SetDuration(60)
M.LevelFrame.Highlight.AnimG.Rotation:SetOrder(1)
M.LevelFrame.Highlight.AnimG.Rotation:SetEndDelay(0)
M.LevelFrame.Highlight.AnimG.Rotation:SetSmoothing("NONE")
M.LevelFrame.Highlight.AnimG.Rotation:SetDegrees(-360)

M.LevelFrame.Highlight.AnimG:SetScript("OnFinished", function(self)
    self:Play()
end)

M.LevelFrame.Highlight.AnimG:Play()

--[[M.LevelFrame:SetScript("OnUpdate", function()
  if not(M.LevelFrame.Highlight.AnimG:IsPlaying()) then 
      M.LevelFrame.Highlight.AnimG:Play()
  end

  if not(M.LevelFrame.AnimG:IsPlaying()) then
    M.LevelFrame.AnimG:Play()
  end
end)]]--
-------------------------------------------------------------------------------
--                                 Top Navi                                  --
-------------------------------------------------------------------------------
M.SearchBox = CreateFrame("EditBox", "MysticEnchantSearchBox", M, "InputBoxTemplate")
M.SearchBox:SetWidth(130)
M.SearchBox:SetHeight(26)
M.SearchBox:SetFontObject(GameFontNormal)
M.SearchBox:SetPoint("TOPRIGHT", M, -140, -33)
M.SearchBox:ClearFocus()
M.SearchBox:SetAutoFocus(false)
M.SearchBox:SetFontObject(GameFontDisable)
M.SearchBox:SetScript("OnEnterPressed", SearchForEnchant)
M.SearchBox:SetScript("OnEscapePressed", ClearSearchEscape)
M.SearchBox:SetText("Search")

-- this needs a global name because UIDropDownMenu sucks
M.EnchantTypeList = CreateFrame("Button", "MysticEnchantEnchantTypeList", M, "UIDropDownMenuTemplate")
M.EnchantTypeList:SetPoint("TOPRIGHT", M, -10, -32)

M.EnchantTypeList.List = {
    "Tous", -- 1 
    "Enchantements d'armes", -- 2
    "Enchantements d'armures et d'armes", -- 3
    "Enchantements connus", -- 4
    "Enchantements inconnus", -- 5
    --"Common", -- 6
    "|cff1eff00commun|r", -- 6
    "|cff0070ddRare|r", -- 7
    "|cffa335eeEpique|r", -- 8
    "|cffff8000Legendaire|r", -- 9
}

function M.EnchantTypeList.Init(self, level)
   local info = UIDropDownMenu_CreateInfo()
   for _,v in pairs(M.EnchantTypeList.List) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v
      info.value = v
      info.func = function(self)
        UIDropDownMenu_SetSelectedID(M.EnchantTypeList, self:GetID())
        if (self:GetID() == 1) then
            UpdateListInfo(Addon.REList)
        elseif (self:GetID() == 2) then
            BuildClassList("WEAPON")
        elseif (self:GetID() == 3) then
            BuildClassList("ANY")
        elseif (self:GetID() == 4) then
            BuildKnownList(true)
        elseif (self:GetID() == 5) then
            BuildKnownList(false)
        --elseif (self:GetID() == 6) then
            --BuildListByQuality(1)
        elseif (self:GetID() == 6) then
            BuildListByQuality(2)
        elseif (self:GetID() == 7) then
            BuildListByQuality(3)
        elseif (self:GetID() == 8) then
            BuildListByQuality(4)
        elseif (self:GetID() == 9) then
            BuildListByQuality(5)
        end

      end
      UIDropDownMenu_AddButton(info, level)
   end
end

UIDropDownMenu_Initialize(M.EnchantTypeList, M.EnchantTypeList.Init)
UIDropDownMenu_SetWidth(M.EnchantTypeList, 90);
UIDropDownMenu_SetButtonWidth(M.EnchantTypeList, 70)
UIDropDownMenu_SetSelectedID(M.EnchantTypeList, 4)
UIDropDownMenu_JustifyText(M.EnchantTypeList, "LEFT")
-------------------------------------------------------------------------------
--                                 Collection                                --
-------------------------------------------------------------------------------
M.CollectionsList = CreateFrame("FRAME", nil, M, nil)
M.CollectionsList:SetPoint("CENTER", 145, -15)
M.CollectionsList:SetSize(470, 425)
M.CollectionsList:EnableMouseWheel(true)
--M.CollectionsList:SetBackdrop(StaticPopup1:GetBackdrop())

--[[M.CollectionsList.TitleText = M.CollectionsList:CreateFontString()
M.CollectionsList.TitleText:SetFont("Fonts\\MORPHEUS.TTF", 20)
M.CollectionsList.TitleText:SetFontObject(GameFontHighlight)
M.CollectionsList.TitleText:SetPoint("TOP", 0, -14)
M.CollectionsList.TitleText:SetSize(417, 22)
M.CollectionsList.TitleText:SetText("Enchant Collection")
M.CollectionsList.TitleText:SetJustifyH("CENTER")

M.CollectionsList.SpellsSubText = M.CollectionsList:CreateFontString()
M.CollectionsList.SpellsSubText:SetFont("Fonts\\FRIZQT__.TTF", 11)
M.CollectionsList.SpellsSubText:SetFontObject(GameFontNormal)
M.CollectionsList.SpellsSubText:SetPoint("CENTER", M.CollectionsList.TitleText, "BOTTOM", 0,-8)
--M.CollectionsList.SpellsText:SetShadowOffset(0,0)
M.CollectionsList.SpellsSubText:SetSize(260, 22)
M.CollectionsList.SpellsSubText:SetText("Select an enchant to apply to your item")
M.CollectionsList.SpellsSubText:SetJustifyH("CENTER")]]--

M.CollectionsList.PageText = M.CollectionsList:CreateFontString()
M.CollectionsList.PageText:SetFontObject(GameFontHighlight)
M.CollectionsList.PageText:SetPoint("RIGHT", M.CollectionsList, "BOTTOM", -6, 40)
M.CollectionsList.PageText:SetSize(100, 16)
M.CollectionsList.PageText:SetJustifyH("RIGHT")

--[[M.CollectionsList.NextButton.Text = M.CollectionsList.NextButton:CreateFontString()
M.CollectionsList.NextButton.Text:SetFontObject(GameFontNormal)
M.CollectionsList.NextButton.Text:SetPoint("RIGHT", M.CollectionsList.NextButton, "LEFT", 0, 0)
M.CollectionsList.NextButton.Text:SetJustifyH("RIGHT")
M.CollectionsList.NextButton.Text:SetText(NEXT)]]--

M.CollectionsList.PrevButton = CreateFrame("Button", nil, M.CollectionsList, nil)
M.CollectionsList.PrevButton:SetSize(28, 28)
M.CollectionsList.PrevButton:SetPoint("LEFT", M.CollectionsList.PageText, "RIGHT", 6, 1)
M.CollectionsList.PrevButton:EnableMouse(true)
M.CollectionsList.PrevButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
M.CollectionsList.PrevButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
M.CollectionsList.PrevButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
M.CollectionsList.PrevButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
M.CollectionsList.PrevButton:SetScript("OnClick", CollectionListPrevPage)

M.CollectionsList.NextButton = CreateFrame("Button", nil, M.CollectionsList, nil)
M.CollectionsList.NextButton:SetSize(28, 28)
M.CollectionsList.NextButton:SetPoint("LEFT", M.CollectionsList.PrevButton, "RIGHT", 4, 0)
M.CollectionsList.NextButton:EnableMouse(true)
M.CollectionsList.NextButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
M.CollectionsList.NextButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
M.CollectionsList.NextButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
M.CollectionsList.NextButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
M.CollectionsList.NextButton:SetScript("OnClick", CollectionListNextPage)

--[[M.CollectionsList.PrevButton.Text = M.CollectionsList.PrevButton:CreateFontString()
M.CollectionsList.PrevButton.Text:SetFontObject(GameFontNormal)
M.CollectionsList.PrevButton.Text:SetPoint("LEFT", M.CollectionsList.PrevButton, "RIGHT", 0, 0)
M.CollectionsList.PrevButton.Text:SetJustifyH("LEFT")
M.CollectionsList.PrevButton.Text:SetText(PREV)]]--

M.CollectionsList:SetScript("OnMouseWheel", function(self, delta)
    if (M.CollectionsList.PrevButton:IsEnabled() == 1) and (delta == -1) then
        CollectionListPrevPage(M.CollectionsList.PrevButton)
    elseif (M.CollectionsList.NextButton:IsEnabled() == 1) and (delta == 1) then
        CollectionListNextPage(M.CollectionsList.NextButton)
    end
end)


CollectionItemFrame1 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame1:SetPoint("CENTER", -150, 127)

CollectionItemFrame2 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame2:SetPoint("CENTER", 0, 127)

CollectionItemFrame3 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame3:SetPoint("CENTER", 150, 127)

CollectionItemFrame4 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame4:SetPoint("CENTER", -150, 67)

CollectionItemFrame5 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame5:SetPoint("CENTER", 0, 67)

CollectionItemFrame6 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame6:SetPoint("CENTER", 150, 67)

CollectionItemFrame7 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame7:SetPoint("CENTER", -150, 7)

CollectionItemFrame8 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame8:SetPoint("CENTER", 0, 7)

CollectionItemFrame9 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame9:SetPoint("CENTER", 150, 7)

CollectionItemFrame10 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame10:SetPoint("CENTER", -150, -53)

CollectionItemFrame11 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame11:SetPoint("CENTER", 0, -53)

CollectionItemFrame12 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame12:SetPoint("CENTER", 150, -53)

CollectionItemFrame13 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame13:SetPoint("CENTER", -150, -113)

CollectionItemFrame14 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame14:SetPoint("CENTER", 0, -113)

CollectionItemFrame15 = CollectionItemTemplate(M.CollectionsList)
CollectionItemFrame15:SetPoint("CENTER", 150, -113)

-------------------------------------------------------------------------------
--                                ProgressBar                                --
-------------------------------------------------------------------------------
M.ProgressBar = CreateFrame("StatusBar", nil, M)
M.ProgressBar:SetSize(212,14)
M.ProgressBar:SetPoint("TOP", M.TitleText,"BOTTOM", 0, -15.5)
M.ProgressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar") 
M.ProgressBar:EnableMouse(true)
M.ProgressBar:SetStatusBarColor(0, .6, 0, 1)
M.ProgressBar:SetMinMaxValues(0, 100)
M.ProgressBar:SetValue(0)

M.ProgressBar:SetScript("OnEnter", function(self)
    if M.CDB then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(format("%s/%s", M.CDB.EnchantProgress, M.CDB.NextRequired))
        GameTooltip:Show()
    end
end)

M.ProgressBar:SetScript("OnLeave", function(self) 
    GameTooltip:Hide()
end)

M.ProgressBar.BG = M.ProgressBar:CreateTexture(nil, "BACKGROUND")
--M.ProgressBar.BG:SetSize(512,64)
M.ProgressBar.BG:SetPoint("TOPLEFT", M.ProgressBar)
M.ProgressBar.BG:SetPoint("BOTTOMRIGHT", M.ProgressBar)
M.ProgressBar.BG:SetVertexColor(0, 0, 0, 0.4)

M.ProgressBar.Border = M.ProgressBar:CreateTexture(nil, "OVERLAY")
--M.ProgressBar.BG:SetSize(512,64)
M.ProgressBar.Border:SetTexture("Interface\\AchievementFrame\\UI-Achievement-ProgressBar-Border")
M.ProgressBar.Border:SetPoint("TOPLEFT", M.ProgressBar, -6, 5)
M.ProgressBar.Border:SetPoint("BOTTOMRIGHT", M.ProgressBar, 6, -5)
M.ProgressBar.Border:SetTexCoord(0, 0.8745, 0, 0.75)

M.ProgressBar.Text = M.ProgressBar:CreateFontString(nil)
M.ProgressBar.Text:SetFontObject(GameFontHighlightSmall)
M.ProgressBar.Text:SetPoint("CENTER")

--[[M.ProgressBar.ArtWork = M.ProgressBar:CreateTexture(nil, "ARTWORK")
M.ProgressBar.ArtWork:SetSize(512,64)
M.ProgressBar.ArtWork:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\CollectionsBar")
M.ProgressBar.ArtWork:SetPoint("CENTER",M.ProgressBar,0,25)

M.ProgressBar.ArtWork_Hover = M.ProgressBar:CreateTexture(nil, "OVERLAY")
M.ProgressBar.ArtWork_Hover:SetSize(512,64)
M.ProgressBar.ArtWork_Hover:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\CollectionsBar_Hover")
M.ProgressBar.ArtWork_Hover:SetPoint("CENTER",M.ProgressBar,0,25)
M.ProgressBar.ArtWork_Hover:SetBlendMode("ADD")
M.ProgressBar.ArtWork_Hover:SetAlpha(0)
M.ProgressBar.ArtWork_Hover:Hide()

M.ProgressBar.Hover = M.ProgressBar:CreateTexture(nil, "OVERLAY")
M.ProgressBar.Hover:SetSize(280,13)
M.ProgressBar.Hover:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\CollectionsBarEnchants")
M.ProgressBar.Hover:SetPoint("CENTER", 0, 0)
M.ProgressBar.Hover:SetBlendMode("ADD")
M.ProgressBar.Hover:Hide()]]--

-------------------------------------------------------------------------------
--                              Left Side Panel                              --
-------------------------------------------------------------------------------
M.PaperDoll = CreateFrame("FRAME", nil, M, nil)
M.PaperDoll:SetPoint("LEFT", 17, -28)
M.PaperDoll:SetSize(280, 333)
--M.PaperDoll:SetBackdrop(GameTooltip:GetBackdrop())

M.PaperDoll.Slot1 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot1:SetPoint("TOPLEFT", M.PaperDoll, "TOPLEFT", 4, -2)
M.PaperDoll.Slot1.Enchant:SetPoint("LEFT", M.PaperDoll.Slot1, "RIGHT", -2, 0)
M.PaperDoll.Slot1.Slot = "HeadSlot"
M.PaperDoll.Slot1.SlotID = 1

M.PaperDoll.Slot2 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot2:SetPoint("TOP", M.PaperDoll.Slot1, "BOTTOM", 0, 2)
M.PaperDoll.Slot2.Enchant:SetPoint("LEFT", M.PaperDoll.Slot2, "RIGHT", -2, 0)
M.PaperDoll.Slot2.Slot = "NeckSlot"
M.PaperDoll.Slot2.SlotID = 2

M.PaperDoll.Slot3 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot3:SetPoint("TOP", M.PaperDoll.Slot2, "BOTTOM", 0, 2)
M.PaperDoll.Slot3.Enchant:SetPoint("LEFT", M.PaperDoll.Slot3, "RIGHT", -2, 0)
M.PaperDoll.Slot3.Slot = "ShoulderSlot"
M.PaperDoll.Slot3.SlotID = 3

M.PaperDoll.Slot4 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot4:SetPoint("TOP", M.PaperDoll.Slot3, "BOTTOM", 0, 2)
M.PaperDoll.Slot4.Enchant:SetPoint("LEFT", M.PaperDoll.Slot4, "RIGHT", -2, 0)
M.PaperDoll.Slot4.Slot = "BackSlot"
M.PaperDoll.Slot4.SlotID = 15

M.PaperDoll.Slot5 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot5:SetPoint("TOP", M.PaperDoll.Slot4, "BOTTOM", 0, 2)
M.PaperDoll.Slot5.Enchant:SetPoint("LEFT", M.PaperDoll.Slot5, "RIGHT", -2, 0)
M.PaperDoll.Slot5.Slot = "ChestSlot"
M.PaperDoll.Slot5.SlotID = 5

-- shirt
M.PaperDoll.Slot6 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot6:SetPoint("TOP", M.PaperDoll.Slot5, "BOTTOM", 0, 2)
M.PaperDoll.Slot6.Enchant:Hide()
M.PaperDoll.Slot6.Icon:Hide()
M.PaperDoll.Slot6:Disable()
M.PaperDoll.Slot6.SlotID = 0

-- tabard
M.PaperDoll.Slot7 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot7:SetPoint("TOP", M.PaperDoll.Slot6, "BOTTOM", 0, 2)
M.PaperDoll.Slot7.Enchant:Hide()
M.PaperDoll.Slot7.Icon:Hide()
M.PaperDoll.Slot7:Disable()
M.PaperDoll.Slot7.SlotID = 0

M.PaperDoll.Slot8 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot8:SetPoint("TOP", M.PaperDoll.Slot7, "BOTTOM", 0, 2)
M.PaperDoll.Slot8.Enchant:SetPoint("LEFT", M.PaperDoll.Slot8, "RIGHT", -2, 0)
M.PaperDoll.Slot8.Slot = "WristSlot"
M.PaperDoll.Slot8.SlotID = 9

M.PaperDoll.Slot9 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot9:SetPoint("TOPRIGHT", M.PaperDoll, "TOPRIGHT", -4, -2)
M.PaperDoll.Slot9.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot9, "LEFT", 2, 0)
M.PaperDoll.Slot9.Slot = "HandsSlot"
M.PaperDoll.Slot9.SlotID = 10

M.PaperDoll.Slot10 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot10:SetPoint("TOP", M.PaperDoll.Slot9, "BOTTOM", 0, 2)
M.PaperDoll.Slot10.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot10, "LEFT", 2, 0)
M.PaperDoll.Slot10.Slot = "WaistSlot"
M.PaperDoll.Slot10.SlotID = 6

M.PaperDoll.Slot11 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot11:SetPoint("TOP", M.PaperDoll.Slot10, "BOTTOM", 0, 2)
M.PaperDoll.Slot11.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot11, "LEFT", 2, 0)
M.PaperDoll.Slot11.Slot = "LegsSlot"
M.PaperDoll.Slot11.SlotID = 7

M.PaperDoll.Slot12 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot12:SetPoint("TOP", M.PaperDoll.Slot11, "BOTTOM", 0, 2)
M.PaperDoll.Slot12.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot12, "LEFT", 2, 0)
M.PaperDoll.Slot12.Slot = "FeetSlot"
M.PaperDoll.Slot12.SlotID = 8

M.PaperDoll.Slot13 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot13:SetPoint("TOP", M.PaperDoll.Slot12, "BOTTOM", 0, 2)
M.PaperDoll.Slot13.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot13, "LEFT", 2, 0)
M.PaperDoll.Slot13.Slot = "Finger0Slot"
M.PaperDoll.Slot13.SlotID = 11

M.PaperDoll.Slot14 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot14:SetPoint("TOP", M.PaperDoll.Slot13, "BOTTOM", 0, 2)
M.PaperDoll.Slot14.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot14, "LEFT", 2, 0)
M.PaperDoll.Slot14.Slot = "Finger1Slot"
M.PaperDoll.Slot14.SlotID = 12

M.PaperDoll.Slot15 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot15:SetPoint("TOP", M.PaperDoll.Slot14, "BOTTOM", 0, 2)
M.PaperDoll.Slot15.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot15, "LEFT", 2, 0)
M.PaperDoll.Slot15.Slot = "Trinket0Slot"
M.PaperDoll.Slot15.SlotID = 13

M.PaperDoll.Slot16 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot16:SetPoint("TOP", M.PaperDoll.Slot15, "BOTTOM", 0, 2)
M.PaperDoll.Slot16.Enchant:SetPoint("RIGHT", M.PaperDoll.Slot16, "LEFT", 2, 0)
M.PaperDoll.Slot16.Slot = "Trinket1Slot"
M.PaperDoll.Slot16.SlotID = 14

M.PaperDoll.Slot17 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot17:SetPoint("BOTTOM", M.PaperDoll, "BOTTOM", 0, 2)
M.PaperDoll.Slot17.Enchant:SetPoint("BOTTOM", M.PaperDoll.Slot17, "TOP", 0, -2)
M.PaperDoll.Slot17.Slot = "SecondaryHandSlot"
M.PaperDoll.Slot17.SlotID = 17

M.PaperDoll.Slot18 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot18:SetPoint("LEFT", M.PaperDoll.Slot17, "RIGHT", -2, 0)
M.PaperDoll.Slot18.Enchant:SetPoint("BOTTOM", M.PaperDoll.Slot18, "TOP", 0, -2)
M.PaperDoll.Slot18.Slot = "RangedSlot"
M.PaperDoll.Slot18.SlotID = 18

M.PaperDoll.Slot19 = CollectionSlotButtonTemplate(M.PaperDoll)
M.PaperDoll.Slot19:SetPoint("RIGHT", M.PaperDoll.Slot17, "LEFT", 2, 0)
M.PaperDoll.Slot19.Enchant:SetPoint("BOTTOM", M.PaperDoll.Slot19, "TOP", 0, -2)
M.PaperDoll.Slot19.Slot = "MainHandSlot"
M.PaperDoll.Slot19.SlotID = 16

CollectionSlotMap = {
    [1] = M.PaperDoll.Slot1,
    [2] = M.PaperDoll.Slot2,
    [3] = M.PaperDoll.Slot3,
    [15] = M.PaperDoll.Slot4,
    [5] = M.PaperDoll.Slot5,
    [9] = M.PaperDoll.Slot8,
    [10] = M.PaperDoll.Slot9,
    [6] = M.PaperDoll.Slot10,
    [7] = M.PaperDoll.Slot11,
    [8] = M.PaperDoll.Slot12,
    [11] = M.PaperDoll.Slot13,
    [12] = M.PaperDoll.Slot14,
    [13] = M.PaperDoll.Slot15,
    [14] = M.PaperDoll.Slot16,
    [16] = M.PaperDoll.Slot19,
    [17] = M.PaperDoll.Slot17,
    [18] = M.PaperDoll.Slot18
}
-------------------------------------------------------------------------------
--                                   Model                                   --
-------------------------------------------------------------------------------
M.PaperDoll.Model = CreateFrame("PlayerModel", "MysticEnchant.PaperDoll.Model", M.PaperDoll, nil)
M.PaperDoll.Model:SetPoint("CENTER", 0, 15)
M.PaperDoll.Model:SetSize(233, 295)
M.PaperDoll.Model:EnableMouse(true)
M.PaperDoll.Model.rotation = 0

M.PaperDoll.Model:SetScript("OnShow", function(self)
    self:SetUnit("player");
end)

M.PaperDoll.Model:SetScript("OnLoad", function(self)
    Model_OnLoad(self);
    self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end)
M.PaperDoll.Model:SetScript("OnEvent", function(self)
    self:RefreshUnit();
end)
M.PaperDoll.Model:SetScript("OnUpdate", function(self, elapsed)
    Model_OnUpdate(self, elapsed);

    if ( M.PaperDoll.Model.Rotation_X ) then
        local x = GetCursorPosition();
        local diff = (x - M.PaperDoll.Model.Rotation_X) * 0.01;
        M.PaperDoll.Model.Rotation_X = GetCursorPosition();

        if (diff > 0) then
            Model_RotateRight(self)
        elseif (diff < 0) then
            Model_RotateLeft(self)
        end
    end

end)

M.PaperDoll.Model:SetScript("OnMouseDown", function(self, button)
    if ( button == "LeftButton" ) then
        M.PaperDoll.Model.Rotation_X = GetCursorPosition();
    end
end)

M.PaperDoll.Model:SetScript("OnMouseUp", function(self, button)
    if ( button == "LeftButton" ) then
        M.PaperDoll.Model.Rotation_X = nil
    end
end)

M.PaperDoll.ModelRotateLeftButton = CreateFrame("Button", "MysticEnchant.PaperDoll.ModelRotateLeftButton", M.PaperDoll.Model, nil)
M.PaperDoll.ModelRotateLeftButton:SetSize(35, 35)
M.PaperDoll.ModelRotateLeftButton:SetPoint("TOP", -16, 0)
M.PaperDoll.ModelRotateLeftButton:SetNormalTexture("Interface\\Buttons\\UI-RotationLeft-Button-Up")
M.PaperDoll.ModelRotateLeftButton:SetPushedTexture("Interface\\Buttons\\UI-RotationLeft-Button-Down")
M.PaperDoll.ModelRotateLeftButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Round")
M.PaperDoll.ModelRotateLeftButton:SetScript("OnLoad", function(self)
    self:RegisterForClicks("LeftButtonDown", "LeftButtonUp");
end)
M.PaperDoll.ModelRotateLeftButton:SetScript("OnClick", function(self)
    Model_RotateLeft(self:GetParent());
end)
--M.PaperDoll.ModelRotateLeftButton:Hide()

M.PaperDoll.ModelRotateRightButton = CreateFrame("Button", "MysticEnchant.PaperDoll.ModelRotateRightButton", M.PaperDoll.Model, nil)
M.PaperDoll.ModelRotateRightButton:SetSize(35, 35)
M.PaperDoll.ModelRotateRightButton:SetPoint("TOP", 16, 0)
M.PaperDoll.ModelRotateRightButton:SetNormalTexture("Interface\\Buttons\\UI-RotationRight-Button-Up")
M.PaperDoll.ModelRotateRightButton:SetPushedTexture("Interface\\Buttons\\UI-RotationRight-Button-Down")
M.PaperDoll.ModelRotateRightButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Round")
M.PaperDoll.ModelRotateRightButton:SetScript("OnLoad", function(self)
    self:RegisterForClicks("LeftButtonDown", "LeftButtonUp");
end)
M.PaperDoll.ModelRotateRightButton:SetScript("OnClick", function(self)
    Model_RotateRight(self:GetParent());
end)
--M.PaperDoll.ModelRotateRightButton:Hide()
M.PaperDoll.Model:SetUnit("player");
-------------------------------------------------------------------------------
--                                 Enchant                                   --
-------------------------------------------------------------------------------
M.EnchantFrame = CreateFrame("FRAME", nil, M, nil)
M.EnchantFrame:SetPoint("BOTTOM", M.PaperDoll, "TOP", 0, 1)
M.EnchantFrame:SetSize(280, 52)
M.EnchantFrame:SetFrameLevel(5)
--M.EnchantFrame:SetBackdrop(GameTooltip:GetBackdrop())

M.EnchantFrame.BG = M.EnchantFrame:CreateTexture(nil, "BORDER")
M.EnchantFrame.BG:SetSize(512,128)
M.EnchantFrame.BG:SetPoint("CENTER", 0, 0)
M.EnchantFrame.BG:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\LabelTop")

M.EnchantFrame.BGHighlight = M.EnchantFrame:CreateTexture(nil, "ARTWORK")
M.EnchantFrame.BGHighlight:SetSize(512,128)
M.EnchantFrame.BGHighlight:SetPoint("CENTER", 0, 0)
M.EnchantFrame.BGHighlight:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\LabelTopAH")
M.EnchantFrame.BGHighlight:SetAlpha(0)
M.EnchantFrame.BGHighlight:SetBlendMode("ADD")

M.EnchantFrame.Icon = M.EnchantFrame:CreateTexture(nil, "BACKGROUND")
M.EnchantFrame.Icon:SetSize(40,40)
M.EnchantFrame.Icon:SetPoint("LEFT", 6, 0)
M.EnchantFrame.Icon:SetTexture("Interface\\Icons\\spell_frost_stun")
M.EnchantFrame.Icon:SetVertexColor(0.5, 0, 0.5, 0.5)

M.EnchantFrame.BreathTex = M.EnchantFrame:CreateTexture(nil, "OVERLAY")
M.EnchantFrame.BreathTex:SetSize(399,399)
M.EnchantFrame.BreathTex:SetPoint("CENTER", M.EnchantFrame.Icon, 1, 0)
M.EnchantFrame.BreathTex:SetTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\BreathTexture")
M.EnchantFrame.BreathTex:SetAlpha(0)
M.EnchantFrame.BreathTex:Hide()
--M.EnchantFrame.BreathTex:SetBlendMode("ADD")

M.EnchantFrame.SlotButton = CreateFrame("Button", nil, M.EnchantFrame, nil)
M.EnchantFrame.SlotButton:SetSize(46, 46)
M.EnchantFrame.SlotButton:SetHighlightTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
M.EnchantFrame.SlotButton:SetPoint("CENTER", M.EnchantFrame.Icon, 0, 0)

M.EnchantFrame.EnchName = M.EnchantFrame:CreateFontString()
M.EnchantFrame.EnchName:SetFont("Fonts\\FRIZQT__.TTF", 12)
M.EnchantFrame.EnchName:SetFontObject(GameFontDisable)
M.EnchantFrame.EnchName:SetPoint("LEFT", M.EnchantFrame.SlotButton, "RIGHT", 6, 6)
M.EnchantFrame.EnchName:SetShadowOffset(1,-1)
M.EnchantFrame.EnchName:SetJustifyH("LEFT")
M.EnchantFrame.EnchName:SetWidth(160)
--M.EnchantFrame.EnchName:SetSize(200, 28)

M.EnchantFrame.ItemName = M.EnchantFrame:CreateFontString()
M.EnchantFrame.ItemName:SetFontObject(GameFontDisable)
M.EnchantFrame.ItemName:SetFont("Fonts\\FRIZQT__.TTF", 11)
M.EnchantFrame.ItemName:SetPoint("TOP", M.EnchantFrame.EnchName, "BOTTOM", 0, -2)
M.EnchantFrame.ItemName:SetShadowOffset(1,-1)
M.EnchantFrame.ItemName:SetJustifyH("LEFT")
M.EnchantFrame.ItemName:SetJustifyV("TOP")
M.EnchantFrame.ItemName:SetSize(160, 14)

M.EnchantFrame.EnchName:SetText("Faites glisser un objet ici")
M.EnchantFrame.ItemName:SetText("Utiliser l'Autel d'enchantement")

M.EnchantFrame.Enchant = CollectionEnchantTemplate(M.EnchantFrame)
M.EnchantFrame.Enchant:SetPoint("RIGHT", M.EnchantFrame, -1, -1)
M.EnchantFrame.Enchant:SetSize(48, 48)
M.EnchantFrame.Enchant.Icon:SetSize(36,36)
M.EnchantFrame.Enchant.Maxed:SetSize(48,48)
M.EnchantFrame.Enchant:GetHighlightTexture():ClearAllPoints()
M.EnchantFrame.Enchant:GetHighlightTexture():SetSize(64,64)
M.EnchantFrame.Enchant:GetHighlightTexture():SetPoint("CENTER", 0, 0)
M.EnchantFrame.Enchant:Hide()

M.EnchantFrame.SlotButton:SetScript("OnMouseDown", function(self)
    PlaceItem(self, false)
end)
M.EnchantFrame.SlotButton:SetScript("OnEnter", EnchantShowLink)
M.EnchantFrame.SlotButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
-------------------------------------------------------------------------------
--                                  Bottom                                   --
-------------------------------------------------------------------------------
M.ControlFrame = CreateFrame("FRAME", nil, M, nil)
M.ControlFrame:SetPoint("TOP", M.PaperDoll, "BOTTOM", 0, -1)
M.ControlFrame:SetSize(280, 28)
M.ControlFrame:RegisterEvent("BAG_UPDATE")
M.ControlFrame:SetScript("OnEvent", UpdateMysticRuneBalance)
--M.ControlFrame:SetBackdrop(GameTooltip:GetBackdrop())

M.ControlFrame.ExtractButton = CreateFrame("Button", nil, M.ControlFrame, "SecureActionButtonTemplate, UIPanelButtonTemplate")
M.ControlFrame.ExtractButton:SetWidth(80)
M.ControlFrame.ExtractButton:SetHeight(22)
M.ControlFrame.ExtractButton:SetPoint("RIGHT",-1,1) 
M.ControlFrame.ExtractButton:RegisterForClicks("AnyUp")
M.ControlFrame.ExtractButton:SetText("Extraction")
M.ControlFrame.ExtractButton:SetScript("OnClick", PrepareDisenchant)
M.ControlFrame.ExtractButton:SetScript("OnShow", DisenchantButtonTokenCheck)
M.ControlFrame.ExtractButton:SetScript("OnEnter", EnchantShowDisenchantHint)
M.ControlFrame.ExtractButton:SetScript("Onleave", function()
    GameTooltip:Hide()
end)
M.ControlFrame.ExtractButton:Disable()

M.ControlFrame.ExtractButton.TooltipFrame = CreateFrame("Frame", nil, M.ControlFrame.ExtractButton)
M.ControlFrame.ExtractButton.TooltipFrame:SetAllPoints()
M.ControlFrame.ExtractButton.TooltipFrame:EnableMouse(true)
M.ControlFrame.ExtractButton.TooltipFrame:SetScript("OnEnter", EnchantShowDisenchantHint)
M.ControlFrame.ExtractButton.TooltipFrame:SetScript("Onleave", function()
    GameTooltip:Hide()
end)


M.ControlFrame.RollButton = CreateFrame("Button", nil, M.ControlFrame, "SecureActionButtonTemplate, UIPanelButtonTemplate")
M.ControlFrame.RollButton:SetWidth(80) 
M.ControlFrame.RollButton:SetHeight(22) 
M.ControlFrame.RollButton:SetPoint("RIGHT", M.ControlFrame.ExtractButton, "LEFT", -3,0) 
M.ControlFrame.RollButton:RegisterForClicks("AnyUp") 
M.ControlFrame.RollButton:SetText("Reforger")
M.ControlFrame.RollButton:Disable()
M.ControlFrame.RollButton:SetScript("OnClick", PrepareReforge)

M.ControlFrame.RollButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)
--[[M.ControlFrame.ApplyButton = CreateFrame("Button", nil, M.ControlFrame, "UIPanelButtonTemplate")
M.ControlFrame.ApplyButton:SetWidth(80) 
M.ControlFrame.ApplyButton:SetHeight(22) 
M.ControlFrame.ApplyButton:SetPoint("RIGHT",-1,1) 
M.ControlFrame.ApplyButton:RegisterForClicks("AnyUp") 
M.ControlFrame.ApplyButton:SetText("Reforge")
M.ControlFrame.ApplyButton:Disable()

M.ControlFrame.ApplyButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)]]--
-------------------------------------------------------------------------------
--                                Cost Frame                                 --
-------------------------------------------------------------------------------
M.ControlFrame.MoneyFrame = CreateFrame("FRAME", "MysticEnchantControlFrameMoneyFrame", M, "SmallMoneyFrameTemplate")
-- old wow ui stuff sucks
M.ControlFrame.MoneyFrame.CopperButton = _G["MysticEnchantControlFrameMoneyFrameCopperButton"]
M.ControlFrame.MoneyFrame.SilverButton = _G["MysticEnchantControlFrameMoneyFrameSilverButton"]
M.ControlFrame.MoneyFrame.GoldButton = _G["MysticEnchantControlFrameMoneyFrameGoldButton"]
M.ControlFrame.MoneyFrame:SetPoint("RIGHT", M.ControlFrame.RollButton, "LEFT", -3,0)
M.ControlFrame.MoneyFrame:SetSize(109, 28)
M.ControlFrame.MoneyFrame:Hide()

-- clear default settings
M.ControlFrame.MoneyFrame:SetScript("OnLoad", nil)
M.ControlFrame.MoneyFrame:SetScript("OnEvent", nil)
M.ControlFrame.MoneyFrame:SetScript("OnShow", nil)
M.ControlFrame.MoneyFrame:SetScript("OnHide", nil)
M.ControlFrame.MoneyFrame.CopperButton:SetScript("OnClick", nil)
M.ControlFrame.MoneyFrame.SilverButton:SetScript("OnClick", nil)
M.ControlFrame.MoneyFrame.GoldButton:SetScript("OnClick", nil)

M.ControlFrame.MoneyFrame.info = {
    truncateSmallCoins = true,
    collapse = 1,
    showSmallerCoins = "Backpack",
}

MoneyFrame_Update(M.ControlFrame.MoneyFrame, 0)

M.ControlFrame.TokenFrame = CreateFrame("FRAME", nil, M, nil)
M.ControlFrame.TokenFrame:SetPoint("RIGHT", M.ControlFrame.RollButton, "LEFT", -3,0) 
M.ControlFrame.TokenFrame:SetSize(109, 28)

M.ControlFrame.TokenFrame.TokenButton = CreateFrame("BUTTON", nil, M.ControlFrame.TokenFrame)
M.ControlFrame.TokenFrame.TokenButton:SetSize(16, 16)
M.ControlFrame.TokenFrame.TokenButton:SetPoint("RIGHT", M.ControlFrame.TokenFrame, "RIGHT", -8, 0)
M.ControlFrame.TokenFrame.TokenButton.Item = ReforgeToken
M.ControlFrame.TokenFrame.TokenButton:SetScript("OnEnter", ItemButtonOnEnter)
M.ControlFrame.TokenFrame.TokenButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
M.ControlFrame.TokenFrame.TokenButton:SetScript("OnClick", ItemButtonOnClick)

M.ControlFrame.TokenFrame.TokenText = M.ControlFrame.TokenFrame:CreateFontString()
M.ControlFrame.TokenFrame.TokenText:SetFontObject(GameFontNormal)
--M.ControlFrame.TokenFrame.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
M.ControlFrame.TokenFrame.TokenText:SetPoint("RIGHT", M.ControlFrame.TokenFrame.TokenButton, "LEFT", -4, 0)
M.ControlFrame.TokenFrame.TokenText:SetText("Rune: |cffFFFFFF1000|r")
M.ControlFrame.TokenFrame.TokenText:SetJustifyH("LEFT")

M.ControlFrame.TokenFrame.TokenButton.Icon = M.ControlFrame.TokenFrame.TokenButton:CreateTexture(nil, "ARTWORK")
M.ControlFrame.TokenFrame.TokenButton.Icon:SetSize(12,12)
M.ControlFrame.TokenFrame.TokenButton.Icon:SetPoint("CENTER", 0, 0)
M.ControlFrame.TokenFrame.TokenButton.Icon:SetTexture(ReforgeTokenTexture)
M.ControlFrame.TokenFrame:Hide()


M.ControlFrame.Currency = CreateFrame("FRAME", nil, M.ControlFrame)
M.ControlFrame.Currency:SetSize(M:GetWidth()-30, 24)
M.ControlFrame.Currency:SetPoint("BOTTOM", M, 0, 9)

-------------------------------------------------------------------------------
--                              Active Enchants                              --
-------------------------------------------------------------------------------
M.ControlFrame.Currency.ActiveText = M.ControlFrame.Currency:CreateFontString()
M.ControlFrame.Currency.ActiveText:SetFontObject(GameFontNormalSmall)
M.ControlFrame.Currency.ActiveText:SetPoint("LEFT", M.ControlFrame.Currency, "LEFT", 8, 1)
M.ControlFrame.Currency.ActiveText:SetJustifyH("LEFT")
M.ControlFrame.Currency.ActiveText:SetText("Limites d'effet: ")

M.ControlFrame.Currency.TotalLeg = ActiveEffectButtonTemplate(M.ControlFrame.Currency)
M.ControlFrame.Currency.TotalLeg:SetPoint("LEFT", M.ControlFrame.Currency.ActiveText, "RIGHT", 16, 0)
M.ControlFrame.Currency.TotalLeg.text:SetPoint("LEFT", M.ControlFrame.Currency.ActiveText, "RIGHT", 2, 0)
M.ControlFrame.Currency.TotalLeg.total = 1
M.ControlFrame.Currency.TotalLeg.quality = 5
M.ControlFrame.Currency.TotalLeg.tooltip = "Legendary"
M.ControlFrame.Currency.TotalLeg.UpdateText()
M.ControlFrame.Currency.TotalLeg.btn:SetNormalTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\QualityLegLight")
M.ControlFrame.Currency.TotalLeg.btn:SetHighlightTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\QualityLegLight")

M.ControlFrame.Currency.TotalEpic = ActiveEffectButtonTemplate(M.ControlFrame.Currency)
M.ControlFrame.Currency.TotalEpic:SetPoint("LEFT", M.ControlFrame.Currency.TotalLeg.btn, "RIGHT", -4, 0)
M.ControlFrame.Currency.TotalEpic.text:SetPoint("LEFT", M.ControlFrame.Currency.TotalLeg.btn, "RIGHT", -4, 0)
M.ControlFrame.Currency.TotalEpic.total = 3
M.ControlFrame.Currency.TotalEpic.quality = 4
M.ControlFrame.Currency.TotalEpic.tooltip = "Epic"
M.ControlFrame.Currency.TotalEpic.UpdateText()

M.ControlFrame.Currency.TotalRare = ActiveEffectButtonTemplate(M.ControlFrame.Currency)
M.ControlFrame.Currency.TotalRare:SetPoint("LEFT", M.ControlFrame.Currency.TotalEpic.btn, "RIGHT", -4, 0)
M.ControlFrame.Currency.TotalRare.text:SetPoint("LEFT", M.ControlFrame.Currency.TotalEpic.btn, "RIGHT", -4, 0)
M.ControlFrame.Currency.TotalRare.total = 13
M.ControlFrame.Currency.TotalRare.active = 13
M.ControlFrame.Currency.TotalRare.quality = 3
M.ControlFrame.Currency.TotalRare.tooltip = "Rare/|cff00FF00Commun|r"
M.ControlFrame.Currency.TotalRare.UpdateText()

M.ControlFrame.Currency.TotalRare.btn:SetNormalTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\QualityRareLight")
M.ControlFrame.Currency.TotalRare.btn:SetHighlightTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\QualityRareLight")
M.ControlFrame.Currency.TotalRare:Hide()
-- mystic rune
M.ControlFrame.Currency.TokenText = M.ControlFrame.Currency:CreateFontString()
M.ControlFrame.Currency.TokenText:SetFontObject(GameFontNormalSmall)
M.ControlFrame.Currency.TokenText:SetPoint("LEFT", M.ControlFrame.Currency.TotalEpic.btn, "RIGHT", 0, 0)
M.ControlFrame.Currency.TokenText:SetText("Rune: |cffFFFFFF1000|r")
M.ControlFrame.Currency.TokenText:SetJustifyH("LEFT")

M.ControlFrame.Currency.TokenButton = CreateFrame("BUTTON", nil, M.ControlFrame.Currency)
M.ControlFrame.Currency.TokenButton:SetSize(16, 16)
M.ControlFrame.Currency.TokenButton:SetPoint("LEFT", M.ControlFrame.Currency.TokenText, "RIGHT", 4, 0)
M.ControlFrame.Currency.TokenButton.Item = ReforgeToken
M.ControlFrame.Currency.TokenButton:SetScript("OnEnter", ItemButtonOnEnter)
M.ControlFrame.Currency.TokenButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
M.ControlFrame.Currency.TokenButton:SetScript("OnClick", ItemButtonOnClick)

M.ControlFrame.Currency.TokenButton.Icon = M.ControlFrame.Currency.TokenButton:CreateTexture( nil, "ARTWORK")
M.ControlFrame.Currency.TokenButton.Icon:SetSize(12,12)
M.ControlFrame.Currency.TokenButton.Icon:SetPoint("CENTER", 0, 0)
M.ControlFrame.Currency.TokenButton.Icon:SetTexture(ReforgeTokenTexture)

-- mystic orbC
M.ControlFrame.Currency.OrbText = M.ControlFrame.Currency:CreateFontString()
M.ControlFrame.Currency.OrbText:SetFontObject(GameFontNormalSmall)
M.ControlFrame.Currency.OrbText:SetPoint("LEFT", M.ControlFrame.Currency.TokenButton, "RIGHT", 8, 0)
M.ControlFrame.Currency.OrbText:SetText("Orb: |cffFFFFFF1000|r")
M.ControlFrame.Currency.OrbText:SetJustifyH("LEFT")

M.ControlFrame.Currency.OrbButton = CreateFrame("BUTTON", nil, M.ControlFrame.Currency)
M.ControlFrame.Currency.OrbButton:SetSize(16, 16)
M.ControlFrame.Currency.OrbButton:SetPoint("LEFT", M.ControlFrame.Currency.OrbText, "RIGHT", 4, 0)
M.ControlFrame.Currency.OrbButton.Item = ReforgeOrb
M.ControlFrame.Currency.OrbButton:SetScript("OnEnter", ItemButtonOnEnter)
M.ControlFrame.Currency.OrbButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
M.ControlFrame.Currency.OrbButton:SetScript("OnClick", ItemButtonOnClick)

M.ControlFrame.Currency.OrbButton.Icon = M.ControlFrame.Currency.OrbButton:CreateTexture(nil, "ARTWORK")
M.ControlFrame.Currency.OrbButton.Icon:SetSize(12,12)
M.ControlFrame.Currency.OrbButton.Icon:SetPoint("CENTER", 0, 0)
M.ControlFrame.Currency.OrbButton.Icon:SetTexture(ReforgeOrbTexture)

-- mystic Extract

M.ControlFrame.Currency.ExtractText = M.ControlFrame.Currency:CreateFontString()
M.ControlFrame.Currency.ExtractText:SetFontObject(GameFontNormalSmall)
--M.ControlFrame.Currency.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
M.ControlFrame.Currency.ExtractText:SetPoint("LEFT", M.ControlFrame.Currency.OrbButton, "RIGHT", 8, 0)
M.ControlFrame.Currency.ExtractText:SetText("Extract: |cffFFFFFF1000|r")
M.ControlFrame.Currency.ExtractText:SetJustifyH("RIGHT")

M.ControlFrame.Currency.ExtractButton = CreateFrame("BUTTON", nil, M.ControlFrame.Currency)
M.ControlFrame.Currency.ExtractButton:SetSize(16, 16)
M.ControlFrame.Currency.ExtractButton:SetPoint("LEFT", M.ControlFrame.Currency.ExtractText, "RIGHT", 4, 0)
M.ControlFrame.Currency.ExtractButton.Item = ReforgeExtract
M.ControlFrame.Currency.ExtractButton:SetScript("OnEnter", ItemButtonOnEnter)
M.ControlFrame.Currency.ExtractButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
M.ControlFrame.Currency.ExtractButton:SetScript("OnClick", ItemButtonOnClick)

M.ControlFrame.Currency.ExtractButton.Icon = M.ControlFrame.Currency.ExtractButton:CreateTexture(nil, "ARTWORK")
M.ControlFrame.Currency.ExtractButton.Icon:SetSize(12,12)
M.ControlFrame.Currency.ExtractButton.Icon:SetPoint("CENTER", 0, 0)
M.ControlFrame.Currency.ExtractButton.Icon:SetTexture(ReforgeExtractTexture)
-------------------------------------------------------------------------------
--                             New Enchant Menu                              --
-------------------------------------------------------------------------------
M.CollectionsList.AnimationBackground = CreateFrame("FRAME", nil, M.CollectionsList, nil)
M.CollectionsList.AnimationBackground:SetPoint("CENTER", M.CollectionsList, 0, 0)
M.CollectionsList.AnimationBackground:SetSize(512,512)
M.CollectionsList.AnimationBackground:SetFrameLevel(7)
M.CollectionsList.AnimationBackground:Hide()

M.CollectionsList.AnimationBackground.BackgroundTexture = M.CollectionsList.AnimationBackground:CreateTexture(nil, "BACKGROUND")
M.CollectionsList.AnimationBackground.BackgroundTexture:SetSize(512,512)
M.CollectionsList.AnimationBackground.BackgroundTexture:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\Shadow")
M.CollectionsList.AnimationBackground.BackgroundTexture:SetPoint("CENTER", 0,0)

M.CollectionsList.AnimationBackground.HighLightOfNewItem = CreateFrame("FRAME", nil, M.CollectionsList.AnimationBackground, nil)
M.CollectionsList.AnimationBackground.HighLightOfNewItem:SetPoint("CENTER", M.CollectionsList.AnimationBackground, -67, 0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem:SetSize(256,256)
M.CollectionsList.AnimationBackground.HighLightOfNewItem:SetFrameLevel(7)

M.CollectionsList.AnimationBackground.HighLightOfNewItem.HighlightTex = M.CollectionsList.AnimationBackground.HighLightOfNewItem:CreateTexture(nil, "ARTWORK")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.HighlightTex:SetSize(256,256)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.HighlightTex:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\DragonHighlight")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.HighlightTex:SetPoint("CENTER", 0,0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.HighlightTex:SetBlendMode("ADD")

M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow = CreateFrame("Model", nil, M.CollectionsList.AnimationBackground.HighLightOfNewItem)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetWidth(256);               
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetHeight(256);
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetPoint("CENTER", 5, -10)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetModel("World\\Kalimdor\\silithus\\passivedoodads\\ahnqirajglow\\quirajglow.m2")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetModelScale(0.02)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetCamera(0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetPosition(0.075,0.09,0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetFacing(0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.Glow:SetFrameLevel(7)

M.CollectionsList.NewEnchantInCollection = CreateFrame("FRAME", nil, M.CollectionsList, nil)
M.CollectionsList.NewEnchantInCollection:SetPoint("CENTER", M.CollectionsList, -10, -10)
M.CollectionsList.NewEnchantInCollection:SetSize(128,64)
M.CollectionsList.NewEnchantInCollection:SetFrameLevel(8)
M.CollectionsList.NewEnchantInCollection:EnableMouse(true)
M.CollectionsList.NewEnchantInCollection:SetAlpha(0)
M.CollectionsList.NewEnchantInCollection:Hide()

M.CollectionsList.NewEnchantInCollection:SetScript("OnMouseUp", function(self, button)
    if button == "RightButton" then 
        M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:Stop()
        M.CollectionsList.NewEnchantInCollection.AnimationGroup:Stop()
    end
end)

M.CollectionsList.NewEnchantInCollection.BackgroundTexture = M.CollectionsList.NewEnchantInCollection:CreateTexture(nil, "BACKGROUND")
M.CollectionsList.NewEnchantInCollection.BackgroundTexture:SetSize(39,39)
M.CollectionsList.NewEnchantInCollection.BackgroundTexture:SetTexture("Interface\\Icons\\INV_Chest_Samurai")
M.CollectionsList.NewEnchantInCollection.BackgroundTexture:SetPoint("LEFT",M.CollectionsList.NewEnchantInCollection, -10,-1)

M.CollectionsList.NewEnchantInCollection.Texture = M.CollectionsList.NewEnchantInCollection:CreateTexture(nil, "OVERLAY")
M.CollectionsList.NewEnchantInCollection.Texture:SetSize(200, 100)
M.CollectionsList.NewEnchantInCollection.Texture:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\NewEnchantUnlocked")
M.CollectionsList.NewEnchantInCollection.Texture:SetPoint("CENTER",0,0)

M.CollectionsList.NewEnchantInCollection.TextNormal = M.CollectionsList.NewEnchantInCollection:CreateFontString(nil, "OVERLAY")
M.CollectionsList.NewEnchantInCollection.TextNormal:SetSize(90, 20)
M.CollectionsList.NewEnchantInCollection.TextNormal:SetFont("Fonts\\FRIZQT__.TTF", 12)
M.CollectionsList.NewEnchantInCollection.TextNormal:SetFontObject(GameFontNormal)
M.CollectionsList.NewEnchantInCollection.TextNormal:SetPoint("CENTER", 15, 0)
M.CollectionsList.NewEnchantInCollection.TextNormal:SetShadowOffset(0,-1)
M.CollectionsList.NewEnchantInCollection.TextNormal:SetText("Enchant Effect Name")

M.CollectionsList.NewEnchantInCollection.TextAdd = M.CollectionsList.NewEnchantInCollection:CreateFontString(nil, "OVERLAY")
M.CollectionsList.NewEnchantInCollection.TextAdd:SetSize(300, 20)
M.CollectionsList.NewEnchantInCollection.TextAdd:SetFont("Fonts\\FRIZQT__.TTF", 11)
M.CollectionsList.NewEnchantInCollection.TextAdd:SetFontObject(GameFontNormal)
M.CollectionsList.NewEnchantInCollection.TextAdd:SetPoint("BOTTOM", 0, -20)
M.CollectionsList.NewEnchantInCollection.TextAdd:SetShadowOffset(0,-1)
M.CollectionsList.NewEnchantInCollection.TextAdd:SetText("|cffFFFFFFDébloqué avec succès|r!")
-------------------------------------------------------------------------------
--                           Place item animation                            --
-------------------------------------------------------------------------------
M.EnchantFrame.BGHighlight.AG = M.EnchantFrame.BGHighlight:CreateAnimationGroup()

M.EnchantFrame.BGHighlight.AG.Alpha0 = M.EnchantFrame.BGHighlight.AG:CreateAnimation("Alpha")
M.EnchantFrame.BGHighlight.AG.Alpha0:SetStartDelay(0)
M.EnchantFrame.BGHighlight.AG.Alpha0:SetDuration(0.4)
M.EnchantFrame.BGHighlight.AG.Alpha0:SetOrder(0)
M.EnchantFrame.BGHighlight.AG.Alpha0:SetEndDelay(0)
M.EnchantFrame.BGHighlight.AG.Alpha0:SetSmoothing("IN")
M.EnchantFrame.BGHighlight.AG.Alpha0:SetChange(1)

M.EnchantFrame.BGHighlight.AG.Alpha1 = M.EnchantFrame.BGHighlight.AG:CreateAnimation("Alpha")
M.EnchantFrame.BGHighlight.AG.Alpha1:SetStartDelay(0)
M.EnchantFrame.BGHighlight.AG.Alpha1:SetDuration(1)
M.EnchantFrame.BGHighlight.AG.Alpha1:SetOrder(0)
M.EnchantFrame.BGHighlight.AG.Alpha1:SetEndDelay(0)
M.EnchantFrame.BGHighlight.AG.Alpha1:SetSmoothing("IN_OUT")
M.EnchantFrame.BGHighlight.AG.Alpha1:SetChange(-1)

-- constant animation of inactive label to attract player's attention to it
M.EnchantFrame.BreathTex.AG = M.EnchantFrame.BreathTex:CreateAnimationGroup()

M.EnchantFrame.BreathTex.AG.Alpha0 = M.EnchantFrame.BreathTex.AG:CreateAnimation("Alpha")
M.EnchantFrame.BreathTex.AG.Alpha0:SetStartDelay(0.5)
M.EnchantFrame.BreathTex.AG.Alpha0:SetDuration(0.5)
M.EnchantFrame.BreathTex.AG.Alpha0:SetOrder(1)
M.EnchantFrame.BreathTex.AG.Alpha0:SetEndDelay(0)
M.EnchantFrame.BreathTex.AG.Alpha0:SetSmoothing("IN")
M.EnchantFrame.BreathTex.AG.Alpha0:SetChange(1)

M.EnchantFrame.BreathTex.AG.Alpha1 = M.EnchantFrame.BreathTex.AG:CreateAnimation("Alpha")
M.EnchantFrame.BreathTex.AG.Alpha1:SetStartDelay(0)
M.EnchantFrame.BreathTex.AG.Alpha1:SetDuration(2)
M.EnchantFrame.BreathTex.AG.Alpha1:SetOrder(2)
M.EnchantFrame.BreathTex.AG.Alpha1:SetEndDelay(2)
M.EnchantFrame.BreathTex.AG.Alpha1:SetSmoothing("IN_OUT")
M.EnchantFrame.BreathTex.AG.Alpha1:SetChange(-1)

M.EnchantFrame.BreathTex.AG:SetScript("OnFinished", function()
    M.EnchantFrame.BreathTex.AG:Play()
end)

M.EnchantFrame.BreathTex.AG:Play()
-------------------------------------------------------------------------------
--                     New enchant unlocked animations                       --
-------------------------------------------------------------------------------
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup = M.CollectionsList.AnimationBackground.HighLightOfNewItem:CreateAnimationGroup()
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation = M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:CreateAnimation("Rotation")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetStartDelay(0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetDuration(6)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetOrder(1)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetEndDelay(0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetSmoothing("NONE")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetDegrees(90)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.Rotation:SetScript("OnPlay", function()
    Addon:BaseFrameFadeIn(M.CollectionsList.AnimationBackground)
end)

M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut = M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:CreateAnimation("Alpha")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetStartDelay(0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetDuration(3)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetOrder(2)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetEndDelay(0)
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetSmoothing("NONE")
M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetChange(-1)

M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:SetScript("OnStop", function()
    M.CollectionsList.AnimationBackground:Hide()
end)

M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:SetScript("OnFinished", function()
    M.CollectionsList.AnimationBackground:Hide()
end)


M.CollectionsList.NewEnchantInCollection.AnimationGroup = M.CollectionsList.NewEnchantInCollection:CreateAnimationGroup()
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha = M.CollectionsList.NewEnchantInCollection.AnimationGroup:CreateAnimation("Alpha")
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetStartDelay(0)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetDuration(1)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetOrder(1)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetEndDelay(5)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetSmoothing("NONE")
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetChange(1)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.Alpha:SetScript("OnPlay", function()
    PlaySound("igQuestListComplete")
    M.CollectionsList.NewEnchantInCollection:Show()
    M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:Play()
end)

M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut = M.CollectionsList.NewEnchantInCollection.AnimationGroup:CreateAnimation("Alpha")
M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut:SetStartDelay(0)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut:SetDuration(3)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut:SetOrder(2)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut:SetEndDelay(0)
M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut:SetSmoothing("NONE")
M.CollectionsList.NewEnchantInCollection.AnimationGroup.AlphaFadeOut:SetChange(-1)

M.CollectionsList.NewEnchantInCollection.AnimationGroup:SetScript("OnStop", function()
    M.CollectionsList.NewEnchantInCollection:Hide()
    M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:Finish()
end)

M.CollectionsList.NewEnchantInCollection.AnimationGroup:SetScript("OnFinished", function()
    M.CollectionsList.NewEnchantInCollection:Hide()
    M.CollectionsList.AnimationBackground.HighLightOfNewItem.AnimationGroup:Finish()
end)
-------------------------------------------------------------------------------
--                     Disenchant Confirm Dialog Frame                       --
-------------------------------------------------------------------------------
M.ConfirmDisenchant = CreateFrame("Frame", nil, M, nil)
M.ConfirmDisenchant:ClearAllPoints()
M.ConfirmDisenchant:SetBackdrop(StaticPopup1:GetBackdrop())
M.ConfirmDisenchant:SetHeight(115)
M.ConfirmDisenchant:SetWidth(390)
M.ConfirmDisenchant:SetPoint("CENTER", M, 0,0)
M.ConfirmDisenchant:SetFrameLevel(10)
M.ConfirmDisenchant:EnableMouse(true)
M.ConfirmDisenchant:Hide()

M.ConfirmDisenchant.Mode = "DISENCHANT"

M.ConfirmDisenchant.text = M.ConfirmDisenchant:CreateFontString(nil, "BORDER", "GameFontHighlight")
M.ConfirmDisenchant.text:SetFont("Fonts\\FRIZQT__.TTF", 11)
M.ConfirmDisenchant.text:SetFontObject(GameFontNormal)
M.ConfirmDisenchant.text:SetText("Are you sure that you want\nto disenchant following item:\n\nITEMLINK")
M.ConfirmDisenchant.text:SetPoint("TOP",0,-20)

M.ConfirmDisenchant.Alert = M.ConfirmDisenchant:CreateTexture()
M.ConfirmDisenchant.Alert:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
M.ConfirmDisenchant.Alert:SetSize(48,48)
M.ConfirmDisenchant.Alert:SetPoint("LEFT",24,0)

M.ConfirmDisenchant.Yes = CreateFrame("Button", nil, M.ConfirmDisenchant, "StaticPopupButtonTemplate")
M.ConfirmDisenchant.Yes:SetWidth(110)
M.ConfirmDisenchant.Yes:SetHeight(19)
M.ConfirmDisenchant.Yes:SetPoint("BOTTOM", -60,15)
M.ConfirmDisenchant.Yes:SetScript("OnClick", function()
  DisenchantItem()
  M.ConfirmDisenchant:Hide()
end)

M.ConfirmDisenchant.No = CreateFrame("Button", nil, M.ConfirmDisenchant, "StaticPopupButtonTemplate")
M.ConfirmDisenchant.No:SetWidth(110)
M.ConfirmDisenchant.No:SetHeight(19)
M.ConfirmDisenchant.No:SetPoint("BOTTOM", 60,15)
M.ConfirmDisenchant.No:SetScript("OnClick", function()
  M.ConfirmDisenchant:Hide()
end)

M.ConfirmDisenchant.Yes.text = M.ConfirmDisenchant.Yes:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
M.ConfirmDisenchant.Yes.text:SetFont("Fonts\\FRIZQT__.TTF", 11)
M.ConfirmDisenchant.Yes.text:SetText("Accept")
M.ConfirmDisenchant.Yes.text:SetPoint("CENTER",0,1)

M.ConfirmDisenchant.No.text = M.ConfirmDisenchant.No:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
M.ConfirmDisenchant.No.text:SetFont("Fonts\\FRIZQT__.TTF", 11)
M.ConfirmDisenchant.No.text:SetText("Cancel")
M.ConfirmDisenchant.No.text:SetPoint("CENTER",0,1)

M.ConfirmDisenchant.Yes:SetFontString(M.ConfirmDisenchant.Yes.text)
M.ConfirmDisenchant.No:SetFontString(M.ConfirmDisenchant.No.text)

M.ConfirmDisenchant.Enchant = CollectionEnchantTemplate(M.ConfirmDisenchant)
M.ConfirmDisenchant.Enchant:SetPoint("BOTTOMRIGHT", M.ConfirmDisenchant.Alert, 14, -16)
M.ConfirmDisenchant.Enchant:SetSize(48, 48)
M.ConfirmDisenchant.Enchant.Icon:SetSize(36,36)
M.ConfirmDisenchant.Enchant.Maxed:SetSize(48,48)
M.ConfirmDisenchant.Enchant:GetHighlightTexture():ClearAllPoints()
M.ConfirmDisenchant.Enchant:GetHighlightTexture():SetSize(64,64)
M.ConfirmDisenchant.Enchant:GetHighlightTexture():SetPoint("CENTER", 0, 0)


M.ConfirmDisenchant:SetScript("OnShow", function(self)
    PlaySound("igMainMenuOpen")
    if (self.Mode == "DISENCHANT") then
        M.ConfirmDisenchant.Yes:SetScript("OnClick", function()
            PlaySound("igMainMenuOptionCheckBoxOn")
            DisenchantItem()
            M.ConfirmDisenchant:Hide()
        end)
    elseif (self.Mode == "COLLECTIONREFORGE") then
        M.ConfirmDisenchant.Yes:SetScript("OnClick", function()
            PlaySound("igMainMenuOptionCheckBoxOn")
            CollectionReforge()
            M.ConfirmDisenchant:Hide()
        end)
    elseif (self.Mode == "REFUND") then
        M.ConfirmDisenchant.Yes:SetScript("OnClick", function()
            PlaySound("igMainMenuOptionCheckBoxOn")
            RefundEnchant()
            M.ConfirmDisenchant:Hide()
        end)
    end
end)
M.ConfirmDisenchant:SetScript("OnHide", function(self)
    PlaySound("igMainMenuClose")
end)
-------------------------------------------------------------------------------
--                            Paper Doll Changes                             --
-------------------------------------------------------------------------------

local PaperDollEnchantHandlerFrame = CreateFrame("FRAME")
PaperDollEnchantHandlerFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
PaperDollEnchantHandlerFrame:SetScript("OnEvent", function()
        UpdatePaperDoll()
    end)

for i, parent in pairs(ParentButtons) do
    _G["EnchantStackDisplayButton"..i] = CreateFrame("Button", "EnchantStackDisplayButton"..i, parent, nil)
    _G["EnchantStackDisplayButton"..i]:SetSize(24, 24)
    _G["EnchantStackDisplayButton"..i]:SetPoint("BOTTOMRIGHT",4,-4)
    _G["EnchantStackDisplayButton"..i]:EnableMouse(true)
    _G["EnchantStackDisplayButton"..i]:SetNormalTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\EnchantBorder")
    _G["EnchantStackDisplayButton"..i]:SetHighlightTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\EnchantBorder_highlight")
    _G["EnchantStackDisplayButton"..i]:GetHighlightTexture():ClearAllPoints()
    _G["EnchantStackDisplayButton"..i]:GetHighlightTexture():SetSize(32,32)
    _G["EnchantStackDisplayButton"..i]:GetHighlightTexture():SetPoint("CENTER", 0, 0)

    _G["EnchantStackDisplayButton"..i].Icon = _G["EnchantStackDisplayButton"..i]:CreateTexture(nil, "BORDER", nil, 10)
    _G["EnchantStackDisplayButton"..i].Icon:SetSize(18,18)
    SetPortraitToTexture(_G["EnchantStackDisplayButton"..i].Icon, "Interface\\Icons\\inv_chest_samurai")
    _G["EnchantStackDisplayButton"..i].Icon:SetPoint("CENTER", 0, 0)

    _G["EnchantStackDisplayButton"..i].Maxed = _G["EnchantStackDisplayButton"..i]:CreateTexture(nil, "OVERLAY", nil, 10)
    _G["EnchantStackDisplayButton"..i].Maxed:SetSize(18,18)
    _G["EnchantStackDisplayButton"..i].Maxed:SetPoint("CENTER", 0, 0)
    _G["EnchantStackDisplayButton"..i].Maxed:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\RedSign")

    _G["EnchantStackDisplayButton"..i]:SetScript("OnEnter", StackDisplayOnEnter)

    _G["EnchantStackDisplayButton"..i]:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    _G["EnchantStackDisplayButton"..i]:SetScript("OnClick", function(self, button)
        if ( IsModifiedClick() ) then
            EnchantStackDisplayButton_OnModifiedClick(self, button);
        end
    end)

    _G["EnchantStackDisplayButton"..i]:Hide()
end

--AIO.Handle("EnchantReRoll", "GetStackDataAll") 
-------------------------------------------------------------------------------
--                               Refund Thing                                --
-------------------------------------------------------------------------------
M.EnchantFrame.Enchant.Refund = CreateFrame("BUTTON", nil, M.EnchantFrame.Enchant)
M.EnchantFrame.Enchant.Refund:Hide()
M.EnchantFrame.Enchant.Refund:SetPoint("LEFT", M.EnchantFrame.Enchant, "RIGHT", -8, 0)
M.EnchantFrame.Enchant.Refund:SetSize(24, 24)
M.EnchantFrame.Enchant.Refund:SetNormalTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\QuestionMark")
M.EnchantFrame.Enchant.Refund:SetHighlightTexture("Interface\\Addons\\AwAddons\\Textures\\EnchOverhaul\\QuestionMark")
M.EnchantFrame.Enchant.Refund:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("|cffFFFFFFOups, on dirait que nous avons changé cet enchantement!|r")
    GameTooltip:AddLine("Vous pouvez échanger l'enchantement de cet objet contre une qualité égale \nou inférieure contre |cffFFFFFFFREE|r.")
    GameTooltip:Show()
end)

M.EnchantFrame.Enchant.Refund:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

M.EnchantFrame.Enchant.Refund.AnimG = M.EnchantFrame.Enchant.Refund:CreateAnimationGroup()
M.EnchantFrame.Enchant.Refund.AnimG.Rotation0 = M.EnchantFrame.Enchant.Refund.AnimG:CreateAnimation("Translation")
M.EnchantFrame.Enchant.Refund.AnimG.Rotation0:SetDuration(2)
M.EnchantFrame.Enchant.Refund.AnimG.Rotation0:SetOrder(1)
M.EnchantFrame.Enchant.Refund.AnimG.Rotation0:SetSmoothing("IN_OUT")
M.EnchantFrame.Enchant.Refund.AnimG.Rotation0:SetOffset(0, -5)

M.EnchantFrame.Enchant.Refund.AnimG.Rotation1 = M.EnchantFrame.Enchant.Refund.AnimG:CreateAnimation("Translation")
M.EnchantFrame.Enchant.Refund.AnimG.Rotation1:SetDuration(2)
M.EnchantFrame.Enchant.Refund.AnimG.Rotation1:SetOrder(2)
M.EnchantFrame.Enchant.Refund.AnimG.Rotation1:SetSmoothing("IN_OUT")
M.EnchantFrame.Enchant.Refund.AnimG.Rotation1:SetOffset(0, 5)

M.EnchantFrame.Enchant.Refund.AnimG:SetScript("OnFinished", function(self)
    self:Play()
end)

M.EnchantFrame.Enchant.Refund.AnimG:Play()
-------------------------------------------------------------------------------
--                              Animation part                               --
-------------------------------------------------------------------------------
                            --Level up animation--
--Progress bar hover animation
--[[M.ProgressBar.ArtWork_Hover.AnimationGroup = M.ProgressBar.ArtWork_Hover:CreateAnimationGroup()

M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha = M.ProgressBar.ArtWork_Hover.AnimationGroup:CreateAnimation("Alpha")
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha:SetStartDelay(0)
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha:SetDuration(0.5)
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha:SetOrder(1)
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha:SetEndDelay(0)
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha:SetSmoothing("IN_OUT")
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha:SetChange(1)
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha:SetScript("OnPlay", function()
    PlaySound("LEVELUP")
    M.ProgressBar.ArtWork_Hover:Show()
end)

M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha2 = M.ProgressBar.ArtWork_Hover.AnimationGroup:CreateAnimation("Alpha")
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha2:SetStartDelay(0)
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha2:SetDuration(2)
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha2:SetOrder(2)
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha2:SetEndDelay(0)
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha2:SetSmoothing("NONE")
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha2:SetChange(-1)
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha2:SetScript("OnFinished", function()
    M.ProgressBar.ArtWork_Hover:SetAlpha(0)
    M.ProgressBar.ArtWork_Hover:Hide()
end)
M.ProgressBar.ArtWork_Hover.AnimationGroup.Alpha2:SetScript("OnStop", function()
    M.ProgressBar.ArtWork_Hover:SetAlpha(0)
    M.ProgressBar.ArtWork_Hover:Hide()
end)

--Fill progress bar with hover
M.ProgressBar.Hover.AnimationGroup = M.ProgressBar.Hover:CreateAnimationGroup()
M.ProgressBar.Hover.AnimationGroup.Scale = M.ProgressBar.Hover.AnimationGroup:CreateAnimation("Scale")
M.ProgressBar.Hover.AnimationGroup.Scale:SetStartDelay(0) 
M.ProgressBar.Hover.AnimationGroup.Scale:SetDuration(0)
M.ProgressBar.Hover.AnimationGroup.Scale:SetOrder(1)
M.ProgressBar.Hover.AnimationGroup.Scale:SetEndDelay(0)
M.ProgressBar.Hover.AnimationGroup.Scale:SetScale(0.1,1)

M.ProgressBar.Hover.AnimationGroup.Scale:SetScript("OnPlay", function()
    Addon:BaseFrameFadeIn(M.ProgressBar.Hover)
    M.ProgressBar.ArtWork_Hover.AnimationGroup:Play()
end)

M.ProgressBar.Hover.AnimationGroup.Scale2 = M.ProgressBar.Hover.AnimationGroup:CreateAnimation("Scale")
M.ProgressBar.Hover.AnimationGroup.Scale2:SetDuration(0.2)
M.ProgressBar.Hover.AnimationGroup.Scale2:SetOrder(2)
M.ProgressBar.Hover.AnimationGroup.Scale2:SetEndDelay(0)
M.ProgressBar.Hover.AnimationGroup.Scale2:SetScale(10,1)
M.ProgressBar.Hover.AnimationGroup.Scale2:SetScript("OnFinished", function()
    Addon:BaseFrameFadeOut(M.ProgressBar.Hover)
    M.ProgressBar:SetMinMaxValues(0,M.ProgressBar.MinMaxValues)
    M.ProgressBar:SetValue(M.ProgressBar.ValueToSet)
    M.LevelFrame.TitleText:SetText(M.ProgressBar.NextLevel)
    M.TitleText:SetText(string.format("Mystic Altar - |cffFFFFFFLevel %i", M.ProgressBar.NextLevel))
    --M.ProgressBar.ProgressText:SetText(M.ProgressBar.ValueToSet.."/"..M.ProgressBar.MinMaxValues)
end)
M.ProgressBar.Hover.AnimationGroup.Scale2:SetScript("OnStop", function()
    Addon:BaseFrameFadeOut(M.ProgressBar.Hover)
    M.ProgressBar:SetMinMaxValues(0,M.ProgressBar.MinMaxValues)
    M.ProgressBar:SetValue(M.ProgressBar.ValueToSet)
    M.LevelFrame.TitleText:SetText(M.ProgressBar.NextLevel)
    M.TitleText:SetText(string.format("Mystic Altar - |cffFFFFFFLevel %i", M.ProgressBar.NextLevel))
    --M.ProgressBar.ProgressText:SetText(M.ProgressBar.ValueToSet.."/"..M.ProgressBar.MinMaxValues)
end)]]--


-------------------------------------------------------------------------------
--                                 HOOKS                                     --
-------------------------------------------------------------------------------

function Ascension_OnEvent(event, ...)
    --print("Ascension Event:", event, unpack(...))

    if event == "ASCENSION_REFORGE_ENCHANTMENT_LEARNED" then
        local enchantID = unpack(...)
        if not enchantID or not GetREData(enchantID) then
            SendSystemMessage(format("REFORGE_ENCHANTMENT_LEARNED: Received invalid enchant with id: [%s] Tell a developer", enchantID))
            return
        end
        if not M:IsVisible() then
            M:Display()
        end
        ReceiveNewEnchant(enchantID)
    
    elseif event == "ASCENSION_REFORGE_ENCHANT_WINDOW_VISIBILITY_CHANGED" then 
        local show = unpack(...)
        if show then 
            DID_GOSSIP_ALTAR = true
            M:Display()
        else
            M:Close()
        end

    elseif event == "ASCENSION_REFORGE_ENCHANT_RESULT" then
        local GUID, enchantID = unpack(...)
        if not enchantID or enchantID == 0 or not GetREData(enchantID) then return end

        OnReforgeSuccess(GUID, enchantID)

    elseif event == "ASCENSION_REFORGE_PROGRESS_UPDATE" then
        local progress, level = unpack(...)
        UpdateProgress(level, progress)
    end
end

CharacterFrame:HookScript("OnShow", function() UpdatePaperDollEnchantList() end)
M:RegisterEvent("ITEM_LOCKED")
M:RegisterEvent("PLAYER_ENTERING_WORLD")
M:RegisterEvent("UNIT_MODEL_CHANGED")
M:RegisterEvent("ADDON_LOADED")
M:RegisterEvent("COMMENTATOR_SKIRMISH_QUEUE_REQUEST") -- Ascension events

M:SetScript("OnEvent", function(self, event, ...)
    if event == "COMMENTATOR_SKIRMISH_QUEUE_REQUEST" then 
        Ascension_OnEvent(select(1, ...), { select(2, ...) })

    elseif (event == "ITEM_LOCKED") then
        GetLastLockedItem(...)

    elseif ( event == "PLAYER_ENTERING_WORLD" or event == "UNIT_MODEL_CHANGED") then
        UpdatePaperDoll()
        UpdateProgress(self.CDB.EnchantLevel, self.CDB.EnchantProgress)

        local unit = ...
        if (unit == "player") then
            M.PaperDoll.Model:SetUnit("player")
        end

    elseif event == "ADDON_LOADED" then
        local name = ...
        if name ~= AddonName then return end
        
        AscensionUI.DB.MysticEnchant = AscensionUI.DB.MysticEnchant or {}
        self.DB = AscensionUI.DB.MysticEnchant

        AscensionUI.CDB.MysticEnchant = AscensionUI.CDB.MysticEnchant or {}
        self.CDB = AscensionUI.CDB.MysticEnchant
    end
end)

M:SetScript("OnHide", CollectionsOnHide)
M:SetScript("OnShow", function(self)
    UpdateMysticRuneBalance()
    UpdatePaperDoll()
    BuildKnownList(true)
    RollButtonCheck(M.ControlFrame.RollButton)
    DisenchantButtonTokenCheck(M.ControlFrame.ExtractButton)
    M.Initializated = true
    EnableBreathing()
end)

-- hook tooltips to show RE quality
local hookedTooltips = {
    "ItemRefTooltip",
    "GameTooltip"
}

for _, v in pairs(hookedTooltips) do
    local tooltip = _G[v]
    local script = tooltip:GetScript("OnTooltipSetSpell")

    tooltip:SetScript("OnTooltipSetSpell", function(self)

        local spellName, _, spellID = self:GetSpell()

        if not Addon.REListSpellID[spellID] then
            return
        end

        local RE = GetREData(spellID)
        local colorStr = M.EnchantQualitySettings[RE.quality][1]

        local line1 = _G[self:GetName().."TextLeft1"]
        line1:SetText(format("%s%s|r", colorStr, spellName))
        InsertTooltipLine(self, 2, "Random Enchant", 1, 1, 1)

        -- call any other scripts
        if script then
            script(self)
        end
    end)
end