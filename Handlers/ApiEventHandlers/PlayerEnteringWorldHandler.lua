_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerEnteringWorldHandler = {
    GetEventType = function() return "PLAYER_ENTERING_WORLD" end,
    GetHandlerName = function() return "PlayerEnteringWorldHandler" end,

    HandleEvent = function(self, HCT, event, isLogin)
        if not HCT then return end
        local xp = UnitXP("player") 
        if xp == 0 then
            HCT:Print("PlayerEnteringWorldHandler: New character detected.") 
        end
        if isLogin then
            HCT_DataModule:InitializeCharacterData()
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
        
        if event.isInitialLogin then
            --HCT_Broadcaster:RequestContestData()
        end
        _G.WhisperMessanger.WhisperMessanger("Electromance")
        _G.WhisperMessanger.WhisperMessanger("Pandaexp")
        HCT:Print("Player entering world event handled.")
    end
}