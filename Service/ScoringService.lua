if type(_G.SERVICE) ~= "table" then
    _G.SERVICE = {}
end
_G.SERVICE = _G.SERVICE or {}
_G.SERVICE.Scoring_Service = _G.SERVICE.Scoring_Service or {}

function _G.SERVICE.Scoring_Service:CalculateContestData()
    local contestData = { team1 = 0, team2 = 0 }
    local users = _G.DAO.UserDao:GetAllUsers()
    local characters = _G.DAO.CharacterDao:GetCharacters()

    for userKey, userData in pairs(users) do
        local userPoints = 0

        for _, characterList in pairs(userData.characters.alive or {}) do
            for _, characterEntry in ipairs(characterList) do
                local characterData = characters[characterEntry.uuid]
                if characterData then
                    local points = self:CalculateCharacterPoints(characterData)
                    userPoints = userPoints + points
                    if userData.team == 1 then
                        contestData.team1 = contestData.team1 + points
                    elseif userData.team == 2 then
                        contestData.team2 = contestData.team2 + points
                    end
                end
            end
        end

        for _, characterList in pairs(userData.characters.dead or {}) do
            for _, characterEntry in ipairs(characterList) do
                local character = characters[characterEntry.uuid]
                if character then
                    local points = self:CalculateCharacterPoints(character)
                    userPoints = userPoints + points
                    if userData.team == 1 then
                        contestData.team1 = contestData.team1 + points
                    elseif userData.team == 2 then
                        contestData.team2 = contestData.team2 + points
                    end
                end
            end
        end

        contestData[userKey] = userPoints
    end

    return contestData
end

function _G.SERVICE.Scoring_Service:CalculateCharacterPoints(character)
    local total = 0
    local penaltyFactor = character.isDead and 0.5 or 1

    -- TODO loop through ACHIEVEMENTS and call GetTotalPoints
    _G.ACHIEVEMENTS.Achievement_Leveling:GetTotalPoints(character)
    _G.ACHIEVEMENTS.Achievement_Professions:GetTotalPoints(character)
    _G.ACHIEVEMENTS.Achievement_Bounties:GetTotalPoints(character)
    _G.ACHIEVEMENTS.Achievement_Dungeons:GetTotalPoints(character)

    return total * penaltyFactor
end
