if type(_G.SERVICE) ~= "table" then
    _G.SERVICE = {}
end
_G.SERVICE = _G.SERVICE or {}
_G.SERVICE.Achievement_Service = _G.SERVICE.Achievement_Service or {}
local function GetHCT() return _G.HCT_Env.GetAddon() end

function _G.SERVICE.Achievement_Service:RecalculateAchievements()
    _G.ACHIEVEMENTS.Achievement_Leveling.CheckAchievement()
end
