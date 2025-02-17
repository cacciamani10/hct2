_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerEnteringWorldHandler = {
    --PLAYER_ENTERING_WORLD is a Blizzard event that fires as the player transitions into the game world
    GetEventType = function() return "PLAYER_ENTERING_WORLD" end,

    GetHandlerName = function() return "PlayerEnteringWorldHandler" end,

    HandleEvent = function(self, HCT, event, isLogin)
        if not HCT then return end
        self:InitializeCharacter()
        self:HandleNewCharacterLogin(HCT)
        self:HandleLogin(HCT, isLogin)
        self:HandleGhostState(HCT)
        self:HandleInitialLogin(event)
    end,

    HandleGhostState = function(HCT)
        --_G.HCT_Env.GetAddon():Print("PlayerEnteringWorldHandler:HandleGhostState: " .. tostring(UnitIsGhost("player")))
        --     end
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
            --HCT_Broadcaster:RequestContestData()
        end
    end,

    HandleLogin = function(HCT, isLogin)
        if isLogin then
            
        end
    end,

    -- if a character dies without earning exp this logic will execute
    HandleNewCharacterLogin = function(HCT)
        local xp = UnitXP("player") 
        if xp == 0 then
            --_G.HCT_Env.GetAddon():Print("PlayerEnteringWorldHandler: New character detected.")
        end
    end,

    -- new character login for first time: UnitIsDeadOrGhost, UnitIsGhost, UnitIsDead will return false
    -- second login alive character, UnitIsDeadOrGhost, UnitIsGhost, UnitIsDead will return false
    -- first login after character death, UnitIsDeadOrGhost will return true, UnitIsGhost will return false, UnitIsDead will return true
    -- second login after character death, UnitIsDeadOrGhost will return true, UnitIsGhost will return true, UnitIsDead will return false
    InitializeCharacter = function(HCT)
        if not UnitIsDeadOrGhost("player") then
            _G.DAO.CharacterDao:InitializeCharacter()
        end
    end
}
