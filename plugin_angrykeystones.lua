local ADDON, Addon = ...

-- print("Plugin:AngryKeystones loaded")

local function OnEvent(self, event, addOnName, message, channel, character)
    if (addOnName == "AngryKeystones") then
        -- print("AngryKeystones received")
        if (string.find(message, "Schedule|")) then
            local _, key = string.split("|", message)
            local keyname, keylevel = string.split(":", key)
            if character ~= Addon.Mykey["fullname"] then
                
            end
            if keyname and keylevel then
                Addon.PartyKeys[character] = {}
                Addon.PartyKeys[character]["current_key"] = keyname
                Addon.PartyKeys[character]["current_keylevel"] = keylevel
            end
        end
    end
end

C_ChatInfo.RegisterAddonMessagePrefix("AngryKeystones")

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript("OnEvent", OnEvent)

-- function Angry_sendKeystone()
--     local data = "Schedule|" .. Addon.Mykey["current_key"] .. ":" .. Addon.Mykey["current_keylevel"]
--     local pname, realm = UnitName("player")
--     C_ChatInfo.SendAddonMessage("AngryKeystones", data, "PARTY")
--     C_ChatInfo.SendAddonMessage("AngryKeystones", data, "WHISPER", pname)
-- end

-- local PartySendAngryFrame = CreateFrame("Frame", nil)
-- PartySendAngryFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
-- PartySendAngryFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- PartySendAngryFrame:RegisterEvent("BAG_UPDATE")

-- PartySendAngryFrame:SetScript("OnEvent", function(self, event, ...)
--     Angry_sendKeystone()
-- end)
