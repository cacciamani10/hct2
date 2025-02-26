_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.ChatMsgCombatMiscInfoHandler = {
    GetEventType = function()
        return "CHAT_MSG_COMBAT_MISC_INFO"
    end,

    HandleEvent = function(self, HCT, eventName, text)
        local playerName = UnitName("player")
        local playerLevel = UnitLevel("player")
        if playerLevel > 10 and text then
            if text:find(playerName .. " fell to his death") or text:find(playerName .. " fell to her death") then
                print("Falling death detected for " .. playerName)
                _G.Dao.CharacterDao:AddLevelingAchievement(513)
            end
        end
    end
}
