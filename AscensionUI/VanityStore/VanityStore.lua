local Addon = select(2, ...)
local Store = CreateFrame("FRAME", "StoreCollectionFrame", Addon.Collections, nil)
Addon.Store = Store

Store:Hide()

local ItemLootQuery = {}

function CheckKnownItem(itemID)
    if not(itemID) then
        return false
    end

    if not(GetItemInfo(itemID)) then
        table.insert(ItemLootQuery, itemID)
    end

    return IsCollectionItemOwned(itemID)
end

local LootQueryFrame = CreateFrame("FRAME")
LootQueryFrame.total = 20
LootQueryFrame.counter = 0

LootQueryFrame:SetScript("OnUpdate", function()
    if not(next(ItemLootQuery)) then
        LootQueryFrame.counter = LootQueryFrame.total -- to make next cache request instant
        return 
    end

    LootQueryFrame.counter = LootQueryFrame.counter + 1

    if LootQueryFrame.counter < LootQueryFrame.total then
        return
    end

    --print("Cache request of "..ItemLootQuery[1]) -- DEBUG

    TryCacheItem(ItemLootQuery[1])
    table.remove(ItemLootQuery, 1)
    LootQueryFrame.counter = 0
end)

LootQueryFrame:Show()

-------------------------------------------------------------------------------
--                               Config Values                               --
-------------------------------------------------------------------------------
Store.Items = {}
Store.ItemsCurrent = {}
Store.TotalItems = 0
Store.KnownItems = 0
Store.Preview_Items = {}
Store.Preview_Creatures = {}
Store.Preview_Current = {}


Store.PageCount = 0
Store.MaxItemsPerPage = 9
Store.CurrentPage = 1

Store.ItemsSorted = {}

Store.ItemSelected = 0

Store.ItemInternal = 0

Store.GroupIcons = {
    [3] = {"Interface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-mounts", "Mounts"},
    [4] = {"Interface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-pets", "Pets"},
    [5] = {"Interface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-toys", "Toys"},
    [7] = {"Interface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-armor", "Appearances"},
	[8] = {"Interface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-weapons", "Weapons"},
    [15] = {"Interface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-featured", "Ascension Exclusives"},
	[16] = {"Interface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-weapons.blp", "Illusions"},
	[17] = {"Interface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-druid.blp", "Incarnations"},
    [18] = {"Interface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-pets.blp", "Pet Cosmetics"},
}

Store.DefaultPreviewTexture = "Interface\\AddOns\\AwAddons\\Textures\\Collections\\PreviewItems\\Store_PreviewMain"
Store.DefaultArtworkTexture = "Interface\\AddOns\\AwAddons\\Textures\\Collections\\StorePaperArtwork"

Store.SPBalance = 0
Store.DPBalance = 0

Store.SP_Cost_Current = 0
Store.DP_Cost_Current = 0
-------------------------------------------------------------------------------
--                                UI Scripts                                 --
-------------------------------------------------------------------------------

local function UpdatePageInfo(pagenum)
    Store.CollectionList.PageText:SetText("Page "..pagenum.."/"..Store.PageCount)
end

local function StoreCollectionHideModelPreview()
    Store.ModelPreview_fake:Hide()
    Store.ModelPreview:Hide()
end

local function StoreCollectionHasOptionToPreview(itemID)
    -- FOR CREATURES
    if (Addon.VanityItems[itemID].creaturePreview > 0) then
        return true
    end
 
    local _, _, _, _, _, _, _, _, equipSlot = GetItemInfo(itemID)

    if not Addon.VanityItems[itemID].contentsPreview or Addon.VanityItems[itemID].contentsPreview == "" then

        if equipSlot and equipSlot ~= "" and equipSlot_Check ~= "INVTYPE_BAG" then
            Addon.VanityItems[itemID].contentsPreview = tostring(itemID)
        else
            return false
        end

        return true
    else
        Store.Preview_Items[itemID] = {}
        for substr in Addon.VanityItems[itemID].contentsPreview:gmatch("%S+") do 
            tinsert(Store.Preview_Items[itemID], tonumber(substr))
        end
        for i, item in pairs(Store.Preview_Items[itemID]) do
            local _, _, _, _, _, _, _, _, equipSlot_Check = GetItemInfo(item)
            if not(equipSlot_Check) or (equipSlot_Check == "") or (equipSlot_Check == "INVTYPE_BAG") then
                Store.Preview_Items[itemID][i] = nil
            end
        end

        if not(next(Store.Preview_Items[itemID])) then -- all of the containers go as preview items. Lets check which items we actually can preview first.
            return false
        end

        return true
    end

    return true
end

local function StoreCollectionGetPreviewData(itemID)
    local PreviewData = Store.Preview_Items[itemID]

    if not(PreviewData) then -- creatures will display only if there is no items preview.
        PreviewData = Addon.VanityItems[itemID].creaturePreview
    end

    return PreviewData or {}
end

local function BuildButtonData(index, entry, qualitycolor, name, texture, isknown, group, dp_cost, sp_cost)
  local ArtWork = Store.Items[entry].artwork
  local groupicon = Store.GroupIcons[group]

  SetPortraitToTexture(_G["StoreCollectionItemFrame"..index..".Icon"], texture)
  _G["StoreCollection"..index..".TextNormal"]:SetText(qualitycolor.."["..name.."]|r")

  _G["StoreCollectionItemFrame"..index..".Button.SeasonalPointsCost"] = sp_cost
  _G["StoreCollectionItemFrame"..index..".Button.DonatePointsCost"] = dp_cost
  _G["StoreCollectionItemFrame"..index..".Button.ItemInternal"] = entry
  _G["StoreCollectionItemFrame"..index..".Button.Icon"] = texture
  _G["StoreCollectionItemFrame"..index..".Button.ItemName"] = name
  _G["StoreCollectionItemFrame"..index..".Button.ItemDescription"] = Store.Items[entry].description

  if not(ArtWork) or (ArtWork == "") then
    ArtWork = Store.DefaultArtworkTexture
    _G["StoreCollectionItemFrame"..index..".Button.ArtWorkPreview"] = Store.DefaultPreviewTexture
  else
    _G["StoreCollectionItemFrame"..index..".Button.ArtWorkPreview"] = "Interface\\AddOns\\AwAddons\\Textures\\Collections\\PreviewItems\\"..ArtWork
    ArtWork = "Interface\\AddOns\\AwAddons\\Textures\\Collections\\"..ArtWork
  end

  _G["StoreCollectionItemFrame"..index..".Button.ArtWork"] = ArtWork

  if not(groupicon) then
    groupicon = "Interface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-featured"
  else
    groupicon = groupicon[1]
  end

  _G["StoreCollectionItemFrame"..index..".GroupIcon"]:SetTexture(groupicon)

  if not(isknown) then
    _G["StoreCollectionItemFrame"..index..".GroupIcon"]:SetVertexColor(0.4, 0.4, 0.4, 0.8)
    _G["StoreCollectionItemFrame"..index..".Button.Item"] = 0
    _G["StoreCollectionItemFrame"..index..".Icon"]:SetVertexColor(0.8, 0.8, 0.8, 0.8)
    _G["StoreCollectionItemFrame"..index..".PrestigeTexture"]:SetVertexColor(1, 1, 1, 0.2)
    _G["StoreCollectionItemFrame"..index..".RoundBG"]:SetVertexColor(1, 1, 1, 0.2)
    _G["StoreCollectionItemFrame"..index..".Circle"]:SetVertexColor(0.5, 0.5, 0.5, 1)
    _G["StoreCollection"..index..".TextNormal"]:SetVertexColor(1, 1, 1, 0.5)
  else
    _G["StoreCollectionItemFrame"..index..".GroupIcon"]:SetVertexColor(1, 1, 1, 1)
    _G["StoreCollectionItemFrame"..index..".Button.Item"] = entry
    _G["StoreCollectionItemFrame"..index..".Icon"]:SetVertexColor(1, 1, 1, 1)
    _G["StoreCollectionItemFrame"..index..".PrestigeTexture"]:SetVertexColor(1, 1, 1, 1)
    _G["StoreCollectionItemFrame"..index..".RoundBG"]:SetVertexColor(1, 1, 1, 1)
    _G["StoreCollectionItemFrame"..index..".Circle"]:SetVertexColor(1, 1, 1, 1)
    _G["StoreCollection"..index..".TextNormal"]:SetVertexColor(1, 1, 1, 1)
  end

  if (sp_cost > 0) then
    _G["StoreCollectionItemFrame"..index..".BackgroundTexture"]:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\StoreButtonBG_Seasonal")
  else
    _G["StoreCollectionItemFrame"..index..".BackgroundTexture"]:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\StoreButtonBG")
  end

  if (StoreCollectionHasOptionToPreview(entry)) then
    _G["StoreCollectionItemFrame"..index..".Button.PreviewData"] = StoreCollectionGetPreviewData(entry)
    else
    _G["StoreCollectionItemFrame"..index..".Button.PreviewData"] = {}
  end

end

