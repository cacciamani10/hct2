-- Core.lua
local addonName = ...
local HCT_Env = _G.HCT_Env
local HCT = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0",
    "AceSerializer-3.0", "AceComm-3.0")
local HCT_Broadcaster = _G.HCT_Broadcaster
HCT_Env.InitializeAddon(HCT);
HCT.teamChatLog = HCT.teamChatLog or {}
HCT.addonPrefix = "HCT2Addon"

-- Set the owner reference in EventModule.
local defaults = {
    profile = {
        realm = HardcoreChallengeTracker_Data.realm,
        faction = HardcoreChallengeTracker_Data.faction,
        teams = {
            [1] = {
                name = "Crimson Vanguards",
                color = { r = 255, g = 0, b = 0 },
                battleTags = { "PeterPiper#1450", "Gad#1916", "Laobod#1570", "FunkyMonk#16573", "GíngerSWAG#1228", "TheCatMan#11376", "LeapingLupin#1343", "Arsine#1917" },
                tugWins = {},
                points = 0,
            },
            [2] = {
                name = "Emerald Guardians",
                color = { r = 0, g = 255, b = 0 },
                battleTags = { "DuncanIdaho#11811", "Dimenster#1890", "LinChengSi#1303", "Necro638#1679", "Handhunter13#1683", "ShadowStorm#13165", "Lolispater71#1962", "TruckLover99#1730" },
                tugWins = {},
                points = 0,
            },
        },
        users = {
            -- ["PeterPiper#1450"] = { team = 1, totalDeaths = 0, characterKeys = { "Morloe:PeterPiper#1450" }},
        },
        characters = {
            -- [Morloe:PeterPiper#1450] = { battleTag = "PeterPiper#1450", level = 1, name = "Morloe", class = "Warrior", race = "Human", faction = "Alliance", realm = "Doomhowl" isDead = false },
        },
        myCompletions = { -- Local store: a set of achievements earned by the local character.
            -- (completionID = characterKey:achievementID)
            -- [completionID] = { timestamp = timestamp }
        },      
        completionLedger = { -- Global ledger: a set aggregating achievements from all players.
            -- (completionID = characterKey:achievementID)
            -- [completionID] = { timestamp = timestamp }
        },   
        tugOfWarEvents = {},
    }
}

local options = {
    name = "Hardcore Challenge Tracker 2",
    handler = HCT,
    type = "group",
    args = {
        -- your custom settings go here...
        displayOptions = {
            type = "group",
            name = "Display",
            args = {
                showOnScreen = {
                    type = "toggle",
                    name = "Show on Screen",
                    desc = "Toggle on-screen notifications.",
                    get = function(info) return HCT.db.profile.showOnScreen end,
                    set = function(info, value) HCT.db.profile.showOnScreen = value end,
                },
                -- Additional settings...
            },
        },
    },
}

function HCT:OnInitialize()
    -- Initialize AceDB with your defaults.
    self.db = LibStub("AceDB-3.0"):New("HardcoreChallengeTracker2DB", defaults, true)

    -- Register the main options table and add it as the top-level category.
    LibStub("AceConfig-3.0"):RegisterOptionsTable("HCTOptions", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HCTOptions", "Hardcore Challenge Tracker 2")

    -- Now register the profile options and add them as a subcategory of the already-created top-level category.
    local profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("HCTProfiles", profileOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HCTProfiles", "Profiles", "Hardcore Challenge Tracker 2")

    self:RegisterChatCommand("hct2", function(input)
        HCT_UIModule:ShowMainGUI()
    end)
    self:Print("On intialize player " .. UnitName("player"))
    HCT_DataModule:InitializeUserData()
    HCT_DataModule:InitializeCharacterData()
    self:Print("Hardcore Challenge Tracker 2 loaded. Use /hct2 to open the UI window.")
end

function HCT:OnEnable()
    HCT_EventModule:RegisterEvents()
    HCT_ChatModule:RegisterChatCommands()
    self:ScheduleTimer(function()
        HCT_Broadcaster:RequestContestData()
    end, 600)
    -- Schedule bulk event broadcast every 5 minutes as a backup.
    self:ScheduleRepeatingTimer(function()
        HCT_Broadcaster:BroadcastBulkEvents()
    end, 900)
    local charKey = UnitName("player")
    HCT_DataModule:CheckAllAchievements(charKey)
end

function HCT:OnDisable()
    HCT_EventModule:UnregisterEvents()
    HCT_ChatModule:UnregisterChatCommands()
    self:CancelAllTimers()
end
