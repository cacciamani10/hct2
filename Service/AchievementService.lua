_G.Service = _G.Service or {}
_G.Service.Achievement_Service = _G.Service.Achievement_Service or {}

local function checkQuestAchievements() 
    local completedQuests = GetQuestsCompleted()
    local count = 0

    for _ in pairs(completedQuests) do
        count = count + 1
    end
    _G.Dao.CharacterDao:AddBounty(807, count)
end

function _G.Service.Achievement_Service:RecalculateAchievements()
    _G.Service.Achievement_Service:CheckCharacterLevelAchievement()
    _G.Service.Achievement_Service:CheckProfessionAchievements()
    -- TODO only check this if the user doenst have the achievement yet
    checkQuestAchievements()
end

function _G.Service.Achievement_Service:CheckProfessionAchievement(professionName, professionLevel)
    for _, ach in ipairs(HardcoreChallengeTracker_Data.achievements["Profession Mastery"] or {}) do
        local reqLevelStr, profName = ach.description:match("Reach level (%d+)%s+(.+)")
        local requiredLevel = reqLevelStr and tonumber(reqLevelStr)
        if requiredLevel and professionLevel >= requiredLevel and profName:lower() == professionName:lower() then
            GetHCT():Print("Profession Mastery achievement triggered for " .. professionName .. " at level " .. professionLevel)
            _G.Dao.CharacterDao:AddLevelingAchievement(ach.uniqueID)
            return
        end
    end
end

function _G.Service.Achievement_Service:CheckCharacterLevelAchievement()
    local character = _G.Dao.CharacterDao:GetCharacter()

    local levelCheckpoints = HardcoreChallengeTracker_Data.achievements["Level Checkpoints"]

    for _, achievement in ipairs(levelCheckpoints or {}) do
        local requiredLevel = achievement.levelRequired
        if requiredLevel and character.level >= requiredLevel then
            _G.Dao.CharacterDao:AddLevelingAchievement(achievement.uniqueID)
        end
    end
end

function _G.Service.Achievement_Service:CheckDungeonAchievement(dungeonBossName)
    for _, ach in ipairs(HardcoreChallengeTracker_Data.achievements["Dungeon Clears"] or {}) do
        -- Extract the boss name from the achievement description
        local dungeonName = ach.description:match("Complete (.+)")
        local requiredBoss = HardcoreChallengeTracker_Data.dungeonBosses[dungeonName]
        -- Check if the boss has been killed
        if requiredBoss and dungeonBossName then
            -- Complete the achievement if the boss kill is found
            _G.Dao.CharacterDao:AddLevelingAchievement(ach.uniqueID)
        end
    end  
end

function _G.Service.Achievement_Service:CheckProfessionAchievements()
    local character = _G.Dao.CharacterDao:GetCharacter()
    if not character then return end

    local professionLevels = _G.Service.Achievement_Service:GetProfessionLevels()

    for _, achDef in ipairs(HardcoreChallengeTracker_Data.achievements["Profession Mastery"] or {}) do
        local reqLevelStr, profName = achDef.description:match("Reach level (%d+)%s+(.+)")
        local reqLevel = reqLevelStr and tonumber(reqLevelStr)
        if reqLevel and profName then
            local currentLevel = professionLevels[profName:lower()]
            if currentLevel and currentLevel >= reqLevel then
                _G.Dao.CharacterDao:AddLevelingAchievement(achDef.uniqueID)
            end
        end
    end
end

function _G.Service.Achievement_Service:GetProfessionLevels()
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

