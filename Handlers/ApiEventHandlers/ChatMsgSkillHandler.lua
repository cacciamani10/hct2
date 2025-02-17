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

            local skillThresholds = { 75, 150, 225, 300 }
            local lowerText = text:lower():gsub("%.$", "")
            local professionList = {"alchemy", "leatherworking", "blacksmithing", "enchanting", "engineering", "herbalism", "tailoring", "skinning", "mining", "fishing", "cooking", "first aid"}
            local skillName, skillLevel = string.match(lowerText, "your skill in%s+([%a ]+)%s+has increased to%s+(%d+)")
            if skillName and skillLevel then
                if  not tContains(professionList, skillName) then return end -- Only check professions
                local skillLevelNumber = tonumber(skillLevel)
                if skillLevelNumber then
                    if tContains(skillThresholds, skillLevelNumber) then
                        HCT:Print("Skill threshold detected. Checking achievement for " ..
                        skillName .. " to " .. skillLevel)
                        _G.ACHIEVEMENTS.Achievement_Professions:CheckProfessionAchievements(skillName, skillLevelNumber)
                    end
                end
            end

    end
}
