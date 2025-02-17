_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerLogoutHandler = {
    
    GetEventType = function() return "PLAYER_LOGOUT" end,
    GetHandlerName = function() return "PlayerLogoutHandler" end,

    HandleEvent = function(self, HCT, event)
        local event = {
            type = "PLAYER_LOGOUT",
            characterName = UnitName("player")
        }

        HCT_Broadcaster:BroadcastEvent(event)
    end
}
