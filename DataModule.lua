-- DataModule.lua
HCT_DataModule = {}

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
    db.myCompletions[completionID] = { timestamp = timeCompleted } -- Add to myCompletions table
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

function HCT_DataModule:CheckDungeonClearAchievements(charKey)
    if not charKey then
        GetHCT():Print("No character key provided.")
        return
    end
    local characters = GetDB().characters
    local charData = characters[charKey]
    if not charData or not charData.dungeonClears then return end

    for _, ach in ipairs(HardcoreChallengeTracker_Data.achievements["Dungeon Clears"] or {}) do
        local dungeonName = ach.name
        if charData.dungeonClears[dungeonName] then
            self:CompleteAchievement(charKey, ach)
        end
    end
end

function HCT_DataModule:GetProfessionLevel(profName)
    local profs = { GetProfessions() }
    for i = 1, #profs, 2 do
        local name, _, skillLevel = GetProfessionInfo(profs[i])
        if skillLevel then
            GetHCT():Print("Profession: " .. name .. " Level: " .. skillLevel)
            if name and name:lower() == profName:lower() then
                return skillLevel
            end
        end
    end
end

function HCT_DataModule:CheckProfessionAchievements(charKey)
    if not charKey then
        GetHCT():Print("No character key provided.")
        return
    end
    local characters = GetDB().characters
    local charData = characters[charKey]
    if not charData then return end

    for _, achDef in ipairs(HardcoreChallengeTracker_Data.achievements["Profession Mastery"] or {}) do
        local reqLevelStr, profName = achDef.description:match("Reach level (%d+)%s+(.+)")
        local reqLevel = reqLevelStr and tonumber(reqLevelStr)
        --():Print("Checking profession achievement for " ..
           -- charKey .. " at level " .. reqLevel .. " in " .. profName)
        if reqLevel and profName then
            local currentLevel = self:GetProfessionLevel(profName)
            if currentLevel and currentLevel >= reqLevel then
                self:CompleteAchievement(charKey, achDef)
            end
        end
    end
end

function HCT_DataModule:CheckAllAchievements(charKey, filter)
    GetHCT():Print("Checking all achievements for " .. charKey)
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
    if not charData then 
        local charKey = UnitName("player") .. ":" .. HCT_DataModule:GetBattleTag()
        charData = GetDB().characters[charKey] or {}
        if not charData then return 0 end -- No data found for character. Return 0 points.
    end
    local total = 0

    -- Level Points: Calculate based on current level.
    local currentLevel = charData.level or UnitLevel("player")
    -- Assuming GetLevelPoints calculates points from level 1 to currentLevel.
    total = total + self:GetLevelPoints(currentLevel, 0)

    -- Achievement Points: Loop through achievements the character has completed.
    local achievements = GetDB().completionLedger or {}
    
    for completionID, _ in pairs(achievements) do
        -- Get Character name and achievementID from completionLedger keys.
        local achID = completionID:match(":(.+)")
        local charName = completionID:match("(.+):")
        if charName == charData.name then -- Only count achievements for this character.
            for category, achList in pairs(HardcoreChallengeTracker_Data.achievements) do
                for _, achDef in ipairs(achList) do
                    if achDef.uniqueID == achID then
                        -- ids 500 - 799 are feats and will not be reduced by death.
                        if achDef.uniqueID >= 500 and achDef.uniqueID <= 799 then
                            total = total + achDef.points
                        else
                            total = total + achDef.points * (1 - charData.totalDeaths * 0.1)
                        end
                    end
                end
            end
        end
    end

    return total
end

function HCT_DataModule:InitializeCharacterData()
    local playerFaction = UnitFactionGroup("player")
    local playerRealm = GetRealmName()
    local characterName = UnitName("player")
    local db = GetDB()
    local battleTag = HCT_DataModule:GetBattleTag()
    local charKey = characterName .. ":" .. battleTag
    if playerRealm ~= db.realm then
        GetHCT():Print("This character is not eligible. Invalid realm: " .. playerRealm)
        return
    end
    if playerFaction ~= db.faction then
        GetHCT():Print("This character is not eligible. Invalid faction: " .. playerFaction)
        return
    end
    db.characters = db.characters or {}
    -- find the character in the db.characters table by name and realm, if not found, create a new entry
    if not db.characters[charKey] then
        local level = UnitLevel("player") or 1
        local class = select(2, UnitClass("player")) or "Unknown"
        local race = select(2, UnitRace("player")) or "Unknown"
        db.characters[charKey] = {
            battleTag = battleTag,
            level = level,
            name = characterName,
            class = class,
            race = race,
            faction = playerFaction,
            realm = playerRealm,
            isDead = false,
        }

        local ev = {
            type = "CHARACTER",
            battleTag = battleTag,
            level = level,
            name = characterName,
            class = class,
            race = race,
            faction = playerFaction,
            realm = playerRealm,
            isDead = false,
        }
        HCT_Broadcaster:BroadcastEvent(ev)
    end
    -- add the character to the user's character list if it is not already there
    db.users = db.users or {}
    db.users[battleTag] = db.users[battleTag] or { team = 1, totalDeaths = 0, characterKeys = {} }
    db.users[battleTag].characterKeys = db.users[battleTag].characterKeys or {}

    -- check if the character is already in the user's character list, if not, add item
    local found = false
    if not db.users[battleTag].characterKeys then db.users[battleTag].characterKeys = {} end
    for _, key in ipairs(db.users[battleTag].characterKeys) do
        if key == charKey then
            found = true
            break
        end
    end
    if not found then
        GetHCT():Print("Adding new character:" .. charKey)
        table.insert(db.users[battleTag].characterKeys, charKey)
    end
end
