skilltab_pagenum = 1
MAX_SPELLS = 1024;
MAX_SKILLLINE_TABS = 29;
SPELLS_PER_PAGE = 12;
MAX_SPELL_PAGES = ceil(MAX_SPELLS / SPELLS_PER_PAGE);
BOOKTYPE_SPELL = "spell";
BOOKTYPE_PET = "pet";
SPELLBOOK_PAGENUMBERS = {};

INTERNAL_TAB_ID = nil
INTERNAL_TAB_TEXTURE = "Interface\\Icons\\Mail_GMIcon"
NUM_SPELL_TABS = GetNumSpellTabs()


local ceil = ceil;
local strlen = strlen;
local tinsert = tinsert;
local tremove = tremove;

local function RecalculateSkillLineTabs()
	
end

function ToggleSpellBook(bookType)
	if ( not HasPetSpells() and bookType == BOOKTYPE_PET ) then
		return;
	end
	
	local isShown = SpellBookFrame:IsShown();
	if ( isShown and (SpellBookFrame.bookType ~= bookType) ) then
		SpellBookFrame.suppressCloseSound = true;
	end
	
	HideUIPanel(SpellBookFrame);
	if ( (not isShown or (SpellBookFrame.bookType ~= bookType)) ) then
		SpellBookFrame.bookType = bookType;
		ShowUIPanel(SpellBookFrame);
	end
	SpellBookFrame_UpdatePages();

	SpellBookFrame.suppressCloseSound = nil;
end

