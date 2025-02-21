if not _G.UI then
    _G.UI = {}
end

if not _G.UI.TeamInfoPage then
    _G.UI.TeamInfoPage = {}
end

local AceGUI = LibStub("AceGUI-3.0")
local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

function _G.UI.TeamInfoPage:DrawTeamInfo(container)
    container:ReleaseChildren()
    local db = GetDB()
    local team1 = db.teams[1] or {}
    local team2 = db.teams[2] or {}

    local team1Name = team1.name or "Team 1"
    local team2Name = team2.name or "Team 2"

    local team1Color = team1.color or { r = 255, g = 0, b = 0 }
    team1Color = _G.Utils.GameUtils.NormalizeColor(team1Color)
    local team2Color = team2.color or { r = 0, g = 255, b = 0 }
    team2Color = _G.Utils.GameUtils.NormalizeColor(team2Color)
    local team1ColorCode = string.format("|cff%02x%02x%02x", team1Color.r, team1Color.g, team1Color.b)
    local team2ColorCode = string.format("|cff%02x%02x%02x", team2Color.r, team2Color.g, team2Color.b)

    local contestData = _G.SERVICE.Scoring_Service:CalculateContestData() or {}

    local team1Points = contestData["team1"] or 0
    local team2Points = contestData["team2"] or 0

    local t1Label = AceGUI:Create("Label")
    t1Label:SetFullWidth(true)
    t1Label:SetText(string.format("%s%s|r - Team Points: %s%d|r", team1ColorCode, team1Name, team1ColorCode, team1Points))
    container:AddChild(t1Label)

    -- Now include each player's point contribution in the list.
    local t1PlayersFormatted = self:FormatPlayersList(team1.battleTags, contestData)
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

    local t2PlayersFormatted = self:FormatPlayersList(team2.battleTags, contestData)
    local t2PlayersLabel = AceGUI:Create("Label")
    t2PlayersLabel:SetFullWidth(true)
    t2PlayersLabel:SetText("Players:\n" .. t2PlayersFormatted)
    container:AddChild(t2PlayersLabel)
end


function _G.UI.TeamInfoPage:FormatPlayersList(players, contestData)
    if not players or #players == 0 then
        return "None"
    end
    local formatted = ""
    for i, player in ipairs(players) do
        local points = contestData[player] or 0
        formatted = formatted .. "• |cff" .. _G.UI.SharedConstants.PLAYER_COLOR .. player .. "|r " ..
            "(|cff" .. _G.UI.SharedConstants.POINTS_COLOR .. points .. " points|r)" .. "\n"
    end
    return formatted
end