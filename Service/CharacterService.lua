local AceSerializer = LibStub("AceSerializer-3.0")

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

_G.Service = _G.Service or {}
_G.Service.Character_Service = _G.Service.Character_Service or {}

function _G.Service.Character_Service:ProcessEvent(ev)
    local HCT = GetHCT()

    if not HCT then
        return
    end
    local db = GetDB()
    if ev.type == "DEATH" then
        HCT:Print("|cffff0000" .. ev.character.username .. " has died at level " .. ev.character.level .. "|r")
        _G.Dao.CharacterDao:UpdateCharacter(ev.uuid, ev.character, ev.timestamp)
    elseif ev.type == _G.EventType.CHARACTER then
        if ev.subtype == "LEVEL_UP" then
            HCT:Print(ev.character.username .. " has leveled up to level " .. ev.character.level)
        elseif ev.subtype == "DEAD" then
            HCT:Print("|cffff0000" .. ev.character.username .. " has died at level " .. ev.character.level .. "|r")
        elseif ev.subtype == "NEW" then
            HCT:Print("Adding new character: " .. ev.character.username)
        
        _G.Dao.CharacterDao:UpdateCharacter(ev.uuid, ev.character, ev.lastUpdated)
        end
        -- elseif ev.type == "SPECIAL_KILL" then
        --     local mobName = ev.name or "Unknown Mob"
        --     local classification = ev.classification or "unknown classification"
        --     local characterName = ev.characterName or "Unknown Player"
        --     HCT:Print(characterName .. " killed a " .. classification .. ": " .. mobName)
    elseif ev.type == "PLAYER_LOGOUT" then
        local characterName = ev.characterName or "Unknown Player"
        HCT:Print(characterName .. " logged out")
    elseif ev.type == "GUILD_JOIN_REQUEST" then
        local requester = ev.requester or "Unknown Player"
        HCT:Print(requester .. " requested to join the guild")
        HCT_GuildManager:HandleGuildInviteRequest(ev.type, requester)
    else
        HCT:Print("Process Event: Unknown event type: " .. tostring(ev.type))
    end
end