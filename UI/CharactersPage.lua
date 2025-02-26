if not _G.UI then
    _G.UI = {}
end

if not _G.UI.CharactersPage then
    _G.UI.CharactersPage = {}
end

local AceGUI = LibStub("AceGUI-3.0")
local function GetDB()
    return _G.HCT_Env.GetAddon().db.profile
end

local function CalculateCharacterDetails(character)
    return _G.SERVICE.Scoring_Service:CalculateCharacterPoints(character)
end

function _G.UI.CharactersPage:DrawCharactersPage(container)
    container:ReleaseChildren()

    local db = GetDB()
    local users = db.users or {}
    local characters = db.characters or {}

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
        btnToggleDead:SetText(showDead and "Hide Dead" or "Show Dead")
    end
    UpdateToggleButtonText()
    btnToggleDead:SetCallback("OnClick", function()
        showDead = not showDead
        UpdateToggleButtonText()
        UpdateCharactersContent()
    end)
    filterGroup:AddChild(btnToggleDead)

    -- Create the scroll frame for character listings.
    local contentContainer = AceGUI:Create("ScrollFrame")
    contentContainer:SetLayout("Flow")
    contentContainer:SetFullWidth(true)
    contentContainer:SetFullHeight(true)
    container:AddChild(contentContainer)

    -- Function to update the content based on filters.
    function UpdateCharactersContent()
        contentContainer:ReleaseChildren()

        for battleTag, userData in pairs(users) do
            if userData.team == selectedTeam then
                local userHeader = AceGUI:Create("Heading")
                userHeader:SetFullWidth(true)
                userHeader:SetText(battleTag)
                contentContainer:AddChild(userHeader)

                -- Process alive characters first.
                if userData.characters.alive then
                    for charName, entries in pairs(userData.characters.alive) do
                        for _, entry in ipairs(entries) do
                            local uuid = entry.uuid
                            local charData = characters[uuid]
                            if charData then
                                local points = CalculateCharacterDetails(charData)

                                local charGroup = AceGUI:Create("InlineGroup")
                                charGroup:SetLayout("Flow")
                                charGroup:SetFullWidth(true)

                                local nameColor = _G.UI.SharedConstants.PLAYER_COLOR
                                local nameHeading = AceGUI:Create("Heading")
                                nameHeading:SetFullWidth(true)
                                nameHeading:SetText(string.format("|cff%s%s|r", nameColor, charData.name))
                                charGroup:AddChild(nameHeading)

                                local classColor = _G.UI.SharedConstants.RAID_CLASS_COLORS[charData.class:upper()]
                                local classColorCode = classColor and string.format("|cff%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255) or "|cffffffff"
                                local basicInfo = AceGUI:Create("Label")
                                basicInfo:SetFullWidth(true)
                                basicInfo:SetText(string.format("Level: %d  |  Class: %s%s|r", charData.level, classColorCode, charData.class))
                                charGroup:AddChild(basicInfo)

                                local totalPointsLabel = AceGUI:Create("Label")
                                totalPointsLabel:SetFullWidth(true)
                                totalPointsLabel:SetText(string.format("Total Points: |cff%s%d|r", _G.UI.SharedConstants.ACHIEVEMENT_COLOR, points.leveling + points.professions + points.bounties + points.dungeons))
                                charGroup:AddChild(totalPointsLabel)

                                local pointsInfo = AceGUI:Create("Label")
                                pointsInfo:SetFullWidth(true)
                                pointsInfo:SetText(string.format("Level Points: %d  |  Achievement Points: %d  |  Bounty Points: %d  |  Dungeon Points: %d", points.leveling, points.professions, points.bounties, points.dungeons))
                                charGroup:AddChild(pointsInfo)

                                if charData.deathTimestamp then
                                    local lostLabel = AceGUI:Create("Label")
                                    lostLabel:SetFullWidth(true)
                                    lostLabel:SetText(string.format("Points lost due to death: |cffff0000%d|r", math.floor((points.leveling + points.professions + points.bounties + points.dungeons) / 2)))
                                    charGroup:AddChild(lostLabel)
                                end

                                contentContainer:AddChild(charGroup)
                            end
                        end
                    end
                end

                -- Process dead characters (always displayed below alive ones if toggled on).
                if showDead and userData.characters.dead then
                    for charName, entries in pairs(userData.characters.dead) do
                        for _, entry in ipairs(entries) do
                            local uuid = entry.uuid
                            local charData = characters[uuid]
                            if charData then
                                local details = CalculateCharacterDetails(charData)

                                local charGroup = AceGUI:Create("InlineGroup")
                                charGroup:SetLayout("Flow")
                                charGroup:SetFullWidth(true)

                                -- Dead characters are shown in red.
                                local nameHeading = AceGUI:Create("Heading")
                                nameHeading:SetFullWidth(true)
                                nameHeading:SetText(string.format("|cff%s%s|r", "ff0000", charData.name))
                                charGroup:AddChild(nameHeading)

                                local classColor = _G.UI.SharedConstants.RAID_CLASS_COLORS[charData.class:upper()]
                                local classColorCode = classColor and string.format("|cff%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255) or "|cffffffff"
                                local basicInfo = AceGUI:Create("Label")
                                basicInfo:SetFullWidth(true)
                                basicInfo:SetText(string.format("Level: %d  |  Class: %s%s|r", charData.level, classColorCode, charData.class))
                                charGroup:AddChild(basicInfo)

                                local totalPointsLabel = AceGUI:Create("Label")
                                totalPointsLabel:SetFullWidth(true)
                                totalPointsLabel:SetText(string.format("Total Points: |cff%s%d|r", _G.UI.SharedConstants.ACHIEVEMENT_COLOR, details.totalPoints))
                                charGroup:AddChild(totalPointsLabel)

                                local pointsInfo = AceGUI:Create("Label")
                                pointsInfo:SetFullWidth(true)
                                pointsInfo:SetText(string.format("Level Points: %d  |  Achievement Points: %d  |  Bounty Points: %d", details.levelPoints, details.achievementPoints, details.bountyPoints))
                                charGroup:AddChild(pointsInfo)

                                if charData.deathTimestamp then
                                    local lostLabel = AceGUI:Create("Label")
                                    lostLabel:SetFullWidth(true)
                                    lostLabel:SetText(string.format("Points lost due to death: |cffff0000%d|r", details.lostPoints))
                                    charGroup:AddChild(lostLabel)
                                end

                                contentContainer:AddChild(charGroup)
                            end
                        end
                    end
                end
            end
        end
    end

    UpdateCharactersContent()
end
