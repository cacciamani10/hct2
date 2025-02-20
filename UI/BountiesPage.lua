if not _G.UI then
    _G.UI = {}
end

if not _G.UI.BountiesPage then
    _G.UI.BountiesPage = {}
end

local AceGUI = LibStub("AceGUI-3.0")
local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

function _G.UI.BountiesPage:DrawBountiesPage(container)
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
        self:UpdateBountiesContent(contentContainer, viewMode)
    end)
    buttonGroup:AddChild(btnAll)

    local btnComplete = AceGUI:Create("Button")
    btnComplete:SetText("Complete")
    btnComplete:SetCallback("OnClick", function()
        viewMode = "complete"
        self:UpdateBountiesContent(contentContainer, viewMode)
    end)
    buttonGroup:AddChild(btnComplete)

    local heading = AceGUI:Create("Heading")
    heading:SetText(viewMode .. " bounties")
    heading:SetFullWidth(true)
    contentContainer:AddChild(heading)

    self:UpdateBountiesContent(contentContainer, viewMode)
end

function UpdateBountiesContent(contentContainer, mode)
    contentContainer:ReleaseChildren()
    local db = GetDB()

    if mode == "all" then
        -- List all available bounties.
        for _, bounty in ipairs(HardcoreChallengeTracker_Data.bounties) do
            local label = AceGUI:Create("Label")
            label:SetFullWidth(true)
            local description = bounty.description or "No description available"
            label:SetText(string.format("|cff%s%s|r - Points: %d\n%s",
                _G.UI.SharedConstants.BOUNTY_COLOR, bounty.name, bounty.points or 0, description))
            contentContainer:AddChild(label)
        end
    elseif mode == "complete" then
        -- Completed mode: add dropdown to select a character.
        local characters = db.characters or {}
        local currentCharKey = _G.Utils.GameUtils:GetCharacterKey()
        local selectedChar = "all" -- default: show all

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

        function UpdateCompletedBounties()
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
                    _G.UI.SharedConstants.COMPLETED_COLOR, entry.category, entry.achievement, entry.points, entry.date))
                bountyContainer:AddChild(label)
            end
        end

        UpdateCompletedBounties()
    end
end