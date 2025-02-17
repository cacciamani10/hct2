if not _G.DAO then
    _G.DAO = {}
end

if not _G.DAO.CharacterDao then
    _G.DAO.CharacterDao = {}
end

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

function _G.DAO.CharacterDao:InitializeCharacter()
    local db = GetDB()
    local playerFaction = UnitFactionGroup("player")
    local playerRealm = GetRealmName()
    local username = UnitName("player")
    local battleTag = HCT_DataModule:GetBattleTag()
    if not battleTag then
        GetHCT():Print("No battle tag found.")
        return
    end

    -- TODO ensure the character is created on the specific server and for a specific faction
    -- if playerFaction ~= db.faction then
    --     GetHCT():Print("This character is not eligible. Invalid faction: " .. playerFaction)
    --     return
    -- end

    if not db.users[battleTag].characters.alive[username] then
        GetHCT():Print("CharacterDao:InitializeCharacter:Creating New Character: " .. username)
        local level = UnitLevel("player") or 1
        local class = select(2, UnitClass("player")) or "Unknown"
        local race = select(2, UnitRace("player")) or "Unknown"

        local uuid = _G.Utils.TimeUtils.CreateTimeBasedUUID()

        db.users[battleTag].characters.alive[username] = {};
        table.insert(db.users[battleTag].characters.alive[username], uuid)

        db.characters = db.characters or {}

        local ev = {
            name      = username,
            level     = level,
            class     = class,
            race      = race,
            faction   = playerFaction,
            realm     = playerRealm,
            deathTimestamp = nil,
            achievements = {}
        }

        db.characters[uuid] = ev

        ev.uuid = uuid
        ev.type = "CHARACTER"
        HCT_Broadcaster:BroadcastEvent(ev)
    end
end

function _G.DAO.CharacterDao:MarkCharacterAsDead(battleTag, username, timestamp)
    local db = GetDB()

    if not db.users[battleTag].characters.alive[username] then
        -- TODO: request update from person who died
        return
    end
    
    db.users[battleTag].characters.dead[username] = db.users[battleTag].characters.dead[username] or {}
    for _, uuid in ipairs(db.users[battleTag].characters.alive[username]) do
        db.characters[uuid].deathTimestamp = timestamp
        table.insert(db.users[battleTag].characters.dead[username], uuid)
    end

    db.users[battleTag].characters.alive[username] = nil;
end

function _G.DAO.CharacterDao:UpdateCharacterLevel(level)
    local username = UnitName("player")
    local battleTag = HCT_DataModule:GetBattleTag()
    local uuid = GetDB().users[battleTag].characters[username]
    GetDB().characters[uuid].level = level
end

function _G.DAO.CharacterDao:UpdateCharacter(character)
    local uuid = character.uuid
    local db = GetDB()
    -- remove attributes not stored on character
    character.type = nil
    character.uuid = nil

    if not db.users[character.battleTag] then 
        _G.DAO.UserDao:InitializeUser(character.battleTag)
    end

    if not db.users[character.battleTag].characters.alive[character.username] then 
        self:CreateCharacter(character, uuid)
    end

end

function _G.DAO.CharacterDao:CreateCharacter(character, uuid)
    local db = GetDB()
    if character.deathTimestamp and not db.users[character.battleTag].characters.alive[character.username] then 
        db.users[character.battleTag].characters.alive[character.username] = {};
    end

    table.insert(db.users[character.battleTag].characters.alive[character.username], uuid)
    db.characters[uuid] = character
end
