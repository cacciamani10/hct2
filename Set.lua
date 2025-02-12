-- Set.lua 
local AchievementSet = {}
AchievementSet.__index = AchievementSet

-- (completionID = characterKey:achievementID)
-- [completionID] = { timestamp = timestamp }

function AchievementSet:New()
    local self = setmetatable({}, AchievementSet)
    self.items = {}  -- keys are completionID and values are timestamp
    return self
end

function AchievementSet:Add(completionID)
    if completionID then
        if not self.items[completionID] then
            self.items[completionID] = time()
            return true  
        end
    end
    return false  
end

function AchievementSet:Remove(completionID)
    if self.items[completionID] then
        self.items[completionID] = nil
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
