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
    if not HCT then return end

    local db = GetDB()
    local senderBattleTag = sender

    if not payload or not payload.users then return end

    for battleTag, userData in pairs(payload.users) do
        if not db.users[battleTag] then
            db.users[battleTag] = userData
        else
            db.users[battleTag].characters.alive = db.users[battleTag].characters.alive or {}
            db.users[battleTag].characters.dead = db.users[battleTag].characters.dead or {}

            for username, characterList in pairs(userData.characters.alive or {}) do
                db.users[battleTag].characters.alive[username] = db.users[battleTag].characters.alive[username] or {}

                for _, characterEntry in ipairs(characterList) do
                    local uuid = characterEntry.uuid
                    if not db.characters[uuid] or characterEntry.lastUpdated > (db.characters[uuid].lastUpdated or 0) then
                        db.characters[uuid] = payload.characters[uuid]
                        table.insert(db.users[battleTag].characters.alive[username], characterEntry)
                    end
                end
            end

            for username, characterList in pairs(userData.characters.dead or {}) do
                db.users[battleTag].characters.dead[username] = db.users[battleTag].characters.dead[username] or {}

                for _, characterEntry in ipairs(characterList) do
                    local uuid = characterEntry.uuid
                    if not db.characters[uuid] or characterEntry.lastUpdated > (db.characters[uuid].lastUpdated or 0) then
                        db.characters[uuid] = payload.characters[uuid]
                        table.insert(db.users[battleTag].characters.dead[username], characterEntry)
                    end
                end
            end
        end
    end

    -- Prepare updated data to send back to the sender
    local updatePayload = {
        users = {},
        characters = {}
    }

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

    -- Send missing users and characters back
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

    if next(updatePayload.characters) or next(updatePayload.users) then
        local responseEvent = {
            type = "SYNC_UPDATE",
            payload = updatePayload
        }
        local serialized = AceSerializer:Serialize("SYNC_UPDATE", responseEvent)
        HCT:SendCommMessage(HCT.addonPrefix, serialized, "WHISPER", sender)
    end
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
