_G.HCT_Handlers = _G.HCT_Handlers or {}

local function GetDB() return _G.HCT_Env.GetAddon().db.profile end

_G.HCT_Handlers.SpecialMobHandler = {
    GetEventType = function()
        return "COMBAT_LOG_EVENT_UNFILTERED"
    end,

    GetHandlerName = function()
        return "SpecialMobHandler"
    end,

    HandleEvent = function(self, HCT, event)
        local _, subEvent, _, _, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
        local db = GetDB()
        if subEvent == "PARTY_KILL" then
            --HCT:Print("SpecialMobHandler Party Kill: " .. subEvent .. ": " .. sourceName .. " killed " .. destName .. ".")
            local charKey = HCT_DataModule:GetCharacterKey()
            -- Check if the unit killed is in the list of dungeon bosses 
            db.localAchievementProgressData[charKey] = db.localAchievementProgressData[charKey] or {}
            db.localAchievementProgressData[charKey].dungeonBossKills = db.localAchievementProgressData[charKey].dungeonBossKills or {}
            if HCT_DataModule:IsDungeonBoss(destName) then
                --HCT:Print("SpecialMobHandler: Dungeon Boss Killed: " .. destName)
                db.localAchievementProgressData[charKey].dungeonBossKills[destName] = db.localAchievementProgressData[charKey].dungeonBossKills[destName] or 0
                db.localAchievementProgressData[charKey].dungeonBossKills[destName] = db.localAchievementProgressData[charKey].dungeonBossKills[destName] + 1
                -- Check if all players in your party are in your guild
                local allInGuild = true
                local myGuild = select(1, GetGuildInfo("player"))
                for i = 1, GetNumGroupMembers() do
                    local partyMemberName = UnitName("party" .. i)
                    if myGuild ~= select(1, GetGuildInfo(partyMemberName)) then
                            allInGuild = false
                        break
                    end
                end
                if allInGuild then
                    db.localAchievementProgressData[charKey].dungeonsClearedWithGroup = db.localAchievementProgressData[charKey].dungeonsClearedWithGroup or 0
                    db.localAchievementProgressData[charKey].dungeonsClearedWithGroup = db.localAchievementProgressData[charKey].dungeonsClearedWithGroup + 1
                end
                HCT_DataModule:CheckDungeonClearAchievements(charKey)
            end
        end
    end
}


-- elseif subEvent == "UNIT_DIED" then
        --     local unitType, npcID = strsplit("-", destGUID)
        --     local classification = UnitClassification(destName) or "normal" -- Default to normal if nil

        --     local validClassifications = {
        --         --normal = "Normal Mob",
        --         elite = "Elite Mob",
        --         rare = "Rare Mob",
        --         rareelite = "Rare Elite Mob",
        --         worldboss = "World Boss"
        --     }

        --     if validClassifications[classification] then
        --         local characterName = UnitName("player")
                
        --         local ev = {
        --             type = "SPECIAL_KILL",
        --             name = destName,
        --             classification = classification,
        --             characterName = characterName,
        --             timestamp = time()
        --         }
                
        --         -- Broadcast the event
        --         HCT_Broadcaster:BroadcastEvent(ev)
        --     end