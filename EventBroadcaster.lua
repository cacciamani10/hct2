local AceSerializer = LibStub("AceSerializer-3.0")

_G.HCT_Broadcaster = {
    BroadcastEvent = function(self, ev)
        local HCT = _G.HCT_Env.GetAddon()
        if not HCT then return end

        table.insert(HCT.db.profile.eventLog, ev)
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

        local currentTime = time()
        local bulkEvents = {}
        for _, ev in ipairs(HCT.db.profile.eventLog or {}) do
            if currentTime - ev.timestamp <= 3600 then
                table.insert(bulkEvents, ev)
            end
        end

        if #bulkEvents > 0 then
            local serializedBulk = AceSerializer:Serialize("EVENTDATA", { events = bulkEvents })
            HCT:SendCommMessage(HCT.addonPrefix, serializedBulk, "GUILD")
            HCT:Print("Broadcasted bulk event update (" .. #bulkEvents .. " events).")
        end
    end
}
