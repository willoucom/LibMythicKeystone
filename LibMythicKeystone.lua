local ADDON, Addon = ...
local MAJOR, MINOR = "LibMythicKeystone-1.0", 1;
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

Addon.ShortName = "MythicKeystone"
Addon.PartyKeys = {}
Addon.Mykey = {
    ["class"] = "",
    ["name"] = "pname",
    ["realm"] = "sname",
    ["fullname"] = "player",
    ["current_key"] = 0,
    ["current_keylevel"] = 0
}

Addon.ProcessingKeys = false

--
-- Public functions
--

function lib.getMyKeystone()
    return Addon.Mykey
end

function lib.getAltsKeystone()
    return LibMythicKeystoneDB['Alts']
end

function lib.getPartyKeystone()
    return Addon.PartyKeys
end

--
-- Private functions
--

function Addon.getKeystone()
    Addon.trace("Start key processing")
    if Addon.ProcessingKeys then
        Addon.trace("Key processing in progress, skip")
        return
    end
    Addon.ProcessingKeys = true
    local keystoneMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID() or 0
    local keystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel() or 0

    -- Look for database and create if not exists
    LibMythicKeystoneDB = LibMythicKeystoneDB or {};
    LibMythicKeystoneDB['Alts'] = LibMythicKeystoneDB['Alts'] or {};
    LibMythicKeystoneDB['Guilds'] = LibMythicKeystoneDB['Guilds'] or {};

    -- Get character name. guild and realm
    local pname = UnitName("player") or "none"
    local sname = GetNormalizedRealmName() or "none"
    local GuildName = GetGuildInfo("player") or "none"
    local _, classFilename = C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))

    -- Create guild storage
    if GuildName ~= "none" then
        LibMythicKeystoneDB['Guilds'] = LibMythicKeystoneDB['Guilds'] or {}
        LibMythicKeystoneDB['Guilds'][GuildName] = LibMythicKeystoneDB['Guilds'][GuildName] or {};
    end

    -- Format for storage
    local player = string.format("%s-%s", pname, sname)

    -- save in database
    if keystoneLevel then
        LibMythicKeystoneDB['Alts'][player] = {
            ["class"] = classFilename,
            ["current_key"] = keystoneMapID,
            ["current_keylevel"] = keystoneLevel,
            ["guild"] = GuildName,
            ["name"] = pname,
            ["realm"] = sname,
            ["fullname"] = player
        }
    end

    Addon.Mykey = {
        ["class"] = classFilename,
        ["name"] = pname,
        ["realm"] = sname,
        ["fullname"] = player,
        ["current_key"] = keystoneMapID,
        ["current_keylevel"] = keystoneLevel
    }

    Addon.PartyKeys[pname] = {
        ["class"] = classFilename,
        ["name"] = pname,
        ["realm"] = sname,
        ["fullname"] = player,
        ["current_key"] = keystoneMapID,
        ["current_keylevel"] = keystoneLevel
    }

    if IsInGroup() then
        for i = 1, 4 do
            local pname, _ = UnitName("party"..i) or "none"
            local _, class = UnitClass("party"..i)
            Addon.PartyKeys[pname] = {
                ["class"] = class,
                ["name"] = pname,
                ["realm"] = sname,
                ["fullname"] = pname,
                ["current_key"] = 0,
                ["current_keylevel"] = 0
            }
        end
    end
    Addon.ProcessingKeys = false
    Addon.trace("End key processing")
end

function Addon.sendKeystone()
    Addon.getKeystone()
    local data = Addon.Mykey["current_key"] .. ":"
        .. Addon.Mykey["current_keylevel"] .. ":"
        .. Addon.Mykey["class"] .. ":"
        .. Addon.Mykey["name"]
    local pname = UnitName("player")
    C_ChatInfo.SendAddonMessage(Addon.ShortName, data, "PARTY")
    -- C_ChatInfo.SendAddonMessage(Addon.ShortName, data, "WHISPER", pname)

    local guildName = GetGuildInfo("player") or "none"
    if guildName ~= "none" then
        for key, value in pairs(LibMythicKeystoneDB['Alts']) do
            if value['guild'] == guildName then
                local data = Addon.Mykey["current_key"] .. ":"
                    .. Addon.Mykey["current_keylevel"] .. ":"
                    .. Addon.Mykey["class"] .. ":"
                    .. Addon.Mykey["fullname"]
                -- C_ChatInfo.SendAddonMessage(Addon.ShortName, data, "GUILD")
            end
        end
    end
