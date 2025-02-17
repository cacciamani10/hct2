-- Core.lua
local addonName = ...
local HCT_Env = _G.HCT_Env
local HCT = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0",
    "AceSerializer-3.0", "AceComm-3.0")
local HCT_Broadcaster = _G.HCT_Broadcaster
HCT_Env.InitializeAddon(HCT);
HCT.teamChatLog = HCT.teamChatLog or {}
HCT.addonPrefix = "HCTAddon"
local defaults = _G.DefaultData.defaults
local options = _G.DefaultData:GetOptions(HCT)

-- OnInitialize is an Ace3 internal hook that fires after your addon’s saved variables are loaded but before the player actually enters the world.
-- Addons load each time you enter the game world (after selecting a character) and also whenever you perform a “reload” (e.g., via /reload).
-- Beware there be dragons here! This is the first time your addon is loaded, so you should be careful about what you do here.
-- WOW classic functions like UnitIsGhost will not return the correct value in this function.
function HCT:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("HardcoreChallengeTrackerDB", defaults, true)
    self.db:RegisterDefaults(defaults)
    -- if not self.db.profile.faction then self.db.profile.faction = HardcoreChallengeTracker_Data.faction end
    -- if not self.db.profile.realm then self.db.profile.realm = HardcoreChallengeTracker_Data.realm end
    if not self.db.profile.teams then self.db.profile.teams = defaults.profile.teams end


    LibStub("AceConfig-3.0"):RegisterOptionsTable("HCTOptions", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HCTOptions", "Hardcore Challenge Tracker")
    local profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("HCTProfiles", profileOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HCTProfiles", "Profiles", "Hardcore Challenge Tracker")

    self:RegisterChatCommand("hct", function(input)
        HCT_UIModule:ShowMainGUI()
    end)
    
    _G.DAO.UserDao:InitializeUser(HCT_DataModule:GetBattleTag())
    self:Print("Hardcore Challenge Tracker loaded. Use /hct to open the UI window or /t to chat with your team.")
end

function HCT:OnEnable()
    HCT:RegisterEvents()
    HCT_ChatModule:RegisterChatCommands()
    -- TODO check all achievements
end

function HCT:OnDisable()
    self:UnregisterEvents()
    HCT_ChatModule:UnregisterChatCommands()
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

    HCT_Broadcaster:RequestContestData()
    HCT_Broadcaster:BroadcastBulkEvents()
end

function HCT:UnregisterEvents()
    for _, handler in pairs(_G.HCT_Handlers) do
        local eventType = handler:GetEventType()
        if eventType ~= HCT.addonPrefix then
            HCT:UnregisterEvent(eventType)
        end
    end
end
