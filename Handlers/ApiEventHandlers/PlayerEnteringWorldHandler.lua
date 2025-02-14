_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerEnteringWorldHandler = {
    GetEventType = function() return "PLAYER_ENTERING_WORLD" end,
    GetHandlerName = function() return "PlayerEnteringWorldHandler" end,

    HandleEvent = function(self, HCT, event)
        if not HCT then return end
        local xp = UnitXP("player") 
        if xp == 0 then
            HCT:Print("PlayerEnteringWorldHandler: New character detected.") 
        end
        if UnitIsGhost("player") then
            local charKey = HCT_DataModule:GetCharacterKey()
            if charKey == nil then 
                return 
            end
            local charData = HCT.db.profile.characters[charKey]
            if charData then
                charData.isDead = true
                HCT:Print("You have died... but we go agane!")
            end
        end
        -- Request data
        HCT_Broadcaster:RequestContestData() -- Request contest data from the guild.
        HCT:Print("Player entering world event handled.")
    end
}