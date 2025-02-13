local AceSerializer = LibStub("AceSerializer-3.0")

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

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
    lastBroadcastTime = 0,
    lastRequestTime = 0,
    BroadcastEvent = function(self, ev)
        local HCT = GetHCT()
        HCT:Print("QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ")
        local now = time()
        self.lastBroadcastTime = now
        
        if not HCT then return end

        HCT:Print("Broadcasting event: " .. ev.type)

        local serialized = AceSerializer:Serialize("EVENT", ev)
        if not serialized or serialized == "" then
            HCT:Print("Error: Serialized event is empty!")
            return
        end

        HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")
    end,

    RequestContestData = function(self)
        local now = time()
        if now - self.lastRequestTime < 180 then
            local remaining = 180 - (now - self.lastRequestTime)
            GetHCT():Print("RequestContestData is on cooldown. Please wait " .. remaining .. " seconds.")
            return
        end
        self.lastRequestTime = now

        local HCT = GetHCT()
        local ev = {
            type = "REQUEST",
            payload = "request"
        }
        local serialized = AceSerializer:Serialize("REQUEST", ev)
        HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")
        HCT:Print("Requesting data update...")
    end,

    BroadcastBulkEvents = function(self)
        local now = time()
        if now - self.lastBroadcastTime < 180 then
            local remaining = 180 - (now - self.lastBroadcastTime)
            GetHCT():Print("BroadcastEvent is on cooldown. Please wait " .. remaining .. " seconds.")
            return
        end
        local HCT = GetHCT()
        local db = GetDB()
        if not HCT then return end
        HCT:Print("Broadcasting bulk events...")

        local broadCastTable = {
            users = db.users or {},
            characters = db.characters or {},
            completionLedger = db.completionLedger or {}
        }

        local userCount = CountTable(broadCastTable.users)
        local charCount = CountTable(broadCastTable.characters)
        local ledgerCount = CountTable(broadCastTable.completionLedger)
        local totalCount = userCount + charCount + ledgerCount
        HCT:Print("BULKED USERS " .. userCount .. ": BULKED CHARS " .. charCount .. ": BULKED LEDGER " .. ledgerCount .. ": TOTAL " .. totalCount)

        -- Serialize the entire broadCastTable
        local serialized = AceSerializer:Serialize("BULK_UPDATE", broadCastTable)
        if not serialized or serialized == "" then
            HCT:Print("Error: Serialized bulk data is empty!")
            return
        end

        -- Send the serialized data
        HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")

        HCT:Print("Bulk update complete.")
    end
}