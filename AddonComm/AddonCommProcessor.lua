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
    local senderBattleTag = sender

    if not payload or not payload.users then return end

    local updatedCharacters = {
        users = {},
        characters = {}
    }

    local requestedCharacters = {
        users = {},
        characters = {}
    }

    for battleTag, senderUserData in pairs(payload.users) do
        local localUserData = db.users[battleTag]

        -- If the user doesn't exist in my DB, request all their data
        if not localUserData then
            requestedCharacters.users[battleTag] = senderUserData
            for username, charList in pairs(senderUserData.characters.alive or {}) do
                for _, charEntry in ipairs(charList) do
                    if payload.characters[charEntry.uuid] then
                        requestedCharacters.characters[charEntry.uuid] = payload.characters[charEntry.uuid]
                    end
                end
            end
            for username, charList in pairs(senderUserData.characters.dead or {}) do
                for _, charEntry in ipairs(charList) do
                    if payload.characters[charEntry.uuid] then
                        requestedCharacters.characters[charEntry.uuid] = payload.characters[charEntry.uuid]
                    end
                end
            end
        else
            -- Compare timestamps for alive characters
            for username, charList in pairs(senderUserData.characters.alive or {}) do
                for _, senderCharEntry in ipairs(charList) do
                    local uuid = senderCharEntry.uuid
                    local senderTimestamp = senderCharEntry.lastUpdated
                    local localCharEntry = localUserData.characters.alive[username] and localUserData.characters.alive[username][1]
                    local localTimestamp = db.characters[uuid] and db.characters[uuid].lastUpdated or 0

                    if not localCharEntry or senderTimestamp > localTimestamp then
                        if payload.characters[uuid] then
                            requestedCharacters.characters[uuid] = payload.characters[uuid]
                        end
                        requestedCharacters.users[battleTag] = requestedCharacters.users[battleTag] or senderUserData
                    elseif senderTimestamp < localTimestamp then
                        updatedCharacters.characters[uuid] = db.characters[uuid]
                        updatedCharacters.users[battleTag] = updatedCharacters.users[battleTag] or localUserData
                    end
                end
            end

            -- Compare timestamps for dead characters
            for username, charList in pairs(senderUserData.characters.dead or {}) do
                for _, senderCharEntry in ipairs(charList) do
                    local uuid = senderCharEntry.uuid
                    local senderTimestamp = senderCharEntry.lastUpdated
                    local localCharEntry = localUserData.characters.dead[username] and localUserData.characters.dead[username][1]
                    local localTimestamp = db.characters[uuid] and db.characters[uuid].lastUpdated or 0

                    if not localCharEntry or senderTimestamp > localTimestamp then
                        if payload.characters[uuid] then
                            requestedCharacters.characters[uuid] = payload.characters[uuid]
                        end
                        requestedCharacters.users[battleTag] = requestedCharacters.users[battleTag] or senderUserData
                    elseif senderTimestamp < localTimestamp then
                        updatedCharacters.characters[uuid] = db.characters[uuid]
                        updatedCharacters.users[battleTag] = updatedCharacters.users[battleTag] or localUserData
                    end
                end
            end
        end
    end

    -- Only send a response if there are updates needed
    if next(updatedCharacters.characters) or next(requestedCharacters.characters) then
        self.printCounts(updatedCharacters, requestedCharacters)
        local responseEvent = {
            payload = {
                updatedCharacters = updatedCharacters,
                requestedCharacters = requestedCharacters
            }
        }
        local serialized = AceSerializer:Serialize("SYNC_UPDATE", responseEvent)
        HCT:SendCommMessage(HCT.addonPrefix, serialized, "WHISPER", sender)
    end
end

