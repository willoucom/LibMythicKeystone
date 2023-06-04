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
Addon.lib = lib

local initializeTime = {}
initializeTime[1] = 1500390000 -- US Tuesday at reset
initializeTime[2] = 1500447600 -- EU Wednesday at reset
initializeTime[3] = 1500505200 -- TW Thursday at reset
initializeTime[4] = 0

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

function lib.getGuildKeystone()
    local GuildName = GetGuildInfo("player") or "none"
    return LibMythicKeystoneDB['Guilds'][GuildName]
end

--
-- Private functions
--

-- This function is from AstralKeys addon (great addon btw)
function Addon.GetWeek()
    local region = GetCurrentRegion()
    if region == 3 then     -- EU
        return math.floor((GetServerTime() - initializeTime[2]) / 604800)
    elseif region == 4 then -- TW
        return math.floor((GetServerTime() - initializeTime[3]) / 604800)
    else                    -- default to US
        return math.floor((GetServerTime() - initializeTime[1]) / 604800)
    end
end

function Addon.getKeystone()
    if Addon.ProcessingKeys then
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
    local pname = UnitName("player")
    if not pname then
        Addon.ProcessingKeys = false
        return false
    end
    local realm = GetNormalizedRealmName()
    if not realm then
        Addon.ProcessingKeys = false
        return false
    end
    local GuildName = GetGuildInfo("player") or "none"
    local _, classFilename = C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))

    -- Create guild storage
    if GuildName ~= "none" then
        LibMythicKeystoneDB['Guilds'] = LibMythicKeystoneDB['Guilds'] or {}
        LibMythicKeystoneDB['Guilds'][GuildName] = LibMythicKeystoneDB['Guilds'][GuildName] or {};
    end

    -- Format for storage
    local player = string.format("%s-%s", pname, realm)

    -- save in database
    if keystoneLevel > 0 and realm then
        LibMythicKeystoneDB['Alts'][player] = {
            ["class"] = classFilename,
            ["current_key"] = keystoneMapID,
            ["current_keylevel"] = keystoneLevel,
            ["guild"] = GuildName,
            ["name"] = pname,
            ["realm"] = realm,
            ["fullname"] = player,
            ["week"] = Addon.GetWeek()
        }
    end

    Addon.Mykey = {
        ["class"] = classFilename,
        ["name"] = pname,
        ["realm"] = realm,
        ["fullname"] = player,
        ["current_key"] = keystoneMapID,
        ["current_keylevel"] = keystoneLevel,
        ["week"] = Addon.GetWeek()
    }

    Addon.PartyKeys[player] = {
        ["class"] = classFilename,
        ["name"] = pname,
        ["realm"] = realm,
        ["fullname"] = player,
        ["current_key"] = keystoneMapID,
        ["current_keylevel"] = keystoneLevel
    }

    -- Init group table
    if IsInGroup() then
        for i = 1, 4 do
            local name, realm = UnitName("party" .. i) or ""
            if not realm then
                -- unit is on the same realm
                realm = Addon.Mykey["realm"]
            end
            local player = string.format("%s-%s", name, realm)
            local _, class = UnitClass("party" .. i)
            if player ~= "" then
                Addon.PartyKeys[player] = Addon.PartyKeys[player] or {}
                Addon.PartyKeys[player]["class"] = class
                Addon.PartyKeys[player]["name"] = name
                Addon.PartyKeys[player]["realm"] = realm
                Addon.PartyKeys[player]["fullname"] = player
                Addon.PartyKeys[player]["current_key"] = Addon.PartyKeys[player]["current_key"] or 0
                Addon.PartyKeys[player]["current_keylevel"] = Addon.PartyKeys[player]["current_keylevel"] or 0
            end
        end
    end

    -- Clean obsolete keys (Guild)
    for guild in pairs(LibMythicKeystoneDB['Guilds']) do
        for char in pairs(LibMythicKeystoneDB['Guilds'][guild]) do
            if LibMythicKeystoneDB['Guilds'][guild][char]['week'] ~= Addon.GetWeek() then
                LibMythicKeystoneDB['Guilds'][guild][char] = nil
            end
        end
    end

    -- Clean obsolete keys (Alts)
    for char in pairs(LibMythicKeystoneDB['Alts']) do
        if LibMythicKeystoneDB['Alts'][char]['week'] ~= Addon.GetWeek() then
            print(LibMythicKeystoneDB['Alts'][char]['week'])
            LibMythicKeystoneDB['Alts'][char] = nil
        end
    end


    Addon.ProcessingKeys = false
end

