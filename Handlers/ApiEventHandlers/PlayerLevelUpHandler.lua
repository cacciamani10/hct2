local HCT_Broadcaster = _G.HCT_Broadcaster

_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerLevelUpHandler = {
    GetEventType = function() return "PLAYER_LEVEL_UP" end,
    GetHandlerName = function() return "PlayerLevelUpHandler" end,
    
    HandleEvent = function(self, HCT, event, newLevel)
        _G.DAO.CharacterDao:UpdateCharacterLevel(tonumber(newLevel))
        _G.ACHIEVEMENTS.Achievement_Leveling.CheckLevelingAchievements()
        local uuid = HCT.db.profile.users[HCT_DataModule:GetBattleTag()].characters.alive[UnitName("player")]
        
        local event = {
            type = "CHARACTER",
            uuid = uuid,
            character = _G.DAO.CharacterDao:GetCharacter()
        }

        HCT_Broadcaster:BroadcastEvent(event)
    end
}