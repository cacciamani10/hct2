_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerEnteringWorldHandler = {
    --PLAYER_ENTERING_WORLD is a Blizzard event that fires as the player transitions into the game world
    GetEventType = function() return "PLAYER_ENTERING_WORLD" end,

    GetHandlerName = function() return "PlayerEnteringWorldHandler" end,

    HandleEvent = function(self, HCT, event, isLogin)
        if not HCT then return end
        self:HandleNewCharacterLogin(HCT)
        self:HandleLogin(HCT, isLogin)
        self:HandleGhostState(HCT)
        self:HandleInitialLogin(event)
    end,

    HandleGhostState = function(HCT)
        -- if UnitIsGhost("player") then
        --     local charKey = HCT_DataModule:GetCharacterKey()
        --     if not charKey then return end
        --     local charData = HCT.db.profile.characters[charKey]
        --     if charData then
        --         charData.isDead = true
        --         HCT:Print("You have died... but we go agane!")
        --     end
        -- end
    end,

    HandleInitialLogin = function(event)
        if event.isInitialLogin then
            HCT_Broadcaster:RequestContestData()
        end
    end,

    HandleLogin = function(HCT, isLogin)
        if isLogin then
            
        end
    end,

    HandleNewCharacterLogin = function(HCT)
        local xp = UnitXP("player") 
        if xp == 0 then
            _G.HCT_Env.GetAddon():Print("PlayerEnteringWorldHandler: New character detected.")
        end
    end
}
