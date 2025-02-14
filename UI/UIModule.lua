-- UIModule.lua
HCT_UIModule = {}
local AceGUI = LibStub("AceGUI-3.0")

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

-- Define color constants for each category (hex without the "|cff" prefix)
local ACHIEVEMENT_COLOR = "ffd700"          -- gold
local BOUNTY_COLOR      = "00bfff"          -- deep sky blue
local FEAT_COLOR        = "32cd32"          -- lime green
local COMPLETED_COLOR   = "00ff00"          -- green
local PLAYER_COLOR      = "ffffff"          -- white for names
local POINTS_COLOR      = "00ff00"          -- green for points
local RAID_CLASS_COLORS = RAID_CLASS_COLORS -- use the default class colors from Blizzard's API

local function FormatPlayersList(players, contestData)
    if not players or #players == 0 then
        return "None"
    end
    local formatted = ""
    for i, player in ipairs(players) do
        local points = contestData[player] or 0
        formatted = formatted .. "• |cff" .. PLAYER_COLOR .. player .. "|r " ..
            "(|cff" .. POINTS_COLOR .. points .. " points|r)" .. "\n"
    end
    return formatted
end

local function CalculateCharacterDetails(charData)
    local details = {}
    -- Base points
    details.levelPoints = HCT_DataModule:GetLevelPoints(charData.level, 0)
    details.achievementPoints = 0
    details.bountyPoints = 0

    local db = GetDB()
    local penaltyFactor = charData.isDead and 0.5 or 1
    for completionID, _ in pairs(db.completionLedger or {}) do
        -- Expected format: "characterName:battleTag:achievementID"
        local cName, battleTag, achievementID = completionID:match("^(.-):(.-):(%d+)$")
        if cName and achievementID and cName == charData.name then
            local achID = tonumber(achievementID)
            for category, achList in pairs(HardcoreChallengeTracker_Data.achievements) do
                for _, achDef in ipairs(achList) do
                    if achDef.uniqueID == achID then
                        -- For simplicity, let's assume bounty IDs are 800-899 and achievements are below 500.
                        if achID >= 800 and achID <= 899 then
                            details.bountyPoints = details.bountyPoints + math.floor(achDef.points * penaltyFactor)
                        elseif achID < 500 then
                            details.achievementPoints = details.achievementPoints +
                                math.floor(achDef.points * penaltyFactor)
                        end
                    end
                end
            end
        end
    end
    details.totalPoints = details.levelPoints + details.achievementPoints + details.bountyPoints
    return details
end

