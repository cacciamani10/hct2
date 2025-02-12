local AceSerializer = LibStub("AceSerializer-3.0")
HCT_EventModule = {}

-- Table to keep track of processed event IDs.
HCT_EventModule.processedEventIDs = {}

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
    
            GetHCT():RegisterEvent(eventType, handlerName)
        end
    end
    
    GetHCT():RegisterEvent("COMBAT_LOG_EVENT", "OnCombatLogEvent") -- This event has only the user's combat log.
    --GetHCT():RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEventUnfiltered") -- This event has the entire guild's combat log.
    GetHCT():RegisterEvent("CHAT_MSG_ADDON", "OnChatMsgAddon")
    GetHCT():RegisterComm(GetHCT().addonPrefix, "OnCommReceived") -- Register for addon messages.
    self:RequestMissingEvents(GetHCT()) -- Request missing events from the guild.
    self:BroadcastBulkEvents() -- Broadcast bulk events to the guild.
end

function HCT_EventModule:UnregisterEvents()
    for _, handler in pairs(_G.HCT_Handlers) do
        local eventType = handler:GetEventType()
        if eventType then
            GetHCT():UnregisterEvent(eventType)
        end
    end

    GetHCT():UnregisterEvent("PLAYER_DEAD")
    GetHCT():UnregisterEvent("COMBAT_LOG_EVENT")
    GetHCT():UnregisterEvent("CHAT_MSG_ADDON")
    GetHCT():UnregisterComm(GetHCT().addonPrefix) -- Unregister for addon messages.
end

function HCT_EventModule:RequestMissingEvents()
    local request = { since = GetDB().lastEventTimestamp or 0 }
    local data = { "Request", request }
    local serializedRequest = AceSerializer:Serialize("REQUEST", data)
    GetHCT():SendCommMessage(GetHCT().addonPrefix, serializedRequest, "GUILD")
    GetHCT():Print("Requested events since " .. (GetDB().lastEventTimestamp or 0))
end

function HCT_EventModule:OnCombatLogEvent(event, ...)
    if not GetHCT() then return end -- Ensure the module is initialized.
    local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags,
          destGUID, destName, destFlags, amount, overkill, school, resisted, block, absorbed, critical, glancing, crushing, isOffHand = ...
    
    -- Example: Track damage dealt by the player.
    if subEvent == "SPELL_DAMAGE" or subEvent == "SWING_DAMAGE" then
        if sourceName == UnitName("player") then
            GetHCT().db.char.totalDamageDealt = (GetHCT().db.char.totalDamageDealt or 0) + (amount or 0)
        end

    -- Similarly for healing or other events.
    elseif subEvent == "SPELL_HEAL" then
        if sourceName == UnitName("player") then
            GetHCT().db.char.totalHealingDone = (GetHCT().db.char.totalHealingDone or 0) + (amount or 0)
        end

    -- Add more subEvent checks as needed.
    end
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

function HCT_EventModule:OnChatMsgAddon(event, prefix, message, channel, sender)
    if prefix ~= GetHCT().addonPrefix then
        return
    end

    -- Filter out messages from ourselves.
    local myName = UnitName("player")
    if sender == myName or Ambiguate(sender, "none") == myName then
        return
    end
    
    print("Raw addon message from " .. sender .. ": " .. message)

    if not GetHCT() then return end -- Ensure the module is properly initialized.
    local success, msgType, payload = AceSerializer:Deserialize(message)
    if success then
        PrintTable(payload)
        if msgType == "EVENT" then
            GetHCT():ProcessEvent(payload)
        elseif msgType == "REQUEST" then
            local since = payload.since or 0
            local eventsToSend = {}
            for _, ev in ipairs(GetDB().eventLog or {}) do
                if ev.timestamp > since then
                    table.insert(eventsToSend, ev)
                end
            end
            local serializedEvents = AceSerializer:Serialize("EVENTDATA", { events = eventsToSend })
            GetHCT():SendCommMessage(GetHCT().addonPrefix, serializedEvents, "GUILD")
        elseif msgType == "EVENTDATA" then
            for _, ev in ipairs(payload.events or {}) do
                GetHCT():ProcessEvent(ev)
            end
        elseif msgType == "TEAMCHAT" then
            HCT_ChatModule:ProcessTeamChatMessage(payload)
        else
            GetHCT():Print("Received unknown message type: " .. tostring(msgType) .. " from " .. sender)
        end
    else
        GetHCT():Print("Failed to deserialize message from " .. sender)
        print("Raw message causing deserialization failure: " .. message)
    end
