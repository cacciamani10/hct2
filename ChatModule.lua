local AceSerializer = LibStub("AceSerializer-3.0")
local AceGUI = LibStub("AceGUI-3.0")
HCT_ChatModule = {}
local function GetHCT()
    return _G.HCT_Env.GetAddon()
end

function HCT_ChatModule:SendTeamChatMessage(text)
    local characterName = UnitName("player")
    local _, classFileName = UnitClass("player")
    local battleTag = HCT_DataModule:GetBattleTag()
    local team = HCT_DataModule:GetPlayerTeam(battleTag) or 0


    local teamData = HCT.db.profile.teams[team] or { color = { r = 255, g = 255, b = 255 } }
    local teamColor = HCT_DataModule.NormalizeColor(teamData.color)
    local teamColorCode = string.format("|cff%02x%02x%02x", teamColor.r, teamColor.g, teamColor.b)

    local classColorStr = "ffffff"
    if classFileName and RAID_CLASS_COLORS[classFileName] then
        classColorStr = RAID_CLASS_COLORS[classFileName].colorStr or "ffffff"
    end
    classColorStr = string.gsub(classColorStr, "%s+", "")
    classColorStr = string.sub(classColorStr, 1, 6)

    local teamChatTag = string.format("%s[Team Chat]|r ", teamColorCode)
    local characterNameColored = string.format("|cff%s%s|r", classColorStr, characterName)
    local fullMessage = teamChatTag .. characterNameColored .. ": " .. text

    local payload = {
        type = "TEAMCHAT",
        character = characterName,
        class = classFileName,
        sender = battleTag,
        team = team,
        text = text,
        timestamp = time(),
    }
    local serialized = AceSerializer:Serialize("TEAMCHAT", payload)
    HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")
    DEFAULT_CHAT_FRAME:AddMessage(fullMessage)
    HCT_ChatModule:AddTeamChatMessage(fullMessage)
end

function HCT_ChatModule:AddTeamChatMessage(message)
    HCT.teamChatLog = HCT.teamChatLog or {}
    table.insert(HCT.teamChatLog, message)
    if HCT.teamChatContainer then
        local msgLabel = AceGUI:Create("Label")
        msgLabel:SetFullWidth(true)
        msgLabel:SetText(message)
        HCT.teamChatContainer:AddChild(msgLabel)
    end
end


function HCT_ChatModule:RegisterChatCommands()
    GetHCT():RegisterChatCommand("t", function(input)
        if input and input ~= "" then
            HCT_ChatModule:SendTeamChatMessage(input)
        end
    end)
end

function HCT_ChatModule:UnregisterChatCommands()
    -- No built-in unregister exists; this is a placeholder if needed.
end

function HCT_ChatModule:ProcessTeamChatMessage(payload)
    local localBattleTag = HCT_DataModule:GetBattleTag()
    if payload.sender == localBattleTag then return end
    local localTeam = HCT_DataModule:GetPlayerTeam(localBattleTag)
    if payload.team and localTeam == payload.team then
        local senderName = payload.character or payload.sender
        local senderClass = payload.class
        local classColorStr = "ffffff"
        local teamColorStr = "ffffff"
        if senderClass and RAID_CLASS_COLORS[senderClass] then
            classColorStr = RAID_CLASS_COLORS[senderClass].colorStr or "ffffff"
        end
        if HCT.db.profile.teams[payload.team] then
            local teamColor = HCT_DataModule.NormalizeColor(HCT.db.profile.teams[payload.team].color)
            teamColorStr = string.format("%02x%02x%02x", teamColor.r, teamColor.g, teamColor.b)
        end
        classColorStr = string.gsub(classColorStr, "%s+", "")
        classColorStr = string.sub(classColorStr, 1, 6)
        local formattedMsg = string.format("|cff%s[Team Chat]|r |cff%s%s|r: %s", teamColorStr, classColorStr, senderName, payload.text)
        DEFAULT_CHAT_FRAME:AddMessage(formattedMsg)
        HCT_ChatModule:AddTeamChatMessage(formattedMsg)
    end
end