function SpellBookFrame_OnLoad(self)
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");

	SpellBookFrame.bookType = BOOKTYPE_SPELL;
	-- Init page nums
	SPELLBOOK_PAGENUMBERS[1] = 1;
	SPELLBOOK_PAGENUMBERS[2] = 1;
	SPELLBOOK_PAGENUMBERS[3] = 1;
	SPELLBOOK_PAGENUMBERS[4] = 1;
	SPELLBOOK_PAGENUMBERS[5] = 1;
	SPELLBOOK_PAGENUMBERS[6] = 1;
	SPELLBOOK_PAGENUMBERS[7] = 1;
	SPELLBOOK_PAGENUMBERS[8] = 1;
	SPELLBOOK_PAGENUMBERS[9] = 1;
	SPELLBOOK_PAGENUMBERS[10] = 1;

	SPELLBOOK_PAGENUMBERS[11] = 1;
	SPELLBOOK_PAGENUMBERS[12] = 1;
	SPELLBOOK_PAGENUMBERS[13] = 1;
	SPELLBOOK_PAGENUMBERS[14] = 1;
	SPELLBOOK_PAGENUMBERS[15] = 1;
	SPELLBOOK_PAGENUMBERS[16] = 1;
	SPELLBOOK_PAGENUMBERS[17] = 1;
	SPELLBOOK_PAGENUMBERS[18] = 1;
	SPELLBOOK_PAGENUMBERS[19] = 1;
	SPELLBOOK_PAGENUMBERS[20] = 1;
	SPELLBOOK_PAGENUMBERS[21] = 1;
	SPELLBOOK_PAGENUMBERS[22] = 1;
	SPELLBOOK_PAGENUMBERS[23] = 1;
	SPELLBOOK_PAGENUMBERS[24] = 1;
	SPELLBOOK_PAGENUMBERS[25] = 1;
	SPELLBOOK_PAGENUMBERS[26] = 1;
	SPELLBOOK_PAGENUMBERS[27] = 1;
	SPELLBOOK_PAGENUMBERS[28] = 1;
	SPELLBOOK_PAGENUMBERS[29] = 1;
	SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = 1;
	
	-- Set to the first tab by default
	SpellBookSkillLineTab_OnClick(nil, 1);

	-- Initialize tab flashing
	SpellBookFrame.flashTabs = nil;

	--extra buttons for a spellbookframe--
	SpellBook_SkillTabOverFlowButton = CreateFrame("Button", "SpellBook_SkillTabOverFlowButton", SpellBookFrame, nil)
	SpellBook_SkillTabOverFlowButton:SetSize(32,32)
	SpellBook_SkillTabOverFlowButton:SetPoint("TOPLEFT", SpellBookSkillLineTab1, 0, 49)
	SpellBook_SkillTabOverFlowButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	SpellBook_SkillTabOverFlowButton:SetNormalTexture("Interface\\Icons\\misc_arrowright")
	SpellBook_SkillTabOverFlowButton:SetDisabledTexture("Interface\\Icons\\misc_arrowright_disabled")
	SpellBook_SkillTabOverFlowButton:SetScript("OnUpdate", function(self)
	    if (_G["SpellBookSkillLineTab"..NUM_SPELL_TABS]) and (_G["SpellBookSkillLineTab"..NUM_SPELL_TABS]:IsVisible()) then
	        self:Disable()
	    elseif (NUM_SPELL_TABS > 7) then
	        self:Enable()
	    end
	    end)

	SpellBook_SkillTabOverFlowButton:SetScript("OnClick", function(self)
	    if (self:IsEnabled()) then
	        skilltab_pagenum = skilltab_pagenum +1
	        SpellBookFrame_PlayOpenSound()
	        SpellBookFrame_Update()
	    end
	end)

	SpellBook_SkillTabOverFlowButton:SetScript("OnEnter", function(self)
	    if (self:IsEnabled()) then
	        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		    GameTooltip:AddLine("Next Page")
		    GameTooltip:Show()
	    end
	end)

	SpellBook_SkillTabOverFlowButton:SetScript("OnLeave", function(self)
	    GameTooltip:Hide()
	end)


	SpellBook_SkillTabOverFlowButton_b = CreateFrame("Button", "SpellBook_SkillTabOverFlowButton_b", SpellBookFrame, nil)
	SpellBook_SkillTabOverFlowButton_b:SetSize(32,32)
	SpellBook_SkillTabOverFlowButton_b:SetPoint("BOTTOMLEFT", SpellBookSkillLineTab7, 0, -49)
	SpellBook_SkillTabOverFlowButton_b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	SpellBook_SkillTabOverFlowButton_b:SetNormalTexture("Interface\\Icons\\misc_arrowleft")
	SpellBook_SkillTabOverFlowButton_b:SetDisabledTexture("Interface\\Icons\\misc_arrowleft_disabled")
	SpellBook_SkillTabOverFlowButton_b:SetScript("OnUpdate", function(self)
	    if (skilltab_pagenum == 1) then
	        self:Disable()
	            else
	        self:Enable()
	    end
	    end)

	SpellBook_SkillTabOverFlowButton_b:SetScript("OnClick", function(self)
	    if (self:IsEnabled()) then
	        skilltab_pagenum = skilltab_pagenum -1
	        SpellBookFrame_PlayOpenSound()
	        SpellBookFrame_Update()
	    end
	end)

	SpellBook_SkillTabOverFlowButton_b:SetScript("OnEnter", function(self)
	    if (self:IsEnabled()) then
	        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		    GameTooltip:AddLine("Previous Page")
		    GameTooltip:Show()
	    end
	end)

	SpellBook_SkillTabOverFlowButton_b:SetScript("OnLeave", function(self)
	    GameTooltip:Hide()
	end)


	SpellBook_SkillTabOverFlowButton.BG = SpellBook_SkillTabOverFlowButton:CreateTexture("SpellBook_SkillTabOverFlowButton", "BACKGROUND", nil)
	SpellBook_SkillTabOverFlowButton.BG:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
	SpellBook_SkillTabOverFlowButton.BG:SetSize(64, 64)
	SpellBook_SkillTabOverFlowButton.BG:SetPoint("TOPLEFT", -3, 11)

	SpellBook_SkillTabOverFlowButton_b.BG = SpellBook_SkillTabOverFlowButton_b:CreateTexture("SpellBook_SkillTabOverFlowButton", "BACKGROUND", nil)
	SpellBook_SkillTabOverFlowButton_b.BG:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
	SpellBook_SkillTabOverFlowButton_b.BG:SetSize(64, 64)
	SpellBook_SkillTabOverFlowButton_b.BG:SetPoint("TOPLEFT", -3, 11)

	SpellBook_SkillTabOverFlowButton:Show()
	SpellBook_SkillTabOverFlowButton_b:Show()

	SpellBook_SkillTabOverFlowButton:Disable()
	SpellBook_SkillTabOverFlowButton_b:Disable()

	SpellBook_SkillTabOverFlowButton:SetScale(0.8)
	SpellBook_SkillTabOverFlowButton_b:SetScale(0.8)

