local realm = "Doomhowl"
local faction = "Alliance"

local achievements = {
    ["Level Checkpoints"] = {
        { name = "Level 10 Reached", description = "Reach level 10 on your character", points = 5 },
        { name = "Level 20 Reached", description = "Reach level 20 on your character", points = 10 },
        { name = "Level 30 Reached", description = "Reach level 30 on your character", points = 15 },
        { name = "Level 40 Reached", description = "Reach level 40 on your character", points = 20 },
        { name = "Level 50 Reached", description = "Reach level 50 on your character", points = 25 },
        { name = "Level 60 Reached", description = "Reach level 60 on your character", points = 30 },
    },
    ["Profession Mastery"] = {
        -- Crafting Professions are 1234 points
        { name = "Apprentice Alchemist",   description = "Reach level 75 Alchemy",        points = 1 },
        { name = "Journeyman Alchemist",   description = "Reach level 150 Alchemy",       points = 2 },
        { name = "Expert Alchemist",       description = "Reach level 225 Alchemy",       points = 3 },
        { name = "Artisan Alchemist",      description = "Reach level 300 Alchemy",       points = 4 },
        { name = "Apprentice Blacksmith",  description = "Reach level 75 Blacksmithing",  points = 1 },
        { name = "Journeyman Blacksmith",  description = "Reach level 150 Blacksmithing", points = 2 },
        { name = "Expert Blacksmith",      description = "Reach level 225 Blacksmithing", points = 3 },
        { name = "Artisan Blacksmith",     description = "Reach level 300 Blacksmithing", points = 4 },
        { name = "Apprentice Enchanting",  description = "Reach level 75 Enchanting",     points = 1 },
        { name = "Journeyman Enchanting",  description = "Reach level 150 Enchanting",    points = 2 },
        { name = "Expert Enchanting",      description = "Reach level 225 Enchanting",    points = 3 },
        { name = "Artisan Enchanting",     description = "Reach level 300 Enchanting",    points = 4 },
        { name = "Apprentice Engineering", description = "Reach level 75 Engineering",    points = 1 },
        { name = "Journeyman Engineering", description = "Reach level 150 Engineering",   points = 2 },
        { name = "Expert Engineering",     description = "Reach level 225 Engineering",   points = 3 },
        { name = "Artisan Engineering",    description = "Reach level 300 Engineering",   points = 4 },
        { name = "Apprentice Tailor",      description = "Reach level 75 Tailor",         points = 1 },
        { name = "Journeyman Tailor",      description = "Reach level 150 Tailor",        points = 2 },
        { name = "Expert Tailor",          description = "Reach level 225 Tailor",        points = 3 },
        { name = "Artisan Tailor",         description = "Reach level 300 Tailor",        points = 4 },
        -- Gathering Professions are 1112 points
        { name = "Apprentice Herbalism",   description = "Reach level 75 Herbalism",      points = 1 },
        { name = "Journeyman Herbalism",   description = "Reach level 150 Herbalism",     points = 1 },
        { name = "Expert Herbalism",       description = "Reach level 225 Herbalism",     points = 1 },
        { name = "Artisan Herbalism",      description = "Reach level 300 Herbalism",     points = 2 },
        { name = "Apprentice Skinning",    description = "Reach level 75 Skinning",       points = 1 },
        { name = "Journeyman Skinning",    description = "Reach level 150 Skinning",      points = 1 },
        { name = "Expert Skinning",        description = "Reach level 225 Skinning",      points = 1 },
        { name = "Artisan Skinning",       description = "Reach level 300 Skinning",      points = 2 },
        { name = "Apprentice Mining",      description = "Reach level 75 Mining",         points = 1 },
        { name = "Journeyman Mining",      description = "Reach level 150 Mining",        points = 1 },
        { name = "Expert Mining",          description = "Reach level 225 Mining",        points = 1 },
        { name = "Artisan Mining",         description = "Reach level 300 Mining",        points = 2 },
        -- Secondary Professions are 1122 points
        { name = "Apprentice Cooking",     description = "Reach level 75 Cooking",        points = 1 },
        { name = "Journeyman Cooking",     description = "Reach level 150 Cooking",       points = 1 },
        { name = "Expert Cooking",         description = "Reach level 225 Cooking",       points = 2 },
        { name = "Artisan Cooking",        description = "Reach level 300 Cooking",       points = 2 },
        { name = "Apprentice First Aid",   description = "Reach level 75 First Aid",      points = 1 },
        { name = "Journeyman First Aid",   description = "Reach level 150 First Aid",     points = 1 },
        { name = "Expert First Aid",       description = "Reach level 225 First Aid",     points = 2 },
        { name = "Artisan First Aid",      description = "Reach level 300 First Aid",     points = 2 },
        { name = "Apprentice Fishing",     description = "Reach level 75 Fishing",        points = 1 },
        { name = "Journeyman Fishing",     description = "Reach level 150 Fishing",       points = 1 },
        { name = "Expert Fishing",         description = "Reach level 225 Fishing",       points = 2 },
        { name = "Artisan Fishing",        description = "Reach level 300 Fishing",       points = 2 },
    },
    ["Dungeon Clears"] = {
        { name = "Ragefire Chasm",               description = "Complete Ragefire Chasm",               points = 1 },
        { name = "Wailing Caverns",              description = "Complete Wailing Caverns",              points = 1 },
        { name = "The Deadmines",                description = "Complete The Deadmines",                points = 1 },
        { name = "Shadowfang Keep",              description = "Complete Shadowfang Keep",              points = 1 },
        { name = "Blackfathom Deeps",            description = "Complete Blackfathom Deeps",            points = 1 },
        { name = "The Stockade",                 description = "Complete The Stockade",                 points = 1 },
        { name = "Gnomeregan",                   description = "Complete Gnomeregan",                   points = 1 },
        { name = "Razorfen Kraul",               description = "Complete Razorfen Kraul",               points = 1 },
        { name = "Scarlet Monestary: Graveyard", description = "Complete Scarlet Monastery: Graveyard", points = 1 },
        { name = "Scarlet Monestary: Library",   description = "Complete Scarlet Monastery: Library",   points = 1 },
        { name = "Scarlet Monestary: Armory",    description = "Complete Scarlet Monastery: Armory",    points = 1 },
        { name = "Scarlet Monestary: Cathedral", description = "Complete Scarlet Monastery: Cathedral", points = 1 },
        { name = "Razorfen Downs",               description = "Complete Razorfen Downs",               points = 1 },
        { name = "Uldaman",                      description = "Complete Uldaman",                      points = 1 },
        { name = "Zul'Farrak",                   description = "Complete Zul'Farrak",                   points = 1 },
        { name = "Maraudon",                     description = "Complete Maraudon",                     points = 1 },
        { name = "Temple of Atal'Hakkar",        description = "Complete Temple of Atal'Hakkar",        points = 1 },
        { name = "Blackrock Depths",             description = "Complete Blackrock Depths",             points = 1 },
        { name = "Lower Blackrock Spire",        description = "Complete Lower Blackrock Spire",        points = 1 },
        { name = "Upper Blackrock Spire",        description = "Complete Upper Blackrock Spire",        points = 1 },
        { name = "Dire Maul: East",              description = "Complete Dire Maul: East",              points = 1 },
        { name = "Dire Maul: West",              description = "Complete Dire Maul: West",              points = 1 },
        { name = "Dire Maul: North",             description = "Complete Dire Maul: North",             points = 1 },
        { name = "Scholomance",                  description = "Complete Scholomance",                  points = 1 },
        { name = "Stratholme",                   description = "Complete Stratholme",                   points = 1 },
    },
}

