local AceSerializer = LibStub("AceSerializer-3.0")

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

_G.Service = _G.Service or {}
_G.Service.Sync_Service = _G.Service.Sync_Service or {}

-- I know this is gross, but chatgpt wrote this in 2 seconds
function _G.Service.Sync_Service:ProcessSyncRequest(payload, sender)
    print("Processing Sync_request")
    local HCT = GetHCT()
    local db = GetDB()

    if not payload or not payload.users then return end

    local updatedCharacters = {
        users = {},
        characters = {}
    }

    local requestedCharacters = {
        users = {},
    }

    for battleTag, senderUserData in pairs(payload.users) do
        local localUserData = db.users[battleTag]

        requestedCharacters.users[battleTag] = {
            characters = {
                alive = {},
                dead = {},
            },
        }

        updatedCharacters.users[battleTag] = {
            characters = {
                alive = {},
                dead = {},
            },
        }

        if not localUserData then
            requestedCharacters.users[battleTag] = senderUserData
        else
            for username, charList in pairs(senderUserData.characters.alive or {}) do
                for _, senderCharEntry in ipairs(charList) do
                    local uuid = senderCharEntry.uuid
                    local senderTimestamp = senderCharEntry.lastUpdated
                    local localCharEntry = localUserData.characters.alive[username] and
                    localUserData.characters.alive[username][1]
                    local localTimestamp = db.characters[uuid] and db.characters[uuid].lastUpdated or 0

                    if not localCharEntry or senderTimestamp > localTimestamp then
                        requestedCharacters.users[battleTag].characters.alive[username] = requestedCharacters.users
                        [battleTag].characters.alive[username] or {}
                        table.insert(requestedCharacters.users[battleTag].characters.alive[username], { uuid = uuid })
                    elseif senderTimestamp < localTimestamp then
                        updatedCharacters.characters[uuid] = db.characters[uuid]
                        table.insert(updatedCharacters.users[battleTag].characters.alive[username], { uuid = uuid, lastUpdated = localTimestamp })
                        updatedCharacters.users[battleTag].team = db.users[battleTag].team 
                        updatedCharacters.users[battleTag].timestamp = db.users[battleTag].timestamp 
                    end
                end
            end

            for username, localCharList in pairs(localUserData.characters.alive or {}) do
                for _, localCharEntry in ipairs(localCharList) do
                    local uuid = localCharEntry.uuid
                    local lastUpdated = localCharEntry.lastUpdated

                    -- If sender does not have this character, add it to updatedCharacters
                    local found = false
                    for _, senderCharEntry in ipairs(senderUserData.characters.alive[username] or {}) do
                        if senderCharEntry.uuid == uuid then
                            found = true
                            break
                        end
                    end

                    if not found then
                        updatedCharacters.users[battleTag] = updatedCharacters.users[battleTag] or
                        { characters = { alive = {}, dead = {} } }
                        updatedCharacters.characters[uuid] = db.characters[uuid]
                        updatedCharacters.users[battleTag].characters.alive[username] = updatedCharacters.users
                        [battleTag].characters.alive[username] or {}
                        table.insert(updatedCharacters.users[battleTag].characters.alive[username],
                            { uuid = uuid, lastUpdated = lastUpdated })
                        updatedCharacters.users[battleTag].team = db.users[battleTag].team 
                        updatedCharacters.users[battleTag].timestamp = db.users[battleTag].timestamp 
                    end
                end
            end

            for username, charList in pairs(senderUserData.characters.dead or {}) do
                for _, senderCharEntry in ipairs(charList) do
                    local uuid = senderCharEntry.uuid
                    local senderTimestamp = senderCharEntry.lastUpdated
                    local localCharEntry = localUserData.characters.dead[username] and
                    localUserData.characters.dead[username][1]
                    local localTimestamp = db.characters[uuid] and db.characters[uuid].lastUpdated or 0

                    if not localCharEntry or senderTimestamp > localTimestamp then
                        requestedCharacters.users[battleTag].characters.dead[username] = requestedCharacters.users
                        [battleTag].characters.dead[username] or {}
                        table.insert(requestedCharacters.users[battleTag].characters.dead[username], { uuid = uuid })
                    elseif senderTimestamp < localTimestamp then
                        updatedCharacters.characters[uuid] = db.characters[uuid]
                        table.insert(updatedCharacters.users[battleTag].characters.dead[username], { uuid = uuid, lastUpdated = localTimestamp })
                        updatedCharacters.users[battleTag].team = db.users[battleTag].team 
                        updatedCharacters.users[battleTag].timestamp = db.users[battleTag].timestamp 
                    end
                end
            end

            for username, localCharList in pairs(localUserData.characters.dead or {}) do
                for _, localCharEntry in ipairs(localCharList) do
                    local uuid = localCharEntry.uuid
                    local lastUpdated = localCharEntry.lastUpdated

                    local found = false
                    for _, senderCharEntry in ipairs(senderUserData.characters.dead[username] or {}) do
                        if senderCharEntry.uuid == uuid then
                            found = true
                            break
                        end
                    end

                    if not found then
                        updatedCharacters.characters[uuid] = db.characters[uuid]
                        updatedCharacters.users[battleTag].characters.dead[username] = updatedCharacters.users
                        [battleTag].characters.dead[username] or {}
                        table.insert(updatedCharacters.users[battleTag].characters.dead[username],
                            { uuid = uuid, lastUpdated = lastUpdated })
                        updatedCharacters.users[battleTag].team = db.users[battleTag].team 
                        updatedCharacters.users[battleTag].timestamp = db.users[battleTag].timestamp 
                    end
                end
            end
        end
    end

    local message = {
        updatedCharacters = updatedCharacters,
        requestedCharacters = requestedCharacters
    }

    _G.Service.Event_Service:WhisperEvent("SYNC_UPDATE", AceSerializer:Serialize("SYNC_UPDATE", message), sender)
    print("Processed Sync_request and sending sync udpate")
