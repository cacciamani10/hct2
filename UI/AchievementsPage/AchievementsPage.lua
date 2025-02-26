if not _G.UI then
    _G.UI = {}
end

if not _G.UI.AchievementsPage then
    _G.UI.AchievementsPage = {}
end

local AceGUI = LibStub("AceGUI-3.0")
local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

local function UpdateAchievementsContent(contentContainer, mode)
    contentContainer:ReleaseChildren()
    local db = GetDB()

    if mode == "all" then
        _G.UI.AllAchievements:DrawAllAchievements(contentContainer)
    elseif mode == "complete" then
        _G.UI.CompletedAchievements:DrawCompletedAchievements(contentContainer)
    end
end

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