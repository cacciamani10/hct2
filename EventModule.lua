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
    -- Use ev.type, ev.charKey (or ev.team if applicable), and ev.timestamp.
    local key = ev.charKey or ev.team or ""
    return ev.type .. ":" .. key .. ":" .. ev.timestamp
end

function HCT_EventModule:RegisterEvents()
    for _, handler in pairs(_G.HCT_Handlers) do
        local eventType = handler:GetEventType()
        local handlerName = handler:GetHandlerName()
    
        if eventType and handlerName then
            GetHCT()[handlerName] = function(_, ...)
                handler:HandleEvent(GetHCT(), ...)
            end
            
            if eventType == GetHCT().addonPrefix then 
                GetHCT():RegisterComm(eventType, handlerName)
            else 
                GetHCT():RegisterEvent(eventType, handlerName)
            end
        end
    end

    --GetHCT():RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEventUnfiltered") -- This event has the entire guild's combat log.
    self:RequestContestData() -- Request missing events from the guild.
    HCT_Broadcaster:BroadcastBulkEvents() -- Broadcast bulk events to the guild.
end

function HCT_EventModule:UnregisterEvents()
    for _, handler in pairs(_G.HCT_Handlers) do
        local eventType = handler:GetEventType()
        if eventType then
            GetHCT():UnregisterEvent(eventType)
        end
    end

    GetHCT():UnregisterEvent("COMBAT_LOG_EVENT")
    GetHCT():UnregisterComm(GetHCT().addonPrefix) -- Unregister for addon messages.
end

function HCT_EventModule:RequestContestData()
    local ev = {
        type = "REQUEST",
        payload = "request"
    }
    HCT_Broadcaster:BroadcastEvent(ev)
    GetHCT():Print("Requesting data update...")
end

local function PrintTable(t, indent)
    indent = indent or 0
    local indentStr = string.rep("  ", indent)
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indentStr .. tostring(k) .. ":")
            PrintTable(v, indent + 1)
        else
            print(indentStr .. tostring(k) .. ": " .. tostring(v))
        end
    end
end

function HCT_EventModule:ProcessEvent(ev)
    if not GetHCT() then return end -- Ensure the module is properly initialized.
    local db = GetDB()
    if ev.type == "DEATH" then
        local charKey = ev.charKey
        if db.characters[charKey] then
            db.characters[charKey].isDead = true
            GetHCT():Print(charKey .. " has died.")
        end
    elseif ev.type == "CHARACTER_INFO" then
        -- (Optional) Process a dedicated character info event.
        local charKey = ev.charKey
        if db.characters[charKey] then
            for k, v in pairs(ev) do -- Merge the character info.
                db.characters[charKey][k] = v -- Update the character info.
            end
            GetHCT():Print("Updated info for " .. charKey)
        end
    else
        GetHCT():Print("Unknown event type: " .. tostring(ev.type))
    end
end

function HCT_EventModule:ProcessBulkUpdate(payload)
    if not GetHCT() then return end -- Ensure the module is properly initialized.
    local db = GetDB() -- Access the database.
    -- Payload should contain users, characters, and completionLedger.
    -- Merge users
    for userKey, userInfo in pairs(payload.users) do
        if not db.users[userKey] then
            db.users[userKey] = userInfo
        else -- Merge existing user info.
            for k, v in pairs(userInfo) do
                db.users[userKey][k] = v
            end
        end
    end
    -- Merge characters
    for charKey, charInfo in pairs(payload.characters) do
        if not db.characters[charKey] then
            db.characters[charKey] = charInfo
        else -- Merge existing character info.
            for k, v in pairs(charInfo) do
                db.characters[charKey][k] = v
            end
        end
    end
    -- Merge completionLedger (assuming it's a set of completionIDs)
    for completionID, completionInfo in pairs(payload.completionLedger) do
        -- (characterKey = characterName:battleTag)
        -- (completionID = characterKey:achievementID)
        -- (achievementID = characterName:battleTag:achievementID)
        local achievementID = tonumber(completionID:match(":(.+)$")) or 0 -- Extract the achievementID.
        if achievementID == 0 then 
            GetHCT():Print("Invalid achievementID in completionID: " .. tostring(completionID)) -- Debug print.
            return 
        end 
        
        if not db.completionLedger[completionID] then
            db.completionLedger[completionID] = completionInfo
        -- Feat IDs are between 500 and 799. If the achievementID is for a feat, check if an earlier timestamp exists
        elseif achievementID <= 799 and achievementID >= 500 then
            if completionInfo.timestamp < db.completionLedger[completionID].timestamp then
                db.completionLedger[completionID] = completionInfo
            end
        end
    end
    GetHCT():Print("Processed bulk update.") -- Debug print.
end

function HCT_EventModule:RespondToRequest(payload)
    if not GetHCT() then return end -- Ensure the module is properly initialized.
    HCT_Broadcaster:BroadcastBulkEvents() -- Broadcast bulk events to the guild.
end
