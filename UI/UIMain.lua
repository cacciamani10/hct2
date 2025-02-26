if not _G.UI then
    _G.UI = {}
end

if not _G.UI.UIMain then
    _G.UI.UIMain = {}
end
local AceGUI = LibStub("AceGUI-3.0")
local guiFrame = nil
local isEnabled = false

local function GetHCT()
    return _G.HCT_Env.GetAddon()
end

local function GetDB()
    return _G.HCT_Env.GetAddon().db.profile
end

function _G.UI.UIMain:ToggleMainGUI()
    if not guiFrame then
        -- Create the frame if it doesn't exist
        guiFrame = AceGUI:Create("Frame")
        guiFrame:SetWidth(800)
        guiFrame:SetHeight(600)
        guiFrame:SetTitle("Hardcore Challenge Tracker")
        -- Calculate initial contest data.
        --_G.SERVICE.Scoring_Service:CalculateContestData()
        local statusText = "Neither team has scored yet."
        local db = GetDB()
        if db.teams[1].points and db.teams[2].points then
            local t1 = HCT_DataModule.calculatedData["team1"] or 0
            local t2 = HCT_DataModule.calculatedData["team2"] or 0
            if t1 > t2 then
                statusText = db.teams[1].name .. " are ahead!"
            elseif t2 > t1 then
                statusText = db.teams[2].name .. " are ahead!"
            elseif t1 == t2 and t1 > 0 then
                statusText = "It's neck and neck!"
            end
        end

        guiFrame:SetStatusText(statusText)
        guiFrame:SetLayout("Fill")
        guiFrame:SetCallback("OnClose", function(widget)
            AceGUI:Release(widget)
            GetHCT().teamChatContainer = nil
        end)

        local tabGroup = AceGUI:Create("TabGroup")
        tabGroup:SetLayout("Flow")
        tabGroup:SetTabs({
            { text = "Team Info",    value = "teamInfo" },
            { text = "Characters",   value = "characters" },
            { text = "Achievements", value = "achievements" },
            { text = "Bounties",     value = "bounties" },
            { text = "Feats",        value = "feats" },
            { text = "Tug of War",   value = "tugOfWar" },
            { text = "Team Chat",    value = "teamChat" },
            { text = "Rules",        value = "rules" },
            { text = "Admin",        value = "admin" },
        })

        tabGroup:SetCallback("OnGroupSelected", function(container, event, group)
            container:ReleaseChildren()
            if group == "teamInfo" then
                _G.UI.TeamInfoPage:DrawTeamInfo(container)
                guiFrame:SetStatusText(statusText)
            elseif group == "characters" then
                _G.UI.CharactersPage:DrawCharactersPage(container)
                guiFrame:SetStatusText("Characters are listed by team.")
            elseif group == "achievements" then
                _G.UI.AchievementsPage:DrawAchievementsPage(container)
                guiFrame:SetStatusText("Achievements are earnable once per character.")
            elseif group == "bounties" then
                _G.UI.BountiesPage:DrawBountiesPage(container)
                guiFrame:SetStatusText("Bounties are earnable an unlimited amount of times.")
            elseif group == "feats" then
                _G.UI.FeatsPage:DrawFeatsPage(container)
                guiFrame:SetStatusText("Feats are earnable only once in the contest.")
            elseif group == "tugOfWar" then
                _G.UI.TugOfWarPage:DrawTugOfWar(container)
                guiFrame:SetStatusText("Coming in Phase 2!")
            elseif group == "teamChat" then
                _G.UI.TeamChatPage:DrawTeamChat(container)
                local team = _G.Utils.GameUtils:GetPlayerTeam(_G.Utils.GameUtils:GetBattleTag()) or ""
                guiFrame:SetStatusText(team .. " Chat")
            elseif group == "rules" then
                _G.UI.RulesPage:DrawRules(container)
                guiFrame:SetStatusText("Rules of the contest.")
            elseif group == "admin" then
                _G.UI.AdminPage:DrawAdminPage(container)
                guiFrame:SetStatusText("Admin page.")
            else
                local placeholder = AceGUI:Create("Label")
                placeholder:SetFullWidth(true)
                placeholder:SetText("Content for the '" .. group .. "' tab coming soon!")
                container:AddChild(placeholder)
            end
        end)
        tabGroup:SelectTab("teamInfo")
        guiFrame:AddChild(tabGroup)
        guiFrame:SetCallback("OnClose", function(widget)
            AceGUI:Release(widget)
            guiFrame = nil
            isEnabled = false
        end)
    end

    -- Toggle the frame's visibility
    if isEnabled then
        guiFrame:Hide()
        isEnabled = false
    else
        guiFrame:Show()
        isEnabled = true
    end
end
