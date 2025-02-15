_G.HCT_Handlers = _G.HCT_Handlers or {}

local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

-- Fires when the player enters a zone.
_G.HCT_Handlers.ZoneChangedNewAreaHandler = {

    GetEventType = function() return "ZONE_CHANGED_NEW_AREA" end,

    GetHandlerName = function() return "ZoneChangedNewAreaHandler" end,

    HandleEvent = function(self, HCT, event)
        if not HCT then return end
        C_Timer.After(0.5, function()
            local subzone = GetSubZoneText()
            local zone = GetZoneText()
            local mapId = C_Map.GetBestMapForUnit("player")
            local mapInfo = mapId and C_Map.GetMapInfo(mapId)
            local mapName = mapInfo and mapInfo.name or "Unknown"
            --HCT:Print("ZoneChangedNewAreaHandler: Entered new area: " .. zone .. " - " .. subzone .. " - " .. mapName)
            local db = GetDB()
            db.localAchievementProgressData = db.localAchievementProgressData or {}
            local charKey = HCT_DataModule:GetCharacterKey()
            db.localAchievementProgressData[charKey] = db.localAchievementProgressData[charKey] or {}
            db.localAchievementProgressData[charKey].zonesVisited = db.localAchievementProgressData[charKey].zonesVisited or {}
            db.localAchievementProgressData[charKey].zonesVisited[zone] = db.localAchievementProgressData[charKey].zonesVisited[zone] or {}
            if not db.localAchievementProgressData[charKey].zonesVisited[zone][subzone] then
                HCT:Print("New zone discovered: " .. zone .. " - " .. subzone)
                db.localAchievementProgressData[charKey].zonesVisited[zone][subzone] = true
            end
        end)
    end,
}
