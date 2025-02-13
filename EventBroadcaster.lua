local AceSerializer = LibStub("AceSerializer-3.0")

local function PrintTable(t, indent)
    indent = indent or 0
    local indentStr = string.rep("  ", indent)
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indentStr .. tostring(k) .. ":")
            PrintTable(v, indent + 1)
        else
            print(indentStr .. tostring(k) .. ": " .. tostring(v))
        end
    end
end

local function CountTable(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

_G.HCT_Broadcaster = {
    BroadcastEvent = function(ev)
        local HCT = _G.HCT_Env.GetAddon()
        if not HCT then return end

        HCT:Print("Broadcasting event: " .. ev.type)

        local serialized = AceSerializer:Serialize("EVENT", ev)
        if not serialized or serialized == "" then
            HCT:Print("Error: Serialized event is empty!")
            return
        end

        HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")
    end,

    RequestContestData = function()
        local HCT = _G.HCT_Env.GetAddon()
        local ev = {
            type = "REQUEST",
            payload = "request"
        }
        local serialized = AceSerializer:Serialize("REQUEST", ev)
        HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")
        HCT:Print("Requesting data update...")
    end,    

    BroadcastBulkEvents = function()
        local HCT = _G.HCT_Env.GetAddon()
        if not HCT then return end
        HCT:Print("Bulking this shit up...")
        local broadCastTable = {}  -- Custom table for broadcasting.
        
        broadCastTable.users = HCT.db.profile.users or {}         -- Copy users table.
        broadCastTable.characters = HCT.db.characters or {}         -- Copy characters table.
        broadCastTable.completionLedger = HCT.db.completionLedger or {} -- Copy completionLedger table.
        
        local userCount = CountTable(broadCastTable.users)
        local charCount = CountTable(broadCastTable.characters)
        local ledgerCount = CountTable(broadCastTable.completionLedger)
        local totalCount = userCount + charCount + ledgerCount
        
        if totalCount > 0 then
            local serializedBulk = AceSerializer:Serialize("BULK_UPDATE", broadCastTable)
            HCT:SendCommMessage(HCT.addonPrefix, serializedBulk, "GUILD")
            HCT:Print("Broadcasted bulk update of " .. totalCount .. " items.")
        end
    end
    
}