local function UpdateListButtons(pagenumber)
    for i = 1, Store.MaxItemsPerPage do 
        _G["StoreCollectionItemFrame"..i]:Hide()
    end

    local listtodisplay = {}

    local StartListValues = pagenumber*Store.MaxItemsPerPage-(Store.MaxItemsPerPage-1)
    local EndListValues = pagenumber*Store.MaxItemsPerPage

    if (#Store.ItemsCurrent < EndListValues) then
        EndListValues = #Store.ItemsCurrent
    end

    for i = StartListValues, EndListValues do
        table.insert(listtodisplay, Store.ItemsCurrent[i])
    end

    local button_progress = 1

    --structure: {entry, name, quality, bannertext, group, description, icon, artwork, known}
    while (button_progress <= #listtodisplay) do
        local itemID = listtodisplay[button_progress].id
        local ItemKnown = listtodisplay[button_progress].known
        local ItemGroup = listtodisplay[button_progress].group
        local ItemDPCost = listtodisplay[button_progress].dpCost
        local ItemSPCost = listtodisplay[button_progress].spCost

        local _,_,_,QualityColor = GetItemQualityColor(listtodisplay[button_progress].quality)
        local ItemName, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)

        if not(ItemName) then
          ItemName = listtodisplay[button_progress].name
        end

        texture = "Interface\\Icons\\"..listtodisplay[button_progress].icon

        BuildButtonData(button_progress, itemID, QualityColor, ItemName, texture, ItemKnown, ItemGroup, ItemDPCost, ItemSPCost)
        _G["StoreCollectionItemFrame"..button_progress]:Show()

        button_progress = button_progress + 1
    end

end

local function UpdateListInfo(list, pagenumber)
    Store.ItemsCurrent = {}

    if not(pagenumber) then
        pagenumber = 1
    end

    for _, v in pairs(list) do
        table.insert(Store.ItemsCurrent, v)
    end

    Store.PageCount = math.ceil(#Store.ItemsCurrent/Store.MaxItemsPerPage)

    if (Store.PageCount < 1) then
        Store.PageCount = 1
    end

    Store.CurrentPage = pagenumber
    UpdatePageInfo(Store.CurrentPage)

    if (Store.PageCount <= 1) then
        Store.CollectionList.NextButton:Disable()
    else
        Store.CollectionList.NextButton:Enable()
    end

    if (pagenumber == 1) then
        Store.CollectionList.PrevButton:Disable()
    end

    UpdateListButtons(pagenumber)
end


local function StoreCollectionListNextPage(self)
    PlaySound("igMainMenuContinue")
    Store.CurrentPage = Store.CurrentPage+1

    if (Store.CurrentPage == Store.PageCount) then
        self:Disable()
    end

    if (Store.CollectionList.PrevButton:IsEnabled() == 0) then
        Store.CollectionList.PrevButton:Enable()
    end

    UpdatePageInfo(Store.CurrentPage)
    UpdateListButtons(Store.CurrentPage)
end

local function StoreCollectionListPrevPage(self)
    PlaySound("igMainMenuContinue")
    Store.CurrentPage = Store.CurrentPage-1

    if (Store.CurrentPage == 1) then
        self:Disable()
    end

    if (Store.CollectionList.NextButton:IsEnabled() == 0) then
        Store.CollectionList.NextButton:Enable()
    end

    UpdatePageInfo(Store.CurrentPage)
    UpdateListButtons(Store.CurrentPage)
end

local function BuildKnownItemsList()
    local list = {}

    for itemID, iteminfo in pairs(Store.Items) do
        if (iteminfo.known) then
            table.insert(list, iteminfo)
        end
    end
    
    UpdateListInfo(list)
end

local function BuildSeasonalRewardsList()
    local list = {}

    for itemID, iteminfo in pairs(Store.Items) do
        if (iteminfo.spCost > 0) then
            table.insert(list, iteminfo)
        end
    end
    
    UpdateListInfo(list)
end

function G_BuildSeasonalRewardsList()
    BuildSeasonalRewardsList()
end

local function BuildSortedList(group)
    local list = {}

    for itemID, iteminfo in pairs(Store.Items) do
        if (iteminfo.group == group) then
            table.insert(list, iteminfo)
        end
    end
    
    UpdateListInfo(list)
end

local function SearchForItem(self)
    local list = {}
    local text = self:GetText()

    if not(text) or (text == "") or (text:lower() == "search") then
        self:ClearFocus(self)
        self:SetText("Recherche")
        return false
    end

    text = text:lower()

    for _, item in pairs(Store.Items) do
        local ItemName = item.name:lower()
        if (string.find(ItemName, text)) then
            table.insert(list, item)
        end
    end

    UpdateListInfo(list)
    self:ClearFocus(self)
    StoreCollectionHideModelPreview()
end

local function StoreCollectionFrameModelPreviewFixModelPosition(self)
    local uiScale = 1
    if (GetCVar("useUiScale") == "1") then
      uiScale = GetCVar("uiScale")
    else
      SetCVar("uiScale","1")
      uiScale = 1
    end -- resolution and uiscale fix
    self:SetPosition(0, 0, 1.65/uiScale)
end

local function StoreCollectionFrameModelPreviewInitModel(self)
    if tonumber(Store.Preview_Current) then
        self.Creature = Store.Preview_Current
    elseif next(Store.Preview_Current) then
        self.Creature = nil
    end

    if (self.Creature) then
        self:SetCreature(self.Creature)
        self:SetCamera(0)
    else
        self:SetCamera(0)
        self:SetUnit("player")
        self:RefreshUnit()
    end

    self:SetFacing(Store.ModelPreview.DefaultFacing)
    self:SetModelScale(Store.ModelPreview.DefaultSize)
    StoreCollectionFrameModelPreviewFixModelPosition(self)
end

local function StoreCollectionFrameModelPreviewLoadItems()
    if not Store.ModelPreview.Creature and Store.Preview_Current and #Store.Preview_Current > 0 then
        for _, item in pairs(Store.Preview_Current) do
            Store.ModelPreview:TryOn(item) 
        end
        Store.ModelPreview_fake.SpendPoints:Show()
    else
        Store.ModelPreview_fake.SpendPoints:Hide()
    end
end

local function StoreCollectionPreviewButtonCheck()
    if tonumber(Store.Preview_Current) or (next(Store.Preview_Current)) then -- table is for items, value is for creatures
        --DISPLAY PREVIEW--
        Store.Paper.ItemPreview:Show()
        Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup:Stop()
        Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup:Play()
    else
        Store.Paper.ItemPreview:Hide()
    end
end

local function StoreCollectionFrameShowPaper()
    BaseFrameFadeIn(Store.Paper)
    BaseFrameFadeIn(Store.Paper_fake)
    Store.Paper.Icon:Show()
    Store.Paper.GoldBG:Show()
    Store.Paper.Texture:Show()
    Store.Paper.LineUp:Show()
    Store.Paper.LineDown:Show()
    Store.Paper.DescText:Show()
    Store.Paper.BorderTex:Show()
    Store.Paper.LineDown.AnimationGroup:Stop()
    Store.Paper.LineDown.AnimationGroup:Play()
    StoreCollectionPreviewButtonCheck()
end

local function StoreCollectionFrameHidePaper()
    BaseFrameFadeOut(Store.Paper)
    BaseFrameFadeOut(Store.Paper_fake)
    Store.Paper.Icon:Hide()
    Store.Paper.GoldBG:Hide()
    Store.Paper.Texture:Hide()
    Store.Paper.LineUp:Hide()
    Store.Paper.LineDown:Hide()
    Store.Paper.DescText:Hide()
    Store.Paper.BorderTex:Hide()
    Store.Paper.LineDown.AnimationGroup:Stop()
end

local function StoreCollectionShowModelPreview()
    StoreCollectionFrameModelPreviewInitModel(Store.ModelPreview)
    Store.ModelPreview_fake:Show()
end

local function LoadBannerRandomItem()
    local ItemInfo = Store.ItemsSorted[math.random(1, #Store.ItemsSorted)]
    local ItemName, _, _, _, _, _, _, _, _, texture = GetItemInfo(ItemInfo.id)
    if not(ItemName) then
      ItemName = ItemInfo.name
    end
    texture = "Interface\\Icons\\"..ItemInfo.icon
    local ItemAddText = ItemInfo.description

    Store.Banner.Item = ItemInfo.id
    Store.Banner.Icon:SetTexture(texture)
    Store.Banner.TitleText:SetText(strupper(ItemName))
    Store.Banner.TitleText_UNEDITED = ItemName
    Store.Banner.DescText:SetText(strupper(ItemAddText))
end

local function LoadItemFromBanner()
    if not(Store.Banner.Item) then
        return false
    end

    local ArtWork = Store.Items[Store.Banner.Item].artwork

    if not(ArtWork) or (ArtWork == "") then
	    ArtWork = Store.DefaultArtworkTexture
	    Store.ModelPreview.BGTex:SetTexture(Store.DefaultPreviewTexture)
	else
		if not(Store.ModelPreview.BGTex:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\PreviewItems\\"..ArtWork)) then
	      Store.ModelPreview.BGTex:SetTexture(Store.DefaultPreviewTexture)
	    end
	    ArtWork = "Interface\\AddOns\\AwAddons\\Textures\\Collections\\"..ArtWork
	end

    Store.Paper.Icon:SetNormalTexture(Store.Banner.Icon:GetTexture())
    Store.Paper.ArtWork:SetTexture(ArtWork)
    Store.Paper.TitleText:SetText(Store.Banner.TitleText_UNEDITED)
    Store.Paper.DescText:SetText(Store.Items[Store.Banner.Item].description)
    Store.ItemInternal = Store.Banner.Item

    if (Store.Items[Store.Banner.Item].dpCost ~= 0) or (Store.Items[Store.Banner.Item].spCost ~= 0) then -- show buy option and cost
        Store.SP_Cost_Current = Store.Items[Store.Banner.Item].spCost
        Store.DP_Cost_Current = Store.Items[Store.Banner.Item].dpCost
        --Store.BuyStoreButton:Enable()
    else
        Store.BuyStoreButton:Disable()
    end

    if (Store.Items[Store.Banner.Item].known) then
        Store.ItemSelected = Store.Banner.Item
        Store.ActivateStoreButton:Enable()
        --Store.ModelPreview_fake.SpendPoints.MainButton:Enable()
        Store.BuyStoreButton:Disable()
    else
        Store.ItemSelected = 0
        Store.ActivateStoreButton:Disable()
        Store.ModelPreview_fake.SpendPoints.MainButton:Disable()
    end

    if (StoreCollectionHasOptionToPreview(Store.Banner.Item)) then
        Store.Preview_Current = StoreCollectionGetPreviewData(Store.Banner.Item)
    else
        Store.Preview_Current = {}
    end
    StoreCollectionHideModelPreview()

    StoreCollectionFrameShowPaper()
end

local function ActivateItem(self)
    PlaySound("igMainMenuOptionCheckBoxOn")
    if (Store.ItemSelected ~= 0) and (self:IsEnabled() == 1 ) then
        RequestDeliverVanityCollectionItem(Store.ItemSelected)
    end
end

local function BuyItem(self)
    PlaySound("igMainMenuOptionCheckBoxOn")
    if (Store.ItemSelected ~= 0) and (self:IsEnabled() == 1 ) then
    end
end
-------------------------------------------------------------------------------
--                            Core Functions                                 --
-------------------------------------------------------------------------------
local function UpdateBalance(DP_Count, SP_Count)
    Store.SPBalance = SP_Count
    Store.DPBalance = DP_Count

    Store.SPCounter_Text:SetText(SP_Count)
    Store.DPCounter_Text:SetText(DP_Count)
end

local function BuildItemList(ItemList)

    for itemID, iteminfo in pairs(ItemList) do
        iteminfo.id = itemID
        Store.Items[itemID] = iteminfo
        Store.Items[itemID].known = CheckKnownItem(itemID)

        tinsert(Store.ItemsSorted, iteminfo)
        Store.TotalItems = Store.TotalItems + 1 
    end

    UpdateListInfo(Store.Items)
end


function UnlockNewItem(itemdata)
    PlaySound("LEVELUP")
    Store.Items[itemdata.id].known = true
    UIDropDownMenu_SetSelectedID(Store.StoreTypeList, 13)
    BuildKnownItemsList()
    if not(StoreNewItemInCollection:IsVisible()) then
        local ItemName, itemLink, _, _, _, _, _, _, _, texture = GetItemInfo(itemdata.name)
        if not ItemName  then
          ItemName = itemdata.name
          itemLink = "["..itemdata.name.."]"
        end
        texture = "Interface\\Icons\\"..itemdata.icon

        SetPortraitToTexture(StoreNewItemInCollection.Main.Icon, texture)
        StoreNewItemInCollection.Main.TextNormal:SetText(strupper(ItemName))
        StoreNewItemInCollection.Main.TextAdd:SetText("|cffFFFFFFNouveau |rObjets Cosmétique|cffFFFFFF débloqués - "..itemLink.."|cffFFFFFF!|r")
        StoreNewItemInCollection.Main.AnimationGroup:Stop()
        StoreNewItemInCollection:Show() 
        StoreNewItemInCollection.Main.AnimationGroup:Play()
    end
end

local function Store_Init()
    if (Store.TotalItems == 0) then
        BuildItemList(Addon.VanityItems)
    end
end

-------------------------------------------------------------------------------
--                           UI Frames and buttons                           --
-------------------------------------------------------------------------------
Store:SetSize(784,512)
Store:SetPoint("CENTER", 0, 0)
Store:SetBackdrop({
            bgFile = "Interface\\AddOns\\AwAddons\\Textures\\Collections\\StoreCollection",
             insets = {
            left = -120,
            right = -120,
            top = -256,
            bottom = -256}
                })
Store:SetClampedToScreen(true)
Store:SetScript("OnShow", Store_Init)

Store:SetScript("OnUpdate", function()
    if not(Store.ModelPreview:IsVisible()) and Store.ModelPreview_fake:IsVisible() then
        Store.ModelPreview.HackFix = Store.ModelPreview.HackFix + 1 
        if (Store.ModelPreview.HackFix >= 5) then
            Store.ModelPreview:Show()
            Store.ModelPreview.HackFix = 0
        end
    end

    if not(Store.Banner:IsVisible()) then
      if (#Store.ItemsSorted <= 0) then
        return
      end
      LoadBannerRandomItem()
      Store.Banner.AnimationGroup:Stop()
      BaseFrameFadeIn(Store.Banner)
      Store.Banner.AnimationGroup:Play()
    end
end)

Store.CloseButton = CreateFrame("Button", nil, Store, "UIPanelCloseButton")
Store.CloseButton:SetPoint("TOPRIGHT", -4, -1) 
Store.CloseButton:EnableMouse(true)
Store.CloseButton:SetScript("OnMouseUp", function()
    PlaySound("igMainMenuClose")
    HideUIPanel(CollectionController)
    end)

Store.TitleText = Store:CreateFontString("StoreCollectionFrameTitleText")
Store.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
Store.TitleText:SetFontObject(GameFontNormal)
Store.TitleText:SetPoint("TOP", 0, -11)
Store.TitleText:SetShadowOffset(1,-1)
Store.TitleText:SetText("Collection des Objets cosmétique")

Store.SearchBox = CreateFrame("EditBox","StoreCollectionFrameSearchBox",Store, "InputBoxTemplate")
Store.SearchBox:SetWidth(150)
Store.SearchBox:SetHeight(26)
Store.SearchBox:SetFontObject(GameFontNormal)
Store.SearchBox:SetPoint("TOPRIGHT", Store, -187, -33)
Store.SearchBox:ClearFocus(self)
Store.SearchBox:SetAutoFocus(false)
Store.SearchBox:SetFontObject(GameFontDisable)
Store.SearchBox:SetScript("OnEnterPressed", SearchForItem)
Store.SearchBox:SetScript("OnEscapePressed", ClearSearchEscape)
Store.SearchBox:SetText("Search")

Store.SPCounter_BackgroundTexture = Store:CreateTexture(nil, "ARTWORK")
Store.SPCounter_BackgroundTexture:SetSize(110,55)
Store.SPCounter_BackgroundTexture:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\DP_Counter")
Store.SPCounter_BackgroundTexture:SetPoint("CENTER", -5, 206)

Store.DPCounter_BackgroundTexture = Store:CreateTexture(nil, "ARTWORK")
Store.DPCounter_BackgroundTexture:SetSize(110,55)
Store.DPCounter_BackgroundTexture:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\SP_Counter")
Store.DPCounter_BackgroundTexture:SetPoint("CENTER", -17, 206)
Store.DPCounter_BackgroundTexture:Hide()

Store.SPCounter_Icon = Store:CreateTexture(nil, "OVERLAY")
Store.SPCounter_Icon:SetSize(21,21)
Store.SPCounter_Icon:SetTexture("Interface\\icons\\inv_archaeology_70_demon_orbofinnerchaos")
Store.SPCounter_Icon:SetPoint("CENTER", -37.5, 210)
SetPortraitToTexture(Store.SPCounter_Icon, "Interface\\icons\\inv_archaeology_70_demon_orbofinnerchaos")

Store.DPCounter_Icon = Store:CreateTexture(nil, "OVERLAY")
Store.DPCounter_Icon:SetSize(21,21)
Store.DPCounter_Icon:SetTexture("Interface\\icons\\spell_frostfire_orb")
Store.DPCounter_Icon:SetPoint("CENTER", -49.5, 210)
SetPortraitToTexture(Store.DPCounter_Icon, "Interface\\icons\\spell_frostfire_orb")
Store.DPCounter_Icon:Hide()

Store.SPCounter_Text = Store:CreateFontString("StoreCollectionFrameSPCounter_Text")
Store.SPCounter_Text:SetFont("Fonts\\FRIZQT__.TTF", 11)
Store.SPCounter_Text:SetFontObject(GameFontNormal)
Store.SPCounter_Text:SetPoint("CENTER", 0, 204.5)
Store.SPCounter_Text:SetShadowOffset(1,-1)
Store.SPCounter_Text:SetText("0")
Store.SPCounter_Text:SetJustifyH("CENTER")

Store.DPCounter_Text = Store:CreateFontString("StoreCollectionFrameDPCounter_Text")
Store.DPCounter_Text:SetFont("Fonts\\FRIZQT__.TTF", 11)
Store.DPCounter_Text:SetFontObject(GameFontNormal)
Store.DPCounter_Text:SetPoint("CENTER", -12, 204.5)
Store.DPCounter_Text:SetShadowOffset(1,-1)
Store.DPCounter_Text:SetText("0")
Store.DPCounter_Text:SetJustifyH("CENTER")
Store.DPCounter_Text:Hide()

Store.SPCounterHintButton = CreateFrame("Button", nil, Store, nil)
Store.SPCounterHintButton:SetWidth(38) 
Store.SPCounterHintButton:SetHeight(38) 
Store.SPCounterHintButton:SetPoint("CENTER", -37.5, 210)
Store.SPCounterHintButton:RegisterForClicks("AnyUp") 
Store.SPCounterHintButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
Store.SPCounterHintButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("|cffFFFFFFPoints saisonniers|r")
    GameTooltip:AddLine("Points que vous avez gagnés au cours")
    GameTooltip:AddLine("des saisons précédentes")
    GameTooltip:Show()
    end)

Store.SPCounterHintButton:SetScript("OnLeave", function (self)
    GameTooltip:Hide()
    end)

Store.StoreTypeList = CreateFrame("Button", "VanityStoreList", Store, "UIDropDownMenuTemplate")
Store.StoreTypeList:SetPoint("TOPRIGHT", Store, -10, -32)

Store.StoreTypeList.List = {
--[[
3 - mounts
5 - toys
4 - pets
2 - progression items
7 - appereances
15 - exclusives
16 - illusions
17 - incarnations
16 - weapon illusions
17 - shapeshift incarnation
]]--
    "Tout", -- 1 
    "|TInterface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-mounts.blp:32:32:0:0|t Montures", -- 2
    "|TInterface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-pets.blp:32:32:0:0|t Familiers", -- 3
    "|TInterface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-toys.blp:32:32:0:0|t Jouets", -- 4
    "|TInterface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-armor.blp:32:32:0:0|t Apparences", -- 5
	"|TInterface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-weapon.blp:32:32:0:0|t Armes", -- 6
    "|TInterface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-featured.blp:32:32:0:0|t Exclusivités d'Ascension", -- 7
    "|TInterface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-sale.blp:32:32:0:0|t Récompenses saisonnières", -- 8
    "|TInterface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-services.blp:32:32:0:0|t Professions", -- 9
	"|TInterface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-illusions.blp:32:32:0:0|t Illusions", -- 10
	"|TInterface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-druid.blp:32:32:0:0|t Formes", -- 11
    "|TInterface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-pets.blp:32:32:0:0|t Familiers Cosmétique", -- 12
    "Connu", -- 13
}

DisabledTabs = {
    [9] = true,
}

function Store.StoreTypeList.Init(self, level)
   local info = UIDropDownMenu_CreateInfo()
   for id, v in pairs(Store.StoreTypeList.List) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v
      info.value = v

      if DisabledTabs[id] then
         info.disabled = true
      end

      info.func = function(self)
        UIDropDownMenu_SetSelectedID(Store.StoreTypeList, self:GetID())
        if (self:GetID() == 1) then -- all
            UpdateListInfo(Store.Items)
        elseif (self:GetID() == 2) then -- mounts
            BuildSortedList(3)
        elseif (self:GetID() == 3) then -- pets
            BuildSortedList(4)
        elseif (self:GetID() == 4) then -- toys
            BuildSortedList(5)
        elseif (self:GetID() == 5) then -- apperances 
            BuildSortedList(7)
        elseif (self:GetID() == 6) then -- weapons
            BuildSortedList(8)
        elseif (self:GetID() == 7) then -- exclusives
            BuildSortedList(15)
        elseif (self:GetID() == 8) then -- seasonal
            BuildSeasonalRewardsList()
        elseif (self:GetID() == 9) then -- professions
            --BuildSortedList(16)
        elseif (self:GetID() == 10) then -- illusions
		    BuildSortedList(16)
        elseif (self:GetID() == 11) then -- Incarnations
            BuildSortedList(17)
        elseif (self:GetID() == 12) then -- Incarnations
            BuildSortedList(18)
        elseif (self:GetID() == 13) then
            BuildKnownItemsList()
        end

        StoreCollectionHideModelPreview()

      end
      UIDropDownMenu_AddButton(info, level)
   end
end

UIDropDownMenu_Initialize(Store.StoreTypeList, Store.StoreTypeList.Init)
UIDropDownMenu_SetWidth(Store.StoreTypeList, 140)
UIDropDownMenu_SetButtonWidth(Store.StoreTypeList, 70)
UIDropDownMenu_SetSelectedID(Store.StoreTypeList, 1)
UIDropDownMenu_JustifyText(Store.StoreTypeList, "LEFT")

Store.ActivateStoreButton = CreateFrame("Button", nil, Store, "UIPanelButtonTemplate")
Store.ActivateStoreButton:SetWidth(118) 
Store.ActivateStoreButton:SetHeight(21) 
Store.ActivateStoreButton:SetPoint("BOTTOMLEFT", 180,37) 
Store.ActivateStoreButton:RegisterForClicks("AnyUp") 
Store.ActivateStoreButton:SetText("Récupérer l'article")
Store.ActivateStoreButton:Disable()
Store.ActivateStoreButton:SetScript("OnMouseDown", ActivateItem)

Store.BuyStoreButton = CreateFrame("Button", nil, Store, "UIPanelButtonTemplate")
Store.BuyStoreButton:SetWidth(118) 
Store.BuyStoreButton:SetHeight(21) 
Store.BuyStoreButton:SetPoint("BOTTOMLEFT", 62,37) 
Store.BuyStoreButton:RegisterForClicks("AnyUp") 
Store.BuyStoreButton:SetText("Acheter un article")
Store.BuyStoreButton:Disable()
Store.BuyStoreButton:SetScript("OnClick", function(self)
        Store.ConfirmBuy:Show()
    end)

-------------------------------------------------------------------------------
--                              Left side frame                              --
-------------------------------------------------------------------------------
Store.Banner = CreateFrame("FRAME", nil, Store, nil)
Store.Banner:SetPoint("TOP", -235, -65)
Store.Banner:SetSize(280,55)
Store.Banner:Hide()
Store.Banner:EnableMouse(true)

Store.Banner:SetScript("OnUpdate", function()
    if not(Store.Banner.HighlightTex.AnimG:IsPlaying()) then 
        Store.Banner.HighlightTex.AnimG:Play()
    end
end)

Store.Banner:SetScript("OnMouseDown", LoadItemFromBanner)

Store.Banner.HighlightTex = Store.Banner:CreateTexture(nil, "BACKGROUND")
Store.Banner.HighlightTex:SetSize(140,140)
Store.Banner.HighlightTex:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\DragonHighlight")
Store.Banner.HighlightTex:SetPoint("LEFT", -39, 0)
Store.Banner.HighlightTex:SetBlendMode("ADD")

Store.Banner.HighlightTex.AnimG = Store.Banner.HighlightTex:CreateAnimationGroup()
Store.Banner.HighlightTex.AnimG.Rotation = Store.Banner.HighlightTex.AnimG:CreateAnimation("Rotation")
Store.Banner.HighlightTex.AnimG.Rotation:SetDuration(20)
Store.Banner.HighlightTex.AnimG.Rotation:SetOrder(1)
Store.Banner.HighlightTex.AnimG.Rotation:SetEndDelay(0)
Store.Banner.HighlightTex.AnimG.Rotation:SetSmoothing("NONE")
Store.Banner.HighlightTex.AnimG.Rotation:SetDegrees(360)

Store.Banner.Glow = CreateFrame("Model", nil, Store.Banner)
Store.Banner.Glow:SetWidth(256);               
Store.Banner.Glow:SetHeight(256);
Store.Banner.Glow:SetPoint("LEFT", -90, -5)
Store.Banner.Glow:SetModel("World\\Kalimdor\\silithus\\passivedoodads\\ahnqirajglow\\quirajglow.m2")
Store.Banner.Glow:SetModelScale(0.01)
Store.Banner.Glow:SetCamera(0)
Store.Banner.Glow:SetPosition(0.075,0.09,0)
Store.Banner.Glow:SetFacing(0)
Store.Banner.Glow:SetFrameLevel(2)

Store.Banner.Icon = Store.Banner:CreateTexture(nil, "ARTWORK")
Store.Banner.Icon:SetSize(40,40)
Store.Banner.Icon:SetTexture("Interface\\icons\\FoxMountIcon")
Store.Banner.Icon:SetPoint("LEFT", 10, 0)

Store.Banner.TitleText = Store.Banner:CreateFontString("StoreCollectionListFrameTitleText")
Store.Banner.TitleText:SetFont("Fonts\\FRIZQT__.ttf", 22)
Store.Banner.TitleText:SetFontObject(GameFontHighlight)
Store.Banner.TitleText:SetPoint("TOP", Store.Banner, "TOPLEFT", 164.5, -9)
Store.Banner.TitleText:SetShadowOffset(0,-1)
Store.Banner.TitleText:SetSize(220, 23)
Store.Banner.TitleText:SetText("MISTY FOX")
Store.Banner.TitleText:SetJustifyH("LEFT")

Store.Banner.DescText = Store.Banner:CreateFontString("StoreCollectionListFrameTitleText")
Store.Banner.DescText:SetFont("Fonts\\FRIZQT__.ttf", 12)
Store.Banner.DescText:SetFontObject(GameFontNormal)
Store.Banner.DescText:SetPoint("TOP", Store.Banner, "TOPLEFT", 168.5, -31)
Store.Banner.DescText:SetShadowOffset(1,-1)
Store.Banner.DescText:SetSize(225, 13)
Store.Banner.DescText:SetText("YOU WON'T EVER GET LOST")
Store.Banner.DescText:SetJustifyH("LEFT")

Store.Banner.AnimationGroup = Store.Banner:CreateAnimationGroup()
Store.Banner.AnimationGroup.Rotation = Store.Banner.AnimationGroup:CreateAnimation("Translation")
Store.Banner.AnimationGroup.Rotation:SetStartDelay(0.15)
Store.Banner.AnimationGroup.Rotation:SetDuration(0)
Store.Banner.AnimationGroup.Rotation:SetOrder(1)
Store.Banner.AnimationGroup.Rotation:SetEndDelay(0)
Store.Banner.AnimationGroup.Rotation:SetSmoothing("OUT")
Store.Banner.AnimationGroup.Rotation:SetOffset(0, 30)

Store.Banner.AnimationGroup.Rotation2 = Store.Banner.AnimationGroup:CreateAnimation("Translation")
Store.Banner.AnimationGroup.Rotation2:SetDuration(1.2)
Store.Banner.AnimationGroup.Rotation2:SetOrder(2)
Store.Banner.AnimationGroup.Rotation2:SetEndDelay(15)
Store.Banner.AnimationGroup.Rotation2:SetSmoothing("OUT")
Store.Banner.AnimationGroup.Rotation2:SetOffset(0, -30)

Store.Banner.AnimationGroup.Rotation3 = Store.Banner.AnimationGroup:CreateAnimation("Translation")
Store.Banner.AnimationGroup.Rotation3:SetDuration(1.2)
Store.Banner.AnimationGroup.Rotation3:SetOrder(3)
Store.Banner.AnimationGroup.Rotation3:SetEndDelay(0)
Store.Banner.AnimationGroup.Rotation3:SetSmoothing("OUT")
Store.Banner.AnimationGroup.Rotation3:SetOffset(0, -30)

Store.Banner.AnimationGroup.Rotation3:SetScript("OnPlay", function()
  BaseFrameFadeOut(Store.Banner)
  end)

Store.Paper = CreateFrame("FRAME", nil, Store, nil)
Store.Paper:SetPoint("CENTER", -235, -41)
Store.Paper:SetSize(280,305)
Store.Paper:SetFrameLevel(4)

Store.Paper_fake = CreateFrame("FRAME", nil, Store, nil)
Store.Paper_fake:SetPoint("CENTER", -235, -41)
Store.Paper_fake:SetSize(280,305)
Store.Paper_fake:SetFrameLevel(2)

Store.Paper.Icon = CreateFrame("Button", nil, Store.Paper_fake, nil)
Store.Paper.Icon:SetSize(40,40)
Store.Paper.Icon:SetPoint("BOTTOMLEFT", 14, 28)
Store.Paper.Icon:EnableMouse(true)
Store.Paper.Icon:SetNormalTexture("Interface\\icons\\FoxMountIcon")
Store.Paper.Icon:SetHighlightTexture("Interface\\BUTTONS\\ButtonHilight-Square")
Store.Paper.Icon:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink("item:"..Store.ItemInternal..":0:0:0:0:0:0:0")
    GameTooltip:Show()
    end)
Store.Paper.Icon:SetScript("OnLeave", function (self)
    GameTooltip:Hide()
    end)
Store.Paper.Icon:Hide()

Store.Paper.ItemPreview = CreateFrame("Button", nil, Store.Paper, nil)
Store.Paper.ItemPreview:SetSize(46,46)
Store.Paper.ItemPreview:SetPoint("BOTTOMLEFT", 28, 10)
Store.Paper.ItemPreview:EnableMouse(true)
Store.Paper.ItemPreview:SetNormalTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\PreviewButton")
Store.Paper.ItemPreview:SetHighlightTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\PreviewButton_H")
Store.Paper.ItemPreview:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("|cffFFFFFFPreview Items|r")
    GameTooltip:AddLine("Click here to preview items")
    GameTooltip:Show()
end)

Store.Paper.ItemPreview:SetScript("OnLeave", function (self)
    GameTooltip:Hide()
end)

Store.Paper.ItemPreview:SetScript("OnClick", function(self)
    if not(Store.ModelPreview_fake:IsVisible()) then
        StoreCollectionShowModelPreview()
    else
        StoreCollectionHideModelPreview()
    end
end)

Store.Paper.ItemPreview:Hide()

Store.Paper.ItemPreview.HighLightAnimTex = Store.Paper:CreateTexture(nil, "OVERLAY") 
Store.Paper.ItemPreview.HighLightAnimTex:SetSize(46,46)
Store.Paper.ItemPreview.HighLightAnimTex:SetPoint("BOTTOMLEFT", 28, 10)
Store.Paper.ItemPreview.HighLightAnimTex:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\PreviewButton_H")
Store.Paper.ItemPreview.HighLightAnimTex:SetAlpha(0)
Store.Paper.ItemPreview.HighLightAnimTex:SetBlendMode("ADD")

Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup = Store.Paper.ItemPreview.HighLightAnimTex:CreateAnimationGroup()

Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup.Alpha1 = Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup:CreateAnimation("Alpha")
Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup.Alpha1:SetDuration(0.3)
Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup.Alpha1:SetStartDelay(0)
Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup.Alpha1:SetOrder(1)
Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup.Alpha1:SetChange(1)

Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup.Alpha2 = Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup:CreateAnimation("Alpha")
Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup.Alpha2:SetDuration(0.7)
Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup.Alpha2:SetStartDelay(0)
Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup.Alpha2:SetOrder(2)
Store.Paper.ItemPreview.HighLightAnimTex.AnimationGroup.Alpha2:SetChange(-1)

Store.Paper.BorderTex = Store.Paper:CreateTexture(nil, "OVERLAY") 
Store.Paper.BorderTex:SetSize(128,64)
Store.Paper.BorderTex:SetPoint("BOTTOMLEFT", -30, 12)
Store.Paper.BorderTex:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\progress\\LearnedSpell_TextureNormal") 
Store.Paper.BorderTex:Hide()

Store.Paper.ArtWork = Store.Paper:CreateTexture(nil, "BACKGROUND")
Store.Paper.ArtWork:SetSize(256,256)
Store.Paper.ArtWork:SetTexture(Store.DefaultArtworkTexture)
Store.Paper.ArtWork:SetPoint("CENTER", 0, 25)

Store.Paper.GoldBG = Store.Paper:CreateTexture(nil, "BACKGROUND")
Store.Paper.GoldBG:SetTexture("Interface\\LevelUp\\LevelUpTex")
Store.Paper.GoldBG:SetSize(223, 115)
Store.Paper.GoldBG:SetPoint("BOTTOM", 0, 16)
Store.Paper.GoldBG:SetTexCoord(0.56054688, 0.99609375, 0.24218750, 0.46679688)
Store.Paper.GoldBG:SetVertexColor(1, 1, 1, 0)

Store.Paper.Texture = Store.Paper:CreateTexture(nil, "BACKGROUND", nil, 2)
Store.Paper.Texture:SetTexture("Interface\\LevelUp\\LevelUpTex")
Store.Paper.Texture:SetSize(284, 115)
Store.Paper.Texture:SetPoint("BOTTOM", 0, 14)
Store.Paper.Texture:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
Store.Paper.Texture:SetVertexColor(1, 1, 1, 0.6)

Store.Paper.LineUp = Store.Paper:CreateTexture(nil, "BORDER", nil, 2)
Store.Paper.LineUp:SetTexture("Interface\\LevelUp\\LevelUpTex")
Store.Paper.LineUp:SetSize(264, 7)
Store.Paper.LineUp:SetPoint("BOTTOM", 0, 75)
Store.Paper.LineUp:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
Store.Paper.LineUp:SetVertexColor(1, 1, 1)

Store.Paper.LineDown = Store.Paper:CreateTexture(nil, "BORDER", nil, 2)
Store.Paper.LineDown:SetTexture("Interface\\LevelUp\\LevelUpTex")
Store.Paper.LineDown:SetSize(264, 7)
Store.Paper.LineDown:SetPoint("BOTTOM", 0, 14)
Store.Paper.LineDown:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
Store.Paper.LineDown:SetVertexColor(1, 1, 1)

Store.Paper.TitleText = Store.Paper:CreateFontString()
Store.Paper.TitleText:SetFont("Fonts\\MORPHEUS.TTF", 18)
Store.Paper.TitleText:SetFontObject(GameFontNormal)
Store.Paper.TitleText:SetPoint("CENTER", 0, -35)
Store.Paper.TitleText:SetShadowOffset(1,-1)
Store.Paper.TitleText:SetSize(270, 40)
Store.Paper.TitleText:SetText("Bienvenue dans la collection d'articles cosmétique!")

Store.Paper.DescText = Store.Paper:CreateFontString()
Store.Paper.DescText:SetFont("Fonts\\FRIZQT__.TTF", 11)
Store.Paper.DescText:SetFontObject(GameFontHighlight)
Store.Paper.DescText:SetPoint("BOTTOM", 0, 22)
Store.Paper.DescText:SetShadowOffset(0,-1)
Store.Paper.DescText:SetSize(160, 50)
Store.Paper.DescText:SetText("Assurez-vous d'utiliser vos objets cosmétique, de cette façon ils apparaissent dans votre collection!")

Store.Paper.Texture.AnimationGroup = Store.Paper.Texture:CreateAnimationGroup()
Store.Paper.Texture.AnimationGroup.Grow = Store.Paper.Texture.AnimationGroup:CreateAnimation("Scale")
Store.Paper.Texture.AnimationGroup.Grow:SetScale(1.0, 0.001)
Store.Paper.Texture.AnimationGroup.Grow:SetDuration(0.0)
Store.Paper.Texture.AnimationGroup.Grow:SetStartDelay(0)
Store.Paper.Texture.AnimationGroup.Grow:SetOrder(1)
Store.Paper.Texture.AnimationGroup.Grow:SetOrigin("BOTTOM", 0, 0)

Store.Paper.Texture.AnimationGroup.Grow = Store.Paper.Texture.AnimationGroup:CreateAnimation("Scale")
Store.Paper.Texture.AnimationGroup.Grow:SetScale(1.0, 1000.0)
Store.Paper.Texture.AnimationGroup.Grow:SetDuration(0.15)
Store.Paper.Texture.AnimationGroup.Grow:SetStartDelay(0.15)
Store.Paper.Texture.AnimationGroup.Grow:SetOrder(2)
Store.Paper.Texture.AnimationGroup.Grow:SetOrigin("BOTTOM", 0, 0)

Store.Paper.LineUp.AnimationGroup = Store.Paper.LineUp:CreateAnimationGroup()
Store.Paper.LineUp.AnimationGroup.Grow = Store.Paper.LineUp.AnimationGroup:CreateAnimation("Scale")
Store.Paper.LineUp.AnimationGroup.Grow:SetScale(0.001, 1.0)
Store.Paper.LineUp.AnimationGroup.Grow:SetDuration(0.0)
Store.Paper.LineUp.AnimationGroup.Grow:SetStartDelay(0.15)
Store.Paper.LineUp.AnimationGroup.Grow:SetOrder(1)
Store.Paper.LineUp.AnimationGroup.Grow:SetOrigin("BOTTOM", 0, 0)

Store.Paper.LineUp.AnimationGroup.Grow = Store.Paper.LineUp.AnimationGroup:CreateAnimation("Scale")
Store.Paper.LineUp.AnimationGroup.Grow:SetScale(1000.0, 1.0)
Store.Paper.LineUp.AnimationGroup.Grow:SetDuration(0.5)
Store.Paper.LineUp.AnimationGroup.Grow:SetOrder(2)
Store.Paper.LineUp.AnimationGroup.Grow:SetOrigin("BOTTOM", 0, 0)

Store.Paper.LineDown.AnimationGroup = Store.Paper.LineDown:CreateAnimationGroup()
Store.Paper.LineDown.AnimationGroup.Grow = Store.Paper.LineDown.AnimationGroup:CreateAnimation("Scale")
Store.Paper.LineDown.AnimationGroup.Grow:SetScale(0.001, 1.0)
Store.Paper.LineDown.AnimationGroup.Grow:SetDuration(0.0)
Store.Paper.LineDown.AnimationGroup.Grow:SetStartDelay(0.15)
Store.Paper.LineDown.AnimationGroup.Grow:SetOrder(1)
Store.Paper.LineDown.AnimationGroup.Grow:SetOrigin("BOTTOM", 0, 0)

Store.Paper.LineDown.AnimationGroup.Grow = Store.Paper.LineDown.AnimationGroup:CreateAnimation("Scale")
Store.Paper.LineDown.AnimationGroup.Grow:SetScale(1000.0, 1.0)
Store.Paper.LineDown.AnimationGroup.Grow:SetDuration(0.5)
Store.Paper.LineDown.AnimationGroup.Grow:SetOrder(2)
Store.Paper.LineDown.AnimationGroup.Grow:SetOrigin("BOTTOM", 0, 0)
Store.Paper.LineDown.AnimationGroup.Grow:SetScript("OnPlay", function()
    Store.Paper.Texture.AnimationGroup:Stop();
    Store.Paper.LineUp.AnimationGroup:Stop();

    Store.Paper.Texture.AnimationGroup:Play();
    Store.Paper.LineUp.AnimationGroup:Play();
end)
-------------------------------------------------------------------------------
--                             Collection itself                             --
-------------------------------------------------------------------------------

Store.CollectionList = CreateFrame("FRAME", nil, Store, nil)
Store.CollectionList:SetPoint("CENTER", 150, -15)
Store.CollectionList:SetSize(470,425)
Store.CollectionList:EnableMouseWheel(true)

Store.CollectionList:SetScript("OnMouseWheel", function(self, delta)
    if (Store.CollectionList.PrevButton:IsEnabled() == 1) and (delta == -1) then
        StoreCollectionListPrevPage(Store.CollectionList.PrevButton)
    elseif (Store.CollectionList.NextButton:IsEnabled() == 1) and (delta == 1) then
        StoreCollectionListNextPage(Store.CollectionList.NextButton)
    end
end)

Store.CollectionList.Glow = CreateFrame("Model", nil, Store.CollectionList)
Store.CollectionList.Glow:SetSize(470,425)
Store.CollectionList.Glow:SetPoint("CENTER", 0, 0)
Store.CollectionList.Glow:SetModel("World\\Kalimdor\\orgrimmar\\passivedoodads\\orgrimmarbonfire\\orgrimmarfloatingembers.m2")
Store.CollectionList.Glow:SetModelScale(0.1)
Store.CollectionList.Glow:SetCamera(0)
Store.CollectionList.Glow:SetPosition(0.085,0.21,0)
Store.CollectionList.Glow:SetFacing(0)
Store.CollectionList.Glow:SetFrameLevel(2)

Store.CollectionList.Glow2 = CreateFrame("Model", nil, Store.CollectionList)
Store.CollectionList.Glow2:SetSize(470,425)
Store.CollectionList.Glow2:SetPoint("CENTER", 0, 0)
Store.CollectionList.Glow2:SetModel("World\\Kalimdor\\orgrimmar\\passivedoodads\\orgrimmarbonfire\\orgrimmarfloatingembers.m2")
Store.CollectionList.Glow2:SetModelScale(0.1)
Store.CollectionList.Glow2:SetCamera(0)
Store.CollectionList.Glow2:SetPosition(0.085,0.21,0)
Store.CollectionList.Glow2:SetFacing(0)
Store.CollectionList.Glow2:SetFrameLevel(2)

Store.CollectionList.TitleText = Store.CollectionList:CreateFontString("StoreCollectionListFrameTitleText")
Store.CollectionList.TitleText:SetFont("Fonts\\MORPHEUS.TTF", 14)
Store.CollectionList.TitleText:SetFontObject(GameFontNormal)
Store.CollectionList.TitleText:SetPoint("TOP", 0, -32)
Store.CollectionList.TitleText:SetShadowOffset(0,-1)
Store.CollectionList.TitleText:SetText("Collection des objets cosmétique")

Store.CollectionList.PageText = Store.CollectionList:CreateFontString("StoreCollectionListFrameTitleText")
Store.CollectionList.PageText:SetFont("Fonts\\FRIZQT__.TTF", 12)
Store.CollectionList.PageText:SetFontObject(GameFontHighlight)
Store.CollectionList.PageText:SetPoint("BOTTOM", 0, 15)
Store.CollectionList.PageText:SetShadowOffset(0,-1)
Store.CollectionList.PageText:SetText("Page 1/1")

Store.CollectionList.NextButton = CreateFrame("Button", nil, Store.CollectionList, nil)
Store.CollectionList.NextButton:SetSize(26, 26)
Store.CollectionList.NextButton:SetPoint("BOTTOM",150,12)
Store.CollectionList.NextButton:EnableMouse(true)
Store.CollectionList.NextButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
Store.CollectionList.NextButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
Store.CollectionList.NextButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
Store.CollectionList.NextButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
Store.CollectionList.NextButton:SetScript("OnClick", StoreCollectionListNextPage)

Store.CollectionList.PrevButton = CreateFrame("Button", nil, Store.CollectionList, nil)
Store.CollectionList.PrevButton:SetSize(26, 26)
Store.CollectionList.PrevButton:SetPoint("BOTTOM",-150,12)
Store.CollectionList.PrevButton:EnableMouse(true)
Store.CollectionList.PrevButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
Store.CollectionList.PrevButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
Store.CollectionList.PrevButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
Store.CollectionList.PrevButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
Store.CollectionList.PrevButton:SetScript("OnClick", StoreCollectionListPrevPage)


StoreCollectionItemFrame1 = CreateFrame("FRAME", "StoreCollectionItemFrame1", Store.CollectionList, nil)
StoreCollectionItemFrame1:SetPoint("CENTER", -152, 95)
StoreCollectionItemFrame1:SetSize(256,128)

StoreCollectionItemFrame2 = CreateFrame("FRAME", "StoreCollectionItemFrame2", Store.CollectionList, nil)
StoreCollectionItemFrame2:SetPoint("CENTER", -2, 95)
StoreCollectionItemFrame2:SetSize(256,128)

StoreCollectionItemFrame3 = CreateFrame("FRAME", "StoreCollectionItemFrame3", Store.CollectionList, nil)
StoreCollectionItemFrame3:SetPoint("CENTER", 148, 95)
StoreCollectionItemFrame3:SetSize(256,128)

StoreCollectionItemFrame4 = CreateFrame("FRAME", "StoreCollectionItemFrame4", Store.CollectionList, nil)
StoreCollectionItemFrame4:SetPoint("CENTER", -152, -11)
StoreCollectionItemFrame4:SetSize(256,128)
StoreCollectionItemFrame4:SetFrameLevel(5)

StoreCollectionItemFrame5 = CreateFrame("FRAME", "StoreCollectionItemFrame5", Store.CollectionList, nil)
StoreCollectionItemFrame5:SetPoint("CENTER", -2, -11)
StoreCollectionItemFrame5:SetSize(256,128)
StoreCollectionItemFrame5:SetFrameLevel(5)

StoreCollectionItemFrame6 = CreateFrame("FRAME", "StoreCollectionItemFrame6", Store.CollectionList, nil)
StoreCollectionItemFrame6:SetPoint("CENTER", 148, -11)
StoreCollectionItemFrame6:SetSize(256,128)
StoreCollectionItemFrame6:SetFrameLevel(5)

StoreCollectionItemFrame7 = CreateFrame("FRAME", "StoreCollectionItemFrame7", Store.CollectionList, nil)
StoreCollectionItemFrame7:SetPoint("CENTER", -152, -117)
StoreCollectionItemFrame7:SetSize(256,128)
StoreCollectionItemFrame7:SetFrameLevel(6)

StoreCollectionItemFrame8 = CreateFrame("FRAME", "StoreCollectionItemFrame8", Store.CollectionList, nil)
StoreCollectionItemFrame8:SetPoint("CENTER", -2, -117)
StoreCollectionItemFrame8:SetSize(256,128)
StoreCollectionItemFrame8:SetFrameLevel(6)

StoreCollectionItemFrame9 = CreateFrame("FRAME", "StoreCollectionItemFrame9", Store.CollectionList, nil)
StoreCollectionItemFrame9:SetPoint("CENTER", 148, -117)
StoreCollectionItemFrame9:SetSize(256,128)
StoreCollectionItemFrame9:SetFrameLevel(6)

for i = 1, 9 do 
    _G["StoreCollectionItemFrame"..i..".BackgroundTexture"] = _G["StoreCollectionItemFrame"..i]:CreateTexture(nil, "BACKGROUND")
    _G["StoreCollectionItemFrame"..i..".BackgroundTexture"]:SetSize(_G["StoreCollectionItemFrame"..i]:GetSize())
    _G["StoreCollectionItemFrame"..i..".BackgroundTexture"]:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\StoreButtonBG")
    _G["StoreCollectionItemFrame"..i..".BackgroundTexture"]:SetPoint("CENTER")

    _G["StoreCollectionItemFrame"..i..".Button"] = CreateFrame("Button", nil, _G["StoreCollectionItemFrame"..i], nil)
    _G["StoreCollectionItemFrame"..i..".Button"]:SetSize(131, 99)
    _G["StoreCollectionItemFrame"..i..".Button"]:SetPoint("CENTER",0,0)
    _G["StoreCollectionItemFrame"..i..".Button"]:EnableMouse(true)
    _G["StoreCollectionItemFrame"..i..".Button"]:SetHighlightTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\StoreButtonBG_Highlight")
    _G["StoreCollectionItemFrame"..i..".Button"]:GetHighlightTexture():ClearAllPoints()
    _G["StoreCollectionItemFrame"..i..".Button"]:GetHighlightTexture():SetPoint("CENTER",0,0)
    _G["StoreCollectionItemFrame"..i..".Button"]:GetHighlightTexture():SetSize(256,128)

    _G["StoreCollectionItemFrame"..i..".PrestigeTexture"] = _G["StoreCollectionItemFrame"..i]:CreateTexture(nil, "ARTWORK")
    _G["StoreCollectionItemFrame"..i..".PrestigeTexture"]:SetSize(92,92)
    _G["StoreCollectionItemFrame"..i..".PrestigeTexture"]:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\prestige-icon-4")
    _G["StoreCollectionItemFrame"..i..".PrestigeTexture"]:SetPoint("CENTER", 0, 10)

    _G["StoreCollectionItemFrame"..i..".IconFrame"] = CreateFrame("FRAME", nil, _G["StoreCollectionItemFrame"..i], nil)
    _G["StoreCollectionItemFrame"..i..".IconFrame"]:SetPoint("CENTER")
    _G["StoreCollectionItemFrame"..i..".IconFrame"]:SetSize(_G["StoreCollectionItemFrame"..i]:GetSize())

    _G["StoreCollectionItemFrame"..i..".Icon"] = _G["StoreCollectionItemFrame"..i..".IconFrame"]:CreateTexture(nil, "BACKGROUND")
    _G["StoreCollectionItemFrame"..i..".Icon"]:SetSize(40,40)
    _G["StoreCollectionItemFrame"..i..".Icon"]:SetTexture("Interface\\icons\\FoxMountIcon")
    _G["StoreCollectionItemFrame"..i..".Icon"]:SetPoint("CENTER", 0, 11)
    SetPortraitToTexture(_G["StoreCollectionItemFrame"..i..".Icon"], "Interface\\icons\\FoxMountIcon")

    _G["StoreCollectionItemFrame"..i..".RoundBG"] = _G["StoreCollectionItemFrame"..i..".IconFrame"]:CreateTexture(nil, "BACKGROUND")
    _G["StoreCollectionItemFrame"..i..".RoundBG"]:SetSize(128,64)
    _G["StoreCollectionItemFrame"..i..".RoundBG"]:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\StoreCollectionRoundBG")
    _G["StoreCollectionItemFrame"..i..".RoundBG"]:SetPoint("CENTER", 0, 10)

    _G["StoreCollectionItemFrame"..i..".Circle"] = _G["StoreCollectionItemFrame"..i..".IconFrame"]:CreateTexture(nil, "ARTWORK")
    _G["StoreCollectionItemFrame"..i..".Circle"]:SetSize(64,64)
    _G["StoreCollectionItemFrame"..i..".Circle"]:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\StoreCollectionRound")
    _G["StoreCollectionItemFrame"..i..".Circle"]:SetPoint("CENTER", 0, 10)

    _G["StoreCollectionItemFrame"..i..".GroupIcon"] = _G["StoreCollectionItemFrame"..i..".IconFrame"]:CreateTexture(nil, "OVERLAY")
    _G["StoreCollectionItemFrame"..i..".GroupIcon"]:SetSize(40,40)
    _G["StoreCollectionItemFrame"..i..".GroupIcon"]:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\category-icon-featured")
    _G["StoreCollectionItemFrame"..i..".GroupIcon"]:SetPoint("CENTER", 0, -10)

    _G["StoreCollection"..i..".TextNormal"] = _G["StoreCollectionItemFrame"..i]:CreateFontString("StoreCollection"..i.."TextNormal")
    _G["StoreCollection"..i..".TextNormal"]:SetSize(120, 22)
    _G["StoreCollection"..i..".TextNormal"]:SetFont("Fonts\\FRIZQT__.TTF", 11)
    _G["StoreCollection"..i..".TextNormal"]:SetFontObject(GameFontHighlight)
    _G["StoreCollection"..i..".TextNormal"]:SetPoint("CENTER", 0, -30)
    _G["StoreCollection"..i..".TextNormal"]:SetShadowOffset(0,-1)
    _G["StoreCollection"..i..".TextNormal"]:SetText("[Misty Fox]")
    _G["StoreCollection"..i..".TextNormal"]:SetJustifyH("CENTER")

    _G["StoreCollectionItemFrame"..i..".Button"]:SetScript("OnClick", function(self)
      PlaySound("igMainMenuOptionCheckBoxOn")

      local Icon            =          _G["StoreCollectionItemFrame"..i..".Button.Icon"]
      local Artwork         =          _G["StoreCollectionItemFrame"..i..".Button.ArtWork"]
      local ArtworkModel    =          _G["StoreCollectionItemFrame"..i..".Button.ArtWorkPreview"]
      local TitleText       =          _G["StoreCollectionItemFrame"..i..".Button.ItemName"]
      local DescText        =          _G["StoreCollectionItemFrame"..i..".Button.ItemDescription"]
      local Sp_Cost         =          _G["StoreCollectionItemFrame"..i..".Button.SeasonalPointsCost"]
      local Dp_Cost         =          _G["StoreCollectionItemFrame"..i..".Button.DonatePointsCost"]
      local ItemInternal    =          _G["StoreCollectionItemFrame"..i..".Button.ItemInternal"]
      local Item            =          _G["StoreCollectionItemFrame"..i..".Button.Item"]
      local PreviewData     =          _G["StoreCollectionItemFrame"..i..".Button.PreviewData"]

      if ( IsModifiedClick("CHATLINK") ) then
        local _, link = GetItemInfo(ItemInternal)
        ChatEdit_InsertLink(link)
        return
      end

      Store.Paper.Icon:SetNormalTexture(Icon)
      Store.Paper.ArtWork:SetTexture(Artwork)
      Store.Paper.TitleText:SetText(TitleText)
      Store.Paper.DescText:SetText(DescText)
      Store.ItemInternal = ItemInternal
      Store.Preview_Current = PreviewData

      if not(Store.ModelPreview.BGTex:SetTexture(ArtworkModel)) then
        Store.ModelPreview.BGTex:SetTexture(Store.DefaultPreviewTexture)
      end

      if (Sp_Cost ~= 0) or (Dp_Cost ~= 0) then -- show buy option and cost
        Store.SP_Cost_Current = Sp_Cost
        Store.DP_Cost_Current = Dp_Cost
        --Store.BuyStoreButton:Enable()
      else
        Store.BuyStoreButton:Disable()
      end

      if (Item ~= 0) then
        Store.ItemSelected = Item
        Store.ActivateStoreButton:Enable()
        --Store.ModelPreview_fake.SpendPoints.MainButton:Enable()
        Store.BuyStoreButton:Disable()
      else
        Store.ItemSelected = 0
        Store.ActivateStoreButton:Disable()
        Store.ModelPreview_fake.SpendPoints.MainButton:Disable()
      end

      StoreCollectionHideModelPreview()
      StoreCollectionFrameShowPaper()   
      end)

    _G["StoreCollectionItemFrame"..i]:Hide()
  end

local NewItemInCollection = CreateFrame("FRAME", "StoreNewItemInCollection", UIParent, nil)
NewItemInCollection:SetPoint("CENTER", UIParent, 0, 200)
NewItemInCollection:SetSize(512,512)
NewItemInCollection:SetFrameStrata("DIALOG")
NewItemInCollection:SetFrameLevel(7)
NewItemInCollection:Hide()

NewItemInCollection.HighLightOfNewItem = CreateFrame("FRAME", nil, NewItemInCollection, nil)
NewItemInCollection.HighLightOfNewItem:SetPoint("CENTER", NewItemInCollection, 0, 40)
NewItemInCollection.HighLightOfNewItem:SetSize(256,256)
NewItemInCollection.HighLightOfNewItem:SetFrameLevel(7)

NewItemInCollection.HighLightOfNewItem.HighlightTex = NewItemInCollection.HighLightOfNewItem:CreateTexture(nil, "ARTWORK")
NewItemInCollection.HighLightOfNewItem.HighlightTex:SetSize(256,256)
NewItemInCollection.HighLightOfNewItem.HighlightTex:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\DragonHighlight")
NewItemInCollection.HighLightOfNewItem.HighlightTex:SetPoint("CENTER", 0,0)
NewItemInCollection.HighLightOfNewItem.HighlightTex:SetBlendMode("ADD")

NewItemInCollection.HighLightOfNewItem.Glow = CreateFrame("Model", nil, NewItemInCollection.HighLightOfNewItem)
NewItemInCollection.HighLightOfNewItem.Glow:SetWidth(256);               
NewItemInCollection.HighLightOfNewItem.Glow:SetHeight(256);
NewItemInCollection.HighLightOfNewItem.Glow:SetPoint("CENTER", 0, 0)
NewItemInCollection.HighLightOfNewItem.Glow:SetModel("World\\Kalimdor\\silithus\\passivedoodads\\ahnqirajglow\\quirajglow.m2")
NewItemInCollection.HighLightOfNewItem.Glow:SetModelScale(0.02)
NewItemInCollection.HighLightOfNewItem.Glow:SetCamera(0)
NewItemInCollection.HighLightOfNewItem.Glow:SetPosition(0.075,0.09,0)
NewItemInCollection.HighLightOfNewItem.Glow:SetFacing(0)
NewItemInCollection.HighLightOfNewItem.Glow:SetFrameLevel(7)

NewItemInCollection.Main = CreateFrame("FRAME", nil, NewItemInCollection, nil)
NewItemInCollection.Main:SetPoint("CENTER", 0, 25)
NewItemInCollection.Main:SetSize(256,128)
NewItemInCollection.Main:SetFrameLevel(8)
NewItemInCollection.Main:EnableMouse(true)
NewItemInCollection.Main:SetAlpha(0)

NewItemInCollection.Main.PrestigeTexture = NewItemInCollection.Main:CreateTexture(nil, "BORDER", nil, 10)
NewItemInCollection.Main.PrestigeTexture:SetSize(92,92)
NewItemInCollection.Main.PrestigeTexture:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\prestige-icon-4")
NewItemInCollection.Main.PrestigeTexture:SetPoint("CENTER", 0, 10)

NewItemInCollection.Main.Icon = NewItemInCollection.Main:CreateTexture(nil, "ARTWORK", nil, 2)
NewItemInCollection.Main.Icon:SetSize(40,40)
NewItemInCollection.Main.Icon:SetTexture("Interface\\icons\\FoxMountIcon")
NewItemInCollection.Main.Icon:SetPoint("CENTER", 0, 11)
SetPortraitToTexture(NewItemInCollection.Main.Icon, "Interface\\icons\\FoxMountIcon")

NewItemInCollection.Main.RoundBG = NewItemInCollection.Main:CreateTexture(nil, "ARTWORK", nil, 2)
NewItemInCollection.Main.RoundBG:SetSize(128,64)
NewItemInCollection.Main.RoundBG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\StoreCollectionRoundBG")
NewItemInCollection.Main.RoundBG:SetPoint("CENTER", 0, 10)

NewItemInCollection.Main.Circle = NewItemInCollection.Main:CreateTexture(nil, "OVERLAY", nil, 1)
NewItemInCollection.Main.Circle:SetSize(64,64)
NewItemInCollection.Main.Circle:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\StoreCollectionRound")
NewItemInCollection.Main.Circle:SetPoint("CENTER", 0, 10)

NewItemInCollection.Main.TextAdd = NewItemInCollection.Main:CreateFontString(nil, "OVERLAY")
NewItemInCollection.Main.TextAdd:SetSize(300, 20)
NewItemInCollection.Main.TextAdd:SetFont("Fonts\\FRIZQT__.TTF", 11)
NewItemInCollection.Main.TextAdd:SetFontObject(GameFontNormal)
NewItemInCollection.Main.TextAdd:SetPoint("CENTER", 0, -60)
NewItemInCollection.Main.TextAdd:SetShadowOffset(0,-1)
NewItemInCollection.Main.TextAdd:SetText("|cffFFFFFFVous avez débloqué avec succès|r Vanity Item|cffFFFFFF!|r")

NewItemInCollection.Main.TextNormal = NewItemInCollection.Main:CreateFontString(nil, "OVERLAY")
NewItemInCollection.Main.TextNormal:SetSize(300, 20)
NewItemInCollection.Main.TextNormal:SetFont("Fonts\\FRIZQT__.TTF", 14)
NewItemInCollection.Main.TextNormal:SetFontObject(GameFontNormal)
NewItemInCollection.Main.TextNormal:SetPoint("CENTER", 0, -30)
NewItemInCollection.Main.TextNormal:SetShadowOffset(0,-1)
NewItemInCollection.Main.TextNormal:SetText("VANITY ITEM NAME")

NewItemInCollection.Main.Texture = NewItemInCollection.Main:CreateTexture(nil, "BACKGROUND", nil, 2)
NewItemInCollection.Main.Texture:SetTexture("Interface\\LevelUp\\LevelUpTex")
NewItemInCollection.Main.Texture:SetSize(284, 115)
NewItemInCollection.Main.Texture:SetPoint("CENTER", 0, 10)
NewItemInCollection.Main.Texture:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
NewItemInCollection.Main.Texture:SetVertexColor(1, 1, 1, 0.6)

NewItemInCollection.Main.LineUp = NewItemInCollection.Main:CreateTexture(nil, "BORDER", nil, 2)
NewItemInCollection.Main.LineUp:SetTexture("Interface\\LevelUp\\LevelUpTex")
NewItemInCollection.Main.LineUp:SetSize(264, 7)
NewItemInCollection.Main.LineUp:SetPoint("CENTER", 0, 15)
NewItemInCollection.Main.LineUp:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
NewItemInCollection.Main.LineUp:SetVertexColor(1, 1, 1)

NewItemInCollection.Main.LineDown = NewItemInCollection.Main:CreateTexture(nil, "BORDER", nil, 2)
NewItemInCollection.Main.LineDown:SetTexture("Interface\\LevelUp\\LevelUpTex")
NewItemInCollection.Main.LineDown:SetSize(264, 7)
NewItemInCollection.Main.LineDown:SetPoint("CENTER", 0, -46)
NewItemInCollection.Main.LineDown:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
NewItemInCollection.Main.LineDown:SetVertexColor(1, 1, 1)

NewItemInCollection.Main.Texture.AnimationGroup = NewItemInCollection.Main.Texture:CreateAnimationGroup()
NewItemInCollection.Main.Texture.AnimationGroup.Grow = NewItemInCollection.Main.Texture.AnimationGroup:CreateAnimation("Scale")
NewItemInCollection.Main.Texture.AnimationGroup.Grow:SetScale(1.0, 0.001)
NewItemInCollection.Main.Texture.AnimationGroup.Grow:SetDuration(0.0)
NewItemInCollection.Main.Texture.AnimationGroup.Grow:SetStartDelay(0)
NewItemInCollection.Main.Texture.AnimationGroup.Grow:SetOrder(1)
NewItemInCollection.Main.Texture.AnimationGroup.Grow:SetOrigin("BOTTOM", 0, 0)

NewItemInCollection.Main.Texture.AnimationGroup.Grow = NewItemInCollection.Main.Texture.AnimationGroup:CreateAnimation("Scale")
NewItemInCollection.Main.Texture.AnimationGroup.Grow:SetScale(1.0, 1000.0)
NewItemInCollection.Main.Texture.AnimationGroup.Grow:SetDuration(0.15)
NewItemInCollection.Main.Texture.AnimationGroup.Grow:SetStartDelay(0.15)
NewItemInCollection.Main.Texture.AnimationGroup.Grow:SetOrder(2)
NewItemInCollection.Main.Texture.AnimationGroup.Grow:SetOrigin("BOTTOM", 0, 0)

NewItemInCollection.Main.LineUp.AnimationGroup = NewItemInCollection.Main.LineUp:CreateAnimationGroup()
NewItemInCollection.Main.LineUp.AnimationGroup.Grow = NewItemInCollection.Main.LineUp.AnimationGroup:CreateAnimation("Scale")
NewItemInCollection.Main.LineUp.AnimationGroup.Grow:SetScale(0.001, 1.0)
NewItemInCollection.Main.LineUp.AnimationGroup.Grow:SetDuration(0.0)
NewItemInCollection.Main.LineUp.AnimationGroup.Grow:SetStartDelay(0.15)
NewItemInCollection.Main.LineUp.AnimationGroup.Grow:SetOrder(1)
NewItemInCollection.Main.LineUp.AnimationGroup.Grow:SetOrigin("BOTTOM", 0, 0)

NewItemInCollection.Main.LineUp.AnimationGroup.Grow = NewItemInCollection.Main.LineUp.AnimationGroup:CreateAnimation("Scale")
NewItemInCollection.Main.LineUp.AnimationGroup.Grow:SetScale(1000.0, 1.0)
NewItemInCollection.Main.LineUp.AnimationGroup.Grow:SetDuration(0.5)
NewItemInCollection.Main.LineUp.AnimationGroup.Grow:SetOrder(2)
NewItemInCollection.Main.LineUp.AnimationGroup.Grow:SetOrigin("BOTTOM", 0, 0)

NewItemInCollection.Main.LineDown.AnimationGroup = NewItemInCollection.Main.LineDown:CreateAnimationGroup()
NewItemInCollection.Main.LineDown.AnimationGroup.Grow = NewItemInCollection.Main.LineDown.AnimationGroup:CreateAnimation("Scale")
NewItemInCollection.Main.LineDown.AnimationGroup.Grow:SetScale(0.001, 1.0)
NewItemInCollection.Main.LineDown.AnimationGroup.Grow:SetDuration(0.0)
NewItemInCollection.Main.LineDown.AnimationGroup.Grow:SetStartDelay(0.15)
NewItemInCollection.Main.LineDown.AnimationGroup.Grow:SetOrder(1)
NewItemInCollection.Main.LineDown.AnimationGroup.Grow:SetOrigin("BOTTOM", 0, 0)

NewItemInCollection.Main.LineDown.AnimationGroup.Grow = NewItemInCollection.Main.LineDown.AnimationGroup:CreateAnimation("Scale")
NewItemInCollection.Main.LineDown.AnimationGroup.Grow:SetScale(1000.0, 1.0)
NewItemInCollection.Main.LineDown.AnimationGroup.Grow:SetDuration(0.5)
NewItemInCollection.Main.LineDown.AnimationGroup.Grow:SetOrder(2)
NewItemInCollection.Main.LineDown.AnimationGroup.Grow:SetOrigin("BOTTOM", 0, 0)
NewItemInCollection.Main.LineDown.AnimationGroup.Grow:SetScript("OnPlay", function()
    NewItemInCollection.Main.Texture.AnimationGroup:Stop();
    NewItemInCollection.Main.LineUp.AnimationGroup:Stop();

    NewItemInCollection.Main.Texture.AnimationGroup:Play();
    NewItemInCollection.Main.LineUp.AnimationGroup:Play();
end)

-------------------------------------------------------------------------------
--                       New Item unlocked animations                        --
-------------------------------------------------------------------------------
NewItemInCollection.HighLightOfNewItem.AnimationGroup = NewItemInCollection.HighLightOfNewItem:CreateAnimationGroup()
NewItemInCollection.HighLightOfNewItem.AnimationGroup.Rotation = NewItemInCollection.HighLightOfNewItem.AnimationGroup:CreateAnimation("Rotation")
NewItemInCollection.HighLightOfNewItem.AnimationGroup.Rotation:SetStartDelay(0)
NewItemInCollection.HighLightOfNewItem.AnimationGroup.Rotation:SetDuration(6)
NewItemInCollection.HighLightOfNewItem.AnimationGroup.Rotation:SetOrder(1)
NewItemInCollection.HighLightOfNewItem.AnimationGroup.Rotation:SetEndDelay(0)
NewItemInCollection.HighLightOfNewItem.AnimationGroup.Rotation:SetSmoothing("NONE")
NewItemInCollection.HighLightOfNewItem.AnimationGroup.Rotation:SetDegrees(90)
NewItemInCollection.HighLightOfNewItem.AnimationGroup.Rotation:SetScript("OnPlay", function()
    PlaySound("igQuestListComplete")
    BaseFrameFadeIn(NewItemInCollection)
end)

NewItemInCollection.HighLightOfNewItem.AnimationGroup.AlphaFadeOut = NewItemInCollection.HighLightOfNewItem.AnimationGroup:CreateAnimation("Alpha")
NewItemInCollection.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetStartDelay(0)
NewItemInCollection.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetDuration(3)
NewItemInCollection.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetOrder(2)
NewItemInCollection.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetEndDelay(0)
NewItemInCollection.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetSmoothing("NONE")
NewItemInCollection.HighLightOfNewItem.AnimationGroup.AlphaFadeOut:SetChange(-1)

NewItemInCollection.HighLightOfNewItem.AnimationGroup:SetScript("OnStop", function()
    NewItemInCollection:Hide()
end)

NewItemInCollection.HighLightOfNewItem.AnimationGroup:SetScript("OnFinished", function()
    NewItemInCollection:Hide()
end)


NewItemInCollection.Main.AnimationGroup = NewItemInCollection.Main:CreateAnimationGroup()
NewItemInCollection.Main.AnimationGroup.Alpha = NewItemInCollection.Main.AnimationGroup:CreateAnimation("Alpha")
NewItemInCollection.Main.AnimationGroup.Alpha:SetStartDelay(0)
NewItemInCollection.Main.AnimationGroup.Alpha:SetDuration(1)
NewItemInCollection.Main.AnimationGroup.Alpha:SetOrder(1)
NewItemInCollection.Main.AnimationGroup.Alpha:SetEndDelay(5)
NewItemInCollection.Main.AnimationGroup.Alpha:SetSmoothing("NONE")
NewItemInCollection.Main.AnimationGroup.Alpha:SetChange(1)
NewItemInCollection.Main.AnimationGroup.Alpha:SetScript("OnPlay", function()
    NewItemInCollection.Main:Show()
    NewItemInCollection.Main.LineDown.AnimationGroup:Play()
    NewItemInCollection.HighLightOfNewItem.AnimationGroup:Play()
end)

NewItemInCollection.Main.AnimationGroup.AlphaFadeOut = NewItemInCollection.Main.AnimationGroup:CreateAnimation("Alpha")
NewItemInCollection.Main.AnimationGroup.AlphaFadeOut:SetStartDelay(0)
NewItemInCollection.Main.AnimationGroup.AlphaFadeOut:SetDuration(3)
NewItemInCollection.Main.AnimationGroup.AlphaFadeOut:SetOrder(2)
NewItemInCollection.Main.AnimationGroup.AlphaFadeOut:SetEndDelay(0)
NewItemInCollection.Main.AnimationGroup.AlphaFadeOut:SetSmoothing("NONE")
NewItemInCollection.Main.AnimationGroup.AlphaFadeOut:SetChange(-1)

NewItemInCollection.Main.AnimationGroup:SetScript("OnStop", function()
    NewItemInCollection.Main:Hide()
    NewItemInCollection.HighLightOfNewItem.AnimationGroup:Finish()
end)

NewItemInCollection.Main.AnimationGroup:SetScript("OnFinished", function()
    NewItemInCollection.Main:Hide()
    NewItemInCollection.HighLightOfNewItem.AnimationGroup:Finish()
end)

-------------------------------------------------------------------------------
--                              Preview Model                                --
-------------------------------------------------------------------------------
Store.ModelPreview = CreateFrame("DressUpModel", nil, Store)
Store.ModelPreview.HackFix = 0
Store.ModelPreview.MaxSize = 1.2
Store.ModelPreview.MinSize = 0.6
Store.ModelPreview.Creature = 101230
Store.ModelPreview.DefaultSize = Store.ModelPreview.MaxSize - (Store.ModelPreview.MaxSize-Store.ModelPreview.MinSize)/2
Store.ModelPreview.DefaultFacing = 0.75

Store.ModelPreview:SetSize(455, 410)
Store.ModelPreview:SetPoint("CENTER", 147, -15)
Store.ModelPreview:SetFrameLevel(9)
Store.ModelPreview:SetCreature(Store.ModelPreview.Creature)
Store.ModelPreview:RefreshUnit()
Store.ModelPreview:SetFacing(Store.ModelPreview.DefaultFacing)
Store.ModelPreview:SetCamera(0)
Store.ModelPreview:SetLight(1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8);
Store.ModelPreview:SetModelScale(Store.ModelPreview.DefaultSize)

--StoreCollectionFrameModelPreviewFixModelPosition(Store.ModelPreview)

Store.ModelPreview:Hide()
Store.ModelPreview_fake = CreateFrame("Frame", nil, Store)
Store.ModelPreview_fake:SetSize(455, 410)
Store.ModelPreview_fake:SetPoint("CENTER", 147, -15)
Store.ModelPreview_fake:SetFrameLevel(9)
Store.ModelPreview_fake:EnableMouse(true)
Store.ModelPreview_fake:EnableMouseWheel(true)
Store.ModelPreview_fake:Hide()

Store.ModelPreview_fake.CloseButton = CreateFrame("Button", nil, Store.ModelPreview_fake, "UIPanelCloseButton")
Store.ModelPreview_fake.CloseButton:SetPoint("TOPRIGHT", 6, 6) 
Store.ModelPreview_fake.CloseButton:EnableMouse(true)
Store.ModelPreview_fake.CloseButton:SetScript("OnMouseUp", function()
    PlaySound("igMainMenuClose")
    StoreCollectionHideModelPreview()
    StoreCollectionFrameShowPaper()
    end)

--StoreCollectionFrameModelPreviewInitModel(Store.ModelPreview)

Store.ModelPreview.BGTex = Store.ModelPreview_fake:CreateTexture(nil, "BACKGROUND")
Store.ModelPreview.BGTex:SetSize(1024,512)
Store.ModelPreview.BGTex:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\PreviewMounts\\MountPreview")
Store.ModelPreview.BGTex:SetPoint("CENTER", 1, 0)

Store.ModelPreview:SetScript("OnShow", function(self)
  StoreCollectionFrameModelPreviewFixModelPosition(self)
  self:SetFacing(Store.ModelPreview.DefaultFacing)
  self:SetModelScale(0.8)
  StoreCollectionFrameModelPreviewLoadItems()
end)
Store.ModelPreview:SetScript("OnHide", function(self)
  StoreCollectionFrameModelPreviewFixModelPosition(self)
  self:SetFacing(Store.ModelPreview.DefaultFacing)
  self:SetModelScale(Store.ModelPreview.DefaultSize)
  StoreCollectionFrameModelPreviewLoadItems()
end)

Store.ModelPreview_fake:SetScript("OnUpdate", function()
    if ( ModelPreview_SELECT_ROTATION_START_X ) then
        local x = GetCursorPosition();
        local diff = (x - ModelPreview_SELECT_ROTATION_START_X) * 0.01;
        ModelPreview_SELECT_ROTATION_START_X = GetCursorPosition();
        Store.ModelPreview:SetFacing((Store.ModelPreview:GetFacing() + diff));
    end
end)

Store.ModelPreview_fake:SetScript("OnMouseDown", function(self, button)
    if ( button == "LeftButton" ) then
        ModelPreview_SELECT_ROTATION_START_X = GetCursorPosition();
        ModelPreview_SELECT_INITIAL_FACING = Store.ModelPreview:GetFacing();
    end
end)

Store.ModelPreview_fake:SetScript("OnMouseUp", function(self, button)
    if ( button == "LeftButton" ) then
        ModelPreview_SELECT_ROTATION_START_X = nil
    end
end)

Store.ModelPreview_fake:SetScript("OnMouseWheel", function(self, delta)
    if Store.ModelPreview:GetModelScale() >= Store.ModelPreview.MaxSize and delta > 0 then
        return false
    end

    if Store.ModelPreview:GetModelScale() <= Store.ModelPreview.MinSize and delta < 0 then
        return false
    end
    Store.ModelPreview:SetModelScale(Store.ModelPreview:GetModelScale()+(delta*0000.1))
end)

Store.ModelPreview_fake.SpendPoints = CreateFrame("FRAME", nil, Store.ModelPreview_fake)
Store.ModelPreview_fake.SpendPoints:SetSize(256,32)
Store.ModelPreview_fake.SpendPoints:SetPoint("BOTTOM", 0, -20)
--Store.ModelPreview_fake.SpendPoints:SetBackdrop(GameTooltip:GetBackdrop())
--Store.ModelPreview_fake.SpendPoints:SetFrameLevel(5)

Store.ModelPreview_fake.SpendPoints.BG = Store.ModelPreview_fake.SpendPoints:CreateTexture(nil, "ARTWORK") 
Store.ModelPreview_fake.SpendPoints.BG:SetAllPoints() 
Store.ModelPreview_fake.SpendPoints.BG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\Enchant_RefundButton") 

Store.ModelPreview_fake.SpendPoints.BG_2 = Store.ModelPreview_fake.SpendPoints:CreateTexture(nil, "BORDER") 
Store.ModelPreview_fake.SpendPoints.BG_2:SetPoint("CENTER", 0, 63)
Store.ModelPreview_fake.SpendPoints.BG_2:SetSize(512, 128)
Store.ModelPreview_fake.SpendPoints.BG_2:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\ShadowPaladinBar_Horizontal_Bgnd") 

Store.ModelPreview_fake.SpendPoints.Glow = CreateFrame("Model", nil, Store.ModelPreview_fake.SpendPoints)
Store.ModelPreview_fake.SpendPoints.Glow:SetWidth(256);               
Store.ModelPreview_fake.SpendPoints.Glow:SetHeight(256);
Store.ModelPreview_fake.SpendPoints.Glow:SetPoint("CENTER", 0, 0)
Store.ModelPreview_fake.SpendPoints.Glow:SetModel("World\\Kalimdor\\silithus\\passivedoodads\\ahnqirajglow\\quirajglow_purple.m2")
Store.ModelPreview_fake.SpendPoints.Glow:SetModelScale(0.016)
Store.ModelPreview_fake.SpendPoints.Glow:SetCamera(0)
Store.ModelPreview_fake.SpendPoints.Glow:SetPosition(0.083,0.095,0)
Store.ModelPreview_fake.SpendPoints.Glow:SetFacing(0)

Store.ModelPreview_fake.SpendPoints.MainButton = CreateFrame("Button", nil, Store.ModelPreview_fake.SpendPoints, "StaticPopupButtonTemplate")
Store.ModelPreview_fake.SpendPoints.MainButton:SetPoint("CENTER", 1, 1)
Store.ModelPreview_fake.SpendPoints.MainButton:EnableMouse(true)
Store.ModelPreview_fake.SpendPoints.MainButton:SetWidth(148)
Store.ModelPreview_fake.SpendPoints.MainButton:SetHeight(19)
Store.ModelPreview_fake.SpendPoints.MainButton:SetText("Transmogrify Items")
Store.ModelPreview_fake.SpendPoints.MainButton:Disable()
Store.ModelPreview_fake.SpendPoints.MainButton:SetScript("OnClick", function(self)
    if (Store.ItemSelected ~= 0) and (self:IsEnabled() == 1 ) then
        --AIO.Handle("StoreCollections", "TmogItem", Store.ItemSelected)
    end
end)
-------------------------------------------------------------------------------
--                     Disenchant Confirm Dialog Frame                       --
-------------------------------------------------------------------------------
Store.ConfirmBuy = CreateFrame("Frame", nil,Store,nil)
Store.ConfirmBuy:ClearAllPoints()
Store.ConfirmBuy:SetBackdrop(StaticPopup1:GetBackdrop())
Store.ConfirmBuy:SetHeight(115)
Store.ConfirmBuy:SetWidth(390)
Store.ConfirmBuy:SetPoint("CENTER", Store, 0,0)
Store.ConfirmBuy:SetFrameLevel(14)
Store.ConfirmBuy:EnableMouse(true)
Store.ConfirmBuy:Hide()

Store.ConfirmBuy.text = Store.ConfirmBuy:CreateFontString(nil, "BORDER", "GameFontHighlight")
Store.ConfirmBuy.text:SetFont("Fonts\\FRIZQT__.TTF", 11)
Store.ConfirmBuy.text:SetText("Are you sure that you want\nto purchase following item:\nITEMLINK\n\nItem cost: |cffFFFFFF10|r Seasonal Points")
Store.ConfirmBuy.text:SetPoint("TOP",0,-20)


Store.ConfirmBuy.Alert = Store.ConfirmBuy:CreateTexture() 
Store.ConfirmBuy.Alert:SetTexture("Interface\\Icons\\inv_archaeology_70_demon_orbofinnerchaos") 
Store.ConfirmBuy.Alert:SetSize(48,48)
Store.ConfirmBuy.Alert:SetPoint("LEFT",24,0)

Store.ConfirmBuy.Yes = CreateFrame("Button", nil, Store.ConfirmBuy, "StaticPopupButtonTemplate") 
Store.ConfirmBuy.Yes:SetWidth(110) 
Store.ConfirmBuy.Yes:SetHeight(19) 
Store.ConfirmBuy.Yes:SetPoint("BOTTOM", -60,15) 
Store.ConfirmBuy.Yes:SetScript("OnClick", function(self)
  BuyItem(self)
  Store.ConfirmBuy:Hide()
end)

Store.ConfirmBuy.No = CreateFrame("Button", nil, Store.ConfirmBuy, "StaticPopupButtonTemplate") 
Store.ConfirmBuy.No:SetWidth(110) 
Store.ConfirmBuy.No:SetHeight(19) 
Store.ConfirmBuy.No:SetPoint("BOTTOM", 60,15) 
Store.ConfirmBuy.No:SetScript("OnClick", function()
  Store.ConfirmBuy:Hide()
end)

Store.ConfirmBuy.Yes.text = Store.ConfirmBuy.Yes:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
Store.ConfirmBuy.Yes.text:SetFont("Fonts\\FRIZQT__.TTF", 11)
Store.ConfirmBuy.Yes.text:SetText("Accept")
Store.ConfirmBuy.Yes.text:SetPoint("CENTER",0,1)

Store.ConfirmBuy.No.text = Store.ConfirmBuy.No:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
Store.ConfirmBuy.No.text:SetFont("Fonts\\FRIZQT__.TTF", 11)
Store.ConfirmBuy.No.text:SetText("Cancel")
Store.ConfirmBuy.No.text:SetPoint("CENTER",0,1)

Store.ConfirmBuy.Yes:SetFontString(Store.ConfirmBuy.Yes.text)
Store.ConfirmBuy.No:SetFontString(Store.ConfirmBuy.No.text)

Store.ConfirmBuy:SetScript("OnShow", function(self)
    PlaySound("igMainMenuOpen")
    if (Store.ItemInternal ~= 0) then
        local _, link = GetItemInfo(Store.ItemInternal)
        Store.ConfirmBuy.text:SetText("|cffE1AB18Are you sure that you want\nto purchase following item:\n"..link.."\n\n|cffE1AB18Item cost: |cffFFFFFF"..Store.SP_Cost_Current.."|r|cffE1AB18 Seasonal Points")

        if (Store.SP_Cost_Current <= Store.SPBalance) then
            Store.ConfirmBuy.Yes:Enable()
        else
            Store.ConfirmBuy.Yes:Disable()
        end
    end
    --[[if (self.Mode == "DISENCHANT") then
        Store.ConfirmBuy.Yes:SetScript("OnClick", function()
            PlaySound("igMainMenuOptionCheckBoxOn")
            DisenchantItem()
            Store.ConfirmBuy:Hide()
        end)
    elseif (self.Mode == "COLLECTIONREFORGE") then
        Store.ConfirmBuy.Yes:SetScript("OnClick", function()
            PlaySound("igMainMenuOptionCheckBoxOn")
            CollectionReforge()
            Store.ConfirmBuy:Hide()
        end)
    end]]--
end)
Store.ConfirmBuy:SetScript("OnHide", function(self)
    PlaySound("igMainMenuClose")
end)

-- Addon Init
Store:RegisterEvent("COMMENTATOR_SKIRMISH_QUEUE_REQUEST")

Store:SetScript("OnEvent", function(self, event, asc_event, ...)
    if event == "COMMENTATOR_SKIRMISH_QUEUE_REQUEST" then
        if asc_event == "ASCENSION_STORE_COLLECTION_ITEM_LEARNED" then
            local item = ...
            local vanityItem = Addon.VanityItems[item]
            UnlockNewItem(vanityItem)

        elseif asc_event == "ASCENSION_CUSTOM_POINTS_SEASONAL_POINTS_VALUE_CHANGED" then
            local old, new = ...
            UpdateBalance(0, new)
        end
    end
end)