local realm = "Doomhowl"
local faction = "Alliance"
local guildName = "WELL MET"
local ACHIEVEMENT_START_ID = 1
local ACHIEVEMENT_END_ID = 499

local FEAT_START_ID = 500
local FEAT_END_ID = 799

local BOUNTY_START_ID = 800
local BOUNTY_END_ID = 899

local achievements = {
    ["Level Checkpoints"] = {
        { uniqueID = 1, name = "Level 10 Reached", description = "Reach level 10 on your character", points = 5 },
        { uniqueID = 2, name = "Level 20 Reached", description = "Reach level 20 on your character", points = 10 },
        { uniqueID = 3, name = "Level 30 Reached", description = "Reach level 30 on your character", points = 15 },
        { uniqueID = 4, name = "Level 40 Reached", description = "Reach level 40 on your character", points = 20 },
        { uniqueID = 5, name = "Level 50 Reached", description = "Reach level 50 on your character", points = 25 },
        { uniqueID = 6, name = "Level 60 Reached", description = "Reach level 60 on your character", points = 30 },
    },
    ["Profession Mastery"] = {
        -- Crafting Professions are 1234 points
        { uniqueID = 7,  name = "Apprentice Alchemist",      description = "Reach level 75 Alchemy",         points = 1 },
        { uniqueID = 8,  name = "Journeyman Alchemist",      description = "Reach level 150 Alchemy",        points = 2 },
        { uniqueID = 9,  name = "Expert Alchemist",          description = "Reach level 225 Alchemy",        points = 3 },
        { uniqueID = 10, name = "Artisan Alchemist",         description = "Reach level 300 Alchemy",        points = 4 },
        { uniqueID = 76, name = "Apprentice Leatherworking", description = "Reach level 75 Leatherworking",  points = 1 },
        { uniqueID = 77, name = "Journeyman Leatherworking", description = "Reach level 150 Leatherworking", points = 2 },
        { uniqueID = 78, name = "Expert Leatherworking",     description = "Reach level 225 Leatherworking", points = 3 },
        { uniqueID = 79, name = "Artisan Leatherworking",    description = "Reach level 300 Leatherworking", points = 4 },
        { uniqueID = 11, name = "Apprentice Blacksmith",     description = "Reach level 75 Blacksmithing",   points = 1 },
        { uniqueID = 12, name = "Journeyman Blacksmith",     description = "Reach level 150 Blacksmithing",  points = 2 },
        { uniqueID = 13, name = "Expert Blacksmith",         description = "Reach level 225 Blacksmithing",  points = 3 },
        { uniqueID = 14, name = "Artisan Blacksmith",        description = "Reach level 300 Blacksmithing",  points = 4 },
        { uniqueID = 15, name = "Apprentice Enchanting",     description = "Reach level 75 Enchanting",      points = 1 },
        { uniqueID = 16, name = "Journeyman Enchanting",     description = "Reach level 150 Enchanting",     points = 2 },
        { uniqueID = 17, name = "Expert Enchanting",         description = "Reach level 225 Enchanting",     points = 3 },
        { uniqueID = 18, name = "Artisan Enchanting",        description = "Reach level 300 Enchanting",     points = 4 },
        { uniqueID = 19, name = "Apprentice Engineering",    description = "Reach level 75 Engineering",     points = 1 },
        { uniqueID = 20, name = "Journeyman Engineering",    description = "Reach level 150 Engineering",    points = 2 },
        { uniqueID = 21, name = "Expert Engineering",        description = "Reach level 225 Engineering",    points = 3 },
        { uniqueID = 22, name = "Artisan Engineering",       description = "Reach level 300 Engineering",    points = 4 },
        { uniqueID = 23, name = "Apprentice Tailor",         description = "Reach level 75 Tailor",          points = 1 },
        { uniqueID = 24, name = "Journeyman Tailor",         description = "Reach level 150 Tailor",         points = 2 },
        { uniqueID = 25, name = "Expert Tailor",             description = "Reach level 225 Tailor",         points = 3 },
        { uniqueID = 26, name = "Artisan Tailor",            description = "Reach level 300 Tailor",         points = 4 },
        { uniqueID = 27, name = "Apprentice Herbalism",      description = "Reach level 75 Herbalism",       points = 1 },
        { uniqueID = 28, name = "Journeyman Herbalism",      description = "Reach level 150 Herbalism",      points = 1 },
        { uniqueID = 29, name = "Expert Herbalism",          description = "Reach level 225 Herbalism",      points = 1 },
        { uniqueID = 30, name = "Artisan Herbalism",         description = "Reach level 300 Herbalism",      points = 2 },
        { uniqueID = 31, name = "Apprentice Skinning",       description = "Reach level 75 Skinning",        points = 1 },
        { uniqueID = 32, name = "Journeyman Skinning",       description = "Reach level 150 Skinning",       points = 1 },
        { uniqueID = 33, name = "Expert Skinning",           description = "Reach level 225 Skinning",       points = 1 },
        { uniqueID = 34, name = "Artisan Skinning",          description = "Reach level 300 Skinning",       points = 2 },
        { uniqueID = 35, name = "Apprentice Mining",         description = "Reach level 75 Mining",          points = 1 },
        { uniqueID = 36, name = "Journeyman Mining",         description = "Reach level 150 Mining",         points = 1 },
        { uniqueID = 37, name = "Expert Mining",             description = "Reach level 225 Mining",         points = 1 },
        { uniqueID = 38, name = "Artisan Mining",            description = "Reach level 300 Mining",         points = 2 },
        { uniqueID = 39, name = "Apprentice Cooking",        description = "Reach level 75 Cooking",         points = 1 },
        { uniqueID = 40, name = "Journeyman Cooking",        description = "Reach level 150 Cooking",        points = 1 },
        { uniqueID = 41, name = "Expert Cooking",            description = "Reach level 225 Cooking",        points = 2 },
        { uniqueID = 42, name = "Artisan Cooking",           description = "Reach level 300 Cooking",        points = 2 },
        { uniqueID = 43, name = "Apprentice First Aid",      description = "Reach level 75 First Aid",       points = 1 },
        { uniqueID = 44, name = "Journeyman First Aid",      description = "Reach level 150 First Aid",      points = 1 },
        { uniqueID = 45, name = "Expert First Aid",          description = "Reach level 225 First Aid",      points = 2 },
        { uniqueID = 46, name = "Artisan First Aid",         description = "Reach level 300 First Aid",      points = 2 },
        { uniqueID = 47, name = "Apprentice Fishing",        description = "Reach level 75 Fishing",         points = 1 },
        { uniqueID = 48, name = "Journeyman Fishing",        description = "Reach level 150 Fishing",        points = 1 },
        { uniqueID = 49, name = "Expert Fishing",            description = "Reach level 225 Fishing",        points = 2 },
        { uniqueID = 50, name = "Artisan Fishing",           description = "Reach level 300 Fishing",        points = 2 },
    },
    ["Dungeon Clears"] = {
        { uniqueID = 51, name = "Ragefire Chasm",               description = "Complete Ragefire Chasm",               points = 1 },
        { uniqueID = 52, name = "Wailing Caverns",              description = "Complete Wailing Caverns",              points = 1 },
        { uniqueID = 53, name = "The Deadmines",                description = "Complete The Deadmines",                points = 1 },
        { uniqueID = 54, name = "Shadowfang Keep",              description = "Complete Shadowfang Keep",              points = 1 },
        { uniqueID = 55, name = "Blackfathom Deeps",            description = "Complete Blackfathom Deeps",            points = 1 },
        { uniqueID = 56, name = "The Stockade",                 description = "Complete The Stockade",                 points = 1 },
        { uniqueID = 57, name = "Gnomeregan",                   description = "Complete Gnomeregan",                   points = 1 },
        { uniqueID = 58, name = "Razorfen Kraul",               description = "Complete Razorfen Kraul",               points = 1 },
        { uniqueID = 59, name = "Scarlet Monestary: Graveyard", description = "Complete Scarlet Monastery: Graveyard", points = 1 },
        { uniqueID = 60, name = "Scarlet Monestary: Library",   description = "Complete Scarlet Monastery: Library",   points = 1 },
        { uniqueID = 61, name = "Scarlet Monestary: Armory",    description = "Complete Scarlet Monastery: Armory",    points = 1 },
        { uniqueID = 62, name = "Scarlet Monestary: Cathedral", description = "Complete Scarlet Monastery: Cathedral", points = 1 },
        { uniqueID = 63, name = "Razorfen Downs",               description = "Complete Razorfen Downs",               points = 1 },
        { uniqueID = 64, name = "Uldaman",                      description = "Complete Uldaman",                      points = 1 },
        { uniqueID = 65, name = "Zul'Farrak",                   description = "Complete Zul'Farrak",                   points = 1 },
        { uniqueID = 66, name = "Maraudon",                     description = "Complete Maraudon",                     points = 1 },
        { uniqueID = 67, name = "Temple of Atal'Hakkar",        description = "Complete Temple of Atal'Hakkar",        points = 1 },
        { uniqueID = 68, name = "Blackrock Depths",             description = "Complete Blackrock Depths",             points = 1 },
        { uniqueID = 69, name = "Lower Blackrock Spire",        description = "Complete Lower Blackrock Spire",        points = 1 },
        { uniqueID = 70, name = "Upper Blackrock Spire",        description = "Complete Upper Blackrock Spire",        points = 1 },
        { uniqueID = 71, name = "Dire Maul: East",              description = "Complete Dire Maul: East",              points = 1 },
        { uniqueID = 72, name = "Dire Maul: West",              description = "Complete Dire Maul: West",              points = 1 },
        { uniqueID = 73, name = "Dire Maul: North",             description = "Complete Dire Maul: North",             points = 1 },
        { uniqueID = 74, name = "Scholomance",                  description = "Complete Scholomance",                  points = 1 },
        { uniqueID = 75, name = "Stratholme",                   description = "Complete Stratholme",                   points = 1 },
    },
}

