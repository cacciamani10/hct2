_G.HCT_Handlers = _G.HCT_Handlers or {}

local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

_G.HCT_Handlers.SpecialMobHandler = {
    GetEventType = function()
        return "COMBAT_LOG_EVENT_UNFILTERED"
    end,

    GetHandlerName = function()
        return "SpecialMobHandler"
    end,

    HandleEvent = function(self, HCT, event)
        local _, subEvent, _, _, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
        if subEvent == "PARTY_KILL" then
            if self:IsDungeonBoss(destName) then
                HCT:Print("SpecialMobHandler: Dungeon Boss Killed: " .. destName)
                _G.ACHIEVEMENTS.Achievement_Dungeons:CheckAchievement(destName)
            end
        end
    end,

    IsDungeonBoss = function(name)
        for _, boss in pairs(HardcoreChallengeTracker_Data.dungeonBosses) do
            if boss == name then return true end
        end
        return false
    end
}


-- elseif subEvent == "UNIT_DIED" then
        --     local unitType, npcID = strsplit("-", destGUID)
        --     local classification = UnitClassification(destName) or "normal" -- Default to normal if nil

        --     local validClassifications = {
        --         --normal = "Normal Mob",
        --         elite = "Elite Mob",
        --         rare = "Rare Mob",
        --         rareelite = "Rare Elite Mob",
        --         worldboss = "World Boss"
        --     }

        --     if validClassifications[classification] then
        --         local characterName = UnitName("player")
                
        --         local ev = {
        --             type = "SPECIAL_KILL",
        --             name = destName,
        --             classification = classification,
        --             characterName = characterName,
        --             timestamp = time()
        --         }
                
        --         -- Broadcast the event
        --         HCT_Broadcaster:BroadcastEvent(ev)
        --     end