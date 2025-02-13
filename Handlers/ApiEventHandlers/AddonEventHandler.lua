local AceSerializer = LibStub("AceSerializer-3.0")

_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.AddonEventHandler = {
    GetEventType = function()
        return "CHAT_MSG_ADDON"
    end,

    GetHandlerName = function()
        return "AddonEventHandler"
    end,

    HandleEvent = function(self, HCT, event, prefix, message, channel, sender)
        local addonPrefix = HCT.addonPrefix
        if prefix ~= addonPrefix then return end
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
            AddonEventProcessor:ProcessEvent(payload)
        elseif msgType == "BULK_UPDATE" then
            AddonEventProcessor:ProcessBulkUpdate(payload)
            HCT:Print("Bulk update received and processed from " .. sender)
        elseif msgType == "REQUEST" then
            AddonEventProcessor:RespondToRequest(payload)
        elseif msgType == "TEAMCHAT" then
            HCT_ChatModule:ProcessTeamChatMessage(payload)
        else
            HCT:Print("Received unknown message type: " .. tostring(msgType) .. " from " .. sender)
        end
    end
}
