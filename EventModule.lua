local AceSerializer = LibStub("AceSerializer-3.0")
HCT_EventModule = {}

local function GetHCT()
    return _G.HCT_Env.GetAddon()
end

local function GetHandlers()
    return _G.HCT_Env.GetAddon().HCT_Handlers
end

local function GetDB()
    return _G.HCT_Env.GetAddon().db.profile
end

-- Helper function: compute a unique ID for an event.
local function ComputeEventID(ev)
    local key = ev.charKey or ev.team or ""
    return ev.type .. ":" .. key .. ":" .. ev.timestamp
end

function HCT_EventModule:RegisterEvents()
    for _, handler in pairs(_G.HCT_Handlers) do
        local eventType = handler:GetEventType()
        local handlerName = handler:GetHandlerName()

        GetHCT():Print("Registering event: " .. eventType .. " with handler: " .. handlerName)
        -- Define the callback that calls the handler's HandleEvent.
        GetHCT()[handlerName] = function(_, ...)
            handler:HandleEvent(GetHCT(), ...)
        end

        -- If this handler is for non-comm events, register it normally.
        -- For comm events (when eventType equals the addon prefix), skip registering here.
        if eventType ~= GetHCT().addonPrefix then
            GetHCT():RegisterEvent(eventType, handlerName)
        else
            -- For comm messages, we rely on the centralized AceComm callback (OnCommReceived) registered in Core.
            -- If desired, you could store these handlers for later dispatch.
        end
    end

    -- Broadcast initial data.
    HCT_Broadcaster:RequestContestData()
    HCT_Broadcaster:BroadcastBulkEvents()
end

function HCT_EventModule:UnregisterEvents()
    for _, handler in pairs(_G.HCT_Handlers) do
        local eventType = handler:GetEventType()
        if eventType ~= GetHCT().addonPrefix then
            GetHCT():UnregisterEvent(eventType)
        end
    end
end

function HCT_EventModule:ProcessEvent(ev)
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
    else
        HCT:Print("Process Event: Unknown event type: " .. tostring(ev.type))
    end
end

function HCT_EventModule:ProcessBulkUpdate(payload)
    local HCT = GetHCT()
    if not HCT then return end
    local db = GetDB()
    -- Merge users
    for userKey, userInfo in pairs(payload.users) do
        if not db.users[userKey] then
            HCT:Print("Adding new user: " .. userKey)

            db.users[userKey] = userInfo
        else
            -- HCT:Print("Updating user: " .. userKey)
            for k, v in pairs(userInfo) do
                db.users[userKey][k] = v
            end
        end
    end
    -- Merge characters
    for charKey, charInfo in pairs(payload.characters) do
        if not db.characters[charKey] then
            HCT:Print("Adding new character: " .. charKey)
            db.characters[charKey] = charInfo
        else
            -- HCT:Print("Updating character: " .. charKey)
            for k, v in pairs(charInfo) do
                db.characters[charKey][k] = v
            end
        end
    end
    -- Merge completionLedger
    -- (completionID = characterKey:achievementID)
    -- [completionID] = { timestamp = timestamp }
    for completionID, completionInfo in pairs(payload.completionLedger) do
        if not db.completionLedger[completionID] then
            HCT:Print("Adding new ledger completion: " .. completionID)
        else
            -- HCT:Print("Updating completion: " .. completionID)
        end
        if not completionInfo then
            HCT:Print("Invalid completionInfo for completionID: " .. completionID)
            break
        end
        HCT:Print("Processing completion: " .. completionID .. " with timestamp: " .. tostring(completionInfo.timestamp))
        local achievementID = tonumber(completionID:match(":(%d+)$")) or 0
        if achievementID == 0 then
            GetHCT():Print("Invalid achievementID in completionID: " .. tostring(completionID))
            return
        end
        if not db.completionLedger[completionID] then
            db.completionLedger[completionID] = completionInfo
        elseif achievementID <= 799 and achievementID >= 500 then
            if completionInfo.timestamp < db.completionLedger[completionID].timestamp then -- error here
                db.completionLedger[completionID] = completionInfo
            end
        end
    end
    -- GetHCT():Print("Processed bulk update.")
end

function HCT_EventModule:RespondToRequest(payload)
    if not GetHCT() then return end
    HCT_Broadcaster:BroadcastBulkEvents()
end
