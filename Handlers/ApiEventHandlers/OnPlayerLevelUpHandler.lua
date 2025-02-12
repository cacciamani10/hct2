local OnPlayerLevelUpHandler = {}

function OnPlayerLevelUpHandler:GetEventType()
    return "PLAYER_LEVEL_UP"
end

function OnPlayerLevelUpHandler:GetHandlerName()
    return "OnPlayerLevelUp"
end

function OnPlayerLevelUpHandler:HandleEvent(HCT, event, newLevel)
    newLevel = tonumber(newLevel)
    local charKey = UnitName("player")
    local charData = GetDB().characters[charKey]
    if charData then
        local oldLevel = tonumber(charData.level) or (newLevel - 1)
        local pointsAwarded = HCT_DataModule:GetLevelPoints(newLevel, oldLevel)
        charData.levelUpPoints = (charData.levelUpPoints or 0) + pointsAwarded
        charData.level = newLevel

        if HCT then
            HCT:Print("Level up! New level: " .. newLevel .. ". Awarded " .. pointsAwarded .. " level points.")
        end

        local battleTag = HCT_DataModule:GetBattleTag()
        local team = HCT_DataModule:GetPlayerTeam(battleTag)
        if team then
            GetDB().teams[team].points = (GetDB().teams[team].points or 0) + pointsAwarded
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

return OnPlayerLevelUpHandler
