local HCT_Broadcaster = _G.HCT_Broadcaster

_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerLevelUpHandler = {
    GetEventType = function() return "PLAYER_LEVEL_UP" end,
    GetHandlerName = function() return "PlayerLevelUpHandler" end,
    
    HandleEvent = function(self, HCT, event, newLevel)
        if not HCT then return end
        local level = tonumber(newLevel)

        _G.DAO.CharacterDao:UpdateCharacterLevel(level)
        local username = UnitName("player")
        local battleTag = HCT_DataModule:GetBattleTag()
        local uuid = HCT.db.profile.users[battleTag].characters.alive[username]
        
        _G.ACHIEVEMENTS.Achievement_Leveling.CheckLevelingAchievements()

        local event = {
            type = "CHARACTER",
            uuid = uuid,
            character = _G.DAO.CharacterDao:GetCharacter()
        }

        HCT_Broadcaster:BroadcastEvent(event)
    end
}