local feats = {
    { uniqueID = 500, name = "Ear Collector",         description = "Win a duel to the death (Players minimum level 15)",                                                     points = 10 },
    { uniqueID = 501, name = "Speedrunner",           description = "Reach level 20 in under 15 hours of playtime",                                                           points = 6 },
    { uniqueID = 502, name = "Dangerous Diplomacy",   description = "Discover an enemy faction capital",                                                                      points = 5 },
    { uniqueID = 503, name = "Spin to Win",           description = "Bind the spirits of wind to create a powerful Whirlwind Weapon while Level 32 or below (Warrior Only).", points = 10 },
    { uniqueID = 504, name = "Lone Wolf",             description = "Defeat 10 yellow elite mobs while solo",                                                                 points = 7 },
    { uniqueID = 505, name = "Dungeoneer of Legend",  description = "Clear a dungeon within 5 levels of your character solo",                                                 points = 10 },
    { uniqueID = 506, name = "Champion of the Light", description = "Obtain the warhammer \"Verigan's Fist\" while level 25 or below (Paladin Only).",                        points = 6 },
    { uniqueID = 507, name = "Mr. Worldwide",         description = "Fully map explore 4 different map zones",                                                                points = 5 },
    { uniqueID = 508, name = "Honored Hero",          description = "Reach Honoured reputation with all 4 factions",                                                          points = 12 },
    { uniqueID = 509, name = "Warpten",               description = "Defeat the final boss of a dungeon in 30 minutes or less",                                               points = 5 },
    { uniqueID = 510, name = "Ocean Man",             description = "Gain the ability to shapeshift into Aquatic Form while level 18 or below (Druid Only).",                 points = 5 },
    { uniqueID = 511, name = "Blue Ribbon Artisan",   description = "Craft a Rare (Blue) item through a profession",                                                          points = 3 },
    { uniqueID = 512, name = "Zone Hopper",           description = "Complete a quest in 6 different zones before reaching level 20.",                                        points = 4 },
    { uniqueID = 513, name = "Acrophilia",            description = "Die by falling (Minimum Level 10)",                                                                      points = 2 },
    { uniqueID = 514, name = "Clerical Work",         description = "Gain your unique racial priest ability while level 20 or below. (Priest Only).",                         points = 1 },
    { uniqueID = 515, name = "Beast Artisan",         description = "Learn 3 unique pet abilities before level 20. (Hunter Only).",                                           points = 5 },
    { uniqueID = 516, name = "Robes of the Arcane",   description = "Create the Lesser Spellfire Robes or Manaweave Robe before reaching level 16. (Mage Only)",              points = 4 },
    { uniqueID = 517, name = "Shadow Orb",            description = "Receive the shadow orb while level 38 or below (Warlock Only).",                                         points = 7 },
}

