local Addon = select(2, ...)

local Collection = CreateFrame("FRAME", "SeasonCollection", CollectionController, nil)
Addon.SeasonalCollection = Collection
Collection:Hide()
-- compatability, clean me up later 
SeasonalCollectionFrame = Collection

-------------------------------------------------------------------------------
--                               Strings                                     --
-------------------------------------------------------------------------------
local TAB_TITLE_TEXT = "Collection saisonnière"
local SEASON_TITLE_TEXT = "Ascension Reborn : Saison 7"

local MAIN_DESCRIPTION_TITLE = "Mode Draft"
local MAIN_DESCRIPTION_TEXT = "Le Mode Draft est une nouvelle façon de jouer! Vos capacités sont choisies celons une liste établie pour le mode draft et à chaque niveau à partir du niveau 10, il existe des récompenses exclusives pour les joueurs du mode draft!"

local MAIN_DESCRIPTION2_TITLE = "Points saisonniers"
local MAIN_DESCRIPTION2_TEXT = "Les points saisonniers sont une forme de progression au sein de la saison. Les points saisonniers débloquent des récompenses cosmétiques dans la collection de cosmétiques, également disponibles sur les royaumes principaux!"

local NON_SEASON_TEXT = "Suivez vos progrès avec la collection saisonnière ! Ici, vous pouvez trouver un aperçu de votre progression sur les royaumes saisonniers de Ascension.\n Vous n'êtes pas actuellement dans un royaume saisonnier, mais restez au courant des dernières nouvelles d'Ascension pour savoir quand la prochaine saison commencera. Une fois cela fait, cet onglet suivra vos progrès à mesure que vous découvrirez de nouvelles façons passionnantes de jouer! Les royaumes saisonniers de Ascension offrent un défi unique aux nouveaux joueurs et aux vétérans, et sont un excellent moyen de repartir à neuf et de s'attaquer à Ascension!\n Les royaumes saisonniers sont utilisés pour tester de nouvelles fonctionnalités sur Ascension que nous pouvons ramener dans nos royaumes principaux. À la fin de chaque saison, les personnages sont transférés vers les royaumes principaux."
local NON_SEASON_TITLE = "Royaumes non saisonniers"

local SEASON_POINT_COUNTER_FORMAT = "Points cette saison: |cffFFFFFF%d|r/|cffFFFFFF%d|r."
local SEASON_POINT_COUNTER_SHORT_FORMAT = "Points cette saison: |cffFFFFFF%d|r"
local SEASON_RATING_COUNTER_FORMAT = "Cote saisonnière: |cffFFFFFF%d|r."

-------------------------------------------------------------------------------
--                               Config Values                               --
-------------------------------------------------------------------------------
local MAX_POINTS_SEASON = 0
local CosmeticRewards = {
	-- {"Creature/shadowstalkerpanthermount/shadowstalkerpanthermount.m2", true, "Chaotic Runesaber", "  Chaotic Runesaber. Reward for playing wildcard mode.", "Interface\\icons\\inv_shadowstalkerpanthermount", {-1.1, 0.12, 0}, -4.3, 1.1},
	-- {"Creature/FlyingBook/FlyingBook_01_Pet_glad.m2", true, "Ruthless Book of Ascension", "  Seasonal Supporter Bundle Exclusive Book. Train all class abilities from anywhere.", "Interface\\icons\\inv_custom_trainerBook", {0, 0, -0.02}, 0.7, 1.1},
	-- {"Creature/shadowstalkerpantherpet/shadowstalkerpantherpet.m2", true, "Chaotic Saber Cub", " Chaotic Saber Cub. Reward for playing wildcard mode.", "Interface\\icons\\inv_shadowstalkerpantherpet", {0.0, 0.05, -0.16}, 0.7, 0.6},
	{"Creature/crawlinghandpet/crawlinghandpet.m2", true, "Griffe rampante", "Griffe rampante. Récompense pour avoir joué en mode Draft.", "Interface\\icons\\Inv_offhand_stratholme_a_02", {0, 0.15, -0.35}, 0.7, 1.2},
	{"Creature/FlyingBook/FlyingBook_01_Pet_drm.m2", true, "Livre d'Ascension rédigé", "  Livre exclusif du lot de supporteurs saisonniers. Entraînez toutes les capacités de classe de n'importe où.","Interface\\icons\\inv_custom_trainerBook", {0, 0, -0.02}, 0.7, 1.1}
}

local CurrentCosmeticReward = 1
local BigChallenges = {
	16718, -- Seasonal: Rank 1
	16719, -- Seasonal: Rank 2
	16720, -- Seasonal: Rank 3
	16721, -- Seasonal: Rank 4
	16722, -- Seasonal: Rank 5
	16723, -- Seasonal: Rank 6
	16724 -- Seasonal: Rank 7
}
local Features = {}
local SpecialRewards = {}
local TotalBigChallenges = #BigChallenges
local MaxSmallChallenges = 16
local SeasonalPoints = 0
local CurrentBigChallenge = 1
local Model_Costil = 0
--[[local TEMP_LevelRange_Challenges = {
  [1] = {1, 20},
  [2] = {21, 30},
  [3] = {31, 40},
  [4] = {41, 50},
  [5] = {51, 58},
  [6] = {59, 60}, 
  [7] = {61, 61}, 
}]] --
local CompletedAchievements = {}
local Progress = 0

local IsSeasonalRealm = GetRealmName():find("Season")
-------------------------------------------------------------------------------
--                                   AIO                                     --
-------------------------------------------------------------------------------


local function RewardPoints(achievementID)
	-- SeasonalPoints = SeasonalPoints + 1
	-- Collection.SeasonalPointsFrame.SPCounter:SetText(SeasonalPoints)
	Collection:LoadChallenges()
end

local function UpdatePoints(TotalPoints, PointsThisSeason)
	SeasonalPoints = TotalPoints
	Collection.SeasonalPointsFrame.SPCounter:SetText(format(SEASON_POINT_COUNTER_SHORT_FORMAT, SeasonalPoints))
	Collection.SeasonalPointsFrame_Total.SPCounter:SetText(format(SEASON_RATING_COUNTER_FORMAT, TotalPoints))
end

-------------------------------------------------------------------------------
--                              UI Functions                                 --
-------------------------------------------------------------------------------
Collection:SetScript("OnShow", function(self)
	
	self:InitProgressBar()

	self:SetUpProgressBar()
	self:LoadChallenges()

	self:LoadSeasonDescriptions()

	for _, achievementId in ipairs(BigChallenges) do 
		local _, _, _, completed = GetAchievementInfo(achievementId)
		CompletedAchievements[achievementId] = completed
	end
end)

function Collection:SetActiveBigChallenge()
	for i = 1, TotalBigChallenges do 
		Collection.BigChallenges["Frame"..i].Current:Hide() 
	end
	Collection.BigChallenges["Frame" .. CurrentBigChallenge].Current.AnimationGroup:Stop()
	Collection.BigChallenges["Frame" .. CurrentBigChallenge].Current.AnimationGroup:Play()
end

function Collection:LoadSeasonDescriptions()
	Collection.DescriptionMain.AnimTex.AnimationGroup:Play()
	Collection.DescriptionMain.AnimTexSub.AnimationGroup:Play()
end

function Collection:LoadProgress()
	for i = 1, (TotalBigChallenges - 1) do Collection.BigChallenges["Frame"..i].ProgessBar:SetValue(0) end

	if (Progress > 0) then for i = 1, Progress do if not (i == TotalBigChallenges) then Collection.BigChallenges["Frame"..i].ProgessBar:SetValue(1) end end end
end

function Collection:SetUpProgressBar()
	Progress = 0
	for i = 1, TotalBigChallenges do
		local _, name, _, completed, _, _, _, description, _, icon = GetAchievementInfo(BigChallenges[i])
		Collection.BigChallenges["Frame"..i].Complete:Hide()
		Collection.BigChallenges["Frame"..i].BigGlow:Hide()

		if not (completed) and not (CompletedAchievements[BigChallenges[i]]) then
			Collection.BigChallenges["Frame"..i].Icon:SetVertexColor(0.6, 0.6, 0.6, 1)
		else
			Collection.BigChallenges["Frame"..i].Complete.AnimationGroup:Stop()
			Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup:Stop()

			Collection.BigChallenges["Frame"..i].Complete.AnimationGroup:Play()
			Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup:Play()
			Collection.BigChallenges["Frame"..i].Icon:SetVertexColor(1, 1, 1, 1)
			Progress = Progress + 1
		end

		SetPortraitToTexture(Collection.BigChallenges["Frame"..i].Icon, icon)
		Collection.BigChallenges["Frame"..i].Current:Hide()
	end

	Collection:LoadProgress()
	Collection:SetActiveBigChallenge()
end

function Collection:HideChallenge(index) -- yeah, I know, I had to make it a frame.
	local content = Collection.SmallChallengesFrame.Scroll.Content
	content["BG" .. index]:Hide()
	content["Icon" .. index]:Hide()
	content["IconBorder" .. index]:Hide()
	content["IconTextMain" .. index]:Hide()
	content["IconTextSub" .. index]:Hide()
	content["SPCounter" .. index]:Hide()
	content["SPCounterBorder" .. index]:Hide()
	content["SPCounterTextMain" .. index]:Hide()
	content["CheckBox" .. index]:SetChecked(false)
	content["CheckBox" .. index]:Hide()
	content["CheckBoxText" .. index]:Hide()
	content["IconTextDate" .. index]:Hide()
end

function Collection:PlayChallengeAnim(index)
	local content = Collection.SmallChallengesFrame.Scroll.Content
	content["Icon" .. index].AnimationGroup:Stop()
	content["IconBorder" .. index].AnimationGroup:Stop()
	content["IconTextMain" .. index].AnimationGroup:Stop()
	content["IconTextSub" .. index].AnimationGroup:Stop()
	content["IconTextDate" .. index].AnimationGroup:Stop()
	content["SPCounter" .. index].AnimationGroup:Stop()
	content["SPCounterBorder" .. index].AnimationGroup:Stop()
	content["SPCounterTextMain" .. index].AnimationGroup:Stop()

	content["Icon" .. index].AnimationGroup:Play()
	content["IconBorder" .. index].AnimationGroup:Play()
	content["IconTextMain" .. index].AnimationGroup:Play()
	content["IconTextSub" .. index].AnimationGroup:Play()
	content["IconTextDate" .. index].AnimationGroup:Play()
	content["SPCounter" .. index].AnimationGroup:Play()
	content["SPCounterBorder" .. index].AnimationGroup:Play()
	content["SPCounterTextMain" .. index].AnimationGroup:Play()
end

function Collection:ShowChallenge(index)
	local content = Collection.SmallChallengesFrame.Scroll.Content
	content["BG" .. index]:Show()
	content["Icon" .. index]:Show()
	content["IconBorder" .. index]:Show()
	content["IconTextMain" .. index]:Show()
	content["IconTextSub" .. index]:Show()
	content["SPCounter" .. index]:Show()
	content["SPCounterBorder" .. index]:Show()
	content["SPCounterTextMain" .. index]:Show()

	Collection:PlayChallengeAnim(index)
end

function Collection:SetChallengeCompleted(index, date)
	local content = Collection.SmallChallengesFrame.Scroll.Content
	content["Icon" .. index]:SetVertexColor(1, 1, 1, 1)
	content["IconTextMain" .. index]:SetVertexColor(1, 1, 1, 1)
	content["SPCounterTextMain" .. index]:SetVertexColor(1, 1, 1, 1)
	content["SPCounterBorder" .. index]:SetVertexColor(1, 1, 1, 1)

	if n then
		local month, day, year = unpack(date)
		content["IconTextDate" .. index]:Show()
		content["IconTextDate" .. index]:SetText(month .. "/" .. day .. "/" .. year)
	end

	content["BG" .. index]:SetScript("OnClick", function() end)
end

function Collection:SetChallengeInCompleted(index, id)
	local content = Collection.SmallChallengesFrame.Scroll.Content
	content["Icon" .. index]:SetVertexColor(0.6, 0.6, 0.6, 0.6)
	content["IconTextMain" .. index]:SetVertexColor(0.6, 0.6, 0.6, 0.6)
	content["SPCounterTextMain" .. index]:SetVertexColor(0.6, 0.6, 0.6, 0.6)
	content["SPCounterBorder" .. index]:SetVertexColor(0.6, 0.6, 0.6, 0.3)
	content["CheckBox" .. index].Achievement = id

	if (IsTrackedAchievement(id)) then 
		content["CheckBox" .. index]:SetChecked(true) 
	end

	content["BG" .. index]:SetScript("OnClick", function(self)
		local content = self:GetParent()
		if (content["CheckBox" .. index]:IsVisible()) then
			content["CheckBox" .. index]:Hide()
			content["CheckBoxText" .. index]:Hide()
		else
			content["CheckBoxText" .. index]:Show()
			content["CheckBox" .. index]:Show()
		end
	end)
end

function Collection:SetupChallenge(index, title, completed, date, description, icon, id, SP_Reward)
	local content = Collection.SmallChallengesFrame.Scroll.Content
	content["Icon" .. index]:SetTexture(icon)
	--content["Icon"..index]:SetTexture("Interface\\icons\\season1_complete")
	content["IconTextMain" .. index]:SetText(title)
	content["IconTextSub" .. index]:SetText(description)
	content["SPCounterTextMain" .. index]:SetText(SP_Reward)
	if (completed) or CompletedAchievements[id] then
		Collection:SetChallengeCompleted(index, date)
	else
		Collection:SetChallengeInCompleted(index, id)
	end
end

function Collection:HideBIGChallenge()
	local content_fake = Collection.SmallChallengesFrame.Scroll.Content_fake
	content_fake.IconBG_BIG:Hide()
	content_fake.BG_BIGChallenge:Hide()
	content_fake.Icon_BIGChallenge:Hide()
	content_fake.IconBorder_BIGChallenge:Hide()
	content_fake.IconTextMain_BIGChallenge:Hide()
	content_fake.IconTextSub_BIGChallenge:Hide()
	content_fake.IconTextDate_BIGChallenge:Hide()
	content_fake.CheckBox_BIGChallenge:Hide()
	content_fake.CheckBoxText_BIGChallenge:Hide()
	content_fake.SPCounter_BIG:Hide()
	content_fake.SPCounterBorder_BIG:Hide()
	content_fake.SPCounterReward_BIG:Hide()
end

function Collection:SetupBIGChallenge(index)
	local content_fake = Collection.SmallChallengesFrame.Scroll.Content_fake
	content_fake.IconBG_BIG:SetPoint("TOPRIGHT", 35, 32 - 60 * index)
	content_fake.BG_BIGChallenge:SetPoint("TOP", 0, -3 - 60 * index)
	content_fake.Icon_BIGChallenge:SetPoint("TOPLEFT", 10, -12 - 60 * index)
	content_fake.IconBorder_BIGChallenge:SetPoint("TOPLEFT", 10, -12 - 60 * index)
	content_fake.IconTextMain_BIGChallenge:SetPoint("TOP", 0, -2 - 60 * index)
	content_fake.IconTextSub_BIGChallenge:SetPoint("TOP", 0, -35 - 60 * index)
	content_fake.IconTextDate_BIGChallenge:SetPoint("TOPRIGHT", -10, -50 - 60 * index)
	content_fake.CheckBox_BIGChallenge:SetPoint("TOPRIGHT", -03, -45 - 60 * index)
	content_fake.CheckBoxText_BIGChallenge:SetPoint("TOPRIGHT", -25, -50 - 60 * index)
	content_fake.SPCounter_BIG:SetPoint("TOPRIGHT", -10, -12 - 60 * index)
	content_fake.SPCounterBorder_BIG:SetPoint("TOPRIGHT", -10, -12 - 60 * index)
	content_fake.SPCounterReward_BIG:SetPoint("TOPRIGHT", -26, -29 - 60 * index)

	content_fake.IconBG_BIG.AnimationGroup.Rotation:SetStartDelay(0.05 * index)
	content_fake.Icon_BIGChallenge.AnimationGroup.Rotation:SetStartDelay(0.05 * index)
	content_fake.IconBorder_BIGChallenge.AnimationGroup.Rotation:SetStartDelay(0.05 * index)
	content_fake.IconTextMain_BIGChallenge.AnimationGroup.Rotation:SetStartDelay(0.05 * index)
	content_fake.IconTextSub_BIGChallenge.AnimationGroup.Rotation:SetStartDelay(0.05 * index)
	content_fake.IconTextDate_BIGChallenge.AnimationGroup.Rotation:SetStartDelay(0.05 * index)
	content_fake.SPCounter_BIG.AnimationGroup.Rotation:SetStartDelay(0.05 * index)
	content_fake.SPCounterBorder_BIG.AnimationGroup.Rotation:SetStartDelay(0.05 * index)
	content_fake.SPCounterReward_BIG.AnimationGroup.Rotation:SetStartDelay(0.05 * index)

	content_fake.IconBG_BIG.AnimationGroup:Stop()
	content_fake.Icon_BIGChallenge.AnimationGroup:Stop()
	content_fake.IconBorder_BIGChallenge.AnimationGroup:Stop()
	content_fake.IconTextMain_BIGChallenge.AnimationGroup:Stop()
	content_fake.IconTextSub_BIGChallenge.AnimationGroup:Stop()
	content_fake.IconTextDate_BIGChallenge.AnimationGroup:Stop()
	content_fake.SPCounter_BIG.AnimationGroup:Stop()
	content_fake.SPCounterBorder_BIG.AnimationGroup:Stop()
	content_fake.SPCounterReward_BIG.AnimationGroup:Stop()

	Addon:BaseFrameFadeIn(content_fake)

	content_fake.IconBG_BIG.AnimationGroup:Play()
	content_fake.Icon_BIGChallenge.AnimationGroup:Play()
	content_fake.IconBorder_BIGChallenge.AnimationGroup:Play()
	content_fake.IconTextMain_BIGChallenge.AnimationGroup:Play()
	content_fake.IconTextSub_BIGChallenge.AnimationGroup:Play()
	content_fake.IconTextDate_BIGChallenge.AnimationGroup:Play()
	content_fake.SPCounter_BIG.AnimationGroup:Play()
	content_fake.SPCounterBorder_BIG.AnimationGroup:Play()
	content_fake.SPCounterReward_BIG.AnimationGroup:Play()

	content_fake.CheckBox_BIGChallenge:Hide()
	content_fake.CheckBoxText_BIGChallenge:Hide()
	content_fake.IconTextDate_BIGChallenge:Hide()

	local _, name, _, completed, month, day, year, description, _, icon = GetAchievementInfo(BigChallenges[CurrentBigChallenge])
	local date = {month, day, year}

	content_fake.IconTextMain_BIGChallenge:SetText(name)
	content_fake.IconTextSub_BIGChallenge:SetText(description)
	content_fake.Icon_BIGChallenge:SetTexture(icon)

	if (completed) or CompletedAchievements[BigChallenges[CurrentBigChallenge]] then
		Collection:SetBIGChallengeCompleted(date)
	else
		Collection:SetBIGChallengeInCompleted()
	end

