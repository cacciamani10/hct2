local HCT_Broadcaster = _G.HCT_Broadcaster

_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerDeathHandler = {
    GetEventType = function()
        return "PLAYER_DEAD"
    end,

    GetHandlerName = function()
        return "PlayerDeathHandler"
    end,

    HandleEvent = function(self, HCT, event)
        local charKey = UnitName("player")
        local charData = HCT.db.profile.characters[charKey]

        if charData then
            charData.isDead = true

            HCT:Print("You have died... but we go agane!")

            local ev = {
                type = "DEATH",
                charKey = charKey,
                timestamp = time()
            }
            
            HCT_Broadcaster:BroadcastEvent(ev)
        end
    end
}
