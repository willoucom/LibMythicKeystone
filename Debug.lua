local ADDON, Addon = ...

-- For debugging
Addon.debug = false

function Addon.trace(o)
    if Addon.debug then
        DevTools_Dump(o)
    end
end

Addon.trace("DEBUG")


if Addon.debug then
    local Debug = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    Debug:SetPoint("LEFT", 0, 0)
    Debug:SetSize(130, 20)
    Debug:SetMovable(true)
    Debug:EnableMouse(true)
    Debug:RegisterForDrag("LeftButton")
    Debug:SetScript("OnDragStart", Debug.StartMoving)
    Debug:SetScript("OnDragStop", Debug.StopMovingOrSizing)
    -- The code below makes the frame visible, and is not necessary to enable dragging.
    Debug:SetPoint("CENTER");
    local tex = Debug:CreateTexture("ARTWORK");
    tex:SetAllPoints();
    tex:SetTexture(1.0);
    tex:SetAlpha(0.5);

    local buttons = {}
    local ibutton = 0

    buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
    buttons[ibutton]:SetText("ReloadUI")
    buttons[ibutton]:SetScript("OnClick", function(self, button)
        C_UI.Reload()
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
        local nobody = "Nobody_" .. math.random(999)
        local tmp = Addon.Mykey
        tmp["current_key"] = 245
        tmp["current_keylevel"] = math.random(30)
        tmp["name"] = nobody
        tmp["fullname"] = nobody
        LibMythicKeystoneDB["Alts"][nobody] = tmp
        nobody = ""
        tmp = {}
    end)
    ibutton = ibutton + 1

    buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
    buttons[ibutton]:SetText("Reset DB")
    buttons[ibutton]:SetScript("OnClick", function(self, button)
        LibMythicKeystoneDB = {}
    end)
    ibutton = ibutton + 1

    buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
    buttons[ibutton]:SetText("Dump AstralKeys")
    buttons[ibutton]:SetScript("OnClick", function(self, button)
        if AstralKeys then
            Addon.trace(AstralKeys)
        else 
            Addon.trace("AstralKeys not found")
        end
    end)
    ibutton = ibutton + 1

    buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
    buttons[ibutton]:SetText("getKeystone")
    buttons[ibutton]:SetScript("OnClick", function(self, button)
        Addon.getKeystone()
    end)
    ibutton = ibutton + 1

    buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
    buttons[ibutton]:SetText("addFakeParty")
    buttons[ibutton]:SetScript("OnClick", function(self, button)
        local nobody = "Nobody_" .. math.random(1, 999)
        Addon.PartyKeys[nobody] = Addon.Mykey
        Addon.PartyKeys[nobody]["current_keylevel"] = math.random(1, 30)
        Addon.PartyKeys[nobody]["name"] = nobody
        Addon.PartyKeys[nobody]["current_key"] = 245
    end)
    ibutton = ibutton + 1

    buttons[ibutton] = CreateFrame("Button", nil, Debug, "UIPanelButtonTemplate")
    buttons[ibutton]:SetText("removeParty")
    buttons[ibutton]:SetScript("OnClick", function(self, button)
        Addon.removePartyKeystone()
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
    
    for key in pairs(buttons) do
        local startpos = -20 -40 * key
        buttons[key]:SetPoint("TOPLEFT", 0, startpos or 0)
        buttons[key]:SetSize(130, 40)
    end
end