_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.GuildRosterUpdateHandler = {
    GetEventType = function()
        return "GUILD_ROSTER_UPDATE"
    end,

    GetHandlerName = function()
        return "GuildRosterUpdateHandler"
    end,

    HandleEvent = function(self, HCT, event)
        if HCT then
            HCT_Broadcaster:BroadcastBulkEvents()
            HCT:Print("Guild roster update handled.")
        end
    end
}
