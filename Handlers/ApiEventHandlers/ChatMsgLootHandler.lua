_G.HCT_Handlers = _G.HCT_Handlers or {}

local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

_G.HCT_Handlers.ChatMsgSkillHandler = {
    GetEventType = function()
        return "CHAT_MSG_LOOT"
    end,

    GetHandlerName = function()
        return "ChatMsgLootHandler"
    end,

    HandleEvent = function(self, HCT, eventName, text)
        if HCT then
            -- linen cloth is eligible from 1-20, wool cloth 16-30
            local clothNames = {
                ["Linen Cloth"] = { 1, 20 },
                ["Wool Cloth"] = { 13, 30 },
                ["Silk Cloth"] = { 25, 40 },
                ["Mageweave Cloth"] = { 30, 50 },
                ["Runecloth"] = { 45, 60 },
                ["Felcloth"] = { 55, 60 }
            }
            -- Remove hidden formatting codes
            local cleanedText = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|H.-|h", ""):gsub("|h|r", ""):gsub("%.$", "")
            -- Use string.match to capture the loot name and quantity.
            local lootName, lootQuantityStr = string.match(cleanedText, "You receive loot: %[(.-)%]x?(%d*)")
            if lootName then
                local lootQuantity = tonumber(lootQuantityStr) or 1 -- Default to 1 if no quantity is found
                HCT:Print("DEBUG: lootName = >" ..
                tostring(lootName) .. "<, lootQuantity = >" .. tostring(lootQuantity) .. "<")
                local charKey = HCT_DataModule:GetCharacterKey()
                local charLevel = UnitLevel("player")
                if clothNames[lootName] then
                    local minLevel, maxLevel = unpack(clothNames[lootName])
                    if charLevel >= minLevel and charLevel <= maxLevel then
                        local db = GetDB()
                        db.localAchievementProgressData[charKey] = db.localAchievementProgressData[charKey] or {}
                        db.localAchievementProgressData[charKey].clothCount = (GetDB().localAchievementProgressData[charKey].clothCount or 0) + lootQuantity
                        return 
                    end
                end
            else 
                HCT:Print("Invalid loot detected. " .. text)
            end
        end
    end
}