end

function Collection:SetBIGChallengeCompleted(date)
	local content_fake = Collection.SmallChallengesFrame.Scroll.Content_fake
	content_fake.Icon_BIGChallenge:SetVertexColor(1, 1, 1, 1)
	content_fake.IconTextMain_BIGChallenge:SetVertexColor(1, 1, 1, 1)
	content_fake.SPCounterBorder_BIG:SetVertexColor(1, 1, 1, 1)
	content_fake.SPCounterReward_BIG:SetVertexColor(1, 1, 1, 1)
	content_fake.IconBG_BIG:SetVertexColor(1, 1, 1, 1)

	if next(date) then
		local month, day, year = unpack(date)
		content_fake.IconTextDate_BIGChallenge:Show()
		content_fake.IconTextDate_BIGChallenge:SetText(month .. "/" .. day .. "/" .. year)
	end
	content_fake.BG_BIGChallenge:SetScript("OnClick", function() end)
end

function Collection:SetBIGChallengeInCompleted()
	local content_fake = Collection.SmallChallengesFrame.Scroll.Content_fake
	content_fake.IconBG_BIG:SetVertexColor(0.6, 0.6, 0.6, 0.6)
	content_fake.Icon_BIGChallenge:SetVertexColor(0.6, 0.6, 0.6, 0.6)
	content_fake.IconTextMain_BIGChallenge:SetVertexColor(0.6, 0.6, 0.6, 0.6)
	content_fake.SPCounterBorder_BIG:SetVertexColor(0.6, 0.6, 0.6, 1)
	content_fake.SPCounterReward_BIG:SetVertexColor(0.6, 0.6, 0.6, 1)

	if (IsTrackedAchievement(BigChallenges[CurrentBigChallenge])) then
		content_fake.CheckBox_BIGChallenge:SetChecked(true)
	else
		content_fake.CheckBox_BIGChallenge:SetChecked(false)
	end

	content_fake.BG_BIGChallenge:SetScript("OnClick", function(self)
		local content_fake = self:GetParent()
		if (content_fake.CheckBox_BIGChallenge:IsVisible()) then
			content_fake.CheckBox_BIGChallenge:Hide()
			content_fake.CheckBoxText_BIGChallenge:Hide()
		else
			content_fake.CheckBoxText_BIGChallenge:Show()
			content_fake.CheckBox_BIGChallenge:Show()
		end
	end)
end

function Collection:LoadNoChallenges()
	local scroll = Collection.SmallChallengesFrame.Scroll
	scroll:Hide()
	scroll.Content:Hide()
	scroll.Content_fake:Hide()
	scroll.ScrollBar:Hide()
	Collection.SmallChallengesFrame.Scroll_Features:Hide()
	Collection.SmallChallengesFrame.TitleText:SetText(SEASON_TITLE_TEXT)
	Collection.SmallChallengesFrame.Scroll_Features:Show()
end

function Collection:LoadProgressInfo() 
end

function Collection:LoadChallenges()
	if not (IsSeasonalRealm) then
		Collection:LoadNoChallenges()
		return false
	end
	-- lets load it according to CurrentBigChallenge
	-- local active_challenges = BigChallenges[BigChallenges[CurrentBigChallenge]]
	local active_challenge = BigChallenges[CurrentBigChallenge]

	if not (active_challenge) then return false end

	local active_challenge_reward = BigChallenges[BigChallenges[CurrentBigChallenge]]
	local active_challenges_count = 1
	-- local minlevel, maxlevel = unpack(LevelRange)

	if ((active_challenges_count - 4) * 64) > 0 then
		Collection.SmallChallengesFrame.Scroll.ScrollUpButton:Enable()
		Collection.SmallChallengesFrame.Scroll.ScrollDownButton:Enable()
		Collection.SmallChallengesFrame.Scroll.ScrollBar:SetMinMaxValues(1, (active_challenges_count - 4) * 64)
	else
		Collection.SmallChallengesFrame.Scroll.ScrollUpButton:Disable()
		Collection.SmallChallengesFrame.Scroll.ScrollDownButton:Disable()
		Collection.SmallChallengesFrame.Scroll.ScrollBar:SetMinMaxValues(1, 1)
	end

	Collection:HideBIGChallenge()

	for i = 1, MaxSmallChallenges do 
		Collection:HideChallenge(i) 
	end

	Addon:BaseFrameFadeIn(Collection.SmallChallengesFrame.Scroll.Content)

	local _, name, _, completed, month, day, year, description, _, icon = GetAchievementInfo(active_challenge)
	local date = {month, day, year}
	Collection.SmallChallengesFrame.TitleText:SetText(name)
	Collection:ShowChallenge(1)
	Collection:SetupChallenge(1, name, completed, date, description, icon, active_challenge, active_challenge_reward)
end

-------------------------------------------------------------------------------
--                           UI Frames and buttons                           --
-------------------------------------------------------------------------------
Collection:SetSize(784, 512)
Collection:SetPoint("CENTER", 0, 0)
Collection:SetBackdrop({bgFile = "Interface\\AddOns\\AwAddons\\Textures\\Collections\\SeasonCollection", insets = {left = -120, right = -120, top = -256, bottom = -256}})
Collection:SetClampedToScreen(true)

Collection:SetScript("OnUpdate", function()
	if not (Collection.CosmeticReward:IsVisible()) then
		Model_Costil = Model_Costil + 1
		if (Model_Costil >= 5) then
			Collection.CosmeticReward:Show()
			Model_Costil = 0
		end
	end
end)

Collection.CloseButton = CreateFrame("Button", nil, Collection, "UIPanelCloseButton")
Collection.CloseButton:SetPoint("TOPRIGHT", -4, -1)
Collection.CloseButton:EnableMouse(true)
Collection.CloseButton:SetScript("OnMouseUp", function()
	PlaySound("igMainMenuClose")
	HideUIPanel(CollectionController)
end)

Collection.TitleText = Collection:CreateFontString()
Collection.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
Collection.TitleText:SetFontObject(GameFontNormal)
Collection.TitleText:SetPoint("TOP", 0, -11)
Collection.TitleText:SetShadowOffset(1, -1)
Collection.TitleText:SetText(TAB_TITLE_TEXT)

-------------------------------------------------------------------------------
--                              Model Background                             --
-------------------------------------------------------------------------------
Collection.ModelBG = CreateFrame("FRAME", nil, Collection, nil)
Collection.ModelBG:SetPoint("CENTER")
Collection.ModelBG:SetSize(Collection:GetSize())
Collection.ModelBG:SetFrameLevel(2)

Collection.ModelBG.Glow = CreateFrame("Model", nil, Collection.ModelBG)
Collection.ModelBG.Glow:SetWidth(256);
Collection.ModelBG.Glow:SetHeight(256);
Collection.ModelBG.Glow:SetPoint("BOTTOMRIGHT", 50, -40)
Collection.ModelBG.Glow:SetModel("World\\Expansion01\\doodads\\netherstorm\\crackeffects\\netherstormcracksmokegreen.m2")
Collection.ModelBG.Glow:SetModelScale(0.07)
Collection.ModelBG.Glow:SetCamera(0)
Collection.ModelBG.Glow:SetPosition(0.075, 0.09, 0)
Collection.ModelBG.Glow:SetFacing(0)
Collection.ModelBG.Glow:SetFrameLevel(2)

Collection.ModelBG.BigGlow = CreateFrame("Model", nil, Collection.ModelBG)
Collection.ModelBG.BigGlow:SetWidth(600);
Collection.ModelBG.BigGlow:SetHeight(600);
Collection.ModelBG.BigGlow:SetPoint("LEFT", 12, 120)
Collection.ModelBG.BigGlow:SetModel("World\\Kalimdor\\silithus\\passivedoodads\\ahnqirajglow\\quirajglow_green.m2")
Collection.ModelBG.BigGlow:SetModelScale(0.04)
Collection.ModelBG.BigGlow:SetCamera(0)
Collection.ModelBG.BigGlow:SetPosition(-0.020, 0.11, 0)
Collection.ModelBG.BigGlow:SetFacing(0)
Collection.ModelBG.BigGlow:SetFrameLevel(2)
Collection.ModelBG.BigGlow:SetAlpha(0.5)

-------------------------------------------------------------------------------
--                              Cosmetic Rewards                             --
-------------------------------------------------------------------------------
Collection.CosmeticReward = CreateFrame("Model", nil, Collection)
Collection.CosmeticReward:SetSize(512, 512)
Collection.CosmeticReward:SetPoint("LEFT", -160, 0)
Collection.CosmeticReward:SetFrameLevel(4)

Collection.CosmeticReward_fake = CreateFrame("Frame", nil, Collection)
Collection.CosmeticReward_fake:SetSize(256, 256)
Collection.CosmeticReward_fake:SetPoint("LEFT", 0, -100)
Collection.CosmeticReward_fake:SetFrameLevel(4)
Collection.CosmeticReward_fake:EnableMouse(true)

Collection.CosmeticReward:SetModelScale(1.2)
Collection.CosmeticReward:SetCamera(1)
Collection.CosmeticReward:SetLight(1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8);

Collection.CosmeticReward.Art = Collection.CosmeticReward:CreateTexture(nil, "ARTWORK", nil, 2)
Collection.CosmeticReward.Art:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\RewardName_Highlight")
Collection.CosmeticReward.Art:SetSize(360, 90)
Collection.CosmeticReward.Art:SetPoint("TOP", 42, -120)

Collection.CosmeticReward.Icon = Collection.CosmeticReward:CreateTexture(nil, "BORDER", nil, 2)
Collection.CosmeticReward.Icon:SetSize(22, 22)
Collection.CosmeticReward.Icon:SetPoint("TOP", -60, -141)
SetPortraitToTexture(Collection.CosmeticReward.Icon, "Interface\\icons\\inv_custom_trainerBook")

Collection.CosmeticReward.TitleText = Collection.CosmeticReward:CreateFontString()
Collection.CosmeticReward.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 11)
Collection.CosmeticReward.TitleText:SetFontObject(GameFontNormal)
Collection.CosmeticReward.TitleText:SetPoint("TOP", 30, -109)
Collection.CosmeticReward.TitleText:SetShadowOffset(1, -1)
Collection.CosmeticReward.TitleText:SetSize(360, 90)

Collection.CosmeticReward.SubText = Collection.CosmeticReward:CreateFontString()
Collection.CosmeticReward.SubText:SetFont("Fonts\\FRIZQT__.TTF", 11)
Collection.CosmeticReward.SubText:SetFontObject(GameFontHighlight)
Collection.CosmeticReward.SubText:SetPoint("TOP", 40, -169)
Collection.CosmeticReward.SubText:SetShadowOffset(1, -1)
Collection.CosmeticReward.SubText:SetSize(200, 128)
Collection.CosmeticReward.SubText:SetJustifyH("LEFT")
Collection.CosmeticReward.SubText:SetJustifyV("TOP")

Collection.CosmeticReward.Art.AnimationGroup = Collection.CosmeticReward.Art:CreateAnimationGroup()

Collection.CosmeticReward.Art.AnimationGroup.Alpha_Init = Collection.CosmeticReward.Art.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.Art.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.CosmeticReward.Art.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.CosmeticReward.Art.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.CosmeticReward.Art.AnimationGroup.Alpha_FadeIn = Collection.CosmeticReward.Art.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.Art.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.CosmeticReward.Art.AnimationGroup.Alpha_FadeIn:SetDuration(0.6)
Collection.CosmeticReward.Art.AnimationGroup.Alpha_FadeIn:SetOrder(2)
Collection.CosmeticReward.Art.AnimationGroup.Alpha_FadeIn:SetStartDelay(0.5)
Collection.CosmeticReward.Icon.AnimationGroup = Collection.CosmeticReward.Icon:CreateAnimationGroup()

Collection.CosmeticReward.Icon.AnimationGroup.Alpha_Init = Collection.CosmeticReward.Icon.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.Icon.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.CosmeticReward.Icon.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.CosmeticReward.Icon.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.CosmeticReward.Icon.AnimationGroup.Alpha_FadeIn = Collection.CosmeticReward.Icon.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.Icon.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.CosmeticReward.Icon.AnimationGroup.Alpha_FadeIn:SetDuration(0.6)
Collection.CosmeticReward.Icon.AnimationGroup.Alpha_FadeIn:SetOrder(2)
Collection.CosmeticReward.Icon.AnimationGroup.Alpha_FadeIn:SetStartDelay(0.5)
Collection.CosmeticReward.TitleText.AnimationGroup = Collection.CosmeticReward.TitleText:CreateAnimationGroup()

Collection.CosmeticReward.TitleText.AnimationGroup.Alpha_Init = Collection.CosmeticReward.TitleText.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.TitleText.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.CosmeticReward.TitleText.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.CosmeticReward.TitleText.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.CosmeticReward.TitleText.AnimationGroup.Alpha_FadeIn = Collection.CosmeticReward.TitleText.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.TitleText.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.CosmeticReward.TitleText.AnimationGroup.Alpha_FadeIn:SetDuration(0.6)
Collection.CosmeticReward.TitleText.AnimationGroup.Alpha_FadeIn:SetOrder(2)
Collection.CosmeticReward.TitleText.AnimationGroup.Alpha_FadeIn:SetStartDelay(0.5)
Collection.CosmeticReward.SubText.AnimationGroup = Collection.CosmeticReward.SubText:CreateAnimationGroup()

Collection.CosmeticReward.SubText.AnimationGroup.Alpha_Init = Collection.CosmeticReward.SubText.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.SubText.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.CosmeticReward.SubText.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.CosmeticReward.SubText.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.CosmeticReward.SubText.AnimationGroup.Alpha_FadeIn = Collection.CosmeticReward.SubText.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.SubText.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.CosmeticReward.SubText.AnimationGroup.Alpha_FadeIn:SetDuration(0.6)
Collection.CosmeticReward.SubText.AnimationGroup.Alpha_FadeIn:SetOrder(2)
Collection.CosmeticReward.SubText.AnimationGroup.Alpha_FadeIn:SetStartDelay(0.5)
Collection.CosmeticReward.AnimTex = Collection.CosmeticReward:CreateTexture(nil, "BACKGROUND")
Collection.CosmeticReward.AnimTex:SetTexture("Interface\\Addons\\AwAddons\\Textures\\SpellKit\\Talent_Bg_animTex")
Collection.CosmeticReward.AnimTex:SetSize(496, 60)
Collection.CosmeticReward.AnimTex:SetPoint("TOP", 30, -118)
Collection.CosmeticReward.AnimTex:SetBlendMode("ADD")
Collection.CosmeticReward.AnimTex:SetAlpha(0)

Collection.CosmeticReward.AnimTex_Add = Collection.CosmeticReward:CreateTexture(nil, "OVERLAY")
Collection.CosmeticReward.AnimTex_Add:SetTexture("Interface\\Addons\\AwAddons\\Textures\\SpellKit\\Talent_Bg_animTex")
Collection.CosmeticReward.AnimTex_Add:SetSize(68, 5)
Collection.CosmeticReward.AnimTex_Add:SetPoint("TOP", 30, -158)
Collection.CosmeticReward.AnimTex_Add:SetBlendMode("ADD")
Collection.CosmeticReward.AnimTex_Add:SetAlpha(0)

Collection.CosmeticReward.AnimTex_Add.AnimationGroup = Collection.CosmeticReward.AnimTex_Add:CreateAnimationGroup()

Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Alpha_Init = Collection.CosmeticReward.AnimTex_Add.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Translation_Init = Collection.CosmeticReward.AnimTex_Add.AnimationGroup:CreateAnimation("Translation")
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Translation_Init:SetOffset(-50, 0)
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Translation_Init:SetDuration(0)
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Translation_Init:SetOrder(1)

Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Alpha_FadeIn = Collection.CosmeticReward.AnimTex_Add.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Alpha_FadeIn:SetDuration(1.5)
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Alpha_FadeIn:SetOrder(2)

Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Translation = Collection.CosmeticReward.AnimTex_Add.AnimationGroup:CreateAnimation("Translation")
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Translation:SetOffset(150, 0)
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Translation:SetDuration(3)
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Translation:SetSmoothing("IN")
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Translation:SetOrder(2)

Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Alpha_FadeOut = Collection.CosmeticReward.AnimTex_Add.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Alpha_FadeOut:SetChange(-1)
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Alpha_FadeOut:SetDuration(0.6)
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Alpha_FadeOut:SetOrder(2)
Collection.CosmeticReward.AnimTex_Add.AnimationGroup.Alpha_FadeOut:SetStartDelay(1.5)

Collection.CosmeticReward.Art:Hide()
Collection.CosmeticReward.Icon:Hide()
Collection.CosmeticReward.TitleText:Hide()
Collection.CosmeticReward.SubText:Hide()
Collection.CosmeticReward.AnimTex:Hide()

Collection.CosmeticReward.AnimTex.AnimationGroup = Collection.CosmeticReward.AnimTex:CreateAnimationGroup()
Collection.CosmeticReward.AnimTex.AnimationGroup:SetScript("OnPlay", function()
	Collection.CosmeticReward.Art:Show()
	Collection.CosmeticReward.Icon:Show()
	Collection.CosmeticReward.TitleText:Show()
	Collection.CosmeticReward.SubText:Show()
	Collection.CosmeticReward.AnimTex:Show()

	Collection.CosmeticReward.Art.AnimationGroup:Play()
	Collection.CosmeticReward.Icon.AnimationGroup:Play()
	Collection.CosmeticReward.TitleText.AnimationGroup:Play()
	Collection.CosmeticReward.SubText.AnimationGroup:Play()
	Collection.CosmeticReward.AnimTex.AnimationGroup:Play()
end)

