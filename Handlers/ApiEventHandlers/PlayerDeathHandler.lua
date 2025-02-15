local HCT_Broadcaster = _G.HCT_Broadcaster

local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

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
        --HCT:Print("PlayerDeathHandler:HandleEvent")
        local charKey = HCT_DataModule:GetCharacterKey()
        local db = GetDB()
        local charData = db.characters[charKey]

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