end

function _G.Service.Sync_Service:ProcessSyncUpdate(payload, sender)
    print("Processing Sync_update")
    local HCT = GetHCT()
    local db = GetDB()

    local updatedCharacters = {
        users = {},
        characters = {}
    }

    if payload.requestedCharacters and payload.requestedCharacters.users then
        for battleTag, _ in pairs(payload.requestedCharacters.users) do
            if db.users[battleTag] then
                -- Ensure user entry exists in updatedCharacters
                updatedCharacters.users[battleTag] = updatedCharacters.users[battleTag] or
                { characters = { alive = {}, dead = {} } }
                updatedCharacters.users[battleTag].lastUpdated = db.users[battleTag].lastUpdated

                for username, charList in pairs(db.users[battleTag].characters.alive or {}) do
                    updatedCharacters.users[battleTag].characters.alive[username] = updatedCharacters.users[battleTag]
                    .characters.alive[username] or {}

                    for _, charEntry in ipairs(charList) do
                        local uuid = charEntry.uuid
                        local lastUpdated = charEntry.lastUpdated
                        if db.characters[uuid] then
                            updatedCharacters.characters[uuid] = db.characters[uuid]
                            table.insert(updatedCharacters.users[battleTag].characters.alive[username],
                                { uuid = uuid, lastUpdated = lastUpdated })
                            updatedCharacters.users[battleTag].team = db.users[battleTag].team 
                            updatedCharacters.users[battleTag].timestamp = db.users[battleTag].timestamp 
                        end
                    end
                end

                for username, charList in pairs(db.users[battleTag].characters.dead or {}) do
                    updatedCharacters.users[battleTag].characters.dead[username] = updatedCharacters.users[battleTag]
                    .characters.dead[username] or {}

                    for _, charEntry in ipairs(charList) do
                        local uuid = charEntry.uuid
                        local lastUpdated = charEntry.lastUpdated
                        if db.characters[uuid] then
                            updatedCharacters.characters[uuid] = db.characters[uuid]
                            table.insert(updatedCharacters.users[battleTag].characters.dead[username],
                                { uuid = uuid, lastUpdated = lastUpdated })
                                updatedCharacters.users[battleTag].team = db.users[battleTag].team 
                                updatedCharacters.users[battleTag].timestamp = db.users[battleTag].timestamp 
                        end
                    end
                end
            end
        end
    end
    self:UpdateLocalData(payload)
    print("Procesed Sync_update")
    if next(updatedCharacters.characters) or next(updatedCharacters.users) then
        local message = {
            updatedCharacters = updatedCharacters
        }
        print("sending Sync_final")
        _G.Service.Event_Service:WhisperEvent("SYNC_UPDATE", AceSerializer:Serialize("SYNC_FINAL", message), sender)
    end
