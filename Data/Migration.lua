local function MigrateDatabase()
    -- Check if the old schema exists
    if HardcoreChallengeTracker2DB then
        -- Initialize the new schema if it doesn't exist
        HardcoreChallengeTrackerDB = HardcoreChallengeTrackerDB or {
            ["profileKeys"] = {},
            ["profiles"] = {},
        }

        -- Iterate over the old schema and migrate data
        for profileKey, profileData in pairs(HardcoreChallengeTracker2DB.profiles) do
            -- Initialize the new profile in the new schema
            HardcoreChallengeTrackerDB.profiles[profileKey] = HardcoreChallengeTrackerDB.profiles[profileKey] or {
                ["characters"] = {},
                ["users"] = {},
                ["localAchievementProgressData"] = {},
            }

            -- Migrate characters
            for characterKey, characterData in pairs(profileData.characters) do
                local newCharacterKey = characterData.name .. ":" .. characterData.realm
                HardcoreChallengeTrackerDB.profiles[profileKey].characters[newCharacterKey] = {
                    ["achievements"] = {}, -- Initialize achievements (you can map old achievements here if needed)
                    ["race"] = characterData.race,
                    ["name"] = characterData.name,
                    ["faction"] = characterData.faction,
                    ["level"] = characterData.level,
                    ["class"] = characterData.class,
                    ["realm"] = characterData.realm,
                }
            end

            -- Migrate users
            for userKey, userData in pairs(profileData.users) do
                HardcoreChallengeTrackerDB.profiles[profileKey].users[userKey] = {
                    ["team"] = userData.team,
                    ["characters"] = {
                        ["alive"] = {},
                        ["dead"] = {},
                    },
                }

                -- Migrate alive and dead characters
                for _, characterKey in ipairs(userData.characterKeys) do
                    local characterData = profileData.characters[characterKey]
                    if characterData then
                        local status = characterData.isDead and "dead" or "alive"
                        local newCharacterKey = characterData.name .. ":" .. characterData.realm
                        HardcoreChallengeTrackerDB.profiles[profileKey].users[userKey].characters[status][characterData.name] = {
                            {
                                ["lastUpdated"] = os.time(), -- Use current time or map from old data if available
                                ["uuid"] = newCharacterKey, -- Generate a unique UUID or use existing data
                            },
                        }
                    end
                end
            end

            -- Migrate local achievement progress data
            for characterKey, progressData in pairs(profileData.localAchievementProgressData) do
                local newCharacterKey = profileData.characters[characterKey].name .. ":" .. profileData.characters[characterKey].realm
                HardcoreChallengeTrackerDB.profiles[profileKey].localAchievementProgressData[newCharacterKey] = progressData
            end
        end

        -- Clean up the old schema
        HardcoreChallengeTracker2DB = nil
    end
end