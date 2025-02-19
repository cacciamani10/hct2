local AceSerializer = LibStub("AceSerializer-3.0")
local AddonCommProcessor = {}
local HCT_Broadcaster = _G.HCT_Broadcaster
local function GetHCT()
    return _G.HCT_Env.GetAddon()
end
local function GetDB()
    return _G.HCT_Env.GetAddon().db.profile
end

function AddonCommProcessor:ProcessEvent(ev)
    local HCT = GetHCT()

    if not HCT then
        return
    end
    local db = GetDB()
    if ev.type == "DEATH" then
        _G.DAO.CharacterDao:UpdateCharacter(ev.uuid, ev.character, ev.timestamp)
        HCT:Print("|cffff0000" .. ev.character.username .. " has died at level " .. ev.character.level .. "|r")
    elseif ev.type == "CHARACTER" then
        _G.DAO.CharacterDao:UpdateCharacter(ev.uuid, ev.character, ev.timestamp)
    -- elseif ev.type == "SPECIAL_KILL" then
    --     local mobName = ev.name or "Unknown Mob"
    --     local classification = ev.classification or "unknown classification"
    --     local characterName = ev.characterName or "Unknown Player"
    --     HCT:Print(characterName .. " killed a " .. classification .. ": " .. mobName)
    elseif ev.type == "PLAYER_LOGOUT" then
        local characterName = ev.characterName or "Unknown Player"
        HCT:Print(characterName .. " logged out")
    elseif ev.type == "GUILD_JOIN_REQUEST" then
        local requester = ev.requester or "Unknown Player"
        HCT:Print(requester .. " requested to join the guild")
        HCT_GuildManager:HandleGuildInviteRequest(ev.type, requester)
    else
        HCT:Print("Process Event: Unknown event type: " .. tostring(ev.type))
    end
end

-- I know this is gross, but chatgpt wrote this in 2 seconds
function AddonCommProcessor:ProcessSyncRequest(payload, sender)
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
                    local localCharEntry = localUserData.characters.alive[username] and localUserData.characters.alive[username][1]
                    local localTimestamp = db.characters[uuid] and db.characters[uuid].lastUpdated or 0

                    if not localCharEntry or senderTimestamp > localTimestamp then
                        requestedCharacters.users[battleTag].characters.alive[username] = requestedCharacters.users[battleTag].characters.alive[username] or {}
                        table.insert(requestedCharacters.users[battleTag].characters.alive[username], { uuid = uuid })
                    elseif senderTimestamp < localTimestamp then
                        updatedCharacters.characters[uuid] = db.characters[uuid]
                        updatedCharacters.users[battleTag] = updatedCharacters.users[battleTag] or localUserData
                    end
                end
            end

            for username, localCharList in pairs(localUserData.characters.alive or {}) do
                for _, localCharEntry in ipairs(localCharList) do
                    local uuid = localCharEntry.uuid
            
                    -- If sender does not have this character, add it to updatedCharacters
                    local found = false
                    for _, senderCharEntry in ipairs(senderUserData.characters.alive[username] or {}) do
                        if senderCharEntry.uuid == uuid then
                            found = true
                            break
                        end
                    end
            
                    if not found then
                        updatedCharacters.users[battleTag] = updatedCharacters.users[battleTag] or { characters = { alive = {}, dead = {} } }
                        updatedCharacters.characters[uuid] = db.characters[uuid]
                        updatedCharacters.users[battleTag].characters.alive[username] = updatedCharacters.users[battleTag].characters.alive[username] or {}
                        table.insert(updatedCharacters.users[battleTag].characters.alive[username], { uuid = uuid })
                    end
                end
            end

            for username, charList in pairs(senderUserData.characters.dead or {}) do
                for _, senderCharEntry in ipairs(charList) do
                    local uuid = senderCharEntry.uuid
                    local senderTimestamp = senderCharEntry.lastUpdated
                    local localCharEntry = localUserData.characters.dead[username] and localUserData.characters.dead[username][1]
                    local localTimestamp = db.characters[uuid] and db.characters[uuid].lastUpdated or 0

                    if not localCharEntry or senderTimestamp > localTimestamp then
                        requestedCharacters.users[battleTag].characters.dead[username] = requestedCharacters.users[battleTag].characters.dead[username] or {}
                        table.insert(requestedCharacters.users[battleTag].characters.dead[username], { uuid = uuid })
                    elseif senderTimestamp < localTimestamp then
                        updatedCharacters.characters[uuid] = db.characters[uuid]
                        updatedCharacters.users[battleTag] = updatedCharacters.users[battleTag] or localUserData
                    end
                end
            end

            for username, localCharList in pairs(localUserData.characters.dead or {}) do
                for _, localCharEntry in ipairs(localCharList) do
                    local uuid = localCharEntry.uuid
            
                    local found = false
                    for _, senderCharEntry in ipairs(senderUserData.characters.dead[username] or {}) do
                        if senderCharEntry.uuid == uuid then
                            found = true
                            break
                        end
                    end
            
                    if not found then
                        updatedCharacters.characters[uuid] = db.characters[uuid]
                        updatedCharacters.users[battleTag].characters.dead[username] = updatedCharacters.users[battleTag].characters.dead[username] or {}
                        table.insert(updatedCharacters.users[battleTag].characters.dead[username], { uuid = uuid })
                    end
                end
            end
        end
    end

        local responseEvent = {
            payload = {
                updatedCharacters = updatedCharacters,
                requestedCharacters = requestedCharacters
            }
        }
        local serialized = AceSerializer:Serialize("SYNC_UPDATE", responseEvent)
        HCT:SendCommMessage(HCT.addonPrefix, serialized, "WHISPER", sender)
        print("Processed REQUEST_SYNC")
