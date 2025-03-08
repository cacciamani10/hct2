describe("SyncService Unit Tests", function()
    local sender = "TestSender"
    local match = require("luassert.match")
    before_each(function()
        CharacterStatus = require("CharacterStatus")
        MockUserData = require("Tests.MockUserData")
        Service = require("Service.SyncService")

        _G.Dao = {
            UserDao = require("Dao.UserDao"),
            CharacterDao = require("Dao.CharacterDao")
        }

        _G.Service = {
            Event_Service = {
                WhisperEvent = function(eventType, event, player) end
            }
        }

        _G.CharacterStatus = CharacterStatus

        MockCharacterDao = mock(_G.Dao.CharacterDao, true)
        MockUserDao = mock(_G.Dao.UserDao, true)
        MockEventService = mock(_G.Service.Event_Service, true)
    end)

    after_each(function()
        mock.revert(MockUserDao)
        mock.revert(MockCharacterDao)
    end)

    describe("localCharacterMatchesSenderByUUID", function()
        it("should find alive character", function()
            local found = Service:localCharacterMatchesSenderByUUID(MockUserData.Alive, CharacterStatus.ALIVE, "Alive", "7777777777-77777")
            assert.True(found)
        end)

        it("should not find alive character when dead", function()
            local found = Service:localCharacterMatchesSenderByUUID(MockUserData.Dead, CharacterStatus.ALIVE, "Alive", "7777777777-77777")
            assert.False(found)
        end)

        it("should find dead character when dead", function()
            local found = Service:localCharacterMatchesSenderByUUID(MockUserData.Dead, CharacterStatus.DEAD, "Dead", "6666666666-66666")
            assert.True(found)
        end)

        it("should not find dead character when alive", function()
            local found = Service:localCharacterMatchesSenderByUUID(MockUserData.Alive, CharacterStatus.DEAD, "Dead", "6666666666-66666")
            assert.False(found)
        end)
    end)

    describe("UpdateLocalCharacter", function()
        it("should update matching alive local character", function()
            stub(MockUserDao, "CharacterExists").returns(true)
            stub(MockUserDao, "UpdateCharacter").returns(true)

            local characters = { MockUserData.CharacterChineseEarthquake }
            Service:UpdateLocalCharacter(MockUserData.ChineseEarthquake, characters, "ChineseEarthquake#0004", CharacterStatus.ALIVE)

            assert.stub(MockUserDao.UpdateCharacter).was.called()
            assert.stub(MockUserDao.CharacterExists).was.called()
            assert.stub(MockUserDao.AddCharacter).was.not_called()
            assert.stub(MockUserDao.UpdateCorrelatedCharacter).was.not_called()
            assert.stub(MockCharacterDao.UpsertCharacter).was.called()
        end)

        it("should update matching dead local character", function()
            stub(MockUserDao, "CharacterExists").returns(true)
            stub(MockUserDao, "UpdateCharacter").returns(true)
            local characters = { MockUserData.CharacterChineseEarthquake }
            local user = MockUserData.DeadChineseEarthquake
            Service:UpdateLocalCharacter(user, characters, "ChineseEarthquake#0004", CharacterStatus.DEAD)

            assert.stub(MockUserDao.UpdateCharacter).was.called()
            assert.stub(MockUserDao.CharacterExists).was.called()
            assert.stub(MockUserDao.AddCharacter).was.not_called()
            assert.stub(MockUserDao.UpdateCorrelatedCharacter).was.not_called()
            assert.stub(MockCharacterDao.UpsertCharacter).was.called()
        end)

        it("should correlate existing user", function()
            stub(MockUserDao, "CharacterExists").returns(true)
            stub(MockUserDao, "UpdateCharacter").returns(false)
            local characters = { MockUserData.CharacterChineseEarthquake }
            Service:UpdateLocalCharacter(MockUserData.ChineseEarthquake, characters, "ChineseEarthquake#0004", CharacterStatus.ALIVE)

            assert.stub(MockUserDao.CharacterExists).was.called()
            assert.stub(MockUserDao.AddCharacter).was.not_called()
            assert.stub(MockUserDao.UpdateCorrelatedCharacter).was.called()
            assert.stub(MockCharacterDao.UpsertCharacter).was.called()
        end)

        it("should add alive character", function()
            stub(MockUserDao, "CharacterExists").returns(false)
            local characters = { MockUserData.CharacterChineseEarthquake }
            Service:UpdateLocalCharacter(MockUserData.ChineseEarthquake, characters, "ChineseEarthquake#0004", CharacterStatus.ALIVE)

            assert.stub(MockUserDao.CharacterExists).was.called()
            assert.stub(MockUserDao.AddCharacter).was.called()
            assert.stub(MockUserDao.UpdateCorrelatedCharacter).was.not_called()
            assert.stub(MockCharacterDao.UpsertCharacter).was.called()
        end)

        it("should add dead character", function()
            local user = MockUserData.DeadChineseEarthquake
            local characters = { MockUserData.CharacterChineseEarthquake }
            stub(MockUserDao, "CharacterExists").returns(false)
            
            Service:UpdateLocalCharacter(user, characters, "ChineseEarthquake#0004", CharacterStatus.DEAD)

            assert.stub(MockUserDao.CharacterExists).was.called()
            assert.stub(MockUserDao.AddCharacter).was.called()
            assert.stub(MockUserDao.UpdateCorrelatedCharacter).was.not_called()
            assert.stub(MockCharacterDao.UpsertCharacter).was.called()
        end)
    end)

    describe("UpdateLocalUser", function()
        it("no update when payload missing", function()
            Service:UpdateLocalUser(nil)
            assert.stub(MockUserDao.CreateUserWithData).was.not_called()
        end)

        it("no update when updatedCharacters missing", function()
            Service:UpdateLocalUser({})
            assert.stub(MockUserDao.CreateUserWithData).was.not_called()
        end)

        it("no update when users missing", function()
            Service:UpdateLocalUser({updatedCharacters = {}})
            assert.stub(MockUserDao.CreateUserWithData).was.not_called()
        end)

        it("updates successfully", function()
            Service:UpdateLocalUser(MockUserData.SENDER_DATA)
            assert.stub(MockUserDao.CreateUserWithData).was.called(3)
        end)
    end)

    describe("ProcessSyncFinal", function()
        it("no update when payload missing", function()
            stub(MockUserDao, "CreateUserWithData")
            Service:ProcessSyncFinal(MockUserData.SENDER_DATA)
            assert.stub(MockUserDao.CreateUserWithData).was.called(3)
        end)
    end)

    describe("ProcessSyncUpdate", function()
        it("should do nothing when payload is nil", function()
            Service:ProcessSyncUpdate(nil)
            assert.stub(MockUserDao.RetrieveUserData).was.not_called()
            assert.stub(MockEventService.WhisperEvent).was.not_called()
        end)
        
        it("should do nothing when payload is empty", function()
            Service:ProcessSyncUpdate({})
            assert.stub(MockUserDao.RetrieveUserData).was.not_called()
            assert.stub(MockEventService.WhisperEvent).was.not_called()
        end)

        it("should call UpdateLocalUser but not WhisperEvent when requestedCharacters missing", function()
            local payload = {
                updatedCharacters = {}
            }
            Service:ProcessSyncUpdate(payload, sender)
            assert.stub(MockEventService.WhisperEvent).was.not_called()
        end)
        
        it("should not retrieve user data when PlayerExists returns false", function()
            local payload = {
                updatedCharacters = {},
                requestedCharacters = {
                    users = { ["NonExistentBattleTag"] = {} }
                }
            }
            stub(MockUserDao, "PlayerExists").returns(false)
            Service:ProcessSyncUpdate(payload, sender)
            
            assert.stub(MockUserDao.PlayerExists).was.called_with("NonExistentBattleTag")
            assert.stub(MockUserDao.RetrieveUserData).was.not_called()
            assert.stub(MockEventService.WhisperEvent).was.not_called()
        end)
        
        it("should process update when requestedCharacters provided and PlayerExists returns true", function()
            local payload = {
                updatedCharacters = {},
                requestedCharacters = {
                    users = { ["SomeBattleTag"] = {} }
                }
            }
            stub(MockUserDao, "PlayerExists").returns(true)
            stub(MockUserDao, "GetTimestamp").returns(123456)
            stub(MockUserDao, "GetTeam").returns("TeamA")
            
            Service:ProcessSyncUpdate(payload, sender)
            
            assert.stub(MockUserDao.PlayerExists).was.called_with("SomeBattleTag")
            assert.stub(MockUserDao.RetrieveUserData).was.called(2)
            assert.stub(MockEventService.WhisperEvent).was.called()
        end)
    end)

    describe("ProcessSyncRequest", function()
        it("should do nothing if payload is nil", function()
            Service:ProcessSyncRequest(nil, "TestSender")
            assert.stub(MockEventService.WhisperEvent).was.not_called()
        end)
    
        it("should do nothing if payload.users is missing", function()
            Service:ProcessSyncRequest({}, "TestSender")
            assert.stub(MockEventService.WhisperEvent).was.not_called()
        end)
    
        it("should process request when local user data is missing", function()
            local payload = {
                users = {
                    ["BattleTag1"] = { data = "senderData" }
                }
            }
            stub(MockUserDao, "GetUser").returns(nil)
    
            Service:ProcessSyncRequest(payload, "TestSender")
    
            assert.stub(MockEventService.WhisperEvent).was.called()
    
            assert.stub(MockUserDao.SyncUsersData).was.not_called()
            assert.stub(MockUserDao.SyncCharactersSenderIsMissing).was.not_called()
        end)
    
        it("should process request when local user data exists", function()
            local payload = {
                users = {
                    ["BattleTag2"] = { senderData = "value" }
                }
            }
            local localUserData = { localData = "exists" }
            stub(MockUserDao, "GetUser").returns(localUserData)
    
            Service:ProcessSyncRequest(payload, "TestSender")
    
            assert.stub(MockUserDao.SyncUsersData).was.called(2)
            assert.stub(MockUserDao.SyncCharactersSenderIsMissing).was.called(2)
            assert.stub(MockEventService.WhisperEvent).was.called()
        end)
    end)
end)