end

function SpellBookFrame_OnEvent(self, event, ...)
	if ( event == "SPELLS_CHANGED" ) then
		if ( SpellBookFrame:IsVisible() ) then
			SpellBookFrame_Update();
		end
	elseif ( event == "LEARNED_SPELL_IN_TAB" ) then
		local arg1 = ...;
		local flashFrame = _G["SpellBookSkillLineTab"..arg1.."Flash"];
		if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
			return;
		else
			if ( flashFrame ) then
				flashFrame:Show();
				SpellBookFrame.flashTabs = 1;
			end
		end
	end
end

function SpellBookFrame_OnShow(self)
	SpellBookFrame_Update(1);
	
	-- If there are tabs waiting to flash, then flash them... yeah..
	if ( self.flashTabs ) then
		UIFrameFlash(SpellBookTabFlashFrame, 0.5, 0.5, 30, nil);
	end

	-- Show multibar slots
	MultiActionBar_ShowAllGrids();
	UpdateMicroButtons();

	SpellBookFrame_PlayOpenSound();
end

function SpellBookFrame_Update(showing)
    -- Hide all tabs
    SpellBookFrameTabButton1:Hide();
    SpellBookFrameTabButton2:Hide();
    SpellBookFrameTabButton3:Hide();
    
    -- Setup skillline tabs
    if ( showing ) then
        SpellBookSkillLineTab_OnClick(nil, SpellBookFrame.selectedSkillLine);
        UpdateSpells();
    end

    local numSkillLineTabs = GetNumSpellTabs();
    local name, texture, offset, numSpells;
    local skillLineTab;
    for i=1, MAX_SKILLLINE_TABS do
        skillLineTab = _G["SpellBookSkillLineTab"..i];
        if ( i <= numSkillLineTabs and SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
            name, texture = GetSpellTabInfo(i);

            if (texture == INTERNAL_TAB_TEXTURE) then
                INTERNAL_TAB_ID = i
            end

            skillLineTab:SetNormalTexture(texture);
            skillLineTab.tooltip = name;
            skillLineTab:Show();

            -- Set the selected tab
            if ( SpellBookFrame.selectedSkillLine == i ) then
                skillLineTab:SetChecked(1);
            else
                skillLineTab:SetChecked(nil);
            end

            if ( SpellBookFrame.selectedSkillLine == numSkillLineTabs ) then
                _G["SpellBookSkillLineTab"..INTERNAL_TAB_ID]:SetChecked(1)
            end
        else
            _G["SpellBookSkillLineTab"..i.."Flash"]:Hide();

            skillLineTab:Hide();
        end
    end

    -- Setup tabs
    local hasPetSpells, petToken = HasPetSpells();
    SpellBookFrame.petTitle = nil;
    if ( hasPetSpells ) then
        SpellBookFrame_SetTabType(SpellBookFrameTabButton1, BOOKTYPE_SPELL);
        SpellBookFrame_SetTabType(SpellBookFrameTabButton2, BOOKTYPE_PET, petToken);
    else
        SpellBookFrame_SetTabType(SpellBookFrameTabButton1, BOOKTYPE_SPELL);

        if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
            -- if has no pet spells but trying to show the pet spellbook close the window;
            HideUIPanel(SpellBookFrame);
            SpellBookFrame.bookType = BOOKTYPE_SPELL;
        end
    end

    if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
        SpellBookTitleText:SetText(SPELLBOOK);
        SpellBookFrame_ShowSpells();
        SpellBookFrame_UpdatePages();
    elseif ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
        SpellBookTitleText:SetText(SpellBookFrame.petTitle);
        SpellBookFrame_ShowSpells();
        SpellBookFrame_UpdatePages();
    end

    if SpellBookFrame.selectedSkillLine == INTERNAL_TAB_ID then 
    	SpellBookSkillLineTab_OnClick(nil, 1)
    end
    
    SpellBook_SkillTabOverflow(skilltab_pagenum)
end

function SpellBookFrame_HideSpells ()
	for i = 1, SPELLS_PER_PAGE do
		_G["SpellButton" .. i]:Hide();
	end
	
	for i = 1, MAX_SKILLLINE_TABS do
		_G["SpellBookSkillLineTab" .. i]:Hide();
	end
	
	SpellBookPrevPageButton:Hide();
	SpellBookNextPageButton:Hide();
	SpellBookPageText:Hide();
end

function SpellBookFrame_ShowSpells ()
	for i = 1, SPELLS_PER_PAGE do
		_G["SpellButton" .. i]:Show();
	end
	
	SpellBookPrevPageButton:Show();
	SpellBookNextPageButton:Show();
	SpellBookPageText:Show();
end

function SpellBookFrame_UpdatePages()
	local currentPage, maxPages = SpellBook_GetCurrentPage();
	if ( maxPages == 0 ) then
		return;
	end
	if ( currentPage > maxPages ) then
		if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
			SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = maxPages;
		else
			SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = maxPages;
		end
		currentPage = maxPages;
		UpdateSpells();
		if ( currentPage == 1 ) then
			SpellBookPrevPageButton:Disable();
		else
			SpellBookPrevPageButton:Enable();
		end
		if ( currentPage == maxPages ) then
			SpellBookNextPageButton:Disable();
		else
			SpellBookNextPageButton:Enable();
		end
	end
	if ( currentPage == 1 ) then
		SpellBookPrevPageButton:Disable();
	else
		SpellBookPrevPageButton:Enable();
	end
	if ( currentPage == maxPages ) then
		SpellBookNextPageButton:Disable();
	else
		SpellBookNextPageButton:Enable();
	end
	SpellBookPageText:SetFormattedText(PAGE_NUMBER, currentPage);
	-- Hide spell rank checkbox if the player is a rogue or warrior
	local _, class = UnitClass("player");
	local showSpellRanks = true;
	if ( class == "ROGUE" or class == "WARRIOR" ) then
		showSpellRanks = false;
	end
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL and showSpellRanks ) then
		ShowAllSpellRanksCheckBox:Show();
	else
		ShowAllSpellRanksCheckBox:Hide();
	end
