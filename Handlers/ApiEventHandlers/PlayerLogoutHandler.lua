_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerLogoutHandler = {
    
    GetEventType = function() return "PLAYER_LOGOUT" end,
    GetHandlerName = function() return "PlayerLogoutHandler" end,

    HandleEvent = function(self, HCT, event)
        if not HCT then return end

        -- local characterName = UnitName("player")
        -- local ev = {
        --     type = "PLAYER_LOGOUT",
        --     characterName = characterName
        -- }

        -- HCT_Broadcaster:BroadcastEvent(ev)
    end
}
