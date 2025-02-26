_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerLogoutHandler = {
    
    GetEventType = function() return "PLAYER_LOGOUT" end,

    HandleEvent = function(self, HCT, event)
        -- to try to only broadcast when a player actually logs out instead of also when they reload
        -- TODO try to use a trick where you register a chat command to a function to flip a flag to true
        -- then in here check the flag, set it to false, then return
        local event = {
            type = "PLAYER_LOGOUT",
            characterName = UnitName("player")
        }

        _G.Service.Event_Service:BroadcastEvent("CHARACTER_UPDATE", event)
    end
}
