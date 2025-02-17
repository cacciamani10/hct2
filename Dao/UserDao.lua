if not _G.DAO then
    _G.DAO = {}
end

if not _G.DAO.UserDao then
    _G.DAO.UserDao = {}
end

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

function _G.DAO.UserDao:InitializeUser(battleTag)
    if not battleTag then
        GetHCT():Print("InitializeUser failed: No battle tag found.")
        return
    end

    self:InitializeUserTable(battleTag)
end

function _G.DAO.UserDao:InitializeUserTable(battleTag)
    local db = GetDB()
    local team = HCT_DataModule:GetPlayerTeam(battleTag) or 1

    if not db.users[battleTag] then
        db.users[battleTag] = {
            lastUpdated = time(),
            team = team,
            characters = {
                alive = {},
                dead = {},
            },
        }
    else
        local user = db.users[battleTag]
        user.team = user.team or team
        user.characters = user.characters or {}
        user.characters.alive = user.characters.alive or {}
        user.characters.dead = user.characters.dead or {}
    end
end

function _G.DAO.UserDao:AddCharacterUUID(battleTag, username, uuid, lastUpdated)
    local db = GetDB()

    if not db.users[battleTag] then
        self:InitializeUserTable(battleTag)
    end
     
    db.users[battleTag].characters.alive[username] = {}
    table.insert(db.users[battleTag].characters.alive[username], { uuid = uuid, lastUpdated = lastUpdated })
end
