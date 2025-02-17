if type(_G.ACHIEVEMENTS) ~= "table" then
    _G.ACHIEVEMENTS = {}
end
_G.ACHIEVEMENTS = _G.ACHIEVEMENTS or {}
_G.ACHIEVEMENTS.Achievement_Professions = _G.ACHIEVEMENTS.Achievement_Professions or {}

local function GetHCT() return _G.HCT_Env.GetAddon()end

function _G.ACHIEVEMENTS.Achievement_Professions:CheckAchievement(professionName, professionLevel)
    for _, ach in ipairs(HardcoreChallengeTracker_Data.achievements["Profession Mastery"] or {}) do
        local reqLevelStr, profName = ach.description:match("Reach level (%d+)%s+(.+)")
        local requiredLevel = reqLevelStr and tonumber(reqLevelStr)
        if requiredLevel and professionLevel >= requiredLevel and profName:lower() == professionName:lower() then
            _G.DAO.CharacterDao:AddLevelingAchievement(ach.uniqueID)
        end
    end
end

function _G.ACHIEVEMENTS.Achievement_Professions:CheckAchievements()
    local character = _G.DAO.CharacterDao:GetCharacter()
    if not character then return end

    local professionLevels = self:GetProfessionLevels()

    for _, achDef in ipairs(HardcoreChallengeTracker_Data.achievements["Profession Mastery"] or {}) do
        local reqLevelStr, profName = achDef.description:match("Reach level (%d+)%s+(.+)")
        local reqLevel = reqLevelStr and tonumber(reqLevelStr)
        if reqLevel and profName then
            local currentLevel = professionLevels[profName:lower()]
            if currentLevel and currentLevel >= reqLevel then
                _G.DAO.CharacterDao:AddLevelingAchievement(achDef.uniqueID)
            end
        end
    end
end

function _G.ACHIEVEMENTS.Achievement_Professions:GetProfessionLevels()
    local professionLevels = {}

    for i = 1, GetNumSkillLines() do
        local skillName, _, _, skillLevel = GetSkillLineInfo(i)
        if skillName then
            professionLevels[skillName:lower()] = skillLevel
        end
    end

    if next(professionLevels) == nil then
        GetHCT():Print("No professions found.")
    end

    return professionLevels
end

function _G.ACHIEVEMENTS.Achievement_Professions:GetTotalPoints(character)
    local total = 0
    local professionAchievements = HardcoreChallengeTracker_Data.achievements["Profession Mastery"]

    if character.achievements then
        return total
    end

    for _, achievement in ipairs(professionAchievements) do
        if character.achievements[achievement.uniqueID] then
            total = total + (achievement.points)
        end
    end

    return total
end

