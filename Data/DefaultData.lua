_G.DefaultData = {}

_G.DefaultData.defaults = {
    profile = {
        users = {},
        characters = {},
        teams = {
            [1] = HardcoreChallengeTracker_Teams[1],
            [2] = HardcoreChallengeTracker_Teams[2],
        }
    }
}

function DefaultData:GetOptions(handler)
    return {
        name = "Hardcore Challenge Tracker",
        handler = handler,
        type = "group",
        args = {
            displayOptions = {
                type = "group",
                name = "Display",
                args = {
                    showOnScreen = {
                        type = "toggle",
                        name = "Show on Screen",
                        desc = "Toggle on-screen notifications.",
                        get = function(info) return handler.db.profile.showOnScreen end,
                        set = function(info, value) handler.db.profile.showOnScreen = value end,
                    },
                },
            },
        }
    }
end
