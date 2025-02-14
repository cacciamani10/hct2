_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.GuildRosterUpdateHandler = {
    GetEventType = function()
        return "GUILD_ROSTER_UPDATE"
    end,

    GetHandlerName = function()
        return "GuildRosterUpdateHandler"
    end,

    HandleEvent = function(self, HCT, event, isUpdated)
        if HCT then
            HCT:Print("Guild roster update handled.")
            if isUpdated then 
                HCT:Print("Guild roster event with update")
            else 
                HCT:Print("Guild roster event with nothing new")
            end
        end
    end
}
