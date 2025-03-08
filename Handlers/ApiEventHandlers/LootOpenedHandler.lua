_G.HCT_Handlers = _G.HCT_Handlers or {}

_G.HCT_Handlers.LootOpenedHandler = {
    GetEventType = function() 
        return "LOOT_OPENED" 
    end,
    
    HandleEvent = function(self, HCT, event, autoLoot)
        print("getting loot")
        local guid = GetLootSourceInfo(1)
        
        if guid then
            local unitType = strsplit("-", guid)
            
            if unitType == "GameObject" then
                print("|cff00ff00You opened a treasure chest!|r")
                --_G.ACHIEVEMENTS.Achievement_Bounties:CheckAchievement(809)
            end
        end
    end
}
