_G.HCT_Handlers = _G.HCT_Handlers or {}

local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

local function ProcessNeedRoll(text, HCT)
    local cleanedText = text:gsub("|c%x%x%x%x%x%x%x%x", "")
                            :gsub("|H.-|h", "")
                            :gsub("|h|r", "")
                            :gsub("%.$", "")
    local rollStr = string.match(cleanedText, "rolls? (%d+).-%(need%)")
    if rollStr then
        local rollValue = tonumber(rollStr)
        if rollValue == 1 then
            HCT:Print("Roll Under Pressure achievement triggered!")
            _G.Dao.CharacterDao:AddLevelingAchievement(521)
        elseif rollValue == 100 then
            _G.Dao.CharacterDao:AddLevelingAchievement(520)
        end
    end
end

local function CheckRecievedRareLoot(text, HCT)
    local lootName, lootQuantityStr = string.match(text, "You receive loot: %[(.-)%]x?(%d*)")
    if lootName then
        local lootQuantity = tonumber(lootQuantityStr) or 1
        -- Check if the item is rare or better by looking for its color codes.
        if lootName:find("|cff0070dd") or lootName:find("|cffa335ee") or lootName:find("|cffff8000") then
            HCT:Print("Rare or better item looted: " .. lootName)
            _G.Dao.CharacterDao:AddBounty(803, loot)
        end
    end
end

_G.HCT_Handlers.ChatMsgLootHandler = {
    GetEventType = function()
        return "CHAT_MSG_LOOT"
    end,

    HandleEvent = function(self, HCT, eventName, text)
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
            local lootQuantity = tonumber(lootQuantityStr) or 1     -- Default to 1 if no quantity is found
            local charKey = _G.Utils.GameUtils:GetCharacterKey()
            local charLevel = UnitLevel("player")
            if clothNames[lootName] then
                local minLevel, maxLevel = unpack(clothNames[lootName])
                if charLevel >= minLevel and charLevel <= maxLevel then
                    local db = GetDB()
                    -- TODO verify this works
                    _G.Dao.CharacterDao:AddBounty(800, loot)
                    return
                end
            end
        end

        ProcessNeedRoll(text, HCT)
        CheckRecievedRareLoot(text, HCT)
    end
}