end

function _G.Service.Sync_Service:ProcessSyncFinal(payload, sender)
    print("processing Sync_final")
    self:UpdateLocalData(payload)
    print("processed Sync_final")
end

function _G.Service.Sync_Service:UpdateLocalData(payload)
    local db = GetDB()

    if not payload then return end
    -- TODO insert while looping through characters. correlate with existing alive characters 
    -- (if someone deleted their saved variables...)
    if payload.updatedCharacters and payload.updatedCharacters.characters then
        for uuid, characterData in pairs(payload.updatedCharacters.characters) do
            db.characters[uuid] = characterData
        end
    end

    if payload.updatedCharacters and payload.updatedCharacters.users then
        for battleTag, userData in pairs(payload.updatedCharacters.users) do
            for username, charList in pairs(userData.characters.alive or {}) do
                db.users[battleTag] = {
                    characters = {
                        alive = {},
                        dead = {},
                    },
                }
                if not db.users[battleTag].team then
                    db.users[battleTag].team = userData.team
                end
                if not db.users[battleTag].timestamp then
                    db.users[battleTag].timestamp = userData.timestamp
                end
                    
                db.users[battleTag].characters.alive[username] = db.users[battleTag].characters.alive[username] or {}
                for _, charEntry in ipairs(charList) do
                    local uuid = charEntry.uuid
                    local lastUpdated = charEntry.lastUpdated
                    local found = false
                    if db.users[battleTag].characters.alive[username] then
                        for _, existingEntry in ipairs(db.users[battleTag].characters.alive[username]) do
                            if existingEntry.uuid == uuid then
                                existingEntry.lastUpdated = charEntry.lastUpdated
                                found = true
                                break
                            end
                        end
                    end

                    if not found then
                        db.users[battleTag].characters.alive[username] = db.users[battleTag].characters.alive[username] or {}
                        table.insert(db.users[battleTag].characters.alive[username],
                            { uuid = uuid, lastUpdated = lastUpdated })
                    end
                end
            end

            for username, charList in pairs(userData.characters.dead or {}) do
                db.users[battleTag].characters.dead[username] = db.users[battleTag].characters.dead[username] or {}
                for _, charEntry in ipairs(charList) do
                    local uuid = charEntry.uuid
                    local lastUpdated = charEntry.lastUpdated
                    local found = false
                    if db.users[battleTag].characters.dead[username] then
                        for _, existingEntry in ipairs(db.users[battleTag].characters.dead[username]) do
                            if existingEntry.uuid == uuid then
                                existingEntry.lastUpdated = charEntry.lastUpdated
                                found = true
                                break
                            end
                        end
                    end

                    if not found then
                        db.users[battleTag].characters.dead[username] = db.users[battleTag].characters.dead[username] or {}
                        table.insert(db.users[battleTag].characters.dead[username],
                            { uuid = uuid, lastUpdated = lastUpdated })
                    end
                end
            end
        end
    end
end
