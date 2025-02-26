if not _G.UI then
    _G.UI = {}
end

if not _G.UI.FeatsPage then
    _G.UI.FeatsPage = {}
end

local AceGUI = LibStub("AceGUI-3.0")
local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

function UpdateFeatsContent(contentContainer, mode)
    contentContainer:ReleaseChildren()
    local db = GetDB()

    if mode == "all" then
        -- List all available feats.
        for _, feat in ipairs(HardcoreChallengeTracker_Data.achievements["Feats"]) do
            local label = AceGUI:Create("Label")
            label:SetFullWidth(true)
            local description = feat.description or "No description available"
            label:SetText(string.format("|cff%s%s|r - Points: %d\n%s",
                _G.UI.SharedConstants.FEAT_COLOR, feat.name, feat.points or 0, description))
            contentContainer:AddChild(label)
        end
    elseif mode == "complete" then
        -- Complete mode: add a dropdown of characters.
        local characters = db.characters or {}
        local currentCharKey = _G.Utils.GameUtils:GetCharacterKey()
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

        function UpdateCompletedFeats()
            featsContainer:ReleaseChildren()
            local completedFeats = {}
            for completionID, data in pairs(db.myCompletions or {}) do
                -- Expected key format: "characterKey:achievementID"
                local charKey, achievementID = completionID:match("^(.-):(%d+)$")
                if charKey and achievementID then
                    if selectedChar == "all" or charKey == selectedChar then
                        local featName, points = nil, 0
                        for _, feat in ipairs(HardcoreChallengeTracker_Data.achievements["Feats"]) do
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
                    _G.UI.SharedConstants.COMPLETED_COLOR, entry.category, entry.achievement, entry.points, entry.date))
                featsContainer:AddChild(label)
            end
        end

        UpdateCompletedFeats()
    end
end

function _G.UI.FeatsPage:DrawFeatsPage(container)
    container:ReleaseChildren()

    local viewMode = "all" -- default mode
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