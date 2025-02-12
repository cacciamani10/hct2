-- Set.lua 
local AchievementSet = {}
AchievementSet.__index = AchievementSet

function AchievementSet:New()
    local self = setmetatable({}, AchievementSet)
    self.items = {}  -- keys are uniqueID, values are achievement tables.
    return self
end

function AchievementSet:Add(achievement)
    if achievement and achievement.uniqueID then
        if not self.items[achievement.uniqueID] then
            self.items[achievement.uniqueID] = achievement
            return true  
        end
    end
    return false  
end

function AchievementSet:Remove(uniqueID)
    if self.items[uniqueID] then
        self.items[uniqueID] = nil
        return true
    end
    return false
end

function AchievementSet:ToArray()
    local arr = {}
    for uid, ach in pairs(self.items) do
        table.insert(arr, ach)
    end
    return arr
end

local AchievementSetLocal = AchievementSet
_G.AchievementSet = AchievementSetLocal
return AchievementSetLocal
