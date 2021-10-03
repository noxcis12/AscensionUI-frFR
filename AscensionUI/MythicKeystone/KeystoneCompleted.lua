local Addon = select(2, ...)
local MythicKeystone = Addon.MythicKeystone

local Completed = CreateFrame("Frame", "AscensionUI.MythicKeystone.KeystoneCompleted", UIParent)
Completed:Hide()

MythicKeystone.KeystoneCompleted = Completed

local SUCCESSFUL_RUN_DESCRIPTION = "Vous avez battu le chronomètre!"
local SUCCESSFUL_RUN_DESCRIPTION2 = "|cFF1EFF0CClé améliorée (+1)|r"
local SUCCESSFUL_RUN_DESCRIPTION3 = "Temps: |cFFFFFFFF%s|r"

local FAILED_RUN_DESCRIPTION = "|cFFFF3F40Temps expiré!|r"
local FAILED_RUN_DESCRIPTION2 = "Réessayer! Terminez le chronomètre pour améliorer votre clé!"

local ABORTED_RUN_DESCRIPTION = "|cFFFF3F40Clé échoué!|r"
local ABORTED_RUN_DESCRIPTION2 = "|cFFFF3F40Clé Altérer (-1)|r"


-- /run AscensionUI.MythicKeystone.KeystoneCompleted:CompleteKey(400823, true, 800)
function Completed:CompleteKey(itemId, success, timer)
    local keystone = Addon.KeystoneData[itemId]
	Completed:ShowBanner(keystone, timer, success)
	if not success and timer > 0 then
		-- key was aborted
		return
	end
    MythicKeystone.KeystoneInfo:StoreKeystoneData(keystone.instanceName, keystone.mythicLevel, success, (keystone.timeLimit / 1000) - timer)
end

function Completed:ShowBanner(keystone, timer, success)
	Completed.FadeOut:Stop()
	Completed:Hide()
	local level = keystone.mythicLevel
	local name = keystone.instanceName

	Completed.Level:SetText(level)
	Completed.Title:SetText(format("%s (+%d)", name, level))
	if success then
		-- beat the timer description
		Completed.Description:SetText(SUCCESSFUL_RUN_DESCRIPTION)

		-- Keystone level description
		Completed.Description2:SetText(SUCCESSFUL_RUN_DESCRIPTION2)

		-- time description
		Completed.Description3:SetText(format(SUCCESSFUL_RUN_DESCRIPTION3, MythicKeystone:FormatTime((keystone.timeLimit / 1000) - timer)))
	elseif timer <= 0 then
		-- beat the timer description
		Completed.Description:SetText(FAILED_RUN_DESCRIPTION)

		-- Keystone level description
		Completed.Description2:SetText(FAILED_RUN_DESCRIPTION2)

		-- time description
		Completed.Description3:SetText("")
	else
		-- beat the timer description
		Completed.Description:SetText(ABORTED_RUN_DESCRIPTION)

		-- Keystone level description
		Completed.Description2:SetText(ABORTED_RUN_DESCRIPTION2)

		-- time description
		Completed.Description3:SetText("")
	end

	for i = 1, 5 do
		Completed["Party"..i]:Hide()
	end

	for i = 0, GetNumPartyMembers() do
		local target = "player"
		if i > 0 then
			target = "party"..i
		end
		local frame = Completed["Party"..i+1]
		
		SetPortraitTexture(frame.Portrait, target)
		frame.Text:SetText(UnitName(target))

		frame:Show()

		if i > 0 then
			Completed.Party1:ClearAllPoints()
			Completed.Party1:SetPoint("BOTTOM", Completed, "BOTTOM", -(i * 31), 65)
		end
	end
	
	Completed:Show()
	Completed.FadeOut:Play()
end

local BossBannerTex = "Interface\\AddOns\\AscensionUI\\Textures\\BossBanner"

Completed:SetSize(128, 356)
Completed:SetPoint("TOP", 0, -120)

-- Textures
-- Banner Top
Completed.BannerTop = Completed:CreateTexture(nil, "BORDER")
Completed.BannerTop:SetSize(440, 112)
--Completed.BannerTop:SetAlpha(0)
Completed.BannerTop:SetBlendMode("BLEND")
Completed.BannerTop:SetPoint("TOP", 0, -44)
Completed.BannerTop:SetTexture(BossBannerTex)
Completed.BannerTop:SetTexCoord(0.00195312, 0.861328, 0.224609, 0.443359)

Completed.BannerTop.Glow = Completed:CreateTexture(nil, "BORDER")
Completed.BannerTop.Glow:SetSize(440, 112)
--Completed.BannerTop.Glow:SetAlpha(0)
Completed.BannerTop.Glow:SetBlendMode("ADD")
Completed.BannerTop.Glow:SetPoint("CENTER", Completed.BannerTop)
Completed.BannerTop.Glow:SetTexture(BossBannerTex)
Completed.BannerTop.Glow:SetTexCoord(0.00195312, 0.861328, 0.224609, 0.443359)

