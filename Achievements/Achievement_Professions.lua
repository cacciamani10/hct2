if type(_G.ACHIEVEMENTS) ~= "table" then
    _G.ACHIEVEMENTS = {}
end
_G.ACHIEVEMENTS = _G.ACHIEVEMENTS or {}
_G.ACHIEVEMENTS.Achievement_Professions = _G.ACHIEVEMENTS.Achievement_Professions or {}

function _G.ACHIEVEMENTS.Achievement_Professions:CheckProfessionAchievement(professionName, professionLevel)
    for _, ach in ipairs(HardcoreChallengeTracker_Data.achievements["Profession Mastery"] or {}) do
        local reqLevelStr, profName = ach.description:match("Reach level (%d+)%s+(.+)")
        local requiredLevel = reqLevelStr and tonumber(reqLevelStr)
        if requiredLevel and professionLevel >= requiredLevel and profName:lower() == professionName:lower() then
            _G.DAO.CharacterDao:AddLevelingAchievement(ach.uniqueID)
        end
    end
end
