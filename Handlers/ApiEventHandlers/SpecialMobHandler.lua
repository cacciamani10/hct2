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
        elseif subEvent == "UNIT_DIED" then
                -- Optionally, you can add filters here to ensure this is a mob death
                -- For example, checking if destName exists and if the GUID indicates a creature
                if destGUID:find("Creature") then
                    if destName and destGUID then
                        _G.ACHIEVEMENTS.Achievement_Bounties:CheckAchievement(801)
                    end
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
