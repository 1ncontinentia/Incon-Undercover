# INCONTINENTIA'S UNDERCOVER / CIVILIAN RECRUITMENT

This is a complex and performance friendly undercover simulation for players and their AI subordinates. Work as a guerrilla cell, go undercover, recruit comrades, and cause mayhem.
SP / Coop and Dedi compatible.


### Requires:

* CBA


### FEATURES

#### General

* Virtually every factor that can affect your cover (within engine limitations and the caveats mentioned below) has been accounted for.
* Optimised to the max; should not noticably affect performance at all - no noticeable performance impact even during a stress test of 45+ undercover units simultaneously undercoverising several enemy patrols.
* Operates primarily on each client - server / client interaction is therefore kept to a minimum even when multiple players are undercover at the same time
* Compatible with RHS, ACE, ALiVE, Zeus, ASR, bCombat, TPWCAS, VCOM... pretty much everything its been tested on with the exception of factions that rely on randomisation (some factions' helmets and bandannas may not be recognised but the overall effect of this will be minimal - if you desperately want all features, use vanilla or RHS versions of these assets)

#### Comprehensive undercover / incognito simulation -

* Works on players and their AI group members
* Quick, easy setup: most aspects of the script are automatically implemented based on the settings you choose
* Can run in the background even when the mission isn't focused around undercover operations - automatically reduces checking overhead when unit isn't undercover so it should be practically unnoticeable
* No need to turn the script on or off - it just works
* No checkboxes, compromised notifications or any other "gamey" stuff; just an optional hint when you're obviously hostile and when you aren't - the rest is up to you
* Responds to whether the units are in vehicles or on foot, dressed as enemies or civilians, whether the unit's face fits or doesn't fit in with the faction they are pretending to be, or whether it is day or night, with each situation requiring players to behave appropriately
* Suspicious enemies may challenge or watch and follow undercover units if they act weirdly; the more weird stuff you do, the more likely they are to see through your disguise (you can even use this to your advantage to draw enemies attention away from another unit while they do something suspicious - just don't get too cocky or they will open fire on you)
* Players must "act" their role; doing weird stuff will raise suspicion and could blow your cover - if you point your weapon at an enemy and they see you doing it, they will get suspicious very quickly. Equally, if an enemy sees you crawling around or planting explosives, you're not going to stay undercover for long.
* Enemies will detect if undercover units are not of the ethnicity of the group they are impersonating; covering your face with a scarf or bandanna will reduce this but not as much as choosing undercover units whose faces fit in with the people they are trying to impersonate
* All actions have consequences, good or bad. If the MRAP you're driving gets a bit close to a patrol, moving into the back of it and out of sight of the enemy might just save your skin. Equally, putting a balaclava on when you're a civilian will attract a lot of attention - which is especially not good if you're already carrying a military rucksack.
* Once undercover units become compromised, enemies will remember the vehicles they are spotted in and (if they get a good look) the clothes they are wearing - change your clothing and if no enemies see you doing it, your new disguise may stick. The further you are away from where you were spotted, the more likely your new disguise is to work.
* Easily switch disguises: take enemy uniforms from nearby crates, vehicles, dead bodies and the ground (and order AI subordinates to do the same)
* Quickly conceal and un-conceal your (and your subordinates') weapons if you have the inventory space - without faffing with inventories
* Different configurable detection systems for regular and asymetric enemy forces
* Configurable high security zones require specific uniforms. Go without and enemies are likely to get suspicious of you very quickly. 

#### Stealth kills work -

* If nobody sees you firing a shot, your cover will remain intact
* BUT, enemies do remember suspicious units - if you kill someone and other enemies of that side already know who you are and that you are nearby, there is a chance your cover will be blown regardless
* However, your cover will return if you kill everyone who knows about you before they can spread the word

#### Different behaviour for regular and asymmetric forces

* Define a side as asymmetric and they will not be able to share your identity outside of the local area, but they will be better at spotting imposters
* Define a side as regular and your cover will stay blown for much longer and for a much wider area once compromised... but they may not have such a good nose for imposters

#### (Optional) Civilian Recruitment

* Undercover units can recruit civilians to join their group
* The more enemies you kill, and the more chaos you are associated with, the better your reputation will become
* The better your reputation, the more likely civilians are to join you
* Kill enemies without getting spotted and there is a chance they will lash out against civilians, with a potential to cause a civilian uprising (optional)
* Automatically arm ambient civilians with weapons and items which they may use if recruited or during an uprising
* Try to steal civilians' clothes from them (but be prepared that your reputation will take a hit or you may become compromised)
* (Requires ALiVE) Turn recruited units into a profiled group to be used by AI commander of the same faction as the undercover unit. Add the following to object init: this addaction ["Profile group","[player,'profileGroup'] remoteExecCall ['INCON_ucr_fnc_ucrMain',2]",[],1,false,true]);


### USAGE

1. Add all files from Incon-Undercover folder into your mission folder. If you already have a description.ext or initPlayerLocal.sqf then add the code to your existing files. (Make sure to delete any previous version of my undercover scripts). In description.ext, if the class is already defined (for instance, cfgFunctions), just add the #include line to the given class.

2. Configure your settings in the UCR_setup.sqf file in the INC_undercover folder (pay close attention to these, one wrong setting can lead to some weird behaviour). Do NOT comment out any lines as this will break the script. 

3. For each out of bounds area, place a marker over the area with "INC_tre" somewhere in the marker name (e.g. "MyMarkerINC_tre" or "INC_tre_sillyMarkerName_15"). The script will handle the rest. But if you want, you can also include other markers by listing them in the relevant array in UCR_setup.sqf.

4. Add in Incon Persistence if you want your band of merry men to persist between ALiVE sessions (this is now a separate script but automatically persists reputation).

5. For each playable undercover unit, put this in their unit init in the editor:

```
this setVariable ["isSneaky",true,true];
```

Non-player units in the undercover unit's group do not need anything; the script will run on them automatically on mission start.


### Caveats / Compatibility:
* Only one side can have undercover units at a time (so no east undercover and west undercover units undercoverising each other at the same time)
* Only one side can be defined as asymmetric at a time and only one side can be defined as regular - and both must be hostile to the undercover unit's side. So if having a three-way war, one side must be asym and the other regular.
* If having a three-way (...war), it is recommended to not have any incognito factions as an engine limitation means that incognito units (i.e. those disguised as the enemy) will be seen as friendly to all - could break the immersion if you're dressed as OPFOR and GreenFOR don't shoot at you when they should.
* For mission makers - just be aware that the following could affect your mission: enemy units may wander from their original positions to follow undercover units if they become suspicious. Also, when compromised by regular forces, an undercover unit's description will be shared across other enemies in the local area after some time if they don't kill everyone who knows about them
* Works on all tested mods with the exception of factions that use randomisation scripts such is the Iraqi Syrian Conflict Mod -- these will need a manual list of the possible enemy uniforms and gear (which is possible using the setup.sqf). If you find an incompatibility, tell me!
* In MP, ensure that respawn timers are set to at least 5 seconds to give the script a chance to recognise when a unit is dead and reset values accordingly.


### Credits

Massive thanks to Spyderblack723 for his help creating some of the functions and correcting my mistakes / oversights on the original release. Also for generally being super helpful over the past year as I've got into modding. Grumpy Old Man, Tajin and sarogahtyp are responsible for creating a performant detection script, which I then adapted and used as a basis for the undercover script, so thank you to those guys too. Also thanks to das attorney, davidoss, Bad Benson, Tankbuster, dedmen, fn_Quiksilver, marceldev89, baermitumlaut and Duda123 for some top optimisation tips. And huge thanks to accuracythruvolume for testing and feedback.


### In Detail: How it works

For the sake of this explanation, we'll separate behaviours into three categories: suspicious, attention-drawing and weird.

* Any suspicious behvaviour will make enemies see the unit as hostile right away. Two minor suspicious behaviours (being both armed and trespassing when not dressed as an enemy) or one major one (firing a weapon) will compromise the unit if they are witnessed. Units will remain suspicious as long as there are enemies who have reasonably fresh target knowledge of the unit, even if not doing anything suspicious anymore.

* Weird behaviour will not make enemies see the unit as hostile instantly, but each additional weird behaviour will increase the likelihood of nearby enemies blowing the unit's cover. Weird behaviour in proximity to enemies may cause some to take interest and follow the unit or become outright hostile straight away if you are acting strangely enough. If the unit isn't able to stop acting strangely or the suspicious enemies are not dealt with quickly (or you don't manage to escape), they may compromise the unit and any teammates who are also acting strangely nearby.

* Attention-drawing behaviour isn't necessarily weird, but it does make enemies notice you from further away. While dressed as the enemy, wearing the wrong helmet for your disguise is harder to detect from a distance than wearing the wrong vest, but both are weird. Wearing a vest will therefore add to your attention-drawing behaviour. Running, for instance, isn't so weird but will draw attention from enemies who are further away. Most weird behaviours will be attention-drawing too. The more attention-drawing behaviours you do, the further away units will start taking an interest in you, and therefore, the more likely they are to compromise you if you are also doing anything weird (like wearing NVGs while dressed as a civilian). The default detection radius can be configured in the UCR_setup file but this radius will expand and contract according to the undercover unit's attention-drawing behaviours, incognito status and vehicle, as well as environmental factors like moon intensity, overcast, rain and fog. It is recommended to not change the detection radius much from the default.

If the unit is compromised, the unit should try to kill all enemies who know about them before they spread the unit's identity across the AO.
After that, the unit becomes fully compromised and must change his disguise (clothes and either goggles / headgear) or leave the area completely to go undercover again.
Each time unit gets fully compromised, the effects of any weird behaviour will be amplified as enemies will be looking for them.

Suspicious / weird behaviours will vary according to factors including:
* Whether the unit is disguised as the enemy or a civilian
* Whether the unit is in a vehicle or on foot
* Whether the position in the vehicle is completely open, partially open, or completely closed
* What time of day and weather it is (dark / moonlit / overcast / fog at night, fog / rain during the day)
* Whether the unit has been compromised before

#### Appropriate behaviour: a guide for new spies
This is a short primer for the kinds of things to bear in mind while going undercover. It is by no means conclusive. The best advice is to act as normal as you can for the situation.

WHEN IN DISGUISE AS THE ENEMY:

When on foot, the following may count as weird behaviour:
* Wearing a backpack or vest that isn't normally used by the enemy faction
* Holding a weapon that isn't normally used by the enemy faction
* Wearing a hat or helmet that isn't normally used by the faction
* Running / sprinting (when not under fire)
* Crouching / crawling (when not under fire)
* Wearing a uniform that the unit was recently compromised in
* Raising your weapon (when not under fire)
* Pointing your weapon at an enemy

When in a vehicle, the following may count as weird behaviour:
* Driving with headlights off at night
* Wearing a non-disguise uniform or vest (if not in an enclosed vehicle)
* Wearing inappropriate headgear or goggles
* Wearing a HMD (like a night vision device)


WHEN IN DISGUISE AS A CIVILIAN:

When on foot, the following may count as weird behaviour:
* Wearing a helmet, HMD or balaclava
* Running / sprinting (when not under fire)
* Crouching / crawling (when not under fire)
* Wearing a uniform that the unit has been recently compromised in
* Smelling of cordite (having shot recently)
* Holding binoculars / laser designators / rangefinders

And suspicious:
* Wearing a non-civilian uniform or vest
* Wearing a compromised uniform
* Visibly carrying a weapon (including on your back - but not including holstered pistols)
* Trespassing onto a restricted area

When in a vehicle, the following may count as weird behaviour:
* Wearing a suspicious vest or uniform
* Wearing a HMD (night vision goggles)
* Wearing a compromised uniform
* Driving fast (the faster you go, the more attention you will draw)

And suspicious:
* Suspicious behaviour:
* Driving a non-civilian vehicle
* Driving a vehicle that has been compromised
* Trespassing onto a restricted area
* Driving more than 30m offroad (optional)
* Driving with headlights off at night

This is a short overview; it is good practice to make sure all aspects of your disguise are in keeping with your cover, even if it isn't listed in the behaviours above. If you are dressed like a civilian, act like one. If dressed like the enemy, keep your head down and don't draw attention to yourself.
