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
        local battleTag = HCT_DataModule:GetBattleTag()
        HCT:Print("sending sync request broadcast...")
    
        if not battleTag or not db.users[battleTag] then
            HCT:Print("Error: No user data found for request.")
            return
        end
    
        local userData = {
            users = {
                [battleTag] = db.users[battleTag]
            },
            characters = {}
        }
    
        for _, entry in ipairs(db.users[battleTag].characters.alive or {}) do
            userData.characters[entry.uuid] = db.characters[entry.uuid]
        end
        for _, entry in ipairs(db.users[battleTag].characters.dead or {}) do
            userData.characters[entry.uuid] = db.characters[entry.uuid]
        end
    
        local ev = {
            type = "SYNC_REQUEST",
            payload = userData
        }
    
        local serialized = AceSerializer:Serialize("SYNC_REQUEST", ev)
        HCT:SendCommMessage(HCT.addonPrefix, serialized, "GUILD")
    end,
}