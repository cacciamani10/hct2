if not _G.UI then
    _G.UI = {}
end

if not _G.UI.TeamChatPage then
    _G.UI.TeamChatPage = {}
end

local AceGUI = LibStub("AceGUI-3.0")
local function GetHCT() return _G.HCT_Env.GetAddon() end

function _G.UI.TeamChatPage:DrawTeamChat(container)
    container:ReleaseChildren()
    GetHCT().teamChatContainer = container

    local logGroup = AceGUI:Create("SimpleGroup")
    logGroup:SetLayout("Flow")
    logGroup:SetFullWidth(true)
    logGroup:SetHeight(300)
    container:AddChild(logGroup)

    local chatLog = GetHCT().teamChatLog or {}
    for _, msg in ipairs(chatLog) do
        local msgLabel = AceGUI:Create("Label")
        msgLabel:SetFullWidth(true)
        msgLabel:SetText(msg)
        logGroup:AddChild(msgLabel)
    end

    local chatBox = AceGUI:Create("EditBox")
    chatBox:SetLabel("Team Chat")
    chatBox:SetFullWidth(true)
    chatBox:SetCallback("OnEnterPressed", function(widget, event, text)
        if text and text ~= "" then
            HCT_ChatModule:SendTeamChatMessage(text)
            widget:SetText("")
        end
    end)
    container:AddChild(chatBox)
end