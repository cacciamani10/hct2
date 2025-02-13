local AceSerializer = LibStub("AceSerializer-3.0")

_G.HCT_Broadcaster = {
    BroadcastEvent = function(self, ev)
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

    BroadcastBulkEvents = function(self)
        local HCT = _G.HCT_Env.GetAddon()
        if not HCT then return end

        local broadCastTable = {}                               -- Custom table for broadcasting.

        broadCastTable.users = HCT.db.profile.users or {}         -- Copy users table.
        broadCastTable.characters = HCT.db.characters or {}         -- Copy characters table.
        broadCastTable.completionLedger = HCT.db.completionLedger or {} -- Copy completionLedger table.

        if #broadCastTable > 0 then
            local serializedBulk = AceSerializer:Serialize("BULK_UPDATE", broadCastTable)
            HCT:SendCommMessage(HCT.addonPrefix, serializedBulk, "GUILD")
            HCT:Print("Broadcasted bulk update of " .. #broadCastTable .. " items.")
        end
    end
}
