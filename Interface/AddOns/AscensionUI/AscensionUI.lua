local Addon = select(2, ...)
AscensionUI = Addon -- make this accessible from other addons. There is useful stuff in here for devs.


-- Module based UI framework. Intented to move stuff to load on demand later. 
-- Allows initialization stuff to have access to db / char db which is super useful. 
Addon.Modules = {}

function Addon:AddModule(name, tbl)
	Addon.Modules[name] = tbl or {}
	return Addon.Modules[name]
end

local function LoadModule(name, tbl)
	tbl.db = AscesnionUI.DB[name]
	tbl.cdb = AscensionUI.CDB[name]
	if tbl.Init then
		tbl:Init()
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event)
	if not AscensionUI_DB then AscensionUI_DB = {} end

	if not AscensionUI_CDB then AscensionUI_CDB = {} end

	AscensionUI.DB = AscensionUI_DB
	AscensionUI.CDB = AscensionUI_CDB

	for name, tbl in pairs(Addon.Modules) do 
		LoadModule(name, tbl)
	end
end)

local bloodForgedExclusions = {
	[14948] = true, 
	[14949] = true, 
	[14950] = true, 
	[14951] = true, 
	[14952] = true, 
	[14953] = true, 
	[14954] = true, 
	[14955] = true, 
	[14956] = true, 
	[30986] = true
}
-------------------------------------------------------------------------------
--                                  Char Frame Edits                         --
-------------------------------------------------------------------------------
function SetCharacterItemValuesUI()
	local totalIlvl = 0
	totalPVE = 0
	totalPVP = 0
	local mainHandEquipLoc, offHandEquipLoc
	local unit = "player"
	local numSlots = 15

	if (CharFrameNewPartFrame0_secTextFrame1) then CharFrameNewPartFrame0_secTextFrame1:Hide() end

	if (CharFrameNewPartFrame1TextFrame1) then
		CharFrameNewPartFrame1TextFrame1:Hide()
		CharFrameNewPartFrame1TextFrame2:Hide()
	end

	for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		local id = GetInventoryItemID("player", slot)
		if id then
			local name, _, _, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(id)
			if slot ~= INVSLOT_BODY and slot ~= INVSLOT_TABARD and slot ~= INVSLOT_RANGED and slot ~= INVSLOT_OFFHAND then totalIlvl = totalIlvl + itemLevel end

			local allStats = GetItemStats(GetInventoryItemLink("player", slot))
			local resilience = allStats["ITEM_MOD_RESILIENCE_RATING_SHORT"] or 0

			if slot == INVSLOT_HEAD or slot == INVSLOT_CHEST or slot == INVSLOT_LEGS then
				if string.find(name, "^Bloodforged") and bloodForgedExclusions[id] ~= true and itemLevel >= 51 then
					totalPVP = totalPVP + 24
				elseif resilience ~= 0 and itemLevel >= 51 then
					totalPVP = totalPVP + 42
				elseif itemLevel >= 45 then
					totalPVE = totalPVE + 45
				end
			elseif slot == INVSLOT_SHOULDER or slot == INVSLOT_FEET or slot == INVSLOT_HAND or slot == INVSLOT_WAIST then
				if string.find(name, "^Bloodforged") and bloodForgedExclusions[id] ~= true and itemLevel >= 51 then
					totalPVP = totalPVP + 18
				elseif resilience ~= 0 and itemLevel >= 51 then
					totalPVP = totalPVP + 36
				elseif itemLevel >= 45 then
					totalPVE = totalPVE + 30
				end
			elseif slot == INVSLOT_WRIST then
				if string.find(name, "^Bloodforged") and bloodForgedExclusions[id] ~= true and itemLevel >= 51 then
					totalPVP = totalPVP + 15
				elseif resilience ~= 0 and itemLevel >= 51 then
					totalPVP = totalPVP + 30
				elseif itemLevel >= 45 then
					totalPVE = totalPVE + 24
				end
			elseif slot == INVSLOT_NECK or slot == INVSLOT_BACK or slot == INVSLOT_FINGER1 or slot == INVSLOT_FINGER2 or slot == INVSLOT_TRINKET1 or slot == INVSLOT_TRINKET2 then
				if string.find(name, "^Bloodforged") and bloodForgedExclusions[id] ~= true and itemLevel >= 51 then
					totalPVP = totalPVP + 12
				elseif resilience ~= 0 and itemLevel >= 51 then
					totalPVP = totalPVP + 18
				elseif itemLevel >= 45 then
					totalPVE = totalPVE + 24
				end
			elseif slot == INVSLOT_RANGED or slot == INVSLOT_OFFHAND then
				if string.find(name, "^Bloodforged") and bloodForgedExclusions[id] ~= true and itemLevel >= 51 then
					totalPVP = totalPVP + 12
				elseif resilience ~= 0 and itemLevel >= 51 then
					totalPVP = totalPVP + 24
				elseif itemLevel >= 45 then
					totalPVE = totalPVE + 24
				end
			elseif slot == INVSLOT_MAINHAND then
				if string.find(name, "^Bloodforged") and bloodForgedExclusions[id] ~= true and itemLevel >= 51 then
					if itemEquipLoc == "INVTYPE_2HWEAPON" and itemLevel >= 51 then
						totalPVP = totalPVP + 24
					elseif itemLevel >= 51 then
						totalPVP = totalPVP + 12
					end
				elseif resilience ~= 0 then
					if itemEquipLoc == "INVTYPE_2HWEAPON" and itemLevel >= 51 then
						totalPVP = totalPVP + 48
					elseif itemLevel >= 51 then
						totalPVP = totalPVP + 24
					end
				else
					if itemEquipLoc == "INVTYPE_2HWEAPON" and itemLevel >= 45 then
						totalPVE = totalPVE + 45
					elseif itemLevel >= 45 then
						totalPVE = totalPVE + 24
					end
				end
			end
		end
	end

	avgIlvl = math.floor(totalIlvl / numSlots)
	AvgIlvlFrameValue:SetText(avgIlvl)
	AvgIlvlFramePVPValue:SetText(totalPVP)
	AvgIlvlFramePVEValue:SetText(totalPVE)

	CharFrameNewPartBackMainButton:HookScript('OnClick', UIHide)
	CharFrameNewPart_EnchantsBackMainButton:HookScript('OnClick', UIShow)