Collection.CosmeticReward.AnimTex.AnimationGroup.Alpha_Init = Collection.CosmeticReward.AnimTex.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.AnimTex.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.CosmeticReward.AnimTex.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.CosmeticReward.AnimTex.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.CosmeticReward.AnimTex.AnimationGroup.Alpha_FadeIn = Collection.CosmeticReward.AnimTex.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.AnimTex.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.CosmeticReward.AnimTex.AnimationGroup.Alpha_FadeIn:SetDuration(0.4)
Collection.CosmeticReward.AnimTex.AnimationGroup.Alpha_FadeIn:SetOrder(2)

Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_Init = Collection.CosmeticReward.AnimTex.AnimationGroup:CreateAnimation("Scale")
Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_Init:SetScale(0.001, 1.0)
Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_Init:SetDuration(0.0)
Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_Init:SetStartDelay(0)
Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_Init:SetOrder(1)

Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_FadeIn = Collection.CosmeticReward.AnimTex.AnimationGroup:CreateAnimation("Scale")
Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_FadeIn:SetScale(1000.0, 1.0)
Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_FadeIn:SetDuration(0.5)
Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_FadeIn:SetOrder(2)
Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_FadeIn:SetEndDelay(0.2)

Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_FadeOut = Collection.CosmeticReward.AnimTex.AnimationGroup:CreateAnimation("Scale")
Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_FadeOut:SetScale(0.1, 1.0)
Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_FadeOut:SetDuration(1.5)
Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_FadeOut:SetOrder(3)
Collection.CosmeticReward.AnimTex.AnimationGroup.Grow_FadeOut:SetScript("OnPlay", function() Collection.CosmeticReward.AnimTex_Add.AnimationGroup:Play() end)

Collection.CosmeticReward.AnimTex.AnimationGroup.Alpha_FadeOut = Collection.CosmeticReward.AnimTex.AnimationGroup:CreateAnimation("Alpha")
Collection.CosmeticReward.AnimTex.AnimationGroup.Alpha_FadeOut:SetChange(-1)
Collection.CosmeticReward.AnimTex.AnimationGroup.Alpha_FadeOut:SetStartDelay(0.2)
Collection.CosmeticReward.AnimTex.AnimationGroup.Alpha_FadeOut:SetDuration(1)
Collection.CosmeticReward.AnimTex.AnimationGroup.Alpha_FadeOut:SetOrder(3)

Collection.CosmeticReward.NextButton = CreateFrame("Button", nil, Collection.CosmeticReward, nil)
Collection.CosmeticReward.NextButton:SetSize(26, 26)
Collection.CosmeticReward.NextButton:SetPoint("BOTTOM", 100, 50)
Collection.CosmeticReward.NextButton:EnableMouse(true)
Collection.CosmeticReward.NextButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
Collection.CosmeticReward.NextButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
Collection.CosmeticReward.NextButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
Collection.CosmeticReward.NextButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
Collection.CosmeticReward.NextButton:SetScript("OnClick", function(self)
	if not (self:IsEnabled() == 1) then return false end
	local minValue = 1
	local MaxValue = #CosmeticRewards

	if (CurrentCosmeticReward + 1) == MaxValue then
		self:Disable()
		Collection.CosmeticReward.PrevButton:Enable()
		CurrentCosmeticReward = CurrentCosmeticReward + 1
		Collection:SetCosmeticReward(CurrentCosmeticReward)
	elseif ((CurrentCosmeticReward + 1) < MaxValue) then
		Collection.CosmeticReward.PrevButton:Enable()
		CurrentCosmeticReward = CurrentCosmeticReward + 1
		Collection:SetCosmeticReward(CurrentCosmeticReward)
	end

	Collection.CosmeticReward.AnimTex.AnimationGroup:Stop()
	Collection.CosmeticReward.Art.AnimationGroup:Stop()
	Collection.CosmeticReward.Icon.AnimationGroup:Stop()
	Collection.CosmeticReward.TitleText.AnimationGroup:Stop()
	Collection.CosmeticReward.SubText.AnimationGroup:Stop()
	Collection.CosmeticReward.AnimTex.AnimationGroup:Stop()
	Collection.CosmeticReward.AnimTex_Add.AnimationGroup:Stop()
	Collection.CosmeticReward.AnimTex.AnimationGroup:Play()

end)

Collection.CosmeticReward.PrevButton = CreateFrame("Button", nil, Collection.CosmeticReward, nil)
Collection.CosmeticReward.PrevButton:SetSize(26, 26)
Collection.CosmeticReward.PrevButton:SetPoint("BOTTOM", -50, 50)
Collection.CosmeticReward.PrevButton:EnableMouse(true)
Collection.CosmeticReward.PrevButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
Collection.CosmeticReward.PrevButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
Collection.CosmeticReward.PrevButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
Collection.CosmeticReward.PrevButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
Collection.CosmeticReward.PrevButton:SetScript("OnClick", function(self)
	if not (self:IsEnabled() == 1) then return false end
	local minValue = 1
	local MaxValue = #CosmeticRewards

	if (CurrentCosmeticReward - 1) == minValue then
		self:Disable()
		Collection.CosmeticReward.NextButton:Enable()
		CurrentCosmeticReward = CurrentCosmeticReward - 1
		Collection:SetCosmeticReward(CurrentCosmeticReward)
	elseif ((CurrentCosmeticReward - 1) > minValue) then
		Collection.CosmeticReward.NextButton:Enable()
		CurrentCosmeticReward = CurrentCosmeticReward - 1
		Collection:SetCosmeticReward(CurrentCosmeticReward)
	end
end)
Collection.CosmeticReward.PrevButton:Disable()

Collection.CosmeticReward.CosmeticModel = CosmeticRewards[1][1]
Collection.CosmeticReward:SetModel(Collection.CosmeticReward.CosmeticModel)

function Collection:SetCosmeticReward(rewardId)
	local Model = CosmeticRewards[rewardId][1]
	local needsCameraUpdate = CosmeticRewards[rewardId][2]
	local Name = CosmeticRewards[rewardId][3]
	local Description = CosmeticRewards[rewardId][4]
	local Icon = CosmeticRewards[rewardId][5]
	local x, y, z = unpack(CosmeticRewards[rewardId][6])
	local Facing = CosmeticRewards[rewardId][7]
	CurrentCosmeticReward = rewardId

	Collection:UpdateModel(Model, needsCameraUpdate, x, y, z, Facing)
	SetPortraitToTexture(Collection.CosmeticReward.Icon, Icon)
	Collection.CosmeticReward.TitleText:SetText(Name)
	Collection.CosmeticReward.SubText:SetText(Description)

	Collection.CosmeticReward.AnimTex.AnimationGroup:Stop()
	Collection.CosmeticReward.Art.AnimationGroup:Stop()
	Collection.CosmeticReward.Icon.AnimationGroup:Stop()
	Collection.CosmeticReward.TitleText.AnimationGroup:Stop()
	Collection.CosmeticReward.SubText.AnimationGroup:Stop()
	Collection.CosmeticReward.AnimTex.AnimationGroup:Stop()
	Collection.CosmeticReward.AnimTex_Add.AnimationGroup:Stop()
	Collection.CosmeticReward.AnimTex.AnimationGroup:Play()
end

function Collection:UpdateModel(modelpath, needsCameraUpdate, x, y, z, Facing)
	Collection.CosmeticReward.CosmeticModel = modelpath
	Collection.CosmeticReward:SetModel(Collection.CosmeticReward.CosmeticModel)
	if (needsCameraUpdate) then
		Collection.CosmeticReward:SetPosition(x, y, z)
		Collection.CosmeticReward:SetCamera(1)
		Collection.CosmeticReward:Hide()
	else
		local uiScale = 1
		if (GetCVar("useUiScale") == "1") then
			uiScale = GetCVar("uiScale")
		else
			SetCVar("uiScale", "1")
			uiScale = 1
		end -- resolution and uiscale fix
		Collection.CosmeticReward:SetFacing(Facing)
		Collection.CosmeticReward:SetPosition(x, y, z + (1.75 / uiScale))
	end
end

Collection:SetCosmeticReward(1)

Collection.CosmeticReward:SetScript("OnShow", function(self)
	Collection.CosmeticReward:SetModel(Collection.CosmeticReward.CosmeticModel)
	Collection.CosmeticReward:SetFacing(CosmeticRewards[CurrentCosmeticReward][7])
	Collection.CosmeticReward:SetModelScale(CosmeticRewards[CurrentCosmeticReward][8])
	-- Collection.CosmeticReward:SetPosition(0, 0, 1.75/uiScale)
end)

Collection.CosmeticReward_fake:SetScript("OnUpdate", function()
	if (COSMETICREWARD_SELECT_ROTATION_START_X) then
		local x = GetCursorPosition();
		local diff = (x - COSMETICREWARD_SELECT_ROTATION_START_X) * 0.01;
		COSMETICREWARD_SELECT_ROTATION_START_X = GetCursorPosition();
		Collection.CosmeticReward:SetFacing((Collection.CosmeticReward:GetFacing() + diff));
	end
end)

Collection.CosmeticReward_fake:SetScript("OnMouseDown", function(self, button)
	if (button == "LeftButton") then
		COSMETICREWARD_SELECT_ROTATION_START_X = GetCursorPosition();
		COSMETICREWARD_SELECT_INITIAL_FACING = Collection.CosmeticReward:GetFacing();
	end
end)

Collection.CosmeticReward_fake:SetScript("OnMouseUp", function(self, button) if (button == "LeftButton") then COSMETICREWARD_SELECT_ROTATION_START_X = nil end end)

Collection.CosmeticReward_fake:EnableMouseWheel(true)
Collection.CosmeticReward_fake:SetScript("OnMouseWheel", function(self, delta)
	if Collection.CosmeticReward:GetModelScale() >= 1.2 and delta > 0 then return false end

	if Collection.CosmeticReward:GetModelScale() <= 0.6 and delta < 0 then return false end

	Collection.CosmeticReward:SetModelScale(Collection.CosmeticReward:GetModelScale() + (delta * 0000.1))
end)

-------------------------------------------------------------------------------
--                           Seasonal Points Frame                           --
-------------------------------------------------------------------------------

Collection.SeasonalPointsFrame = CreateFrame("FRAME", nil, Collection, nil)
Collection.SeasonalPointsFrame:SetPoint("BOTTOMLEFT", -28, -43)
Collection.SeasonalPointsFrame:SetSize(128, 128)
Collection.SeasonalPointsFrame:SetFrameLevel(3)

Collection.SeasonalPointsFrame.Highlight = Collection.SeasonalPointsFrame:CreateTexture(nil, "BACKGROUND")
Collection.SeasonalPointsFrame.Highlight:SetSize(54, 54)
Collection.SeasonalPointsFrame.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\Arcane_Circular_Flash")
Collection.SeasonalPointsFrame.Highlight:SetPoint("CENTER", 0, 0)
Collection.SeasonalPointsFrame.Highlight:SetBlendMode("ADD")

Collection.SeasonalPointsFrame.Icon = Collection.SeasonalPointsFrame:CreateTexture(nil, "ARTWORK")
Collection.SeasonalPointsFrame.Icon:SetSize(25, 25)
Collection.SeasonalPointsFrame.Icon:SetTexture("Interface\\icons\\inv_archaeology_70_demon_orbofinnerchaos")
Collection.SeasonalPointsFrame.Icon:SetPoint("CENTER", 0, 0)

Collection.SeasonalPointsFrame.SPIconFrame = CreateFrame("FRAME", nil, Collection.SeasonalPointsFrame, nil)
Collection.SeasonalPointsFrame.SPIconFrame:SetPoint("CENTER")
Collection.SeasonalPointsFrame.SPIconFrame:SetSize(Collection.SeasonalPointsFrame:GetSize())
Collection.SeasonalPointsFrame.SPIconFrame:SetFrameLevel(5)

Collection.SeasonalPointsFrame.Border = Collection.SeasonalPointsFrame.SPIconFrame:CreateTexture(nil, "ARTWORK")
Collection.SeasonalPointsFrame.Border:SetSize(51, 51)
Collection.SeasonalPointsFrame.Border:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\MetalEternium_Circular_Frame")
Collection.SeasonalPointsFrame.Border:SetPoint("CENTER", 0, 0)

Collection.SeasonalPointsFrame.BorderHighlight = Collection.SeasonalPointsFrame.SPIconFrame:CreateTexture(nil, "OVERLAY")
Collection.SeasonalPointsFrame.BorderHighlight:SetSize(32, 32)
Collection.SeasonalPointsFrame.BorderHighlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\CircularHighLight")
Collection.SeasonalPointsFrame.BorderHighlight:SetPoint("CENTER", 1, 0)
Collection.SeasonalPointsFrame.BorderHighlight:SetBlendMode("ADD")

Collection.SeasonalPointsFrame.BGText = Collection.SeasonalPointsFrame:CreateTexture(nil, "BACKGROUND")
Collection.SeasonalPointsFrame.BGText:SetSize(360, 90)
Collection.SeasonalPointsFrame.BGText:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\RewardName_Highlight")
Collection.SeasonalPointsFrame.BGText:SetPoint("CENTER", 102, -12)

--[[Collection.SeasonalPointsFrame.RefundBG = Collection.SeasonalPointsFrame:CreateTexture(nil, "BORDER")
Collection.SeasonalPointsFrame.RefundBG:SetPoint("BOTTOM", 0, 15)
Collection.SeasonalPointsFrame.RefundBG:SetSize(160, 32)
Collection.SeasonalPointsFrame.RefundBG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\Enchant_RefundButton")

Collection.SeasonalPointsFrame.Button = CreateFrame("Button", nil, Collection.SeasonalPointsFrame, "StaticPopupButtonTemplate")
Collection.SeasonalPointsFrame.Button:SetPoint("BOTTOM", 1, 20)
Collection.SeasonalPointsFrame.Button:EnableMouse(true)
Collection.SeasonalPointsFrame.Button:SetText("Refund")
Collection.SeasonalPointsFrame.Button:SetWidth(92)
Collection.SeasonalPointsFrame.Button:SetHeight(21)
Collection.SeasonalPointsFrame.Button:SetNormalTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\UI-DialogBox-Button-Up_Green")
Collection.SeasonalPointsFrame.Button:SetHighlightTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\UI-DialogBox-Button-Highlight_Green")
Collection.SeasonalPointsFrame.Button:SetPushedTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\UI-DialogBox-Button-Down_Green")
Collection.SeasonalPointsFrame.Button:SetScript("OnClick", function(self)
  if not(self:IsEnabled() == 1) then
    return false
  end
  AIO.Handle("SeasonalCollection", "RefundSeasonalPoints") 
  end)]] --

Collection.SeasonalPointsFrame.SPCounter = Collection.SeasonalPointsFrame:CreateFontString(nil, "OVERLAY")
Collection.SeasonalPointsFrame.SPCounter:SetFont("Fonts\\FRIZQT__.TTF", 11)
Collection.SeasonalPointsFrame.SPCounter:SetFontObject(GameFontNormal)
Collection.SeasonalPointsFrame.SPCounter:SetPoint("CENTER", 128, -1)
Collection.SeasonalPointsFrame.SPCounter:SetShadowOffset(0, -1)
Collection.SeasonalPointsFrame.SPCounter:SetSize(200, 32)
Collection.SeasonalPointsFrame.SPCounter:SetText(format(SEASON_POINT_COUNTER_SHORT_FORMAT, 0))
Collection.SeasonalPointsFrame.SPCounter:SetJustifyH("LEFT")

-------------------------------------Total Points Earned------------------------------------

Collection.SeasonalPointsFrame_Total = CreateFrame("FRAME", nil, Collection, nil)
Collection.SeasonalPointsFrame_Total:SetPoint("BOTTOMRIGHT", -142, -43)
Collection.SeasonalPointsFrame_Total:SetSize(128, 128)
Collection.SeasonalPointsFrame_Total:SetFrameLevel(3)

Collection.SeasonalPointsFrame_Total.Icon = Collection.SeasonalPointsFrame_Total:CreateTexture(nil, "ARTWORK")
Collection.SeasonalPointsFrame_Total.Icon:SetSize(25, 25)
Collection.SeasonalPointsFrame_Total.Icon:SetTexture("Interface\\icons\\inv_archaeology_70_demon_orbofinnerchaos")
Collection.SeasonalPointsFrame_Total.Icon:SetPoint("CENTER", 0, 0)

Collection.SeasonalPointsFrame_Total.SPIconFrame = CreateFrame("FRAME", nil, Collection.SeasonalPointsFrame_Total, nil)
Collection.SeasonalPointsFrame_Total.SPIconFrame:SetPoint("CENTER")
Collection.SeasonalPointsFrame_Total.SPIconFrame:SetSize(Collection.SeasonalPointsFrame_Total:GetSize())
Collection.SeasonalPointsFrame_Total.SPIconFrame:SetFrameLevel(5)

Collection.SeasonalPointsFrame_Total.Border = Collection.SeasonalPointsFrame_Total.SPIconFrame:CreateTexture(nil, "ARTWORK")
Collection.SeasonalPointsFrame_Total.Border:SetSize(51, 51)
Collection.SeasonalPointsFrame_Total.Border:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\MetalEternium_Circular_Frame")
Collection.SeasonalPointsFrame_Total.Border:SetPoint("CENTER", 0, 0)

Collection.SeasonalPointsFrame_Total.SPCounter = Collection.SeasonalPointsFrame_Total:CreateFontString(nil, "OVERLAY")
Collection.SeasonalPointsFrame_Total.SPCounter:SetFont("Fonts\\FRIZQT__.TTF", 11)
Collection.SeasonalPointsFrame_Total.SPCounter:SetFontObject(GameFontNormal)
Collection.SeasonalPointsFrame_Total.SPCounter:SetPoint("CENTER", 128, 0)
Collection.SeasonalPointsFrame_Total.SPCounter:SetShadowOffset(0, -1)
Collection.SeasonalPointsFrame_Total.SPCounter:SetSize(200, 32)
Collection.SeasonalPointsFrame_Total.SPCounter:SetText(format(SEASON_RATING_COUNTER_FORMAT, 0))
Collection.SeasonalPointsFrame_Total.SPCounter:SetJustifyH("LEFT")

