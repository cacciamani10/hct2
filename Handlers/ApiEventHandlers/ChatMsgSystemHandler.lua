_G.HCT_Handlers = _G.HCT_Handlers or {}

local function GetDB() 
    return _G.HCT_Env.GetAddon().db.profile 
end

_G.HCT_Handlers.ChatMsgSystemHandler = {
    GetEventType = function()
        return "CHAT_MSG_SYSTEM"
    end,

    GetHandlerName = function()
        return "ChatMsgSystemHandler"
    end,

    HandleEvent = function(self, HCT, eventName, text)
        if text and text:find("You create:") then
            if text:find("|cff0070dd") then
                HCT:Print("Rare item crafted!")
                _G.ACHIEVEMENTS.Achievement_Feats:CheckAchievement(511)
            end
        end
    end
}