end

function AddonCommProcessor:ProcessSyncUpdate(payload, sender)
    local HCT = GetHCT()
    local db = GetDB()
    
    self:UpdateLocalData(payload)

    -- Prepare updatedCharacters object for FINAL_SYNC (contains requested data from local db)
    local updatedCharacters = {
        users = {},
        characters = {}
    }

    -- Loop through requested users and send all associated character data
    if payload.requestedCharacters and payload.requestedCharacters.users then
        for battleTag, _ in pairs(payload.requestedCharacters.users) do
            if db.users[battleTag] then
                -- Add user data
                updatedCharacters.users[battleTag] = db.users[battleTag]

                -- Send all alive characters for the user
                for username, charList in pairs(db.users[battleTag].characters.alive or {}) do
                    for _, charEntry in ipairs(charList) do
                        local uuid = charEntry.uuid
                        if db.characters[uuid] then
                            updatedCharacters.characters[uuid] = db.characters[uuid]
                        end
                    end
                end

                -- Send all dead characters for the user
                for username, charList in pairs(db.users[battleTag].characters.dead or {}) do
                    for _, charEntry in ipairs(charList) do
                        local uuid = charEntry.uuid
                        if db.characters[uuid] then
                            updatedCharacters.characters[uuid] = db.characters[uuid]
                        end
                    end
                end
            end
        end
    end

    -- Send FINAL_SYNC response back to the sender
    if next(updatedCharacters.characters) or next(updatedCharacters.users) then
        local responseEvent = {
            type = "FINAL_SYNC",
            payload = {
                updatedCharacters = updatedCharacters
            }
        }
        local serialized = AceSerializer:Serialize("FINAL_SYNC", responseEvent)
        HCT:SendCommMessage(HCT.addonPrefix, serialized, "WHISPER", sender)
        print("Processed SYNC_UPDATE and sent FINAL_SYNC to", sender)
    end
end


function AddonCommProcessor:ProcessSyncFinal(payload, sender)
    self:UpdateLocalData(payload)
    print("Processed FINAL_SYNC")
end

function AddonCommProcessor:UpdateLocalData(payload)
    local db = GetDB()
    
    if not payload then return end

    -- Overwrite local data with updatedCharacters
    if payload.updatedCharacters and payload.updatedCharacters.characters then
        for uuid, characterData in pairs(payload.updatedCharacters.characters) do
            db.characters[uuid] = characterData
        end
    end

    if payload.updatedCharacters and payload.updatedCharacters.users then
        for battleTag, userData in pairs(payload.updatedCharacters.users) do
            db.users[battleTag] = userData
        end
    end
end

_G.AddonCommProcessor = AddonCommProcessor
