HCT_EventModule = {}

local function GetHCT()
    return _G.HCT_Env.GetAddon()
end

function HCT_EventModule:RegisterEvents()
    for _, handler in pairs(_G.HCT_Handlers) do
        local eventType = handler:GetEventType()
        local handlerName = handler:GetHandlerName()

        --GetHCT():Print("Registering event: " .. eventType .. " with handler: " .. handlerName)
        -- Define the callback that calls the handler's HandleEvent.
        GetHCT()[handlerName] = function(_, ...)
            handler:HandleEvent(GetHCT(), ...)
        end

        -- If this handler is for non-comm events, register it normally.
        -- For comm events (when eventType equals the addon prefix), skip registering here.
        if handlerName == "AddonCommHandler" then
            GetHCT():RegisterComm(GetHCT().addonPrefix, handlerName)
        elseif eventType ~= GetHCT().addonPrefix then
            GetHCT():RegisterEvent(eventType, handlerName)
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
