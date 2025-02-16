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

        db.characters[uuid] = {
            name      = username,
            level     = level,
            class     = class,
            race      = race,
            faction   = playerFaction,
            realm     = playerRealm,
            deathTimestamp = nil,
            achievements = {}
        }

        -- local ev = {
        --     name      = username,
        --     level     = level,
        --     class     = class,
        --     race      = race,
        --     faction   = playerFaction,
        --     realm     = playerRealm,
        --     deathTimestamp = nil,
        --     achievements = {}
        -- }
        --HCT_Broadcaster:BroadcastEvent(ev)
    end
end

function _G.DAO.CharacterDao:MarkCharacterAsDead()
    local db = GetDB()
    local battleTag = HCT_DataModule:GetBattleTag()
    local username = UnitName("player")
    
    db.users[battleTag].characters.dead[username] = db.users[battleTag].characters.dead[username] or {}
    for _, uuid in ipairs(db.users[battleTag].characters.alive[username]) do
        db.characters[uuid].deathTimestamp = time()
        table.insert(db.users[battleTag].characters.dead[username], uuid)
    end

    db.users[battleTag].characters.alive[username] = nil;
end

function _G.DAO.CharacterDao:UpdateCharacterLevel(level)
        local username = UnitName("player")
        local battleTag = HCT_DataModule:GetBattleTag()
        local uuid = HCT.db.profile.characters.alive[username]

        if uuid then
            local character = HCT.db.profile.characters[uuid].level = newLevelNumber
        end
end
