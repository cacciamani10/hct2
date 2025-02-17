-- DataModule.lua
HCT_DataModule = {}

HCT_DataModule.calculatedData = {}

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

function HCT_DataModule:GetBattleTag()
    local info = select(2, BNGetInfo())
    return info and info:match("^(%S+#%S+)") or "unknown"
end

function HCT_DataModule:GetLevelPoints(newLevel, oldLevel)
    newLevel = tonumber(newLevel) or 0
    oldLevel = tonumber(oldLevel) or 0
    local points = 0
    for i = oldLevel + 1, newLevel do
        if i <= 20 then
            points = points + 1
        elseif i <= 40 then
            points = points + 2
        elseif i <= 60 then
            points = points + 3
        end
    end
    return points
end

function HCT_DataModule:CalculateContestData()
    local db = GetDB()
    local contestData = { team1 = 0, team2 = 0 }
    local players = db.users or {}
    local characters = db.characters or {}

    for playerKey, playerData in pairs(players) do
        local playerPoints = 0
        for _, charKey in ipairs(playerData.characterKeys or {}) do
            local charData = characters[charKey]
            if charData then
                local points = self:CalculateCharacterPoints(charData)
                playerPoints = playerPoints + points
                if playerData.team == 1 then
                    contestData.team1 = contestData.team1 + points
                elseif playerData.team == 2 then
                    contestData.team2 = contestData.team2 + points
                end
            end
        end
        contestData[playerKey] = playerPoints
    end
    self.calculatedData = contestData
    return contestData
end

function HCT_DataModule:GetCharacterKey()
    local name = UnitName("player") .. ":" .. HCT_DataModule:GetBattleTag()
    return name or "unknown"
end

function HCT_DataModule:GetPlayerTeam(player)
    local teams = GetDB().teams
    for i, team in ipairs(teams) do
        for _, name in ipairs(team.battleTags) do
            if name == player then
                return i
            end
        end
    end
    return nil
end

local function AssignPlayerToTeam(player)
    local teams = GetDB().teams
    for _, team in ipairs(teams) do
        for _, name in ipairs(team.battleTags) do
            if name == player then
                return
            end
        end
    end
    if #teams[1].battleTags > #teams[2].battleTags then
        table.insert(teams[2].battleTags, player)
    else
        table.insert(teams[1].battleTags, player)
    end
end

function HCT_DataModule:CompleteAchievement(charKey, achievement)
    if not charKey then
        GetHCT():Print("No character key provided.")
        return
    end
    if not achievement then
        GetHCT():Print("No achievement data found.")
        return
    end
    local charData = GetDB().characters[charKey]
    if not charData then
        GetHCT():Print("CompleteAchievement: No data found for character: " .. charKey)
        return
    end
    local completionID = charKey .. ":" .. achievement.uniqueID
    local db = GetDB()
    if db.myCompletions[completionID] then return end -- Already completed
    GetHCT():Print("Completing achievement: " .. achievement.name .. " for " .. charKey)
    local timeCompleted = time()
    db.myCompletions[completionID] = { timestamp = timeCompleted }    -- Add to myCompletions table
    db.completionLedger[completionID] = { timestamp = timeCompleted } -- Add to completionLedger table
end

function HCT_DataModule:CheckLevelAchievements(charKey)
    local characters = GetDB().characters
    local charData = characters[charKey]
    if not charData then
        GetHCT():Print("CheckLevelAchievements: No data found for character: " .. charKey)
        return
    end

    local currentLevel = charData.level or UnitLevel("player")
    local levelCheckpoints = HardcoreChallengeTracker_Data.achievements["Level Checkpoints"]
    -- GetHCT():Print("Checking level achievements for " .. charKey .. " at level " .. currentLevel)
    for _, ach in ipairs(levelCheckpoints or {}) do
        local requiredLevel = tonumber(ach.name:match("Level (%d+) Reached"))
        if requiredLevel and currentLevel >= requiredLevel then
            self:CompleteAchievement(charKey, ach)
        end
    end
end

function HCT_DataModule:InitializeUserData()
    local db = GetDB()
    local battleTag = HCT_DataModule:GetBattleTag()
    -- Get Team
    local team = HCT_DataModule:GetPlayerTeam(battleTag) or 1
    db.users = db.users or {}
    if not db.users[battleTag] then
        db.users[battleTag] = { team = team, totalDeaths = 0, characterKeys = {} }
    end
    AssignPlayerToTeam(battleTag)
end

function HCT_DataModule:IsDungeonBoss(name)
    for _, boss in pairs(HardcoreChallengeTracker_Data.dungeonBosses) do
        if boss == name then return true end
    end
    return false
end

-- Example function to handle boss defeat
function HCT_DataModule:OnBossDefeated(charKey, bossName)
    -- Check if the boss is a dungeon boss
    if self:IsDungeonBoss(bossName) then

        -- Update the dungeonBossKills table
        local localAchievementProgressData = GetDB().localAchievementProgressData or {}
        local dungeonBossKills = localAchievementProgressData[charKey] and localAchievementProgressData[charKey].dungeonBossKills or {}
        dungeonBossKills[bossName] = true

        -- Ensure the data is saved back to the database
        localAchievementProgressData[charKey] = localAchievementProgressData[charKey] or {}
        localAchievementProgressData[charKey].dungeonBossKills = dungeonBossKills
        GetDB().localAchievementProgressData = localAchievementProgressData

        -- Check for dungeon clear achievements
        self:CheckDungeonClearAchievements(charKey)
    end
