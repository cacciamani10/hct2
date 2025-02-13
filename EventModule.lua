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