end

function UIHide()
	AvgIlvlFrameStatIlvlValue:Hide()
	AvgIlvlFrameStatPVPText:Hide()
	AvgIlvlFrameStatPVPValue:Hide()
	AvgIlvlFrameStatPVEText:Hide()
	AvgIlvlFrameStatPVEValue:Hide()
end

function UIShow()
	AvgIlvlFrameStatIlvlValue:Show()
	AvgIlvlFrameStatPVPText:Show()
	AvgIlvlFrameStatPVPValue:Show()
	AvgIlvlFrameStatPVEText:Show()
	AvgIlvlFrameStatPVEValue:Show()
	-- /run AvgIlvlFrameStatIlvlValue:Show();AvgIlvlFrameStatPVPText:Show();AvgIlvlFrameStatPVPValue:Show();AvgIlvlFrameStatPVEText:Show();AvgIlvlFrameStatPVEValue:Show()
end

CharacterFrame:HookScript("OnShow", SetCharacterItemValuesUI)

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function() SetCharacterItemValuesUI() end)
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

function ItemlevelTooltipShow(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText("Niveau d'objet Moyen", 1, 1, 1)
	GameTooltip:AddLine("Votre Niveau d'objet Moyen est : |cffFFFFFF" .. avgIlvl .. "|r", 1.0, 0.82, 0.0)
	GameTooltip:Show()
end

function PVPTooltipShow(self)
	local pvpPowerCap = 495
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText("Puissance JcJ: " .. totalPVP .. "/" .. pvpPowerCap, 1, 1, 1)
	GameTooltip:AddLine("Augmente les dégâts contre les joueurs au niveau maximum de: |cffFFFFFF" .. (totalPVP * 0.05) .. "%|r.", 1.0, 0.82, 0.0)
	GameTooltip:Show()
end

function PVETooltipShow(self)
	local pvePowerCap = 495
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText("Puissance JcE: " .. totalPVE .. "/" .. pvePowerCap, 1, 1, 1)
	GameTooltip:AddLine("Augmente les dégâts contre les créatures au niveau maximum de: |cffFFFFFF" .. (totalPVE * 0.05) .. "%|r.")
	GameTooltip:AddLine("Réduit les dégâts subis par les créatures au niveau maximum de: |cffFFFFFF" .. (totalPVE * 0.05) .. "%|r")
	GameTooltip:AddLine("Augmente les soins prodigués et l'absorption dans les instances au niveau maximum de: |cffFFFFFF" .. (totalPVE * 0.05) .. "%|r.")
	GameTooltip:Show()
end

function ToolTipHide(self) GameTooltip:Hide() end

-- Frame Fader Functions
Addon.FramesToFade = {}
function Addon:BaseFrameFade(frame, dir)
	if not frame then return end

	frame.FadeTimer = 0
	if frame.time then
		frame.TimeToFade = frame.time
	else
		frame.TimeToFade = 3
	end

	frame.FadeMode = dir
	tinsert(Addon.FramesToFade, frame)
end

function Addon:BaseFrameFadeIn(frame)
	self:BaseFrameFade(frame, "IN")
	frame:Show()
end

function Addon:BaseFrameFadeOut(frame) self:BaseFrameFade(frame, "OUT") end

local fader = CreateFrame("Frame")
fader:SetScript("OnUpdate", function(self, dt)
	for i, frame in ipairs(Addon.FramesToFade) do
		frame.FadeTimer = frame.FadeTimer + dt
		if frame.FadeTimer < frame.TimeToFade then
			if frame.FadeMode == "IN" then
				frame:SetAlpha(frame.FadeTimer / frame.TimeToFade)
			elseif frame.FadeMode == "OUT" then
				frame:SetAlpha((frame.TimeToFade - frame.FadeTimer) / frame.TimeToFade)
			end
		else
			if frame.FadeMode == "IN" then
				frame:SetAlpha(1)
			elseif frame.FadeMode == "OUT" then
				frame:SetAlpha(0)
				frame:Hide()
			end
			tremove(Addon.FramesToFade, i)
		end
	end
end)

-- Arena Related UI Changes (@robinsch)
ARENA_TEAM_5V5 = "1v1 Arena Team";
StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] = {
	text = CONFIRM_BATTLEFIELD_ENTRY,
	button1 = ENTER_BATTLE,
	button2 = LEAVE_QUEUE,
	OnShow = function(self, data)
		local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, registeredMatch = GetBattlefieldStatus(data);
		if (teamSize == 0) then
			self.button2:Enable();
		else
			self.button2:Disable();
		end
		-- Rated Match (1v1)
		if (registeredMatch and teamSize == 1) then self.text:SetText("Vous êtes maintenant éligible pour participer à un match classé (1v1), choisissez une action:") end
		-- Wargames
		if (registeredMatch == nil and instanceID == 0) then
			self.button1:SetText("Accepter");
			self.button2:SetText("Refuser");
			self.button2:Enable();
			self.text:SetText(string.format("Votre groupe a été défié dans un WarGame début dans |cffe6cc80%s|h", mapName))
		end
	end,
	OnAccept = function(self, data)
		if (not AcceptBattlefieldPort(data, 1)) then return 1; end
		if (StaticPopup_Visible("DEATH")) then StaticPopup_Hide("DEATH"); end
	end,
	OnCancel = function(self, data) if (not AcceptBattlefieldPort(data, 0)) then return 1; end end,
	OnUpdate = function(self, elapsed)
		if (UnitAffectingCombat("player")) then
			self.button1:Disable();
		else
			self.button1:Enable();
		end
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	noCancelOnEscape = 1,
	noCancelOnReuse = 1,
	multiple = 1,
	closeButton = 1,
	closeButtonIsHide = 1
};