end

function SpellBookFrame_SetTabType(tabButton, bookType, token)
	if ( bookType == BOOKTYPE_SPELL ) then
		tabButton.bookType = BOOKTYPE_SPELL;
		tabButton:SetText(SPELLBOOK);
		tabButton:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 1);
		tabButton.binding = "TOGGLESPELLBOOK";
	elseif ( bookType == BOOKTYPE_PET ) then
		tabButton.bookType = BOOKTYPE_PET;
		tabButton:SetText(_G["PET_TYPE_"..token]);
		tabButton:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 1);
		tabButton.binding = "TOGGLEPETBOOK";
		SpellBookFrame.petTitle = _G["PET_TYPE_"..token];
	else
		tabButton.bookType = INSCRIPTION;
		tabButton:SetText(GLYPHS);
		tabButton:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 2);
		tabButton.binding = "TOGGLEINSCRIPTION";
	end
	if ( SpellBookFrame.bookType == bookType ) then
		tabButton:Disable();
	else
		tabButton:Enable();
	end
	tabButton:Show();
end

function SpellBookFrame_PlayOpenSound()
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound("igSpellBookOpen");
	elseif ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		-- Need to change to pet book open sound
		PlaySound("igAbilityOpen");
	else
		PlaySound("igSpellBookOpen");
	end
end

function SpellBookFrame_PlayCloseSound()
	if ( not SpellBookFrame.suppressCloseSound ) then
		if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
			PlaySound("igSpellBookClose");
		else
			-- Need to change to pet book close sound
			PlaySound("igAbilityClose");
		end
	end
end

function SpellBookFrame_OnHide(self)
	SpellBookFrame_PlayCloseSound();

	-- Stop the flash frame from flashing if its still flashing.. flash flash flash
	UIFrameFlashRemoveFrame(SpellBookTabFlashFrame);
	-- Hide all the flashing textures
	for i=1, MAX_SKILLLINE_TABS do
		_G["SpellBookSkillLineTab"..i.."Flash"]:Hide();
	end

	-- Hide multibar slots
	MultiActionBar_HideAllGrids();
	
	-- Do this last, it can cause taint.
	UpdateMicroButtons();
end

