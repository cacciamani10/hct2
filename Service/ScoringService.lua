_G.Service = _G.Service or {}
_G.Service.Scoring_Service = _G.Service.Scoring_Service or {}


function _G.Service.Scoring_Service:CalculateCharacterPoints(character)
    local points = {
        leveling = 0,
        professions = 0,
        bounties = 0,
        dungeons = 0
    }
    points.leveling = _G.Service.Scoring_Service:GetPoints(character, "Level Checkpoints") or 0
    points.professions = _G.Service.Scoring_Service:GetPoints(character, "Profession Mastery") or 0
    points.dungeons = _G.Service.Scoring_Service:GetPoints(character, "Dungeon Clears") or 0
    points.bounties = _G.Service.Scoring_Service:GetPoints(character, "Bounties") or 0
    points.feats = _G.Service.Scoring_Service:GetPoints(character, "Feats") or 0
    return points
end

function _G.Service.Scoring_Service:GetPoints(character, achievementType)
    local achievements = HardcoreChallengeTracker_Data.achievements[achievementType]
    if not achievements or not character.achievements then
        return 0
    end

    local totalPoints = 0

    for _, achievement in ipairs(achievements) do
        if character.achievements[achievement.uniqueID] then
            if (achievementType == "bounties") then
                local bountyCount = tonumber(character.achievements[achievement.uniqueID].count) or 0
                local metNumber = math.floor(bountyCount/achievement.required)
                totalPoints = totalPoints + ((achievement.points * metNumber) or 0)
            else
                totalPoints = totalPoints + (achievement.points or 0)
            end
        end
    end

    return totalPoints
end

function _G.Service.Scoring_Service:CalculateContestData()
    local contestData = { team1 = 0, team2 = 0 }
    local users = _G.Dao.UserDao:GetAllUsers()
    local characters = _G.Dao.CharacterDao:GetCharacters()

    for battleTag, userData in pairs(users) do
        local userPoints = 0
        for username, characterList in pairs(userData.characters.alive or {}) do
            for _, characterEntry in ipairs(characterList) do
                local character = characters[characterEntry.uuid]
                if character then
                    local points = self:CalculateCharacterPoints(character)
                    local totalPoints = points.leveling + points.professions + points.bounties + points.dungeons
                    userPoints = userPoints + totalPoints
                    if userData.team == 1 then
                        contestData.team1 = contestData.team1 + totalPoints
                    elseif userData.team == 2 then
                        contestData.team2 = contestData.team2 + totalPoints
                    end
                end
            end
        end

        for _, characterList in pairs(userData.characters.dead or {}) do
            for _, characterEntry in ipairs(characterList) do
                local character = characters[characterEntry.uuid]
                if character then
                    local points = self:CalculateCharacterPoints(character)
                    local totalPoints = points.leveling + points.professions + points.bounties + points.dungeons
                    userPoints = userPoints + (totalPoints * .5)
                    if userData.team == 1 then
                        contestData.team1 = contestData.team1 + totalPoints
                    elseif userData.team == 2 then
                        contestData.team2 = contestData.team2 + totalPoints
                    end
                end
            end
        end

        contestData[battleTag] = userPoints
    end
    return contestData
end


