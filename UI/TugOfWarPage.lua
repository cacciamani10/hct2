if not _G.UI then
    _G.UI = {}
end

if not _G.UI.TugOfWarPage then
    _G.UI.TugOfWarPage = {}
end

local AceGUI = LibStub("AceGUI-3.0")

function _G.UI.TugOfWarPage:DrawTugOfWar(container)
    container:ReleaseChildren()

    local placeholder = AceGUI:Create("Label")
    placeholder:SetFullWidth(true)
    placeholder:SetText("Tug of War content coming soon!")

    container:AddChild(placeholder)
end