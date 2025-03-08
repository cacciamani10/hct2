_G.Service = _G.Service or {}
_G.Service.Sync_Service = _G.Service.Sync_Service or {}

function _G.Service.Sync_Service:localCharacterMatchesSenderByUUID(senderUserData, status, username, uuid)
    local found = false
    for _, senderCharEntry in ipairs(senderUserData.characters[status][username] or {}) do
        if senderCharEntry.uuid == uuid then
            found = true
            break
        end
    end
    return found
end

function _G.Service.Sync_Service:ProcessSyncRequest(payload, sender)
    print("Processing Sync_request")

    if not payload or not payload.users then
        return
    end

    local updatedCharacters = {
        users = {},
        characters = {}
    }
    local requestedCharacters = {
        users = {}
    }

    for battleTag, senderUserData in pairs(payload.users) do
        local localUserData = _G.Dao.UserDao:GetUser(battleTag)
        requestedCharacters.users[battleTag] = {
            characters = {
                alive = {},
                dead = {}
            }
        }
        updatedCharacters.users[battleTag] = {
            characters = {
                alive = {},
                dead = {}
            }
        }

        if not localUserData then
            requestedCharacters.users[battleTag] = senderUserData
        else
            _G.Dao.UserDao:SyncUsersData(senderUserData, battleTag, requestedCharacters, updatedCharacters, _G.CharacterStatus.ALIVE)
            _G.Dao.UserDao:SyncCharactersSenderIsMissing(senderUserData, localUserData, battleTag, updatedCharacters, _G.CharacterStatus.ALIVE)
            _G.Dao.UserDao:SyncUsersData(senderUserData, battleTag, requestedCharacters, updatedCharacters, _G.CharacterStatus.DEAD)
            _G.Dao.UserDao:SyncCharactersSenderIsMissing(senderUserData, localUserData, battleTag, updatedCharacters, _G.CharacterStatus.DEAD)
        end
    end

    print("Processed Sync_request")

    if next(updatedCharacters.characters) or next(updatedCharacters.users) then
        local message = {
            updatedCharacters = updatedCharacters,
            requestedCharacters = requestedCharacters
        }
        print("sending SYNC_UPDATE")
        _G.Service.Event_Service:WhisperEvent("SYNC_UPDATE", message, sender)
    end    
end

function _G.Service.Sync_Service:ProcessSyncUpdate(payload, sender)
    print("Processing Sync_update")
    if not payload or (not payload.updatedCharacters and not payload.updatedCharacters) then
        return
    end

    local updatedCharacters = {
        users = {},
        characters = {}
    }

    if payload.requestedCharacters and payload.requestedCharacters.users then
        for battleTag, _ in pairs(payload.requestedCharacters.users) do
            if _G.Dao.UserDao.PlayerExists(battleTag) then
                updatedCharacters.users[battleTag] = updatedCharacters.users[battleTag] or {
                    timestamp = _G.Dao.UserDao:GetTimestamp(battleTag),
                    team = _G.Dao.UserDao:GetTeam(battleTag),
                    characters = {
                        alive = {},
                        dead = {}
                    }
                }

                _G.Dao.UserDao:RetrieveUserData(battleTag, updatedCharacters, _G.CharacterStatus.ALIVE)
                _G.Dao.UserDao:RetrieveUserData(battleTag, updatedCharacters, _G.CharacterStatus.DEAD)
            end
        end
    end

    self:UpdateLocalUser(payload)
    print("Procesed Sync_update")
    if next(updatedCharacters.characters) or next(updatedCharacters.users) then
        local message = {
            updatedCharacters = updatedCharacters
        }
        print("sending Sync_final")
        _G.Service.Event_Service:WhisperEvent("SYNC_FINAL", message, sender)
    end
end

function _G.Service.Sync_Service:ProcessSyncFinal(payload)
    print("processing Sync_final")
    self:UpdateLocalUser(payload)
    print("processed Sync_final")
end

function _G.Service.Sync_Service:UpdateLocalUser(payload)
    if not (payload and payload.updatedCharacters and payload.updatedCharacters.users) then
        return
    end

    for battleTag, userData in pairs(payload.updatedCharacters.users) do
        _G.Dao.UserDao:CreateUserWithData(battleTag, userData.team, userData.timestamp)

        self:UpdateLocalCharacter(userData, payload.updatedCharacters.characters, battleTag, _G.CharacterStatus.ALIVE)
        self:UpdateLocalCharacter(userData, payload.updatedCharacters.characters, battleTag, _G.CharacterStatus.DEAD)
    end
end

function _G.Service.Sync_Service:UpdateLocalCharacter(userData, characterData, battleTag, status)
    for username, charList in pairs(userData.characters[status] or {}) do
        for _, charEntry in ipairs(charList) do
            local newUuid = charEntry.uuid
            local uuidFound = false
            local characterExists = _G.Dao.UserDao.CharacterExists(battleTag, status, username)
            if characterExists then
                uuidFound = _G.Dao.UserDao.UpdateCharacter(battleTag, username, newUuid, status, charEntry, characterData)
                if (uuidFound) then
                    _G.Dao.CharacterDao:UpsertCharacter(uuidFound, characterData[uuidFound])
                end
            end

            if not uuidFound then
                if characterExists and status == CharacterStatus.ALIVE then
                    -- savevariables were likely deleted, which assigns a new uuid to existing characte
                    _G.Dao.UserDao.UpdateCorrelatedCharacter(battleTag, username, newUuid, status, charEntry.lastUpdated)
                else
                    _G.Dao.UserDao:AddCharacter(battleTag, username, newUuid, status, charEntry.lastUpdated)
                end
                _G.Dao.CharacterDao:UpsertCharacter(newUuid, characterData[newUuid])
            end
        end
    end
end

return _G.Service.Sync_Service
