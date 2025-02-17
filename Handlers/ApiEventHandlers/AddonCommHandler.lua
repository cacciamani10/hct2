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
                HCT:Print("Processing Death Event")
                AddonCommProcessor:ProcessEvent(payload)
                HCT:Print("Completed Death Event")
            elseif msgType == "SYNC_REQUEST" then
                HCT:Print("Processing Sync Request")
                AddonCommProcessor:ProcessSyncRequest(payload, sender)
                HCT:Print("Completed Sync Request")
            elseif msgType == "SYNC_UPDATE" then
                HCT:Print("Processing Sync Update")
                AddonCommProcessor:ProcessSyncUpdate(payload, sender)
                HCT:Print("Completed Sync Update")
            elseif msgType == "SYNC_FINAL" then
                HCT:Print("Processing Sync Final")
                AddonCommProcessor:ProcessSyncFinal(payload, sender)
                HCT:Print("Completed Sync Final")
            elseif msgType == "TEAMCHAT" then
                HCT_ChatModule:ProcessTeamChatMessage(payload)
            else
                HCT:Print("Received unknown message type: " .. tostring(msgType) .. " from " .. sender)
            end
        end
    end
}
