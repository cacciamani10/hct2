_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerLevelUpHandler = {
    GetEventType = function() return "PLAYER_LEVEL_UP" end,
    GetHandlerName = function() return "PlayerLevelUpHandler" end,
    
    HandleEvent = function(self, HCT, event, newLevel)
        _G.DAO.CharacterDao:UpdateCharacterLevel(tonumber(newLevel))
        _G.ACHIEVEMENTS.Achievement_Leveling.CheckAchievement()
        local uuid = _G.DAO.CharacterDao:GetUUID()
        
        local event = {
            type = _G.EventType.CHARACTER,
            subtype = "LEVEL_UP",
            uuid = uuid,
            character = _G.DAO.CharacterDao:GetCharacter()
        }

        _G.Service.Event_Service:BroadcastEvent("CHARACTER_UPDATE", event)
    end
}