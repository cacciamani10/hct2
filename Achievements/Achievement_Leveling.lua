if type(_G.ACHIEVEMENTS) ~= "table" then
    _G.ACHIEVEMENTS = {}
end
_G.ACHIEVEMENTS = _G.ACHIEVEMENTS or {}
_G.ACHIEVEMENTS.Achievement_Leveling = _G.ACHIEVEMENTS.Achievement_Leveling or {}

local function GetHCT() return _G.HCT_Env.GetAddon() end

function _G.ACHIEVEMENTS.Achievement_Leveling:CheckAchievement()
    local character = _G.DAO.CharacterDao:GetCharacter()

    local levelCheckpoints = HardcoreChallengeTracker_Data.achievements["Level Checkpoints"]

    for _, achievement in ipairs(levelCheckpoints or {}) do
        local requiredLevel = achievement.levelRequired
        if requiredLevel and character.level >= requiredLevel then
            --_G.HCT_Env.GetAddon():Print(achievement.uniqueID)
            _G.DAO.CharacterDao:AddLevelingAchievement(achievement.uniqueID)
        end
    end
end

function _G.ACHIEVEMENTS.Achievement_Leveling:CheckAchievements()
    local currentLevel = UnitLevel("player")
    local levelCheckpoints = HardcoreChallengeTracker_Data.achievements["Level Checkpoints"]
    for _, ach in ipairs(levelCheckpoints or {}) do
        local requiredLevel = tonumber(ach.name:match("Level (%d+) Reached"))
        if requiredLevel and currentLevel >= requiredLevel then
            _G.DAO.CharacterDao:AddLevelingAchievement(ach.uniqueID)
        end
    end
end

function _G.ACHIEVEMENTS.Achievement_Leveling:GetTotalPoints(character)
    local levelCheckpoints = HardcoreChallengeTracker_Data.achievements["Level Checkpoints"]
    if not levelCheckpoints or not character.achievements then
        return 0
    end

    local totalPoints = 0

    for _, achievement in ipairs(levelCheckpoints) do
        if character.achievements[achievement.uniqueID] then
            totalPoints = totalPoints + (achievement.points or 0)
        end
    end

    return totalPoints
end