end

function HCT_DataModule:CheckDungeonClearAchievements(charKey)
    if not charKey then
        GetHCT():Print("No character key provided.")
        return
    end

    -- Retrieve the character's dungeon boss kills from SavedVariables
    local localAchievementProgressData = GetDB().localAchievementProgressData or {}
    local dungeonBossKills = localAchievementProgressData[charKey] and localAchievementProgressData[charKey].dungeonBossKills or {}

    -- Iterate through the "Dungeon Clears" achievements
    for _, ach in ipairs(HardcoreChallengeTracker_Data.achievements["Dungeon Clears"] or {}) do
        -- Extract the boss name from the achievement description
        local dungeonName = ach.description:match("Complete (.+)") -- Get Dungeon Name
        local requiredBoss = HardcoreChallengeTracker_Data.dungeonBosses[dungeonName] -- Get Boss Name from Dungeon Name
        -- Check if the boss has been killed
        if requiredBoss and dungeonBossKills[requiredBoss] then
            -- Complete the achievement if the boss kill is found
            self:CompleteAchievement(charKey, ach)
        end
    end
end

function HCT_DataModule:GetProfessionLevels()
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

function HCT_DataModule:CheckProfessionAchievement(charKey, professionName, professionLevel)
    if not charKey then
        GetHCT():Print("No character key provided.")
        return
    end

    local characters = GetDB().characters
    local charData = characters[charKey]
    if not charData then return end

    for _, ach in ipairs(HardcoreChallengeTracker_Data.achievements["Profession Mastery"] or {}) do
        local reqLevelStr, profName = ach.description:match("Reach level (%d+)%s+(.+)")
        local requiredLevel = reqLevelStr and tonumber(reqLevelStr)
        if requiredLevel and professionLevel >= requiredLevel and profName:lower() == professionName:lower() then
            self:CompleteAchievement(charKey, ach)
        end
    end
end

-- Searches for all profession mastery achievements and checks if the character has completed them. If not, it will complete them.
function HCT_DataModule:CheckProfessionAchievements(charKey)
    if not charKey then
        GetHCT():Print("No character key provided.")
        return
    end

    local characters = GetDB().characters
    local charData = characters[charKey]
    if not charData then return end

    local professionLevels = self:GetProfessionLevels() -- Get all profession levels once

    for _, achDef in ipairs(HardcoreChallengeTracker_Data.achievements["Profession Mastery"] or {}) do
        local reqLevelStr, profName = achDef.description:match("Reach level (%d+)%s+(.+)")
        local reqLevel = reqLevelStr and tonumber(reqLevelStr)
        if reqLevel and profName then
            local currentLevel = professionLevels[profName:lower()]
            if currentLevel and currentLevel >= reqLevel then
                self:CompleteAchievement(charKey, achDef)
            end
        end
    end
end

function HCT_DataModule:CheckAllAchievements(charKey, filter)
    --GetHCT():Print("Checking all achievements for " .. charKey)
    if not filter or filter == "level" then
        self:CheckLevelAchievements(charKey)
    end
    if not filter or filter == "dungeon" then
        self:CheckDungeonClearAchievements(charKey)
    end
    if not filter or filter == "profession" then
        self:CheckProfessionAchievements(charKey)
    end
end

function HCT_DataModule.NormalizeColor(color)
    if color.r <= 1 and color.g <= 1 and color.b <= 1 then
        return { r = math.floor(color.r * 255), g = math.floor(color.g * 255), b = math.floor(color.b * 255) }
    else
        return color
    end
end

function HCT_DataModule:CalculateCharacterPoints(charData)
    local HCT = GetHCT()
    local db = GetDB()
    if not charData then
        local charKey = UnitName("player") .. ":" .. HCT_DataModule:GetBattleTag()
        charData = GetDB().characters[charKey] or {}
        if not charData then
            GetHCT():Print("CalculateCharacterPoints: No data found for character: " .. charKey)
            return 0
        end
    end
    local total = 0

    -- Determine penaltyFactor based solely on isDead.
    local penaltyFactor = charData.isDead and 0.5 or 1

    -- Level Points: Calculate based on current level.
    local currentLevel = charData.level or UnitLevel("player")
    total = total + math.floor(HCT_DataModule:GetLevelPoints(currentLevel) * penaltyFactor)

    -- Achievement Points: Loop through achievements the character has completed.
    for completionID, _ in pairs(db.completionLedger or {}) do
        -- Expected format: "<characterName>:<battleTag>:<achievementID>"
        local charName, battleTag, achIDStr = completionID:match("^(.-):(.-):(%d+)$")
        if charName and achIDStr and charName == charData.name then
            local achID = tonumber(achIDStr)
            for category, achList in pairs(HardcoreChallengeTracker_Data.achievements) do
                for _, achDef in ipairs(achList) do
                    if achDef.uniqueID == achID then
                        if achDef.uniqueID >= HardcoreChallengeTracker_Data.FEAT_START_ID and achDef.uniqueID <= HardcoreChallengeTracker_Data.FEAT_END_ID then
                            total = total + achDef.points
                        else
                            local penaltyFactor = charData.isDead and 0.5 or 1
                            total = total + math.floor(achDef.points * penaltyFactor)
                        end
                    end
                end
            end
        end
    end
    return total
end