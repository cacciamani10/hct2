MyAddonDB = {
    users = {
        ["Arsine#1917"] = {
            lastUpdated = 394757349,
            team = 1,
            characters = {
                alive = {
                    ["MilfyMan"] = {
                        {
                            uuid = "uuid-1234-5678",
                            lastUpdated = 394757349,
                        }
                    }
                },
                dead = {
                    ["MilfyMan"] = {
                        {
                            uuid = "uuid-1234-5678",
                            lastUpdated = 394757349,
                        },
                        {
                            uuid = "uuid-1234-5678",
                            lastUpdated = 394757349,
                        }
                    }
                }
            }
        }
    },
    characters = {
        ["uuid-1234-5678"] = {
            name = "MilfyMan", 
            level = 8, 
            class = "Hunter", 
            race = "Dwarf", 
            faction = "Alliance", 
            realm = "Doomhowl", 
            deathTimestamp = nil,
            achievements = {
                [1] = { timestamp = 1739131199 }, -- the key is an achievementId. use it to lookup achievement in hardcoded list
            }
        },
        ["uuid-8765-4321"] = {
            name = "MilfyMan", 
            level = 21, 
            class = "Hunter", 
            race = "Dwarf", 
            faction = "Alliance", 
            realm = "Doomhowl", 
            deathTimestamp = nil,
            achievements = {
                [1] = { timestamp = 1739131199 },
                [2] = { timestamp = 1739131210 },
                [5] = { timestamp = 1739131225 }
            }
        },
        ["uuid-uuid-5678-9101"] = {
            name = "MilfyMan", 
            level = 5, 
            class = "Hunter", 
            race = "Dwarf", 
            faction = "Alliance", 
            realm = "Doomhowl", 
            deathTimestamp = nil, 
            achievements = {
                [1] = { timestamp = 1739131199 }
            }
        }
    }
}