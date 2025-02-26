if not _G.UI then
    _G.UI = {}
end

if not _G.UI.CompletedAchievements then
    _G.UI.CompletedAchievements = {}
end

local AceGUI = LibStub("AceGUI-3.0")


local function DrawDropDown(contentContainer, onChangeCallback)
    local characters = _G.Dao.CharacterDao:GetCharacters()
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetLabel("Select Character")
    dropdown:SetFullWidth(true)

    local items = { all = "All Characters" }
    for uuid, charData in pairs(characters) do
        local name = charData.name or "Unknown"
        local level = charData.level or 0
        items[uuid] = string.format("%s (Level %d)", name, level)
    end

    dropdown:SetList(items)
    dropdown:SetValue("all")
    dropdown:SetCallback("OnValueChanged", function(widget, event, newValue)
        onChangeCallback(newValue)
    end)
    contentContainer:AddChild(dropdown)
end

function _G.UI.CompletedAchievements:DrawCompletedAchievements(contentContainer)
    local selectedChar = "all"

    DrawDropDown(contentContainer, function(newValue)
        selectedChar = newValue
        UpdateCompletedAchievements()
    end)

    -- Create a container to hold the list of completed achievements.
    local achievementsContainer = AceGUI:Create("SimpleGroup")
    achievementsContainer:SetLayout("Flow")
    achievementsContainer:SetFullWidth(true)
    contentContainer:AddChild(achievementsContainer)


    function GetCharacterAchievements(entries, characters)
        local achievements = {}
        for _, entry in ipairs(entries) do
            local uuid = entry.uuid
            if selectedChar == "all" or uuid == selectedChar then
                local charData = characters[uuid]
                if charData then
                    for achievementId, achievementData in pairs(charData.achievements or {}) do
                        local achievement, points, category = nil, 0, "Unknown"
                        for cat, achList in pairs(HardcoreChallengeTracker_Data.achievements) do
                            for _, ach in ipairs(achList) do
                                if ach.uniqueID == achievementId then
                                    local basePoints = ach.points
                                    if cat == "Bounties" then
                                        basePoints = math.floor((achievementData.count * ach.points) / ach.required) or 0
                                    end

                                    if charData.timestamp then
                                        basePoints = math.floor(basePoints / 2)
                                    end
                                    achievement = ach.name
                                    points = basePoints or 0
                                    category = cat
                                    break
                                end
                            end
                            if achievement then break end
                        end

                        table.insert(achievements, {
                            player = charData.name,
                            achievement = achievement or ("ID:" .. achievementId),
                            category = category,
                            points = points,
                            date = date("%Y-%m-%d %H:%M:%S", achievementData.timestamp)
                        })
                    end
                end
            end
        end
        return achievements
    end

    function UpdateCompletedAchievements()
        achievementsContainer:ReleaseChildren()
        local users = _G.Dao.UserDao:GetAllUsers() or {}
        local characters = _G.Dao.CharacterDao:GetCharacters() or {}
        local achievements = {}

        for battleTag, userData in pairs(users) do
            for username, entries in pairs(userData.characters.dead) do
                local characterAchievements = GetCharacterAchievements(entries, characters) or {}
                for _, ach in ipairs(characterAchievements) do
                    table.insert(achievements, ach)
                end
            end

            for username, entries in pairs(userData.characters.alive) do
                local characterAchievements = GetCharacterAchievements(entries, characters) or {}
                for _, ach in ipairs(characterAchievements) do
                    table.insert(achievements, ach)
                end
            end
        end

        table.sort(achievements, function(a, b)
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
        for _, entry in ipairs(achievements) do
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
