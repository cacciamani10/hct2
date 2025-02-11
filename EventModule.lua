local AceSerializer = LibStub("AceSerializer-3.0")
HCT_EventModule = {}

-- Table to keep track of processed event IDs.
HCT_EventModule.processedEventIDs = {}

local function GetDB()
    return HCT.db.profile
end

-- Helper function: compute a unique ID for an event.
local function ComputeEventID(ev)
    -- Use ev.type, ev.charKey (or ev.team if applicable), and ev.timestamp.
    local key = ev.charKey or ev.team or ""
    return ev.type .. ":" .. key .. ":" .. ev.timestamp
end

function HCT_EventModule:RegisterEvents(hctObj)
    if not hctObj then
        print("HCT_EventModule:RegisterEvents - hctObj is nil")
        return
    end     -- Ensure the module is properly initialized.
    hctObj:RegisterEvent("PLAYER_LEVEL_UP", "OnPlayerLevelUp")
    hctObj:RegisterEvent("PLAYER_DEAD", "OnPlayerDead")
    hctObj:RegisterEvent("COMBAT_LOG_EVENT", "OnCombatLogEvent") -- This event has only the user's combat log.
    --hctObj:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEventUnfiltered") -- This event has the entire guild's combat log.
    hctObj:RegisterEvent("GUILD_ROSTER_UPDATE", "OnGuildRosterUpdate")
    hctObj:RegisterEvent("CHAT_MSG_ADDON", "OnChatMsgAddon")
    hctObj:RegisterComm(ADDON_PREFIX, "OnCommReceived") -- Register for addon messages.
    self.owner = hctObj -- Store the owner object.
    self:RequestMissingEvents(hctObj) -- Request missing events from the guild.
    self:BroadcastBulkEvents(hctObj) -- Broadcast bulk events to the guild.
end

function HCT_EventModule:UnregisterEvents(hctObj)
    hctObj:UnregisterEvent("PLAYER_LEVEL_UP")
    hctObj:UnregisterEvent("PLAYER_DEAD")
    hctObj:UnregisterEvent("COMBAT_LOG_EVENT")
    hctObj:UnregisterEvent("GUILD_ROSTER_UPDATE")
    hctObj:UnregisterEvent("CHAT_MSG_ADDON")
    hctObj:UnregisterComm(ADDON_PREFIX)
    self.owner = nil -- Clear the owner object.
end

function HCT_EventModule:RequestMissingEvents(hctObj)
    local request = { since = GetDB().lastEventTimestamp or 0 }
    local serializedRequest = AceSerializer:Serialize("REQUEST", request)
    hctObj:SendCommMessage(ADDON_PREFIX, serializedRequest, "GUILD")
    hctObj:Print("Requested events since " .. (GetDB().lastEventTimestamp or 0))
end

-- Event handler for level up.
function HCT_EventModule:OnPlayerLevelUp(event, newLevel)
    newLevel = tonumber(newLevel)
    local charKey = UnitName("player")
    local charData = GetDB().characters[charKey]
    if charData then
        local oldLevel = tonumber(charData.level) or (newLevel - 1)
        local pointsAwarded = HCT_DataModule:GetLevelPoints(newLevel, oldLevel)
        charData.levelUpPoints = (charData.levelUpPoints or 0) + pointsAwarded
        charData.level = newLevel
        if self.owner then
            self.owner:Print("Level up! New level: " .. newLevel .. ". Awarded " .. pointsAwarded .. " level points.")
        end

        local battleTag = HCT_DataModule:GetBattleTag()
        local team = HCT_DataModule:GetPlayerTeam(battleTag)
        if team then
            -- Note: In this dynamic approach, team points may be computed on the fly,
            -- but if you want to update a stored field, do so here.
            GetDB().teams[team].points = (GetDB().teams[team].points or 0) + pointsAwarded
        end

        local ev = {
            type = "LEVELUP",
            charKey = charKey,
            newLevel = newLevel,
            pointsAwarded = pointsAwarded,
            timestamp = time()
        }
        HCT_EventModule:BroadcastEvent(ev)
    end
end

function HCT_EventModule:OnCombatLogEvent(event, ...)
    if not self.owner then return end -- Ensure the module is initialized.
    local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags,
          destGUID, destName, destFlags, amount, overkill, school, resisted, block, absorbed, critical, glancing, crushing, isOffHand = ...
    
    -- Example: Track damage dealt by the player.
    if subEvent == "SPELL_DAMAGE" or subEvent == "SWING_DAMAGE" then
        if sourceName == UnitName("player") then
            self.owner.db.char.totalDamageDealt = (self.owner.db.char.totalDamageDealt or 0) + (amount or 0)
        end

    -- Similarly for healing or other events.
    elseif subEvent == "SPELL_HEAL" then
        if sourceName == UnitName("player") then
            self.owner.db.char.totalHealingDone = (self.owner.db.char.totalHealingDone or 0) + (amount or 0)
        end

    -- Add more subEvent checks as needed.
    end
end


function HCT_EventModule:OnPlayerDead(event)
    local charKey = UnitName("player")
    local charData = GetDB().characters[charKey]
    if charData then
        charData.isDead = true
        charData.levelUpPoints = math.floor((charData.levelUpPoints or 0) / 2)
        charData.achievementPoints = math.floor((charData.achievementPoints or 0) / 2)
        charData.featPoints = math.floor((charData.featPoints or 0) / 2)
        if self.owner then
            self.owner:Print("You have died... but we go agane!")
        end
        local ev = {
            type = "DEATH",
            charKey = charKey,
            timestamp = time()
        }
        HCT_EventModule:BroadcastEvent(ev)
    end
