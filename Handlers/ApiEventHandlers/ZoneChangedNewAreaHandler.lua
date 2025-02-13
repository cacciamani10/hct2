_G.HCT_Handlers = _G.HCT_Handlers or {}

-- Fires when the player enters a zone.
_G.HCT_Handlers.ZoneChangedNewAreaHandler = {

    GetEventType = function() return "ZONE_CHANGED_NEW_AREA" end,

    GetHandlerName = function() return "ZoneChangedNewAreaHandler" end,

    HandleEvent = function(self, HCT, event)
        if not HCT then return end
        local subzone = GetSubZoneText()
        local zone = GetZoneText()
        local mapId = C_Map.GetBestMapForUnit("player")
        HCT:Print("ZoneChangedNewAreaHandler: Entered new area: " ..
        zone .. " - " .. subzone .. " (Map ID: " .. mapId .. ")")
    end,
}
