-- UIModule.lua
HCT_UIModule            = {}
local AceGUI            = LibStub("AceGUI-3.0")

-- Define color constants for each category (hex without the "|cff" prefix)
local ACHIEVEMENT_COLOR = "ffd700" -- gold
local BOUNTY_COLOR      = "00bfff" -- deep sky blue
local FEAT_COLOR     = "32cd32" -- lime green
local COMPLETED_COLOR   = "00ff00" -- green

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

local function FormatPlayersList(players)
    if not players or #players == 0 then
        return "None"
    end
    local formatted = ""
    for i, player in ipairs(players) do
        formatted = formatted .. "• " .. player .. "\n"
    end
    return formatted
end

local function AggregateTeamPoints(team)
    local total = 0
    local db = GetDB()
    for _, battleTag in ipairs(team.battleTags or {}) do
        local user = db.users[battleTag]
        if user and user.characters then
            for _, charName in ipairs(user.characters) do
                local charData = db.characters[charName]
                if charData then
                    total = total + (charData.levelUpPoints or 0)
                        + (charData.achievementPoints or 0)
                        + (charData.featPoints or 0)
                end
            end
        end
    end
    return total
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

    -- Dynamically compute team points.
    local team1Points = AggregateTeamPoints(team1)
    local team2Points = AggregateTeamPoints(team2)

    local t1Label = AceGUI:Create("Label")
    t1Label:SetFullWidth(true)
    t1Label:SetText(string.format("%s%s|r - Team Points: %s%d|r", team1ColorCode, team1Name, team1ColorCode, team1Points))
    container:AddChild(t1Label)

    local t1PlayersFormatted = FormatPlayersList(team1.battleTags)
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

    local t2PlayersFormatted = FormatPlayersList(team2.battleTags)
    local t2PlayersLabel = AceGUI:Create("Label")
    t2PlayersLabel:SetFullWidth(true)
    t2PlayersLabel:SetText("Players:\n" .. t2PlayersFormatted)
    container:AddChild(t2PlayersLabel)

    local spacer2 = AceGUI:Create("Label")
    spacer2:SetFullWidth(true)
    spacer2:SetText(" ")
    container:AddChild(spacer2)

    local totalPoints = team1Points + team2Points
    local percentTeam1 = totalPoints > 0 and (team1Points / totalPoints) * 100 or 50

    local progressSlider = AceGUI:Create("Slider")
    progressSlider:SetLabel("Tug of War Progress")
    progressSlider:SetFullWidth(true)
    progressSlider:SetSliderValues(0, 100, 1)
    progressSlider:SetValue(percentTeam1)
    progressSlider:SetDisabled(true)
    container:AddChild(progressSlider)
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

local function DrawCharacters(container)
    container:ReleaseChildren()
    local scrollFrame = AceGUI:Create("ScrollFrame")
    local db = GetDB()
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)
    for user, userData in pairs(db.users) do
        local userLabel = AceGUI:Create("Label")
        userLabel:SetFullWidth(true)
        userLabel:SetText("|cffaaaaaaUser:|r " .. user)
        scrollFrame:AddChild(userLabel)
        if userData.characters and #userData.characters > 0 then
            for _, charName in ipairs(userData.characters) do
                local charData = db.characters[charName]
                if charData then
                    local status = (charData.isDead and " [DEAD]" or "")
                    local charText = string.format(
                        "  - %s, Level: %d, Lvl Points: %d, Ach Points: %d, Trib Points: %d%s",
                        charName, charData.level, charData.levelUpPoints or 0, charData.achievementPoints or 0,
                        charData.featPoints or 0, status)
                    local charLabel = AceGUI:Create("Label")
                    charLabel:SetFullWidth(true)
                    charLabel:SetText(charText)
                    scrollFrame:AddChild(charLabel)
                    if charData.achievements then
                        local achText = "Achievements: "
                        if next(charData.achievements) == nil then
                            achText = achText .. "None"
                        else
                            for achName, completed in pairs(charData.achievements) do
                                if completed then
                                    achText = achText .. achName .. ", "
                                end
                            end
                            -- Remove trailing comma and space if necessary.
                            achText = achText:gsub(", $", "")
                        end
                        local achLabel = AceGUI:Create("Label")
                        achLabel:SetFullWidth(true)
                        achLabel:SetText("|cff" .. ACHIEVEMENT_COLOR .. achText .. "|r")
                        scrollFrame:AddChild(achLabel)
                    end
                else
                    local charLabel = AceGUI:Create("Label")
                    charLabel:SetFullWidth(true)
                    charLabel:SetText("  - " .. charName .. " (No data)")
                    scrollFrame:AddChild(charLabel)
                end
            end
        else
            local noneLabel = AceGUI:Create("Label")
            noneLabel:SetFullWidth(true)
            noneLabel:SetText("  No characters recorded.")
            scrollFrame:AddChild(noneLabel)
        end
        local spacer = AceGUI:Create("Label")
        spacer:SetFullWidth(true)
        spacer:SetText(" ")
        scrollFrame:AddChild(spacer)
    end
