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
        if not HCT then return end
        local charKey = (UnitName("player")..":"..HCT_DataModule:GetBattleTag())
        local charData = HCT.db.profile.characters[charKey]

        if charData then
            charData.isDead = true

            HCT:Print("You have died... but we go agane!")

            local ev = {
                type = "DEATH",
                charKey = charKey,
                level = UnitLevel("player"),
                name = UnitName("player"),
                timestamp = time()
            }
            
            HCT_Broadcaster:BroadcastEvent(ev)
        end
    end
}
