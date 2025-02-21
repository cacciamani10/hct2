if type(_G.ACHIEVEMENTS) ~= "table" then
    _G.ACHIEVEMENTS = {}
end
_G.ACHIEVEMENTS = _G.ACHIEVEMENTS or {}
_G.ACHIEVEMENTS.Achievement_Feats = _G.ACHIEVEMENTS.Achievement_Feats or {}

function _G.ACHIEVEMENTS.Achievement_Feats:CheckAchievement(achievementId)
    _G.DAO.CharacterDao:AddLevelingAchievement(achievementId)
end


function _G.ACHIEVEMENTS.Achievement_Feats:CheckAchievements()
    return
end

function _G.ACHIEVEMENTS.Achievement_Feats:GetTotalPoints(character)
    -- local bountyAchievements = HardcoreChallengeTracker_Data.bounties
    -- if not bountyAchievements or not character.achievements then
    --     return 0
    -- end

    -- local totalPoints = 0

    -- for _, achievement in ipairs(bountyAchievements) do
    --     if character.achievements[achievement.uniqueID] then
    --         totalPoints = totalPoints + ((achievement.points * character.achievements[achievement.uniqueID].count)  or 0)
    --     end
    -- end

    -- return totalPoints
    return 8080
end