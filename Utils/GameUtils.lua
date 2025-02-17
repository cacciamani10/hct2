if not _G.Utils then
    _G.Utils = {}
end
-- this could be broken up or renamed. This is the former DataModule
if not _G.Utils.GameUtils then
    _G.Utils.GameUtils = {}
end

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

function _G.Utils.GameUtils:GetBattleTag()
    local info = select(2, BNGetInfo())
    return info and info:match("^(%S+#%S+)") or "unknown"
end

function _G.Utils.GameUtils:GetCharacterKey()
    local name = UnitName("player") .. ":" .. _G.Utils.GameUtils:GetBattleTag()
    return name or "unknown"
end

function _G.Utils.GameUtils:GetPlayerTeam(player)
    local teams = GetDB().teams
    for i, team in ipairs(teams) do
        for _, name in ipairs(team.battleTags) do
            if name == player then
                return i
            end
        end
    end
    return nil
end

function _G.Utils.GameUtils.NormalizeColor(color)
    if color.r <= 1 and color.g <= 1 and color.b <= 1 then
        return { r = math.floor(color.r * 255), g = math.floor(color.g * 255), b = math.floor(color.b * 255) }
    else
        return color
    end
end