end

function Addon.removePartyKeystone()
    Addon.trace("removePartyKeystone")
    local tmptable = {}
    local playerinparty = {}
    for i = 1, 4 do
        local pname, _ = UnitName("party"..i) or "none","none"
        playerinparty[pname] = true
    end
    playerinparty[Addon.Mykey["name"]] = true
    Addon.trace(playerinparty)

    for key in pairs(Addon.PartyKeys) do
        Addon.trace("Check if ".. key .. " is in party")
        if playerinparty[key] then
            Addon.trace(playerinparty[key])
            Addon.trace(" ".. key ..  " in party")
            tmptable[key] = Addon.PartyKeys[key]
        else
            Addon.trace(" ".. key ..  " deleted")
        end
    end
    Addon.PartyKeys = tmptable
    for key in pairs(Addon.PartyKeys) do
        Addon.trace(key)
    end
end

function Addon.receiveKeystone(addOnName, message, channel, character)
    if (addOnName == Addon.ShortName) then
        local key, keylevel, class, fullname = string.split(":", message)
        Addon.PartyKeys[fullname] = Addon.PartyKeys[fullname] or {}
        Addon.PartyKeys[fullname]["class"] = class
        Addon.PartyKeys[fullname]["current_key"] = key
        Addon.PartyKeys[fullname]["current_keylevel"] = keylevel
    end
    Addon.removePartyKeystone()
end

-- Register library for chat msg addon
C_ChatInfo.RegisterAddonMessagePrefix(Addon.ShortName)

--
-- Frames
--

local LibMythicKeystoneFrame = CreateFrame("Frame")
local LibMythicKeystoneFrames = {}

LibMythicKeystoneFrames["PartyEvent"] = CreateFrame("Frame", nil, LibMythicKeystoneFrame)
LibMythicKeystoneFrames["PartyEvent"]:RegisterEvent("CHAT_MSG_ADDON")
LibMythicKeystoneFrames["PartyEvent"]:SetScript("OnEvent", function(self, event, addOnName, message, channel, character, ...)
    if addOnName == Addon.ShortName then
        Addon.receiveKeystone(addOnName, message, channel, character)
    end
end)

LibMythicKeystoneFrames["KeyEvent"] = CreateFrame("Frame", nil, LibMythicKeystoneFrame)
LibMythicKeystoneFrames["KeyEvent"]:RegisterEvent("BAG_UPDATE")
LibMythicKeystoneFrames["KeyEvent"]:RegisterEvent("PLAYER_ENTERING_WORLD")
LibMythicKeystoneFrames["KeyEvent"]:RegisterEvent("GROUP_ROSTER_UPDATE")
LibMythicKeystoneFrames["KeyEvent"]:RegisterEvent("ZONE_CHANGED")
LibMythicKeystoneFrames["KeyEvent"]:RegisterEvent("ZONE_CHANGED_INDOORS")
LibMythicKeystoneFrames["KeyEvent"]:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED")
LibMythicKeystoneFrames["KeyEvent"]:SetScript("OnEvent", function(self, event, ...)
    Addon.trace("KeyEvent:" .. event)
    Addon.removePartyKeystone()
    Addon.getKeystone()
    Addon.sendKeystone()
end)

local function bootlegRepeatingTimer()
    Addon.trace("Auto refresh")
    Addon.getKeystone()
    Addon.removePartyKeystone()
	C_Timer.After(60, bootlegRepeatingTimer)
end
bootlegRepeatingTimer()

_G[ADDON] = lib