Collection.SeasonalPointsFrame_Total.BGText = Collection.SeasonalPointsFrame_Total:CreateTexture(nil, "BACKGROUND")
Collection.SeasonalPointsFrame_Total.BGText:SetSize(360, 90)
Collection.SeasonalPointsFrame_Total.BGText:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\RewardName_Highlight")
Collection.SeasonalPointsFrame_Total.BGText:SetPoint("CENTER", 102, -12)

-------------------------------------------------------------------------------
--                                Progress Bar                               --
-------------------------------------------------------------------------------

function Collection:InitProgressBar()
	if Collection.BigChallenges then return end
	Collection.BigChallenges = {}
	for i = 1, TotalBigChallenges do

		Collection.BigChallenges["Frame"..i] = CreateFrame("FRAME", nil, Collection, nil)
		Collection.BigChallenges["Frame"..i]:SetPoint("CENTER", -302 + (i - 1) * 100, 170)
		Collection.BigChallenges["Frame"..i]:SetSize(128, 128)
		Collection.BigChallenges["Frame"..i]:SetFrameLevel(3)

		Collection.BigChallenges["Frame"..i].Button = CreateFrame("BUTTON", nil, Collection.BigChallenges["Frame"..i])
		Collection.BigChallenges["Frame"..i].Button:SetSize(65, 65)
		Collection.BigChallenges["Frame"..i].Button:SetPoint("CENTER", 1, 0)
		Collection.BigChallenges["Frame"..i].Button:SetHighlightTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\CircularHighLight")
		Collection.BigChallenges["Frame"..i].Button:SetScript("OnMouseDown", function(self)
			CurrentBigChallenge = i
			Collection:LoadChallenges()
			Collection:SetActiveBigChallenge()
		end)

		Collection.BigChallenges["Frame"..i].IconBorder = Collection.BigChallenges["Frame"..i]:CreateTexture(nil, "ARTWORK")
		Collection.BigChallenges["Frame"..i].IconBorder:SetSize(93, 93)
		Collection.BigChallenges["Frame"..i].IconBorder:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\MetalEternium_Circular_Frame")
		Collection.BigChallenges["Frame"..i].IconBorder:SetPoint("CENTER", 0, 0)

		Collection.BigChallenges["Frame"..i].Current = Collection.BigChallenges["Frame"..i]:CreateTexture(nil, "OVERLAY")
		Collection.BigChallenges["Frame"..i].Current:SetSize(113, 113)
		Collection.BigChallenges["Frame"..i].Current:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\TalentMaxHighlight_Green")
		Collection.BigChallenges["Frame"..i].Current:SetPoint("CENTER", 0, 0)
		Collection.BigChallenges["Frame"..i].Current:SetBlendMode("ADD")
		Collection.BigChallenges["Frame"..i].Current:Hide()

		Collection.BigChallenges["Frame"..i].Current.AnimationGroup = Collection.BigChallenges["Frame"..i].Current:CreateAnimationGroup()
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup:SetScript("OnPlay", function() Collection.BigChallenges["Frame"..i].Current:Show() end)

		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Alpha_Init = Collection.BigChallenges["Frame"..i].Current.AnimationGroup:CreateAnimation("Alpha")
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Alpha_Init:SetChange(-1)
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Alpha_Init:SetDuration(0)
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Alpha_Init:SetOrder(1)

		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Grow_Init = Collection.BigChallenges["Frame"..i].Current.AnimationGroup:CreateAnimation("Scale")
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Grow_Init:SetScale(0.1, 0.1)
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Grow_Init:SetDuration(0.0)
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Grow_Init:SetStartDelay(0)
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Grow_Init:SetOrder(1)

		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Grow_FadeIn = Collection.BigChallenges["Frame"..i].Current.AnimationGroup:CreateAnimation("Scale")
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Grow_FadeIn:SetScale(10.0, 10.0)
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Grow_FadeIn:SetDuration(0.5)
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Grow_FadeIn:SetOrder(2)

		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Alpha_FadeIn = Collection.BigChallenges["Frame"..i].Current.AnimationGroup:CreateAnimation("Alpha")
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Alpha_FadeIn:SetChange(1)
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Alpha_FadeIn:SetDuration(0.8)
		Collection.BigChallenges["Frame"..i].Current.AnimationGroup.Alpha_FadeIn:SetOrder(2)

		Collection.BigChallenges["Frame"..i].Complete = Collection.BigChallenges["Frame"..i]:CreateTexture(nil, "BACKGROUND")
		Collection.BigChallenges["Frame"..i].Complete:SetSize(150, 150)
		Collection.BigChallenges["Frame"..i].Complete:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\AdditionalHighlight")
		Collection.BigChallenges["Frame"..i].Complete:SetPoint("CENTER", 5, -2)
		Collection.BigChallenges["Frame"..i].Complete:SetBlendMode("ADD")
		Collection.BigChallenges["Frame"..i].Complete:Hide()

		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup = Collection.BigChallenges["Frame"..i].Complete:CreateAnimationGroup()
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup:SetScript("OnPlay", function() Collection.BigChallenges["Frame"..i].Complete:Show() end)

		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Alpha_Init = Collection.BigChallenges["Frame"..i].Complete.AnimationGroup:CreateAnimation("Alpha")
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Alpha_Init:SetChange(-1)
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Alpha_Init:SetDuration(0)
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Alpha_Init:SetOrder(1)

		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Grow_Init = Collection.BigChallenges["Frame"..i].Complete.AnimationGroup:CreateAnimation("Scale")
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Grow_Init:SetScale(0.1, 0.1)
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Grow_Init:SetDuration(0.0)
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Grow_Init:SetStartDelay(0)
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Grow_Init:SetOrder(1)

		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Grow_FadeIn = Collection.BigChallenges["Frame"..i].Complete.AnimationGroup:CreateAnimation("Scale")
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Grow_FadeIn:SetScale(10.0, 10.0)
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Grow_FadeIn:SetDuration(0.5)
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Grow_FadeIn:SetOrder(2)

		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Alpha_FadeIn = Collection.BigChallenges["Frame"..i].Complete.AnimationGroup:CreateAnimation("Alpha")
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Alpha_FadeIn:SetChange(1)
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Alpha_FadeIn:SetDuration(0.8)
		Collection.BigChallenges["Frame"..i].Complete.AnimationGroup.Alpha_FadeIn:SetOrder(2)

		Collection.BigChallenges["Frame"..i].BigGlow = CreateFrame("Model", nil, Collection.BigChallenges["Frame"..i])
		Collection.BigChallenges["Frame"..i].BigGlow:SetWidth(300);
		Collection.BigChallenges["Frame"..i].BigGlow:SetHeight(300);
		Collection.BigChallenges["Frame"..i].BigGlow:SetPoint("CENTER", 0, 0)
		Collection.BigChallenges["Frame"..i].BigGlow:SetModel("World\\Kalimdor\\silithus\\passivedoodads\\ahnqirajglow\\quirajglow_green.m2")
		Collection.BigChallenges["Frame"..i].BigGlow:SetModelScale(0.015)
		Collection.BigChallenges["Frame"..i].BigGlow:SetCamera(0)
		Collection.BigChallenges["Frame"..i].BigGlow:SetPosition(0.095, 0.097, 0)
		Collection.BigChallenges["Frame"..i].BigGlow:SetFacing(0)
		Collection.BigChallenges["Frame"..i].BigGlow:SetFrameLevel(2)
		Collection.BigChallenges["Frame"..i].BigGlow:SetAlpha(1)
		Collection.BigChallenges["Frame"..i].BigGlow:Hide()

		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup = Collection.BigChallenges["Frame"..i].BigGlow:CreateAnimationGroup()
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup:SetScript("OnPlay", function() Collection.BigChallenges["Frame"..i].BigGlow:Show() end)

		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Alpha_Init = Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup:CreateAnimation("Alpha")
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Alpha_Init:SetChange(-1)
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Alpha_Init:SetDuration(0)
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Alpha_Init:SetOrder(1)

		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Grow_Init = Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup:CreateAnimation("Scale")
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Grow_Init:SetScale(0.1, 0.1)
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Grow_Init:SetDuration(0.0)
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Grow_Init:SetStartDelay(0)
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Grow_Init:SetOrder(1)

		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Grow_FadeIn = Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup:CreateAnimation("Scale")
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Grow_FadeIn:SetScale(10.0, 10.0)
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Grow_FadeIn:SetDuration(0.5)
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Grow_FadeIn:SetOrder(2)

		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Alpha_FadeIn = Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup:CreateAnimation("Alpha")
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Alpha_FadeIn:SetChange(1)
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Alpha_FadeIn:SetDuration(0.8)
		Collection.BigChallenges["Frame"..i].BigGlow.AnimationGroup.Alpha_FadeIn:SetOrder(2)

		Collection.BigChallenges["Frame"..i].Icon = Collection.BigChallenges["Frame"..i]:CreateTexture(nil, "BORDER")
		Collection.BigChallenges["Frame"..i].Icon:SetSize(47, 47)
		Collection.BigChallenges["Frame"..i].Icon:SetPoint("CENTER", 0, 0)
		SetPortraitToTexture(Collection.BigChallenges["Frame"..i].Icon, "Interface\\icons\\FoxMountIcon")

		if (i < TotalBigChallenges) then

			Collection.BigChallenges["Frame"..i].ProgessBar= CreateFrame("StatusBar", nil, Collection)
			-- _G["Collection.ProgressBar"..i]:SetBackdrop(GameTooltip:GetBackdrop())
			Collection.BigChallenges["Frame"..i].ProgessBar:SetBackdropColor(0, 0, 0, 1)
			Collection.BigChallenges["Frame"..i].ProgessBar:SetBackdropBorderColor(0, 0, 0, 1)
			Collection.BigChallenges["Frame"..i].ProgessBar:SetSize(100, 23)
			Collection.BigChallenges["Frame"..i].ProgessBar:SetPoint("CENTER", -232 + (i - 1) * 100, 167)
			Collection.BigChallenges["Frame"..i].ProgessBar:SetStatusBarTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\MetalEternium_bar_fill")
			Collection.BigChallenges["Frame"..i].ProgessBar:SetMinMaxValues(0, 1)
			Collection.BigChallenges["Frame"..i].ProgessBar:SetValue(1)
			Collection.BigChallenges["Frame"..i].ProgessBar:GetStatusBarTexture():SetDrawLayer("BORDER")
			Collection.BigChallenges["Frame"..i].ProgessBar:GetStatusBarTexture():SetBlendMode("ADD")
			Collection.BigChallenges["Frame"..i].ProgessBar:GetStatusBarTexture():SetPoint("CENTER", 0, -8)
			Collection.BigChallenges["Frame"..i].ProgessBar:SetFrameLevel(2)

			Collection.BigChallenges["Frame"..i].ProgessBar.ArtWork = Collection.BigChallenges["Frame"..i].ProgessBar:CreateTexture(nil, "ARTWORK")
			Collection.BigChallenges["Frame"..i].ProgessBar.ArtWork:SetSize(128, 32)
			Collection.BigChallenges["Frame"..i].ProgessBar.ArtWork:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\MetalEternium_bar")
			Collection.BigChallenges["Frame"..i].ProgessBar.ArtWork:SetPoint("CENTER", Collection.BigChallenges["Frame"..i].ProgessBar, 0, 3)
		end

	end

	local highlight = Collection.BigChallenges.Frame7:CreateTexture(nil, "BACKGROUND")
	Collection.BigChallenges.Frame7.Highlight = highlight
	highlight:SetSize(160, 160)
	highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\DragonHighlight_green")
	highlight:SetPoint("CENTER", 0, 0)
	highlight:SetBlendMode("ADD")

	highlight.AnimG = highlight:CreateAnimationGroup()
	highlight.AnimG.Rotation = highlight.AnimG:CreateAnimation("Rotation")
	highlight.AnimG.Rotation:SetDuration(60)
	highlight.AnimG.Rotation:SetOrder(1)
	highlight.AnimG.Rotation:SetEndDelay(0)
	highlight.AnimG.Rotation:SetSmoothing("NONE")
	highlight.AnimG.Rotation:SetDegrees(-360)

	Collection.BigChallenges.Frame7.Button:SetScript("OnUpdate", function(self)
		local highlight = self:GetParent().Highlight
		if not (highlight.AnimG:IsPlaying()) then 
			highlight.AnimG:Play() 
		end 
	end)

end

-------------------------------------------------------------------------------
--                            Small BigChallenges Main                          --
-------------------------------------------------------------------------------

Collection.SmallChallengesFrame = CreateFrame("FRAME", nil, Collection, nil)
Collection.SmallChallengesFrame:SetPoint("CENTER", 0, -48)
Collection.SmallChallengesFrame:SetSize(320, 313)
Collection.SmallChallengesFrame:SetFrameLevel(5)

Collection.SmallChallengesFrame.BG = Collection.SmallChallengesFrame:CreateTexture(nil, "BACKGROUND")
Collection.SmallChallengesFrame.BG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\SmallChallengesBorder")
Collection.SmallChallengesFrame.BG:SetSize(1024, 1024)
Collection.SmallChallengesFrame.BG:SetPoint("CENTER", Collection, 0, 0)

Collection.SmallChallengesFrame.TitleText = Collection.SmallChallengesFrame:CreateFontString()
Collection.SmallChallengesFrame.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
Collection.SmallChallengesFrame.TitleText:SetFontObject(GameFontNormal)
Collection.SmallChallengesFrame.TitleText:SetPoint("TOP", 0, 15)
Collection.SmallChallengesFrame.TitleText:SetShadowOffset(1, -1)

Collection.SmallChallengesFrame.GoldBG = Collection.SmallChallengesFrame:CreateTexture(nil, "BORDER")
Collection.SmallChallengesFrame.GoldBG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\LevelUpTex_Green")
Collection.SmallChallengesFrame.GoldBG:SetSize(180, 48)
Collection.SmallChallengesFrame.GoldBG:SetPoint("TOP", 0, 43)
Collection.SmallChallengesFrame.GoldBG:SetTexCoord(0.56054688, 0.99609375, 0.24218750, 0.46679688)
Collection.SmallChallengesFrame.GoldBG:SetVertexColor(1, 1, 1, 0.6)
Collection.SmallChallengesFrame.GoldBG:SetBlendMode("ADD")

Collection.SmallChallengesFrame.LineUp = Collection.SmallChallengesFrame:CreateTexture(nil, "BORDER", nil, 2)
Collection.SmallChallengesFrame.LineUp:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\LevelUpTex_Green")
Collection.SmallChallengesFrame.LineUp:SetSize(365, 7)
Collection.SmallChallengesFrame.LineUp:SetPoint("TOP", 0, 3)
Collection.SmallChallengesFrame.LineUp:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
Collection.SmallChallengesFrame.LineUp:SetVertexColor(1, 1, 1)
Collection.SmallChallengesFrame.LineUp:SetBlendMode("ADD")

Collection.SmallChallengesFrame.LineDown = Collection.SmallChallengesFrame:CreateTexture(nil, "BORDER", nil, 2)
Collection.SmallChallengesFrame.LineDown:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\LevelUpTex_Green")
Collection.SmallChallengesFrame.LineDown:SetSize(365, 7)
Collection.SmallChallengesFrame.LineDown:SetPoint("BOTTOM", 0, 3)
Collection.SmallChallengesFrame.LineDown:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
Collection.SmallChallengesFrame.LineDown:SetVertexColor(1, 1, 1)
Collection.SmallChallengesFrame.LineDown:SetBlendMode("ADD")

Collection.SmallChallengesFrame.Texture = Collection.SmallChallengesFrame:CreateTexture(nil, "BACKGROUND", nil, 2)
Collection.SmallChallengesFrame.Texture:SetTexture("Interface\\LevelUp\\LevelUpTex")
Collection.SmallChallengesFrame.Texture:SetSize(400, 400)
Collection.SmallChallengesFrame.Texture:SetPoint("BOTTOM", 0, 2)
Collection.SmallChallengesFrame.Texture:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
Collection.SmallChallengesFrame.Texture:SetVertexColor(1, 1, 1, 0.6)

Collection.SmallChallengesFrame.Art = Collection.SmallChallengesFrame:CreateTexture(nil, "BACKGROUND", nil, 2)
Collection.SmallChallengesFrame.Art:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\Special_Bottom")
Collection.SmallChallengesFrame.Art:SetSize(256, 32)
Collection.SmallChallengesFrame.Art:SetPoint("BOTTOM", 0, 2)
Collection.SmallChallengesFrame.Art:SetVertexColor(1, 1, 1, 0.6)
Collection.SmallChallengesFrame.Art:SetBlendMode("ADD")

Collection.SmallChallengesFrame.Scroll = CreateFrame("ScrollFrame", "SeasonalCollection.SmallChallengesFrame.Scroll", Collection.SmallChallengesFrame)
Collection.SmallChallengesFrame.Scroll:SetSize(298, 241)
Collection.SmallChallengesFrame.Scroll:SetPoint("CENTER", -10, 29)

Collection.SmallChallengesFrame.Scroll:EnableMouseWheel(true)

Collection.SmallChallengesFrame.Scroll:SetScript("OnMouseWheel", function(self, delta)
	if (Collection.SmallChallengesFrame.Scroll.ScrollBar:IsVisible()) then
		local value = Collection.SmallChallengesFrame.Scroll.ScrollBar:GetValue()
		Collection.SmallChallengesFrame.Scroll.ScrollBar:SetValue(value - delta * 64)
	end
end)

local content = CreateFrame("Frame", nil, Collection.SmallChallengesFrame)
Collection.SmallChallengesFrame.Scroll.Content = content
content:SetSize(298, 256)
content:SetPoint("CENTER")

local content_fake = CreateFrame("Frame", nil, Collection.SmallChallengesFrame)
Collection.SmallChallengesFrame.Scroll.Content_fake = content_fake
content_fake:SetSize(298, 241)
content_fake:SetPoint("CENTER", -10, 29)