function SpellButton_OnLoad(self) 
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function SpellButton_OnEvent(self, event, ...)
	if ( event == "SPELLS_CHANGED" or event == "SPELL_UPDATE_COOLDOWN" or event == "UPDATE_SHAPESHIFT_FORM" ) then
		-- need to listen for UPDATE_SHAPESHIFT_FORM because attack icons change when the shapeshift form changes
		SpellButton_UpdateButton(self);
	elseif ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		SpellButton_UpdateSelection(self);
	elseif ( event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
		SpellButton_UpdateSelection(self);
	elseif ( event == "PET_BAR_UPDATE" ) then
		if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
			SpellButton_UpdateButton(self);
		end
	end
end

function SpellButton_OnShow(self)
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	self:RegisterEvent("TRADE_SKILL_SHOW");
	self:RegisterEvent("TRADE_SKILL_CLOSE");
	self:RegisterEvent("PET_BAR_UPDATE");

	SpellButton_UpdateButton(self);

	skilltab_pagenum = 1
	SpellBookFrame_Update(1)
end

function SpellButton_OnHide(self)
	self:UnregisterEvent("SPELLS_CHANGED");
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED");
	self:UnregisterEvent("TRADE_SKILL_SHOW");
	self:UnregisterEvent("TRADE_SKILL_CLOSE");
	self:UnregisterEvent("PET_BAR_UPDATE");
end
 
function SpellButton_OnEnter(self)
	local id = SpellBook_GetSpellID(self:GetID());
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( GameTooltip:SetSpell(id, SpellBookFrame.bookType) ) then
		self.UpdateTooltip = SpellButton_OnEnter;
	else
		self.UpdateTooltip = nil;
	end
end

function SpellButton_OnClick(self, button) 
	local id = SpellBook_GetSpellID(self:GetID());
	if ( id > MAX_SPELLS ) then
		return;
	end
	if ( button ~= "LeftButton" and SpellBookFrame.bookType == BOOKTYPE_PET ) then
		ToggleSpellAutocast(id, SpellBookFrame.bookType);
	else
		CastSpell(id, SpellBookFrame.bookType);
		SpellButton_UpdateSelection(self);
	end
end

function SpellButton_OnModifiedClick(self, button) 
	local id = SpellBook_GetSpellID(self:GetID());
	if ( id > MAX_SPELLS ) then
		return;
	end
	if ( IsModifiedClick("CHATLINK") ) then
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName, subSpellName = GetSpellName(id, SpellBookFrame.bookType);
			if ( spellName and not IsPassiveSpell(id, SpellBookFrame.bookType) ) then
				if ( subSpellName and (strlen(subSpellName) > 0) ) then
					ChatEdit_InsertLink(spellName.."("..subSpellName..")");
				else
					ChatEdit_InsertLink(spellName);
				end
			end
			return;
		else
			local spellLink, tradeSkillLink = GetSpellLink(id, SpellBookFrame.bookType);
			if ( tradeSkillLink ) then
				ChatEdit_InsertLink(tradeSkillLink);
			elseif ( spellLink ) then
				ChatEdit_InsertLink(spellLink);
			end
			return;
		end
	end
	if ( IsModifiedClick("PICKUPACTION") ) then
		PickupSpell(id, SpellBookFrame.bookType);
		return;
	end
	if ( IsModifiedClick("SELFCAST") ) then
		CastSpell(id, SpellBookFrame.bookType, true);
		return;
	end
end

function SpellButton_OnDrag(self) 
	local id = SpellBook_GetSpellID(self:GetID());
	if ( id > MAX_SPELLS or not _G[self:GetName().."IconTexture"]:IsShown() ) then
		return;
	end
	self:SetChecked(0);
	PickupSpell(id, SpellBookFrame.bookType);
end

function SpellButton_UpdateSelection(self)
	local temp, texture, offset, numSpells = SpellBook_GetTabInfo(SpellBookFrame.selectedSkillLine);
	
	local id, displayID = SpellBook_GetSpellID(self:GetID());
	if ( (SpellBookFrame.bookType ~= BOOKTYPE_PET) and (not displayID or displayID > (offset + numSpells)) ) then
		self:SetChecked("false");
		return;
	end

	if ( IsSelectedSpell(id, SpellBookFrame.bookType) ) then
		self:SetChecked("true");
	else
		self:SetChecked("false");
	end
end

function SpellButton_UpdateButton(self)
	if ( not SpellBookFrame.selectedSkillLine ) then
		SpellBookFrame.selectedSkillLine = 1;
	end
	local temp, texture, offset, numSpells = SpellBook_GetTabInfo(SpellBookFrame.selectedSkillLine);
	SpellBookFrame.selectedSkillLineOffset = offset;

	local id, displayID = SpellBook_GetSpellID(self:GetID());
	local name = self:GetName();
	local iconTexture = _G[name.."IconTexture"];
	local spellString = _G[name.."SpellName"];
	local subSpellString = _G[name.."SubSpellName"];
	local cooldown = _G[name.."Cooldown"];
	local autoCastableTexture = _G[name.."AutoCastable"];

	if ( (SpellBookFrame.bookType ~= BOOKTYPE_PET) and (not displayID or displayID > (offset + numSpells)) ) then
		self:Disable();
		iconTexture:Hide();
		spellString:Hide();
		subSpellString:Hide();
		cooldown:Hide();
		autoCastableTexture:Hide();
		SpellBook_ReleaseAutoCastShine(self.shine)
		self.shine = nil;
		self:SetChecked(0);
		_G[name.."NormalTexture"]:SetVertexColor(1.0, 1.0, 1.0);
		return;
	else
		self:Enable();
	end

	local texture = GetSpellTexture(id, SpellBookFrame.bookType);
	local highlightTexture = _G[name.."Highlight"];
	local normalTexture = _G[name.."NormalTexture"];
	-- If no spell, hide everything and return
	if ( not texture or (strlen(texture) == 0) ) then
		iconTexture:Hide();
		spellString:Hide();
		subSpellString:Hide();
		cooldown:Hide();
		autoCastableTexture:Hide();
		SpellBook_ReleaseAutoCastShine(self.shine);
		self.shine = nil;
		highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		self:SetChecked(0);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
		return;
	end

	local start, duration, enable = GetSpellCooldown(id, SpellBookFrame.bookType);
	CooldownFrame_SetTimer(cooldown, start, duration, enable);
	if ( enable == 1 ) then
		iconTexture:SetVertexColor(1.0, 1.0, 1.0);
	else
		iconTexture:SetVertexColor(0.4, 0.4, 0.4);
	end

	local autoCastAllowed, autoCastEnabled = GetSpellAutocast(id, SpellBookFrame.bookType);
	if ( autoCastAllowed ) then
		autoCastableTexture:Show();
	else
		autoCastableTexture:Hide();
	end
	if ( autoCastEnabled and not self.shine ) then
		self.shine = SpellBook_GetAutoCastShine();
		self.shine:Show();
		self.shine:SetParent(self);
		self.shine:SetPoint("CENTER", self, "CENTER");
		AutoCastShine_AutoCastStart(self.shine);
	elseif ( autoCastEnabled ) then
		self.shine:Show();
		self.shine:SetParent(self);
		self.shine:SetPoint("CENTER", self, "CENTER");
		AutoCastShine_AutoCastStart(self.shine);
	elseif ( not autoCastEnabled ) then
		SpellBook_ReleaseAutoCastShine(self.shine);
		self.shine = nil;
	end

	local spellName, subSpellName = GetSpellName(id, SpellBookFrame.bookType);
	local isPassive = IsPassiveSpell(id, SpellBookFrame.bookType);
	if ( isPassive ) then
		normalTexture:SetVertexColor(0, 0, 0);
		highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
		--subSpellName = PASSIVE_PARENS;
		spellString:SetTextColor(PASSIVE_SPELL_FONT_COLOR.r, PASSIVE_SPELL_FONT_COLOR.g, PASSIVE_SPELL_FONT_COLOR.b);
	else
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
		highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		spellString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	iconTexture:SetTexture(texture);
	spellString:SetText(spellName);
	subSpellString:SetText(subSpellName);
	if ( subSpellName ~= "" ) then
		spellString:SetPoint("LEFT", self, "RIGHT", 4, 4);
	else
		spellString:SetPoint("LEFT", self, "RIGHT", 4, 2);
	end

	iconTexture:Show();
	spellString:Show();
	subSpellString:Show();
	SpellButton_UpdateSelection(self);
end

function SpellBookPrevPageButton_OnClick()
	local pageNum = SpellBook_GetCurrentPage() - 1;
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound("igAbiliityPageTurn");
		SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = pageNum;
	else
		SpellBookTitleText:SetText(SpellBookFrame.petTitle);
		-- Need to change to pet book pageturn sound
		PlaySound("igAbiliityPageTurn");
		SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = pageNum;
	end
	SpellBook_UpdatePageArrows();
	SpellBookPageText:SetFormattedText(PAGE_NUMBER, pageNum);
	UpdateSpells();
	
end

function SpellBookNextPageButton_OnClick()
	local pageNum = SpellBook_GetCurrentPage() + 1;
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound("igAbiliityPageTurn");
		SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = pageNum;
	else
		SpellBookTitleText:SetText(SpellBookFrame.petTitle);
		-- Need to change to pet book pageturn sound
		PlaySound("igAbiliityPageTurn");
		SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = pageNum;
	end
	SpellBook_UpdatePageArrows();
	SpellBookPageText:SetFormattedText(PAGE_NUMBER, pageNum);
	UpdateSpells();
	
end

function SpellBookSkillLineTab_OnClick(self, id)
	local update;
	if ( not id ) then
		update = 1;
		id = self:GetID();
	end
	if ( SpellBookFrame.selectedSkillLine ~= id ) then
		PlaySound("igAbiliityPageTurn");
	end
	SpellBookFrame.selectedSkillLine = id;
	local name, texture, offset, numSpells = SpellBook_GetTabInfo(SpellBookFrame.selectedSkillLine);
	SpellBookFrame.selectedSkillLineOffset = offset;
	SpellBookFrame.selectedSkillLineNumSpells = numSpells;
	SpellBook_UpdatePageArrows();
	SpellBookFrame_Update();
	SpellBookPageText:SetFormattedText(PAGE_NUMBER, SpellBook_GetCurrentPage());
	if ( update ) then
		UpdateSpells();
	end
	-- Stop tab flashing
	if ( self ) then
		local tabFlash = _G[self:GetName().."Flash"];
		if ( tabFlash ) then
			tabFlash:Hide();
		end
	end
end

function SpellBookFrameTabButton_OnClick(self)
	-- suppress the hiding sound so we don't play a hide and show sound simultaneously
	SpellBookFrame.suppressCloseSound = true;
	ToggleSpellBook(self.bookType, true);
	SpellBookFrame.suppressCloseSound = false;
end

function SpellBook_GetSpellID(id)
	if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		return id + (SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] - 1));
	else
		local slot = id + SpellBookFrame.selectedSkillLineOffset + ( SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] - 1));
		if ( not GetCVarBool("ShowAllSpellRanks") ) then
			return GetKnownSlotFromHighestRankSlot(slot), slot;
		end
		return slot, slot;
	end
