local Addon = select(2, ...)
-------------------------------------------------------------------------------
--                                  Overwrites                               --
-------------------------------------------------------------------------------
-- Replace RequestSlotReforgeExtraction to handle bag offsets
if RequestSlotReforgeExtraction then
	RequestSlotReforgeExtraction_Internal = RequestSlotReforgeExtraction

	RequestSlotReforgeExtraction = function(bag, slot)
		if bag == 255 then
			-- equipped item
			RequestSlotReforgeExtraction_Internal(bag, slot)
		elseif bag == 0 then
			-- backpack is treated same as the character equipped slots + 22
			-- so 23-36 are the default backpack item slots
			slot = slot + 22
			RequestSlotReforgeExtraction_Internal(255, slot)
		else
			-- additional bags (1-4) are treated the same as the character equipped slots + 18 
			-- so slot 19 to 22 are your additional bags
			bag = bag + 18
			-- slot is indexed at 0 o the server for bags
			slot = slot - 1
			RequestSlotReforgeExtraction_Internal(bag, slot)
		end
	end
end

-- Replace RequestSlotReforgeEnchantment to handle bag offsets
if RequestSlotReforgeEnchantment then
	RequestSlotReforgeEnchantment_Internal = RequestSlotReforgeEnchantment

	RequestSlotReforgeEnchantment = function(bag, slot, enchantID)
		if bag == 255 then
			-- equipped item
			RequestSlotReforgeEnchantment_Internal(bag, slot, enchantID)
		elseif bag == 0 then
			-- backpack is treated same as the character equipped slots y + 22
			-- so 23-36 are the default backpack item slots
			slot = slot + 22
			RequestSlotReforgeEnchantment_Internal(255, slot, enchantID)
		else
			-- additional bags (1-4) are treated the same as the character equipped slots + 18 
			-- so slot 19 to 22 are your additional bags
			bag = bag + 18
			-- slot is indexed at 0 on the server for bags
			slot = slot - 1
			RequestSlotReforgeEnchantment_Internal(bag, slot, enchantID)
		end
	end
end

-- Replace GetFelCommutationInfo to handle server side slot offsets 
if GetFelCommutationInfo then
	GetFelCommutationInfo_Internal = GetFelCommutationInfo

	GetFelCommutationInfo = function(slot)
		slot = slot - 1
		return GetFelCommutationInfo_Internal(slot)
	end
end

-- Replace SetFelCommutation to handle server side offsets
if SetFelCommutation then
	SetFelCommutation_Internal = SetFelCommutation

	SetFelCommutation = function(slot, protect)
		slot = slot - 1
		return SetFelCommutation_Internal(slot, protect)
	end
end

-- returns the enchantID for the bag and slot.
-- bag 255 = equipped items
function GetREInSlot(bag, slot)
	local item = nil
	if bag == 255 then
		-- character equipped slots is indexed at 0 on the server
		item = GetSlotItemInstanceId(slot - 1)
	elseif bag == 0 then
		-- backpack is treated same as the character equipped slots + 22
		-- so 23-36 are the default backpack item slots
		bag = slot + 22
		item = GetSlotItemInstanceId(bag)
	else
		-- additional bags (1-4) are treated the same as the character equipped slots + 18 
		-- so slot 19 to 22 are your additional bags
		bag = bag + 18
		-- get the bag we want to look in
		local bagID = GetSlotItemInstanceId(bag)
		-- items are indexed at 0 on the server
		slot = slot - 1
		item = GetBagItemInstanceId(bagID, slot)
	end

	if item == nil then return 0 end

	local enchantID = GetItemEnchantmentInfo(item, 5)

	return enchantID or 0
end

-- returns the enchant data for a given enchantId or spellId
function GetREData(enchantId)
	local RE = Addon.REList[enchantId] 
	if RE then 
		return RE
	end

	-- maybe we passed a spell id?
	local spellId = enchantId
	enchantId = Addon.REListSpellID[spellId]
	if enchantId then
		RE = Addon.REList[enchantId]
		if RE then 
			return RE
		end
	end

	-- we don't know this enchant
	return Addon.REList[0]
end

-------------------------------------------------------------------------------
--                                  Useful Globals                           --
-------------------------------------------------------------------------------
-- Consider moving these to SharedXML or FrameXML so they're loaded first and accessible in FrameXML / SharedXML files

