-- Core.lua
local addonName = ...
local HCT_Env = _G.HCT_Env
local HCT = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0",
    "AceSerializer-3.0", "AceComm-3.0")
local HCT_Broadcaster = _G.HCT_Broadcaster
HCT_Env.InitializeAddon(HCT);
HCT.teamChatLog = HCT.teamChatLog or {}
HCT.addonPrefix = "HCT2Addon"
local defaults = _G.DefaultData.defaults
local options = _G.DefaultData:GetOptions(HCT)

function HCT:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("HardcoreChallengeTracker2DB", defaults, true)
    self.db:RegisterDefaults(defaults)
    if not self.db.profile.faction then self.db.profile.faction = HardcoreChallengeTracker_Data.faction end
    if not self.db.profile.realm then self.db.profile.realm = HardcoreChallengeTracker_Data.realm end
    if not self.db.profile.teams then self.db.profile.teams = defaults.profile.teams end


    LibStub("AceConfig-3.0"):RegisterOptionsTable("HCTOptions", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HCTOptions", "Hardcore Challenge Tracker 2")
    local profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("HCTProfiles", profileOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HCTProfiles", "Profiles", "Hardcore Challenge Tracker 2")

    self:RegisterChatCommand("hct2", function(input)
        HCT_UIModule:ShowMainGUI()
    end)
    HCT_DataModule:InitializeUserData()
    HCT_DataModule:InitializeCharacterData()
    self:Print("Hardcore Challenge Tracker 2 loaded. Use /hct2 to open the UI window.")
end

function HCT:OnEnable()
    HCT:RegisterEvents()
    HCT_ChatModule:RegisterChatCommands()
    HCT:ScheduleTimer(function()
        HCT_Broadcaster:RequestContestData()
    end, 600)
    -- Schedule bulk event broadcast every 15 minutes.
    self:ScheduleRepeatingTimer(function()
        HCT_Broadcaster:BroadcastBulkEvents()
    end, 900)
    local charKey = UnitName("player") .. ":" .. HCT_DataModule:GetBattleTag()
    HCT_DataModule:CheckAllAchievements(charKey)
end

function HCT:OnDisable()
    self:UnregisterEvents()
    HCT_ChatModule:UnregisterChatCommands()
    self:CancelAllTimers()
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
