# INCONTINENTIA'S UNDERCOVER / CIVILIAN RECRUITMENT

This script allows a player and his subordinate teammates to dress as civilians and go incognito, recruit actual civilians, and cause mayhem.
It should work well for SP / small COOP missions (up to 10 players) and has been tested on a dedicated server.
I cannot vouch for server performance above 10 players.

### Requires:

* ALiVE (for civilian recruitment)
* CBA
* iniDBI2 (for group persistence between ALiVE persistent sessions)

### FEATURES

* Integrates with ALiVE
* Undercover simulation for sneaky beaky / guerilla missions without killing performance
* Works on players and their AI group members
* Recruit civilians and cause mayhem
* Kill enemies without getting spotted and there is a chance they will lash out against civilians (optional)
* Order recruited civilians to hide their weapons if they have inventory space
* Order them to get concealed weapons out without faffing about with their inventories
* Define a side as asymmetric or regular for different detection systems
* (EXPERIMENTAL) Persistence for non-playable AI teammates (requires INC_groupPersist - included - and iniDBI2).
* (EXPERIMENTAL) Turn recruited units into a profiled group to be used by AI commander of the same faction as the undercover unit (add to object init: this addaction ["Profile group","[player,'profileGroup'] remoteExecCall ['INCON_fnc_ucrMain',2]",[],1,false,true]);


Undercover units remain incognito unless they

    (a) get too close to military units (of enemy side defined in INT_setup.sqf),
    (b) wear a suspicious uniform or vest (configurable),
    (c) openly carry any military equipment, such as weapons, binoculars, laser designators, HMDs (like night vision goggles),
    (d) trespass into a forbidden area
    (e) become compromised


Enemies ignore the AI group members of undercover units unless they

    (a) wear a suspicious uniform or vest (configurable),
    (b) openly carry any weapon / military equipment,
    (c) are seen doing naughty things (see below)


Stealth kills work -

    * If nobody sees you firing a shot, your cover will remain intact
    * BUT, enemies do remember suspicious units - if you kill someone and other enemies of that side already know who you are and that you are nearby, there is a chance your cover will be blown regardless
    * However, your cover will return if you kill everyone who knows about you before they can spread the word
    * Go for quick, clean kills and eliminate anyone before they can spread the word, and your cover will remain intact

Different behaviour for regular and asymmetric forces

    * Define a side as asymmetric and they will not share your identity outside of the local area (maximum 1 regular side and 1 asymmetric side supported at present)
    * Define a side as regular and your cover will stay blown for much longer and for a much wider area once compromised

(Optional) Civilian Recruitment

* Undercover units can recruit civilians to join their group
* The more enemies you kill, the better your reputation will become
* The better your reputation, the more likely civilians are to join you
* Simple incognito script for recruited civilians - if they are openly armed or enemies have seen them acting suspiciously, they will be seen as hostile to enemies until all enemies that know about them have been killed
* If they have the inventory space, armed civilians can hide their weapons to remain incognito using the group actions radio menu (command menu -> 6, the same menu as "open subordinate's inventory"), and get them out when required using the same radio menu
* You can dismiss civilians at any time using the radio menu
* Ordinary ALiVE-spawned civilians may carry concealed weapons and pistols on their person or in backpacks (optional)
* If you kill an enemy and remain undetected, their side may lash out against civilians, which could in turn prompt reprisals from any armed civilians in the area (Optional)

### Caveats:
* Only one side can have undercover units at a time (so no east undercover and west undercover undercoverising each other at the same time)
* Only one side can be defined as asymmetric at a time and only one side can be defined as regular. So if having a three-way war, one side must be asym and the other regular.

### USAGE

Change your settings in the UCR_setup.sqf file in the INC_undercover folder.

For each playable undercover unit, put this in their unit init in the editor:

```
this setVariable ["isSneaky",true,true];
```

Non-playable AI units in the undercover unit's group do not need anything; the script will run on them automatically as long as the group leader is a playable undercover unit.


For each out of bounds area, place a marker over the area with "INC_tre" somewhere in the marker name (e.g. "MyMarkerINC_tre" or "INC_tre_sillyMarkerName_15"). The script will handle the rest.


In initPlayerLocal.sqf:

```
if (player getVariable ["isSneaky",false]) then {
    [player] execVM "INCON\INC_undercover\initUCR.sqf";
};
```


In description.ext:

```
class Extended_InitPost_EventHandlers {
     class CAManBase {
		init = "_this call (compile preprocessFileLineNumbers 'INCON\INC_undercover\unitInitsUndercover.sqf')";
	};
};

class CfgFunctions
{
	#include "INCON\cfgFunctions.hpp"
};

class CfgRemoteExec
{
   class Functions
   {
       mode = 2;
       jip = 1;
       #include "INCON\functionsWhitelist.hpp"
   };
};

```



### FUTURE PLANS

* Better support for going incognito as an enemy unit
