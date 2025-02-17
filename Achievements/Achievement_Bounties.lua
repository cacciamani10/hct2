if type(_G.ACHIEVEMENTS) ~= "table" then
    _G.ACHIEVEMENTS = {}
end
_G.ACHIEVEMENTS = _G.ACHIEVEMENTS or {}
_G.ACHIEVEMENTS.Achievement_Bounties = _G.ACHIEVEMENTS.Achievement_Bounties or {}

function _G.ACHIEVEMENTS.Achievement_Bounties:CheckAchievement(achievementId)
    _G.DAO.CharacterDao:AddBounty(achievementId)
end


function _G.ACHIEVEMENTS.Achievement_Bounties:CheckAchievements()
    return
end

function _G.ACHIEVEMENTS.Achievement_Bounties:GetTotalPoints(character)
    local bountyAchievements = HardcoreChallengeTracker_Data.bounties
    if not bountyAchievements or not character.achievements then
        return 0
    end

    local totalPoints = 0

    for _, achievement in ipairs(bountyAchievements) do
        if character.achievements[achievement.uniqueID] then
            totalPoints = totalPoints + ((achievement.points * character.achievements[achievement.uniqueID].count)  or 0)
        end
    end

    return totalPoints
end