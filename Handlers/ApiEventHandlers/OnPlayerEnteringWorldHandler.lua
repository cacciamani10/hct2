_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.OnPlayerEnteringWorldHandler = {
    GetEventType = function() return "PLAYER_ENTERING_WORLD" end,
    GetHandlerName = function() return "OnPlayerEnteringWorldHandler" end,

    HandleEvent = function(self, HCT, event)
        -- Your event handling logic here
        HCT:Print("Player entering world event handled.")
    end
}