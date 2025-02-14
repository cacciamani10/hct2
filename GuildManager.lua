HCT_GuildManager = {}
local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end
-- Add battle tag - team to guild notes automatically (e.g. “PeterPiper#1480 - Team 1”)
-- Mark guild mates as dead. When a player receives an event of player death, update the guild note to (e.g. “PeterPiper#1480 - Team 1 - Dead”)
-- Auto invite new characters of players with the addon. If a player login and they are not in the guild, send a guild_join_request which responds with a guild invite.

function HCT_GuildManager:UpdateGuildNotes()
    if not GetHCT() then return end
    local db = GetDB()
    -- Update guild notes for all guild members
    local guildName = GetGuildInfo("player")
    if not guildName or guildName ~= db.guildName then return end

    local numGuildMembers = GetNumGuildMembers()
    for i = 1, numGuildMembers do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
        local charKey = GetHCT().HCT_DataModule:GetCharKey(name)
        local battleTag = db.characters[charKey] and db.characters[charKey].battleTag or ""
        local team = db.characters[charKey] and db.characters[charKey].team or ""
        local isDead = db.characters[charKey] and db.characters[charKey].isDead or false
        local noteString = battleTag .. " - " .. team .. (isDead and " - [Dead]" or "")
        if not battleTag or not team then return end
        if note ~= noteString then
            GuildRosterSetOfficerNote(i, noteString)
        end
    end
end

function HCT_GuildManager:HandleGuildDeath()
    if not GetHCT() then return end
    local db = GetDB()
    local characterName = UnitName("player")
    local battleTag = GetHCT().HCT_DataModule:GetBattleTag()
    local charKey = characterName .. ":" .. battleTag
    local charData = db.characters[charKey]

    if charData then
        charData.isDead = true
        HCT_GuildManager:UpdateGuildNotes()
    end
end

function HCT_GuildManager:AutoRequestToJoinGuild()
    if not GetHCT() then return end
    if not IsInGuild() then
        local db = GetDB()
        local requester = UnitName("player")

        local ev = {
            type = "GUILD_JOIN_REQUEST",
            requester = requester,
        }
        HCT_Broadcaster:BroadcastEvent(ev)
    end
end

function HCT_GuildManager:HandleGuildInviteRequest(event, requester)
    
    if not GetHCT() then return end
    GetHCT():Print("Handling guild invite request from " .. requester)
    local db = GetDB()
    local targetGuild = db.guildName
    GuildInvite(requester) -- TODO: Fix this
end
