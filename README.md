# INCONTINENTIA'S UNDERCOVER / CIVILIAN RECRUITMENT

This is a complex and performance friendly undercover simulation for players and their AI subordinates. Work as a guerrilla cell, go undercover, recruit comrades, and cause mayhem.
SP / Coop and Dedi compatible.

### Requires:

* CBA

### USAGE

1. Add all files from Incon-Undercover folder into your mission folder. If you already have a description.ext or initPlayerLocal.sqf then add the code to your existing files. (Make sure to delete any previous version of my undercover scripts)

2. Configure your settings in the UCR_setup.sqf file in the INC_undercover folder (pay close attention to these, one wrong setting can lead to some weird behaviour).

3. For each out of bounds area, place a marker over the area with "INC_tre" somewhere in the marker name (e.g. "MyMarkerINC_tre" or "INC_tre_sillyMarkerName_15"). The script will handle the rest. But if you want, you can also include other markers by listing them in the relevant array in UCR_setup.sqf.

4. Add in Incon Persistence if you want your band of merry men to persist between ALiVE sessions (this is now a separate script but automatically persists reputation).

5. For each playable undercover unit, put this in their unit init in the editor:

```
this setVariable ["isSneaky",true,true];
```

Non-player units in the undercover unit's group do not need anything; the script will run on them automatically on mission start.




### FEATURES

#### General

* Optimised detection system: enemies respond in a realistic and credible way to undercover units without destroying performance (checks are minimal during firefights)
* Operates primarily on each client - server performance impact is therefore kept to a minimum even when multiple players are undercover at the same time
* Works on players and their AI group members

#### Comprehensive undercover / incognito simulation -