function Addon.sendKeystone()
    Addon.getKeystone()
    if IsInGroup() then
        local data = Addon.Mykey["current_key"] .. ":"
            .. Addon.Mykey["current_keylevel"] .. ":"
            .. Addon.Mykey["class"] .. ":"
            .. Addon.Mykey["fullname"]
        local pname = UnitName("player")
        -- C_ChatInfo.SendAddonMessage(Addon.ShortName, data, "PARTY")
        ChatThrottleLib:SendAddonMessage("NORMAL",  Addon.ShortName, data, "PARTY");
        -- C_ChatInfo.SendAddonMessage(Addon.ShortName, data, "GUILD")
        ChatThrottleLib:SendAddonMessage("NORMAL",  Addon.ShortName, data, "GUILD");
        -- C_ChatInfo.SendAddonMessage(Addon.ShortName, data, "WHISPER", pname)
    end

    local guildName = GetGuildInfo("player") or "none"
    if guildName ~= "none" then
        for _, value in pairs(LibMythicKeystoneDB['Alts']) do
            if value['guild'] == guildName and value["current_key"] > 0 then
                local data = value["current_key"] .. ":"
                    .. value["current_keylevel"] .. ":"
                    .. value["class"] .. ":"
                    .. value["fullname"]
                ChatThrottleLib:SendAddonMessage("NORMAL",  Addon.ShortName, data, "GUILD");
                -- C_ChatInfo.SendAddonMessage(Addon.ShortName, data, "GUILD")
            end
        end
    end
end

function Addon.removePartyKeystone()
    local playerinparty = {}
    for i = 1, 4 do
        local name, realm = UnitName("party" .. i)
        if not realm then
            -- unit is on the same realm
            realm = Addon.Mykey["realm"]
        end
        if name then
            local player = string.format("%s-%s", name, realm)
            playerinparty[player] = true
        end
    end
    playerinparty[Addon.Mykey["fullname"]] = true

    for key in pairs(Addon.PartyKeys) do
        if not playerinparty[key] then
            Addon.PartyKeys[key] = nil
        end
    end
end

function Addon.receiveKeystone(addOnName, message, channel, character)
    if (addOnName == Addon.ShortName) then
        if channel == "PARTY" then
            local key, keylevel, class, fullname = string.split(":", message)
            Addon.PartyKeys[fullname] = Addon.PartyKeys[fullname] or {}
            Addon.PartyKeys[fullname]["class"] = class
            Addon.PartyKeys[fullname]["current_key"] = tonumber(key)
            Addon.PartyKeys[fullname]["current_keylevel"] = tonumber(keylevel)
        end
        if channel == "GUILD" then
            local key, keylevel, class, fullname = string.split(":", message)
            local name, realm = string.split("-", fullname)
            local GuildName = GetGuildInfo("player") or "none"
            if not GuildName then return end
            LibMythicKeystoneDB['Guilds'] = LibMythicKeystoneDB['Guilds'] or {}
            LibMythicKeystoneDB['Guilds'][GuildName] = LibMythicKeystoneDB['Guilds'][GuildName] or {}
            LibMythicKeystoneDB['Guilds'][GuildName][fullname] = LibMythicKeystoneDB['Guilds'][GuildName][fullname] or {}
            LibMythicKeystoneDB['Guilds'][GuildName][fullname]["fullname"] = fullname
            LibMythicKeystoneDB['Guilds'][GuildName][fullname]["week"] = Addon.GetWeek()
            LibMythicKeystoneDB['Guilds'][GuildName][fullname]["guild"] = GuildName
            LibMythicKeystoneDB['Guilds'][GuildName][fullname]["current_key"] = tonumber(key)
            LibMythicKeystoneDB['Guilds'][GuildName][fullname]["current_keylevel"] = tonumber(keylevel)
            LibMythicKeystoneDB['Guilds'][GuildName][fullname]["class"] = class
            LibMythicKeystoneDB['Guilds'][GuildName][fullname]["name"] = name
            LibMythicKeystoneDB['Guilds'][GuildName][fullname]["realm"] = realm
        end
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
LibMythicKeystoneFrames["PartyEvent"]:SetScript("OnEvent",
    function(self, event, addOnName, message, channel, character, ...)
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
    Addon.removePartyKeystone()
    Addon.getKeystone()
end)

LibMythicKeystoneFrames["SendkeyEvent"] = CreateFrame("Frame", nil, LibMythicKeystoneFrame)
LibMythicKeystoneFrames["SendkeyEvent"]:RegisterEvent("BAG_UPDATE")
LibMythicKeystoneFrames["SendkeyEvent"]:RegisterEvent("PLAYER_ENTERING_WORLD")
LibMythicKeystoneFrames["SendkeyEvent"]:SetScript("OnEvent", function(self, event, ...)
    Addon.sendKeystone()
end)

local function bootlegRepeatingTimer()
    Addon.ProcessingKeys = false
    C_Timer.After(60, bootlegRepeatingTimer)
end
bootlegRepeatingTimer()

local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function(self, elap)
    Addon.getKeystone()
    Addon.removePartyKeystone()
end)




Addon.lib = lib
_G[ADDON] = lib
