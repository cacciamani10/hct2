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
    BroadcastEvent = function(self, ev)
        local HCT = GetHCT()
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
        local HCT = GetHCT()
        local db = GetDB()
        if not HCT then return end
        HCT:Print("Bulking this shit up...")
        local broadCastTable = {}                                   -- Custom table for broadcasting.

        broadCastTable.users = db.users or {}                       -- Copy users table.
        broadCastTable.characters = db.characters or {}             -- Copy characters table.
        broadCastTable.completionLedger = db.completionLedger or {} -- Copy completionLedger table.

        local userCount = CountTable(broadCastTable.users)
        local charCount = CountTable(broadCastTable.characters)
        local ledgerCount = CountTable(broadCastTable.completionLedger)
        local totalCount = userCount + charCount + ledgerCount
        HCT:Print("BULKED USERS " ..
            userCount .. ": BULKED CHARS " .. charCount .. ": BULKED LEDGER " .. ledgerCount .. ": TOTAL " .. totalCount)
        local chunks = {}
        local chunkSize = 200
        -- User table into chunks
        for i = 1, #broadCastTable.users do
            local chunk = {}

            for j = i, math.min(i + chunkSize - 1, #broadCastTable.users) do
                table.insert(chunk, broadCastTable.users[j])
            end

            table.insert(chunks, broadCastTable.users)
        end

        -- Character table into chunks
        for i = 1, #broadCastTable.characters do
            local chunk = {}

            for j = i, math.min(i + chunkSize - 1, #broadCastTable.characters) do
                table.insert(chunk, broadCastTable.characters[j])
            end

            table.insert(chunks, broadCastTable.characters)
        end

        -- CompletionLedger table into chunks

        for i = 1, #broadCastTable.completionLedger do
            local chunk = {}

            for j = i, math.min(i + chunkSize - 1, #broadCastTable.completionLedger) do
                table.insert(chunk, broadCastTable.completionLedger[j])
            end

            table.insert(chunks, broadCastTable.completionLedger)
        end

    -- elseif msgType == "BULK_UPDATE" then
    --     Chunks_Remaining = payload.chunks
    
        -- Broadcast Length of Incoming Chunks to prevent desync
        local ev = {
            type = "BULK_UPDATE",
            payload = #chunks
        }
        local serialized = AceSerializer:Serialize(ev)
        HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")

        -- Broadcast each chunk
        for id, chunk in ipairs(chunks) do
            local ev = {
                type = "BULK_CHUNK",
                id = id,
                payload = chunk
            }
            local serialized = AceSerializer:Serialize(ev)
            HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")
        end

        HCT:Print("Bulk update complete.")
        
    end

}
