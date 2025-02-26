_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.QuestCompletionHandler = {
    GetEventType = function() return "QUEST_TURNED_IN" end,

    HandleEvent = function(self, HCT, event, questID, turnedInBy)
        local playerName = UnitName("player")

        if turnedInBy ~= playerName then
            return
        end

        _G.Dao.CharacterDao:AddBounty(807, 1)

        local event = {
            type = _G.EventType.CHARACTER,
            characterName = playerName,
            questID = questID,
            totalCompleted = count
        }
        
        _G.Service.Event_Service:BroadcastEvent("CHARACTER_UPDATE", event)
    end
}