-- Banner Bottom
Completed.BannerBottom = Completed:CreateTexture(nil, "BORDER")
Completed.BannerBottom:SetSize(440, 112)
--Completed.BannerBottom:SetAlpha(0)
Completed.BannerBottom:SetBlendMode("BLEND")
Completed.BannerBottom:SetPoint("BOTTOM", 0, 0)
Completed.BannerBottom:SetTexture(BossBannerTex)
Completed.BannerBottom:SetTexCoord(0.00195312, 0.861328, 0.00195312, 0.220703)

Completed.BannerBottom.Glow = Completed:CreateTexture(nil, "BORDER")
Completed.BannerBottom.Glow:SetSize(440, 112)
Completed.BannerBottom.Glow:SetAlpha(0)
Completed.BannerBottom.Glow:SetBlendMode("ADD")
Completed.BannerBottom.Glow:SetPoint("CENTER", Completed.BannerBottom)
Completed.BannerBottom.Glow:SetTexture(BossBannerTex)
Completed.BannerBottom.Glow:SetTexCoord(0.00195312, 0.861328, 0.00195312, 0.220703)

-- Banner Middle
Completed.BannerMiddle = Completed:CreateTexture(nil, "BACKGROUND")
Completed.BannerMiddle:SetSize(440, 64)
--Completed.BannerMiddle:SetAlpha(0)
Completed.BannerMiddle:SetBlendMode("BLEND")
Completed.BannerMiddle:SetPoint("TOPLEFT", Completed.BannerTop, "TOPLEFT", -100, -34)
Completed.BannerMiddle:SetPoint("BOTTOMRIGHT", Completed.BannerBottom, "BOTTOMRIGHT", 100, 25)
Completed.BannerMiddle:SetTexture(BossBannerTex)
Completed.BannerMiddle:SetTexCoord(0.00195312, 0.861328, 0.447266, 0.572266)

Completed.BannerMiddle.Glow = Completed:CreateTexture(nil, "BACKGROUND")
Completed.BannerMiddle.Glow:SetSize(440, 64)
Completed.BannerMiddle.Glow:SetAlpha(0)
Completed.BannerMiddle.Glow:SetBlendMode("ADD")
Completed.BannerMiddle.Glow:SetPoint("CENTER", Completed.BannerMiddle)
Completed.BannerMiddle.Glow:SetTexture(BossBannerTex)
Completed.BannerMiddle.Glow:SetTexCoord(0.00195312, 0.861328, 0.447266, 0.572266)

-- Spiky Star
Completed.Star = Completed:CreateTexture(nil, "ARTWORK")
Completed.Star:SetSize(100, 100)
Completed.Star:SetPoint("CENTER", Completed.BannerTop, 0, 46)
Completed.Star:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
Completed.Star:SetTexCoord(0.000976562, 0.196289, 0.408203, 0.798828)

Completed.Star.Glow = Completed:CreateTexture(nil, "OVERLAY", nil, 4)
Completed.Star.Glow:SetSize(106, 106)
Completed.Star.Glow:SetPoint("CENTER", Completed.Star)
Completed.Star.Glow:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeModeHud")
Completed.Star.Glow:SetTexCoord(0.000976562, 0.202148, 0.00195312, 0.404297)

-- level text
Completed.Level = Completed:CreateFontString(nil, "OVERLAY")
Completed.Level:SetFontObject(GameFontNormalLarge)
Completed.Level:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
Completed.Level:SetPoint("CENTER", Completed.Star, "CENTER", -1, 0)
Completed.Level:SetText("99")
Completed.Level:SetJustifyH("CENTER")

Completed.BottomFill = Completed:CreateTexture(nil, "ARTWORK")
Completed.BottomFill:SetSize(66, 28)
--Completed.BottomFill:SetAlpha(0)
Completed.BottomFill:SetBlendMode("BLEND")
Completed.BottomFill:SetPoint("BOTTOM", 0, 8)
Completed.BottomFill:SetTexture(BossBannerTex)
Completed.BottomFill:SetTexCoord(0.865234, 0.994141, 0.314453, 0.369141)

Completed.RightFill = Completed:CreateTexture(nil, "ARTWORK")
Completed.RightFill:SetSize(72, 40)
--Completed.RightFill:SetAlpha(0)
Completed.RightFill:SetBlendMode("BLEND")
Completed.RightFill:SetPoint("CENTER", Completed.Star, 10, 6)
Completed.RightFill:SetTexture(BossBannerTex)
Completed.RightFill:SetTexCoord(0.736328, 0.876953, 0.576172, 0.654297)

Completed.LeftFill = Completed:CreateTexture(nil, "ARTWORK")
Completed.LeftFill:SetSize(72, 40)
--Completed.LeftFill:SetAlpha(0)
Completed.LeftFill:SetBlendMode("BLEND")
Completed.LeftFill:SetPoint("CENTER", Completed.Star, -10, 6)
Completed.LeftFill:SetTexture(BossBannerTex)
Completed.LeftFill:SetTexCoord(0.591797, 0.732422, 0.576172, 0.654297)

