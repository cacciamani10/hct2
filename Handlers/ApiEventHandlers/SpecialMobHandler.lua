_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.SpecialMobHandler = {
    GetEventType = function()
        return "COMBAT_LOG_EVENT_UNFILTERED"
    end,

    GetHandlerName = function()
        return "SpecialMobHandler"
    end,

    HandleEvent = function(self, HCT, event)
        local _, subEvent, _, _, _, _, _, destGUID, destName, _, _, _, overkill = CombatLogGetCurrentEventInfo()

        if subEvent == "UNIT_DIED" and overkill and overkill > 0 then
            local unitType, npcID = strsplit("-", destGUID)
            local classification = UnitClassification(destName)

            if classification == "rare" or classification == "rareelite" or classification == "elite" or classification == "worldboss" then
                local message = "You killed a " .. classification .. ": " .. (destName or "Unknown NPC")
                HCT:Print(message)

                local ev = {
                    type = "SPECIAL_KILL",
                    name = destName,
                    classification = classification,
                    characterName = UnitName("player"),
                    timestamp = time()
                }
                HCT_Broadcaster:BroadcastEvent(ev)
            end
        end
    end
}
