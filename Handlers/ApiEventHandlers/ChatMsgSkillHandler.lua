_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.ChatMsgSkillHandler = {
    GetEventType = function()
        return "CHAT_MSG_SKILL"
    end,

    GetHandlerName = function()
        return "ChatMsgSkillHandler"
    end,

    HandleEvent = function(self, HCT, eventName, text, playerName, languageName, channelName, playerName2, specialFlags,
                           zoneChannelID, channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile,
                           isSubtitle, hideSenderInLetterbox, supressRaidIcons)
        if HCT then
            local skillThresholds = { 75, 150, 225, 300 }
            local lowerText = text:lower():gsub("%.$", "")
            local skillName, skillLevel = string.match(lowerText, "your skill in%s+([%a ]+)%s+has increased to%s+(%d+)")
            if skillName and skillLevel then
                local charKey = HCT_DataModule:GetCharacterKey()
                local skillLevelNumber = tonumber(skillLevel)
                if skillLevelNumber then
                    if tContains(skillThresholds, skillLevelNumber) then
                        HCT:Print("Skill threshold detected. Checking achievement for " ..
                        skillName .. " to " .. skillLevel)
                        HCT_DataModule:CheckProfessionAchievement(charKey, skillName, skillLevelNumber)
                    end
                end
            else
                HCT:Print("No skill match in: " .. text)
            end
        end
    end
}
