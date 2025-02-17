local HCT_Broadcaster = _G.HCT_Broadcaster

_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerLevelUpHandler = {
    GetEventType = function() return "PLAYER_LEVEL_UP" end,
    GetHandlerName = function() return "PlayerLevelUpHandler" end,
    
    HandleEvent = function(self, HCT, event, newLevel)
        if not HCT then return end
        level = tonumber(newLevel)

        _G.DAO.CharacterDao:UpdateCharacterLevel(level)
        local username = UnitName("player")
        local battleTag = HCT_DataModule:GetBattleTag()
        local uuid = HCT.db.profile.users[battleTag].characters.alive[username]

        local ev = {
            type = "CHARACTER",
            uuid = uuid
            battleTag = battleTag,
            level = newLevel,
            name = username,
            class = select(2, UnitClass("player")),
            race = select(2, UnitRace("player")),
            faction = UnitFactionGroup("player"),
            realm = GetRealmName(),
        }
        HCT_Broadcaster:BroadcastEvent(ev)
        -- recalculate achievements?
    end
}