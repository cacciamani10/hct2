-- DataModule.lua
HCT_DataModule = {}

local function GetDB()
    return HCT.db.profile
end

local realm = HardcoreChallengeTracker_Data.realm
local faction = HardcoreChallengeTracker_Data.faction

-- (No longer need InitializeSavedVariables as AceDB handles that)

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
    if not achievement then 
        HCT:Print("No achievement data found.")
        return 
    end
    local achievementName = achievement.name
    local charData = GetDB().characters[charKey]
    if not charData then
        HCT:Print("No data found for character: " .. charKey)
        return
    end
    if charData.achievements and charData.achievements[achievementName] then
        HCT:Print("Achievement '" .. achievementName .. "' already completed for " .. charKey)
        return
    end

    charData.achievements = charData.achievements or {}
    charData.achievements[achievementName] = time()

    local points = achievement.points or 0
    charData.achievementPoints = (charData.achievementPoints or 0) + points

    HCT:Print("Achievement completed: " .. achievementName .. " (" .. points .. " points) for " .. charKey)

    local ev = {
        type = "ACHIEVEMENT",
        charKey = charKey,
        achievement = achievementName,
        pointsAwarded = points,
        timestamp = time(),
    }
    HCT_EventModule:BroadcastEvent(ev)
end

function HCT_DataModule:CheckLevelAchievements(charKey)
    local characters = GetDB().characters
    local charData = characters[charKey]
    if not charData then return end

    local currentLevel = charData.level or UnitLevel("player")
    local levelCheckpoints = HardcoreChallengeTracker_Data.achievements["Level Checkpoints"]
    for _, ach in ipairs(levelCheckpoints or {}) do
        local requiredLevel = tonumber(ach.name:match("Level (%d+) Reached"))
        if requiredLevel and currentLevel >= requiredLevel then
            if not (charData.achievements and charData.achievements[ach.name]) then
                self:CompleteAchievement(charKey, ach)
            end
        end
    end
end

function HCT_DataModule:InitializeUserData()
    local db = GetDB()
    local battleTag = HCT_DataModule:GetBattleTag()
    print("BattleTag: " .. battleTag)
    db.users = db.users or {}
    if not db.users[battleTag] then
        db.users[battleTag] = { totalDeaths = 0, characters = {} }
    end
    AssignPlayerToTeam(battleTag)
end

function HCT_DataModule:CheckDungeonClearAchievements(charKey)
    local characters = GetDB().characters
    local charData = characters[charKey]
    if not charData or not charData.dungeonClears then return end

    for _, ach in ipairs(HardcoreChallengeTracker_Data.achievements["Dungeon Clears"] or {}) do
        local dungeonName = ach.name
        if charData.dungeonClears[dungeonName] then
            if not (charData.achievements and charData.achievements[ach.name]) then
                self:CompleteAchievement(charKey, ach)
            end
        end
    end
end

function HCT_DataModule:GetProfessionLevel(profName)
    local numProfs = tonumber(GetNumPrimaryProfessions()) or 0
    for i = 1, numProfs do
        local name, _, skillLevel = GetProfessionInfo(i)
        if name and name:lower() == profName:lower() then
            return skillLevel
        end
    end
    return nil
end

function HCT_DataModule:BroadcastCharacterInfo()
    local charKey = UnitName("player")
    local _, playerClass = UnitClass("player")
    local race = UnitRace("player")
    local ev = {
        type = "CHARACTER_INFO",
        charKey = charKey,
        class = playerClass,
        level = UnitLevel("player"),
        race = race,    
        timestamp = time(),
    }
    HCT_EventModule:BroadcastEvent(ev)
end

function HCT_DataModule:CheckProfessionAchievements(charKey)
    local characters = GetDB().characters
    local charData = characters[charKey]
    if not charData then return end

    for _, achDef in ipairs(HardcoreChallengeTracker_Data.achievements["Profession Mastery"] or {}) do
        local reqLevelStr, profName = achDef.description:match("Reach level (%d+)%s+(.+)")
        local reqLevel = reqLevelStr and tonumber(reqLevelStr)
        if reqLevel and profName then
            local currentLevel = self:GetProfessionLevel(profName)
            if currentLevel and currentLevel >= reqLevel then
                if not (charData.achievements and charData.achievements[achDef.name]) then
                    self:CompleteAchievement(charKey, achDef)
                end
            end
        end
    end
end

function HCT_DataModule:CheckAllAchievements(charKey, filter)
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

function HCT_DataModule:InitializeCharacterData()
    local playerFaction = UnitFactionGroup("player")
    local playerRealm = GetRealmName()
    local charKey = UnitName("player")
    local db = GetDB()
    print("Realm: " .. playerRealm .. ", Faction: " .. playerFaction)
    print("Realm: " .. db.realm .. ", Faction: " .. db.faction)
    if playerRealm ~= db.realm then
        print("This character is not eligible. Invalid realm: " .. playerRealm)
        return
    end
    if playerFaction ~= db.faction then
        print("This character is not eligible. Invalid faction: " .. playerFaction)
        return
    end
    db.characters = db.characters or {}
    if not db.characters[charKey] then
        db.characters[charKey] = {
            level = UnitLevel("player"),
            achievements = {},
            bounties = {},
            feats = {},
            levelUpPoints = HCT_DataModule:GetLevelPoints(UnitLevel("player"), 1),
            achievementPoints = 0,
            featPoints = 0,
            isDead = false,
        }
        self:BroadcastCharacterInfo()
    end
    local battleTag = HCT_DataModule:GetBattleTag()
    db.users = db.users or {}
    db.users[battleTag] = db.users[battleTag] or { totalDeaths = 0, characters = {} }
    local found = false
    for _, key in ipairs(db.users[battleTag].characters) do
        if key == charKey then
            found = true
            break
        end
    end
    if not found then
        table.insert(db.users[battleTag].characters, charKey)
    end
end