end

function HCT_EventModule:OnGuildRosterUpdate(event)
    if self.owner then
        self.owner:Print("Guild roster updated.")
    end
end

local function PrintTable(t, indent)
    indent = indent or 0
    local indentStr = string.rep("  ", indent)
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indentStr .. tostring(k) .. ":")
            PrintTable(v, indent + 1)
        else
            print(indentStr .. tostring(k) .. ": " .. tostring(v))
        end
    end
end

function HCT_EventModule:OnChatMsgAddon(event, prefix, message, channel, sender)
    if prefix ~= ADDON_PREFIX then
        return
    end

    -- Filter out messages from ourselves.
    local myName = UnitName("player")
    -- (If sender includes realm information, you might want to strip that out using Ambiguate)
    if sender == myName or Ambiguate(sender, "none") == myName then
        return
    end
    
    if not self.owner then return end -- Ensure the module is properly initialized.
    local success, msgType, payload = AceSerializer:Deserialize(message)
    if success then
        print("Deserialized payload:")
        PrintTable(payload)
        if msgType == "EVENT" then
            self.owner:ProcessEvent(payload)
        elseif msgType == "REQUEST" then
            local since = payload.since or 0
            local eventsToSend = {}
            for _, ev in ipairs(GetDB().eventLog or {}) do
                if ev.timestamp > since then
                    table.insert(eventsToSend, ev)
                end
            end
            local serializedEvents = AceSerializer:Serialize("EVENTDATA", { events = eventsToSend })
            HCT:SendCommMessage(ADDON_PREFIX, serializedEvents, "GUILD")
        elseif msgType == "EVENTDATA" then
            for _, ev in ipairs(payload.events or {}) do
                self.owner:ProcessEvent(ev)
            end
        elseif msgType == "TEAMCHAT" then
            HCT_ChatModule:ProcessTeamChatMessage(payload)
        else
            self.owner:Print("Received unknown message type: " .. tostring(msgType) .. " from " .. sender)
        end
    else
        self.owner:Print("Failed to deserialize " .. tostring(msgType) .. " message from " .. sender)
    end
end

function HCT_EventModule:ProcessEvent(ev)
    if not self.owner then return end -- Ensure the module is properly initialized.
    local db = GetDB()
    local uniqueID = ComputeEventID(ev)
    self.processedEventIDs = self.processedEventIDs or {}
    if self.processedEventIDs[uniqueID] then
        return -- Already processed.
    end
    self.processedEventIDs[uniqueID] = true

    if ev.type == "LEVELUP" then
        local charKey = ev.charKey
        if db.characters[charKey] then
            db.characters[charKey].level = ev.newLevel
            db.characters[charKey].levelUpPoints = (db.characters[charKey].levelUpPoints or 0) + ev.pointsAwarded
            -- Update class info if present.
            if ev.class then
                db.characters[charKey].class = ev.class
            end
            self.owner:Print(charKey .. " has leveled up to " .. ev.newLevel .. ": Awarded " .. ev.pointsAwarded .. " level points.")
        end
    elseif ev.type == "DEATH" then
        local charKey = ev.charKey
        if db.characters[charKey] then
            db.characters[charKey].isDead = true
            self.owner:Print(charKey .. " has died.")
        end
    elseif ev.type == "ACHIEVEMENT" then
        local charKey = ev.charKey
        if db.characters[charKey] then
            db.characters[charKey].achievementPoints = (db.characters[charKey].achievementPoints or 0) + ev.pointsAwarded
            self.owner:Print(charKey .. " completed achievement '" .. ev.achievement .. "': Awarded " .. ev.pointsAwarded .. " points.")
        end
    elseif ev.type == "CHARACTER_INFO" then
        -- (Optional) Process a dedicated character info event.
        local charKey = ev.charKey
        if db.characters[charKey] then
            db.characters[charKey].class = ev.class
            db.characters[charKey].race = ev.race
            -- Add any additional fields you wish to propagate.
            self.owner:Print("Updated info for " .. charKey)
        end
    else
        self.owner:Print("Unknown event type: " .. tostring(ev.type))
    end
    if ev.timestamp and ev.timestamp > db.lastEventTimestamp then
        db.lastEventTimestamp = ev.timestamp
    end
end


function HCT_EventModule:BroadcastEvent(ev)
    table.insert(GetDB().eventLog, ev)
    local serialized = AceSerializer:Serialize("EVENT", ev)
    HCT:SendCommMessage(ADDON_PREFIX, serialized, "GUILD")
end

-- Backup: Broadcast Bulk Events
function HCT_EventModule:BroadcastBulkEvents(hctObj)
    if not hctObj then return end -- Ensure the module is properly initialized.

    local currentTime = time()
    local bulkEvents = {}
    for _, ev in ipairs(GetDB().eventLog or {}) do
        if currentTime - ev.timestamp <= 3600 then
            table.insert(bulkEvents, ev)
        end
    end
    if #bulkEvents > 0 then
        if not self.owner then return end -- Ensure the module is properly initialized.
        local serializedBulk = AceSerializer:Serialize("EVENTDATA", { events = bulkEvents })
        self.owner:SendCommMessage(ADDON_PREFIX, serializedBulk, "GUILD")
        hctObj:Print("Broadcasted bulk event update (" .. #bulkEvents .. " events).")
    end
end