-- @robinsch: Arena Tab in PvP Frame needs to receive SMSG_BATTLEFIELD_LIST in order to allow client
-- to queue for arena when using JoinBattlefield
_G["PVPParentFrameTab3"]:SetScript("OnClick", function(self, ...)
	GetBattlefieldList(6, 0, 0)
	ArenaFrameTab3:Click()
end);

-- @robinsch: Somehow Tab3 disappears when PVPFrame.lua:PVPFrame_SetJustBG(true) is called once
-- just make it reappear when tabs are shown in PVPParentFrame
_G["PVPParentFrameTab1"]:HookScript("OnShow", function(self, button) _G["PVPParentFrameTab3"]:Show() end);

ArenaFrame.activeTab = 3
PanelTemplates_SetNumTabs(ArenaFrame, 3)

ArenaFrameTab1 = CreateFrame("Button", "ArenaFrameTab1", ArenaFrame, "CharacterFrameTabButtonTemplate")
ArenaFrameTab1:SetPoint("BOTTOMLEFT", 11, 46)
ArenaFrameTab1:SetText("PvP")
ArenaFrameTab1.id = 1
ArenaFrameTab1:SetScript("OnClick", function(self)
	ArenaFrame:Hide()
	PVPParentFrame:Show()
	PVPParentFrameTab1:Click()
end)

ArenaFrameTab2 = CreateFrame("Button", "ArenaFrameTab2", ArenaFrame, "CharacterFrameTabButtonTemplate")
ArenaFrameTab2:SetPoint("LEFT", ArenaFrameTab1, "RIGHT", -15, 0)
ArenaFrameTab2:SetText("Battlegrounds")
ArenaFrameTab2.id = 2
ArenaFrameTab2:SetScript("OnClick", function(self)
	ArenaFrame:Hide()
	PVPParentFrame:Show()
	PVPParentFrameTab2:Click()
end)

ArenaFrameTab3 = CreateFrame("Button", "ArenaFrameTab3", ArenaFrame, "CharacterFrameTabButtonTemplate")
ArenaFrameTab3:SetPoint("LEFT", ArenaFrameTab2, "RIGHT", -15, 0)
ArenaFrameTab3:SetText("Arenas")
ArenaFrameTab3.id = 3
ArenaFrameTab3:SetScript("OnClick", function(self)
	PanelTemplates_SetTab(ArenaFrame, 3)
	ArenaFrameJoinButton:SetFrameLevel(ArenaFrameTab3:GetFrameLevel() + 1)
end)

