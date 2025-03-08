local AceSerializer = LibStub("AceSerializer-3.0")

local function GetHCT() return _G.HCT_Env.GetAddon() end

_G.Service = _G.Service or {}
_G.Service.Event_Service = _G.Service.Event_Service or {}

function _G.Service.Event_Service:BroadcastEvent(eventType, event)
    local HCT = GetHCT()
        if not HCT then return end
        local serialized = AceSerializer:Serialize(eventType, event)
        if not serialized or serialized == "" then
            HCT:Print("Error: Serialized event is empty!")
            return
        end

        HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")
end

function _G.Service.Event_Service:WhisperEvent(eventType, event, player)
    local HCT = GetHCT()
        local serialized = AceSerializer:Serialize(eventType, event)
        if not serialized or serialized == "" then
            HCT:Print("Error: Serialized data is empty!")
            return
        end

        HCT:SendCommMessage(HCT.addonPrefix, serialized, "WHISPER", player)
end

return _G.Service.Event_Service.Event_Service