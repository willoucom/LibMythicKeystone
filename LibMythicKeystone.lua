local ADDON, Addon = ...
local MAJOR, MINOR = "LibMythicKeystone-1.0", 1;
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end
local CTL = assert(ChatThrottleLib, "AceComm-3.0 requires ChatThrottleLib")

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

    Addon.Mykey = {
        ["class"] = classFilename,
        ["name"] = pname,
        ["realm"] = realm,
        ["fullname"] = player,
        ["current_key"] = keystoneMapID,
        ["guild"] = GuildName,
        ["current_keylevel"] = keystoneLevel,
        ["week"] = Addon.GetWeek()
    }

    Addon.PartyKeys[pname] = {
        ["class"] = classFilename,
        ["name"] = pname,
        ["realm"] = realm,
        ["fullname"] = player,
        ["current_key"] = keystoneMapID,
        ["current_keylevel"] = keystoneLevel
    }

    -- save in database
    if keystoneLevel > 0 and realm then
        -- save in alts
        LibMythicKeystoneDB['Alts'][player] = Addon.Mykey
        -- save in guild
        if GuildName ~= "none" then
            LibMythicKeystoneDB['Guilds'][GuildName][player] = Addon.Mykey
        end
    end

    -- Init group table
    local tempkeys = {}
    tempkeys[Addon.Mykey["name"]] = Addon.Mykey
    if IsInGroup(LE_PARTY_CATEGORY_HOME) then
        for i = 1, 4 do
            local name, realm = UnitNameUnmodified("party" .. i) or nil, nil
            local _, class = UnitClass("party" .. i)
            if not realm then
                -- unit is on the same realm
                realm = Addon.Mykey["realm"]
            end
            if name then
                tempkeys[name] = {}
                tempkeys[name]["class"] = class
                tempkeys[name]["name"] = name
                tempkeys[name]["realm"] = realm
                tempkeys[name]["current_key"] = 0
                tempkeys[name]["current_keylevel"] = 0
                if Addon.PartyKeys[name] then
                    tempkeys[name]["current_key"] = Addon.PartyKeys[name]["current_key"] or 0
                    tempkeys[name]["current_keylevel"] = Addon.PartyKeys[name]["current_keylevel"] or 0
                end
            end
        end
    end
    Addon.PartyKeys = tempkeys

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
            LibMythicKeystoneDB['Alts'][char] = nil
        end
    end


    Addon.ProcessingKeys = false
end

function Addon.sendKeystone()
    -- Sending to group
    if IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInRaid() then
        local data = Addon.Mykey["current_key"] .. ":"
            .. Addon.Mykey["current_keylevel"] .. ":"
            .. Addon.Mykey["class"] .. ":"
            .. Addon.Mykey["fullname"]
        CTL:SendAddonMessage("NORMAL", Addon.ShortName, data, "PARTY")
    end

    -- Sending to guild
    local GuildName = GetGuildInfo("player")
    if not GuildName then return end
    for _, value in pairs(LibMythicKeystoneDB['Alts']) do
        if value['guild'] == GuildName and value["current_key"] > 0 then
            local data = value["current_key"] .. ":"
                .. value["current_keylevel"] .. ":"
                .. value["class"] .. ":"
                .. value["fullname"]
            CTL:SendAddonMessage("NORMAL", Addon.ShortName, data, "GUILD")
        end
    end
end

function Addon.receiveKeystone(addOnName, message, channel, character)
    if channel == "PARTY" then
        if message == "requestPartyKeystone" then
            Addon.sendKeystone()
        elseif string.match(message, ":") then
            local key, keylevel, class, fullname = strsplit(":", message)
            character = strsplit("-", fullname)
            Addon.PartyKeys[character] = Addon.PartyKeys[character] or {}
            Addon.PartyKeys[character]["class"] = class
            Addon.PartyKeys[character]["current_key"] = tonumber(key)
            Addon.PartyKeys[character]["current_keylevel"] = tonumber(keylevel)
        end
    end
    if channel == "GUILD" then
        if message == "requestGuildKeystone" then
            Addon.sendKeystone()
        elseif string.match(message, ":") then
            local key, keylevel, class, fullname = strsplit(":", message)
            local name, realm = strsplit("-", fullname)
            local GuildName = GetGuildInfo("player")
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
end

function Addon.requestGuildKeystone()
    local GuildName = GetGuildInfo("player")
    if not GuildName then return end
    CTL:SendAddonMessage("NORMAL", Addon.ShortName, "requestGuildKeystone", "GUILD")
end

function Addon.requestPartyKeystone()
    if IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInRaid() then
        CTL:SendAddonMessage("NORMAL", Addon.ShortName, "requestPartyKeystone", "PARTY")
    end
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

LibMythicKeystoneFrames["RequestGuildKeyEvent"] = CreateFrame("Frame", nil, LibMythicKeystoneFrame)
LibMythicKeystoneFrames["RequestGuildKeyEvent"]:RegisterEvent("PLAYER_ENTERING_WORLD")
LibMythicKeystoneFrames["RequestGuildKeyEvent"]:SetScript("OnEvent", function(self, event, ...)
    C_Timer.After(10, Addon.requestGuildKeystone)
end)

LibMythicKeystoneFrames["SendkeyEvent"] = CreateFrame("Frame", nil, LibMythicKeystoneFrame)
LibMythicKeystoneFrames["SendkeyEvent"]:RegisterEvent("PLAYER_ENTERING_WORLD")
LibMythicKeystoneFrames["SendkeyEvent"]:RegisterEvent("GROUP_JOINED")
LibMythicKeystoneFrames["SendkeyEvent"]:RegisterEvent("GROUP_LEFT")
LibMythicKeystoneFrames["SendkeyEvent"]:RegisterEvent("GROUP_ROSTER_UPDATE")
LibMythicKeystoneFrames["SendkeyEvent"]:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED")
LibMythicKeystoneFrames["SendkeyEvent"]:RegisterEvent("ITEM_CHANGED")
LibMythicKeystoneFrames["SendkeyEvent"]:SetScript("OnEvent", function(self, event, ...)
    C_Timer.After(10, Addon.sendKeystone)
    C_Timer.After(10, Addon.requestPartyKeystone)
    C_Timer.After(10, Addon.requestGuildKeystone)
end)

local function bootlegRepeatingTimer()
    Addon.ProcessingKeys = false
    C_Timer.After(60, bootlegRepeatingTimer)
end
bootlegRepeatingTimer()

local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function(self, elap)
    Addon.getKeystone()
end)




Addon.lib = lib
_G[ADDON] = lib
