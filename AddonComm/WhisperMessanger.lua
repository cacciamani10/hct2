
local AceSerializer = LibStub("AceSerializer-3.0")

local function GetHCT() return _G.HCT_Env.GetAddon() end
local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

_G.WhisperMessenger = {
    WhisperMessenger = function(targetPlayer)
    local serialized = AceSerializer:Serialize("WHISPER", "Hello World!")
    if not serialized or serialized == "" then
        GetHCT():Print("Error: Serialized data is empty!")
        return
    end

    GetHCT():SendCommMessage(GetHCT().addonPrefix, serialized, "WHISPER", targetPlayer)
end
}
