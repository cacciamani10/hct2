_G.HCT_Env = _G.HCT_Env or {}

HCT_Env.GetAddon = function()
    if not HCT_Env.HCT then
        error("Addon not initialized.")
    end
    return HCT_Env.HCT
end

HCT_Env.InitializeAddon = function(addon)
    HCT_Env.HCT = addon
end
