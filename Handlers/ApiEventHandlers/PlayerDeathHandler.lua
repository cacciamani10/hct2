local HCT_Broadcaster = _G.HCT_Broadcaster

local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.PlayerDeathHandler = {
    -- this event fires the first time you relogin on a dead character
    GetEventType = function()
        return "PLAYER_DEAD"
    end,

    GetHandlerName = function()
        return "PlayerDeathHandler"
    end,

    -- alive character has just died: UnitIsDeadOrGhost will return true, UnitIsGhost will return false, UnitIsDead will return true
    -- first login on dead character: UnitIsDeadOrGhost will return true, UnitIsGhost will return false, UnitIsDead will return true
    -- alive character has just died with .5second delay: UnitIsDeadOrGhost will return true, UnitIsGhost will return false, UnitIsDead will return true
    -- first login on dead character with .5second delay: UnitIsDeadOrGhost will return true, UnitIsGhost will return true, UnitIsDead will return false
    HandleEvent = function(self, HCT, event)
        if not HCT then return end
        -- This is a hack to differentiate between a death of a character and the fisrt login on a dead character
        -- could also just check if there is an alive character before tring to mark the character as dead, since
        -- character names must be unique realm wide regardless if its alive or dead
        C_Timer.After(0.5, function()
            if not UnitIsGhost("player") then
                local timestamp = time()
                local battleTag = HCT_DataModule:GetBattleTag()
                local username = UnitName("player")
                
                _G.DAO.CharacterDao:MarkCharacterAsDead(battleTag, username, timestamp)
                HCT:Print("You have died... but we go agane!")

                local event = {
                    type = "DEATH",
                    uuid = _G.DAO.CharacterDao:GetCharacterUUID_BattleTag_Username(battleTag, username),
                    lastUpdated = timestamp,
                    character = _G.DAO.CharacterDao:GetCharacter()
                }
                
                HCT_Broadcaster:BroadcastEvent(event)
            end
        end)
    end
}