Completed.Title = Completed:CreateFontString(nil, "OVERLAY")
Completed.Title:SetFont("Fonts\\MORPHEUS.ttf", 24, "OUTLINE")
Completed.Title:SetTextColor(1, 0.82, 0, 1)
Completed.Title:SetPoint("TOP", Completed.BannerTop, 0, -61)
Completed.Title:SetText("No Dungeon +99")

Completed.Description = Completed:CreateFontString(nil, "ARTWORK")
Completed.Description:SetFontObject(GameFontHighlightLarge)
Completed.Description:SetPoint("TOP", Completed.Title, "BOTTOM", 0, -8)
Completed.Description:SetText(SUCCESSFUL_RUN_DESCRIPTION)

Completed.Description2 = Completed:CreateFontString(nil, "ARTWORK")
Completed.Description2:SetFontObject(GameFontHighlightLarge)
Completed.Description2:SetPoint("TOP", Completed.Description, "BOTTOM", 0, -6)
Completed.Description2:SetText(SUCCESSFUL_RUN_DESCRIPTION2)

Completed.Description3 = Completed:CreateFontString(nil, "ARTWORK")
Completed.Description3:SetFontObject(GameFontNormalLarge)
Completed.Description3:SetPoint("TOP", Completed.Description2, "BOTTOM", 0, -12)
Completed.Description3:SetText(format(SUCCESSFUL_RUN_DESCRIPTION3, MythicKeystone:FormatTime(0)))

for i = 1, 5 do
	local frame = CreateFrame("Frame", nil, Completed)
	frame:SetSize(62, 62)
	if i == 1 then
		frame:SetPoint("BOTTOM", Completed, "BOTTOM", 0, 65)
	else
		frame:SetPoint("LEFT", Completed["Party"..i-1], "RIGHT", 4, 0)
	end

	frame.Border = frame:CreateTexture(nil, "OVERLAY")
	frame.Border:SetAllPoints()
	frame.Border:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\Challenges\\ChallengeMode")
	frame.Border:SetTexCoord(0.912109, 0.962891, 0.0537109, 0.104492)

	frame.Portrait = frame:CreateTexture(nil, "BACKGROUND")
	frame.Portrait:SetAllPoints()
	SetPortraitTexture(frame.Portrait, "player")

	frame.Text = frame:CreateFontString(nil, "OVERLAY")
	frame.Text:SetPoint("TOP", frame, "BOTTOM", 0, 0)
	frame.Text:SetFontObject(GameFontHighlight)
	frame.Text:SetText(UnitName("player"))

	frame:Hide()
	Completed["Party"..i] = frame
end


-- Animations
Completed.FadeOut = Completed:CreateAnimationGroup()
Completed.FadeOut.Alpha = Completed.FadeOut:CreateAnimation("ALPHA")
Completed.FadeOut.Alpha:SetChange(-1)
Completed.FadeOut.Alpha:SetDuration(4)
Completed.FadeOut.Alpha:SetStartDelay(4)

Completed.FadeOut:SetScript("OnFinished", function(self)
	Completed:Hide()
end)

Completed.FadeOut:SetScript("OnStop", function(self)
	Completed:Hide()
end)


--[[
    ["Interface/LevelUp/BossBanner"]={
		["BossBanner-BottomFillagree"]={66, 28, 0.865234, 0.994141, 0.314453, 0.369141, false, false},
		["BossBanner-SkullCircle"]={44, 44, 0.865234, 0.951172, 0.134766, 0.220703, false, false},
		["BossBanner-TopFillagree"]={176, 74, 0.244141, 0.587891, 0.576172, 0.720703, false, false},
		["BossBanner-RedFlash"]={92, 92, 0.00195312, 0.181641, 0.810547, 0.990234, false, false},
		["BossBanner-LeftFillagree"]={72, 40, 0.591797, 0.732422, 0.576172, 0.654297, false, false},
		["BossBanner-RightFillagree"]={72, 40, 0.736328, 0.876953, 0.576172, 0.654297, false, false},
		["BossBanner-SkullSpikes"]={50, 66, 0.865234, 0.962891, 0.00195312, 0.130859, false, false},
		["BossBanner-BgBanner-Bottom"]={440, 112, 0.00195312, 0.861328, 0.00195312, 0.220703, false, false},
		["BossBanner-BgBanner-Top"]={440, 112, 0.00195312, 0.861328, 0.224609, 0.443359, false, false},
		["LootBanner-IconGlow"]={40, 40, 0.865234, 0.943359, 0.447266, 0.525391, false, false},
		["LootBanner-ItemBg"]={269, 41, 0.244141, 0.769531, 0.724609, 0.804688, false, false},
		["LootBanner-LootBagCircle"]={44, 44, 0.865234, 0.951172, 0.224609, 0.310547, false, false},
		["BossBanner-BgBanner-Mid"]={440, 64, 0.00195312, 0.861328, 0.447266, 0.572266, false, false},
		["BossBanner-RedLightning"]={122, 118, 0.00195312, 0.240234, 0.576172, 0.806641, false, false},
	}, -- Interface/LevelUp/BossBanner
]]