end

function HCT_EventModule:ProcessEvent(ev)
    if not GetHCT() then return end -- Ensure the module is properly initialized.
    local db = GetDB()
    local uniqueID = ComputeEventID(ev)
    self.processedEventIDs = self.processedEventIDs or {}
    if self.processedEventIDs[uniqueID] then
        return -- Already processed.
    end
    self.processedEventIDs[uniqueID] = true

    if ev.type == "LEVELUP" then
        local charKey = ev.charKey
        if db.characters[charKey] then
            db.characters[charKey].level = ev.newLevel
            db.characters[charKey].levelUpPoints = (db.characters[charKey].levelUpPoints or 0) + ev.pointsAwarded
            -- Update class info if present.
            if ev.class then
                db.characters[charKey].class = ev.class
            end
            GetHCT():Print(charKey .. " has leveled up to " .. ev.newLevel .. ": Awarded " .. ev.pointsAwarded .. " level points.")
        end
    elseif ev.type == "DEATH" then
        local charKey = ev.charKey
        if db.characters[charKey] then
            db.characters[charKey].isDead = true
            GetHCT():Print(charKey .. " has died.")
        end
    elseif ev.type == "ACHIEVEMENT" then
        local charKey = ev.charKey
        if db.characters[charKey] then
            db.characters[charKey].achievementPoints = (db.characters[charKey].achievementPoints or 0) + ev.pointsAwarded
            GetHCT():Print(charKey .. " completed achievement '" .. ev.achievement .. "': Awarded " .. ev.pointsAwarded .. " points.")
        end
    elseif ev.type == "CHARACTER_INFO" then
        -- (Optional) Process a dedicated character info event.
        local charKey = ev.charKey
        if db.characters[charKey] then
            db.characters[charKey].class = ev.class
            db.characters[charKey].race = ev.race
            -- Add any additional fields you wish to propagate.
            GetHCT():Print("Updated info for " .. charKey)
        end
    else
        GetHCT():Print("Unknown event type: " .. tostring(ev.type))
    end
    if ev.timestamp and ev.timestamp > db.lastEventTimestamp then
        db.lastEventTimestamp = ev.timestamp
    end
end

function HCT_EventModule:BroadcastEvent(ev)
    if not GetHCT() then return end -- Ensure the module is initialized.
    table.insert(GetDB().eventLog, ev)
    
    -- Debug: print the event table being broadcast.
    HCT:Print("Broadcasting event: " .. ev.type)
    PrintTable(ev)  -- Assumes you have a helper to print tables.
    
    local serialized = AceSerializer:Serialize("EVENT", ev)
    if not serialized or serialized == "" then
        HCT:Print("Error: Serialized event is empty!")
    else
        print("Serialized event: " .. serialized)
    end
    GetHCT():SendCommMessage(GetHCT().addonPrefix, serialized, "GUILD")
end

function HCT_EventModule:BroadcastBulkEvents()
    if not GetHCT() then return end

    local currentTime = time()
    local bulkEvents = {}
    for _, ev in ipairs(GetDB().eventLog or {}) do
        if currentTime - ev.timestamp <= 3600 then
            table.insert(bulkEvents, ev)
        end
    end
    if #bulkEvents > 0 then
        local serializedBulk = AceSerializer:Serialize("EVENTDATA", { events = bulkEvents })
        GetHCT():SendCommMessage(GetHCT().addonPrefix, serializedBulk, "GUILD")
        GetHCT():Print("Broadcasted bulk event update (" .. #bulkEvents .. " events).")
    end
end
