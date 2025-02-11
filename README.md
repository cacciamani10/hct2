# Hardcore Challenge Tracker 2

## Overview
Hardcore Challenge Tracker 2 is a World of Warcraft addon designed for a contest on WoW Classic Hardcore. In this contest, players are split into two teams and earn points by:
- Leveling up
- Competing in team tug-of-war events
- Completing achievements
- Completing feats (renamed from "bounties" to avoid confusion)
- Completing additional tasks (such as special achievements)

**Contest Rules:**
- All players must be on the same official hardcore server (as of 2024, these servers enforce a no-resurrection rule).
- If a player dies, points earned from leveling, achievements, and feats are halved (truncated).
- Tug-of-war points and feats remain unchanged upon death.
- All players are on the same faction and guild but are split into two teams.

## Features
- **Level Tracking:** Points are awarded based on level milestones (1–20: 1 pt per level, 21–40: 2 pts, 41–60: 3 pts).
- **Achievements & Feats:** Completion of achievements and feats award bonus points.
- **Team Tug-of-War:** Special events where teams compete for additional points.
- **Real-Time Communication:** Uses AceComm to broadcast events so that every team member gets updated with other characters’ progress.
- **UI Display:** An in-game GUI (built with AceGUI) shows team info, character stats, achievements, and chat logs.

## File Organization
The addon is organized into several Lua modules to separate concerns:

- **Core.lua:**  
  - The entry point for the addon.
  - Initializes AceDB (data persistence) using AceDB-3.0.
  - Registers AceConfig options (with AceConfig-3.0, AceConfigDialog-3.0, and AceDBOptions-3.0) for in-game configuration.
  - Sets up the AceAddon event system (via AceEvent-3.0) and registers chat commands.
  - Sets the owner for the EventModule.

- **DataModule.lua:**  
  - Manages all data operations, including:
    - Accessing and updating character and team data stored in AceDB.
    - Handling achievement logic (e.g., awarding level milestones and achievements).
    - Propagating character metadata (such as level, class, and race).
  - Uses helper functions to retrieve the AceDB profile (via `HCT.db.profile`).

- **EventModule.lua:**  
  - Registers for game events (e.g., `PLAYER_LEVEL_UP`, `PLAYER_DEAD`, `COMBAT_LOG_EVENT`, `CHAT_MSG_ADDON`, etc.).
  - Processes incoming events and broadcasts them to other players using AceComm-3.0.
  - Implements deduplication of events and updates the AceDB stored eventLog.
  - Provides additional event handlers (e.g., for combat log events to track damage and healing).

- **UIModule.lua:**  
  - Constructs the graphical user interface (GUI) using AceGUI-3.0.
  - Displays team information, character stats, achievements, and a chat panel.
  - Aggregates data from AceDB to create real-time visual updates for players.

- **ChatModule.lua (if applicable):**  
  - Handles team chat messages.
  - Sends and receives team chat messages through AceComm-3.0.
  - Integrates with the UI so players can communicate within the addon.

## Ace3 Libraries and Data Flow
The addon leverages [the Ace3 framework](https://www.wowace.com/projects/ace3/pages/getting-started) to simplify development and ensure consistency:
- **AceAddon-3.0:** Provides the base addon object and modular architecture.
- **AceEvent-3.0:** Manages event registration and dispatch, allowing the addon to respond to WoW API events.
- **AceConsole-3.0:** Offers easy-to-use chat command support.
- **AceTimer-3.0:** Enables scheduled and repeating timers for tasks like periodic event broadcasts.
- **AceSerializer-3.0:** Serializes and deserializes data for communication between players.
- **AceComm-3.0:** Handles addon messaging over chat channels, allowing for real-time synchronization.
- **AceDB-3.0:** Provides a robust saved variables system with support for profiles.
- **AceConfig-3.0 & AceConfigDialog-3.0:** Build in-game configuration panels.
- **AceDBOptions-3.0:** Automatically creates profile management options for your addon.

**Data Flow Overview:**
1. **Initialization:**  
   When the addon loads, Core.lua initializes AceDB with a defaults table. Character and team data are stored under `HCT.db.profile`.
2. **Event Propagation:**  
   Game events (e.g., leveling up) trigger event handlers in EventModule.lua. These handlers update the local AceDB data and then broadcast a serialized event using AceComm-3.0.
3. **Data Merging:**  
   Other clients receive these events via their CHAT_MSG_ADDON handler. Each client then deserializes the event and calls ProcessEvent to update its local copy of AceDB.
4. **UI Updates:**  
   The UIModule reads from AceDB (using helper functions) and updates the GUI to display the latest character stats, achievements, and team progress.

## Onboarding & Development Guidelines
- **Development Tips:**  
  - Use the provided helper functions (like GetDB()) for all database access.
  - Add print statements or use a debugging library to trace event propagation and data updates.
  - When modifying event handling or data updates, ensure that changes are broadcast so that all team members maintain a synchronized state.

## Setup and Reload Tips
- Clone the repo into C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\HardcoreChallengeTracker2
- Open the game and ensure the addon is enabled. Upon entering the world, the addon should say: "Hardcore Challenge Tracker 2 loaded. Use /hct2 to open the UI window."
- After pulling changes or doing some quick changes yourself, save your files and type "/reload" in-game. This will fully reload all your addons, including your new changes.
- Use LLMs to verify Lua and Ace3 syntax, and for understanding error messages.