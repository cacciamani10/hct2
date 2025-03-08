if not _G.Dao then
    _G.Dao = {}
end

if not _G.Dao.UserDao then
    _G.Dao.UserDao = {}
end

local function GetHCT()
    return _G.HCT_Env.GetAddon()
end
local function GetDB()
    return _G.HCT_Env.GetAddon().db.profile
end

function _G.Dao.UserDao:InitializeUser(battleTag)
    if not battleTag then
        GetHCT():Print("InitializeUser failed: No battle tag found.")
        return
    end

    self:CreateUser(battleTag)
end

function _G.Dao.UserDao:CreateUser(battleTag)
    local db = GetDB()
    local team = _G.Utils.GameUtils:GetPlayerTeam(battleTag) or 1

    if not db.users[battleTag] then
        db.users[battleTag] = {
            lastUpdated = time(),
            team = team,
            characters = {
                alive = {},
                dead = {}
            }
        }
    end
end

function _G.Dao.UserDao:CreateUserWithData(battleTag, team, timestamp)
    local db = GetDB()
    if not db.users[battleTag] then
        db.users[battleTag] = {
            lastUpdated = timestamp,
            team = team,
            characters = {
                alive = {},
                dead = {}
            }
        }
    end
end

function _G.Dao.UserDao:AddCharacterUUID(battleTag, username, uuid, lastUpdated)
    local db = GetDB()

    self:CreateUser(battleTag)

    db.users[battleTag].characters.alive[username] = {}
    table.insert(db.users[battleTag].characters.alive[username], {
        uuid = uuid,
        lastUpdated = lastUpdated
    })
end

