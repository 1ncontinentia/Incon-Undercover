# INC_Scripts_A3
Incontinentia's Mission Scripts for Arma 3

INC_Scripts_A3 is a collection of scripts for Arma 3 mission makers. They are primarily designed to be used with ALiVE and ACE in SP / Coop scenarios but some can be used standalone.

These are currently available as a (very) early Alpha. More scripts will be released in the upcoming weeks as and when I get the time to test them.

Requires CBA.

## Instructions

Place all files in your mission root folder. If you already have a description.ext or init.sqf, add the lines from these files into your pre-existing ones.

Inside the INCON\INC_undercover and INCON\INC_intel folders, you will find the XXX_setup.sqf files. Edit these to your preference. Also read the readme in the respective folders to find out how to set up the scripts fully for your mission.

## Overview

(Check individual readme files in the respective addon folders for more information).

#### INC_Undercover
Go undercover as a civilian, become a local hero, recruit other civilians, cause mayhem. Features an optimised detection system that allows you to maintain cover as long as you are careful and choose your targets well.

Requires: CBA, ALiVE Civ Placement Modules (for civilian recruitment)

Status: Experimental release. Feature complete, untested in Coop but works well in dedicated server / SP environments.

#### INC_Intel
Enemy units drop intel when they are killed. Allows units to hack into enemy radio networks and see nearby groups on the map, as well as track cellphone contacts. Also reveals enemy installations.

Requires: CBA

Status: Initial (early Alpha) release.

#### INC_groupPersist

Provides persistence for non-playable AI teammates (in player group) between play sessions when ALiVE data is present using iniDBI2. Saves full unit information for up to 11 AI teammates and loads it when there is corresponding ALiVE persistent player information.

To have full persistent AI teammates you need to:

(a) have mission time persistence to be set to on (so iniDBI2 can tally it's information with ALiVE's persistent data),

(b) save and exit the server at the end of each session,  

(c) when loading the mission again, make sure the mission time is the same as it was when you last saved and exited (if not, your persistent group won't load),

(d)  don't play the same mission in multiplayer in the meantime if persistent data hasn't loaded (this will also overwrite your saved group data).

No further configuration required, just load the iniDBI2 mod on server and client and it will save your group state periodically (including health, loadout, skill etc.) until you save and exit the server.

Requires: CBA, ALiVE, iniDBI2, (works best with TADST in SP / Coop locally hosted dedicated server sessions)

Status: Experimental release.

#### INC_Surrender
Adds a new element to the battlefield: fear.

Get close enough to an enemy unit and order them to surrender; whether they do surrender depends on a number of factors, including their morale, whether you have taken them by surprise, their weapon, your weapon, its health, and how close you are when you tell them to surrender.

Ambush a patrol and if they are outnumbered, surprised or unskilled, they might make a tactical withdrawal, give up and run or even drop their weapons and put their hands up.

Keep an eye on surrendered units, you never know what they might try.

Requires: CBA, ACE.

Status: Unreleased.



### Credits

Spyderblack723 - contributed several useful functions and a massive amount of help over the past year
Dixon13 - wrote the original intel spawning script
ARJay - wrote the original unit tracking script