end

function SpellBook_UpdatePageArrows()
	local currentPage, maxPages = SpellBook_GetCurrentPage();
	if ( currentPage == 1 ) then
		SpellBookPrevPageButton:Disable();
	else
		SpellBookPrevPageButton:Enable();
	end
	if ( currentPage == maxPages ) then
		SpellBookNextPageButton:Disable();
	else
		SpellBookNextPageButton:Enable();
	end
end

function SpellBook_GetCurrentPage()
	local currentPage, maxPages;
	local numPetSpells = HasPetSpells();
	if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		currentPage = SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET];
		maxPages = ceil(numPetSpells/SPELLS_PER_PAGE);
	else
		currentPage = SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine];
		local name, texture, offset, numSpells = SpellBook_GetTabInfo(SpellBookFrame.selectedSkillLine);
		maxPages = ceil(numSpells/SPELLS_PER_PAGE);
	end
	return currentPage, maxPages;
end

local maxShines = 1;
shineGet = {}
function SpellBook_GetAutoCastShine ()
	local shine = shineGet[1];
	
	if ( shine ) then
		tremove(shineGet, 1);
	else
		shine = CreateFrame("FRAME", "AutocastShine" .. maxShines, SpellBookFrame, "SpellBookShineTemplate");
		maxShines = maxShines + 1;
	end
	
	return shine;
