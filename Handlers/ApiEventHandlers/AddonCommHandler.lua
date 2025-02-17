local AceSerializer = LibStub("AceSerializer-3.0")
_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.AddonCommHandler = {
    GetEventType = function()
        return _G.HCT_Env.GetAddon().addonPrefix
    end,

    GetHandlerName = function()
        return "AddonCommHandler"
    end,

    HandleEvent = function(self, HCT, prefix, message, distribution, sender)
        if not HCT then return end
        if prefix == HCT.addonPrefix then
            local myName = UnitName("player")
            if sender == myName or Ambiguate(sender, "none") == myName then return end
            local success, msgType, payload = AceSerializer:Deserialize(message)
            if not success then
                HCT:Print("Failed to deserialize message from " .. sender)
                HCT:Print("prefix: " .. prefix)
                HCT:Print("message: " .. message)
                return
            end

            if msgType == "EVENT" or msgType == "DEATH" then
                AddonCommProcessor:ProcessEvent(payload)
            elseif msgType == "SYNC_REQUEST" then
                AddonCommProcessor:ProcessSyncRequest(payload, sender)
            elseif msgType == "SYNC_UPDATE" then
                AddonCommProcessor:ProcessSyncUpdate(payload, sender)
            elseif msgType == "SYNC_FINAL" then
                AddonCommProcessor:ProcessSyncFinal(payload, sender)
            elseif msgType == "TEAMCHAT" then
                HCT_ChatModule:ProcessTeamChatMessage(payload)
            else
                HCT:Print("Received unknown message type: " .. tostring(msgType) .. " from " .. sender)
            end
        end
    end
}