end

local function UpdateAchievementsContent(contentContainer, mode)
    contentContainer:ReleaseChildren()  -- attempt to index local 'contentContainer' (a nil value)

    if mode == "all" then
        -- Draw all available achievements
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
        -- Draw completed achievements (aggregated from user data)
        local completedAch = {}
        local db = GetDB()
        for user, userData in pairs(db.users) do
            if userData.characters then
                for _, charName in ipairs(userData.characters) do
                    local charData = db.characters[charName]
                    if charData and charData.achievements then
                        for achName, ts in pairs(charData.achievements) do
                            local found, points, cat = nil, 0, nil
                            for category, achList in pairs(HardcoreChallengeTracker_Data.achievements) do
                                for _, ach in ipairs(achList) do
                                    if ach.name == achName then
                                        found = true
                                        points = ach.points or 0
                                        cat = category
                                        break
                                    end
                                end
                                if found then break end
                            end
                            if found then
                                table.insert(completedAch, {
                                    player = charName,
                                    achievement = achName,
                                    category = cat,
                                    points = points,
                                    date = date("%Y-%m-%d %H:%M:%S", ts)
                                })
                            end
                        end
                    end
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
        -- Create Header for completed achievements.
        local completedHeader = AceGUI:Create("Heading")
        completedHeader:SetText("Completed Achievements")
        completedHeader:SetFullWidth(true)
        contentContainer:AddChild(completedHeader)

        for _, entry in ipairs(completedAch) do
            local label = AceGUI:Create("Label")
            label:SetFullWidth(true)
            label:SetText(string.format("|cff%s[%s]|r |cffffffff%s|r - Points: %d - Completed: %s",
                COMPLETED_COLOR, entry.category, entry.achievement, entry.points, entry.date))
            contentContainer:AddChild(label)
        end
    end
end

function HCT_UIModule:DrawAchievementsPage(container)
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

    -- Create and assign the content container as a ScrollFrame
    contentContainer = AceGUI:Create("ScrollFrame")
    contentContainer:SetLayout("Flow")
    contentContainer:SetFullWidth(true)
    contentContainer:SetFullHeight(true)
    container:AddChild(contentContainer)

    local heading = AceGUI:Create("Heading")
    heading:SetText(viewMode .. " achievements")
    heading:SetFullWidth(true)
    contentContainer:AddChild(heading)

    -- Initial draw with default mode "all"
    UpdateAchievementsContent(contentContainer, viewMode)
end