Collection.SmallChallengesFrame.Scroll.ScrollBar = CreateFrame("Slider", "SeasonalCollection.SmallChallengesFrame.Scroll.ScrollBar", Collection.SmallChallengesFrame.Scroll, "UIPanelScrollBarTemplate")
Collection.SmallChallengesFrame.Scroll.ScrollBar:SetPoint("TOPLEFT", Collection.SmallChallengesFrame.Scroll, "TOPRIGHT", 1, -14)
Collection.SmallChallengesFrame.Scroll.ScrollBar:SetPoint("BOTTOMLEFT", Collection.SmallChallengesFrame.Scroll, "BOTTOMRIGHT", 1, -45)

Collection.SmallChallengesFrame.Scroll.ScrollBar:SetMinMaxValues(1, Collection.SmallChallengesFrame.Scroll.Content:GetHeight())
Collection.SmallChallengesFrame.Scroll.ScrollBar:SetValueStep(1)
Collection.SmallChallengesFrame.Scroll.ScrollBar.scrollStep = 64
Collection.SmallChallengesFrame.Scroll.ScrollBar:SetValue(0)
Collection.SmallChallengesFrame.Scroll.ScrollBar:SetWidth(16)
Collection.SmallChallengesFrame.Scroll.ScrollBar:SetScript("OnValueChanged", function(self, value) 
	Collection.SmallChallengesFrame.Scroll:SetVerticalScroll(value) 
end)

Collection.SmallChallengesFrame.Scroll.ScrollUpButton = _G[Collection.SmallChallengesFrame.Scroll.ScrollBar:GetName().."ScrollUpButton"]
Collection.SmallChallengesFrame.Scroll.ScrollDownButton = _G[Collection.SmallChallengesFrame.Scroll.ScrollBar:GetName().."ScrollDownButton"]

Collection.SmallChallengesFrame.Scroll:SetScrollChild(Collection.SmallChallengesFrame.Scroll.Content)
-------------------------------------------------------------------------------
--                               Small BigChallenges                            --
-------------------------------------------------------------------------------

for i = 1, MaxSmallChallenges do
	content["BG" .. i] = CreateFrame("BUTTON", nil, content)
	content["BG" .. i]:SetSize(293, 58)
	content["BG" .. i]:SetPoint("TOP", 0, -3 - 60 * (i - 1))
	content["BG" .. i]:SetHighlightTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\LevelUpTex_Green")
	content["BG" .. i]:GetHighlightTexture():SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	content["BG" .. i]:GetHighlightTexture():ClearAllPoints()
	content["BG" .. i]:GetHighlightTexture():SetSize(200, 7)
	content["BG" .. i]:GetHighlightTexture():SetPoint("CENTER", 0, 8)

	content["Icon" .. i] = content:CreateTexture(nil, "BORDER")
	content["Icon" .. i]:SetSize(40, 40)
	content["Icon" .. i]:SetTexture("Interface\\icons\\FoxMountIcon")
	content["Icon" .. i]:SetPoint("TOPLEFT", 10, -12 - 60 * (i - 1))

	content["Icon" .. i].AnimationGroup = content["Icon" .. i]:CreateAnimationGroup()
	content["Icon" .. i].AnimationGroup.Rotation = content["Icon" .. i].AnimationGroup:CreateAnimation("Translation")
	content["Icon" .. i].AnimationGroup.Rotation:SetStartDelay(0.05 * i)
	content["Icon" .. i].AnimationGroup.Rotation:SetDuration(0)
	content["Icon" .. i].AnimationGroup.Rotation:SetOrder(1)
	content["Icon" .. i].AnimationGroup.Rotation:SetEndDelay(0)
	content["Icon" .. i].AnimationGroup.Rotation:SetSmoothing("OUT")
	content["Icon" .. i].AnimationGroup.Rotation:SetOffset(-30, 0)

	content["Icon" .. i].AnimationGroup.Rotation2 = content["Icon" .. i].AnimationGroup:CreateAnimation("Translation")
	content["Icon" .. i].AnimationGroup.Rotation2:SetDuration(0.5)
	content["Icon" .. i].AnimationGroup.Rotation2:SetOrder(2)
	content["Icon" .. i].AnimationGroup.Rotation2:SetSmoothing("OUT")
	content["Icon" .. i].AnimationGroup.Rotation2:SetOffset(30, 0)

	content["IconBorder" .. i] = content:CreateTexture(nil, "ARTWORK")
	content["IconBorder" .. i]:SetSize(40, 40)
	content["IconBorder" .. i]:SetTexture("Interface\\Addons\\AwAddons\\Textures\\SpellKit\\ArtifactPower-QuestBorder")
	content["IconBorder" .. i]:SetPoint("TOPLEFT", 10, -12 - 60 * (i - 1))

	content["IconBorder" .. i].AnimationGroup = content["IconBorder" .. i]:CreateAnimationGroup()
	content["IconBorder" .. i].AnimationGroup.Rotation = content["IconBorder" .. i].AnimationGroup:CreateAnimation("Translation")
	content["IconBorder" .. i].AnimationGroup.Rotation:SetStartDelay(0.05 * i)
	content["IconBorder" .. i].AnimationGroup.Rotation:SetDuration(0)
	content["IconBorder" .. i].AnimationGroup.Rotation:SetOrder(1)
	content["IconBorder" .. i].AnimationGroup.Rotation:SetEndDelay(0)
	content["IconBorder" .. i].AnimationGroup.Rotation:SetSmoothing("OUT")
	content["IconBorder" .. i].AnimationGroup.Rotation:SetOffset(-30, 0)

	content["IconBorder" .. i].AnimationGroup.Rotation2 = content["IconBorder" .. i].AnimationGroup:CreateAnimation("Translation")
	content["IconBorder" .. i].AnimationGroup.Rotation2:SetDuration(0.5)
	content["IconBorder" .. i].AnimationGroup.Rotation2:SetOrder(2)
	
	content["IconBorder" .. i].AnimationGroup.Rotation2:SetSmoothing("OUT")
	content["IconBorder" .. i].AnimationGroup.Rotation2:SetOffset(30, 0)

	content["IconTextMain" .. i] = content:CreateFontString(nil)
	content["IconTextMain" .. i]:SetFont("Fonts\\FRIZQT__.ttf", 11)
	content["IconTextMain" .. i]:SetFontObject(GameFontHighlight)
	content["IconTextMain" .. i]:SetPoint("TOP", 0, -2 - 60 * (i - 1))
	content["IconTextMain" .. i]:SetShadowOffset(0, -1)
	content["IconTextMain" .. i]:SetSize(190, 24)
	content["IconTextMain" .. i]:SetText("Misty Fox")
	content["IconTextMain" .. i]:SetJustifyH("CENTER")
	content["IconTextMain" .. i]:SetJustifyV("BOTTOM")

	content["IconTextMain" .. i].AnimationGroup = content["IconTextMain" .. i]:CreateAnimationGroup()
	content["IconTextMain" .. i].AnimationGroup.Rotation = content["IconTextMain" .. i].AnimationGroup:CreateAnimation("Translation")
	content["IconTextMain" .. i].AnimationGroup.Rotation:SetStartDelay(0.05 * i)
	content["IconTextMain" .. i].AnimationGroup.Rotation:SetDuration(0)
	content["IconTextMain" .. i].AnimationGroup.Rotation:SetOrder(1)
	content["IconTextMain" .. i].AnimationGroup.Rotation:SetEndDelay(0)
	content["IconTextMain" .. i].AnimationGroup.Rotation:SetSmoothing("OUT")
	content["IconTextMain" .. i].AnimationGroup.Rotation:SetOffset(-30, 0)

	content["IconTextMain" .. i].AnimationGroup.Rotation2 = content["IconTextMain" .. i].AnimationGroup:CreateAnimation("Translation")
	content["IconTextMain" .. i].AnimationGroup.Rotation2:SetDuration(0.5)
	content["IconTextMain" .. i].AnimationGroup.Rotation2:SetOrder(2)
	content["IconTextMain" .. i].AnimationGroup.Rotation2:SetSmoothing("OUT")
	content["IconTextMain" .. i].AnimationGroup.Rotation2:SetOffset(30, 0)

	content["IconTextSub" .. i] = content:CreateFontString(nil)
	content["IconTextSub" .. i]:SetFont("Fonts\\FRIZQT__.ttf", 10)
	content["IconTextSub" .. i]:SetFontObject(GameFontHighlight)
	content["IconTextSub" .. i]:SetPoint("TOP", 0, -35 - 60 * (i - 1))
	content["IconTextSub" .. i]:SetShadowOffset(0, -1)
	content["IconTextSub" .. i]:SetSize(190, 23)
	content["IconTextSub" .. i]:SetText("Kill Misty Fox")
	content["IconTextSub" .. i]:SetJustifyH("CENTER")
	content["IconTextSub" .. i]:SetJustifyV("TOP")

	content["IconTextSub" .. i].AnimationGroup = content["IconTextSub" .. i]:CreateAnimationGroup()
	content["IconTextSub" .. i].AnimationGroup.Rotation = content["IconTextSub" .. i].AnimationGroup:CreateAnimation("Translation")
	content["IconTextSub" .. i].AnimationGroup.Rotation:SetStartDelay(0.05 * i)
	content["IconTextSub" .. i].AnimationGroup.Rotation:SetDuration(0)
	content["IconTextSub" .. i].AnimationGroup.Rotation:SetOrder(1)
	content["IconTextSub" .. i].AnimationGroup.Rotation:SetEndDelay(0)
	content["IconTextSub" .. i].AnimationGroup.Rotation:SetSmoothing("OUT")
	content["IconTextSub" .. i].AnimationGroup.Rotation:SetOffset(-30, 0)

	content["IconTextSub" .. i].AnimationGroup.Rotation2 = content["IconTextSub" .. i].AnimationGroup:CreateAnimation("Translation")
	content["IconTextSub" .. i].AnimationGroup.Rotation2:SetDuration(0.5)
	content["IconTextSub" .. i].AnimationGroup.Rotation2:SetOrder(2)
	content["IconTextSub" .. i].AnimationGroup.Rotation2:SetSmoothing("OUT")
	content["IconTextSub" .. i].AnimationGroup.Rotation2:SetOffset(30, 0)

	content["IconTextDate" .. i] = content:CreateFontString(nil)
	content["IconTextDate" .. i]:SetFont("Fonts\\FRIZQT__.ttf", 9)
	content["IconTextDate" .. i]:SetFontObject(GameFontHighlight)
	content["IconTextDate" .. i]:SetPoint("TOPRIGHT", -10, -55 - 60 * (i - 1))
	content["IconTextDate" .. i]:SetShadowOffset(0, -1)
	content["IconTextDate" .. i]:SetSize(70, 23)
	content["IconTextDate" .. i]:SetText("08/01/2018")
	content["IconTextDate" .. i]:SetJustifyH("RIGHT")
	content["IconTextDate" .. i]:SetJustifyV("TOP")

	content["IconTextDate" .. i].AnimationGroup = content["IconTextDate" .. i]:CreateAnimationGroup()
	content["IconTextDate" .. i].AnimationGroup.Rotation = content["IconTextDate" .. i].AnimationGroup:CreateAnimation("Translation")
	content["IconTextDate" .. i].AnimationGroup.Rotation:SetStartDelay(0.05 * i)
	content["IconTextDate" .. i].AnimationGroup.Rotation:SetDuration(0)
	content["IconTextDate" .. i].AnimationGroup.Rotation:SetOrder(1)
	content["IconTextDate" .. i].AnimationGroup.Rotation:SetEndDelay(0)
	content["IconTextDate" .. i].AnimationGroup.Rotation:SetSmoothing("OUT")
	content["IconTextDate" .. i].AnimationGroup.Rotation:SetOffset(-30, 0)

	content["IconTextDate" .. i].AnimationGroup.Rotation2 = content["IconTextDate" .. i].AnimationGroup:CreateAnimation("Translation")
	content["IconTextDate" .. i].AnimationGroup.Rotation2:SetDuration(0.5)
	content["IconTextDate" .. i].AnimationGroup.Rotation2:SetOrder(2)
	content["IconTextDate" .. i].AnimationGroup.Rotation2:SetSmoothing("OUT")
	content["IconTextDate" .. i].AnimationGroup.Rotation2:SetOffset(30, 0)

	content["CheckBox" .. i] = CreateFrame("CheckButton", nil, content, "ChatConfigSmallCheckButtonTemplate")
	content["CheckBox" .. i]:SetPoint("TOPRIGHT", -03, -50 - 60 * (i - 1))
	content["CheckBox" .. i]:RegisterForClicks("AnyUp")
	content["CheckBox" .. i]:SetScript("OnClick", function(self)
		if (self:GetChecked()) then
			AddTrackedAchievement(self.Achievement)
		else
			RemoveTrackedAchievement(self.Achievement)
		end
	end)

	content["CheckBoxText" .. i] = content:CreateFontString(nil)
	content["CheckBoxText" .. i]:SetFont("Fonts\\FRIZQT__.ttf", 9)
	content["CheckBoxText" .. i]:SetFontObject(GameFontNormal)
	content["CheckBoxText" .. i]:SetPoint("TOPRIGHT", -25, -55 - 60 * (i - 1))
	content["CheckBoxText" .. i]:SetShadowOffset(0, -1)
	content["CheckBoxText" .. i]:SetSize(70, 23)
	content["CheckBoxText" .. i]:SetText("Track")
	content["CheckBoxText" .. i]:SetJustifyH("RIGHT")
	content["CheckBoxText" .. i]:SetJustifyV("TOP")

	content["SPCounter" .. i] = content:CreateTexture(nil, "BORDER")
	content["SPCounter" .. i]:SetSize(32, 32)
	content["SPCounter" .. i]:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\Border_points")
	content["SPCounter" .. i]:SetPoint("TOPRIGHT", -10, -20 - 60 * (i - 1))

	content["SPCounter" .. i].AnimationGroup = content["SPCounter" .. i]:CreateAnimationGroup()
	content["SPCounter" .. i].AnimationGroup.Rotation = content["SPCounter" .. i].AnimationGroup:CreateAnimation("Translation")
	content["SPCounter" .. i].AnimationGroup.Rotation:SetStartDelay(0.05 * i)
	content["SPCounter" .. i].AnimationGroup.Rotation:SetDuration(0)
	content["SPCounter" .. i].AnimationGroup.Rotation:SetOrder(1)
	content["SPCounter" .. i].AnimationGroup.Rotation:SetEndDelay(0)
	content["SPCounter" .. i].AnimationGroup.Rotation:SetSmoothing("OUT")
	content["SPCounter" .. i].AnimationGroup.Rotation:SetOffset(-30, 0)

	content["SPCounter" .. i].AnimationGroup.Rotation2 = content["SPCounter" .. i].AnimationGroup:CreateAnimation("Translation")
	content["SPCounter" .. i].AnimationGroup.Rotation2:SetDuration(0.5)
	content["SPCounter" .. i].AnimationGroup.Rotation2:SetOrder(2)
	content["SPCounter" .. i].AnimationGroup.Rotation2:SetSmoothing("OUT")
	content["SPCounter" .. i].AnimationGroup.Rotation2:SetOffset(30, 0)

	content["SPCounterBorder" .. i] = content:CreateTexture(nil, "ARTWORK")
	content["SPCounterBorder" .. i]:SetSize(32, 32)
	content["SPCounterBorder" .. i]:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\Border_points_highlight")
	content["SPCounterBorder" .. i]:SetPoint("TOPRIGHT", -10, -20 - 60 * (i - 1))
	content["SPCounterBorder" .. i]:SetBlendMode("ADD")

	content["BG" .. i]:SetScript("OnUpdate", function(self)
		local SPCounterBorder = self:GetParent()["SPCounterBorder"..i]
		if not SPCounterBorder.AnimG:IsPlaying() then 
			SPCounterBorder.AnimG:Play() 
		end
	end)

	content["SPCounterBorder" .. i].AnimationGroup = content["SPCounterBorder" .. i]:CreateAnimationGroup()
	content["SPCounterBorder" .. i].AnimationGroup.Rotation = content["SPCounterBorder" .. i].AnimationGroup:CreateAnimation("Translation")
	content["SPCounterBorder" .. i].AnimationGroup.Rotation:SetStartDelay(0.05 * i)
	content["SPCounterBorder" .. i].AnimationGroup.Rotation:SetDuration(0)
	content["SPCounterBorder" .. i].AnimationGroup.Rotation:SetOrder(1)
	content["SPCounterBorder" .. i].AnimationGroup.Rotation:SetEndDelay(0)
	content["SPCounterBorder" .. i].AnimationGroup.Rotation:SetSmoothing("OUT")
	content["SPCounterBorder" .. i].AnimationGroup.Rotation:SetOffset(-30, 0)

	content["SPCounterBorder" .. i].AnimationGroup.Rotation2 = content["SPCounterBorder" .. i].AnimationGroup:CreateAnimation("Translation")
	content["SPCounterBorder" .. i].AnimationGroup.Rotation2:SetDuration(0.5)
	content["SPCounterBorder" .. i].AnimationGroup.Rotation2:SetOrder(2)
	content["SPCounterBorder" .. i].AnimationGroup.Rotation2:SetSmoothing("OUT")
	content["SPCounterBorder" .. i].AnimationGroup.Rotation2:SetOffset(30, 0)

	content["SPCounterBorder" .. i].AnimG = content["SPCounterBorder" .. i]:CreateAnimationGroup()
	content["SPCounterBorder" .. i].AnimG.Rotation = content["SPCounterBorder" .. i].AnimG:CreateAnimation("Rotation")
	content["SPCounterBorder" .. i].AnimG.Rotation:SetDuration(10)
	content["SPCounterBorder" .. i].AnimG.Rotation:SetOrder(1)
	content["SPCounterBorder" .. i].AnimG.Rotation:SetEndDelay(0)
	content["SPCounterBorder" .. i].AnimG.Rotation:SetSmoothing("NONE")
	content["SPCounterBorder" .. i].AnimG.Rotation:SetDegrees(-360)

	content["SPCounterTextMain" .. i] = content:CreateFontString(nil)
	content["SPCounterTextMain" .. i]:SetFont("Fonts\\FRIZQT__.ttf", 12)
	content["SPCounterTextMain" .. i]:SetFontObject(GameFontHighlight)
	content["SPCounterTextMain" .. i]:SetPoint("TOPRIGHT", -10, -20 - 60 * (i - 1))
	content["SPCounterTextMain" .. i]:SetShadowOffset(0, -1)
	content["SPCounterTextMain" .. i]:SetSize(32, 32)
	content["SPCounterTextMain" .. i]:SetText("1")
	content["SPCounterTextMain" .. i]:SetJustifyH("CENTER")

	content["SPCounterTextMain" .. i].AnimationGroup = content["SPCounterTextMain" .. i]:CreateAnimationGroup()
	content["SPCounterTextMain" .. i].AnimationGroup.Rotation = content["SPCounterTextMain" .. i].AnimationGroup:CreateAnimation("Translation")
	content["SPCounterTextMain" .. i].AnimationGroup.Rotation:SetStartDelay(0.05 * i)
	content["SPCounterTextMain" .. i].AnimationGroup.Rotation:SetDuration(0)
	content["SPCounterTextMain" .. i].AnimationGroup.Rotation:SetOrder(1)
	content["SPCounterTextMain" .. i].AnimationGroup.Rotation:SetEndDelay(0)
	content["SPCounterTextMain" .. i].AnimationGroup.Rotation:SetSmoothing("OUT")
	content["SPCounterTextMain" .. i].AnimationGroup.Rotation:SetOffset(-30, 0)

	content["SPCounterTextMain" .. i].AnimationGroup.Rotation2 = content["SPCounterTextMain" .. i].AnimationGroup:CreateAnimation("Translation")
	content["SPCounterTextMain" .. i].AnimationGroup.Rotation2:SetDuration(0.5)
	content["SPCounterTextMain" .. i].AnimationGroup.Rotation2:SetOrder(2)
	content["SPCounterTextMain" .. i].AnimationGroup.Rotation2:SetSmoothing("OUT")
	content["SPCounterTextMain" .. i].AnimationGroup.Rotation2:SetOffset(30, 0)
