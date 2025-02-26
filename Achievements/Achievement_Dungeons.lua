if type(_G.ACHIEVEMENTS) ~= "table" then
    _G.ACHIEVEMENTS = {}
end
_G.ACHIEVEMENTS = _G.ACHIEVEMENTS or {}
_G.ACHIEVEMENTS.Achievement_Dungeons = _G.ACHIEVEMENTS.Achievement_Dungeons or {}

local function GetHCT() return _G.HCT_Env.GetAddon() end

function _G.ACHIEVEMENTS.Achievement_Dungeons:CheckAchievement(dungeonBossName)
    for _, ach in ipairs(HardcoreChallengeTracker_Data.achievements["Dungeon Clears"] or {}) do
        -- Extract the boss name from the achievement description
        local dungeonName = ach.description:match("Complete (.+)")
        local requiredBoss = HardcoreChallengeTracker_Data.dungeonBosses[dungeonName]
        -- Check if the boss has been killed
        if requiredBoss and dungeonBossName then
            -- Complete the achievement if the boss kill is found
            _G.DAO.CharacterDao:AddLevelingAchievement(ach.uniqueID)
        end
    end
    
end


function _G.ACHIEVEMENTS.Achievement_Dungeons:CheckAchievements()
    return
end

function _G.ACHIEVEMENTS.Achievement_Dungeons:GetTotalPoints(character)
    local DungeonAchievements = HardcoreChallengeTracker_Data["Dungeon Clears"]
    if not DungeonAchievements or not character.achievements then
        return 0
    end

    local totalPoints = 0

    for _, achievement in ipairs(DungeonAchievements) do
        if character.achievements[achievement.uniqueID] then
            totalPoints = totalPoints + (achievement.point or 0)
        end
    end

    return totalPoints
end