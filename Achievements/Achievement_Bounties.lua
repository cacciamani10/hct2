if type(_G.ACHIEVEMENTS) ~= "table" then
    _G.ACHIEVEMENTS = {}
end
_G.ACHIEVEMENTS = _G.ACHIEVEMENTS or {}
_G.ACHIEVEMENTS.Achievement_Bounties = _G.ACHIEVEMENTS.Achievement_Bounties or {}

function _G.ACHIEVEMENTS.Achievement_Bounties:CheckBountiesAchievements(achievementId)
    _G.DAO.CharacterDao:AddAchievement(achievementId)
end