function _G.Dao.UserDao.CharacterExists(battleTag, status, username)
    local db = GetDB()
    local characters = db.users[battleTag].characters[status] and db.users[battleTag].characters[status][username] or {}
    return characters and (#characters > 0)
end

function _G.Dao.UserDao.PlayerExists(battleTag)
    local db = GetDB()
    local playerExists = true;
    if not db.users[battleTag] then
        playerExists = false
    end
    return playerExists
end

function _G.Dao.UserDao:AddCharacter(battleTag, username, uuid, status, lastUpdated)
    local db = GetDB()

    db.users[battleTag].characters[status][username] = db.users[battleTag].characters[status][username] or {}
    table.insert(db.users[battleTag].characters[status][username], {
        uuid = uuid,
        lastUpdated = lastUpdated
    })
end

function _G.Dao.UserDao.UpdateCharacter(battleTag, username, uuid, status, charEntry, characterData)
    local db = GetDB()
    local uuidFound = false
    for _, localCharacter in ipairs(db.users[battleTag].characters[status][username]) do
        if localCharacter.uuid == uuid then
            uuidFound = true
            localCharacter.lastUpdated = charEntry.lastUpdated
            db.characters[uuid] = characterData[uuid]
            break
        end
    end
    return uuidFound;
end

function _G.Dao.UserDao.UpdateCorrelatedCharacter(battleTag, username, uuid, status, lastUpdated, level)
    local db = GetDB()
    local character = db.users[battleTag].characters[status][username][1];
    if lastUpdated > character.lastUpdated and level >= character.level then
        local oldUuid = db.users[battleTag].characters[status][username][1].uuid
        db.users[battleTag].characters[status][username][1] = {
            uuid = uuid,
            lastUpdated = lastUpdated
        }
        db.characters[oldUuid] = uuid
    end
end

function _G.Dao.UserDao:UpdateTeam(battleTag, team)
    local db = GetDB()
    if not db.users[battleTag].team then
        db.users[battleTag].team = team
    end
end

function _G.Dao.UserDao:GetTeam(battleTag)
    local db = GetDB()
    return db.users[battleTag].team
end

function _G.Dao.UserDao:UpdateTimestamp(battleTag, timestamp)
    local db = GetDB()
    if not db.users[battleTag].timestamp then
        db.users[battleTag].timestamp = timestamp
    end
end

function _G.Dao.UserDao:GetTimestamp(battleTag)
    local db = GetDB()
    return db.users[battleTag].timestamp
end

function _G.Dao.UserDao:RetrieveUserData(battleTag, updatedCharacters, status)
    local db = GetDB()
    for username, charList in pairs(db.users[battleTag].characters[status] or {}) do
        updatedCharacters.users[battleTag].characters[status][username] =
            updatedCharacters.users[battleTag].characters[status][username] or {}

        for _, charEntry in ipairs(charList) do
            local uuid = charEntry.uuid
            local lastUpdated = charEntry.lastUpdated
            if db.characters[uuid] then
                updatedCharacters.characters[uuid] = db.characters[uuid]
                table.insert(updatedCharacters.users[battleTag].characters[status][username], {
                    uuid = uuid,
                    lastUpdated = lastUpdated
                })
                updatedCharacters.users[battleTag].team = db.users[battleTag].team
                updatedCharacters.users[battleTag].timestamp = db.users[battleTag].timestamp
            end
        end
    end
end

function _G.Dao.UserDao:SyncUsersData(senderUserData, battleTag, requestedCharacters, updatedCharacters, status)
    local db = GetDB()
    local localUserData = db.users[battleTag]
    for username, charList in pairs(senderUserData.characters[status] or {}) do
        for _, senderCharEntry in ipairs(charList) do
            local uuid = senderCharEntry.uuid
            local senderTimestamp = senderCharEntry.lastUpdated
            local localCharacterExists = _G.Dao.UserDao.CharacterExists(localUserData, status, username)
            local localTimestamp = db.characters[uuid] and db.characters[uuid].lastUpdated or 0
            if not localCharacterExists or senderTimestamp > localTimestamp then
                requestedCharacters.users[battleTag].characters[status][username] =
                    requestedCharacters.users[battleTag].characters[status][username] or {}
                table.insert(requestedCharacters.users[battleTag].characters[status][username], {
                    uuid = uuid
                })
            elseif senderTimestamp < localTimestamp then
                updatedCharacters.characters[uuid] = db.characters[uuid]
                updatedCharacters.users[battleTag].characters[status][username] =
                    updatedCharacters.users[battleTag].characters[status][username] or {}
                table.insert(updatedCharacters.users[battleTag].characters[status][username], {
                    uuid = uuid,
                    lastUpdated = localTimestamp
                })
                updatedCharacters.users[battleTag].team = db.users[battleTag].team
                updatedCharacters.users[battleTag].timestamp = db.users[battleTag].timestamp
            end
        end
    end
end

function _G.Dao.UserDao:SyncCharactersSenderIsMissing(senderUserData, localUserData, battleTag, updatedCharacters, status)
    local db = GetDB()
    for username, localCharList in pairs(localUserData.characters[status] or {}) do
        for _, localCharEntry in ipairs(localCharList) do
            local uuid = localCharEntry.uuid
            local lastUpdated = localCharEntry.lastUpdated

            if not _G.Service.Sync_Service.localCharacterMatchesSenderByUUID(senderUserData, status, username, uuid) then
                updatedCharacters.users[battleTag] = updatedCharacters.users[battleTag] or {
                    characters = {
                        alive = {},
                        dead = {}
                    }
                }
                updatedCharacters.characters[uuid] = db.characters[uuid]
                updatedCharacters.users[battleTag].characters[status][username] =
                    updatedCharacters.users[battleTag].characters[status][username] or {}
                table.insert(updatedCharacters.users[battleTag].characters[status][username], {
                    uuid = uuid,
                    lastUpdated = lastUpdated
                })
                updatedCharacters.users[battleTag].team = db.users[battleTag].team
                updatedCharacters.users[battleTag].timestamp = db.users[battleTag].timestamp
            end
        end
    end
end

function _G.Dao.UserDao:GetUsers()
    local db = GetDB()
    return db.users
end

function _G.Dao.UserDao:GetUser(battleTag)
    local db = GetDB()
    return db.users[battleTag]
end

return _G.Dao.UserDao
