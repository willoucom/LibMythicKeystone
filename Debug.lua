local ADDON, Addon = ...


-- For debugging
function Addon.trace(o)
    if Addon.debug then
        DevTools_Dump(o)
    end
end

local LibMythicKeystoneDebug = CreateFrame("Frame")
LibMythicKeystoneDebug:RegisterEvent("ADDON_LOADED")
LibMythicKeystoneDebug:SetScript("OnEvent", function(self, event, addOnName, ...)
    if addOnName == "LibMythicKeystone" then
        if not LibMythicKeystoneDB["options"] then
            LibMythicKeystoneDB["options"] = {}
        end
        if not LibMythicKeystoneDB["options"]["debug"] then
            LibMythicKeystoneDB["options"]["debug"] = false
        end
        Addon.debug = LibMythicKeystoneDB["options"]["debug"] or false

        if Addon.debug then
            print("LMK Debug status : ON")
            local Debug = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            Debug:SetPoint("TOPLEFT", 20, -20)
            Debug:SetSize(130, 20)
            Debug:SetMovable(true)
            Debug:EnableMouse(true)
            Debug:RegisterForDrag("LeftButton")
            Debug:SetScript("OnDragStart", Debug.StartMoving)
            Debug:SetScript("OnDragStop", Debug.StopMovingOrSizing)
            Debug.tex = Debug:CreateTexture("ARTWORK")
            Debug.tex:SetAllPoints();
            Debug.tex:SetTexture(1.0);
            Debug.tex:SetAlpha(0.5);

            local blackscreen = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            blackscreen:SetPoint("TOPLEFT", 0, 0)
            blackscreen:SetSize(9000, 9000)
            blackscreen.tex = blackscreen:CreateTexture("ARTWORK")
            blackscreen.tex:SetAllPoints(blackscreen)
            blackscreen.tex:SetColorTexture(0, 0, 0, 1)
            blackscreen.tex:SetAlpha(1);
            blackscreen:Hide()

            local buttons = {}
            local ibutton = 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("Disable DEBUG")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                Addon.debug = false
                LibMythicKeystoneDB["options"]["debug"] = Addon.debug
                C_UI.Reload()
            end)
            ibutton = ibutton + 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("ReloadUI")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                C_UI.Reload()
            end)
            ibutton = ibutton + 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("Black Screen")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                if blackscreen:IsVisible() then
                    blackscreen:Hide()
                else
                    blackscreen:Show()
                end
            end)
            ibutton = ibutton + 1



            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("sendKeystone")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                Addon.sendKeystone()
            end)
            ibutton = ibutton + 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("addFakeAlts")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                local _, class = GetClassInfo(math.random(GetNumClasses()))
                local nobody = class .. "-" .. math.random(999)
                local tmp = CopyTable(Addon.Mykey)
                tmp["current_key"] = 245
                tmp["class"] = class
                tmp["current_keylevel"] = math.random(30)
                tmp["name"] = nobody
                tmp["fullname"] = nobody
                LibMythicKeystoneDB["Alts"][nobody] = tmp
            end)
            ibutton = ibutton + 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("Reset DB")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                LibMythicKeystoneDB['Alts'] = {}
                LibMythicKeystoneDB['Guilds'] = {}
            end)
            ibutton = ibutton + 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("REFRESH Keystone")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                Addon.getKeystone()
            end)
            ibutton = ibutton + 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("addFakeParty")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                local nobody = "Nobody_" .. math.random(1, 999)
                Addon.PartyKeys[nobody] = {}
                local _, class = GetClassInfo(math.random(GetNumClasses()))
                Addon.PartyKeys[nobody]["current_keylevel"] = math.random(30)
                Addon.PartyKeys[nobody]["name"] = nobody
                Addon.PartyKeys[nobody]["class"] = class
                Addon.PartyKeys[nobody]["current_key"] = 245
                Addon.trace(Addon.PartyKeys)
                for key in pairs(Addon.PartyKeys) do
                    Addon.trace(key)
                end
            end)
            ibutton = ibutton + 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("showParty")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                Addon.trace(Addon.PartyKeys)
                for key in pairs(Addon.PartyKeys) do
                    Addon.trace(key)
                end
            end)
            ibutton = ibutton + 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("showMykey")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                Addon.trace(Addon.lib.getMyKeystone())
            end)
            ibutton = ibutton + 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("showMyAltskey")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                Addon.trace(Addon.lib.getAltsKeystone())
            end)
            ibutton = ibutton + 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("addFakeGuild")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                local guild = GetGuildInfo("player")
                if not guild then return end
                local _, classFilename = C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))
                local char = "toto"
                LibMythicKeystoneDB['Guilds'][guild] = LibMythicKeystoneDB['Guilds'][guild] or {}
                LibMythicKeystoneDB['Guilds'][guild][char] = {
                    ["class"] = classFilename,
                    ["name"] = char,
                    ["realm"] = char,
                    ["fullname"] = char,
                    ["current_key"] = 404,
                    ["current_keylevel"] = 10,
                    ["week"] = Addon.GetWeek()
                }
            end)
            ibutton = ibutton + 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("showGuild")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                Addon.trace(Addon.lib.getGuildKeystone())
            end)
            ibutton = ibutton + 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("request Keystone")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                Addon.requestGuildKeystone()
                Addon.requestPartyKeystone()
            end)
            ibutton = ibutton + 1


            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("homePlayers")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                local homePlayers = GetHomePartyInfo()
                Addon.trace(homePlayers)
                if homePlayers then
                    for _, name in pairs(homePlayers) do
                        Addon.trace(UnitName(name))
                        local _, class = UnitClass(name)
                        Addon.trace(class)
                    end
                end
            end)
            ibutton = ibutton + 1

            buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
            buttons[ibutton]:SetText("Get Week")
            buttons[ibutton]:SetScript("OnClick", function(self, button)
                Addon.trace(Addon.GetWeek())
                Addon.trace(C_WeeklyRewards.GetActivities(1))
            end)
            ibutton = ibutton + 1

            local startxpos = 0
            local startypos = 0
            local i = 0
            for key in ipairs(buttons) do
                if (key%2 ~= 0) then
                    startxpos = -10 - 40 * i
                    startypos = 0
                    i = i + 1
                else 
                    startypos = 130
                end
                buttons[key]:SetPoint("TOPLEFT", startypos or 0, startxpos or 0)
                buttons[key]:SetSize(130, 40)
            end
        end
    end
end)

SLASH_LMK1 = "/lmk"
SlashCmdList["LMK"] = function(msg)
    if msg == "debug on" then
        Addon.debug = true
        LibMythicKeystoneDB["options"]["debug"] = Addon.debug
        print("LMK Debug activated, please reload ui")
    elseif msg == "debug off" then
        Addon.debug = false
        LibMythicKeystoneDB["options"]["debug"] = Addon.debug
        print("LMK Debug disabled, please reload ui")
    else 
        print("Error: unknown command")
    end
end
