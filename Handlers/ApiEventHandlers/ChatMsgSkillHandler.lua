local HCT_Broadcaster = _G.HCT_Broadcaster

_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.ChatMsgSkillHandler = {
    GetEventType = function()
        return "CHAT_MSG_SKILL"
    end,

    GetHandlerName = function()
        return "ChatMsgSkillHandler"
    end,

    HandleEvent = function(self, HCT, event)
         --  arg1 your skill in mining has increased to 57
        if HCT then

            local skillName, skillLevel = string.match(event, "your skill in (.+) has increased to (%d+)")
            if skillName and skillLevel then
                local charKey = HCT_DataModule:GetCharacterKey()
                HCT_DataModule:CheckProfessionAchievement(charKey, skillName, skillLevel)
            end
            HCT:Print("ChatMsgSkillHandler handled.")
        end
    end
}
