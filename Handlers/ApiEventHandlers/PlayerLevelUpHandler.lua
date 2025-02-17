local HCT_Broadcaster = _G.HCT_Broadcaster

_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerLevelUpHandler = {
    GetEventType = function() return "PLAYER_LEVEL_UP" end,
    GetHandlerName = function() return "PlayerLevelUpHandler" end,
    
    HandleEvent = function(self, HCT, event, newLevel)
        local uuid = _G.DAO.CharacterDao:GetUUID()
        
        local event = {
            type = "CHARACTER",
            uuid = uuid,
            character = _G.DAO.CharacterDao:GetCharacter()
        }

        HCT_Broadcaster:BroadcastEvent(event)
    end
}