local function DrawBounties(container)
    container:ReleaseChildren()

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)

    local db = GetDB()
    local bounties = db.bounties or {}

    for _, bounty in ipairs(bounties) do
        local label = AceGUI:Create("Label")
        label:SetFullWidth(true)
        local description = bounty.description or "No description available"
        label:SetText(string.format("|cff%s%s|r - Points: %d\n%s", BOUNTY_COLOR, bounty.name, bounty.points or 0,
            description))
        scrollFrame:AddChild(label)
    end

    local completedHeader = AceGUI:Create("Heading")
    completedHeader:SetText("Completed Bounties")
    completedHeader:SetFullWidth(true)
    scrollFrame:AddChild(completedHeader)

    local completedBounties = {}                                      -- List of completed bounties.
    for user, userData in pairs(db.users) do                          -- Iterate over all users.
        if userData.characters then                                   -- Check if the user has characters.
            for _, charName in ipairs(userData.characters) do         -- Iterate over each character.
                local charData = db.characters[charName]              -- Get character data.
                if charData and charData.bounties then                -- Check if the character has completed bounties.
                    for bountyName, ts in pairs(charData.bounties) do -- Iterate over each completed bounty.
                        local found, points = nil,
                            0                                         -- Initialize variables to find the bounty and its points.
                        for _, bounty in ipairs(bounties) do          -- Iterate over all bounties.
                            if bounty.name == bountyName then         -- Check if the bounty matches the completed one.
                                found = true                          -- Mark the bounty as found.
                                points = bounty.points or 0           -- Get the points for the bounty.
                                break                                 -- Exit the loop since we found the bounty.
                            end                                       -- End of if bounty.name == bountyName.
                        end                                           -- End of for _, bounty in ipairs(bounties).
                        if found then                                 -- Check if the bounty was found.
                            table.insert(completedBounties, {         -- Add the completed bounty to the list.
                                player = charName,                    -- The player who completed the bounty.
                                bounty = bountyName,                  -- The name of the bounty.
                                points = points,                      -- The points for the bounty.
                                timestamp = ts
                            })                                        -- End of table.insert.
                        end                                           -- End of if found.
                    end                                               -- End of for bountyName, ts in pairs(charData.bounties).
                end                                                   -- End of if charData and charData.bounties.
            end                                                       -- End of for _, charName in ipairs(userData.characters).
        end                                                           -- End of if userData.characters.
    end                                                               -- End of for user, userData in pairs(db.users).
end

local function DrawFeats(container)
    container:ReleaseChildren()

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)

    local db = GetDB()
    local feats = db.feats or {}

    for _, feat in ipairs(feats) do
        local label = AceGUI:Create("Label")
        label:SetFullWidth(true)

        local description = feat.description or "No description available"
        label:SetText(string.format("|cff%s%s|r - Points: %d\n%s", FEAT_COLOR, feat.name, feat.points or 0,
            description))
        scrollFrame:AddChild(label)
    end

    local completedHeader = AceGUI:Create("Heading")
    completedHeader:SetText("Completed Feats")
    completedHeader:SetFullWidth(true)
    scrollFrame:AddChild(completedHeader)

    local completedFeats = {}                                          -- List of completed feats.
    for user, userData in pairs(db.users) do                              -- Iterate over all users.
        if userData.characters then                                       -- Check if the user has characters.
            for _, charName in ipairs(userData.characters) do             -- Iterate over each character.
                local charData = db.characters[charName]                  -- Get character data.
                if charData and charData.feats then                    -- Check if the character has completed feats.
                    for featName, count in pairs(charData.feats) do -- Iterate over each completed feat.
                        local found, points = nil,
                            0                                             -- Initialize variables to find the feat and its points.
                        for _, feat in ipairs(feats) do             -- Iterate over all feats.
                            if feat.name == featName then           -- Check if the feat matches the completed one.
                                found = true                              -- Mark the feat as found.
                                points = feat.points or 0              -- Get the points for the feat.
                                break                                     -- Exit the loop since we found the feat.
                            end                                           -- End of if feat.name == featName.
                        end                                               -- End of for _, feat in ipairs(feats).
                        if found then                                     -- Check if the feat was found.
                            table.insert(completedFeats, {             -- Add the completed feat to the list.

                                player = charName,                        -- The player who completed the feat.
                                feat = featName,                    -- The name of the feat.
                                points = points,                          -- The points for the feat.
                                count = count                             -- The number of times the feat was completed
                            })                                            -- End of table.insert.
                        end                                               -- End of if found.
                    end                                                   -- End of for featName, count in pairs(charData.feats).
                end                                                       -- End of if charData and charData.feats.
            end                                                           -- End of for _, charName in ipairs(userData.characters).
        end                                                               -- End of if userData.characters.
    end                                                                   -- End of for user, userData in pairs(db.users).

    table.sort(completedFeats, function(a, b)
        if a.player == b.player then
            return a.feat < b.feat
        else
            return a.player < b.player
        end
    end)

    for _, entry in ipairs(completedFeats) do
        local label = AceGUI:Create("Label")
        label:SetFullWidth(true)
        label:SetText(string.format("|cff%s%s|r - Points: %d - Completed: %d times", COMPLETED_COLOR, entry.feat,
            entry.points, entry.count))
        scrollFrame:AddChild(label)
    end
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

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    container:AddChild(scrollFrame)
end

