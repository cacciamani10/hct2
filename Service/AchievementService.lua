_G.Service = _G.Service or {}
_G.Service.Achievement_Service = _G.Service.Achievement_Service or {}

local function checkQuestAchievements() 
    local completedQuests = GetQuestsCompleted()
    local count = 0

    for _ in pairs(completedQuests) do
        count = count + 1
    end

    _G.ACHIEVEMENTS.Achievement_Bounties:CheckAchievement(807, count)
end

function _G.Service.Achievement_Service:RecalculateAchievements()
    _G.ACHIEVEMENTS.Achievement_Leveling.CheckAchievement()
    _G.ACHIEVEMENTS.Achievement_Professions.CheckAchievements()
    checkQuestAchievements()
end
