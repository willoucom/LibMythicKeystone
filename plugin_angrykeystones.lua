local ADDON, Addon = ...

-- print("Plugin:AngryKeystones loaded")

local AngryKeystoneStorage = {}


local function OnEvent(self, event, addOnName, message, channel, character)
    if (addOnName == "AngryKeystones") then
        -- print("AngryKeystones received")
        if (string.find(message, "Schedule|")) then
            -- print(message)
            local _, key = string.split("|", message)
            local keyname, keylevel = string.split(":", key)
            local character = string.split("-", character)
            if keyname and keylevel then
                AngryKeystoneStorage[character] = AngryKeystoneStorage[character] or {}
                AngryKeystoneStorage[character]["current_key"] = keyname
                AngryKeystoneStorage[character]["current_keylevel"] = keylevel
            end
        end
    end

    for key in pairs(AngryKeystoneStorage) do
        Addon.PartyKeys[key] = Addon.PartyKeys[key] or {}
        Addon.PartyKeys[key]["current_key"] = AngryKeystoneStorage[key]["current_key"]
        Addon.PartyKeys[key]["current_keylevel"] = AngryKeystoneStorage[key]["current_keylevel"]
    end
end

C_ChatInfo.RegisterAddonMessagePrefix("AngryKeystones")

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript("OnEvent", OnEvent)