function HCT_UIModule:ShowMainGUI()
    local guiFrame = AceGUI:Create("Frame")
    guiFrame:SetTitle("Hardcore Challenge Tracker")
    local statusText = "Neither team has scored yet."
    local db = GetDB()
    if db.teams[1].points and db.teams[2].points then
        local t1 = AggregateTeamPoints(db.teams[1])
        local t2 = AggregateTeamPoints(db.teams[2])
        if t1 > t2 then
            statusText = "Team 1 is ahead!"
        elseif t2 > t1 then
            statusText = "Team 2 is ahead!"
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
        { text = "Feats",     value = "feats" },
        { text = "Achievements", value = "achievements" },
        { text = "Bounties",     value = "bounties" },
        { text = "Tug of War",   value = "tugOfWar" },    
        { text = "Team Chat",    value = "teamChat" },
        { text = "Rules",        value = "rules" },
    })
    tabGroup:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "teamInfo" then
            DrawTeamInfo(container)
            guiFrame:SetStatusText(statusText)
        elseif group == "teamChat" then
            DrawTeamChat(container)
            -- Get the users team from their battleTag
            local team = HCT_DataModule:GetPlayerTeam(HCT_DataModule:GetBattleTag()) or ""
            guiFrame:SetStatusText(team .. " Chat")
        elseif group == "characters" then
            DrawCharacters(container)
            guiFrame:SetStatusText("Character Information")
        elseif group == "achievements" then
            HCT_UIModule:DrawAchievementsPage(container)
            guiFrame:SetStatusText("Achievements are earnable once per character.")
        elseif group == "feats" then
            DrawFeats(container)
            guiFrame:SetStatusText("Feats can only be earned once per contest.")
        elseif group == "bounties" then
            DrawBounties(container)
            guiFrame:SetStatusText(
                "Bounties can be earned infinitely - the level will reflect how many times you've completed it.")
        elseif group == "tugOfWar" then
            DrawTugOfWar(container)
            guiFrame:SetStatusText("Coming in Phase 2!")
        elseif group == "rules" then
            DrawRules(container)
            guiFrame:SetStatusText("Rules of the contest.")
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

-- Helper function to aggregate team points.
function AggregateTeamPoints(team)
    local total = 0
    local db = GetDB()
    for _, battleTag in ipairs(team.battleTags or {}) do
        local user = db.users[battleTag]
        if user and user.characters then
            for _, charName in ipairs(user.characters) do
                local charData = db.characters[charName]
                if charData then
                    total = total + (charData.levelUpPoints or 0)
                        + (charData.achievementPoints or 0)
                        + (charData.featPoints or 0)
                end
            end
        end
    end
    return total
end
