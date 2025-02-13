_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerEnteringWorldHandler = {
    GetEventType = function() return "PLAYER_ENTERING_WORLD" end,
    GetHandlerName = function() return "PlayerEnteringWorldHandler" end,

    HandleEvent = function(self, HCT, event)
        -- Request data
        HCT_Broadcaster:RequestContestData() -- Request contest data from the guild.
        HCT:Print("Player entering world event handled.")
    end
}