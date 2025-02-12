_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerLevelUpHandler = {
    GetEventType = function() return "PLAYER_LEVEL_UP" end,
    GetHandlerName = function() return "PlayerLevelUpHandler" end,
    
    HandleEvent = function(self, HCT, event, newLevel)
        newLevel = tonumber(newLevel)
        local charKey = UnitName("player")
        local charData = HCT.db.profile.characters[charKey]

        if charData then
            local oldLevel = tonumber(charData.level) or (newLevel - 1)
            local pointsAwarded = HCT_DataModule:GetLevelPoints(newLevel, oldLevel)
            charData.levelUpPoints = (charData.levelUpPoints or 0) + pointsAwarded
            charData.level = newLevel

            HCT:Print("Level up! New level: " .. newLevel .. ". Awarded " .. pointsAwarded .. " level points.")

            local battleTag = HCT_DataModule:GetBattleTag()
            local team = HCT_DataModule:GetPlayerTeam(battleTag)
            if team then
                HCT.db.profile.teams[team].points = (HCT.db.profile.teams[team].points or 0) + pointsAwarded
            end

            local ev = {
                type = "LEVELUP",
                charKey = charKey,
                newLevel = newLevel,
                pointsAwarded = pointsAwarded,
                timestamp = time()
            }
            HCT:BroadcastEvent(ev)
        end
    end
}