* Quick, easy setup: most aspects of the script are automatically implemented based on the settings you choose
* Can run in the background even when the mission isn't focused around undercover operations - automatically reduces overhead when unit isn't undercover
* No need to turn the script on or off - it just works
* Responds to whether the units are in vehicles or on foot, dressed as enemies or civilians, or whether it is day or night, with each situation requiring players to behave appropriately
* Players must "act" their role; doing weird stuff will raise suspicion and could blow your cover - something as simple as lowering your weapon might mean the difference between a nearby enemy becoming suspicious and being able to walk right past a patrol unscathed
* Suspicious enemies may challenge or watch and follow undercover units if they act weirdly; the more weird stuff you do, the more likely they are to see through your disguise (you can even use this to your advantage to draw enemies attention away from another unit - just don't get too cocky)
* Enemies will detect if undercover units are the nationality of the group they are impersonating; covering your face with a scarf or bandanna will reduce this but not as much as choosing undercover units whose faces fit in with the people they are trying to impersonate
* Once undercover units become compromised, enemies will remember the vehicles they are spotted in and clothes they are wearing
* Change your clothing (both uniform and either headgear or goggles) and if no enemies see you doing it, your new disguise may stick
* Easily switch disguises: take enemy uniforms from nearby crates, vehicles, dead bodies and the ground (and order AI subordinates to do the same)
* Quickly conceal and un-conceal your (and your subordinates') weapons if you have the inventory space - without faffing with inventories
* Different configurable detection systems for regular and asymetric enemy forces
* Compatible with RHS, ACE, ALiVE, Zeus, ASR, bCombat, TPWCAS, VCOM... pretty much everything I've tried (some factions' helmets and bandannas may not be recognised but the overall effect of this will be minimal - if you desperately want all features, use vanilla or RHS versions of these assets)

#### Stealth kills work -

* If nobody sees you firing a shot, your cover will remain intact
* BUT, enemies do remember suspicious units - if you kill someone and other enemies of that side already know who you are and that you are nearby, there is a chance your cover will be blown regardless
* However, your cover will return if you kill everyone who knows about you before they can spread the word

#### Different behaviour for regular and asymmetric forces

* Define a side as asymmetric and they will not be able to share your identity outside of the local area, but they will be better at spotting imposters
* Define a side as regular and your cover will stay blown for much longer and for a much wider area once compromised, but they may not have such a good nose for imposters

#### (Optional) Civilian Recruitment

* Undercover units can recruit civilians to join their group
* The more enemies you kill, and the more chaos you are associated with, the better your reputation will become
* The better your reputation, the more likely civilians are to join you
* Kill enemies without getting spotted and there is a chance they will lash out against civilians, with a potential to cause a civilian uprising (optional)
* Arm ambient civilians with weapons and items which they may use during an uprising
* Try to steal civilians' clothes from them (but be prepared that your reputation will take a hit or you may become compromised)
* (Requires ALiVE) Turn recruited units into a profiled group to be used by AI commander of the same faction as the undercover unit (add to object init: this addaction ["Profile group","[player,'profileGroup'] remoteExecCall ['INCON_ucr_fnc_ucrMain',2]",[],1,false,true]);


### Caveats / Compatibility:
* Only one side can have undercover units at a time (so no east undercover and west undercover guys undercoverising each other at the same time)
* Only one side can be defined as asymmetric at a time and only one side can be defined as regular - and both must be hostile to the undercover unit's side. So if having a three-way war, one side must be asym and the other regular. If those enemy sides are fighting each other, it is recommended to not have any incognito factions as an engine limitation means that incognito units (i.e. those disguised as the enemy) will be seen as friendly to all - could break the immersion if you're dressed as OPFOR and GreenFOR don't shoot at you when they should.
* Should work with all AI mods (tested with ASR, bCombat and TPWCAS but no reason why others wouldn't work)

### Credits

Massive thanks to Spyderblack723 for his help creating some of the functions and correcting my mistakes / oversights on the original release. Also for generally being super helpful over the past year as I've got into modding. Grumpy Old Man, Tajin and sarogahtyp are responsible for creating a performant detection script, which I then adapted and used as a basis for the undercover script, so thank you to those guys too. Also thanks to das attorney, davidoss, Bad Benson and Tankbuster for some top optimisation tips.

### In Detail: How it works

For the sake of this explanation, we'll separate behaviours into three categories: suspicious, attention-drawing and weird.

* Any suspicious behvaviour will make enemies see the unit as hostile right away. Two minor suspicious behaviours seen at once (being both armed and trespassing) or one major one (shooting / killing an enemy) will compromise the unit. Units will remain suspicious as long as there are enemies who have reasonably fresh target knowledge of the unit, even if not doing anything suspicious anymore.

* Weird behaviour will not make enemies see the unit as hostile instantly, but each additional weird behaviour will increase the likelihood of nearby enemies who could blow the units cover. Weird behaviour in proximity to enemies may cause some to take interest or become outright hostile straight away if you are acting strange enough. If the unit isn't able to stop acting strangely or the suspicious enemies are not dealt with quickly (or you manage to escape somehow), they may compromise the unit and any teammates who are also acting strangely nearby.

* Attention-drawing behaviour isn't necessarily weird, but it does make enemies notice you from further away. While dressed as the enemy, wearing the wrong helmet for your disguise is harder to detect from a distance than wearing the wrong vest, but both are similarly weird. Wearing a vest will therefore add to your attention-drawing behaviour. Running, for instance, isn't so weird but will draw attention from enemies who are further away. Most weird behaviours will be attention-drawing too. The more attention-drawing behaviours you do, the further away units will start taking an interest in you, and therefore, the more likely they are to compromise you if you are doing anything weird (like wearing NVGs while dressed as a civilian). The default detection radius can be configured in the UCR_setup file but this radius will expand and contract according to the undercover unit's attention-drawing behaviours, incognito status and vehicle, as well as environmental factors like moon intensity, overcast, rain and fog. It is recommended to not increase the detection radius much beyond the default.

If the unit is compromised, the unit must kill all enemies who know about them before they spread the units identity across the AO.
After that, the unit becomes fully compromised and must change his disguise (clothes and either goggles / headgear) to go undercover again.
Each time unit gets fully compromised, the effects of any weird behaviour will be amplified as enemies will be looking for them.

Suspicious / weird behaviours will vary according to:
* Whether the unit is disguised as the enemy
* Whether the unit is in a vehicle or on foot
* What time of day and weather it is (dark / moonlit / overcast / fog at night, fog / rain during the day)
* Whether the unit has been compromised before

#### Appropriate behaviour: a guide for new spies
This is a short primer for the kinds of things to bear in mind while going undercover. It is by no means conclusive.

WHEN IN DISGUISE AS ENEMY:

When on foot, the following may count as weird behaviour:
* Wearing a backpack or vest that isn't normally used by the enemy faction
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
* Wearing a helmet, HMD or balaclava
* Running / sprinting (when not under fire)
* Crouching / crawling (when not under fire)
* Wearing a uniform that the unit was recently compromised in
* Smelling of cordite (having shot recently)
* Raising your weapon

And suspicious:
* Wearing a suspicious uniform or vest
* Wearing a compromised uniform
* Holding a weapon or holding binoculars / laser designators / rangefinders
* Visibly carrying a weapon (including on your back - but not including holstered pistols)
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
