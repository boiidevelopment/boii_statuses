# BOII Developmet - Statuses

## 🌍 Overview

This resource provides a comprehensive status system designed to replace built-in framework statuses with more depth and flexibility. 
It handles a variety of player flags, a buff and debuff system, and persistent player position saving. 
Created to integrate with the BOII framework, however this is also adaptable for use with other frameworks.

## 🌐 Features

- **Statuses:** Manage player-specific statuses with defaults including health, armor, hunger, thirst, stamina, oxygen, hygiene, and stress.
- **Flags:** Set and manage player flags. Defaults include dead, handcuffed, wanted, jailed, safezone, inside, and grouped.
- **Injuries Tracking:** Set and track specific body part injuries.
- **Buffs & Debuffs:** Comprehensive system for applying and managing temporary effects on players.
- **Position Tracking:** Automatically saves and stores players last known location.

## 💹 Dependencies

- `oxmysql`
- `boii_utils`

## 📦 Installation

### Prerequisites

- Downloading `boii_utils`:

1. Download the utility library from one of our platforms; 

- https://github.com/boiidevelopment/boii_utils
- https://boiidevelopment.tebex.io/package/5972340

2. Edit `client/config.lua` & `server/config.lua`:

- Set your framework choice under `config.framework`
- Set your notifications choice under `config.notifications`

Any other changes to the configs you wish to make can also be made.

### Script installation

1. Customisation:

- Customise `client/config.lua` & `server/config.lua`

2. Installation:

- Drag and drop `boii_statuses` into your server resources
- Add `ensure boii_statuses` into your `server.cfg` ensuring it is placed after `boii_utils`

3. Restart server:

- Once you have completed the above steps you are ready to restart your server and test out the script.

### Statuses initialization

1. Add the following export into your framework. 
- Typically you would want to add this into your player joined event if applicable or somewhere within a player object.

- Export
```lua
exports.boii_statuses:init(player.source)
```
- Example usage
```lua
RegisterNetEvent('boii:player_joined', function(player)
    exports.boii_statuses:init(player.source)
end)
```

- If this has been added correctly a status object will be created on players when they join the server.

## 📝 Notes

- This resource is built to be flexible and should integrate well with other frameworks with minimal adjustments.
- Always ensure you are using the latest version of `boii_utils` to avoid compatibility issues.
- You can intergrate this system with any hud of your choice, however currently this is up to you to figure out. Documentation for this will be added in time. 

## 🤝 Contributions

Contributions are welcome! If you'd like to contribute to the development of this resource, please fork the repository and submit a pull request or contact through discord.

## 📩 Support

https://discord.gg/boiidevelopment