end

content_fake.IconBG_BIG = content_fake:CreateTexture(nil, "BACKGROUND")
content_fake.IconBG_BIG:SetSize(116, 116)
content_fake.IconBG_BIG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\DragonHighlight_green")
content_fake.IconBG_BIG:SetPoint("TOPRIGHT", 35, 92 - 60 * 4)
content_fake.IconBG_BIG:SetBlendMode("ADD")

content_fake.IconBG_BIG.AnimG = content_fake.IconBG_BIG:CreateAnimationGroup()
content_fake.IconBG_BIG.AnimG.Rotation = content_fake.IconBG_BIG.AnimG:CreateAnimation("Rotation")
content_fake.IconBG_BIG.AnimG.Rotation:SetDuration(60)
content_fake.IconBG_BIG.AnimG.Rotation:SetOrder(1)
content_fake.IconBG_BIG.AnimG.Rotation:SetEndDelay(0)
content_fake.IconBG_BIG.AnimG.Rotation:SetSmoothing("NONE")
content_fake.IconBG_BIG.AnimG.Rotation:SetDegrees(-360)

content_fake.IconBG_BIG.AnimationGroup = content_fake.IconBG_BIG:CreateAnimationGroup()
content_fake.IconBG_BIG.AnimationGroup.Rotation = content_fake.IconBG_BIG.AnimationGroup:CreateAnimation("Translation")
content_fake.IconBG_BIG.AnimationGroup.Rotation:SetStartDelay(0.05 * 4)
content_fake.IconBG_BIG.AnimationGroup.Rotation:SetDuration(0)
content_fake.IconBG_BIG.AnimationGroup.Rotation:SetOrder(1)
content_fake.IconBG_BIG.AnimationGroup.Rotation:SetEndDelay(0)
content_fake.IconBG_BIG.AnimationGroup.Rotation:SetSmoothing("OUT")
content_fake.IconBG_BIG.AnimationGroup.Rotation:SetOffset(-30, 0)

content_fake.IconBG_BIG.AnimationGroup.Rotation2 = content_fake.IconBG_BIG.AnimationGroup:CreateAnimation("Translation")
content_fake.IconBG_BIG.AnimationGroup.Rotation2:SetDuration(0.5)
content_fake.IconBG_BIG.AnimationGroup.Rotation2:SetOrder(2)
content_fake.IconBG_BIG.AnimationGroup.Rotation2:SetSmoothing("OUT")
content_fake.IconBG_BIG.AnimationGroup.Rotation2:SetOffset(30, 0)

content_fake.BG_BIGChallenge = CreateFrame("BUTTON", nil, content_fake)
content_fake.BG_BIGChallenge:SetSize(250, 58)
content_fake.BG_BIGChallenge:SetPoint("TOP", 0, -3 - 60 * 4)
content_fake.BG_BIGChallenge:SetHighlightTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\LevelUpTex_Green")
content_fake.BG_BIGChallenge:GetHighlightTexture():SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
content_fake.BG_BIGChallenge:GetHighlightTexture():ClearAllPoints()
content_fake.BG_BIGChallenge:GetHighlightTexture():SetSize(200, 7)
content_fake.BG_BIGChallenge:GetHighlightTexture():SetPoint("CENTER", 0, 8)

content_fake.BG_BIGChallenge:SetScript("OnUpdate", function(self)
	local IconBG_BIG = self:GetParent().IconBG_BIG
	if not (IconBG_BIG.AnimG:IsPlaying()) then
		IconBG_BIG.AnimG:Play() 
	end
end)

content_fake.Icon_BIGChallenge = content_fake:CreateTexture(nil, "BORDER")
content_fake.Icon_BIGChallenge:SetSize(40, 40)
content_fake.Icon_BIGChallenge:SetTexture("Interface\\icons\\FoxMountIcon")
content_fake.Icon_BIGChallenge:SetPoint("TOPLEFT", 10, -12 - 60 * 4)

content_fake.Icon_BIGChallenge.AnimationGroup = content_fake.Icon_BIGChallenge:CreateAnimationGroup()
content_fake.Icon_BIGChallenge.AnimationGroup.Rotation = content_fake.Icon_BIGChallenge.AnimationGroup:CreateAnimation("Translation")
content_fake.Icon_BIGChallenge.AnimationGroup.Rotation:SetStartDelay(0.05 * 4)
content_fake.Icon_BIGChallenge.AnimationGroup.Rotation:SetDuration(0)
content_fake.Icon_BIGChallenge.AnimationGroup.Rotation:SetOrder(1)
content_fake.Icon_BIGChallenge.AnimationGroup.Rotation:SetEndDelay(0)
content_fake.Icon_BIGChallenge.AnimationGroup.Rotation:SetSmoothing("OUT")
content_fake.Icon_BIGChallenge.AnimationGroup.Rotation:SetOffset(-30, 0)

content_fake.Icon_BIGChallenge.AnimationGroup.Rotation2 = content_fake.Icon_BIGChallenge.AnimationGroup:CreateAnimation("Translation")
content_fake.Icon_BIGChallenge.AnimationGroup.Rotation2:SetDuration(0.5)
content_fake.Icon_BIGChallenge.AnimationGroup.Rotation2:SetOrder(2)
content_fake.Icon_BIGChallenge.AnimationGroup.Rotation2:SetSmoothing("OUT")
content_fake.Icon_BIGChallenge.AnimationGroup.Rotation2:SetOffset(30, 0)

content_fake.IconBorder_BIGChallenge = content_fake:CreateTexture(nil, "ARTWORK")
content_fake.IconBorder_BIGChallenge:SetSize(40, 40)
content_fake.IconBorder_BIGChallenge:SetTexture("Interface\\Addons\\AwAddons\\Textures\\SpellKit\\ArtifactPower-QuestBorder")
content_fake.IconBorder_BIGChallenge:SetPoint("TOPLEFT", 10, -12 - 60 * 4)

content_fake.IconBorder_BIGChallenge.AnimationGroup = content_fake.IconBorder_BIGChallenge:CreateAnimationGroup()
content_fake.IconBorder_BIGChallenge.AnimationGroup.Rotation = content_fake.IconBorder_BIGChallenge.AnimationGroup:CreateAnimation("Translation")
content_fake.IconBorder_BIGChallenge.AnimationGroup.Rotation:SetStartDelay(0.05 * 4)
content_fake.IconBorder_BIGChallenge.AnimationGroup.Rotation:SetDuration(0)
content_fake.IconBorder_BIGChallenge.AnimationGroup.Rotation:SetOrder(1)
content_fake.IconBorder_BIGChallenge.AnimationGroup.Rotation:SetEndDelay(0)
content_fake.IconBorder_BIGChallenge.AnimationGroup.Rotation:SetSmoothing("OUT")
content_fake.IconBorder_BIGChallenge.AnimationGroup.Rotation:SetOffset(-30, 0)

content_fake.IconBorder_BIGChallenge.AnimationGroup.Rotation2 = content_fake.IconBorder_BIGChallenge.AnimationGroup:CreateAnimation("Translation")
content_fake.IconBorder_BIGChallenge.AnimationGroup.Rotation2:SetDuration(0.5)
content_fake.IconBorder_BIGChallenge.AnimationGroup.Rotation2:SetOrder(2)
content_fake.IconBorder_BIGChallenge.AnimationGroup.Rotation2:SetSmoothing("OUT")
content_fake.IconBorder_BIGChallenge.AnimationGroup.Rotation2:SetOffset(30, 0)

content_fake.IconTextMain_BIGChallenge = content_fake:CreateFontString(nil)
content_fake.IconTextMain_BIGChallenge:SetFont("Fonts\\FRIZQT__.ttf", 11)
content_fake.IconTextMain_BIGChallenge:SetFontObject(GameFontHighlight)
content_fake.IconTextMain_BIGChallenge:SetPoint("TOP", 0, -2 - 60 * 4)
content_fake.IconTextMain_BIGChallenge:SetShadowOffset(0, -1)
content_fake.IconTextMain_BIGChallenge:SetSize(190, 24)
content_fake.IconTextMain_BIGChallenge:SetText("Misty Fox")
content_fake.IconTextMain_BIGChallenge:SetJustifyH("CENTER")
content_fake.IconTextMain_BIGChallenge:SetJustifyV("BOTTOM")

content_fake.IconTextMain_BIGChallenge.AnimationGroup = content_fake.IconTextMain_BIGChallenge:CreateAnimationGroup()
content_fake.IconTextMain_BIGChallenge.AnimationGroup.Rotation = content_fake.IconTextMain_BIGChallenge.AnimationGroup:CreateAnimation("Translation")
content_fake.IconTextMain_BIGChallenge.AnimationGroup.Rotation:SetStartDelay(0.05 * 4)
content_fake.IconTextMain_BIGChallenge.AnimationGroup.Rotation:SetDuration(0)
content_fake.IconTextMain_BIGChallenge.AnimationGroup.Rotation:SetOrder(1)
content_fake.IconTextMain_BIGChallenge.AnimationGroup.Rotation:SetEndDelay(0)
content_fake.IconTextMain_BIGChallenge.AnimationGroup.Rotation:SetSmoothing("OUT")
content_fake.IconTextMain_BIGChallenge.AnimationGroup.Rotation:SetOffset(-30, 0)

content_fake.IconTextMain_BIGChallenge.AnimationGroup.Rotation2 = content_fake.IconTextMain_BIGChallenge.AnimationGroup:CreateAnimation("Translation")
content_fake.IconTextMain_BIGChallenge.AnimationGroup.Rotation2:SetDuration(0.5)
content_fake.IconTextMain_BIGChallenge.AnimationGroup.Rotation2:SetOrder(2)
content_fake.IconTextMain_BIGChallenge.AnimationGroup.Rotation2:SetSmoothing("OUT")
content_fake.IconTextMain_BIGChallenge.AnimationGroup.Rotation2:SetOffset(30, 0)

content_fake.IconTextSub_BIGChallenge = content_fake:CreateFontString(nil)
content_fake.IconTextSub_BIGChallenge:SetFont("Fonts\\FRIZQT__.ttf", 10)
content_fake.IconTextSub_BIGChallenge:SetFontObject(GameFontHighlight)
content_fake.IconTextSub_BIGChallenge:SetPoint("TOP", 0, -35 - 60 * 4)
content_fake.IconTextSub_BIGChallenge:SetShadowOffset(0, -1)
content_fake.IconTextSub_BIGChallenge:SetSize(190, 23)
content_fake.IconTextSub_BIGChallenge:SetText("Kill Misty Fox")
content_fake.IconTextSub_BIGChallenge:SetJustifyH("CENTER")
content_fake.IconTextSub_BIGChallenge:SetJustifyV("TOP")

content_fake.IconTextSub_BIGChallenge.AnimationGroup = content_fake.IconTextSub_BIGChallenge:CreateAnimationGroup()
content_fake.IconTextSub_BIGChallenge.AnimationGroup.Rotation = content_fake.IconTextSub_BIGChallenge.AnimationGroup:CreateAnimation("Translation")
content_fake.IconTextSub_BIGChallenge.AnimationGroup.Rotation:SetStartDelay(0.05 * 4)
content_fake.IconTextSub_BIGChallenge.AnimationGroup.Rotation:SetDuration(0)
content_fake.IconTextSub_BIGChallenge.AnimationGroup.Rotation:SetOrder(1)
content_fake.IconTextSub_BIGChallenge.AnimationGroup.Rotation:SetEndDelay(0)
content_fake.IconTextSub_BIGChallenge.AnimationGroup.Rotation:SetSmoothing("OUT")
content_fake.IconTextSub_BIGChallenge.AnimationGroup.Rotation:SetOffset(-30, 0)

content_fake.IconTextSub_BIGChallenge.AnimationGroup.Rotation2 = content_fake.IconTextSub_BIGChallenge.AnimationGroup:CreateAnimation("Translation")
content_fake.IconTextSub_BIGChallenge.AnimationGroup.Rotation2:SetDuration(0.5)
content_fake.IconTextSub_BIGChallenge.AnimationGroup.Rotation2:SetOrder(2)
content_fake.IconTextSub_BIGChallenge.AnimationGroup.Rotation2:SetSmoothing("OUT")
content_fake.IconTextSub_BIGChallenge.AnimationGroup.Rotation2:SetOffset(30, 0)

content_fake.IconTextDate_BIGChallenge = content_fake:CreateFontString(nil)
content_fake.IconTextDate_BIGChallenge:SetFont("Fonts\\FRIZQT__.ttf", 9)
content_fake.IconTextDate_BIGChallenge:SetFontObject(GameFontHighlight)
content_fake.IconTextDate_BIGChallenge:SetPoint("TOPRIGHT", -10, -50 - 60 * 4)
content_fake.IconTextDate_BIGChallenge:SetShadowOffset(0, -1)
content_fake.IconTextDate_BIGChallenge:SetSize(70, 23)
content_fake.IconTextDate_BIGChallenge:SetText("08/01/2018")
content_fake.IconTextDate_BIGChallenge:SetJustifyH("RIGHT")
content_fake.IconTextDate_BIGChallenge:SetJustifyV("TOP")

content_fake.IconTextDate_BIGChallenge.AnimationGroup = content_fake.IconTextDate_BIGChallenge:CreateAnimationGroup()
content_fake.IconTextDate_BIGChallenge.AnimationGroup.Rotation = content_fake.IconTextDate_BIGChallenge.AnimationGroup:CreateAnimation("Translation")
content_fake.IconTextDate_BIGChallenge.AnimationGroup.Rotation:SetStartDelay(0.05 * 4)
content_fake.IconTextDate_BIGChallenge.AnimationGroup.Rotation:SetDuration(0)
content_fake.IconTextDate_BIGChallenge.AnimationGroup.Rotation:SetOrder(1)
content_fake.IconTextDate_BIGChallenge.AnimationGroup.Rotation:SetEndDelay(0)
content_fake.IconTextDate_BIGChallenge.AnimationGroup.Rotation:SetSmoothing("OUT")
content_fake.IconTextDate_BIGChallenge.AnimationGroup.Rotation:SetOffset(-30, 0)

content_fake.IconTextDate_BIGChallenge.AnimationGroup.Rotation2 = content_fake.IconTextDate_BIGChallenge.AnimationGroup:CreateAnimation("Translation")
content_fake.IconTextDate_BIGChallenge.AnimationGroup.Rotation2:SetDuration(0.5)
content_fake.IconTextDate_BIGChallenge.AnimationGroup.Rotation2:SetOrder(2)
content_fake.IconTextDate_BIGChallenge.AnimationGroup.Rotation2:SetSmoothing("OUT")
content_fake.IconTextDate_BIGChallenge.AnimationGroup.Rotation2:SetOffset(30, 0)

content_fake.CheckBox_BIGChallenge = CreateFrame("CheckButton", nil, content_fake, "ChatConfigSmallCheckButtonTemplate")
content_fake.CheckBox_BIGChallenge:SetPoint("TOPRIGHT", -03, -45 - 60 * 4)
content_fake.CheckBox_BIGChallenge:RegisterForClicks("AnyUp")
content_fake.CheckBox_BIGChallenge:SetScript("OnClick", function(self)
	if (self:GetChecked()) then
		AddTrackedAchievement(BigChallenges[CurrentBigChallenge])
	else
		RemoveTrackedAchievement(BigChallenges[CurrentBigChallenge])
	end
end)

content_fake.CheckBoxText_BIGChallenge = content_fake:CreateFontString(nil)
content_fake.CheckBoxText_BIGChallenge:SetFont("Fonts\\FRIZQT__.ttf", 9)
content_fake.CheckBoxText_BIGChallenge:SetFontObject(GameFontNormal)
content_fake.CheckBoxText_BIGChallenge:SetPoint("TOPRIGHT", -25, -50 - 60 * 4)
content_fake.CheckBoxText_BIGChallenge:SetShadowOffset(0, -1)
content_fake.CheckBoxText_BIGChallenge:SetSize(70, 23)
content_fake.CheckBoxText_BIGChallenge:SetText("Track")
content_fake.CheckBoxText_BIGChallenge:SetJustifyH("RIGHT")
content_fake.CheckBoxText_BIGChallenge:SetJustifyV("TOP")

content_fake.SPCounter_BIG = content_fake:CreateTexture(nil, "BORDER")
content_fake.SPCounter_BIG:SetSize(28, 28)
content_fake.SPCounter_BIG:SetTexture("Interface\\Addons\\AwAddons\\Textures\\SpellKit\\ArtifactPower-QuestBorder")
content_fake.SPCounter_BIG:SetPoint("TOPRIGHT", -10, -12 - 60 * 4)

