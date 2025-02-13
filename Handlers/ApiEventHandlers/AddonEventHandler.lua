local AceSerializer = LibStub("AceSerializer-3.0")
local HCT_Broadcaster = _G.HCT_Broadcaster
local AddonEventProcessor = _G.AddonEventProcessor

_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.AddonEventHandler = {
    Chunks = {},
    Chunks_Remaining = 0,
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
        if sender == myName or Ambiguate(sender, "none") == myName then return end

        local success, msgType, payload = AceSerializer:Deserialize(message)

        if not success then
            HCT:Print("Failed to deserialize message from " .. sender)
            HCT:Print("event: " .. event)
            HCT:Print("prefix: " .. prefix)
            HCT:Print("message: " .. message)
            return
        end

        -- Handle different message types
        if msgType == "EVENT" then
            AddonEventProcessor:ProcessEvent(payload)
        elseif msgType == "BULK_UPDATE" then
            Chunks_Remaining = payload.chunks
        elseif msgType == "BULK_CHUNK" then
            if Chunks_Remaining == 0 then
                HCT:Print("Received chunk without expecting one from " .. sender)
                return
            end
            Chunks[payload.id] = payload.chunkData
            Chunks_Remaining = Chunks_Remaining - 1
            if Chunks_Remaining == 0 then
                AddonEventProcessor:ProcessBulkUpdate(Chunks)
                Chunks = {}
            end
        elseif msgType == "REQUEST" then
            AddonEventProcessor:RespondToRequest(payload)
        elseif msgType == "TEAMCHAT" then
            HCT_ChatModule:ProcessTeamChatMessage(payload)
        else
            HCT:Print("Received unknown message type: " .. tostring(msgType) .. " from " .. sender)
        end
    end
}
