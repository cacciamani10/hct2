_G.HCT_Handlers = _G.HCT_Handlers or {}

local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

_G.HCT_Handlers.ChatMsgLootHandler = {
    GetEventType = function()
        return "CHAT_MSG_LOOT"
    end,

    GetHandlerName = function()
        return "ChatMsgLootHandler"
    end,

    HandleEvent = function(self, HCT, eventName, text)
        if HCT then
            local clothNames = {
                ["Linen Cloth"] = { 1, 20 },
                ["Wool Cloth"] = { 13, 30 },
                ["Silk Cloth"] = { 25, 40 },
                ["Mageweave Cloth"] = { 30, 50 },
                ["Runecloth"] = { 45, 60 },
                ["Felcloth"] = { 55, 60 }
            }
            local cleanedText = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|H.-|h", ""):gsub("|h|r", ""):gsub("%.$", "")
            local lootName, lootQuantityStr = string.match(cleanedText, "You receive loot: %[(.-)%]x?(%d*)")
            if lootName then
                local lootQuantity = tonumber(lootQuantityStr) or 1 -- Default to 1 if no quantity is found
                local charKey = _G.Utils.GameUtils:GetCharacterKey()
                local charLevel = UnitLevel("player")
                if clothNames[lootName] then
                    local minLevel, maxLevel = unpack(clothNames[lootName])
                    if charLevel >= minLevel and charLevel <= maxLevel then
                        local db = GetDB()
                        -- TODO count how many cloth recieved
                        _G.ACHIEVEMENTS.Achievement_Bounties:CheckAchievement(800, nil)
                        return
                    end
                end
            end
        end
    end
}
