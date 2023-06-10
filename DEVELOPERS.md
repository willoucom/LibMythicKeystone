# LibMythicKeystone

LibMythicKeystone is a library that retrieves and synchronizes mythical dungeon keys.
The library exposes account character keys for use in various addons.

## Usage

In your addon:
```
local lib = LibStub("LibMythicKeystone-1.0")
if not lib then return end
```

Then you can access keys with the following methods :

- Get the current character's key : `lib.getMyKeystone()`
- Get rerolls' keys : `lib.getAltsKeystone()`
- Get party keys (in beta, subject to change) : `lib.getPartyKeystone()`
- Get guild keys (in beta, subject to change) : `lib.getGuildKeystone()`

Data format:
```
{
    ["class"] = CLASSNAME in uppercase for C_ClassColor.GetClassColor(key["class"]):GenerateHexColorMarkup()
    ["name"] = Name of the character
    ["realm"] = Realm of the character
    ["guild"] = Guild of the character
    ["fullname"] = Name-Realm of the character, also the key of the table
    ["current_key"] = ID of the keystone for  C_ChallengeMode.GetMapUIInfo(key["current_key"])
    ["current_keylevel"] = Level of the keystone
    ["week"] = Data are valid this Week only
}
```

## Debug 

You can display a "nice" debug toolbar

enter command in chat : 

- `/lmk debug on` : enable debug mode
- `/lmk debug off` : disable debug mode

then reload your interface with `/reload`

## Libaries used

- The awesome LibStub https://wowpedia.fandom.com/wiki/LibStub
- The awesome ChatThrottleLib https://wowpedia.fandom.com/wiki/ChatThrottleLib