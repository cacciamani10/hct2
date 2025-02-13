local AceSerializer = LibStub("AceSerializer-3.0")
local AddonCommProcessor = {}
local HCT_Broadcaster = _G.HCT_Broadcaster
local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

function AddonCommProcessor:ProcessEvent(ev)
    local HCT = GetHCT()
    if not HCT then return end
    local db = GetDB().profile

    if ev.type == "DEATH" then
        local charKey = ev.charKey
        if db.characters[charKey] then
            db.characters[charKey].isDead = true
            HCT:Print(charKey .. " has died.")
        end
    elseif ev.type == "CHARACTER" then
        local charKey = ev.characterName .. ":" .. ev.battleTag
        if db.characters[charKey] then
            for k, v in pairs(ev) do
                db.characters[charKey][k] = v
            end
            HCT:Print("Updated info for " .. charKey)
        end
    elseif ev.type == "SPECIAL_KILL" then
        local mobName = ev.name or "Unknown Mob"
        local classification = ev.classification or "unknown classification"
        local characterName = ev.characterName or "Unknown Player"    
        HCT:Print(characterName .. " killed a " .. classification .. ": " .. mobName)
    elseif ev.type == "PLAYER_LOGOUT" then
        local characterName = ev.characterName or "Unknown Player"
        HCT:Print(characterName .. " logged out")
    else
        HCT:Print("Process Event: Unknown event type: " .. tostring(ev.type))
    end
end

function AddonCommProcessor:ProcessBulkUpdate(payload)
    local HCT = GetHCT()
    if not HCT then return end
    local db = GetDB().profile
    if not db then return end
    HCT:Print("Processing bulk update - saving to database.")
    if not db.users then db.users = {} end
    -- Merge users
    for userKey, userInfo in pairs(payload.users or {}) do
        if not db.users[userKey] then
            db.users[userKey] = userInfo
        else
            for k, v in pairs(userInfo) do
                db.users[userKey][k] = v
            end
        end
    end

    -- Merge characters
    for charKey, charInfo in pairs(payload.characters or {}) do
        if not db.characters[charKey] then
            db.characters[charKey] = charInfo
        else
            for k, v in pairs(charInfo) do
                db.characters[charKey][k] = v
            end
        end
    end

    -- Merge completionLedger
    for completionID, completionInfo in pairs(payload.completionLedger or {}) do
        local achievementID = tonumber(completionID:match(":(.+)$")) or 0
        if achievementID == 0 then
            HCT:Print("Invalid achievementID in completionID: " .. tostring(completionID))
        elseif not db.completionLedger[completionID] then
            db.completionLedger[completionID] = completionInfo
        elseif achievementID >= 500 and achievementID <= 799 then
            if completionInfo.timestamp < db.completionLedger[completionID].timestamp then
                db.completionLedger[completionID] = completionInfo
            end
        end
    end

    HCT:Print("Processed bulk update.")
end

function AddonCommProcessor:RespondToRequest(payload)
    if not GetHCT() then return end
    HCT_Broadcaster:BroadcastBulkEvents()
end

_G.AddonCommProcessor = AddonCommProcessor
