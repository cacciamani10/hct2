if not _G.UI then
    _G.UI = {}
end

if not _G.UI.CharactersPage then
    _G.UI.CharactersPage = {}
end

local AceGUI = LibStub("AceGUI-3.0")
local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

function _G.UI.CharactersPage:DrawCharactersPage(container)
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
                -- For each character for this user.
                for _, charKey in ipairs(userData.characterKeys or {}) do
                    local charData = characters[charKey]
                    if charData and (showDead or not charData.isDead) then
                        local details = self:CalculateCharacterDetails(charData)

                        local charGroup = AceGUI:Create("InlineGroup")
                        charGroup:SetLayout("Flow")
                        charGroup:SetFullWidth(true)

                        -- Name (in red if dead, otherwise white)
                        local nameColor = charData.isDead and "ff0000" or _G.UI.SharedConstants.PLAYER_COLOR
                        local nameHeading = AceGUI:Create("Heading")
                        nameHeading:SetFullWidth(true)
                        nameHeading:SetText(string.format("|cff%s%s|r", nameColor, charData.name))
                        charGroup:AddChild(nameHeading)

                        -- Basic info: Level and Class (with class colored)
                        local classColor = _G.UI.SharedConstants.RAID_CLASS_COLORS[charData.class:upper()]
                        local classColorCode = classColor and
                            string.format("|cff%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255) or
                            "|cffffffff"
                        local basicInfo = AceGUI:Create("Label")
                        basicInfo:SetFullWidth(true)
                        basicInfo:SetText(string.format("Level: %d  |  Class: %s%s|r", charData.level, classColorCode,
                            charData.class))
                        charGroup:AddChild(basicInfo)

                        -- Total Points (highlighted)
                        local totalPointsLabel = AceGUI:Create("Label")
                        totalPointsLabel:SetFullWidth(true)
                        totalPointsLabel:SetText(string.format("Total Points: |cff%s%d|r", _G.UI.SharedConstants.ACHIEVEMENT_COLOR,
                            details.totalPoints))
                        charGroup:AddChild(totalPointsLabel)

                        -- Breakdown: Level, Achievement, and Bounty Points
                        local pointsInfo = AceGUI:Create("Label")
                        pointsInfo:SetFullWidth(true)
                        pointsInfo:SetText(string.format(
                            "Level Points: %d  |  Achievement Points: %d  |  Bounty Points: %d",
                            details.levelPoints, details.achievementPoints, details.bountyPoints))
                        charGroup:AddChild(pointsInfo)

                        -- If the character is dead, show lost points.
                        if charData.isDead then
                            local lostLabel = AceGUI:Create("Label")
                            lostLabel:SetFullWidth(true)
                            lostLabel:SetText(string.format("Points lost due to death: |cffff0000%d|r",
                                details.lostPoints))
                            charGroup:AddChild(lostLabel)
                        end

                        contentContainer:AddChild(charGroup)
                    end
                end
            end
        end
    end

    UpdateCharactersContent()
end

local function CalculateCharacterDetails(charData)
    local details = {}
    
    -- Compute raw level points and then actual level points based on death.
    local rawLevelPoints = _G.Utils.GameUtils:GetLevelPoints(charData.level, 0)
    local penaltyFactor = charData.isDead and 0.5 or 1
    details.levelPoints = math.floor(rawLevelPoints * penaltyFactor)
    details.rawLevelPoints = rawLevelPoints

    details.achievementPoints = 0
    details.rawAchievementPoints = 0
    details.bountyPoints = 0
    details.rawBountyPoints = 0

    local db = GetDB()
    for completionID, _ in pairs(db.completionLedger or {}) do
        -- Expected format: "characterName:battleTag:achievementID"
        local cName, battleTag, achievementID = completionID:match("^(.-):(.-):(%d+)$")
        if cName and achievementID and cName == charData.name then
            local achID = tonumber(achievementID)
            for category, achList in pairs(HardcoreChallengeTracker_Data.achievements) do
                for _, achDef in ipairs(achList) do
                    if achDef.uniqueID == achID then
                        if achID >= 800 and achID <= 899 then
                            details.rawBountyPoints = details.rawBountyPoints + (achDef.points or 0)
                            details.bountyPoints = details.bountyPoints + math.floor((achDef.points or 0) * penaltyFactor)
                        elseif achID < 500 then
                            details.rawAchievementPoints = details.rawAchievementPoints + (achDef.points or 0)
                            details.achievementPoints = details.achievementPoints + math.floor((achDef.points or 0) * penaltyFactor)
                        end
                    end
                end
            end
        end
    end

    details.totalPoints = details.levelPoints + details.achievementPoints + details.bountyPoints
    local totalRaw = details.rawLevelPoints + details.rawAchievementPoints + details.rawBountyPoints
    if charData.isDead then
        details.lostPoints = totalRaw - details.totalPoints
    else
        details.lostPoints = 0
    end
    return details
end