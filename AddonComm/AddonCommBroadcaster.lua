local AceSerializer = LibStub("AceSerializer-3.0")

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

_G.HCT_Broadcaster = {
    BroadcastEvent = function(self, ev)
        local HCT = GetHCT()
        HCT:Print("sending event broadcast...")
        if not HCT then return end
        local serialized = AceSerializer:Serialize("EVENT", ev)
        if not serialized or serialized == "" then
            HCT:Print("Error: Serialized event is empty!")
            return
        end

        HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")
    end,

    SyncRequest = function()
        local HCT = GetHCT()
        local db = GetDB()
    
        if not db.users then
            HCT:Print("Error: No users found in the database.")
            return
        end
    
        local ev = {
            users = db.users
        }
    
        local serialized = AceSerializer:Serialize("SYNC_REQUEST", ev)
        HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")
    end
}