local HCT_Broadcaster = _G.HCT_Broadcaster

_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerLevelUpHandler = {
    GetEventType = function() return "PLAYER_LEVEL_UP" end,
    GetHandlerName = function() return "PlayerLevelUpHandler" end,
    
    HandleEvent = function(self, HCT, event, newLevel)
        newLevel = tonumber(newLevel)
        local characterName = UnitName("player")
        local battleTag = HCT_DataModule:GetBattleTag()
        local charKey =  characterName.. ":" .. battleTag
        local charData = HCT.db.profile.characters[charKey]

        if charData then
            local oldLevel = tonumber(charData.level) or (newLevel - 1)
            local pointsAwarded = HCT_DataModule:GetLevelPoints(newLevel, oldLevel)
            charData.level = newLevel

            HCT:Print("Level up! New level: " .. newLevel .. "!")

            local ev = {
                type = "CHARACTER",
                battleTag = battleTag,
                level = newLevel,
                name = characterName,
                class = select(2, UnitClass("player")),
                race = select(2, UnitRace("player")),
                faction = UnitFactionGroup("player"),
                realm = GetRealmName(),
                isDead = false,
            }
            HCT_Broadcaster:BroadcastEvent(ev)
        end
    end
}