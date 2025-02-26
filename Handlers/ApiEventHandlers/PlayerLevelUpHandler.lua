_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerLevelUpHandler = {
    GetEventType = function() return "PLAYER_LEVEL_UP" end,
    
    HandleEvent = function(self, HCT, event, newLevel)
        _G.Dao.CharacterDao:UpdateCharacterLevel(tonumber(newLevel))
        _G.Service.Achievement_Service.CheckCharacterLevelAchievement()
        local uuid = _G.Dao.CharacterDao:GetUUID()
        
        local event = {
            type = _G.EventType.CHARACTER,
            subtype = "LEVEL_UP",
            uuid = uuid,
            character = _G.Dao.CharacterDao:GetCharacter()
        }

        _G.Service.Event_Service:BroadcastEvent("CHARACTER_UPDATE", event)
    end
}