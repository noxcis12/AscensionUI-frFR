if UnitLevel("player") ~= 1 then
    return
end
local LOCALE_CLIENT = GetLocale()
local chatFrameId = ChatFrame1:GetID()
if (LOCALE_CLIENT ~= "frFR") and (LOCALE_CLIENT ~= "frFR") then
    JoinPermanentChannel(LOCALE_CLIENT, nil, chatFrameId, 0)
end
JoinPermanentChannel("Ascension", nil, chatFrameId, nil)
JoinPermanentChannel("World", nil, chatFrameId, nil)
