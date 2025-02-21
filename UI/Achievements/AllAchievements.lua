if not _G.UI then
    _G.UI = {}
end

if not _G.UI.AllAchievements then
    _G.UI.AllAchievements = {}
end

local AceGUI = LibStub("AceGUI-3.0")

function _G.UI.AllAchievements:DrawAllAchievements(contentContainer)
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
end




