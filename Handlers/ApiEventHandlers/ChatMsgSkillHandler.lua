local HCT_Broadcaster = _G.HCT_Broadcaster

_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerDeathHandler = {
    GetEventType = function()
        return "CHAT_MSG_SKILL"
    end,

    GetHandlerName = function()
        return "ChatMsgSkillHandler"
    end,

    HandleEvent = function(self, HCT, event)
        
    end
}
