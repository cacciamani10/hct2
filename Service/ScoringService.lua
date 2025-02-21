if type(_G.SERVICE) ~= "table" then
    _G.SERVICE = {}
end
_G.SERVICE = _G.SERVICE or {}
_G.SERVICE.Scoring_Service = _G.SERVICE.Scoring_Service or {}


function _G.SERVICE.Scoring_Service:CalculateCharacterPoints(character)
    local points = {
        leveling = 0,
        professions = 0,
        bounties = 0,
        dungeons = 0
    }
    points.leveling = _G.ACHIEVEMENTS.Achievement_Leveling:GetTotalPoints(character) or 0
    points.professions = _G.ACHIEVEMENTS.Achievement_Professions:GetTotalPoints(character) or 0
    points.bounties = _G.ACHIEVEMENTS.Achievement_Bounties:GetTotalPoints(character) or 0
    points.dungeons = _G.ACHIEVEMENTS.Achievement_Dungeons:GetTotalPoints(character) or 0
    return points
end

function _G.SERVICE.Scoring_Service:CalculateContestData()
    local contestData = { team1 = 0, team2 = 0 }
    local users = _G.DAO.UserDao:GetAllUsers()
    local characters = _G.DAO.CharacterDao:GetCharacters()

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


