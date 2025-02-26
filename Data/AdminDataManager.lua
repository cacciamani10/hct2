-- Chat commands for admin purposes

local function InsertUser(battleTag)
    local db = _G.HCT_Env.GetAddon().db.profile
    db.users[battleTag] = db.users[battleTag] or { characters = { alive = {}, dead = {} } }
end

-- Insert character
-- name = "MilfyMan", 
-- level = 8, 
-- class = "Hunter", 
-- race = "Dwarf", 
-- faction = "Alliance", 
-- realm = "Doomhowl", 
-- deathTimestamp = nil,
local function InsertCharacter(battleTag, name, level, class, race)
    local db = _G.HCT_Env.GetAddon().db.profile
    local uuid = _G.Utils.TimeUtils.CreateTimeBasedUUID()
    local lastUpdated = time()
    if not db.users[battleTag] then
        InsertUser(battleTag)
    end
    db.users[battleTag].characters.alive[name] = db.users[battleTag].characters.alive[name] or {}
    table.insert(db.users[battleTag].characters.alive[name], { uuid = uuid, lastUpdated = lastUpdated })
    db.characters = db.characters or {}
    db.characters[uuid] = {
        name = name,
        level = level,
        class = class,
        race = race,
        faction = HardcoreChallengeTracker_Data.faction,
        realm = HardcoreChallengeTracker_Data.realm,
        deathTimestamp = nil,
        achievements = {}
    }
    local event = {
        type = _G.EventType.CHARACTER,
        subtype = "NEW",
        uuid = uuid,
        lastUpdated = lastUpdated,
        character = db.characters[uuid]
    }
    _G.Service.Event_Service:BroadcastEvent("CHARACTER_UPDATE", event)
end

local function InsertAchievement(battleTag, name, achievementId, timestamp)
    local db = _G.HCT_Env.GetAddon().db.profile
    if not db.users[battleTag] then
        InsertUser(battleTag)
    end
    if not db.users[battleTag].characters.alive[name] then
        return
    end
    local entry = db.users[battleTag].characters.alive[name][1]
    if not entry then
        return
    end
    db.characters[entry.uuid].achievements = db.characters[entry.uuid].achievements or {}
    db.characters[entry.uuid].achievements[achievementId] = { timestamp = timestamp }
    local event = {
        type = _G.EventType.CHARACTER,
        subtype = "ACHIEVEMENT",
        uuid = entry.uuid,
        lastUpdated = timestamp,
        character = db.characters[entry.uuid]
    }
    _G.Service.Event_Service:BroadcastEvent("CHARACTER_UPDATE", event)
end

local function InsertDeath(battleTag, name, timestamp)
    local db = _G.HCT_Env.GetAddon().db.profile
    if not db.users[battleTag] then
        InsertUser(battleTag)
    end
    local entry = db.users[battleTag].characters.alive[name] and db.users[battleTag].characters.alive[name][1]
    if not entry then
        return
    end
    db.users[battleTag].characters.dead[name] = db.users[battleTag].characters.dead[name] or {}
    db.characters[entry.uuid].deathTimestamp = timestamp
    table.insert(db.users[battleTag].characters.dead[name], { uuid = entry.uuid, lastUpdated = timestamp })
    local event = {
        type = _G.EventType.CHARACTER,
        subtype = "DEATH",
        uuid = entry.uuid,
        lastUpdated = timestamp,
        character = db.characters[entry.uuid]
    }
    _G.Service.Event_Service:BroadcastEvent("CHARACTER_UPDATE", event)
end

-- Achievement should be marked as null. Info will still be present but a flag will be set to ignore it.
local function DeleteAchievement(battleTag, name, achievementId)
    local db = _G.HCT_Env.GetAddon().db.profile
    if not db.users[battleTag] then
        return
    end
    if not db.users[battleTag].characters.alive[name] then
        return
    end
    local entry = db.users[battleTag].characters.alive[name][1]
    if not entry then
        return
    end
    db.characters[entry.uuid].achievements = db.characters[entry.uuid].achievements or {}
    db.characters[entry.uuid].achievements[achievementId]["ignore"] = true
end

local function DeleteCharacter(battleTag, name)
    local db = _G.HCT_Env.GetAddon().db.profile
    if not db.users[battleTag] then
        return
    end
    if not db.users[battleTag].characters.alive[name] or not db.users[battleTag].characters.dead[name] then
        return
    end
    local alive = db.users[battleTag].characters.alive[name][1]
    local dead = db.users[battleTag].characters.dead[name][1]
    if alive then
        db.characters[alive.uuid]["ignore"] = true
        return
    end
    if dead then
        db.characters[dead.uuid]["ignore"] = true
    end
end