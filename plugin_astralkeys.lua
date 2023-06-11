local ADDON, Addon = ...

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addOnName, ...)
    if AstralKeys then
        local GuildName = GetGuildInfo("player")
        if not GuildName then return end
        LibMythicKeystoneDB['Guilds'][GuildName] = LibMythicKeystoneDB['Guilds'][GuildName] or {}
        for _, value in pairs(AstralKeys) do
            if value['source'] == "guild" then
                local name, realm = strsplit("-",value['unit'])
                LibMythicKeystoneDB['Guilds'][GuildName][value['unit']] = LibMythicKeystoneDB['Guilds'][GuildName][value['unit']] or {}
                LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["class"] = LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["class"] or value["class"]
                LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["current_key"] = LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["current_key"] or value["dungeon_id"]
                LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["current_keylevel"] = LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["current_keylevel"] or value ["key_level"]
                LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["guild"] = LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["guild"] or GuildName
                LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["name"] = LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["name"] or name
                LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["realm"] = LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["realm"] or realm
                LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["week"] = LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["week"] or value["week"]
                LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["fullname"] = LibMythicKeystoneDB['Guilds'][GuildName][value['unit']]["fullname"] or value["unit"]
            end
        end
    end
end)
