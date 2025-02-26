-- Core.lua
local addonName = "HCT"
local HCT_Env = _G.HCT_Env
local HCT = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0",
    "AceSerializer-3.0", "AceComm-3.0")
local HCT_LDB = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
    type = "data source",
    text = addonName,
    icon = "Interface\\Icons\\spell_holy_painsupression",
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(addonName)
        tooltip:AddLine("Left-click to toggle the main UI")
        tooltip:AddLine("Right-click to toggle the main UI")
    end,
    OnClick = function(_, button)
        if button == "LeftButton" then
            _G.UI.UIMain:ToggleMainGUI()
        elseif button == "RightButton" then
            _G.UI.UIMain:ToggleMainGUI()
        end
    end,
})
--local icon = LibStub("LibDBIcon-1.0")
HCT_Env.InitializeAddon(HCT);
HCT.teamChatLog = HCT.teamChatLog or {}
HCT.addonPrefix = addonName
local defaults = _G.DefaultData.defaults
local options = _G.DefaultData:GetOptions(HCT)

-- OnInitialize is an Ace3 internal hook that fires after your addon’s saved variables are loaded but before the player actually enters the world.
-- Addons load each time you enter the game world (after selecting a character) and also whenever you perform a “reload” (e.g., via /reload).
-- Beware there be dragons here! This is the first time your addon is loaded, so you should be careful about what you do here.
-- WOW classic functions like UnitIsGhost will not return the correct value in this function.
function HCT:OnInitialize()
    local playerFaction = UnitFactionGroup("player")
    local playerRealm = GetRealmName()

    if playerFaction ~= HardcoreChallengeTracker_Data.faction then
        _G["YourAddon"] = nil
    end

    if playerRealm ~= HardcoreChallengeTracker_Data.realm then
        _G["YourAddon"] = nil
    end
    self.db = LibStub("AceDB-3.0"):New("HardcoreChallengeTrackerDB", defaults, true)
    self.db:RegisterDefaults(defaults)

    if not self.db.profile.teams then self.db.profile.teams = defaults.profile.teams end

    LibStub("AceConfig-3.0"):RegisterOptionsTable("HCTOptions", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HCTOptions", "Hardcore Challenge Tracker")
    local profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("HCTProfiles", profileOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HCTProfiles", "Profiles", "Hardcore Challenge Tracker")

    self:RegisterChatCommand("hct", function(input)
        _G.UI.UIMain:ToggleMainGUI()
    end)
    --icon:Register(addonName, HCT_LDB, self.db.profile.minimap)
    
    _G.Dao.UserDao:InitializeUser(_G.Utils.GameUtils:GetBattleTag())
    self:Print("Hardcore Challenge Tracker loaded. Use /hct to open the UI window or /t to chat with your team."..addonName)
end

function HCT:OnEnable()
    HCT:RegisterEvents()
    HCT:StartMonitors()
    _G.Service.Chat_Service:RegisterChatCommands()
end

function HCT:OnDisable()
    self:UnregisterEvents()
end

function HCT:StartMonitors()
    for _, monitor in pairs(_G.Monitors) do
        if monitor.StartMonitor then
            monitor:StartMonitor()
        end
    end
end

function HCT:RegisterEvents()
    for _, handler in pairs(_G.HCT_Handlers) do
        local eventType = handler:GetEventType()
        local handlerName = handler:GetHandlerName()

        HCT[handlerName] = function(_, ...)
            handler:HandleEvent(HCT, ...)
        end

        if handlerName == "AddonCommHandler" then
            HCT:RegisterComm(HCT.addonPrefix, handlerName)
        elseif eventType ~= HCT.addonPrefix then
            HCT:RegisterEvent(eventType, handlerName)
        end
    end
end

function HCT:UnregisterEvents()
    for _, handler in pairs(_G.HCT_Handlers) do
        local eventType = handler:GetEventType()
        if eventType ~= HCT.addonPrefix then
            HCT:UnregisterEvent(eventType)
        end
    end
end