content_fake.SPCounter_BIG.AnimationGroup = content_fake.SPCounter_BIG:CreateAnimationGroup()
content_fake.SPCounter_BIG.AnimationGroup.Rotation = content_fake.SPCounter_BIG.AnimationGroup:CreateAnimation("Translation")
content_fake.SPCounter_BIG.AnimationGroup.Rotation:SetStartDelay(0.05 * 4)
content_fake.SPCounter_BIG.AnimationGroup.Rotation:SetDuration(0)
content_fake.SPCounter_BIG.AnimationGroup.Rotation:SetOrder(1)
content_fake.SPCounter_BIG.AnimationGroup.Rotation:SetEndDelay(0)
content_fake.SPCounter_BIG.AnimationGroup.Rotation:SetSmoothing("OUT")
content_fake.SPCounter_BIG.AnimationGroup.Rotation:SetOffset(-30, 0)

content_fake.SPCounter_BIG.AnimationGroup.Rotation2 = content_fake.SPCounter_BIG.AnimationGroup:CreateAnimation("Translation")
content_fake.SPCounter_BIG.AnimationGroup.Rotation2:SetDuration(0.5)
content_fake.SPCounter_BIG.AnimationGroup.Rotation2:SetOrder(2)
content_fake.SPCounter_BIG.AnimationGroup.Rotation2:SetEndDelay(15)
content_fake.SPCounter_BIG.AnimationGroup.Rotation2:SetSmoothing("OUT")
content_fake.SPCounter_BIG.AnimationGroup.Rotation2:SetOffset(30, 0)

content_fake.SPCounterBorder_BIG = content_fake:CreateTexture(nil, "ARTWORK")
content_fake.SPCounterBorder_BIG:SetSize(28, 28)
content_fake.SPCounterBorder_BIG:SetTexture("Interface\\icons\\INV_Chest_Awakening")
content_fake.SPCounterBorder_BIG:SetPoint("TOPRIGHT", -10, -12 - 60 * 4)

content_fake.SPCounterBorder_BIG.AnimationGroup = content_fake.SPCounterBorder_BIG:CreateAnimationGroup()
content_fake.SPCounterBorder_BIG.AnimationGroup.Rotation = content_fake.SPCounterBorder_BIG.AnimationGroup:CreateAnimation("Translation")
content_fake.SPCounterBorder_BIG.AnimationGroup.Rotation:SetStartDelay(0.05 * 4)
content_fake.SPCounterBorder_BIG.AnimationGroup.Rotation:SetDuration(0)
content_fake.SPCounterBorder_BIG.AnimationGroup.Rotation:SetOrder(1)
content_fake.SPCounterBorder_BIG.AnimationGroup.Rotation:SetEndDelay(0)
content_fake.SPCounterBorder_BIG.AnimationGroup.Rotation:SetSmoothing("OUT")
content_fake.SPCounterBorder_BIG.AnimationGroup.Rotation:SetOffset(-30, 0)

content_fake.SPCounterBorder_BIG.AnimationGroup.Rotation2 = content_fake.SPCounterBorder_BIG.AnimationGroup:CreateAnimation("Translation")
content_fake.SPCounterBorder_BIG.AnimationGroup.Rotation2:SetDuration(0.5)
content_fake.SPCounterBorder_BIG.AnimationGroup.Rotation2:SetOrder(2)
content_fake.SPCounterBorder_BIG.AnimationGroup.Rotation2:SetSmoothing("OUT")
content_fake.SPCounterBorder_BIG.AnimationGroup.Rotation2:SetOffset(30, 0)

content_fake.SPCounterReward_BIG = content_fake:CreateTexture(nil, "OVERLAY")
content_fake.SPCounterReward_BIG:SetSize(22, 22)
content_fake.SPCounterReward_BIG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\Pickup")
content_fake.SPCounterReward_BIG:SetPoint("TOPRIGHT", -26, -29 - 60 * 4)

content_fake.SPCounterReward_BIG.AnimationGroup = content_fake.SPCounterReward_BIG:CreateAnimationGroup()
content_fake.SPCounterReward_BIG.AnimationGroup.Rotation = content_fake.SPCounterReward_BIG.AnimationGroup:CreateAnimation("Translation")
content_fake.SPCounterReward_BIG.AnimationGroup.Rotation:SetStartDelay(0.05 * 4)
content_fake.SPCounterReward_BIG.AnimationGroup.Rotation:SetDuration(0)
content_fake.SPCounterReward_BIG.AnimationGroup.Rotation:SetOrder(1)
content_fake.SPCounterReward_BIG.AnimationGroup.Rotation:SetEndDelay(0)
content_fake.SPCounterReward_BIG.AnimationGroup.Rotation:SetSmoothing("OUT")
content_fake.SPCounterReward_BIG.AnimationGroup.Rotation:SetOffset(-30, 0)

content_fake.SPCounterReward_BIG.AnimationGroup.Rotation2 = content_fake.SPCounterReward_BIG.AnimationGroup:CreateAnimation("Translation")
content_fake.SPCounterReward_BIG.AnimationGroup.Rotation2:SetDuration(0.5)
content_fake.SPCounterReward_BIG.AnimationGroup.Rotation2:SetOrder(2)
content_fake.SPCounterReward_BIG.AnimationGroup.Rotation2:SetSmoothing("OUT")
content_fake.SPCounterReward_BIG.AnimationGroup.Rotation2:SetOffset(30, 0)

-------------------------------------------------------------------------------
--                             Description Block                             --
-------------------------------------------------------------------------------

Collection.DescriptionMain = CreateFrame("Model", nil, Collection)
Collection.DescriptionMain:SetSize(512, 512)
Collection.DescriptionMain:SetPoint("RIGHT", 140, -100)
Collection.DescriptionMain:SetFrameLevel(4)

Collection.DescriptionMain.Art = Collection.DescriptionMain:CreateTexture(nil, "ARTWORK", nil, 2)
Collection.DescriptionMain.Art:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\RewardName_Highlight")
Collection.DescriptionMain.Art:SetSize(360, 90)
Collection.DescriptionMain.Art:SetPoint("TOP", 12, -20)
Collection.DescriptionMain.Art.AnimationGroup = Collection.DescriptionMain.Art:CreateAnimationGroup()

Collection.DescriptionMain.Art.AnimationGroup.Alpha_Init = Collection.DescriptionMain.Art.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.Art.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.DescriptionMain.Art.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.DescriptionMain.Art.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.DescriptionMain.Art.AnimationGroup.Alpha_FadeIn = Collection.DescriptionMain.Art.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.Art.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.DescriptionMain.Art.AnimationGroup.Alpha_FadeIn:SetDuration(0.6)
Collection.DescriptionMain.Art.AnimationGroup.Alpha_FadeIn:SetOrder(2)
Collection.DescriptionMain.Art.AnimationGroup.Alpha_FadeIn:SetStartDelay(0.5)

Collection.DescriptionMain.Icon = Collection.DescriptionMain:CreateTexture(nil, "BORDER", nil, 2)
Collection.DescriptionMain.Icon:SetSize(22, 22)
Collection.DescriptionMain.Icon:SetPoint("TOP", -90, -41)
SetPortraitToTexture(Collection.DescriptionMain.Icon, "Interface\\icons\\misc_draftmode")
Collection.DescriptionMain.Icon.AnimationGroup = Collection.DescriptionMain.Icon:CreateAnimationGroup()

Collection.DescriptionMain.Icon.AnimationGroup.Alpha_Init = Collection.DescriptionMain.Icon.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.Icon.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.DescriptionMain.Icon.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.DescriptionMain.Icon.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.DescriptionMain.Icon.AnimationGroup.Alpha_FadeIn = Collection.DescriptionMain.Icon.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.Icon.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.DescriptionMain.Icon.AnimationGroup.Alpha_FadeIn:SetDuration(0.6)
Collection.DescriptionMain.Icon.AnimationGroup.Alpha_FadeIn:SetOrder(2)
Collection.DescriptionMain.Icon.AnimationGroup.Alpha_FadeIn:SetStartDelay(0.5)

Collection.DescriptionMain.TitleText = Collection.DescriptionMain:CreateFontString()
Collection.DescriptionMain.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 11)
Collection.DescriptionMain.TitleText:SetFontObject(GameFontNormal)
Collection.DescriptionMain.TitleText:SetPoint("TOP", 0, -9)
Collection.DescriptionMain.TitleText:SetShadowOffset(1, -1)
Collection.DescriptionMain.TitleText:SetSize(360, 90)
Collection.DescriptionMain.TitleText:SetText(MAIN_DESCRIPTION_TITLE)

Collection.DescriptionMain.TitleText.AnimationGroup = Collection.DescriptionMain.TitleText:CreateAnimationGroup()

Collection.DescriptionMain.TitleText.AnimationGroup.Alpha_Init = Collection.DescriptionMain.TitleText.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.TitleText.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.DescriptionMain.TitleText.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.DescriptionMain.TitleText.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.DescriptionMain.TitleText.AnimationGroup.Alpha_FadeIn = Collection.DescriptionMain.TitleText.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.TitleText.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.DescriptionMain.TitleText.AnimationGroup.Alpha_FadeIn:SetDuration(0.6)
Collection.DescriptionMain.TitleText.AnimationGroup.Alpha_FadeIn:SetOrder(2)
Collection.DescriptionMain.TitleText.AnimationGroup.Alpha_FadeIn:SetStartDelay(0.5)

Collection.DescriptionMain.SubText = Collection.DescriptionMain:CreateFontString()
Collection.DescriptionMain.SubText:SetFont("Fonts\\FRIZQT__.TTF", 11)
Collection.DescriptionMain.SubText:SetFontObject(GameFontHighlight)
Collection.DescriptionMain.SubText:SetPoint("TOP", 5, -69)
Collection.DescriptionMain.SubText:SetShadowOffset(1, -1)
Collection.DescriptionMain.SubText:SetSize(180, 128)
Collection.DescriptionMain.SubText:SetJustifyH("LEFT")
Collection.DescriptionMain.SubText:SetJustifyV("TOP")
Collection.DescriptionMain.SubText:SetText(MAIN_DESCRIPTION_TEXT)

Collection.DescriptionMain.SubText.AnimationGroup = Collection.DescriptionMain.SubText:CreateAnimationGroup()

Collection.DescriptionMain.SubText.AnimationGroup.Alpha_Init = Collection.DescriptionMain.SubText.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.SubText.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.DescriptionMain.SubText.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.DescriptionMain.SubText.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.DescriptionMain.SubText.AnimationGroup.Alpha_FadeIn = Collection.DescriptionMain.SubText.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.SubText.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.DescriptionMain.SubText.AnimationGroup.Alpha_FadeIn:SetDuration(0.6)
Collection.DescriptionMain.SubText.AnimationGroup.Alpha_FadeIn:SetOrder(2)
Collection.DescriptionMain.SubText.AnimationGroup.Alpha_FadeIn:SetStartDelay(0.5)

Collection.DescriptionMain.AnimTex = Collection.DescriptionMain:CreateTexture(nil, "BACKGROUND")
Collection.DescriptionMain.AnimTex:SetTexture("Interface\\Addons\\AwAddons\\Textures\\SpellKit\\Talent_Bg_animTex")
Collection.DescriptionMain.AnimTex:SetSize(496, 60)
Collection.DescriptionMain.AnimTex:SetPoint("TOP", 0, -18)
Collection.DescriptionMain.AnimTex:SetBlendMode("ADD")
Collection.DescriptionMain.AnimTex:SetAlpha(0)

Collection.DescriptionMain.AnimTex_Add = Collection.DescriptionMain:CreateTexture(nil, "OVERLAY")
Collection.DescriptionMain.AnimTex_Add:SetTexture("Interface\\Addons\\AwAddons\\Textures\\SpellKit\\Talent_Bg_animTex")
Collection.DescriptionMain.AnimTex_Add:SetSize(68, 5)
Collection.DescriptionMain.AnimTex_Add:SetPoint("TOP", 0, -58)
Collection.DescriptionMain.AnimTex_Add:SetBlendMode("ADD")
Collection.DescriptionMain.AnimTex_Add:SetAlpha(0)

Collection.DescriptionMain.AnimTex_Add.AnimationGroup = Collection.DescriptionMain.AnimTex_Add:CreateAnimationGroup()

Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Alpha_Init = Collection.DescriptionMain.AnimTex_Add.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Translation_Init = Collection.DescriptionMain.AnimTex_Add.AnimationGroup:CreateAnimation("Translation")
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Translation_Init:SetOffset(-50, 0)
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Translation_Init:SetDuration(0)
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Translation_Init:SetOrder(1)

Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Alpha_FadeIn = Collection.DescriptionMain.AnimTex_Add.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Alpha_FadeIn:SetDuration(1.5)
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Alpha_FadeIn:SetOrder(2)

Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Translation = Collection.DescriptionMain.AnimTex_Add.AnimationGroup:CreateAnimation("Translation")
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Translation:SetOffset(150, 0)
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Translation:SetDuration(3)
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Translation:SetSmoothing("IN")
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Translation:SetOrder(2)

Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Alpha_FadeOut = Collection.DescriptionMain.AnimTex_Add.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Alpha_FadeOut:SetChange(-1)
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Alpha_FadeOut:SetDuration(0.6)
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Alpha_FadeOut:SetOrder(2)
Collection.DescriptionMain.AnimTex_Add.AnimationGroup.Alpha_FadeOut:SetStartDelay(1.5)

Collection.DescriptionMain.Art:Hide()
Collection.DescriptionMain.Icon:Hide()
Collection.DescriptionMain.TitleText:Hide()
Collection.DescriptionMain.SubText:Hide()
Collection.DescriptionMain.AnimTex:Hide()

Collection.DescriptionMain.AnimTex.AnimationGroup = Collection.DescriptionMain.AnimTex:CreateAnimationGroup()
Collection.DescriptionMain.AnimTex.AnimationGroup:SetScript("OnPlay", function()
	Collection.DescriptionMain.Art:Show()
	Collection.DescriptionMain.Icon:Show()
	Collection.DescriptionMain.TitleText:Show()
	Collection.DescriptionMain.SubText:Show()
	Collection.DescriptionMain.AnimTex:Show()

	Collection.DescriptionMain.Art.AnimationGroup:Play()
	Collection.DescriptionMain.Icon.AnimationGroup:Play()
	Collection.DescriptionMain.TitleText.AnimationGroup:Play()
	Collection.DescriptionMain.SubText.AnimationGroup:Play()
end)

Collection.DescriptionMain.AnimTex.AnimationGroup.Alpha_Init = Collection.DescriptionMain.AnimTex.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.AnimTex.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.DescriptionMain.AnimTex.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.DescriptionMain.AnimTex.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.DescriptionMain.AnimTex.AnimationGroup.Alpha_FadeIn = Collection.DescriptionMain.AnimTex.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.AnimTex.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.DescriptionMain.AnimTex.AnimationGroup.Alpha_FadeIn:SetDuration(0.4)
Collection.DescriptionMain.AnimTex.AnimationGroup.Alpha_FadeIn:SetOrder(2)

Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_Init = Collection.DescriptionMain.AnimTex.AnimationGroup:CreateAnimation("Scale")
Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_Init:SetScale(0.001, 1.0)
Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_Init:SetDuration(0.0)
Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_Init:SetStartDelay(0)
Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_Init:SetOrder(1)

Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_FadeIn = Collection.DescriptionMain.AnimTex.AnimationGroup:CreateAnimation("Scale")
Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_FadeIn:SetScale(1000.0, 1.0)
Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_FadeIn:SetDuration(0.5)
Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_FadeIn:SetOrder(2)
Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_FadeIn:SetEndDelay(0.2)

Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_FadeOut = Collection.DescriptionMain.AnimTex.AnimationGroup:CreateAnimation("Scale")
Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_FadeOut:SetScale(0.1, 1.0)
Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_FadeOut:SetDuration(1.5)
Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_FadeOut:SetOrder(3)
Collection.DescriptionMain.AnimTex.AnimationGroup.Grow_FadeOut:SetScript("OnPlay", function() Collection.DescriptionMain.AnimTex_Add.AnimationGroup:Play() end)

Collection.DescriptionMain.AnimTex.AnimationGroup.Alpha_FadeOut = Collection.DescriptionMain.AnimTex.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.AnimTex.AnimationGroup.Alpha_FadeOut:SetChange(-1)
Collection.DescriptionMain.AnimTex.AnimationGroup.Alpha_FadeOut:SetStartDelay(0.2)
Collection.DescriptionMain.AnimTex.AnimationGroup.Alpha_FadeOut:SetDuration(1)
Collection.DescriptionMain.AnimTex.AnimationGroup.Alpha_FadeOut:SetOrder(3)

Collection.DescriptionMain.ArtSub = Collection.DescriptionMain:CreateTexture(nil, "ARTWORK", nil, 2)
Collection.DescriptionMain.ArtSub:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Collections\\RewardName_Highlight")
Collection.DescriptionMain.ArtSub:SetSize(360, 90)
Collection.DescriptionMain.ArtSub:SetPoint("TOP", 12, -148)

Collection.DescriptionMain.IconSub = Collection.DescriptionMain:CreateTexture(nil, "BORDER", nil, 2)
Collection.DescriptionMain.IconSub:SetSize(22, 22)
Collection.DescriptionMain.IconSub:SetPoint("TOP", -90, -169)
SetPortraitToTexture(Collection.DescriptionMain.IconSub, "Interface\\icons\\season1_complete")

Collection.DescriptionMain.TitleTextSub = Collection.DescriptionMain:CreateFontString()
Collection.DescriptionMain.TitleTextSub:SetFont("Fonts\\FRIZQT__.TTF", 11)
Collection.DescriptionMain.TitleTextSub:SetFontObject(GameFontNormal)
Collection.DescriptionMain.TitleTextSub:SetPoint("TOP", 0, -137)
Collection.DescriptionMain.TitleTextSub:SetShadowOffset(1, -1)
Collection.DescriptionMain.TitleTextSub:SetSize(360, 90)
Collection.DescriptionMain.TitleTextSub:SetText(MAIN_DESCRIPTION2_TITLE)

