if not _G.DAO then
    _G.DAO = {}
end

if not _G.DAO.UserDao then
    _G.DAO.UserDao = {}
end

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

function _G.DAO.UserDao:InitializeUser()
    local db = GetDB()
    local battleTag = HCT_DataModule:GetBattleTag()
    local team = HCT_DataModule:GetPlayerTeam(battleTag) or 1

    if not battleTag then
        GetHCT():Print("InitializeUser failed: No battle tag found.")
        return
    end

    GetHCT():Print("UsersDao.lua")
    if not db.users[battleTag] then
        db.users[battleTag] = {
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

