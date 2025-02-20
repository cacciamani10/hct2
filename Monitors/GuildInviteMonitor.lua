_G.Monitors = _G.Monitors or {}

_G.Monitors.GuildInviteMonitor = {
    Check = function()
        if not IsInGuild() then return end

        local guildMembers = {}
        for i = 1, GetNumGuildMembers() do
            local name = GetGuildRosterInfo(i)
            if name then guildMembers[name] = true end
        end

        for i = 1, C_FriendList.GetNumFriends() do
            local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
            if friendInfo and friendInfo.connected then
                local friendName = friendInfo.name
                if friendName and not guildMembers[friendName] then
                    print("|cffff0000" .. friendName .. " is online but not in the guild! Consider inviting them.|r")
                end
            end
        end
    end
}

function _G.Monitors.GuildInviteMonitor:StartMonitor()
    C_Timer.NewTicker(900, function()
        if _G.HCT_Handlers.GuildInviteMonitorHandler then
            _G.HCT_Handlers.GuildInviteMonitorHandler:Check()
        end
    end)
end