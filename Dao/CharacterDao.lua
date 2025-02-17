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
        local level = UnitLevel("player") or 1
        local class = select(2, UnitClass("player")) or "Unknown"
        local race = select(2, UnitRace("player")) or "Unknown"

        local uuid = _G.Utils.TimeUtils.CreateTimeBasedUUID()

        db.users[battleTag].characters.alive[username] = {};
        table.insert(db.users[battleTag].characters.alive[username], uuid)

        db.characters = db.characters or {}

        local character = {
            name      = username,
            level     = level,
            class     = class,
            race      = race,
            faction   = playerFaction,
            realm     = playerRealm,
            deathTimestamp = nil,
            achievements = {}
        }

        db.characters[uuid] = character

        local event = {
            type = "CHARACTER",
            uuid = uuid,
            character = character
        }
        HCT_Broadcaster:BroadcastEvent(event)
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
    local battleTag =  HCT_DataModule:GetBattleTag()
    local uuid = GetDB().users[battleTag].characters.alive[username]
    GetDB().characters[uuid].level = level
end

function _G.DAO.CharacterDao:AddAchievement(achievementId)
    local username = UnitName("player")
    local battleTag =  HCT_DataModule:GetBattleTag()
    local db = GetDB()
    
    local uuid = db.users[battleTag].characters.alive[username]

    if db.characters[uuid].achievements[achievementId] then
        return
    end

    db.characters[uuid].achievements[achievementId] = { timestamp = time() }
end

function _G.DAO.CharacterDao:AddBounty(achievementId)
    local username = UnitName("player")
    local battleTag =  HCT_DataModule:GetBattleTag()
    local db = GetDB()
    
    local uuid = db.users[battleTag].characters.alive[username]

    local currentCount = (db.characters[uuid].achievements[achievementId] and db.characters[uuid].achievements[achievementId].count) or 0
    db.characters[uuid].achievements[achievementId] = { timestamp = time(), count = currentCount + 1 }
end


function _G.DAO.CharacterDao:UpdateCharacter(uuid, character)
    local db = GetDB()

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

function _G.DAO.CharacterDao:GetCharacterBy_UUID(uuid)
    local db = GetDB()
    return db.characters[uuid]
end

function _G.DAO.CharacterDao:GetCharacterBy_BattleTag_Username(battleTag, username)
    local db = GetDB()
    return db.characters[db.users[battleTag].characters.alive[username]]
end

function _G.DAO.CharacterDao:GetCharacter()
    local db = GetDB()
    local username = UnitName("player")
    local battleTag = HCT_DataModule:GetBattleTag()
    return db.characters[db.users[battleTag].characters.alive[username]]
end
