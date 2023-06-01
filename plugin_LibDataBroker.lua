local ADDON, Addon = ...

local f = CreateFrame("frame")
local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject('LibMythicKeystone', {type='data source', label='MythicKeystone'})
f:SetScript("OnUpdate", function(self, elap)
    if Addon.Mykey["current_key"] > 0 then
        local keystoneMapName = Addon.Mykey["current_key"] and C_ChallengeMode.GetMapUIInfo(Addon.Mykey["current_key"]) or " "
        dataobj.text = Addon.Mykey["current_keylevel"] .. " ".. keystoneMapName
    else
        dataobj.text = ""
    end
end)
-- In the data source addon...
function dataobj:OnTooltipShow()
	self:AddLine("Alts")
    if LibMythicKeystoneDB['Alts'] then
        for key in pairs(LibMythicKeystoneDB['Alts']) do
            local text = ""
            local name = LibMythicKeystoneDB['Alts'][key]["fullname"] or ""
            if string.find(name, "-") then
                name,_ = string.split("-", name)
            end
            name = string.sub(name, 1, 12) -- cut long name
    
            local color = "|cFFFF000"
            if LibMythicKeystoneDB['Alts'][key]["class"] ~= "" then
                color = C_ClassColor.GetClassColor(LibMythicKeystoneDB['Alts'][key]["class"]):GenerateHexColorMarkup()
            end
            
            local keylevel = LibMythicKeystoneDB['Alts'][key]["current_keylevel"]
            
            local keystoneMapName = ""
            if LibMythicKeystoneDB['Alts'][key]["current_key"] ~= "" then
                keystoneMapName = LibMythicKeystoneDB['Alts'][key]["current_key"] and C_ChallengeMode.GetMapUIInfo(LibMythicKeystoneDB['Alts'][key]["current_key"]) or " "
            end
            if string.len(keystoneMapName) > 25 then
                keystoneMapName = string.sub(keystoneMapName or "", 1, 25) .. "..."
            end
    
            text = color .. name .. " " .. keylevel .. " " .. keystoneMapName .. "\n"
            self:AddLine(text)
        end
    end

end