local function DrawCharactersPage(container)
    container:ReleaseChildren()

    local db = GetDB()
    local users = db.users or {}
    local characters = db.characters or {}

    -- Filter state variables
    local selectedTeam = 1
    local showDead = false

    -- Create a horizontal group for filter buttons.
    local filterGroup = AceGUI:Create("SimpleGroup")
    filterGroup:SetLayout("Flow")
    filterGroup:SetFullWidth(true)
    container:AddChild(filterGroup)

    local btnTeam1 = AceGUI:Create("Button")
    btnTeam1:SetText("Team 1")
    btnTeam1:SetCallback("OnClick", function()
        selectedTeam = 1
        UpdateCharactersContent()
    end)
    filterGroup:AddChild(btnTeam1)

    local btnTeam2 = AceGUI:Create("Button")
    btnTeam2:SetText("Team 2")
    btnTeam2:SetCallback("OnClick", function()
        selectedTeam = 2
        UpdateCharactersContent()
    end)
    filterGroup:AddChild(btnTeam2)

    local btnToggleDead = AceGUI:Create("Button")
    local function UpdateToggleButtonText()
        btnToggleDead:SetText(showDead and "Disable Dead" or "Enable Dead")
    end
    UpdateToggleButtonText()
    btnToggleDead:SetCallback("OnClick", function()
        showDead = not showDead
        UpdateToggleButtonText()
        UpdateCharactersContent()
    end)
    filterGroup:AddChild(btnToggleDead)

    -- Create the scroll frame for character listing.
    local contentContainer = AceGUI:Create("ScrollFrame")
    contentContainer:SetLayout("Flow")
    contentContainer:SetFullWidth(true)
    contentContainer:SetFullHeight(true)
    container:AddChild(contentContainer)

    -- Function to update the content based on filters.
    function UpdateCharactersContent()
        contentContainer:ReleaseChildren()
        -- Loop over each user in db.users.
        for battleTag, userData in pairs(users) do
            if userData.team == selectedTeam then
                local userHeader = AceGUI:Create("Heading")
                userHeader:SetFullWidth(true)
                userHeader:SetText(battleTag)
                contentContainer:AddChild(userHeader)
                -- For each character for this user.
                for _, charKey in ipairs(userData.characterKeys or {}) do
                    local charData = characters[charKey]
                    if charData and (showDead or not charData.isDead) then
                        local details = CalculateCharacterDetails(charData)

                        local charGroup = AceGUI:Create("InlineGroup")
                        charGroup:SetLayout("Flow")
                        charGroup:SetFullWidth(true)

                        -- Name (in red if dead, otherwise white)
                        local nameColor = charData.isDead and "ff0000" or PLAYER_COLOR
                        local nameHeading = AceGUI:Create("Heading")
                        nameHeading:SetFullWidth(true)
                        nameHeading:SetText(string.format("|cff%s%s|r", nameColor, charData.name))
                        charGroup:AddChild(nameHeading)

                        -- Basic info: Level and Class (with class colored)
                        local classColor = RAID_CLASS_COLORS[charData.class:upper()]
                        local classColorCode = classColor and
                            string.format("|cff%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255) or
                            "|cffffffff"
                        local basicInfo = AceGUI:Create("Label")
                        basicInfo:SetFullWidth(true)
                        basicInfo:SetText(string.format("Level: %d  |  Class: %s%s|r", charData.level, classColorCode,
                            charData.class))
                        charGroup:AddChild(basicInfo)

                        -- Total Points (highlighted, e.g., using a bold or distinct color)
                        local totalPointsLabel = AceGUI:Create("Label")
                        totalPointsLabel:SetFullWidth(true)
                        totalPointsLabel:SetText(string.format("Total Points: |cff%s%d|r", ACHIEVEMENT_COLOR,
                            details.totalPoints))
                        charGroup:AddChild(totalPointsLabel)

                        -- Breakdown: Level, Achievement, and Bounty Points
                        local pointsInfo = AceGUI:Create("Label")
                        pointsInfo:SetFullWidth(true)
                        pointsInfo:SetText(string.format(
                            "Level Points: %d  |  Achievement Points: %d  |  Bounty Points: %d",
                            details.levelPoints, details.achievementPoints, details.bountyPoints))
                        charGroup:AddChild(pointsInfo)

                        contentContainer:AddChild(charGroup)
                    end
                end
            end
        end
    end

    UpdateCharactersContent()
end

local function DrawTeamInfo(container)
    container:ReleaseChildren()
    local db = GetDB()
    local team1 = db.teams[1] or {}
    local team2 = db.teams[2] or {}

    local team1Name = team1.name or "Team 1"
    local team2Name = team2.name or "Team 2"

    local team1Color = team1.color or { r = 255, g = 0, b = 0 }
    team1Color = HCT_DataModule.NormalizeColor(team1Color)
    local team2Color = team2.color or { r = 0, g = 255, b = 0 }
    team2Color = HCT_DataModule.NormalizeColor(team2Color)
    local team1ColorCode = string.format("|cff%02x%02x%02x", team1Color.r, team1Color.g, team1Color.b)
    local team2ColorCode = string.format("|cff%02x%02x%02x", team2Color.r, team2Color.g, team2Color.b)

    -- Assume HCT_DataModule.calculatedData has been updated with player contributions.
    local contestData = HCT_DataModule.calculatedData or {}

    local team1Points = contestData["team1"] or 0
    local team2Points = contestData["team2"] or 0

    local t1Label = AceGUI:Create("Label")
    t1Label:SetFullWidth(true)
    t1Label:SetText(string.format("%s%s|r - Team Points: %s%d|r", team1ColorCode, team1Name, team1ColorCode, team1Points))
    container:AddChild(t1Label)

    -- Now include each player's point contribution in the list.
    local t1PlayersFormatted = FormatPlayersList(team1.battleTags, contestData)
    local t1PlayersLabel = AceGUI:Create("Label")
    t1PlayersLabel:SetFullWidth(true)
    t1PlayersLabel:SetText("Players:\n" .. t1PlayersFormatted)
    container:AddChild(t1PlayersLabel)

    local spacer1 = AceGUI:Create("Label")
    spacer1:SetFullWidth(true)
    spacer1:SetText(" ")
    container:AddChild(spacer1)

    local t2Label = AceGUI:Create("Label")
    t2Label:SetFullWidth(true)
    t2Label:SetText(string.format("%s%s|r - Team Points: %s%d|r", team2ColorCode, team2Name, team2ColorCode, team2Points))
    container:AddChild(t2Label)

    local t2PlayersFormatted = FormatPlayersList(team2.battleTags, contestData)
    local t2PlayersLabel = AceGUI:Create("Label")
    t2PlayersLabel:SetFullWidth(true)
    t2PlayersLabel:SetText("Players:\n" .. t2PlayersFormatted)
    container:AddChild(t2PlayersLabel)
end

local function DrawTeamChat(container)
    container:ReleaseChildren()
    GetHCT().teamChatContainer = container

    local logGroup = AceGUI:Create("SimpleGroup")
    logGroup:SetLayout("Flow")
    logGroup:SetFullWidth(true)
    logGroup:SetHeight(300)
    container:AddChild(logGroup)

    local chatLog = GetHCT().teamChatLog or {}
    for _, msg in ipairs(chatLog) do
        local msgLabel = AceGUI:Create("Label")
        msgLabel:SetFullWidth(true)
        msgLabel:SetText(msg)
        logGroup:AddChild(msgLabel)
    end

    local chatBox = AceGUI:Create("EditBox")
    chatBox:SetLabel("Team Chat")
    chatBox:SetFullWidth(true)
    chatBox:SetCallback("OnEnterPressed", function(widget, event, text)
        if text and text ~= "" then
            HCT_ChatModule:SendTeamChatMessage(text)
            widget:SetText("")
        end
    end)
    container:AddChild(chatBox)
end

local function UpdateAchievementsContent(contentContainer, mode)
    contentContainer:ReleaseChildren()
    local db = GetDB()

    if mode == "all" then
        -- Draw all available achievements (unchanged, with styling)
        for category, achList in pairs(HardcoreChallengeTracker_Data.achievements) do
            local catHeader = AceGUI:Create("Heading")
            catHeader:SetText(category)
            catHeader:SetFullWidth(true)
            contentContainer:AddChild(catHeader)
            table.sort(achList, function(a, b) return a.name < b.name end)
            for _, ach in ipairs(achList) do
                local label = AceGUI:Create("Label")
                label:SetFullWidth(true)
                local description = ach.description or "No description available"
                label:SetText(string.format("|cff%s%s|r - Points: %d\n%s",
                    ACHIEVEMENT_COLOR, ach.name, ach.points or 0, description))
                contentContainer:AddChild(label)
            end
        end
    elseif mode == "complete" then
        -- In the complete mode, add a dropdown of all characters at the top.
        local characters = db.characters or {}
        local currentCharKey = HCT_DataModule:GetCharacterKey()
        -- Add an option to show achievements from all characters.
        local selectedChar = "all" -- default to all characters

        local dropdown = AceGUI:Create("Dropdown")
        dropdown:SetLabel("Select Character")
        dropdown:SetFullWidth(true)
        local items = {}
        items["all"] = "All Characters"
        for charKey, charData in pairs(characters) do
            local name = charData.name or "Unknown"
            local level = charData.level or 0
            items[charKey] = string.format("%s (Level %d)", name, level)
        end
        dropdown:SetList(items)
        dropdown:SetValue("all")
        dropdown:SetCallback("OnValueChanged", function(widget, event, newValue)
            selectedChar = newValue
            UpdateCompletedAchievements()
        end)
        contentContainer:AddChild(dropdown)

        -- Create a container to hold the list of completed achievements.
        local achievementsContainer = AceGUI:Create("SimpleGroup")
        achievementsContainer:SetLayout("Flow")
        achievementsContainer:SetFullWidth(true)
        contentContainer:AddChild(achievementsContainer)

        -- Define a function that updates the achievements list based on the selected character.
        function UpdateCompletedAchievements()
            achievementsContainer:ReleaseChildren()
            local completedAch = {}
            for completionID, data in pairs(db.completionLedger or {}) do
                -- Expected key format: "characterKey:achievementID"
                local charKey, achievementID = completionID:match("^(.-):(%d+)$")
                if charKey and achievementID then
                    -- If "all" is selected, include all completions; otherwise, only include the ones matching selectedChar.
                    if selectedChar == "all" or charKey == selectedChar then
                        local achievement, points, category = nil, 0, "Unknown"
                        for cat, achList in pairs(HardcoreChallengeTracker_Data.achievements) do
                            for _, ach in ipairs(achList) do
                                if tostring(ach.uniqueID) == achievementID then
                                    achievement = ach.name
                                    points = ach.points or 0
                                    category = cat
                                    break
                                end
                            end
                            if achievement then break end
                        end
                        table.insert(completedAch, {
                            player = charKey,
                            achievement = achievement or ("ID:" .. achievementID),
                            category = category,
                            points = points,
                            date = date("%Y-%m-%d %H:%M:%S", data.timestamp)
                        })
                    end
                end
            end
            table.sort(completedAch, function(a, b)
                if a.player == b.player then
                    return a.achievement < b.achievement
                else
                    return a.player < b.player
                end
            end)
            local completedHeader = AceGUI:Create("Heading")
            completedHeader:SetText("Completed Achievements")
            completedHeader:SetFullWidth(true)
            achievementsContainer:AddChild(completedHeader)
            for _, entry in ipairs(completedAch) do
                local label = AceGUI:Create("Label")
                label:SetFullWidth(true)
                label:SetText(string.format("|cff%s[%s]|r |cffffffff%s|r - Points: %d - Completed: %s",
                    COMPLETED_COLOR, entry.category, entry.achievement, entry.points, entry.date))
                achievementsContainer:AddChild(label)
            end
        end

        -- Initial population.
        UpdateCompletedAchievements()
    end
end

local function DrawAchievementsPage(container)
    container:ReleaseChildren()

    -- Store the current view mode; default is "all"
    local viewMode = "all"
    local contentContainer

    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    container:AddChild(buttonGroup)

    local btnAll = AceGUI:Create("Button")
    btnAll:SetText("All")
    btnAll:SetCallback("OnClick", function()
        viewMode = "all"
        UpdateAchievementsContent(contentContainer, viewMode)
    end)
    buttonGroup:AddChild(btnAll)

    local btnComplete = AceGUI:Create("Button")
    btnComplete:SetText("Complete")
    btnComplete:SetCallback("OnClick", function()
        viewMode = "complete"
        UpdateAchievementsContent(contentContainer, viewMode)
    end)
    buttonGroup:AddChild(btnComplete)

    contentContainer = AceGUI:Create("ScrollFrame")
    contentContainer:SetLayout("Flow")
    contentContainer:SetFullWidth(true)
    contentContainer:SetFullHeight(true)
    container:AddChild(contentContainer)

    local heading = AceGUI:Create("Heading")
    heading:SetText(viewMode .. " achievements")
    heading:SetFullWidth(true)
    contentContainer:AddChild(heading)

    UpdateAchievementsContent(contentContainer, viewMode)
end

local function UpdateBountiesContent(contentContainer, mode)
    contentContainer:ReleaseChildren()
    local db = GetDB()

    if mode == "all" then
        -- List all available bounties.
        for _, bounty in ipairs(HardcoreChallengeTracker_Data.bounties) do
            local label = AceGUI:Create("Label")
            label:SetFullWidth(true)
            local description = bounty.description or "No description available"
            label:SetText(string.format("|cff%s%s|r - Points: %d\n%s", 
                BOUNTY_COLOR, bounty.name, bounty.points or 0, description))
            contentContainer:AddChild(label)
        end
    elseif mode == "complete" then
        -- Completed mode: add dropdown to select a character.
        local characters = db.characters or {}
        local currentCharKey = HCT_DataModule:GetCharacterKey()
        local selectedChar = "all"  -- default: show all

        local dropdown = AceGUI:Create("Dropdown")
        dropdown:SetLabel("Select Character")
        dropdown:SetFullWidth(true)
        local items = {}
        items["all"] = "All Characters"
        for charKey, charData in pairs(characters) do
            local name = charData.name or "Unknown"
            local level = charData.level or 0
            items[charKey] = string.format("%s (Level %d)", name, level)
        end
        dropdown:SetList(items)
        dropdown:SetValue("all")
        dropdown:SetCallback("OnValueChanged", function(widget, event, newValue)
            selectedChar = newValue
            UpdateCompletedBounties()
        end)
        contentContainer:AddChild(dropdown)

        local bountyContainer = AceGUI:Create("SimpleGroup")
        bountyContainer:SetLayout("Flow")
        bountyContainer:SetFullWidth(true)
        contentContainer:AddChild(bountyContainer)

        local function UpdateCompletedBounties()
            bountyContainer:ReleaseChildren()
            local completedBounties = {}
            for completionID, data in pairs(db.completionLedger or {}) do
                -- Expected key format: "characterKey:achievementID"
                local charKey, achievementID = completionID:match("^(.-):(%d+)$")
                if charKey and achievementID then
                    if selectedChar == "all" or charKey == selectedChar then
                        local bountyName, points = nil, 0
                        -- Look up the bounty with matching uniqueID.
                        for _, bounty in ipairs(HardcoreChallengeTracker_Data.bounties) do
                            if tostring(bounty.uniqueID) == achievementID then
                                bountyName = bounty.name
                                points = bounty.points or 0
                                break
                            end
                        end
                        if bountyName then
                            table.insert(completedBounties, {
                                player = charKey,
                                achievement = bountyName,
                                category = "Bounty",
                                points = points,
                                date = date("%Y-%m-%d %H:%M:%S", data.timestamp)
                            })
                        end
                    end
                end
            end
            table.sort(completedBounties, function(a, b)
                if a.player == b.player then
                    return a.achievement < b.achievement
                else
                    return a.player < b.player
                end
            end)
            local header = AceGUI:Create("Heading")
            header:SetText("Completed Bounties")
            header:SetFullWidth(true)
            bountyContainer:AddChild(header)
            for _, entry in ipairs(completedBounties) do    
                local label = AceGUI:Create("Label")        
                label:SetFullWidth(true)                
                label:SetText(string.format("|cff%s[%s]|r |cffffffff%s|r - Points: %d - Completed: %s",
                    COMPLETED_COLOR, entry.category, entry.achievement, entry.points, entry.date))
                bountyContainer:AddChild(label)
            end
        end
        
        UpdateCompletedBounties()
    end
end

local function DrawBountiesPage(container)
    container:ReleaseChildren()
    
    local viewMode = "all"  -- default mode
    local contentContainer = AceGUI:Create("ScrollFrame")
    contentContainer:SetLayout("Flow")
    contentContainer:SetFullWidth(true)
    contentContainer:SetFullHeight(true)
    container:AddChild(contentContainer)
    
    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    container:AddChild(buttonGroup)
    
    local btnAll = AceGUI:Create("Button")
    btnAll:SetText("All")
    btnAll:SetCallback("OnClick", function()
        viewMode = "all"
        UpdateBountiesContent(contentContainer, viewMode)
    end)
    buttonGroup:AddChild(btnAll)
    
    local btnComplete = AceGUI:Create("Button")
    btnComplete:SetText("Complete")
    btnComplete:SetCallback("OnClick", function()
        viewMode = "complete"
        UpdateBountiesContent(contentContainer, viewMode)
    end)
    buttonGroup:AddChild(btnComplete)
    
    local heading = AceGUI:Create("Heading")
    heading:SetText(viewMode .. " bounties")
    heading:SetFullWidth(true)
    contentContainer:AddChild(heading)
    
    UpdateBountiesContent(contentContainer, viewMode)
end

local function UpdateFeatsContent(contentContainer, mode)
    contentContainer:ReleaseChildren()
    local db = GetDB()

    if mode == "all" then
        -- List all available feats.
        for _, feat in ipairs(HardcoreChallengeTracker_Data.feats) do
            local label = AceGUI:Create("Label")
            label:SetFullWidth(true)
            local description = feat.description or "No description available"
            label:SetText(string.format("|cff%s%s|r - Points: %d\n%s", 
                FEAT_COLOR, feat.name, feat.points or 0, description))
            contentContainer:AddChild(label)
        end
    elseif mode == "complete" then
        -- Complete mode: add a dropdown of characters.
        local characters = db.characters or {}
        local currentCharKey = HCT_DataModule:GetCharacterKey()
        local selectedChar = "all"

        local dropdown = AceGUI:Create("Dropdown")
        dropdown:SetLabel("Select Character")
        dropdown:SetFullWidth(true)
        local items = {}
        items["all"] = "All Characters"
        for charKey, charData in pairs(characters) do
            local name = charData.name or "Unknown"
            local level = charData.level or 0
            items[charKey] = string.format("%s (Level %d)", name, level)
        end
        dropdown:SetList(items)
        dropdown:SetValue("all")
        dropdown:SetCallback("OnValueChanged", function(widget, event, newValue)
            selectedChar = newValue
            UpdateCompletedFeats()
        end)
        contentContainer:AddChild(dropdown)

        local featsContainer = AceGUI:Create("SimpleGroup")
        featsContainer:SetLayout("Flow")
        featsContainer:SetFullWidth(true)
        contentContainer:AddChild(featsContainer)

        local function UpdateCompletedFeats()
            featsContainer:ReleaseChildren()
            local completedFeats = {}
            for completionID, data in pairs(db.myCompletions or {}) do
                -- Expected key format: "characterKey:achievementID"
                local charKey, achievementID = completionID:match("^(.-):(%d+)$")
                if charKey and achievementID then
                    if selectedChar == "all" or charKey == selectedChar then
                        local featName, points = nil, 0
                        for _, feat in ipairs(HardcoreChallengeTracker_Data.feats) do
                            if tostring(feat.uniqueID) == achievementID then
                                featName = feat.name
                                points = feat.points or 0
                                break
                            end
                        end
                        if featName then
                            table.insert(completedFeats, {
                                player = charKey,
                                achievement = featName,
                                category = "Feat",
                                points = points,
                                date = date("%Y-%m-%d %H:%M:%S", data.timestamp)
                            })
                        end
                    end
                end
            end
            table.sort(completedFeats, function(a, b)
                if a.player == b.player then
                    return a.achievement < b.achievement
                else
                    return a.player < b.player
                end
            end)
            local header = AceGUI:Create("Heading")
            header:SetText("Completed Feats")
            header:SetFullWidth(true)
            featsContainer:AddChild(header)
            for _, entry in ipairs(completedFeats) do    
                local label = AceGUI:Create("Label")        
                label:SetFullWidth(true)                
                label:SetText(string.format("|cff%s[%s]|r |cffffffff%s|r - Points: %d - Completed: %s",
                    COMPLETED_COLOR, entry.category, entry.achievement, entry.points, entry.date))
                featsContainer:AddChild(label)
            end
        end
        
        UpdateCompletedFeats()
    end
end

local function DrawFeatsPage(container)
    container:ReleaseChildren()
    
    local viewMode = "all"  -- default mode
    local contentContainer = AceGUI:Create("ScrollFrame")
    contentContainer:SetLayout("Flow")
    contentContainer:SetFullWidth(true)
    contentContainer:SetFullHeight(true)
    container:AddChild(contentContainer)
    
    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    container:AddChild(buttonGroup)
    
    local btnAll = AceGUI:Create("Button")
    btnAll:SetText("All")
    btnAll:SetCallback("OnClick", function()
        viewMode = "all"
        UpdateFeatsContent(contentContainer, viewMode)
    end)
    buttonGroup:AddChild(btnAll)
    
    local btnComplete = AceGUI:Create("Button")
    btnComplete:SetText("Complete")
    btnComplete:SetCallback("OnClick", function()
        viewMode = "complete"
        UpdateFeatsContent(contentContainer, viewMode)
    end)
    buttonGroup:AddChild(btnComplete)
    
    local heading = AceGUI:Create("Heading")
    heading:SetText(viewMode .. " feats")
    heading:SetFullWidth(true)
    contentContainer:AddChild(heading)
    
    UpdateFeatsContent(contentContainer, viewMode)
end


local function DrawTugOfWar(container)
    container:ReleaseChildren()

    local placeholder = AceGUI:Create("Label")
    placeholder:SetFullWidth(true)
    placeholder:SetText("Tug of War content coming soon!")

    container:AddChild(placeholder)
end

local function DrawRules(container)
    container:ReleaseChildren()

    -- Create a scroll frame for the rules content.
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)

    -- Heading for the rules page.
    local header = AceGUI:Create("Heading")
    header:SetText("Contest Rules")
    header:SetFullWidth(true)
    scrollFrame:AddChild(header)
    -- Spacer.
    local spacer = AceGUI:Create("Label")
    spacer:SetFullWidth(true)
    spacer:SetText(" ")
    scrollFrame:AddChild(spacer)

    -- Overview section.
    local overviewText = [[
Hardcore Challenge Tracker 2 is a World of Warcraft addon designed for a contest on WoW Classic Hardcore.
In this contest, players are split into two teams and earn points by:
- Leveling up
- Competing in team tug-of-war events
- Completing achievements
- Completing feats
- Completing bounties
    ]]
    local overviewLabel = AceGUI:Create("Label")
    overviewLabel:SetFullWidth(true)
    overviewLabel:SetText(overviewText)
    scrollFrame:AddChild(overviewLabel)

    -- Spacer.
    local spacer2 = AceGUI:Create("Label")
    spacer2:SetFullWidth(true)
    spacer2:SetText(" ")
    scrollFrame:AddChild(spacer2)

    -- Contest rules.
    local rulesText = [[
Contest Rules:
- All players must be on the same official hardcore server (as of 2024, these servers enforce a no-resurrection rule).
- If a player dies, points earned from leveling, achievements, and bounties are halved (truncated).
- Tug-of-war points and feats remain unchanged upon death.
- All players are on the same faction and guild but are split into two teams.
    ]]
    local rulesLabel = AceGUI:Create("Label")
    rulesLabel:SetFullWidth(true)
    rulesLabel:SetText(rulesText)
    scrollFrame:AddChild(rulesLabel)

    -- Spacer.
    local spacer3 = AceGUI:Create("Label")
    spacer3:SetFullWidth(true)
    spacer3:SetText(" ")
    scrollFrame:AddChild(spacer3)

    local scoringText = [[
    Contest Scoring Details

Level Score:
Your level score is determined solely by your character’s progression. Points are awarded for each level gained using the following scale:

Levels 1–20: 1 point per level
Levels 21–40: 2 points per level
Levels 41–60: 3 points per level
For example, if your character reaches level 30, you earn:
20 points for levels 1–20, plus
10 levels × 2 points per level = 20 points
This totals 40 level points.
Achievement and Bounty Points:
Completing achievements and bounties adds extra points to your score. Each task has a predetermined point value based on its difficulty and significance. These points are tallied separately and then added to your overall score.

Death Penalty:
In line with contest rules, if your character dies, points earned from leveling, achievements, and bounties are halved (with any fractional points truncated). This penalty applies only to those categories—points earned from tug-of-war events and feats remain unaffected.
For example, if you have accumulated 40 level points and 20 achievement points, a death would reduce these to 20 and 10 points respectively.

Overall Score:
Your total contest score is the sum of:

Level Points (adjusted by death if applicable)
Achievement Points (adjusted by death if applicable)
Bounty Points (adjusted by death if applicable) plus the full, unpenalized values of:
Tug-of-War Points
Feat Points
    ]]
    local scoringLabel = AceGUI:Create("Label")
    scoringLabel:SetFullWidth(true)
    scoringLabel:SetText(scoringText)
    scrollFrame:AddChild(scoringLabel)