-- REMOVE THIS FROM ClientCharacterAdvancement.lua
local cacheLoaderTooltip = CreateFrame("GameTooltip", "CacheLoaderTooltip", UIParent, "GameTooltipTemplate")

function GetSpellDescriptionFromTooltip(tooltip)
	local text = ""
	for i = 2, tooltip:NumLines() do
		text = text .. _G[tooltip:GetName() .. "TextLeft" .. i]:GetText()
	end
	return text
end

function GetSpellDescription(spellID)
	cacheLoaderTooltip:SetOwner(WorldFrame, "ACHOR_NONE")
	local spellName = GetSpellInfo(spellID)
	if not spellName then return "" end
	local link = "|Hspell:" .. spellID .. "|h[" .. spellName .. "]|h"
	cacheLoaderTooltip:SetHyperlink(link)
	local desc = GetSpellDescriptionFromTooltip(cacheLoaderTooltip)
	cacheLoaderTooltip:Hide()
	return desc
end

Addon.GetSpellDescription = GetSpellDescription

function TryCacheItem(itemID)
	if not itemID then return end
	cacheLoaderTooltip:SetOwner(WorldFrame, "ACHOR_NONE")
	cacheLoaderTooltip:SetHyperlink("item:" .. itemID .. ":0:0:0:0:0:0:0")
	cacheLoaderTooltip:Hide()
end

function InsertTooltipLine(tooltip, index, text, r, g, b)
	local numLines = tooltip:NumLines()
	local leftText = {}
	local rightText = {}

	-- store all the lines we have
	for i = 1, numLines do
		local left = _G[tooltip:GetName() .. "TextLeft" .. i]
		if left then
			local r, g, b = left:GetTextColor()
			leftText[i] = {text = left:GetText(), r = r, g = g, b = b}
		end

		local right = _G[tooltip:GetName() .. "TextRight" .. i]
		if right:GetText() then
			local r, g, b = right:GetTextColor()
			rightText[i] = {text = right:GetText(), r = r, g = g, b = b}
		end
	end

	tooltip:ClearLines()
	local offset = 1

	for i = 1, numLines + offset do
		if i == index then
			tooltip:AddLine(text, r, g, b, true)
			offset = offset - 1
		else
			local left = leftText[offset]
			local right = rightText[offset]

			if right then
				tooltip:AddDoubleLine(left.text, right.text, left.r, left.g, left.b, right.r, right.g, right.b)
            else
				tooltip:AddLine(left.text, left.r, left.g, left.b, true)
			end
		end
		offset = offset + 1
	end
end

function InsertTooltipMultipleLines(tooltip, data, count, r, g, b)
	local numLines = tooltip:NumLines()
	local leftText = {}
	local rightText = {}

	-- store all the lines we have
	for i = 1, numLines do
		local left = _G[tooltip:GetName() .. "TextLeft" .. i]
		if left then
			local r, g, b = left:GetTextColor()
			leftText[i] = {text = left:GetText(), r = r, g = g, b = b}
		end

		local right = _G[tooltip:GetName() .. "TextRight" .. i]
		if right:GetText() then
			local r, g, b = right:GetTextColor()
			rightText[i] = {text = right:GetText(), r = r, g = g, b = b}
		end
	end

	tooltip:ClearLines()
	local offset = 1
	for i = 1, numLines + count do
		if data[i] then
			tooltip:AddLine(data[i], r, g, b, true)
			offset = offset - 1
		else
			local left = leftText[offset]
			local right = rightText[offset]

			if right then
				tooltip:AddDoubleLine(left.text, right.text, left.r, left.g, left.b, right.r, right.g, right.b)
			else
				tooltip:AddLine(left.text, left.r, left.g, left.b, true)
			end
		end
		offset = offset + 1
	end
end


-- TODO: remove from ClientEBB.lua
function GetGoldForMoney(money)
	local gold, silver, copper = 0, 0, 0

	gold = floor(abs(money / 1e4))
	silver = floor(abs(mod(money / 100, 100)))
	copper = floor(abs(mod(money, 100)))

	return gold, silver, copper
end

-- from SharedXML/LinkUtil.lua
function GetItemInfoFromHyperlink(link)
	local strippedItemLink, itemID = link:match("|Hitem:((%d+).-)|h");
	if itemID then
		return tonumber(itemID), strippedItemLink;
	end
end