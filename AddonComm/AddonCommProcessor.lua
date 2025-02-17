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
        local level = ev.level or "Unknown"
        local timestamp = ev.timestamp
        _G.DAO.CharacterDao:MarkCharacterAsDead(battleTag, username, timestamp)
        HCT:Print("|cffff0000" .. name .. " has died at level " .. level .. "|r")
    elseif ev.type == "CHARACTER" then
        local charKey = ev.name .. ":" .. ev.battleTag
        if db.characters[charKey] then
            for k, v in pairs(ev) do
                db.characters[charKey][k] = v
            end
            HCT:Print("Updated info for " .. charKey)
        end
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
    if not HCT then
        print("HCT is not initialized.")
        return
    end

    local myBattleTag = HCT_DataModule:GetBattleTag()
    if not myBattleTag then
        HCT:Print("My Battle Tag missing")
        return
    end

    local db = HCT.db and HCT.db.profile
    if not db then
        HCT:Print("Database profile is missing.")
        return
    end
    -- HCT:Print("Processing bulk update - saving to database.")
    if not db.users then
        db.users = {}
    end
    -- Merge users
    for userKey, userInfo in pairs(payload.users or {}) do
        -- HCT:Print("Attempting to process user table update userKey: "..userKey)

        if myBattleTag == userKey then
            -- HCT:Print("skipping user table update for userKey: "..userKey)
        else
            if not db.users[userKey] then
                db.users[userKey] = userInfo
            else
                for k, v in pairs(userInfo) do
                    db.users[userKey][k] = v
                end
            end
            -- HCT:Print("processed user table update userKey "..userKey)
        end
    end

    -- Merge characters
    for charKey, charInfo in pairs(payload.characters or {}) do
        -- HCT:Print("Attempting to process character table update charKey: "..charKey)
        local battleTagToProcess = charKey:match(":(.*)")
        if myBattleTag == battleTagToProcess then
            -- HCT:Print("skipping character table update for charkey: "..charKey)
        else
            if not db.characters[charKey] then
                db.characters[charKey] = charInfo
            else
                for k, v in pairs(charInfo) do
                    db.characters[charKey][k] = v
                end
            end
            -- HCT:Print("processed character table update charKey "..charKey)
        end
    end

    -- Merge completionLedger
    for completionID, completionInfo in pairs(payload.completionLedger or {}) do
        -- HCT:Print("Attempting to process completionLedger table update completionID: "..completionID)
        local achievementID = tonumber(completionID:match(":(%d+)$")) or 0
        local battleTagToProcess = completionID:match(":(.-):")
        if battleTagToProcess == myBattleTag then
            -- HCT:Print("skipping completionLedger table update for completionID: "..completionID)
        else
            if achievementID == 0 then
                error("Invalid achievementID in completionID: " .. tostring(completionID))
            elseif not db.completionLedger[completionID] then
                db.completionLedger[completionID] = completionInfo
            elseif achievementID >= 500 and achievementID <= 799 then
                if completionInfo.timestamp < db.completionLedger[completionID].timestamp then
                    db.completionLedger[completionID] = completionInfo
                end
            end
            -- HCT:Print("processed completionLedger table update completionID "..completionID)
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
