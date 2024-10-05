# Cheat Console Commands Mod for Abiotic Factor

[Official NexusMods page](https://www.nexusmods.com/abioticfactor/mods/28)

## Commands
Command | Aliases | Parameters | Description
------- | ------- | ---------- | -----------
Help | help | {command alias} | Prints a list of all commands or info about a single one
Status | status \| state \| settings |  | Prints status of the mod, which commands are active with which values
Disable All | disableall \| alloff |  | Disables all commands
God Mode | god \| godmode |  | Activates all health, stamina and status related features at once. (You will have to disable god mode to be able to toggle them seperatly)
Heal | heal |  | Player gets fully healed once (host only)
Infinite Health | health \| hp \| infhp \| infhealth |  | Player gets fully healed and becomes invincible (host only)
Infinite Stamina | stamina \| sp \| infsp \| infstamina |  | Player won't consume stamina (works partial as guest)
Infinite Durability | durability \| infdurability \| infdur |  | Keeps player's gear and hotbar items durability at maximum (works as guest)
Infinite Energy | energy \| infenergy |  | Keeps player's gear and held item charge/energy at maximum (host only)
Infinite Max Weight | infweight \| carryweight \| maxweight \| noweight \| infcarry |  | Increases maximum carry weight. (To refresh overweight status drop heavy items then pick them up again) (host only)
No Hunger | hunger \| nohunger \| eat |  | Player won't be hungry (works partial as guest)
No Thirst | thirst \| nothirst \| drink |  | Player won't be thirsty (works partial as guest)
No Fatigue | fat \| nofat \| fatigue \| nofatigue \| tired |  | Player won't be tired (works partial as guest)
Infinite Continence | con \| infcon \| InfiniteContinence \| noneed \| constipation |  | Player won't need to go to the toilet (works partial as guest)
Low Continence | lowcon \| lowcontinence \| nocon \| nocontinence \| laxative |  | Freezes the need to go to the toilet at low value. (Each time you seat down on Portal WC you have 1% change to trigger it) (host only)
No Radiation | rad \| norad \| radiation \| noradiation |  | Player can't receive radiation (works partial as guest)
Perfect Temperature | nocold \| nohot \| temperature \| temp \| perfecttemp |  | Makes player temperature resistant. (host only)
Infinite Oxygen | oxygen \| info2 \| o2 \| infoxygen |  | Makes player breath under water. (host only)
Invisible | invisible \| invis \| invisibility |  | Makes player invisible to NPCs (host only)
No Fall Damage | falldmg \| falldamage \| nofall \| nofalldmg \| nofalldamage |  | Prevents player from taking fall damage (host only)
Free Crafting (Debug function) | freecraft \| freecrafting \| crafting \| craft |  | Allows player to craft all recipes, simulates possession of all items and allows to unlock all chests without keys. (Warning: You may need to restart the game to deactivate it completely!) (host only)
Instant Crafting | InstantCrafting \| instacraft \| instantcraft \| instcraft |  | Reduces crafting duration for all recipes to minimum (works as guest)
Set Money | money | {value} | Set money to desired value (works as guest)
Infinite Ammo | infammo \| ammo \| infiniteammo |  | Keeps ammo of ranged weapons replenished (as guest works somehow, but is bugged)
No Recoil | norecoil \| recoil \| weaponnorecoil |  | Reduces weapon's fire recoil to minimum (haven't found a way to remove completely yet) (works as guest)
No Sway | nosway \| sway \| noweaponsway |  | Removes weapon's sway  (works as guest)
Leyak Cooldown | leyakcd \| leyakcooldown \| cdleyak | {minutes} | Changes Leyak's spawn cooldown in minutes (Default: 15min). The cooldown will be reapplied by the mod automatically each time you start the game. (To disable the command set value to 0 or 15) (host only)
No Clip | noclip \| clip \| ghost |  | Disables player's collision and makes him fly (host only)
Add Skill Experience | addxp \| addexp \| xpadd \| skillxp \| skillexp \| skill \| skillxp | {skill alias} {XP value} | Adds XP to specified Skill (host only)
Remove Skill Experience | removexp \| removeexp \| resetxp \| resetexp \| resetskill \| resetlevel \| resetlvl | {skill alias} | Removes All XP from specified Skill (host only)
Reset All Skills | resetallskills \| resetallskill \| resetallxp \| resetallexp \| resetalllvl |  | Resets all character skills! (works as guest)
Master Key | masterkey \| key \| keys \| opendoor \| opendoors |  | Allows to open all doors (host only)
Weather Event | setweather \| nextweather \| weatherevent \| weather | {weather} | Sets weather event for the next day (host only)
Reset Portal Worlds | resetportals \| resetportal \| resetworlds \| resetportalworlds \| resetvignettes |  | Resets Portal Worlds (host only)
Kill All Enemies | killall \| killnpc \| killnpcs \| killallnpc \| killallnpcs \| killallenemies \| killenemies |  | Kill all enemy NPCs in your vicinity. (host only)
List Locations | locations \| showloc \| showlocations \| loc \| locs |  | Shows all saved locations
Save Location | savelocation \| saveloc \| setloc \| wp \| savewp \| setwp \| waypoint \| setwaypoint \| savewaypoint | {name} | Saves your current position and rotation under an assigned name
Load Location | loadlocation \| loadloc \| loadwp \| tp \| goto \| loadwaypoint \| teleport | {name} | Teleports you to a named location that was previously saved (host only)
Player List | playerlist \| listplayers \| players |  | Prints a list of all players in the game. Format: (index): (player name)
Teleport To Player | toplayer \| teleportto \| tpto | {name/index} | Teleports to a player based on their name or index (host only)
Teleport To Me | tome \| teleporttome \| pull | {name/index} | Teleports a player to yourself based on their name or index (host only)
Kill Player | smite \| kill \| execute | {name/index} | Kills a player based on their name or index (host only)
Revive Player | revive \| res \| resurrect | {name/index} | Revive a dead palyer (host only)
Speedhack | speedhack \| speedmulti \| speedscale | {multiplier/scale} | Sets a speed multiplier for your character's Walk and Sprint speed. (Default speed: 1.0) (host only)
Player Gravity Scale | playergravity \| playergrav \| pg \| setpg | {scale} | Sets player's gravity scale. (Default scale: 1.0) (host only)
Give Skill Experience to Player | givexp | {name/index} {skill alias} {XP value} | Gives Skill XP to a player (host only)
Remove Skill Experience from Player | takexp | {name/index} {skill alias} | Remove All Skill XP from a player (host only)
Send to Distant Shore | DistantShore \| dshore \| portalwc |  | Sends player to Distant Shore if [REDACTED] is deployed/placed. (host only)
