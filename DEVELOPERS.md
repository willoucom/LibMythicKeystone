# LibMythicKeystone

LibMythicKeystone is a library that retrieves and synchronizes Mythic+ keystones.
The library exposes keystone data across your characters for use in various addons.

## Usage

In your addon:
```lua
local lib = LibStub("LibMythicKeystone-1.0")
if not lib then return end
```

Then you can access keystones with the following methods:

- Get the current character's keystone: `lib.getMyKeystone()`
- Get alts' keystones: `lib.getAltsKeystone()`
- Get party keystones (in beta, subject to change): `lib.getPartyKeystone()`
- Get guild keystones (in beta, subject to change): `lib.getGuildKeystone()`

Data format:
```lua
{
    ["class"] = CLASSNAME,          -- Uppercase, use with C_ClassColor.GetClassColor(key["class"]):GenerateHexColorMarkup()
    ["name"] = "CharacterName",
    ["realm"] = "RealmName",
    ["guild"] = "GuildName",
    ["fullname"] = "Name-Realm",    -- Unique key, use with C_ChallengeMode.GetMapUIInfo()
    ["current_key"] = 0,            -- Dungeon map ID, use with C_ChallengeMode.GetMapUIInfo(key["current_key"])
    ["current_keylevel"] = 0,       -- Level of the keystone
    ["weeklybest"] = 0,             -- Best keystone level completed this week
    ["weeklycount"] = 0,            -- Number of Mythic+ runs completed this week
    ["week"] = 0,                   -- Week number, data is only valid for the current week
}
```

## Debug

You can display a debug toolbar by entering the following commands in chat:

- `/lmk debug on` — enable debug mode
- `/lmk debug off` — disable debug mode

Then reload your interface with `/reload`.

## Libraries used

- [LibStub](https://wowpedia.fandom.com/wiki/LibStub)
- [ChatThrottleLib](https://wowpedia.fandom.com/wiki/ChatThrottleLib)
