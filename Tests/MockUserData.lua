local MockUserData = {}

MockUserData.Alive = {
    team = 1,
    characters = {
        alive = {
            Alive = {{
                lastUpdated = 7777777777,
                uuid = "7777777777-77777"
            }}
        },
        dead = {}
    }
}

MockUserData.Dead = {
    team = 1,
    characters = {
        alive = {},
        dead = {
            Dead = {{
                lastUpdated = 6666666666,
                uuid = "6666666666-66666"
            }, {
                lastUpdated = 7777777777,
                uuid = "7777777777-77777"
            }}
        }
    }
}

MockUserData.Arsine = {
    team = 1,
    characters = {
        alive = {
            Arsine = {{
                lastUpdated = 1740454595,
                uuid = "1740251597-40915"
            }}
        },
        dead = {}
    }
}

MockUserData.EbonDrake = {
    team = 1,
    characters = {
        alive = {
            EbonDrake = {{
                lastUpdated = 1740545741,
                uuid = "1740251252-34960"
            }}
        },
        dead = {}
    }
}

MockUserData.PeterPiper = {
    team = 1,
    characters = {
        alive = {
            PeterPiper = {{
                lastUpdated = 1740544776,
                uuid = "1740456262-97952"
            }}
        },
        dead = {}
    }
}

MockUserData.ChineseEarthquake = {
    team = 2,
    characters = {
        alive = {
            ChineseEarthquake = {{
                lastUpdated = 1740454595,
                uuid = "1740251597-40916"
            }}
        },
        dead = {}
    }
}

MockUserData.DeadChineseEarthquake = {
    team = 2,
    characters = {
        alive = {},
        dead = {
            ChineseEarthquake = {{
                lastUpdated = 1740454595,
                uuid = "1740251597-40916"
            }}
        }
    }
}

MockUserData.HandHunter = {
    team = 2,
    characters = {
        alive = {
            HandHunter = {{
                lastUpdated = 1740545741,
                uuid = "1740251252-34960"
            }}
        },
        dead = {}
    }
}

MockUserData.CharacterChineseEarthquake = {
    ["1740251597-40916"] = {
        ["achievements"] = {
            [807] = {
                ["count"] = 1,
                ["timestamp"] = 1740251334
            }
        },
        ["race"] = "Dwarf",
        ["name"] = "ChineseEarthquake",
        ["faction"] = "Alliance",
        ["level"] = 10,
        ["class"] = "HUNTER",
        ["realm"] = "Doomhowl"
    }
}

MockUserData.CharacterArsine = {
    ["1740251597-40915"] = {
        ["achievements"] = {
            [807] = {
                ["count"] = 1,
                ["timestamp"] = 1740251334
            }
        },
        ["race"] = "Dwarf",
        ["name"] = "Arsine",
        ["faction"] = "Alliance",
        ["level"] = 5,
        ["class"] = "HUNTER",
        ["realm"] = "Doomhowl"
    }
}

MockUserData.LOCALDB = {
    users = {
        ["Arsine#0001"] = MockUserData.Arsine,
        ["EbonDrake#0002"] = MockUserData.EbonDrake,
        ["PeterPiper#0003"] = MockUserData.PeterPiper
    },
    characters = {
        ["1740251597-40915"] = {
            ["achievements"] = {
                [807] = {
                    ["count"] = 1,
                    ["timestamp"] = 1740251334
                }
            },
            ["race"] = "Dwarf",
            ["name"] = "Arsine",
            ["faction"] = "Alliance",
            ["level"] = 1,
            ["class"] = "HUNTER",
            ["realm"] = "Doomhowl"
        }
    }
}

MockUserData.SENDER_DATA = {
    updatedCharacters = {
        users = {
            ["ChineseEarthquake#0004"] = MockUserData.ChineseEarthquake,
            ["HandHunter#0005"] = MockUserData.HandHunter,
            ["EbonDrake#0002"] = MockUserData.EbonDrake
        },
        characters = {
            ["1740251597-40915"] = {
                ["achievements"] = {
                    [807] = {
                        ["count"] = 1,
                        ["timestamp"] = 1740251334
                    }
                },
                ["race"] = "Dwarf",
                ["name"] = "Arsine",
                ["faction"] = "Alliance",
                ["level"] = 1,
                ["class"] = "HUNTER",
                ["realm"] = "Doomhowl"
            }
        }
    }
}

return MockUserData
