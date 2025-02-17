local AceSerializer = LibStub("AceSerializer-3.0")

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

local function CountTable(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

_G.HCT_Broadcaster = {

    BroadcastEvent = function(self, ev)
        -- local HCT = GetHCT()
        
        -- if not HCT then return end
        -- local serialized = AceSerializer:Serialize("EVENT", ev)
        -- if not serialized or serialized == "" then
        --     HCT:Print("Error: Serialized event is empty!")
        --     return
        -- end

        -- HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")
    end,

    RequestContestData = function()
        local HCT = GetHCT()
        local ev = {
            type = "REQUEST",
            payload = "request"
        }
        local serialized = AceSerializer:Serialize("REQUEST", ev)
        HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")
        --HCT:Print("Requesting data update...")
    end,

    BroadcastBulkEvents = function()
        local HCT = GetHCT()
        local db = GetDB()

        local database = {
            users = db.users or {},
            characters = db.characters or {},
        }

        local serialized = AceSerializer:Serialize("BULK_UPDATE", database)
        if not serialized or serialized == "" then
            HCT:Print("Error: Serialized bulk data is empty!")
            return
        end

        HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")
        --HCT:Print("Bulk update complete.")
    end
}