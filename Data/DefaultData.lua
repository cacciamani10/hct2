_G.DefaultData = {}

_G.DefaultData.defaults = {
    profile = {
        realm = HardcoreChallengeTracker_Data.realm,
        faction = HardcoreChallengeTracker_Data.faction,
        guildName = HardcoreChallengeTracker_Data.guildName,
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
        users = {},
        characters = {},
        myCompletions = {},
        completionLedger = {},
        tugOfWarEvents = {},
    }
}

function DefaultData:GetOptions(handler)
    return {
        name = "Hardcore Challenge Tracker 2",
        handler = handler,
        type = "group",
        args = {
            displayOptions = {
                type = "group",
                name = "Display",
                args = {
                    showOnScreen = {
                        type = "toggle",
                        name = "Show on Screen",
                        desc = "Toggle on-screen notifications.",
                        get = function(info) return handler.db.profile.showOnScreen end,
                        set = function(info, value) handler.db.profile.showOnScreen = value end,
                    },
                },
            },
        }
    }
end