local feats = {
    { name = "Mak'gora", description = "Win a duel to the death (Opponent Minimum Level 10)", points = 10 },
    { name = "Speedrunner" , description = "Reach level 20 in under 15 hours of playtime", points = 6 },
    { name = "Dangerous Diplomacy", description = "Discover an enemy faction capital", points = 4 },
    -- Add more feats
}

local bounties = {
    { name = "Cloth Collector", description = "Every 100 Cloth", points = 1 },
    { name = "Headhunter", description = "Every 250 enemy killed", points = 1 },
    { name = "Treasure Hunter", description = "Every 5 rare or better items looted", points = 2 },
    { name = "Deungeoneer", description = "Every 3 dungeons cleared", points = 1 },
    -- Add more bounties
}

local tugOfWarEvents = {
    { name = "Gatherers Galore", duration = 5 * 3600 },
    { name = "Beast Master", duration = 3 * 3600 },
    -- Add more events
}

local dungeonBosses = {
    ["Ragefire Chasm"] = "Bazzalan",
    ["Wailing Caverns"] = "Mutanus the Devourer",
    ["The Deadmines"] = "Edwin VanCleef",
    ["Shadowfang Keep"] = "Archmage Arugal",
    ["Blackfathom Deeps"] = "Aku'mai",
    ["The Stockade"] = "Bazil Thredd",
    ["Gnomeregan"] = "Mekgineer Thermaplugg",
    ["Razorfen Kraul"] = "Charlga Razorflank",
    ["Scarlet Monastery: Graveyard"] = "Interrogator Vishas",
    ["Scarlet Monastery: Library"] = "Houndmaster Loksey",
    ["Scarlet Monastery: Armory"] = "Herod",
    ["Scarlet Monastery: Cathedral"] = "High Inquisitor Whitemane",
    ["Razorfen Downs"] = "Amnennar the Coldbringer",
    ["Uldaman"] = "Archaeus",
    ["Zul'Farrak"] = "Chief Ukorz Sandscalp",
    ["Maraudon"] = "Princess Theradras",
    ["Temple of Atal'Hakkar"] = "Shade of Eranikus",
    ["Blackrock Depths"] = "Emperor Dagran Thaurissan",
    ["Lower Blackrock Spire"] = "Overlord Wyrmthalak",
    ["Upper Blackrock Spire"] = "General Drakkisath",
    ["Dire Maul: East"] = "Alzzin the Wildshaper",
    ["Dire Maul: West"] = "Prince Tortheldrin",
    ["Dire Maul: North"] = "King Gordok",
    ["Scholomance"] = "Darkmaster Gandling",
    ["Stratholme"] = "Baron Rivendare",
}

local broadcastChannels = { "GUILD", "PARTY", "RAID", "INSTANCE_CHAT" }

HardcoreChallengeTracker_Data = {
    realm = realm,
    faction = faction,
    achievements = achievements,
    tugOfWarEvents = tugOfWarEvents,
    bounties = bounties,
    feats = feats,
    dungeonBosses = dungeonBosses,
    broadcastChannels = broadcastChannels,
}