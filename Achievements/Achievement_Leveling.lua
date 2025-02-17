if type(_G.ACHIEVEMENTS) ~= "table" then
    _G.ACHIEVEMENTS = {}
end
_G.ACHIEVEMENTS = _G.ACHIEVEMENTS or {}
_G.ACHIEVEMENTS.Achievement_Leveling = _G.ACHIEVEMENTS.Achievement_Leveling or {}

function _G.ACHIEVEMENTS.Achievement_Leveling:CheckLevelingAchievements()
    local character = _G.DAO.CharacterDao:GetCharacter()

    local levelCheckpoints = HardcoreChallengeTracker_Data.achievements["Level Checkpoints"]

    for _, ach in ipairs(levelCheckpoints or {}) do
        local requiredLevel = tonumber(ach.name:match("Level (%d+) Reached"))
        if requiredLevel and character.level >= requiredLevel then
            _G.DAO.CharacterDao:AddAchievement(ach.uniqueID)
        end
    end
end
