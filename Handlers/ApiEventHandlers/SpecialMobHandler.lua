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
        local playerGUID = UnitGUID("player")
        local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()

        if subEvent == "PARTY_KILL" then
            if self:IsDungeonBoss(destName) then
                HCT:Print("SpecialMobHandler: Dungeon Boss Killed: " .. destName)
                _G.ACHIEVEMENTS.Achievement_Bounties:CheckAchievement(804)
                _G.ACHIEVEMENTS.Achievement_Dungeons:CheckAchievement(destName)
            end
            -- this keeps a running total creature kill count
            if destGUID:find("Creature") then
                if sourceGUID ~= playerGUID then
                    return
                end
                if destName and destGUID then
                    _G.ACHIEVEMENTS.Achievement_Bounties:CheckAchievement(801, nil)
                end
            end
        elseif subEvent == "UNIT_DIED" then
                -- this event triggers for other players
            end
        end,

    IsDungeonBoss = function(name)
        for _, boss in pairs(HardcoreChallengeTracker_Data.dungeonBosses) do
            if boss == name then return true end
        end
        return false
    end
}
