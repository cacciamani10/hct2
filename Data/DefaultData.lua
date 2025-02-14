_G.DefaultData = {}

_G.DefaultData.defaults = {
    profile = {
        realm = HardcoreChallengeTracker_Data.realm,
        faction = HardcoreChallengeTracker_Data.faction,
        guildName = HardcoreChallengeTracker_Data.guildName,
        teams = {
            [1] = HardcoreChallengeTracker2_Teams[1],
            [2] = HardcoreChallengeTracker2_Teams[2],
        },
        users = {
            -- ["PeterPiper#1450"] = { team = 1, totalDeaths = 0, characterKeys = { 1: "Morloe:PeterPiper#1450" }},
            ["TheCatMan#11376"] = { team = 1, totalDeaths = 2, characterKeys = { "Cloudycolton:TheCatMan#11376", "Cloudypally:TheCatMan#11376" } },
            ["Dimenster#1890"] = { team = 2, totalDeaths = 6, characterKeys = { "Bigspank:Dimenster#1890", "Bigspankjr:Dimenster#1890", "Burbur:Dimenster#1890", "Anitadeek:Dimenster#1890", "Goliathen:Dimenster#1890", "Starinn:Dimenster#1890", "Storas:Dimenster#1890" } },
        },
        characters = {
            -- [Morloe:PeterPiper#1450] = { battleTag = "PeterPiper#1450", level = 1, name = "Morloe", class = "WARRIOR", race = "Human", faction = "Alliance", realm = "Doomhowl" isDead = false },
            ["Cloudycolton:TheCatMan#11376"] = { battleTag = "TheCatMan#11376", level = 20, name = "Cloudycolton", class = "PRIEST", race = "Human", faction = "Alliance", realm = "Doomhowl", isDead = true },
            ["Cloudypally:TheCatMan#11376"] = { battleTag = "TheCatMan#11376", level = 17, name = "Cloudypally", class = "PALADIN", race = "Human", faction = "Alliance", realm = "Doomhowl", isDead = true },
            ["Bigspank:Dimenster#1890"] = { battleTag = "Dimenster#1890", level = 8, name = "Bigspank", class = "HUNTER", race = "Human", faction = "Alliance", realm = "Doomhowl", isDead = true },
            ["Bigspankjr:Dimenster#1890"] = { battleTag = "Dimenster#1890", level = 11, name = "Bigspankjr", class = "HUNTER", race = "Human", faction = "Alliance", realm = "Doomhowl", isDead = true },
            ["Burbur:Dimenster#1890"] = { battleTag = "Dimenster#1890", level = 8, name = "Burbur", class = "DRUID", race = "Night Elf", faction = "Alliance", realm = "Doomhowl", isDead = true },
            ["Anitadeek:Dimenster#1890"] = { battleTag = "Dimenster#1890", level = 12, name = "Anitadeek", class = "HUNTER", race = "Human", faction = "Alliance", realm = "Doomhowl", isDead = false },
            ["Goliathen:Dimenster#1890"] = { battleTag = "Dimenster#1890", level = 10, name = "Goliathen", class = "DRUID", race = "Human", faction = "Alliance", realm = "Doomhowl", isDead = true },
            ["Starinn:Dimenster#1890"] = { battleTag = "Dimenster#1890", level = 8, name = "Starinn", class = "DRUID", race = "Night Elf", faction = "Alliance", realm = "Doomhowl", isDead = true },
            ["Storas:Dimenster#1890"] = { battleTag = "Dimenster#1890", level = 14, name = "Storas", class = "DRUID", race = "Night Elf", faction = "Alliance", realm = "Doomhowl", isDead = true },
        },
        myCompletions = { -- Local store: a set of achievements earned by the local character.
            -- (completionID = characterKey:achievementID)
            -- [completionID] = { timestamp = timestamp }
        },
        -- Example of a completion ledger entry:
        -- ["Morloe:PeterPiper#1450:1"] = {
        --     ["timestamp"] = 1739458821,
        -- },
        completionLedger = { 
            ["Cloudycolton:TheCatMan#11376:1"] = { timestamp = 1739131199 },
            ["Cloudycolton:TheCatMan#11376:2"] = { timestamp = 1739131199 },
            ["Cloudycolton:TheCatMan#11376:7"] = { timestamp = 1739131199 },
            ["Cloudycolton:TheCatMan#11376:27"] = { timestamp = 1739131199 },
            ["Cloudycolton:TheCatMan#11376:39"] = { timestamp = 1739131199 },
            ["Cloudycolton:TheCatMan#11376:40"] = { timestamp = 1739131199 },
            ["Cloudycolton:TheCatMan#11376:47"] = { timestamp = 1739131199 },
            ["Cloudycolton:TheCatMan#11376:48"] = { timestamp = 1739131199 },
            ["Cloudypally:TheCatMan#11376:1"] = { timestamp = 1739131199 },
            ["Cloudypally:TheCatMan#11376:35"] = { timestamp = 1739131199 },
        },
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
