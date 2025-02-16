if not _G.Utils then
    _G.Utils = {}
end

if not _G.Utils.TimeUtils then
    _G.Utils.TimeUtils = {}
end

function _G.Utils.TimeUtils:CreateTimeBasedUUID()
    local now = time()
    local rand = math.random(10000, 99999)
    return string.format("%d-%d", now, rand)
end
