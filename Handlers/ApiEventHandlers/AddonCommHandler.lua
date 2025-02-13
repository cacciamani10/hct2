local HCT_EventModule = _G.HCT_EventModule
local AddonEventHandler = _G.HCT_Handlers.AddonEventHandler

_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.AddonCommHandler = {
    GetEventType = function()
        return _G.HCT_Env.GetAddon().addonPrefix
    end,

    GetHandlerName = function()
        return "OnCommReceived"
    end,

    HandleEvent = function(self, HCT, prefix, message, distribution, sender)
        if prefix == HCT.addonPrefix then
            -- Delegate the handling to AddonEventHandler. Not sure if AddonEventHandler also needs to be registered with wow API
            AddonEventHandler:HandleEvent(HCT, "CHAT_MSG_ADDON", prefix, message, distribution, sender)
        end
    end
}