local bounties = {
    { uniqueID = 800, name = "Cloth Collector",                description = "Every 100 Cloth",                                              points = 1 },
    { uniqueID = 801, name = "Headhunter",                     description = "Every 250 enemy killed",                                       points = 1 },
    { uniqueID = 802, name = "Death Defier",                   description = "Escape near death from an enemy 5 times (20% health or less)", points = 1 }, -- Add a check to see if recently in combat they took some big hits or were attacked by several enemies rather than self damage
    { uniqueID = 803, name = "Treasure Hunter",                description = "Every 5 rare or better items looted",                          points = 2 },
    { uniqueID = 804, name = "Deungeoneer",                    description = "Every 3 dungeons cleared",                                     points = 1 },
    { uniqueID = 805, name = "Team-work makes the dream-work", description = "Complete a dungeon with a full team of guild memebers",       points = 1 },
    { uniqueID = 806, name = "GrAy-okay",                      description = "Every 500 grey mobs killed",                                   points = 1 },
    { uniqueID = 807, name = "Dedicated Quester",              description = "Every 25 unique quests completed",                             points = 1 },
    { uniqueID = 808, name = "Exalted Hero",                   description = "Reach Exalted reputation with a faction",                      points = 2 },
    { uniqueID = 809, name = "Treasure Hunter",                description = "Open 5 treasure chests in the world",                          points = 1 },
    -- Add more bounties
}

local tugOfWarEvents = {
    { uniqueID = 1000, name = "Gatherers Galore", duration = 5 * 3600 },
    { uniqueID = 1001, name = "Beast Master",     duration = 3 * 3600 },
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
    guildName = guildName,
    achievements = achievements,
    tugOfWarEvents = tugOfWarEvents,
    bounties = bounties,
    feats = feats,
    dungeonBosses = dungeonBosses,
    broadcastChannels = broadcastChannels,
    ACHIEVEMENT_START_ID = ACHIEVEMENT_START_ID,
    ACHIEVEMENT_END_ID = ACHIEVEMENT_END_ID,
    FEAT_START_ID = FEAT_START_ID,
    FEAT_END_ID = FEAT_END_ID,
    BOUNTY_START_ID = BOUNTY_START_ID,
    BOUNTY_END_ID = BOUNTY_END_ID,
}
