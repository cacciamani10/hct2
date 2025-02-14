_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerEnteringWorldHandler = {
    GetEventType = function() return "PLAYER_ENTERING_WORLD" end,
    GetHandlerName = function() return "PlayerEnteringWorldHandler" end,

    HandleEvent = function(self, HCT, event)
        if not HCT then return end
        local xp = UnitXP("player") 
        if xp == 0 then
            HCT:Print("PlayerEnteringWorldHandler: New character detected.") 
        end
        -- Request data
        if event.isInitialLogin then
            HCT_Broadcaster:RequestContestData()
        end
        HCT:Print("Player entering world event handled.")
    end
}