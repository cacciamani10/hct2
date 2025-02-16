_G.HCT_Handlers = _G.HCT_Handlers or {}

-- Fires when you are invited to join a guild.

--inviter: string , guildName: string, guildAchievementPoints: number, oldGuildName :string, isNewGuild: boolean?

_G.HCT_Handlers.GuildInviteRequestHandler = {
    
    GetEventType = function() return "GUILD_INVITE_REQUEST" end,

    GetHandlerName = function() return "GuildInviteRequestHandler" end,

    -- what is this doing?
    HandleEvent = function(self, HCT, event, inviter, guildName)
        if not HCT then return end
        local targetGuild = HCT.db.profile.guildName
        if guildName == targetGuild then
            HCT:Print("Guild invite request from " .. inviter .. " to join " .. guildName .. " accepted.")
            AcceptGuild()
        else
            HCT:Print("Guild invite request from " .. inviter .. " to join " .. guildName .. " declined.")
            DeclineGuild()
        end
    end,
}