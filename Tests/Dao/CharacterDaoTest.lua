luaunit = require('luaunit')
dao = require('Dao.CharacterDao')

_G.Dao = _G.Dao or {}
_G.Dao.CharacterDao = _G.Dao.CharacterDao or {}

local mockDb = {
    users = { ["tag#123"] = { characters = { alive = {}, dead = {} } } },
    characters = {}
  }
  
  _G.HCT_Env = {
    GetAddon = function()
      return { db = { profile = mockDb } }
    end
  }

local function resetDb()
  return {
    users = {
      ["tag#123"] = {
        characters = {
          alive = { ["user1"] = { { uuid = "uuid1" } } },
          dead = {}
        }
      }
    },
    characters = { ["uuid1"] = {} }
  }
end

TestCharacterDao = {}

function TestCharacterDao:testMarkCharacterAsDeadExists()
  
  local db = resetDb()
  _G.Dao.CharacterDao:MarkCharacterAsDead("tag#123", "user1", 123456789)
  luaunit.assertEquals(db.characters["uuid1"].deathTimestamp, 123456789)
  luaunit.assertNil(db.users["tag#123"].characters.alive["user1"])
  local dead = db.users["tag#123"].characters.dead["user1"]
  luaunit.assertNotNil(dead)
  luaunit.assertEquals(#dead, 1)
  luaunit.assertEquals(dead[1].uuid, "uuid1")
  luaunit.assertEquals(dead[1].lastUpdated, 123456789)
end

function TestCharacterDao:testMarkCharacterAsDeadNoEntry()
  local db = resetDb()
  _G.Dao.CharacterDao:MarkCharacterAsDead("tag#123", "user2", 987654321)
  luaunit.assertNil(db.users["tag#123"].characters.dead["user2"])
end



os.exit( luaunit.LuaUnit.run() )