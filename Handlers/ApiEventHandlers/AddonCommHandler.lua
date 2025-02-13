local AceSerializer = LibStub("AceSerializer-3.0")
local HCT_EventModule = _G.HCT_EventModule
_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.AddonCommHandler = {
    GetEventType = function()
        return _G.HCT_Env.GetAddon().addonPrefix
    end,

    GetHandlerName = function()
        return "AddonCommHandler"
    end,

    HandleEvent = function(self, HCT, prefix, message, distribution, sender)
        if prefix == HCT.addonPrefix then
            local myName = UnitName("player")
            -- if sender == myName or Ambiguate(sender, "none") == myName then return end
            local success, msgType, payload = AceSerializer:Deserialize(message)
            if not success then
                HCT:Print("Failed to deserialize message from " .. sender)
                HCT:Print("event: " .. event)
                HCT:Print("prefix: " .. prefix)
                HCT:Print("message: " .. message)
                return
            end

            if msgType == "EVENT" then
                AddonCommProcessor:ProcessEvent(payload)
            elseif msgType == "BULK_UPDATE" then
                AddonCommProcessor:ProcessBulkUpdate(payload)
                HCT:Print("Bulk update received and processed from " .. sender)
            elseif msgType == "REQUEST" then
                AddonCommProcessor:RespondToRequest(payload)
            elseif msgType == "TEAMCHAT" then
                HCT_ChatModule:ProcessTeamChatMessage(payload)
            else
                HCT:Print("Received unknown message type: " .. tostring(msgType) .. " from " .. sender)
            end
        end
    end
}
