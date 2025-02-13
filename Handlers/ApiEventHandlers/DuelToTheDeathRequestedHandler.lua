_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.DuelToTheDeathRequestedHandler = {
    GetEventType = function() return "DUEL_TO_THE_DEATH_REQUESTED" end,
    GetHandlerName = function() return "DuelToTheDeathRequestedHandler" end,

    HandleEvent = function(self, HCT, event)
        if not HCT then return end
        -- payload = playerName
        local playerName = event.payload.playerName
        HCT:Print("Duel to the death requested by " .. playerName)
        HCT:Print("Duel to the death requeste handled.")
    end
}