end

function HCT_UIModule:ShowMainGUI()
    local guiFrame = AceGUI:Create("Frame")
    guiFrame:SetTitle("Hardcore Challenge Tracker")
    HCT_DataModule:CalculateContestData()
    local statusText = "Neither team has scored yet."
    local db = GetDB()
    if db.teams[1].points and db.teams[2].points then
        local t1 = HCT_DataModule.calculatedData["team1"] or 0
        local t2 = HCT_DataModule.calculatedData["team2"] or 0
        if t1 > t2 then
            statusText = db.teams[1].name .. " are ahead!"
        elseif t2 > t1 then
            statusText = db.teams[2].name .. " are ahead!"
        elseif t1 == t2 and t1 > 0 then
            statusText = "It's neck and neck!"
        end
    end
    guiFrame:SetStatusText(statusText)
    guiFrame:SetLayout("Fill")
    guiFrame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        GetHCT().teamChatContainer = nil
    end)

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Flow")
    tabGroup:SetTabs({
        { text = "Team Info",    value = "teamInfo" },
        { text = "Characters",   value = "characters" },
        { text = "Achievements", value = "achievements" },
        { text = "Bounties",     value = "bounties" },
        { text = "Feats",        value = "feats" },
        { text = "Tug of War",   value = "tugOfWar" },
        { text = "Team Chat",    value = "teamChat" },
        { text = "Rules",        value = "rules" },
    })
    tabGroup:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "teamInfo" then
            DrawTeamInfo(container)
            guiFrame:SetStatusText(statusText)
        elseif group == "characters" then
            DrawCharactersPage(container)
            guiFrame:SetStatusText("Characters are listed by team.")
        elseif group == "achievements" then
            DrawAchievementsPage(container)
            guiFrame:SetStatusText("Achievements are earnable once per character.")
        elseif group == "bounties" then
            DrawBountiesPage(container)
            guiFrame:SetStatusText("Bounties are earnable once per character.")
        elseif group == "feats" then
            DrawFeatsPage(container)
            guiFrame:SetStatusText("Feats are earnable only once in the contest.")
        elseif group == "tugOfWar" then
            DrawTugOfWar(container)
            guiFrame:SetStatusText("Coming in Phase 2!")
        elseif group == "rules" then
            DrawRules(container)
            guiFrame:SetStatusText("Rules of the contest.")
        elseif group == "teamChat" then
            DrawTeamChat(container)
            -- Get the users team from their battleTag
            local team = HCT_DataModule:GetPlayerTeam(HCT_DataModule:GetBattleTag()) or ""
            guiFrame:SetStatusText(team .. " Chat")
        else
            local placeholder = AceGUI:Create("Label")
            placeholder:SetFullWidth(true)
            placeholder:SetText("Content for the '" .. group .. "' tab coming soon!")
            container:AddChild(placeholder)
        end
    end)
    tabGroup:SelectTab("teamInfo")
    guiFrame:AddChild(tabGroup)
end
