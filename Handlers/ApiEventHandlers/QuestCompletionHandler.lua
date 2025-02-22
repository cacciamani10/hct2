_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.QuestCompletionHandler = {
    GetEventType = function() return "QUEST_TURNED_IN" end,
    GetHandlerName = function() return "QuestCompletionHandler" end,

    HandleEvent = function(self, HCT, event, questID, turnedInBy)
        local playerName = UnitName("player")

        if turnedInBy ~= playerName then
            return
        end

        _G.ACHIEVEMENTS.Achievement_Bounties:CheckAchievement(807)

        local eventData = {
            type = "QUEST_TURNED_IN",
            characterName = playerName,
            questID = questID,
            totalCompleted = count
        }
        
        HCT_Broadcaster:BroadcastEvent(eventData)
    end
}
