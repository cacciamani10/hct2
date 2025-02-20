if type(_G.SERVICE) ~= "table" then
    _G.SERVICE = {}
end
_G.SERVICE = _G.SERVICE or {}
_G.SERVICE.Achievement_Service = _G.SERVICE.Achievement_Service or {}
local function GetHCT() return _G.HCT_Env.GetAddon() end

function _G.SERVICE.Achievement_Service:RecalculateAchievements()
    _G.ACHIEVEMENTS.Achievement_Leveling.CheckAchievement()
    _G.ACHIEVEMENTS.Achievement_Professions.CheckAchievements()
    self:checkQuestAchievements()
end

function checkQuestAchievements() {
    local completedQuests = GetQuestsCompleted()
    local count = 0

    for _ in pairs(completedQuests) do
        count = count + 1
    end

    _G.ACHIEVEMENTS.Achievement_Bounties:CheckAchievement(807, count)
}
