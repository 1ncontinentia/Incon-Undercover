# INCONTINENTIA'S UNDERCOVER / CIVILIAN RECRUITMENT

This is a complex and performance friendly undercover simulation for players and their AI subordinates. Work as a guerrilla cell, go undercover, recruit civilians, and cause mayhem.
SP / Coop and Dedi compatible.

### Requires:

* CBA

### FEATURES

#### General

* Optimised detection system: enemies respond in a realistic and credible way to undercover units without destroying performance (tested on 20+ undercover units simultaneously with +/- 4 fps difference)
* Operates primarily on each client, very little information is passed to the server - server performance impact is therefore kept to a minimum even when multiple players are undercover at the same time
* Works on players and their AI subordinates
* Players must "act" their role; doing weird stuff will raise suspicion and could blow your cover
* Responds to whether the units are in vehicles or on foot, dressed as enemies or civilians, or whether it is day or night, with each situation requiring players to behave appropriately
* Suspicious enemies may challenge units or watch and follow them if they act strange; the more weird stuff you do, the more likely they are to see through your disguise
* Once undercover units become compromised, enemies will remember the vehicles they are spotted in and clothes they are wearing
* Change your clothing (both uniform and either headgear or goggles) and if no enemies sees you doing it, your new disguise may stick
* Easily switch disguises: take enemy uniforms from crates, vehicles, dead bodies and the ground (and order AI subordinates to do the same)
* Quickly conceal and un-conceal your (and your subordinates') weapons if you have the inventory space - without faffing with inventories
* Different configurable detection systems for regular and asymetric enemy forces

#### Stealth kills work -

* If nobody sees you firing a shot, your cover will remain intact
* BUT, enemies do remember suspicious units - if you kill someone and other enemies of that side already know who you are and that you are nearby, there is a chance your cover will be blown regardless
* However, your cover will return if you kill everyone who knows about you before they can spread the word
* Go for quick, clean kills and eliminate anyone before they can spread the word, and your cover will remain intact

#### Different behaviour for regular and asymmetric forces

* Define a side as asymmetric and they will not be able to share your identity outside of the local area, but they will be better at spotting imposters
* Define a side as regular and your cover will stay blown for much longer and for a much wider area once compromised, but they may not have such a good nose for imposters

#### (Optional) Civilian Recruitment

* Undercover units can recruit civilians to join their group
* The more enemies you kill, and the more chaos you are associated with, the better your reputation will become
* The better your reputation, the more likely civilians are to join you
* Kill enemies without getting spotted and there is a chance they will lash out against civilians, with a potential to cause a civilian uprising (optional)
* Arm ambient civilians with weapons and items which they may use during an uprising
* Steal civilians' clothes from them (but be prepared that your reputation will take a hit)
* (Requires ALiVE) Turn recruited units into a profiled group to be used by AI commander of the same faction as the undercover unit (add to object init: this addaction ["Profile group","[player,'profileGroup'] remoteExecCall ['INCON_fnc_ucrMain',2]",[],1,false,true]);


### Caveats / Compatibility:
* Only one side can have undercover units at a time (so no east undercover and west undercover guys undercoverising each other at the same time)
* Only one side can be defined as asymmetric at a time and only one side can be defined as regular. So if having a three-way war, one side must be asym and the other regular.
* Should work with all AI mods (tested with ASR, bCombat and TPWCAS but no reason why others wouldn't work)

### Credits

Massive thanks to Spyderblack723 for his help creating some of the functions and correcting my mistakes / oversights on the original release. Also for generally being super helpful over the past year as I've got into modding. Grumpy Old Man, Tajin and sarogahtyp are responsible for creating a performant detection script, which I then adapted and used as a basis for the undercover script, so thank you to those guys too. Also thanks to das attorney, davidoss and Tankbuster for some top optimisation tips.

### USAGE

1. Add all files from Incon-Undercover folder into your mission folder. If you already have a description.ext or initPlayerLocal.sqf then add the code to your existing files.

2. VERY IMPORTANT: Configure your settings in the UCR_setup.sqf file in the INC_undercover folder.

3. For each playable undercover unit, put this in their unit init in the editor:

```
this setVariable ["isSneaky",true,true];
```

Non-playable AI subordinates in the undercover unit's group do not need anything; the script will run on them automatically as long as the group leader is a playable undercover unit.


4. For each out of bounds area, place a marker over the area with "INC_tre" somewhere in the marker name (e.g. "MyMarkerINC_tre" or "INC_tre_sillyMarkerName_15"). The script will handle the rest. But if you want, you can also include other markers by listing them in the relevant array in UCR_setup.sqf.



### In Detail: How it works

For the sake of this explanation, we'll separate behaviours into two categories: suspicious and weird.

* Any suspicious behvaviour will make enemies see the unit as hostile automatically. Two minor suspicious behaviours seen at once (being both armed and trespassing) or one major one (shooting / killing an enemy) will compromise the unit.
* Weird behaviour will not make enemies see the unit as hostile instantly, but each additional weird behaviour will increase the radius and likelihood of nearby enemies who could blow the units cover. Weird behaviour in proximity to enemies may cause some to take interest. If they are not dealt with quickly, they may compromise the unit. Units will remain suspicious as long as there are enemies who have reasonably fresh target knowledge of the unit, even if not doing anything suspicious anymore. The default detection radius can be configured in the UCR_setup file but this radius will expand and contract according to the unit's speed, behaviour, vehicle, as well as environmental factors like moon intensity, overcast and fog.

If the unit is compromised, the unit must kill all enemies who know about them before they spread the units identity across the AO.
After that, the unit becomes fully compromised and must change his disguise (clothes and either goggles / headgear) to go undercover again.
Each time unit gets fully compromised, the effects of any weird behaviour will be amplified as enemies will be looking for them.

Suspicious / weird behaviours will vary according to:
* Whether the unit is disguised as the enemy
* Whether the unit is in a vehicle or on foot
* What time of day and weather it is (dark / moonlit / overcast / fog at night, fog during the day)
* Whether the unit has been compromised before

#### Appropriate behaviour: a guide for new spies
This is a short primer for the kinds of things to bear in mind while going undercover. It is by no means conclusive.

WHEN IN DISGUISE AS ENEMY:

When on foot, the following may count as weird behaviour:
* Wearing a backpack or vest that doesn't fit the disguise
* Holding a weapon that isn't normally used by the enemy faction
* Wearing a hat or helmet that isn't normally used by the faction
* Running / sprinting (when not under fire)
* Crouching / crawling (when not under fire)
* Wearing a uniform that the unit was recently compromised in

When in a vehicle, the following may count as weird behaviour:
* Driving with headlights off at night
* Wearing a non-disguise vest (if not in a tank)


WHEN NOT IN DISGUISE AS ENEMY:

When on foot, the following may count as weird behaviour:
* Wearing a helmet or balaclava
* Running / sprinting (when not under fire)
* Crouching / crawling (when not under fire)
* Wearing a uniform that the unit was recently compromised in
* Visibly carrying a weapon (including on your back - but not including holstered pistols)

And suspicious:
* Wearing a suspicious uniform, vest or HMD
* Wearing a compromised uniform
* Holding a weapon or holding binoculars / laser designators / rangefinders
* Trespassing onto a restricted area

When in a vehicle, the following may count as weird behaviour:
* Driving with headlights off at night
* Wearing a suspicious vest or uniform
* Wearing a HMD (night vision goggles)
* Wearing a compromised uniform
* Driving fast (the faster you go, the more people will look at you)

And suspicious:
* Suspicious behaviour:
* Driving a suspicious vehicle
* Driving a vehicle that has been compromised
* Trespassing onto a restricted area
* Driving more than 30m offroad (optional)
* Driving with headlights off at night

It is good practice to make sure all aspects of your disguise are in keeping with your cover. If you are dressed like a civilian, act like one. If dressed like the enemy, don't draw attention to yourself.