Collection.DescriptionMain.SubTextSub = Collection.DescriptionMain:CreateFontString()
Collection.DescriptionMain.SubTextSub:SetFont("Fonts\\FRIZQT__.TTF", 11)
Collection.DescriptionMain.SubTextSub:SetFontObject(GameFontHighlight)
Collection.DescriptionMain.SubTextSub:SetPoint("TOP", 5, -197)
Collection.DescriptionMain.SubTextSub:SetShadowOffset(1, -1)
Collection.DescriptionMain.SubTextSub:SetSize(180, 128)
Collection.DescriptionMain.SubTextSub:SetJustifyH("LEFT")
Collection.DescriptionMain.SubTextSub:SetJustifyV("TOP")
Collection.DescriptionMain.SubTextSub:SetText(MAIN_DESCRIPTION2_TEXT)

Collection.DescriptionMain.ArtSub.AnimationGroup = Collection.DescriptionMain.ArtSub:CreateAnimationGroup()

Collection.DescriptionMain.ArtSub.AnimationGroup.Alpha_Init = Collection.DescriptionMain.ArtSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.ArtSub.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.DescriptionMain.ArtSub.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.DescriptionMain.ArtSub.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.DescriptionMain.ArtSub.AnimationGroup.Alpha_FadeIn = Collection.DescriptionMain.ArtSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.ArtSub.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.DescriptionMain.ArtSub.AnimationGroup.Alpha_FadeIn:SetDuration(0.6)
Collection.DescriptionMain.ArtSub.AnimationGroup.Alpha_FadeIn:SetOrder(2)
Collection.DescriptionMain.ArtSub.AnimationGroup.Alpha_FadeIn:SetStartDelay(0.5)

Collection.DescriptionMain.IconSub.AnimationGroup = Collection.DescriptionMain.IconSub:CreateAnimationGroup()

Collection.DescriptionMain.IconSub.AnimationGroup.Alpha_Init = Collection.DescriptionMain.IconSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.IconSub.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.DescriptionMain.IconSub.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.DescriptionMain.IconSub.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.DescriptionMain.IconSub.AnimationGroup.Alpha_FadeIn = Collection.DescriptionMain.IconSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.IconSub.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.DescriptionMain.IconSub.AnimationGroup.Alpha_FadeIn:SetDuration(0.6)
Collection.DescriptionMain.IconSub.AnimationGroup.Alpha_FadeIn:SetOrder(2)
Collection.DescriptionMain.IconSub.AnimationGroup.Alpha_FadeIn:SetStartDelay(0.5)
Collection.DescriptionMain.TitleTextSub.AnimationGroup = Collection.DescriptionMain.TitleTextSub:CreateAnimationGroup()

Collection.DescriptionMain.TitleTextSub.AnimationGroup.Alpha_Init = Collection.DescriptionMain.TitleTextSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.TitleTextSub.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.DescriptionMain.TitleTextSub.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.DescriptionMain.TitleTextSub.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.DescriptionMain.TitleTextSub.AnimationGroup.Alpha_FadeIn = Collection.DescriptionMain.TitleTextSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.TitleTextSub.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.DescriptionMain.TitleTextSub.AnimationGroup.Alpha_FadeIn:SetDuration(0.6)
Collection.DescriptionMain.TitleTextSub.AnimationGroup.Alpha_FadeIn:SetOrder(2)
Collection.DescriptionMain.TitleTextSub.AnimationGroup.Alpha_FadeIn:SetStartDelay(0.5)

Collection.DescriptionMain.SubTextSub.AnimationGroup = Collection.DescriptionMain.SubTextSub:CreateAnimationGroup()

Collection.DescriptionMain.SubTextSub.AnimationGroup.Alpha_Init = Collection.DescriptionMain.SubTextSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.SubTextSub.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.DescriptionMain.SubTextSub.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.DescriptionMain.SubTextSub.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.DescriptionMain.SubTextSub.AnimationGroup.Alpha_FadeIn = Collection.DescriptionMain.SubTextSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.SubTextSub.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.DescriptionMain.SubTextSub.AnimationGroup.Alpha_FadeIn:SetDuration(0.6)
Collection.DescriptionMain.SubTextSub.AnimationGroup.Alpha_FadeIn:SetOrder(2)
Collection.DescriptionMain.SubTextSub.AnimationGroup.Alpha_FadeIn:SetStartDelay(0.5)

Collection.DescriptionMain.AnimTexSub = Collection.DescriptionMain:CreateTexture(nil, "BACKGROUND")
Collection.DescriptionMain.AnimTexSub:SetTexture("Interface\\Addons\\AwAddons\\Textures\\SpellKit\\Talent_Bg_animTex")
Collection.DescriptionMain.AnimTexSub:SetSize(496, 60)
Collection.DescriptionMain.AnimTexSub:SetPoint("TOP", 0, -146)
Collection.DescriptionMain.AnimTexSub:SetBlendMode("ADD")
Collection.DescriptionMain.AnimTexSub:SetAlpha(0)

Collection.DescriptionMain.AnimTex_AddSub = Collection.DescriptionMain:CreateTexture(nil, "OVERLAY")
Collection.DescriptionMain.AnimTex_AddSub:SetTexture("Interface\\Addons\\AwAddons\\Textures\\SpellKit\\Talent_Bg_animTex")
Collection.DescriptionMain.AnimTex_AddSub:SetSize(68, 5)
Collection.DescriptionMain.AnimTex_AddSub:SetPoint("TOP", 0, -186)
Collection.DescriptionMain.AnimTex_AddSub:SetBlendMode("ADD")
Collection.DescriptionMain.AnimTex_AddSub:SetAlpha(0)

Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup = Collection.DescriptionMain.AnimTex_AddSub:CreateAnimationGroup()

Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Alpha_Init = Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Translation_Init = Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup:CreateAnimation("Translation")
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Translation_Init:SetOffset(-50, 0)
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Translation_Init:SetDuration(0)
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Translation_Init:SetOrder(1)

Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Alpha_FadeIn = Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Alpha_FadeIn:SetDuration(1.5)
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Alpha_FadeIn:SetOrder(2)

Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Translation = Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup:CreateAnimation("Translation")
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Translation:SetOffset(150, 0)
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Translation:SetDuration(3)
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Translation:SetSmoothing("IN")
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Translation:SetOrder(2)

Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Alpha_FadeOut = Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Alpha_FadeOut:SetChange(-1)
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Alpha_FadeOut:SetDuration(0.6)
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Alpha_FadeOut:SetOrder(2)
Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup.Alpha_FadeOut:SetStartDelay(1.5)

Collection.DescriptionMain.ArtSub:Hide()
Collection.DescriptionMain.IconSub:Hide()
Collection.DescriptionMain.TitleTextSub:Hide()
Collection.DescriptionMain.SubTextSub:Hide()
Collection.DescriptionMain.AnimTexSub:Hide()

Collection.DescriptionMain.AnimTexSub.AnimationGroup = Collection.DescriptionMain.AnimTexSub:CreateAnimationGroup()
Collection.DescriptionMain.AnimTexSub.AnimationGroup:SetScript("OnPlay", function()
	Collection.DescriptionMain.ArtSub:Show()
	Collection.DescriptionMain.IconSub:Show()
	Collection.DescriptionMain.TitleTextSub:Show()
	Collection.DescriptionMain.SubTextSub:Show()
	Collection.DescriptionMain.AnimTexSub:Show()

	Collection.DescriptionMain.ArtSub.AnimationGroup:Play()
	Collection.DescriptionMain.IconSub.AnimationGroup:Play()
	Collection.DescriptionMain.TitleTextSub.AnimationGroup:Play()
	Collection.DescriptionMain.SubTextSub.AnimationGroup:Play()
end)

Collection.DescriptionMain.AnimTexSub.AnimationGroup.Alpha_Init = Collection.DescriptionMain.AnimTexSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Alpha_Init:SetChange(-1)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Alpha_Init:SetDuration(0)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Alpha_Init:SetOrder(1)

Collection.DescriptionMain.AnimTexSub.AnimationGroup.Alpha_FadeIn = Collection.DescriptionMain.AnimTexSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Alpha_FadeIn:SetChange(1)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Alpha_FadeIn:SetDuration(0.4)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Alpha_FadeIn:SetOrder(2)

Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_Init = Collection.DescriptionMain.AnimTexSub.AnimationGroup:CreateAnimation("Scale")
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_Init:SetScale(0.001, 1.0)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_Init:SetDuration(0.0)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_Init:SetStartDelay(0)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_Init:SetOrder(1)

Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_FadeIn = Collection.DescriptionMain.AnimTexSub.AnimationGroup:CreateAnimation("Scale")
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_FadeIn:SetScale(1000.0, 1.0)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_FadeIn:SetDuration(0.5)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_FadeIn:SetOrder(2)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_FadeIn:SetEndDelay(0.2)

Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_FadeOut = Collection.DescriptionMain.AnimTexSub.AnimationGroup:CreateAnimation("Scale")
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_FadeOut:SetScale(0.1, 1.0)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_FadeOut:SetDuration(1.5)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_FadeOut:SetOrder(3)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Grow_FadeOut:SetScript("OnPlay", function() Collection.DescriptionMain.AnimTex_AddSub.AnimationGroup:Play() end)

Collection.DescriptionMain.AnimTexSub.AnimationGroup.Alpha_FadeOut = Collection.DescriptionMain.AnimTexSub.AnimationGroup:CreateAnimation("Alpha")
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Alpha_FadeOut:SetChange(-1)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Alpha_FadeOut:SetStartDelay(0.2)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Alpha_FadeOut:SetDuration(1)
Collection.DescriptionMain.AnimTexSub.AnimationGroup.Alpha_FadeOut:SetOrder(3)

-------------------------------------------------------------------------------
--                             Non-Seasonal Features Block                             --
-------------------------------------------------------------------------------
Collection.SmallChallengesFrame.Scroll_Features = CreateFrame("ScrollFrame", "SeasonalCollection.SmallChallenges.Scroll_Features", Collection.SmallChallengesFrame)
Collection.SmallChallengesFrame.Scroll_Features:SetSize(298, 301)
Collection.SmallChallengesFrame.Scroll_Features:SetPoint("CENTER", -10, -1.5)

Collection.SmallChallengesFrame.Scroll_Features:Hide()

Collection.SmallChallengesFrame.Scroll_Features:EnableMouseWheel(true)

Collection.SmallChallengesFrame.Scroll_Features:SetScript("OnMouseWheel", function(self, delta)
	if (Collection.SmallChallengesFrame.Scroll_Features.ScrollBar:IsVisible()) then
		local value = Collection.SmallChallengesFrame.Scroll_Features.ScrollBar:GetValue()
		Collection.SmallChallengesFrame.Scroll_Features.ScrollBar:SetValue(value - delta * 64)
	end
end)

local features_content = CreateFrame("Frame", nil, Collection.SmallChallengesFrame)
Collection.SmallChallengesFrame.Scroll_Features.Content = features_content
features_content:SetSize(298, 256)
features_content:SetPoint("CENTER")

Collection.SmallChallengesFrame.Scroll_Features.ScrollBar = CreateFrame("Slider", "SeasonalCollection.SmallChallenges.Scroll_Features.ScrollBar", Collection.SmallChallengesFrame.Scroll_Features, "UIPanelScrollBarTemplate")
Collection.SmallChallengesFrame.Scroll_Features.ScrollBar:SetPoint("TOPLEFT", Collection.SmallChallengesFrame.Scroll_Features, "TOPRIGHT", 1, -14)
Collection.SmallChallengesFrame.Scroll_Features.ScrollBar:SetPoint("BOTTOMLEFT", Collection.SmallChallengesFrame.Scroll_Features, "BOTTOMRIGHT", 1, 15)


Collection.SmallChallengesFrame.Scroll_Features.ScrollBar:SetMinMaxValues(1, 1)
Collection.SmallChallengesFrame.Scroll_Features.ScrollBar:SetValueStep(1)
Collection.SmallChallengesFrame.Scroll_Features.ScrollBar.scrollStep = 64
Collection.SmallChallengesFrame.Scroll_Features.ScrollBar:SetValue(0)
Collection.SmallChallengesFrame.Scroll_Features.ScrollBar:SetWidth(16)
Collection.SmallChallengesFrame.Scroll_Features.ScrollBar:SetScript("OnValueChanged", function(self, value)
	Collection.SmallChallengesFrame.Scroll_Features:SetVerticalScroll(value) 
end)
Collection.SmallChallengesFrame.Scroll_Features:SetScrollChild(features_content)

Collection.SmallChallengesFrame.Scroll_Features.ScrollUpButton = _G[Collection.SmallChallengesFrame.Scroll_Features.ScrollBar:GetName() .. "ScrollUpButton"]
Collection.SmallChallengesFrame.Scroll_Features.ScrollDownButton = _G[Collection.SmallChallengesFrame.Scroll_Features.ScrollBar:GetName() .. "ScrollDownButton"]
Collection.SmallChallengesFrame.Scroll_Features.ScrollUpButton:Disable()
Collection.SmallChallengesFrame.Scroll_Features.ScrollDownButton:Disable()

for i = 1, 1 do
	features_content["Icon" .. i] = features_content:CreateTexture(nil, "BORDER")
	features_content["Icon" .. i]:SetSize(40, 40)
	features_content["Icon" .. i]:SetTexture("Interface\\icons\\season1_complete")
	features_content["Icon" .. i]:SetPoint("TOPLEFT", 10, -12 - 60 * (i - 1))
	features_content["IconBorder" .. i] = features_content:CreateTexture(nil, "ARTWORK")
	features_content["IconBorder" .. i]:SetSize(40, 40)
	features_content["IconBorder" .. i]:SetTexture("Interface\\Addons\\AwAddons\\Textures\\SpellKit\\ArtifactPower-QuestBorder")
	features_content["IconBorder" .. i]:SetPoint("TOPLEFT", 10, -12 - 60 * (i - 1))

	features_content["IconTextMain" .. i] = features_content:CreateFontString(nil)
	features_content["IconTextMain" .. i]:SetFont("Fonts\\MORPHEUS.ttf", 16)
	features_content["IconTextMain" .. i]:SetFontObject(GameFontHighlight)
	features_content["IconTextMain" .. i]:SetPoint("TOP", 0, -8 - 60 * (i - 1))
	features_content["IconTextMain" .. i]:SetShadowOffset(0, -1)
	features_content["IconTextMain" .. i]:SetSize(190, 24)
	features_content["IconTextMain" .. i]:SetText("Collection saisonnière")
	features_content["IconTextMain" .. i]:SetJustifyH("CENTER")
	features_content["IconTextMain" .. i]:SetJustifyV("TOP")

	features_content["IconTextMain" .. i] = features_content:CreateFontString(nil)
	features_content["IconTextMain" .. i]:SetFont("Fonts\\MORPHEUS.ttf", 12)
	features_content["IconTextMain" .. i]:SetFontObject(GameFontNormal)
	features_content["IconTextMain" .. i]:SetPoint("TOP", 0, -32 - 60 * (i - 1))
	features_content["IconTextMain" .. i]:SetShadowOffset(0, -1)
	features_content["IconTextMain" .. i]:SetSize(190, 24)
	features_content["IconTextMain" .. i]:SetText(NON_SEASON_TITLE)
	features_content["IconTextMain" .. i]:SetJustifyH("CENTER")
	features_content["IconTextMain" .. i]:SetJustifyV("TOP")

	features_content["DescriptionBlock" .. i] = features_content:CreateFontString(nil)
	features_content["DescriptionBlock" .. i]:SetFont("Fonts\\FRIZQT__.ttf", 12)
	features_content["DescriptionBlock" .. i]:SetFontObject(GameFontHighlight)
	features_content["DescriptionBlock" .. i]:SetPoint("TOP", 0, -62 - 60 * (i - 1))
	features_content["DescriptionBlock" .. i]:SetShadowOffset(0, -1)
	features_content["DescriptionBlock" .. i]:SetSize(270, 256)
	features_content["DescriptionBlock" .. i]:SetText(NON_SEASON_TEXT)
	features_content["DescriptionBlock" .. i]:SetJustifyH("LEFT")
	features_content["DescriptionBlock" .. i]:SetJustifyV("TOP")
end

Collection.SpendPoints = CreateFrame("FRAME", nil, Collection)
Collection.SpendPoints:SetSize(256, 32)
Collection.SpendPoints:SetPoint("BOTTOM", 0, 16)
-- Collection.SpendPoints:SetBackdrop(GameTooltip:GetBackdrop())
-- Collection.SpendPoints:SetFrameLevel(5)

Collection.SpendPoints.BG = Collection.SpendPoints:CreateTexture(nil, "BORDER")
Collection.SpendPoints.BG:SetAllPoints()
Collection.SpendPoints.BG:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\enchant\\Enchant_RefundButton")

Collection.SpendPoints.MainButton = CreateFrame("Button", nil, Collection.SpendPoints, "StaticPopupButtonTemplate")
Collection.SpendPoints.MainButton:SetPoint("CENTER", 1, 1)
Collection.SpendPoints.MainButton:EnableMouse(true)
Collection.SpendPoints.MainButton:SetWidth(148)
Collection.SpendPoints.MainButton:SetHeight(19)
Collection.SpendPoints.MainButton:SetText("Dépenser des points")
Collection.SpendPoints.MainButton:SetScript("OnClick", function(self)
	Collection:Hide()
	StoreCollectionFrame:Show()

	CollectionController.CollectionControllerTab3:SetChecked(true)
	CollectionController.CollectionControllerTab3:Disable()

	CollectionController.CollectionControllerTab4:SetChecked(false)
	CollectionController.CollectionControllerTab4:Enable()

	UIDropDownMenu_SetSelectedID(Addon.Store.StoreTypeList, 7)
	G_BuildSeasonalRewardsList()
end)

Collection:RegisterEvent("COMMENTATOR_SKIRMISH_QUEUE_REQUEST")

Collection:SetScript("OnEvent", function(self, event, ...)
	if event == "COMMENTATOR_SKIRMISH_QUEUE_REQUEST" then
		local asc_event = ...
		if asc_event == "ASCENSION_CUSTOM_POINTS_SEASONAL_POINTS_VALUE_CHANGED" then
			local points = select(2, ...)
			UpdatePoints(points, points)
		end
	end
end)

