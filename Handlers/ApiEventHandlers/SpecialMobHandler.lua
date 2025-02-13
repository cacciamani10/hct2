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
            local classification = UnitClassification(destName) or "normal" -- Default to normal if nil

            local validClassifications = {
                normal = "Normal Mob",
                elite = "Elite Mob",
                rare = "Rare Mob",
                rareelite = "Rare Elite Mob",
                worldboss = "World Boss"
            }

            if validClassifications[classification] then
                local characterName = UnitName("player")
                local message = characterName .. " killed a " .. validClassifications[classification] .. ": " .. (destName or "Unknown NPC")
                
                HCT:Print(message)
                
                local ev = {
                    type = "SPECIAL_KILL",
                    name = destName,
                    classification = classification,
                    characterName = characterName,
                    timestamp = time()
                }
                
                -- Broadcast the event
                HCT_Broadcaster:BroadcastEvent(ev)
            end
        end
    end
}
