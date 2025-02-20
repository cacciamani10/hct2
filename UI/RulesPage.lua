if not _G.UI then
    _G.UI = {}
end

if not _G.UI.RulesPage then
    _G.UI.RulesPage = {}
end

local AceGUI = LibStub("AceGUI-3.0")

function _G.UI.RulesPage:DrawRules(container)
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
Hardcore Challenge Tracker is a World of Warcraft addon designed for a contest on WoW Classic Hardcore.
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