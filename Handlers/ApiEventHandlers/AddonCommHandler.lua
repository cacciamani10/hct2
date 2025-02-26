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
            local success, msgType, message = AceSerializer:Deserialize(message)
            if not success then
                HCT:Print("Failed to deserialize message from " .. sender)
                HCT:Print("prefix: " .. prefix)
                HCT:Print("message: " .. message)
                return
            end

            if msgType == "CHARACTER_EVENT" then
                _G.Service.Character_Service:ProcessEvent(message)
            elseif msgType == "SYNC_REQUEST" then
                _G.Service.Sync_Service:ProcessSyncRequest(message, sender)
            elseif msgType == "SYNC_UPDATE" then
                _G.Service.Sync_Service:ProcessSyncUpdate(message, sender)
            elseif msgType == "SYNC_FINAL" then
                _G.Service.Sync_Service:ProcessSyncFinal(message, sender)
            elseif msgType == "TEAMCHAT" then
                HCT_ChatModule:ProcessTeamChatMessage(message)
            else
                HCT:Print("Received unknown message type: " .. tostring(msgType) .. " from " .. sender)
            end
        end
    end
}