end

function SpellBook_ReleaseAutoCastShine (shine)
	if ( not shine ) then
		return;
	end
	
	shine:Hide();
	AutoCastShine_AutoCastStop(shine);
	tinsert(shineGet, shine);
end

function SpellBook_GetTabInfo(skillLine)
	local name, texture, offset, numSpells, highestRankOffset, highestRankNumSpells = GetSpellTabInfo(skillLine);
	if ( not GetCVarBool("ShowAllSpellRanks")) then
		offset = highestRankOffset;
		numSpells = highestRankNumSpells;
	end
	return name, texture, offset, numSpells;
end

function SpellBook_SkillTabOverflow(skilltab_pagenum)
  NUM_SPELL_TABS = GetNumSpellTabs()
  local pagestart = 1
  local pagemax = 7

  --page settings--
  if skilltab_pagenum == 1 then 
    pagestart = 1
    pagemax = 7

  elseif skilltab_pagenum == 2 then 
    pagestart = 8
    pagemax = 14

  elseif skilltab_pagenum == 3 then 
    pagestart = 15
    pagemax = 21

  elseif skilltab_pagenum == 4 then 
    pagestart = 22
    pagemax = 28

  elseif skilltab_pagenum == 5 then 
    pagestart = 29
    pagemax = 29
  end
  --end of the page settings

  if (INTERNAL_TAB_ID) then
      if (INTERNAL_TAB_ID == GetNumSpellTabs()) then
        NUM_SPELL_TABS = NUM_SPELL_TABS - 1
        _G["SpellBookSkillLineTab"..INTERNAL_TAB_ID]:Hide()
        _G["SpellBookSkillLineTab"..INTERNAL_TAB_ID.."Flash"]:Hide()

      else
        for i = 1, GetNumSpellTabs() do
            _G["SpellBookSkillLineTab"..i]:SetScript("OnClick", function(self)
                SpellBookSkillLineTab_OnClick(_G["SpellBookSkillLineTab"..i])
            end);
        end

        local name, texture = GetSpellTabInfo(GetNumSpellTabs())
        _G["SpellBookSkillLineTab"..INTERNAL_TAB_ID]:SetNormalTexture(texture)
        _G["SpellBookSkillLineTab"..INTERNAL_TAB_ID].tooltip = name
        _G["SpellBookSkillLineTab"..INTERNAL_TAB_ID]:SetScript("OnClick", function(self)
            SpellBookSkillLineTab_OnClick(_G["SpellBookSkillLineTab"..GetNumSpellTabs()])
        end)

        _G["SpellBookSkillLineTab"..GetNumSpellTabs()]:Hide()
        _G["SpellBookSkillLineTab"..GetNumSpellTabs().."Flash"]:Hide()
        NUM_SPELL_TABS = NUM_SPELL_TABS - 1
      end
  end

  --clear book before loading pages
  for i = 1, 29 do 
    if (_G["SpellBookSkillLineTab"..i]) then
        _G["SpellBookSkillLineTab"..i]:Hide()
    end
  end
    -- loading pages
  for i = pagestart, pagemax do
    if  (i <= NUM_SPELL_TABS) then
        _G["SpellBookSkillLineTab"..i]:Show()
    end
  end
  
  if (skilltab_pagenum > 1) then
    for i=pagestart-7, pagemax-7 do
      if (_G["SpellBookSkillLineTab"..i.."Flash"]) then
        _G["SpellBookSkillLineTab"..i.."Flash"]:Hide();
      end
    end
  end
  
end

function Asc_SpellBookFrame_SetTabType(tabButton, bookType, token)
    if ( bookType == BOOKTYPE_SPELL ) then
        tabButton.bookType = BOOKTYPE_SPELL;
        tabButton:SetText(SPELLBOOK);
        tabButton:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 1);
        tabButton.binding = "TOGGLESPELLBOOK";
    elseif ( bookType == BOOKTYPE_PET ) then
        tabButton.bookType = BOOKTYPE_PET;
        tabButton:SetText(COMBATLOG_FILTER_STRING_MY_PET);
        tabButton:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 1);
        tabButton.binding = "TOGGLEPETBOOK";
        SpellBookFrame.petTitle = COMBATLOG_FILTER_STRING_MY_PET;
    else
        tabButton.bookType = INSCRIPTION;
        tabButton:SetText(GLYPHS);
        tabButton:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 2);
        tabButton.binding = "TOGGLEINSCRIPTION";
    end
    if ( SpellBookFrame.bookType == bookType ) then
        tabButton:Disable();
    else
        tabButton:Enable();
    end
    tabButton:Show();
end

SpellBookFrame_SetTabType = Asc_SpellBookFrame_SetTabType