function AddonCommProcessor:printCounts(updatedCharacters, requestedCharacters)
    local updatedAccounts = 0
    local updatedCharacterCount = 0
    for battleTag, userData in pairs(updatedCharacters.users) do
        updatedAccounts = updatedAccounts + 1
        local charCount = (userData.characters.alive and #userData.characters.alive or 0) + 
                          (userData.characters.dead and #userData.characters.dead or 0)
        updatedCharacterCount = updatedCharacterCount + charCount
        print("Updated Account:", battleTag, "Characters:", charCount)
    end

    -- Count accounts and characters for requestedCharacters
    local requestedAccounts = 0
    local requestedCharacterCount = 0
    for battleTag, userData in pairs(requestedCharacters.users) do
        requestedAccounts = requestedAccounts + 1
        local charCount = (userData.characters.alive and #userData.characters.alive or 0) + 
                          (userData.characters.dead and #userData.characters.dead or 0)
        requestedCharacterCount = requestedCharacterCount + charCount
        print("Requested Account:", battleTag, "Characters:", charCount)
    end

    -- Print final counts
    print("Total Updated Accounts:", updatedAccounts, "Total Updated Characters:", updatedCharacterCount)
    print("Total Requested Accounts:", requestedAccounts, "Total Requested Characters:", requestedCharacterCount)
end

function AddonCommProcessor:ProcessSyncUpdate(payload, sender)
    local HCT = GetHCT()
    if not HCT then return end

    local db = GetDB()
    local senderBattleTag = sender -- Assuming sender is the battle tag

    if not payload or not payload.users then return end

    local updatePayload = {
        users = {},
        characters = {}
    }
    
    local requestPayload = {
        users = {},
        characters = {}
    }

    -- Merge sender's users and characters into the database
    for battleTag, userData in pairs(payload.users) do
        if not db.users[battleTag] then
            db.users[battleTag] = userData
        else
            db.users[battleTag].team = userData.team

            db.users[battleTag].characters.alive = db.users[battleTag].characters.alive or {}
            db.users[battleTag].characters.dead = db.users[battleTag].characters.dead or {}

            for username, charList in pairs(userData.characters.alive or {}) do
                db.users[battleTag].characters.alive[username] = db.users[battleTag].characters.alive[username] or {}

                for _, charEntry in ipairs(charList) do
                    local uuid = charEntry.uuid
                    if not db.characters[uuid] or charEntry.lastUpdated > (db.characters[uuid].lastUpdated or 0) then
                        db.characters[uuid] = payload.characters[uuid]
                        table.insert(db.users[battleTag].characters.alive[username], charEntry)
                    end
                end
            end

            for username, charList in pairs(userData.characters.dead or {}) do
                db.users[battleTag].characters.dead[username] = db.users[battleTag].characters.dead[username] or {}

                for _, charEntry in ipairs(charList) do
                    local uuid = charEntry.uuid
                    if not db.characters[uuid] or charEntry.lastUpdated > (db.characters[uuid].lastUpdated or 0) then
                        db.characters[uuid] = payload.characters[uuid]
                        table.insert(db.users[battleTag].characters.dead[username], charEntry)
                    end
                end
            end
        end
    end

    -- Prepare updates for the requester
    for battleTag, userData in pairs(db.users) do
        if battleTag ~= senderBattleTag then
            for username, charList in pairs(userData.characters.alive or {}) do
                for _, charEntry in ipairs(charList) do
                    local uuid = charEntry.uuid
                    if not payload.characters[uuid] or (db.characters[uuid].lastUpdated or 0) > (payload.characters[uuid] and payload.characters[uuid].lastUpdated or 0) then
                        updatePayload.characters[uuid] = db.characters[uuid]
                    end
                end
            end

            for username, charList in pairs(userData.characters.dead or {}) do
                for _, charEntry in ipairs(charList) do
                    local uuid = charEntry.uuid
                    if not payload.characters[uuid] or (db.characters[uuid].lastUpdated or 0) > (payload.characters[uuid] and payload.characters[uuid].lastUpdated or 0) then
                        updatePayload.characters[uuid] = db.characters[uuid]
                    end
                end
            end
        end
    end

    -- Check what data the sender is missing
    for uuid, charData in pairs(db.characters) do
        if not payload.characters[uuid] then
            updatePayload.characters[uuid] = charData
        end
    end

    for battleTag, userData in pairs(db.users) do
        if not payload.users[battleTag] then
            updatePayload.users[battleTag] = userData
        end
    end

    -- Prepare request for missing or outdated data from sender
    for uuid, charData in pairs(payload.characters) do
        if not db.characters[uuid] or (charData.lastUpdated or 0) > (db.characters[uuid].lastUpdated or 0) then
            requestPayload.characters[uuid] = charData
        end
    end

    for battleTag, userData in pairs(payload.users) do
        if not db.users[battleTag] then
            requestPayload.users[battleTag] = userData
        end
    end

    -- Send updated data back to the requester
    if next(updatePayload.characters) or next(updatePayload.users) then
        local responseEvent = {
            type = "SYNC_UPDATE",
            payload = updatePayload
        }
        local serialized = AceSerializer:Serialize("SYNC_UPDATE", responseEvent)
        HCT:SendCommMessage(HCT.addonPrefix, serialized, "WHISPER", sender)
    end

    -- Request missing data from the sender
    if next(requestPayload.characters) or next(requestPayload.users) then
        local requestEvent = {
            type = "FINAL_SYNC",
            payload = requestPayload
        }
        local serializedRequest = AceSerializer:Serialize("FINAL_SYNC", requestEvent)
        HCT:SendCommMessage(HCT.addonPrefix, serializedRequest, "WHISPER", sender)
    end
end


function AddonCommProcessor:ProcessSyncFinal(payload, sender)
    local HCT = GetHCT()
    if not HCT then return end

    local db = GetDB()
    local senderBattleTag = sender -- Assuming sender is the battle tag

    if not payload or not payload.users then return end

    -- Merge incoming data into the database
    for battleTag, userData in pairs(payload.users) do
        if not db.users[battleTag] then
            db.users[battleTag] = userData
        else
            db.users[battleTag].team = userData.team
            db.users[battleTag].characters.alive = db.users[battleTag].characters.alive or {}
            db.users[battleTag].characters.dead = db.users[battleTag].characters.dead or {}

            for username, charList in pairs(userData.characters.alive or {}) do
                db.users[battleTag].characters.alive[username] = db.users[battleTag].characters.alive[username] or {}

                for _, charEntry in ipairs(charList) do
                    local uuid = charEntry.uuid
                    if not db.characters[uuid] or charEntry.lastUpdated > (db.characters[uuid].lastUpdated or 0) then
                        db.characters[uuid] = payload.characters[uuid]
                        table.insert(db.users[battleTag].characters.alive[username], charEntry)
                    end
                end
            end

            for username, charList in pairs(userData.characters.dead or {}) do
                db.users[battleTag].characters.dead[username] = db.users[battleTag].characters.dead[username] or {}

                for _, charEntry in ipairs(charList) do
                    local uuid = charEntry.uuid
                    if not db.characters[uuid] or charEntry.lastUpdated > (db.characters[uuid].lastUpdated or 0) then
                        db.characters[uuid] = payload.characters[uuid]
                        table.insert(db.users[battleTag].characters.dead[username], charEntry)
                    end
                end
            end
        end
    end

    -- Send Sync Complete Confirmation
    local confirmationEvent = {
        type = "SYNC_COMPLETE",
        payload = { senderBattleTag = senderBattleTag }
    }
    local serialized = AceSerializer:Serialize("SYNC_COMPLETE", confirmationEvent)
    HCT:SendCommMessage(HCT.addonPrefix, serialized, "WHISPER", sender)
end

_G.AddonCommProcessor = AddonCommProcessor
