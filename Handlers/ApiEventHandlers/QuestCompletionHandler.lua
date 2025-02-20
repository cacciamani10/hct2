_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.QuestCompletionHandler = {
    GetEventType = function() return "QUEST_TURNED_IN" end,
    GetHandlerName = function() return "QuestCompletionHandler" end,

    HandleEvent = function(self, HCT, event, questID)
        _G.ACHIEVEMENTS.Achievement_Bounties:CheckAchievement(807, nil)

        local eventData = {
            type = "QUEST_TURNED_IN",
            characterName = UnitName("player"),
            questID = questID,
            totalCompleted = count
        }
        
        HCT_Broadcaster:BroadcastEvent(eventData)
    end
}