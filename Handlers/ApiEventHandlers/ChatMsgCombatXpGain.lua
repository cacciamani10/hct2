_G.HCT_Handlers = _G.HCT_Handlers or {}

local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

_G.HCT_Handlers.ChatMsgCombatXpGainHandler = {
    GetEventType = function()
        return "CHAT_MSG_COMBAT_XP_GAIN"
    end,

    GetHandlerName = function()
        return "ChatMsgCombatXpGainHandler"
    end,

    HandleEvent = function(self, HCT, eventName, text, playerName, ...)
        if HCT then
            local player = UnitName("player")

            if player == playerName then
                local xpGain = tonumber(text:match("(%d+) experience")) or 0
                if xpGain > 0 then
                    _G.ACHIEVEMENTS.Achievement_Bounties:CheckBountiesAchievements(801)
                end
            end
        end
    end
}
