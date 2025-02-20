if not _G.UI then
    _G.UI = {}
end

if not _G.UI.AchievementsPage then
    _G.UI.AchievementsPage = {}
end

local AceGUI = LibStub("AceGUI-3.0")
local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

function _G.UI.AchievementsPage:DrawAchievementsPage(container)
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
        self:UpdateAchievementsContent(contentContainer, viewMode)
    end)
    buttonGroup:AddChild(btnAll)

    local btnComplete = AceGUI:Create("Button")
    btnComplete:SetText("Complete")
    btnComplete:SetCallback("OnClick", function()
        viewMode = "complete"
        self:UpdateAchievementsContent(contentContainer, viewMode)
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

    self:UpdateAchievementsContent(contentContainer, viewMode)
end

function UpdateAchievementsContent(contentContainer, mode)
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
                    _G.UI.SharedConstants.ACHIEVEMENT_COLOR, ach.name, ach.points or 0, description))
                contentContainer:AddChild(label)
            end
        end
    elseif mode == "complete" then
        -- In the complete mode, add a dropdown of all characters at the top.
        local characters = db.characters or {}
        local currentCharKey = _G.Utils.GameUtils:GetCharacterKey()
        -- Select your character at the start
        local selectedChar = currentCharKey or "all" -- default: show all

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
        dropdown:SetValue(currentCharKey or "all")
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
                    _G.UI.SharedConstants.COMPLETED_COLOR, entry.category, entry.achievement, entry.points, entry.date))
                achievementsContainer:AddChild(label)
            end
        end

        -- Initial population.
        UpdateCompletedAchievements()
    end
end