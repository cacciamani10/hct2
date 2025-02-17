if not _G.DAO then
    _G.DAO = {}
end

if not _G.DAO.CharacterDao then
    _G.DAO.CharacterDao = {}
end

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

-- this class needs some thought. Its harder to organize things cleanly when updating characters while peer to peer syncing asynchronously
function _G.DAO.CharacterDao:InitializeCharacter()
    local db = GetDB()
    local playerFaction = UnitFactionGroup("player")
    local playerRealm = GetRealmName()
    local username = UnitName("player")
    local battleTag = HCT_DataModule:GetBattleTag()
    if not battleTag then
        GetHCT():Print("No battle tag found.")
        return
    end

    if playerFaction ~= HardcoreChallengeTracker_Data.faction then
        return
    end

    if playerRealm ~= HardcoreChallengeTracker_Data.realm then
        return
    end

    if not db.users[battleTag].characters.alive[username] then
        local level = UnitLevel("player") or 1
        local class = select(2, UnitClass("player")) or "Unknown"
        local race = select(2, UnitRace("player")) or "Unknown"

        local uuid = _G.Utils.TimeUtils.CreateTimeBasedUUID()

        local lastUpdated = time()
        _G.DAO.UserDao:AddCharacterUUID(battleTag, username, uuid, lastUpdated)

        db.characters = db.characters or {}

        local character = {
            name           = username,
            level          = level,
            class          = class,
            race           = race,
            faction        = playerFaction,
            realm          = playerRealm,
            deathTimestamp = nil,
            achievements   = {}
        }

        db.characters[uuid] = character

        local event = {
            type = "CHARACTER",
            uuid = uuid,
            lastUpdated = lastUpdated,
            character = character
        }
        HCT_Broadcaster:BroadcastEvent(event)
    end
end

function _G.DAO.CharacterDao:MarkCharacterAsDead(battleTag, username, timestamp)
    local db = GetDB()

    if not db.users[battleTag].characters.alive[username] then
        return
    end

    db.users[battleTag].characters.dead[username] = db.users[battleTag].characters.dead[username] or {}

    for _, entry in ipairs(db.users[battleTag].characters.alive[username]) do
        db.characters[entry.uuid].deathTimestamp = timestamp
        table.insert(db.users[battleTag].characters.dead[username], { uuid = entry.uuid, lastUpdated = timestamp })
    end

    db.users[battleTag].characters.alive[username] = nil
end

function _G.DAO.CharacterDao:UpdateCharacterLevel(level)
    local username = UnitName("player")
    local battleTag = HCT_DataModule:GetBattleTag()
    local db = GetDB()

    if not db.users[battleTag] or not db.users[battleTag].characters.alive[username] then
        print("Error: No alive character found for", username)
        return
    end

    local characterEntry = db.users[battleTag].characters.alive[username][1]
    if not characterEntry then
        print("Error: No character entry found for", username)
        return
    end

    local uuid = characterEntry.uuid

    db.characters[uuid].level = level
    characterEntry.lastUpdated = time()
end

function _G.DAO.CharacterDao:AddLevelingAchievement(achievementId)
    local username = UnitName("player")
    local battleTag = HCT_DataModule:GetBattleTag()
    local db = GetDB()

    if not db.users[battleTag] or not db.users[battleTag].characters.alive[username] then
        print("Error: No alive character found for", username)
        return
    end

    local characterEntry = db.users[battleTag].characters.alive[username][1]
    if not characterEntry then
        print("Error: No character entry found for", username)
        return
    end

    local uuid = characterEntry.uuid
    local lastUpdated = time()
    db.characters[uuid].achievements = db.characters[uuid].achievements or {}

    if db.characters[uuid].achievements[achievementId] then
        return
    end

    db.characters[uuid].achievements[achievementId] = { timestamp = lastUpdated }

    
    characterEntry.lastUpdated = lastUpdated
    local event = {
        type = "CHARACTER",
        uuid = uuid,
        lastUpdated = lastUpdated,
        character = db.characters[uuid]
    }
    HCT_Broadcaster:BroadcastEvent(event)
end

function _G.DAO.CharacterDao:AddBounty(achievementId)
    local username = UnitName("player")
    local battleTag = HCT_DataModule:GetBattleTag()
    local db = GetDB()

    if not db.users[battleTag] or not db.users[battleTag].characters.alive[username] then
        print("Error: No alive character found for", username)
        return
    end

    local characterEntry = db.users[battleTag].characters.alive[username][1]
    if not characterEntry then
        print("Error: No character entry found for", username)
        return
    end

    local uuid = characterEntry.uuid

    db.characters[uuid].achievements = db.characters[uuid].achievements or {}

    local currentCount = (db.characters[uuid].achievements[achievementId] and db.characters[uuid].achievements[achievementId].count) or
    0

    db.characters[uuid].achievements[achievementId] = { timestamp = time(), count = currentCount + 1 }

    characterEntry.lastUpdated = time()
end

function _G.DAO.CharacterDao:UpdateCharacter(uuid, character, lastUpdated)
    local db = GetDB()

    if not db.users[character.battleTag] then
        _G.DAO.UserDao:InitializeUser(character.battleTag)
    end

    if character.deathTimestamp then
        db.users[character.battleTag].characters.dead[character.username] = db.users[character.battleTag].characters
        .dead[character.username] or {}

        local found = false
        for _, entry in ipairs(db.users[character.battleTag].characters.dead[character.username]) do
            if entry.uuid == uuid then
                found = true
                if lastUpdated > entry.lastUpdated then
                    entry.lastUpdated = lastUpdated
                end
                break
            end
        end

        if not found then
            table.insert(db.users[character.battleTag].characters.dead[character.username],
                { uuid = uuid, lastUpdated = lastUpdated })
        end
    else
        db.users[character.battleTag].characters.alive[character.username] = db.users[character.battleTag].characters
        .alive[character.username] or {}

        local found = false
        for _, entry in ipairs(db.users[character.battleTag].characters.alive[character.username]) do
            if entry.uuid == uuid then
                found = true
                if lastUpdated > entry.lastUpdated then
                    entry.lastUpdated = lastUpdated
                end
                break
            end
        end

        if not found then
            table.insert(db.users[character.battleTag].characters.alive[character.username],
                { uuid = uuid, lastUpdated = lastUpdated })
        end
    end
    db.characters[uuid] = character
end

function _G.DAO.CharacterDao:GetCharacterBy_UUID(uuid)
    return GetDB().characters[uuid]
end

function _G.DAO.CharacterDao:GetCharacterUUID_BattleTag_Username(battleTag, username)
    local db = GetDB()
    local entry = db.users[battleTag] and db.users[battleTag].characters.alive[username] and db.users[battleTag].characters.alive[username][1]
    return entry and entry.uuid or nil
end


function _G.DAO.CharacterDao:GetCharacterBy_BattleTag_Username(battleTag, username)
    local db = GetDB()
    local entry = db.users[battleTag] and db.users[battleTag].characters.alive[username] and
    db.users[battleTag].characters.alive[username][1]
    return entry and db.characters[entry.uuid] or nil
end

function _G.DAO.CharacterDao:GetCharacter()
    local db = GetDB()
    local username = UnitName("player")
    local battleTag = HCT_DataModule:GetBattleTag()
    local entry = db.users[battleTag] and db.users[battleTag].characters.alive[username] and
    db.users[battleTag].characters.alive[username][1]
    return entry and db.characters[entry.uuid]
end
