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
        local battleTag = ev.battleTag
        local username = ev.username
        _G.DAO.CharacterDao:MarkCharacterAsDead(battleTag, username, ev.timestamp)
        HCT:Print("|cffff0000" .. username .. " has died at level " .. ev.level .. "|r")
    elseif ev.type == "CHARACTER" then
        _G.DAO.CharacterDao:UpdateCharacter(ev.uuid, ev.character)
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

function AddonCommProcessor:ProcessBulkUpdate(payload)
    local HCT = GetHCT()
    local db = GetDB()
    if not HCT then
        print("HCT is not initialized.")
        return
    end

    local myBattleTag = HCT_DataModule:GetBattleTag()

    if not myBattleTag then
        HCT:Print("My Battle Tag missing")
        return
    end

    -- Users
    for battleTag, userData in pairs(payload.users) do
        if battleTag ~= myBattleTag then
            db.users[battleTag] = db.users[battleTag] or {}
            db.users[battleTag].team = userData.team

            db.users[battleTag].characters = db.users[battleTag].characters or { alive = {}, dead = {} }

            for name, uuid in pairs(userData.characters.alive or {}) do
                db.users[battleTag].characters.alive[name] = uuid
            end

            for name, uuidList in pairs(userData.characters.dead or {}) do
                db.users[battleTag].characters.dead[name] = db.users[battleTag].characters.dead[name] or {}
                for _, uuid in ipairs(uuidList) do
                    table.insert(db.users[battleTag].characters.dead[name], uuid)
                end
            end
        end
    end

    -- Characters
    for uuid, charData in pairs(payload.characters) do
        if not db.characters[uuid] then
            db.characters[uuid] = charData
        else
            local existingChar = db.characters[uuid]

            existingChar.level = math.max(existingChar.level, charData.level)

            if charData.deathTimestamp then
                existingChar.deathTimestamp = charData.deathTimestamp
            end

            existingChar.achievements = existingChar.achievements or {}
            for achId, achData in pairs(charData.achievements or {}) do
                if not existingChar.achievements[achId] or achData.timestamp > existingChar.achievements[achId].timestamp then
                    existingChar.achievements[achId] = achData
                end
            end
        end
    end

    HCT:Print("Processed bulk update.")
end

function AddonCommProcessor:RespondToRequest(payload)
    if not GetHCT() then
        return
    end
    HCT_Broadcaster:BroadcastBulkEvents()
end

_G.AddonCommProcessor = AddonCommProcessor
